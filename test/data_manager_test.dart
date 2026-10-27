import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/audio/wave_file.dart';
import 'package:articulate/data/archive_format.dart';
import 'package:articulate/data/data_manager.dart';
import 'package:articulate/data/logical_library.dart';
import 'package:articulate/data/platform_files.dart';
import 'package:articulate/history/history_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';
import 'data_fixture.dart';

Future<void> rawArchive(
  File target,
  Map<String, dynamic> manifest, {
  List<int> bytes = const [],
}) async {
  final data = utf8.encode(jsonEncode(manifest));
  await target.writeAsBytes([
    ...archiveMagic,
    ...(ByteData(
      4,
    )..setUint32(0, data.length, Endian.big)).buffer.asUint8List(),
    ...data,
    ...bytes,
  ], flush: true);
}

class CancellingToken extends OperationToken {
  CancellingToken(this.after);
  int after;
  @override
  void check() {
    if (--after <= 0) {
      cancelled = true;
    }
    super.check();
  }
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);
  late Directory root, targetRoot;
  late AppDatabase db, targetDb;
  late PracticeRepository p, targetP;
  late DataManager manager, target;
  setUp(() async {
    (root, db, p, manager) = await dataLibrary(fixture: true);
    (targetRoot, targetDb, targetP, target) = await dataLibrary();
  });
  tearDown(() async {
    await db.close();
    await targetDb.close();
    await root.delete(recursive: true);
    await targetRoot.delete(recursive: true);
  });
  test('staged payload tampering and low storage during replacement preserve original records and media', () async {
    final sentinel = await sentinelLibrary(targetP, targetRoot),
        snapshot = await manager.export(OperationToken()),
        preview = await target.stageFile(snapshot.file, OperationToken());
    await File('${preview.payload.path}/data/responses.jsonl')
        .writeAsString('tampered\n');
    await expectLater(
      target.replace(preview, OperationToken(), confirmed: true),
      throwsA(isA<DataFailure>()),
    );
    final fresh = await target.stageFile(snapshot.file, OperationToken()),
        low = DataManager(targetP, targetRoot, space: (_) async => 1024);
    await expectLater(
      low.replace(fresh, OperationToken(), confirmed: true),
      throwsA(isA<DataFailure>()),
    );
    expect(
      (await targetP.load(sentinel)).response.body,
      'My original library must survive.',
    );
    expect(await target.journal.exists(), isFalse);
  });
  test('deep logical JSON, invalid recovery paths and unsafe cleanup cannot escape staging', () async {
    expect(
      () => safeJson(
        '${List.filled(65, '[').join()}0${List.filled(65, ']').join()}',
      ),
      throwsA(isA<DataFailure>()),
    );
    final sentinel = await sentinelLibrary(targetP, targetRoot);
    await expectLater(
      target.removeStage(targetRoot),
      throwsA(isA<DataFailure>()),
    );
    await target.journal.writeAsString(
      '{"id":"../outside","kind":"replace","stage":"anything","hadAudio":true}',
    );
    await expectLater(target.recover(), throwsA(isA<DataFailure>()));
    expect(
      (await targetP.load(sentinel)).response.body,
      contains('original library'),
    );
  });
  test('temporary and recovery cleanup require confirmation and do not delete the live library', () async {
    final snapshot = await manager.export(OperationToken()),
        preview = await target.stageFile(snapshot.file, OperationToken());
    await expectLater(
      manager.cleanupStaging(confirmed: false),
      throwsA(isA<DataFailure>()),
    );
    await manager.cleanupStaging(confirmed: true);
    expect(await snapshot.directory.exists(), isFalse);
    await target.replace(preview, OperationToken(), confirmed: true);
    final recovery = (await target.recoveryArchives()).single;
    await expectLater(
      target.removeRecovery(recovery, confirmed: false),
      throwsA(isA<DataFailure>()),
    );
    await target.removeRecovery(recovery, confirmed: true);
    expect(await target.recoveryArchives(), isEmpty);
    expect(
      await targetDb.select(targetDb.practiceSessions).get(),
      hasLength(15),
    );
  });
  test(
    'linked media symlinks are rejected without following their destination',
    () async {
      final row = (await db.select(db.audioRecordings).get()).first,
          file = File('${root.path}/${row.relativePath}'),
          external = File('${targetRoot.path}/outside.wav');
      await file.copy(external.path);
      await file.delete();
      try {
        await Link(file.path).create(external.path);
      } on FileSystemException {
        markTestSkipped(
          'Host does not permit filesystem symlink creation; archive link-kind rejection remains tested.',
        );
        return;
      }
      await expectLater(
        manager.export(OperationToken()),
        throwsA(isA<DataFailure>()),
      );
      await expectLater(
        manager.deleteMedia(row.id, confirmed: true),
        throwsA(isA<DataFailure>()),
      );
      expect(
        (await db.select(db.audioRecordings).get()).first.state,
        row.state,
      );
      expect(await external.exists(), isTrue);
    },
  );
  test('all six modules round-trip logical records, snapshots, provenance, attribution and byte-identical PCM media', () async {
    final original = await HistoryRepository(p).load(),
        snapshot = await manager.export(OperationToken());
    final preview = await target.stageFile(snapshot.file, OperationToken());
    expect(preview.sessions, 15);
    expect(preview.media, 3);
    expect(preview.missing, 0);
    final before = await sentinelLibrary(targetP, targetRoot);
    await expectLater(
      target.replace(preview, OperationToken(), confirmed: false),
      throwsA(isA<DataFailure>()),
    );
    expect(
      (await targetP.load(before)).response.body,
      contains('original library'),
    );
    await target.replace(preview, OperationToken(), confirmed: true);
    final restored = await HistoryRepository(targetP).load();
    expect(restored.length, 15);
    expect(HistorySummary(restored).finalizedMs, 21700);
    for (final e in original) {
      final copy = restored.singleWhere((r) => r.id == e.id);
      expect(copy.detail.session.snapshot, e.detail.session.snapshot);
      expect(copy.detail.response.body, e.detail.response.body);
      expect(
        copy.assessments.map((a) => a.display),
        e.assessments.map((a) => a.display),
      );
    }
    for (final table in logicalTables) {
      Future<List<String>> values(AppDatabase database) async {
        final rows = await database
                .customSelect('SELECT * FROM "$table"')
                .get(),
            result = <String>[];
        for (final row in rows) {
          final value = Map<String, dynamic>.from(row.data);
          if (table == 'app_settings' &&
              !{'theme', 'reduceMotion'}.contains(value['key'])) {
            continue;
          }
          if (table == 'audio_recordings') {
            value['input_id'] = '';
            value['status_note'] = '';
          }
          result.add(canonicalData(value));
        }
        return result..sort();
      }

      expect(
        await values(targetDb),
        await values(db),
        reason: 'Every logical field retained in $table',
      );
    }
    for (final r in await db.select(db.audioRecordings).get()) {
      final a = File('${root.path}/${r.relativePath}'),
          b = File('${targetRoot.path}/${r.relativePath}');
      expect(await fileDigest(a), await fileDigest(b));
      expect((await inspectWave(b.path)).durationMs, r.durationMs);
    }
    expect(
      await File('${snapshot.directory.path}/payload/ATTRIBUTION.txt')
          .readAsString(),
      contains('CC0-1.0'),
    );
    expect(await target.recoveryArchives(), hasLength(1));
    expect((await targetP.watchSettings().first)['apiCredential'], isNull);
    final recovery = await target.stageFile(
      (await target.recoveryArchives()).single,
      OperationToken(),
    );
    await target.replace(recovery, OperationToken(), confirmed: true);
    expect(
      (await targetP.load(before)).response.body,
      'My original library must survive.',
    );
  });
  test('archive excludes credentials, sensitive runtime diagnostics, logs and recovery copies', () async {
    await File('${root.path}/sensitive.log').writeAsString('NEVER_EXPORT_LOG');
    final snapshot = await manager.export(OperationToken());
    final text = await snapshot.file.readAsBytes();
    final raw = latin1.decode(text);
    for (final secret in [
      'NEVER_EXPORT_CREDENTIAL',
      'NEVER_EXPORT_INPUT_ID',
      'NEVER_EXPORT_DIAGNOSTIC_LOG',
      'NEVER_EXPORT_LOG',
    ]) {
      expect(raw, isNot(contains(secret)));
    }
    expect(
      (snapshot.manifest['entries'] as List).every(
        (e) => validArchivePath(e['path'] as String),
      ),
      isTrue,
    );
  });
  test('cancelled export, import and Windows destination preserve the original library and existing destination', () async {
    final sentinel = await sentinelLibrary(targetP, targetRoot),
        snapshot = await manager.export(OperationToken());
    await expectLater(
      manager.export(CancellingToken(3)),
      throwsA(isA<DataCancelled>()),
    );
    await expectLater(
      target.stageFile(snapshot.file, CancellingToken(4)),
      throwsA(isA<DataCancelled>()),
    );
    final destination = File(
      '${targetRoot.parent.path}/cancel-${DateTime.now().microsecondsSinceEpoch}.articulate',
    );
    await destination.writeAsString('Existing archive');
    addTearDown(() => destination.delete());
    await expectLater(
      DataFiles().exportTo(
        snapshot.file,
        destination.path,
        CancellingToken(2),
        protectedRoot: root,
      ),
      throwsA(isA<DataCancelled>()),
    );
    expect(await destination.readAsString(), 'Existing archive');
    expect(
      (await targetP.load(sentinel)).response.body,
      'My original library must survive.',
    );
  });
  test('missing media is disclosed and restored as a retained reference without inventing playable evidence', () async {
    final row = (await db.select(db.audioRecordings).get()).first;
    await File('${root.path}/${row.relativePath}').delete();
    final snapshot = await manager.export(OperationToken()),
        preview = await target.stageFile(snapshot.file, OperationToken());
    expect(preview.missing, 1);
    await target.replace(preview, OperationToken(), confirmed: true);
    final store = AudioStore(targetP, targetRoot),
        audio = LocalAudio(
          store,
          FakeAudioBackend(),
          automaticHeartbeat: false,
        );
    addTearDown(audio.close);
    await expectLater(
      audio.select(await store.load(row.id)),
      throwsA(isA<AudioFailure>()),
    );
    expect(
      await targetDb.select(targetDb.audioObservations).get(),
      hasLength(6),
    );
  });
  test('corruption and truncation cannot replace a live library', () async {
    final sentinel = await sentinelLibrary(targetP, targetRoot),
        snapshot = await manager.export(OperationToken()),
        bytes = await snapshot.file.readAsBytes();
    final corrupted = File('${root.path}/corrupt.articulate');
    bytes[bytes.length - 1] ^= 1;
    await corrupted.writeAsBytes(bytes);
    await expectLater(
      target.stageFile(corrupted, OperationToken()),
      throwsA(isA<DataFailure>()),
    );
    await corrupted.writeAsBytes(bytes.sublist(0, 100));
    await expectLater(
      target.stageFile(corrupted, OperationToken()),
      throwsA(isA<DataFailure>()),
    );
    expect(
      (await targetP.load(sentinel)).response.body,
      contains('original library'),
    );
  });
  test('unsafe paths, links, duplicate entries, unsupported versions, compressed and excessive archives are rejected', () async {
    final snapshot = await manager.export(OperationToken()),
        file = File('${root.path}/unsafe.articulate');
    for (final edit in <void Function(Map<String, dynamic>)>[
      (m) => m['entries'][0]['path'] = '../outside',
      (m) => m['entries'][0]['path'] = 'C:\\outside',
      (m) => m['entries'][0]['path'] = 'audio/../../outside',
      (m) => m['entries'][0]['kind'] = 'link',
      (m) => m['entries'].add(m['entries'][0]),
      (m) => m['formatVersion'] = 99,
      (m) => m['schemaVersion'] = 99,
      (m) => m['entries'][0]['size'] = 10 * 1024 * 1024 * 1024,
    ]) {
      final copy =
          jsonDecode(jsonEncode(snapshot.manifest)) as Map<String, dynamic>;
      edit(copy);
      await rawArchive(file, copy);
      await expectLater(
        target.stageFile(file, OperationToken()),
        throwsA(isA<DataFailure>()),
      );
    }
    await file.writeAsBytes([80, 75, 3, 4, ...List.filled(30, 0)]);
    await expectLater(
      target.stageFile(file, OperationToken()),
      throwsA(isA<DataFailure>()),
    );
  });
  test('checksummed but broken references and false answer keys are rejected in staged SQLite', () async {
    final snapshot = await manager.export(OperationToken());
    Future<File> changed(
      String table,
      void Function(Map<String, dynamic>) edit,
    ) async {
      final file = File('${snapshot.directory.path}/payload/data/$table.jsonl'),
          rows = (await file.readAsLines())
              .map((v) => jsonDecode(v) as Map<String, dynamic>)
              .toList();
      edit(rows.first);
      await file.writeAsString('${rows.map(jsonEncode).join('\n')}\n');
      final manifest =
              jsonDecode(jsonEncode(snapshot.manifest)) as Map<String, dynamic>,
          entry = (manifest['entries'] as List).singleWhere(
            (e) => e['path'] == 'data/$table.jsonl',
          );
      entry['size'] = await file.length();
      entry['sha256'] = await fileDigest(file);
      final output = File('${snapshot.directory.path}/tampered.articulate');
      await const ArchiveCodec().pack(
        Directory('${snapshot.directory.path}/payload'),
        manifest,
        output,
        OperationToken(),
      );
      return output;
    }

    await expectLater(
      target.stageFile(
        await changed('responses', (r) => r['session_id'] = 'missing-owner'),
        OperationToken(),
      ),
      throwsA(isA<DataFailure>()),
    );
    final fresh = await manager.export(OperationToken()),
        file = File(
          '${fresh.directory.path}/payload/data/reading_workspaces.jsonl',
        ),
        row = jsonDecode((await file.readAsLines()).first);
    final keys = jsonDecode(row['key_results']);
    keys[keys.keys.first]['status'] = 'incorrect';
    row['key_results'] = jsonEncode(keys);
    await file.writeAsString('${jsonEncode(row)}\n');
    final entry = (fresh.manifest['entries'] as List).singleWhere(
      (e) => e['path'] == 'data/reading_workspaces.jsonl',
    );
    entry['size'] = await file.length();
    entry['sha256'] = await fileDigest(file);
    final output = File('${fresh.directory.path}/bad-key.articulate');
    await const ArchiveCodec().pack(
      Directory('${fresh.directory.path}/payload'),
      fresh.manifest,
      output,
      OperationToken(),
    );
    await expectLater(
      target.stageFile(output, OperationToken()),
      throwsA(isA<DataFailure>()),
    );
  });
  test('low storage stops before mutation and active capture prevents inconsistent export', () async {
    final sentinel = await sentinelLibrary(targetP, targetRoot),
        snapshot = await manager.export(OperationToken());
    final low = DataManager(targetP, targetRoot, space: (_) async => 1024);
    await expectLater(
      low.stageFile(snapshot.file, OperationToken()),
      throwsA(isA<DataFailure>()),
    );
    expect(
      (await targetP.load(sentinel)).response.body,
      contains('original library'),
    );
    final store = AudioStore(p, root);
    await store.reserve(
      (await db.select(db.practiceSessions).get())
          .firstWhere((s) => s.status == 'draft')
          .id,
      '',
      '',
    );
    await expectLater(
      manager.export(OperationToken()),
      throwsA(isA<DataFailure>()),
    );
  });
  for (final point in [
    'intent',
    'old-media-moved',
    'new-media-moved',
    'before-commit',
    'after-commit',
  ]) {
    test(
      'process restart at $point retains the correct database/media generation and recovery snapshot',
      () async {
        final sentinel = await sentinelLibrary(targetP, targetRoot),
            snapshot = await manager.export(OperationToken()),
            preview = await target.stageFile(snapshot.file, OperationToken());
        final crashing = DataManager(
          targetP,
          targetRoot,
          space: (_) async => 50 * 1024 * 1024 * 1024,
          fault: (phase) async {
            if (phase == point) {
              throw DataProcessInterruption();
            }
          },
        );
        await expectLater(
          crashing.replace(preview, OperationToken(), confirmed: true),
          throwsA(isA<DataProcessInterruption>()),
        );
        await targetDb.close();
        targetDb = AppDatabase(
          NativeDatabase(File('${targetRoot.path}/articulate.sqlite')),
        );
        targetP = PracticeRepository(targetDb);
        target = DataManager(
          targetP,
          targetRoot,
          space: (_) async => 50 * 1024 * 1024 * 1024,
        );
        await target.recover();
        if (point == 'after-commit') {
          expect(
            await targetDb.select(targetDb.practiceSessions).get(),
            hasLength(15),
          );
        } else {
          expect(
            (await targetP.load(sentinel)).response.body,
            'My original library must survive.',
          );
          final r =
              (await targetDb.select(targetDb.audioRecordings).get()).single;
          expect(
            (await inspectWave('${targetRoot.path}/${r.relativePath}'))
                .durationMs,
            1000,
          );
        }
        expect(await target.recoveryArchives(), isNotEmpty);
        expect(await target.journal.exists(), isFalse);
        await target.recover();
      },
    );
  }
  test('deliberate media deletion retains review evidence; linked session deletion removes only its family', () async {
    final recordings = await db.select(db.audioRecordings).get(),
        row = recordings.first;
    await expectLater(
      manager.deleteMedia(row.id, confirmed: false),
      throwsA(isA<DataFailure>()),
    );
    await manager.deleteMedia(row.id, confirmed: true);
    expect(await File('${root.path}/${row.relativePath}').exists(), isFalse);
    expect(
      (await (db.select(
        db.audioRecordings,
      )..where((r) => r.id.equals(row.id))).getSingle()).state,
      'unavailable',
    );
    expect(await db.select(db.audioObservations).get(), hasLength(6));
    final child = (await db.select(db.writingWorkspaces).get()).firstWhere(
      (w) => w.versionNumber == 2,
    );
    final plan = await manager.planSession(child.sessionId);
    expect(plan.ids.length, 3);
    await manager.deleteSession(child.sessionId, confirmed: true);
    expect(await db.select(db.practiceSessions).get(), hasLength(12));
    expect(await db.select(db.memorySpeeches).get(), isNotEmpty);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
  test('deletion interruption commits metadata before files and completes safely on restart', () async {
    final row = (await db.select(db.audioRecordings).get()).first,
        crashing = DataManager(
          p,
          root,
          space: (_) async => 50 * 1024 * 1024 * 1024,
          fault: (phase) async {
            if (phase == 'delete-after-commit') {
              throw DataProcessInterruption();
            }
          },
        );
    await expectLater(
      crashing.deleteMedia(row.id, confirmed: true),
      throwsA(isA<DataProcessInterruption>()),
    );
    expect(await File('${root.path}/${row.relativePath}').exists(), isTrue);
    await manager.recover();
    expect(await File('${root.path}/${row.relativePath}').exists(), isFalse);
    expect(await db.select(db.practiceSessions).get(), hasLength(15));
  });
  test('large original media streams through export and restore without a whole-file byte API', () async {
    final row = (await db.select(db.audioRecordings).get()).first,
        file = File('${root.path}/${row.relativePath}');
    await largeTestWave(file, 32 * 1024 * 1024);
    final info = await inspectWave(file.path);
    await (db.update(
      db.audioRecordings,
    )..where((r) => r.id.equals(row.id))).write(
      AudioRecordingsCompanion(
        byteCount: Value(info.bytes),
        durationMs: Value(info.durationMs),
        sampleRate: Value(info.sampleRate),
        channels: Value(info.channels),
      ),
    );
    final snapshot = await manager.export(OperationToken()),
        preview = await target.stageFile(snapshot.file, OperationToken());
    await target.replace(preview, OperationToken(), confirmed: true);
    expect(
      await fileDigest(file),
      await fileDigest(File('${targetRoot.path}/${row.relativePath}')),
    );
    expect(
      await File('${targetRoot.path}/${row.relativePath}').length(),
      32 * 1024 * 1024 + 44,
    );
  });
}
