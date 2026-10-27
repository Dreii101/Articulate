import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../providers.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import '../exercises.dart';
import 'archive_format.dart';
import '../advanced/advanced_repository.dart';
import 'logical_library.dart';
import 'platform_files.dart';

final dataManagerProvider = FutureProvider((ref) async {
  final manager = DataManager(
    ref.watch(repositoryProvider),
    await getApplicationSupportDirectory(),
    space: DataFiles().freeBytes,
  );
  await manager.recover();
  return manager;
});

class ExportSnapshot {
  ExportSnapshot(this.directory, this.file, this.manifest);
  final Directory directory;
  final File file;
  final Map<String, dynamic> manifest;
}

class RestorePreview {
  RestorePreview(this.id, this.directory, this.manifest, this.archiveHash);
  final String id, archiveHash;
  final Directory directory;
  final Map<String, dynamic> manifest;
  Directory get payload => Directory('${directory.path}/payload');
  int get sessions => manifest['tables']['practice_sessions'] as int;
  int get media => (manifest['entries'] as List)
      .where((e) => (e['path'] as String).startsWith('audio/'))
      .length;
  int get missing => (manifest['missingMedia'] as List).length;
}

class DeletionPlan {
  DeletionPlan(this.ids, this.media);
  final Set<String> ids;
  final List<AudioRecording> media;
}

// Fault injection leaves the durable intent in place, as process termination would.
class DataProcessInterruption extends Error {}

class DataManager {
  DataManager(
    this.practice,
    this.root, {
    required this.space,
    this.codec = const ArchiveCodec(),
    this.fault,
  });
  final PracticeRepository practice;
  final Directory root;
  final Future<int> Function(String) space;
  final ArchiveCodec codec;
  final Future<void> Function(String)? fault;
  AppDatabase get db => practice.db;
  Directory get work => Directory('${root.path}/data-management');
  File get journal => File('${work.path}/intent.json');
  bool busy = false;
  Future<T> _exclusive<T>(Future<T> Function() action) async {
    if (busy) {
      throw const DataFailure('Another data operation is already active.');
    }
    busy = true;
    try {
      await _prepare();
      if (await journal.exists()) {
        throw const DataFailure(
          'Restart Articulate to finish recovery before another data operation.',
        );
      }
      return await action();
    } finally {
      busy = false;
    }
  }

  Future<void> _prepare() async {
    await plainDirectory(root);
    await root.create(recursive: true);
    await plainDirectory(work);
    await work.create();
  }

  Future<void> _space(int needed) async {
    if (await space(root.path) < needed + 16 * 1024 * 1024) {
      throw const DataFailure(
        'Not enough local storage. The current library has not been replaced.',
      );
    }
  }

  Future<void> _quiet() async {
    if ((await db.select(db.audioRecordings).get()).any(
          (r) => r.state == 'pending',
        ) ||
        (await db.select(db.practiceSessions).get()).any(
          (s) => s.status == 'running',
        )) {
      throw const DataFailure(
        'Stop recording and pause practice before managing data. Reopen interrupted work if needed.',
      );
    }
  }

  Future<Directory> _newJob(String id) async {
    if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(id)) {
      throw const DataFailure('Invalid staging identity.');
    }
    final dir = Directory('${work.path}/stage-$id');
    if (await FileSystemEntity.type(dir.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw const DataFailure('Staging directory already exists.');
    }
    await dir.create();
    return dir;
  }

  Future<void> removeStage(Directory directory) async {
    final parent = directory.absolute.parent.uri.normalizePath().toString(),
        base = work.absolute.uri.normalizePath().toString(),
        name = directory.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if ((Platform.isWindows
            ? parent.toLowerCase() != base.toLowerCase()
            : parent != base) ||
        !RegExp(r'^stage-[a-f0-9]{32}$').hasMatch(name)) {
      throw const DataFailure('Unsafe cleanup target.');
    }
    await _removeTree(directory);
  }

  Future<void> _removeTree(FileSystemEntity entity) async {
    final type = await FileSystemEntity.type(entity.path, followLinks: false);
    if (type == FileSystemEntityType.directory) {
      await plainDirectory(Directory(entity.path));
      await for (final child in Directory(
        entity.path,
      ).list(followLinks: false)) {
        await _removeTree(child);
      }
      await Directory(entity.path).delete();
    } else if (type == FileSystemEntityType.link) {
      await Link(entity.path).delete();
    } else if (type == FileSystemEntityType.file) {
      await File(entity.path).delete();
    }
  }

