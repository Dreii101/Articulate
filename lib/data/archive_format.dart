import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

const archiveMagic = [65, 82, 84, 73, 67, 85, 76, 65, 84, 69, 0, 1];
const legacyLogicalTables = [
  'practice_sessions',
  'responses',
  'timing_segments',
  'review_records',
  'app_settings',
  'writing_workspaces',
  'reading_workspaces',
  'memory_speeches',
  'memory_versions',
  'memory_workspaces',
  'debate_workspaces',
  'debate_stages',
  'impromptu_queues',
  'impromptu_workspaces',
  'audio_recordings',
  'audio_observations',
];

const logicalTables = [
  ...legacyLogicalTables,
  'custom_exercises',
  'practice_contexts',
  'recall_schedules',
];
List<String> archiveTables(Map<String, dynamic> manifest) =>
    manifest['schemaVersion'] == 8 ? legacyLogicalTables : logicalTables;

class DataFailure implements Exception {
  const DataFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class DataCancelled extends DataFailure {
  const DataCancelled()
    : super('Cancelled. Your current library was not replaced.');
}

class OperationToken {
  bool cancelled = false;
  void check() {
    if (cancelled) {
      throw const DataCancelled();
    }
  }
}

class ArchiveLimits {
  const ArchiveLimits({
    this.total = 8 * 1024 * 1024 * 1024,
    this.file = 2 * 1024 * 1024 * 1024,
    this.logical = 256 * 1024 * 1024,
    this.manifest = 4 * 1024 * 1024,
    this.entries = 10000,
    this.rows = 200000,
    this.line = 4 * 1024 * 1024,
  });
  final int total, file, logical, manifest, entries, rows, line;
}

bool validArchivePath(String path) =>
    path == 'ATTRIBUTION.txt' ||
    logicalTables.any((t) => path == 'data/$t.jsonl') ||
    RegExp(r'^audio/[a-f0-9]{32}\.wav$').hasMatch(path);
Future<void> regularFile(File file) async {
  if (await FileSystemEntity.type(file.path, followLinks: false) !=
      FileSystemEntityType.file) {
    throw const DataFailure('A required file is missing or is a link.');
  }
}

Future<void> plainDirectory(Directory directory) async {
  final type = await FileSystemEntity.type(directory.path, followLinks: false);
  if (type != FileSystemEntityType.notFound &&
      type != FileSystemEntityType.directory) {
    throw const DataFailure('Unsafe storage directory. No data was changed.');
  }
  if (type == FileSystemEntityType.directory) {
    final parent = await directory.absolute.parent.resolveSymbolicLinks(),
        name = directory.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final expected = Directory.fromUri(
          Directory(parent).uri.resolve('${Uri.encodeComponent(name)}/'),
        ).uri.normalizePath().toString(),
        actual = Directory(await directory.resolveSymbolicLinks()).uri
            .normalizePath()
            .toString();
    if (Platform.isWindows
        ? expected.toLowerCase() != actual.toLowerCase()
        : expected != actual) {
      throw const DataFailure('Linked storage directories are not supported.');
    }
  }
}

Future<String> fileDigest(File file) async {
  await regularFile(file);
  return (await sha256.bind(file.openRead()).first).toString();
}

// Backpressure and fixed chunks keep original media out of in-memory byte arrays.
Future<int> streamCopy(
  Stream<List<int>> input,
  File output,
  OperationToken token, {
  required int limit,
  Future<void> Function(int)? checkpoint,
}) async {
  final target = await output.open(mode: FileMode.write);
  var bytes = 0, nextCheck = 16 * 1024 * 1024;
  try {
    await for (final chunk in input) {
      token.check();
      bytes += chunk.length;
      if (bytes > limit) {
        throw const DataFailure('File exceeds the supported size limit.');
      }
      for (var at = 0; at < chunk.length; at += 65536) {
        token.check();
        await target.writeFrom(chunk, at, min(at + 65536, chunk.length));
      }
      if (bytes >= nextCheck) {
        await checkpoint?.call(bytes);
        nextCheck = bytes + 16 * 1024 * 1024;
      }
    }
    token.check();
    await target.flush();
    return bytes;
  } finally {
    await target.close();
  }
}

class _Reader {
  _Reader(Stream<List<int>> source) : iterator = StreamIterator(source);
  final StreamIterator<List<int>> iterator;
  List<int> chunk = const [];
  int offset = 0;
  Future<Uint8List> read(int size) async {
    final result = Uint8List(size);
    var at = 0;
    while (at < size) {
      if (offset == chunk.length) {
        if (!await iterator.moveNext()) {
          throw const DataFailure('Archive is truncated.');
        }
        chunk = iterator.current;
        offset = 0;
        continue;
      }
      final n = min(size - at, chunk.length - offset);
      result.setRange(at, at + n, chunk, offset);
      offset += n;
      at += n;
    }
    return result;
  }

