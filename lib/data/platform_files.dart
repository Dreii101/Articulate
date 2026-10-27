import 'dart:io';

import 'package:flutter/services.dart';

import 'archive_format.dart';

class DataFiles {
  static const channel = MethodChannel('articulate/data_files');
  Future<int> freeBytes(String path) async =>
      (await const MethodChannel('articulate/audio_platform')
          .invokeMethod<int>('freeBytes', path))!;
  Future<String?> choose(bool save, String name) => channel
      .invokeMethod<String>(save ? 'chooseExport' : 'chooseImport', name);
  Future<void> cancel() async {
    if (Platform.isAndroid) {
      await channel.invokeMethod<void>('cancelCopy');
    }
  }

  Future<void> importTo(
    String source,
    File target,
    OperationToken token,
    int limit,
  ) async {
    if (Platform.isAndroid) {
      if (Uri.tryParse(source)?.scheme != 'content') {
        throw const DataFailure(
          'The Android picker did not return a document URI.',
        );
      }
      await channel.invokeMethod<void>('readToPrivate', {
        'uri': source,
        'path': target.path,
        'limit': limit,
      });
      token.check();
    } else {
      final file = File(source);
      await regularFile(file);
      await streamCopy(file.openRead(), target, token, limit: limit);
    }
  }

  Future<void> exportTo(
    File source,
    String destination,
    OperationToken token, {
    Directory? protectedRoot,
  }) async {
    if (Platform.isAndroid) {
      if (Uri.tryParse(destination)?.scheme != 'content') {
        throw const DataFailure(
          'The Android picker did not return a document URI.',
        );
      }
      await channel.invokeMethod<void>('writeFromPrivate', {
        'uri': destination,
        'path': source.path,
        'limit': await source.length(),
        'sha256': await fileDigest(source),
      });
      token.check();
    } else {
      final target = File(destination),
          partial = File(
            '$destination.partial-${DateTime.now().microsecondsSinceEpoch}',
          );
      if (protectedRoot != null) {
        final base = (await protectedRoot.resolveSymbolicLinks()).toLowerCase(),
            parent = (await target.parent.resolveSymbolicLinks()).toLowerCase();
        if (parent == base ||
            parent.startsWith('$base${Platform.pathSeparator}')) {
          throw const DataFailure(
            'Choose a destination outside Articulate private storage.',
          );
        }
      }
      final type = await FileSystemEntity.type(target.path, followLinks: false);
      if (type != FileSystemEntityType.notFound &&
          type != FileSystemEntityType.file) {
        throw const DataFailure('Choose a regular Windows destination file.');
      }
      if (source.absolute.path.toLowerCase() ==
          target.absolute.path.toLowerCase()) {
        throw const DataFailure('Choose a separate export destination.');
      }
      try {
        await streamCopy(
          source.openRead(),
          partial,
          token,
          limit: await source.length(),
        );
        if (await fileDigest(partial) != await fileDigest(source)) {
          throw const DataFailure('Destination verification failed.');
        }
        token.check();
        await partial.rename(target.path);
      } finally {
        if (await partial.exists()) {
          await partial.delete();
        }
      }
    }
  }
}