  Future<ExportSnapshot> export(OperationToken token) =>
      _exclusive(() => _snapshot(token));
  Future<ExportSnapshot> _snapshot(OperationToken token) async {
    await _quiet();
    final dir = await _newJob(stableId()),
        payload = Directory('${dir.path}/payload');
    await payload.create();
    try {
      final manifest = await db.transaction(() async {
        token.check();
        await _quiet();
        final entries = <Map<String, dynamic>>[],
            tables = <String, int>{},
            missing = <String>[],
            attributions = <String>{};
        await _space(1024 * 1024);
        var logicalBytes = 0;
        final audio = await db.select(db.audioRecordings).get();
        var mediaBytes = 0;
        await plainDirectory(Directory('${root.path}/audio'));
        for (final r in audio) {
          if (r.relativePath != 'audio/${r.id}.wav' ||
              !RegExp(r'^[a-f0-9]{32}$').hasMatch(r.id)) {
            throw const DataFailure('Unsafe media ownership path.');
          }
          final file = File('${root.path}/${r.relativePath}'),
              type = await FileSystemEntity.type(file.path, followLinks: false);
          if (type == FileSystemEntityType.notFound) {
            missing.add(r.relativePath);
          } else {
            await regularFile(file);
            mediaBytes += await file.length();
          }
        }
        if (mediaBytes > codec.limits.total) {
          throw const DataFailure('Library exceeds archive size limits.');
        }
        await _space(mediaBytes * 2 + 32 * 1024 * 1024);
        for (final table in logicalTables) {
          final file = File('${payload.path}/data/$table.jsonl');
          await file.parent.create(recursive: true);
          final output = await file.open(mode: FileMode.write);
          var count = 0, size = 0;
          try {
            for (var offset = 0; ; offset += 128) {
              token.check();
              final rows = await db
                  .customSelect(
                    'SELECT * FROM "$table" ORDER BY rowid LIMIT 128 OFFSET $offset',
                  )
                  .get();
              if (rows.isEmpty) {
                break;
              }
              for (final result in rows) {
                final row = Map<String, dynamic>.from(result.data);
                if (table == 'app_settings' &&
                    !{
                      'theme',
                      'reduceMotion',
                      ...advancedSettingKeys,
                    }.contains(row['key'])) {
                  continue;
                }
                if (table == 'audio_recordings') {
                  row['input_id'] = '';
                  row['status_note'] = '';
                }
                if (table == 'practice_sessions' ||
                    table == 'custom_exercises') {
                  final e = Exercise.fromSnapshot(row['snapshot'] as String);
                  attributions.add(
                    '${e.content['authorship']['creator']}\n${e.content['authorship']['source']}\n${e.content['license']['id']}: ${e.content['license']['notice']}',
                  );
                }
                if (table == 'memory_speeches' || table == 'memory_versions') {
                  final source = jsonMap(
                    row[table == 'memory_speeches' ? 'draft' : 'content']
                        as String,
                  );
                  attributions.add('${source['author']}\n${source['license']}');
                }
                final bytes = utf8.encode('${jsonEncode(row)}\n');
                if (bytes.length > codec.limits.line ||
                    ++count > codec.limits.rows) {
                  throw const DataFailure(
                    'Logical data exceeds supported limits.',
                  );
                }
                size += bytes.length;
                logicalBytes += bytes.length;
                if (logicalBytes > codec.limits.logical) {
                  throw const DataFailure(
                    'Logical library exceeds archive limits.',
                  );
                }
                await output.writeFrom(bytes);
              }
            }
            await output.flush();
          } finally {
            await output.close();
          }
          tables[table] = count;
          entries.add({
            'kind': 'file',
            'path': 'data/$table.jsonl',
            'size': size,
            'sha256': await fileDigest(file),
          });
        }
        for (final r in audio) {
          token.check();
          if (missing.contains(r.relativePath)) {
            continue;
          }
          final target = File('${payload.path}/${r.relativePath}');
          await target.parent.create(recursive: true);
          final size = await streamCopy(
            File('${root.path}/${r.relativePath}').openRead(),
            target,
            token,
            limit: codec.limits.file,
            checkpoint: (_) => _space(1024 * 1024),
          );
          entries.add({
            'kind': 'file',
            'path': r.relativePath,
            'size': size,
            'sha256': await fileDigest(target),
          });
        }
        final attribution = File('${payload.path}/ATTRIBUTION.txt');
        await attribution.writeAsString(
          'Articulate logical-data archive 1\nUser writing and audio are private content, not an application license grant.\nNo application binaries, fonts or third-party native libraries are included.\nSHA-256 checksums detect corruption, not authorship or authenticity.\n\n${attributions.join('\n\n')}\n',
          flush: true,
        );
        entries.add({
          'kind': 'file',
          'path': 'ATTRIBUTION.txt',
          'size': await attribution.length(),
          'sha256': await fileDigest(attribution),
        });
        return <String, dynamic>{
          'formatVersion': 1,
          'schemaVersion': 9,
          'appVersion': '1.1.0+12',
          'createdUtc': DateTime.now().toUtc().toIso8601String(),
          'tables': tables,
          'entries': entries,
          'missingMedia': missing,
          'redactions': [
            'Runtime audio input IDs and diagnostic status notes omitted.',
            'Only theme, reduced-motion, review intervals and recommendation preference settings included. No logs, credentials, caches or recovery copies included.',
          ],
        };
      });
      final file = File('${dir.path}/library.articulate');
      await codec.pack(payload, manifest, file, token);
      return ExportSnapshot(dir, file, manifest);
    } catch (_) {
      await removeStage(dir);
      rethrow;
    }
  }