  Future<bool> get ended async =>
      offset == chunk.length && !await iterator.moveNext();
}

class ArchiveCodec {
  const ArchiveCodec({this.limits = const ArchiveLimits()});
  final ArchiveLimits limits;
  Future<Map<String, dynamic>> unpack(
    File archive,
    Directory stage,
    OperationToken token, {
    Future<void> Function(int)? space,
  }) async {
    await regularFile(archive);
    if (await archive.length() > limits.total + limits.manifest + 16) {
      throw const DataFailure('Archive is too large.');
    }
    await plainDirectory(stage);
    await stage.create(recursive: true);
    final reader = _Reader(archive.openRead());
    try {
      if (jsonEncode(await reader.read(12)) != jsonEncode(archiveMagic)) {
        throw const DataFailure(
          'Unsupported archive format. ZIP, compressed files and links are not accepted.',
        );
      }
      final length = ByteData.sublistView(await reader.read(4))
          .getUint32(0, Endian.big);
      if (length < 2 || length > limits.manifest) {
        throw const DataFailure('Invalid manifest size.');
      }
      final value = jsonDecode(utf8.decode(await reader.read(length)));
      final manifest = validateManifest(value);
      await File('${stage.path}/manifest.json')
          .writeAsString(jsonEncode(manifest), flush: true);
      var done = 0;
      for (final entry in manifest['entries'] as List) {
        token.check();
        final path = entry['path'] as String, size = entry['size'] as int;
        final file = File('${stage.path}/$path');
        await file.parent.create(recursive: true);
        final output = await file.open(mode: FileMode.write);
        try {
          for (var left = size; left > 0;) {
            token.check();
            final bytes = await reader.read(min(65536, left));
            await output.writeFrom(bytes);
            left -= bytes.length;
            done += bytes.length;
            await space?.call(done);
          }
          await output.flush();
        } finally {
          await output.close();
        }
        if (await fileDigest(file) != entry['sha256']) {
          throw const DataFailure('Archive checksum verification failed.');
        }
      }
      if (!await reader.ended) {
        throw const DataFailure('Unexpected data after the archive contents.');
      }
      return manifest;
    } on DataFailure {
      rethrow;
    } on FormatException {
      throw const DataFailure('Invalid archive manifest.');
    } finally {
      await reader.iterator.cancel();
    }
  }

  Map<String, dynamic> validateManifest(Object? value) {
    Never bad() =>
        throw const DataFailure('Unsupported or unsafe archive manifest.');
    if (value is! Map<String, dynamic> ||
        value.keys.toSet().difference({
          'formatVersion',
          'schemaVersion',
          'appVersion',
          'createdUtc',
          'entries',
          'missingMedia',
          'tables',
          'redactions',
        }).isNotEmpty ||
        value['formatVersion'] is! int ||
        value['formatVersion'] != 1 ||
        value['schemaVersion'] is! int ||
        !{8, 9}.contains(value['schemaVersion']) ||
        value['appVersion'] is! String ||
        value['createdUtc'] is! String ||
        DateTime.tryParse(value['createdUtc'] as String) == null ||
        value['redactions'] is! List ||
        value['tables'] is! Map ||
        value['missingMedia'] is! List ||
        value['entries'] is! List) {
      bad();
    }
    final expectedTables = archiveTables(value);
    final entries = value['entries'] as List, paths = <String>{};
    var total = 0, logical = 0;
    if (entries.length > limits.entries ||
        entries.length < expectedTables.length + 1) {
      bad();
    }
    for (final e in entries) {
      if (e is! Map ||
          e.length != 4 ||
          e['kind'] != 'file' ||
          e['path'] is! String ||
          !validArchivePath(e['path'] as String) ||
          ((e['path'] as String).startsWith('data/') &&
              !expectedTables.any((t) => e['path'] == 'data/$t.jsonl')) ||
          !paths.add(e['path'] as String) ||
          e['size'] is! int ||
          e['size'] < 0 ||
          e['size'] > limits.file ||
          e['sha256'] is! String ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(e['sha256'] as String)) {
        bad();
      }
      total += e['size'] as int;
      if ((e['path'] as String).startsWith('data/')) {
        logical += e['size'] as int;
      }
    }
    if (total > limits.total ||
        logical > limits.logical ||
        !paths.contains('ATTRIBUTION.txt') ||
        !expectedTables.every((t) => paths.contains('data/$t.jsonl'))) {
      bad();
    }
    final tables = value['tables'] as Map;
    if (tables.length != expectedTables.length ||
        !expectedTables.every(
          (t) => tables[t] is int && tables[t] >= 0 && tables[t] <= limits.rows,
        )) {
      bad();
    }
    final missing = value['missingMedia'] as List, missingPaths = <String>{};
    if (missing.length > limits.entries) {
      bad();
    }
    for (final path in missing) {
      if (path is! String ||
          !RegExp(r'^audio/[a-f0-9]{32}\.wav$').hasMatch(path) ||
          paths.contains(path) ||
          !missingPaths.add(path)) {
        bad();
      }
    }
    return value;
  }

  Future<void> pack(
    Directory source,
    Map<String, dynamic> manifest,
    File output,
    OperationToken token,
  ) async {
    validateManifest(manifest);
    final json = utf8.encode(jsonEncode(manifest));
    if (json.length > limits.manifest) {
      throw const DataFailure('Manifest is too large.');
    }
    final stream = await output.open(mode: FileMode.write);
    try {
      await stream.writeFrom(archiveMagic);
      await stream.writeFrom(
        (ByteData(
          4,
        )..setUint32(0, json.length, Endian.big)).buffer.asUint8List(),
      );
      await stream.writeFrom(json);
      for (final entry in manifest['entries'] as List) {
        final file = File('${source.path}/${entry['path']}');
        await regularFile(file);
        if (await file.length() != entry['size'] ||
            await fileDigest(file) != entry['sha256']) {
          throw const DataFailure(
            'Snapshot changed while packing. Retry export.',
          );
        }
        await for (final chunk in file.openRead()) {
          token.check();
          await stream.writeFrom(chunk);
        }
      }
      await stream.flush();
    } finally {
      await stream.close();
    }
  }
}