  Future<RestorePreview> stageFile(File source, OperationToken token) =>
      stageTransfer((target) async {
        await regularFile(source);
        await streamCopy(
          source.openRead(),
          target,
          token,
          limit: codec.limits.total + codec.limits.manifest + 16,
          checkpoint: (_) => _space(1024 * 1024),
        );
      }, token);
  Future<RestorePreview> stageTransfer(
    Future<void> Function(File) transfer,
    OperationToken token,
  ) => _exclusive(() async {
    final id = stableId(), dir = await _newJob(id);
    try {
      await _space(32 * 1024 * 1024);
      final incoming = File('${dir.path}/incoming.articulate');
      await transfer(incoming);
      token.check();
      var nextSpace = 0;
      final payload = Directory('${dir.path}/payload'),
          manifest = await codec.unpack(
            incoming,
            payload,
            token,
            space: (done) async {
              if (done >= nextSpace) {
                await _space(1024 * 1024);
                nextSpace = done + 16 * 1024 * 1024;
              }
            },
          );
      await Directory('${payload.path}/audio').create();
      await _validate(payload, manifest, token);
      return RestorePreview(id, dir, manifest, await fileDigest(incoming));
    } catch (_) {
      await removeStage(dir);
      rethrow;
    }
  });
  Future<void> _validate(
    Directory payload,
    Map<String, dynamic> manifest,
    OperationToken token,
  ) async {
    codec.validateManifest(manifest);
    await plainDirectory(payload);
    await plainDirectory(Directory('${payload.path}/data'));
    await plainDirectory(Directory('${payload.path}/audio'));
    for (final entry in manifest['entries'] as List) {
      token.check();
      final file = File('${payload.path}/${entry['path']}');
      await regularFile(file);
      if (await file.length() != entry['size'] ||
          await fileDigest(file) != entry['sha256']) {
        throw const DataFailure('Staged data failed checksum verification.');
      }
    }
    final check = File('${payload.path}/check-${stableId()}.sqlite');
    // This executor is deliberately isolated from the live database.
    final warnings = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    late AppDatabase staged;
    try {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      staged = AppDatabase(NativeDatabase(check));
    } finally {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = warnings;
    }
    try {
      await importLogical(staged, payload, manifest, codec.limits, token);
      await LogicalValidator(staged, payload, manifest, token).validate();
    } on DataFailure {
      rethrow;
    } catch (_) {
      throw const DataFailure(
        'Archive logical validation failed. No live data was changed.',
      );
    } finally {
      await staged.close();
      if (await check.exists()) {
        await check.delete();
      }
    }
  }

  Future<void> replace(
    RestorePreview preview,
    OperationToken token, {
    required bool confirmed,
  }) => _exclusive(() async {
    if (!confirmed) {
      throw const DataFailure('Explicit replace confirmation is required.');
    }
    if (preview.directory.path != '${work.path}/stage-${preview.id}' ||
        await fileDigest(
              File('${preview.directory.path}/incoming.articulate'),
            ) !=
            preview.archiveHash) {
      throw const DataFailure('Restore preview is no longer valid.');
    }
    await _quiet();
    await _validate(preview.payload, preview.manifest, token);
    token.check();
    final recovery = await _snapshot(token),
        id = stableId(),
        backup = Directory('${work.path}/recovery-$id');
    await backup.create();
    await recovery.file.rename('${backup.path}/library.articulate');
    await removeStage(recovery.directory);
    final currentFile = File('${root.path}/articulate.sqlite'),
        logicalBytes = (preview.manifest['entries'] as List)
            .where((e) => (e['path'] as String).startsWith('data/'))
            .fold<int>(0, (n, e) => n + e['size'] as int);
    await _space(
      (await currentFile.exists() ? await currentFile.length() : 0) +
          logicalBytes * 3 +
          32 * 1024 * 1024,
    );
    final audio = Directory('${root.path}/audio');
    await plainDirectory(audio);
    final hadAudio = await audio.exists();
    await _writeIntent({
      'id': id,
      'kind': 'replace',
      'stage': preview.id,
      'hadAudio': hadAudio,
    });
    try {
      await fault?.call('intent');
      if (hadAudio) {
        await audio.rename('${backup.path}/original-audio');
      }
      await fault?.call('old-media-moved');
      await Directory('${preview.payload.path}/audio').rename(audio.path);
      await fault?.call('new-media-moved');
      await db.transaction(() async {
        await importLogical(
          db,
          preview.payload,
          preview.manifest,
          codec.limits,
          OperationToken(),
          replace: true,
        );
        await db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key,value) VALUES (?,?)',
          ['_dataCommit', id],
        );
        await fault?.call('before-commit');
      });
      await fault?.call('after-commit');
      await _recoverIntent();
      db.markTablesUpdated(db.allTables);
    } on DataProcessInterruption {
      rethrow;
    } catch (_) {
      await _recoverIntent();
      db.markTablesUpdated(db.allTables);
      if (await _marker() != id) {
        throw const DataFailure(
          'Restore was rolled back. Your original library remains available.',
        );
      }
    }
  });
  Future<void> _writeIntent(Map<String, dynamic> value) async {
    if (await journal.exists()) {
      throw const DataFailure('A recovery operation is already pending.');
    }
    final temporary = File('${journal.path}.tmp');
    await temporary.writeAsString(jsonEncode(value), flush: true);
    await temporary.rename(journal.path);
  }

  Future<String?> _marker() async => (await (db.select(
    db.appSettings,
  )..where((s) => s.key.equals('_dataCommit'))).getSingleOrNull())?.value;
  Future<void> recover() async {
    await _prepare();
    await _recoverIntent();
  }

  Future<void> _recoverIntent() async {
    if (!await journal.exists()) {
      return;
    }
    await regularFile(journal);
    if (await journal.length() > 1024 * 1024) {
      throw const DataFailure(
        'Recovery intent is invalid. Data has not been reset.',
      );
    }
    final intent = jsonMap(await journal.readAsString()), id = intent['id'];
    if (id is! String ||
        !RegExp(r'^[a-f0-9]{32}$').hasMatch(id) ||
        !{'replace', 'delete'}.contains(intent['kind'])) {
      throw const DataFailure(
        'Recovery intent is invalid. Data has not been reset.',
      );
    }
    final committed = await _marker() == id;
    if (intent['kind'] == 'replace') {
      final stage = intent['stage'];
      if (stage is! String ||
          !RegExp(r'^[a-f0-9]{32}$').hasMatch(stage) ||
          intent['hadAudio'] is! bool) {
        throw const DataFailure('Invalid recovery paths.');
      }
      final backup = Directory('${work.path}/recovery-$id/original-audio'),
          audio = Directory('${root.path}/audio'),
          dir = Directory('${work.path}/stage-$stage');
      await plainDirectory(backup);
      await plainDirectory(audio);
      await plainDirectory(dir);
      if (committed) {
        if (!await audio.exists()) {
          throw const DataFailure(
            'Restored media directory is unavailable. Recovery copies are retained.',
          );
        }
        if (await dir.exists()) {
          await removeStage(dir);
        }
      } else if (await backup.exists()) {
        if (await audio.exists()) {
          await audio.rename('${dir.path}/rejected-audio');
        }
        await backup.rename(audio.path);
      } else if (intent['hadAudio'] == false && await audio.exists()) {
        await audio.rename('${dir.path}/rejected-audio');
      }
    } else if (committed) {
      await plainDirectory(Directory('${root.path}/audio'));
      final paths = intent['paths'];
      if (paths is! List || paths.length > 10000) {
        throw const DataFailure('Invalid deletion recovery.');
      }
      for (final path in paths) {
        if (path is! String ||
            !RegExp(r'^audio/[a-f0-9]{32}\.wav$').hasMatch(path)) {
          throw const DataFailure('Invalid deletion path.');
        }
        final owner = await (db.select(
          db.audioRecordings,
        )..where((r) => r.relativePath.equals(path))).getSingleOrNull();
        if (owner == null || owner.state == 'unavailable') {
          final file = File('${root.path}/$path');
          if (await FileSystemEntity.type(file.path, followLinks: false) ==
              FileSystemEntityType.file) {
            await file.delete();
          }
        }
      }
    }
    await journal.delete();
  }

  Future<DeletionPlan> planSession(String selected) async {
    await practice.load(selected);
    final writing = await db.select(db.writingWorkspaces).get(),
        impromptu = await db.select(db.impromptuWorkspaces).get();
    final w = writing.where((w) => w.sessionId == selected).firstOrNull;
    final ids = <String>{selected};
    if (w != null) {
      ids.addAll(
        writing
            .where((v) => v.rootSessionId == w.rootSessionId)
            .map((v) => v.sessionId),
      );
    }
    String at = selected;
    final visited = <String>{};
    while (true) {
      if (!visited.add(at)) {
        throw const DataFailure('Broken retry linkage.');
      }
      final parent = impromptu
          .where((w) => w.sessionId == at)
          .firstOrNull
          ?.parentSessionId;
      if (parent == null) {
        break;
      }
      at = parent;
      ids.add(at);
    }
    final targeted = await db.select(db.practiceContexts).get();
    var changed = true;
    while (changed) {
      changed = false;
      // Delete connected retry/version families together; preview names the full count.
      for (final r in writing) {
        if (ids.contains(r.sessionId) || ids.contains(r.rootSessionId)) {
          if (ids.add(r.sessionId)) changed = true;
          if (ids.add(r.rootSessionId)) changed = true;
        }
      }
      for (final r in targeted) {
        if (r.parentSessionId != null &&
            (ids.contains(r.sessionId) || ids.contains(r.parentSessionId))) {
          if (ids.add(r.sessionId)) changed = true;
          if (ids.add(r.parentSessionId!)) changed = true;
        }
      }
      for (final r in impromptu) {
        if (r.parentSessionId != null &&
            ids.contains(r.sessionId) &&
            ids.add(r.parentSessionId!)) {
          changed = true;
        }
        if (r.parentSessionId != null &&
            ids.contains(r.parentSessionId) &&
            ids.add(r.sessionId)) {
          changed = true;
        }
      }
    }
    return DeletionPlan(
      ids,
      (await db.select(db.audioRecordings).get())
          .where((r) => ids.contains(r.sessionId))
          .toList(),
    );
  }

  Future<void> deleteSession(
    String id, {
    required bool confirmed,
  }) => _exclusive(() async {
    if (!confirmed) {
      throw const DataFailure('Explicit deletion confirmation is required.');
    }
    await _quiet();
    final plan = await planSession(id);
    await _delete(plan.media.map((r) => r.relativePath).toList(), () async {
      for (final recording in plan.media) {
        await (db.delete(
          db.audioObservations,
        )..where((o) => o.recordingId.equals(recording.id))).go();
      }
      for (final table in [
        'recall_schedules',
        'practice_contexts',
        'audio_recordings',
        'writing_workspaces',
        'reading_workspaces',
        'memory_workspaces',
        'debate_stages',
        'debate_workspaces',
        'impromptu_workspaces',
        'timing_segments',
        'review_records',
        'responses',
      ]) {
        await db.customStatement(
          'DELETE FROM "$table" WHERE session_id IN (${List.filled(plan.ids.length, '?').join(',')})',
          plan.ids.toList(),
        );
      }
      await db.customStatement(
        'DELETE FROM practice_sessions WHERE id IN (${List.filled(plan.ids.length, '?').join(',')})',
        plan.ids.toList(),
      );
    });
  });
  Future<void> deleteMedia(String id, {required bool confirmed}) =>
      _exclusive(() async {
        if (!confirmed) {
          throw const DataFailure(
            'Explicit media deletion confirmation is required.',
          );
        }
        await _quiet();
        final row = await (db.select(
          db.audioRecordings,
        )..where((r) => r.id.equals(id))).getSingle();
        await _delete([row.relativePath], () async {
          await (db.update(
            db.audioRecordings,
          )..where((r) => r.id.equals(id))).write(
            const AudioRecordingsCompanion(
              state: Value('unavailable'),
              statusNote: Value(
                'Media deliberately deleted. Notes and observations retained.',
              ),
            ),
          );
        });
      });
  Future<void> _delete(
    List<String> paths,
    Future<void> Function() action,
  ) async {
    if (paths.any((p) => !RegExp(r'^audio/[a-f0-9]{32}\.wav$').hasMatch(p))) {
      throw const DataFailure('Unsafe deletion path.');
    }
    await plainDirectory(Directory('${root.path}/audio'));
    for (final path in paths) {
      final file = File('${root.path}/$path');
      if (await FileSystemEntity.type(file.path, followLinks: false) !=
          FileSystemEntityType.notFound) {
        await regularFile(file);
      }
    }
    final id = stableId();
    await _writeIntent({'id': id, 'kind': 'delete', 'paths': paths});
    try {
      await fault?.call('delete-intent');
      await db.transaction(() async {
        await db.customStatement('PRAGMA defer_foreign_keys = ON');
        await action();
        await db.customStatement(
          'INSERT OR REPLACE INTO app_settings (key,value) VALUES (?,?)',
          ['_dataCommit', id],
        );
        await fault?.call('delete-before-commit');
      });
      await fault?.call('delete-after-commit');
      await _recoverIntent();
      db.markTablesUpdated(db.allTables);
    } on DataProcessInterruption {
      rethrow;
    } catch (_) {
      await _recoverIntent();
      db.markTablesUpdated(db.allTables);
      rethrow;
    }
  }

  Future<Map<String, int>> storage() async {
    await _prepare();
    var database = 0,
        audio = 0,
        recovery = 0,
        staging = 0,
        orphans = 0,
        missing = 0;
    final recordings = await db.select(db.audioRecordings).get(),
        owned = recordings.map((r) => r.relativePath).toSet();
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('${root.path}/articulate.sqlite$suffix');
      if (await file.exists()) {
        database += await file.length();
      }
    }
    final media = Directory('${root.path}/audio');
    await plainDirectory(media);
    if (await media.exists()) {
      await for (final f in media.list(followLinks: false)) {
        if (await FileSystemEntity.type(f.path, followLinks: false) ==
            FileSystemEntityType.file) {
          final name = f.uri.pathSegments.last;
          audio += await File(f.path).length();
          if (!owned.contains('audio/$name')) {
            orphans++;
          }
        }
      }
    }
    for (final r in recordings) {
      if (!await File('${root.path}/${r.relativePath}').exists()) {
        missing++;
      }
    }
    await for (final f in work.list(recursive: true, followLinks: false)) {
      if (await FileSystemEntity.type(f.path, followLinks: false) ==
          FileSystemEntityType.file) {
        final relative = f.path.substring(work.path.length);
        if (relative.contains('recovery-')) {
          recovery += await File(f.path).length();
        } else {
          staging += await File(f.path).length();
        }
      }
    }
    return {
      'database': database,
      'media': audio,
      'recovery': recovery,
      'staging': staging,
      'unindexedFiles': orphans,
      'missingMedia': missing,
      'free': await space(root.path),
    };
  }

  Future<List<File>> recoveryArchives() async {
    await _prepare();
    final result = <File>[];
    await for (final f in work.list(followLinks: false)) {
      if (f is Directory &&
          RegExp(r'^recovery-[a-f0-9]{32}$')
              .hasMatch(f.uri.pathSegments.where((s) => s.isNotEmpty).last)) {
        await plainDirectory(f);
        final archive = File('${f.path}/library.articulate');
        if (await archive.exists()) {
          await regularFile(archive);
          result.add(archive);
        }
      }
    }
    return result;
  }

  Future<void> cleanupStaging({required bool confirmed, String? keepId}) =>
      _exclusive(() async {
        if (!confirmed) {
          throw const DataFailure(
            'Explicit temporary-copy deletion confirmation is required.',
          );
        }
        final jobs = await work.list(followLinks: false).toList();
        for (final entry in jobs) {
          final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
          if (entry is Directory &&
              RegExp(r'^stage-[a-f0-9]{32}$').hasMatch(name) &&
              name != 'stage-$keepId') {
            await removeStage(entry);
          }
        }
      });

  Future<void> removeRecovery(File archive, {required bool confirmed}) =>
      _exclusive(() async {
        if (!confirmed) {
          throw const DataFailure(
            'Explicit recovery-copy deletion confirmation is required.',
          );
        }
        if (!(await recoveryArchives()).any((f) => f.path == archive.path)) {
          throw const DataFailure('Unknown recovery snapshot.');
        }
        await _removeTree(archive.parent);
      });
}
