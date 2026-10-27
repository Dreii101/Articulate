import 'dart:io';
import 'dart:convert';

import 'package:articulate/advanced/advanced_repository.dart';
import 'package:articulate/data/archive_format.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'advanced_repository_test.dart' show customTemplate, completedRecall;
import 'data_fixture.dart';

void main() {
  test('deeply nested custom snapshots are rejected before restore changes the library', () async {
    final (root, db, p, manager) = await dataLibrary();
    final (dest, destDb, destP, target) = await dataLibrary();
    try {
      await AdvancedRepository(p)
          .saveCustom(customTemplate().snapshot, DateTime.now());
      final sentinel = await sentinelLibrary(destP, dest);
      final snapshot = await manager.export(OperationToken());
      final file = File(
        '${snapshot.directory.path}/payload/data/custom_exercises.jsonl',
      );
      final row =
          jsonDecode((await file.readAsLines()).single) as Map<String, dynamic>;
      row['snapshot'] = '${'[' * 65}0${']' * 65}';
      await file.writeAsString('${jsonEncode(row)}\n');
      final entry = (snapshot.manifest['entries'] as List).singleWhere(
        (e) => e['path'] == 'data/custom_exercises.jsonl',
      );
      entry['size'] = await file.length();
      entry['sha256'] = await fileDigest(file);
      final corrupt = File('${snapshot.directory.path}/nested.articulate');
      await const ArchiveCodec().pack(
        Directory('${snapshot.directory.path}/payload'),
        snapshot.manifest,
        corrupt,
        OperationToken(),
      );
      await expectLater(
        target.stageFile(corrupt, OperationToken()),
        throwsA(isA<DataFailure>()),
      );
      expect(
        (await destP.load(sentinel)).response.body,
        'My original library must survive.',
      );
    } finally {
      await db.close();
      await destDb.close();
      await root.delete(recursive: true);
      await dest.delete(recursive: true);
    }
  });
  test('advanced archive restores versions, schedules, overrides, preferences and retry provenance', () async {
    final (root, db, p, manager) = await dataLibrary();
    final (dest, destDb, destP, target) = await dataLibrary();
    try {
      final advanced = AdvancedRepository(p), now = DateTime(2026, 10, 27);
      final custom = await advanced.saveCustom(customTemplate().snapshot, now);
      final original = await advanced.start(
        Exercise.fromSnapshot(custom.snapshot),
        'original',
        now,
        label: 'benchmark',
        conditions: 'Untimed at desk',
      );
      await p.transition(original, PracticeStatus.completed, now);
      final retry = await advanced.start(
        (await p.load(original)).exercise,
        'retry',
        now,
        parent: original,
        target: 'Add support for the main claim',
      );
      final (_, recall) = await completedRecall(p);
      await advanced.observe(recall, 'withHelp', now);
      await advanced.override(recall, date: '2026-11-10', paused: true);
      await advanced.saveIntervals([2, 4, 8]);
      await p.saveSetting('practiceRecommendations', 'false');
      final snapshot = await manager.export(OperationToken());
      final preview = await target.stageFile(snapshot.file, OperationToken());
      expect(preview.manifest['schemaVersion'], 9);
      expect((preview.manifest['tables'] as Map).length, 19);
      await target.replace(preview, OperationToken(), confirmed: true);
      final restored = AdvancedRepository(destP);
      expect(
        (await restored.customVersions()).single.snapshot,
        custom.snapshot,
      );
      expect((await restored.queue()).single.date, '2026-11-10');
      expect((await restored.queue()).single.schedule.paused, isTrue);
      expect(await restored.intervals(), [2, 4, 8]);
      expect(
        (await destDb.select(destDb.practiceContexts).get())
            .singleWhere((c) => c.sessionId == retry)
            .parentSessionId,
        original,
      );
      expect((await target.planSession(original)).ids, {original, retry});
      await validateAdvancedLibrary(destDb);
      await target.deleteSession(original, confirmed: true);
      expect((await destDb.select(destDb.practiceContexts).get()), isEmpty);
      expect((await restored.queue()).single.schedule.sessionId, recall);
    } finally {
      await db.close();
      await destDb.close();
      await root.delete(recursive: true);
      await dest.delete(recursive: true);
    }
  });
  test('schema-8 logical archive restores into schema 9 without fabricating advanced records', () async {
    final (root, db, p, manager) = await dataLibrary(fixture: true);
    final (dest, destDb, destP, target) = await dataLibrary();
    try {
      final snapshot = await manager.export(OperationToken());
      final unpacked = await Directory('${root.path}/legacy-payload').create();
      final codec = ArchiveCodec();
      final manifest = await codec.unpack(
        snapshot.file,
        unpacked,
        OperationToken(),
      );
      manifest['schemaVersion'] = 8;
      manifest['appVersion'] = '1.0.1+11';
      (manifest['tables'] as Map).removeWhere(
        (k, v) => !legacyLogicalTables.contains(k),
      );
      (manifest['entries'] as List).removeWhere(
        (e) =>
            e['path'].toString().startsWith('data/') &&
            !legacyLogicalTables.any((t) => e['path'] == 'data/$t.jsonl'),
      );
      final file = File('${root.path}/legacy.articulate');
      await codec.pack(unpacked, manifest, file, OperationToken());
      final preview = await target.stageFile(file, OperationToken());
      expect(preview.sessions, 15);
      await target.replace(preview, OperationToken(), confirmed: true);
      expect(await destDb.select(destDb.customExercises).get(), isEmpty);
      expect(await destDb.select(destDb.practiceContexts).get(), isEmpty);
      expect(await AdvancedRepository(destP).queue(), isEmpty);
      expect(await AdvancedRepository(destP).intervals(), defaultIntervals);
      expect(await destDb.select(destDb.practiceSessions).get(), hasLength(15));
    } finally {
      await db.close();
      await destDb.close();
      await root.delete(recursive: true);
      await dest.delete(recursive: true);
    }
  });
  test('restart keeps exact custom snapshot and schedule; corrupt references are rejected in staging', () async {
    final root = await Directory.systemTemp.createTemp(
      'articulate-advanced-restart-',
    );
    var db = AppDatabase(NativeDatabase(File('${root.path}/test.sqlite')));
    try {
      var p = PracticeRepository(db), repo = AdvancedRepository(p);
      final (_, id) = await completedRecall(p);
      await repo.observe(id, 'needsWork', DateTime(2026, 10, 27));
      final custom = await repo.saveCustom(
        customTemplate().snapshot,
        DateTime.now(),
      );
      await db.close();
      db = AppDatabase(NativeDatabase(File('${root.path}/test.sqlite')));
      p = PracticeRepository(db);
      repo = AdvancedRepository(p);
      expect((await repo.queue()).single.schedule.sessionId, id);
      expect((await repo.customVersions()).single.snapshot, custom.snapshot);
      await db.customStatement(
        "UPDATE recall_schedules SET recommended_date='2026-02-30'",
      );
      await expectLater(validateAdvancedLibrary(db), throwsFormatException);
      final invalid = jsonDecode(custom.snapshot) as Map<String, dynamic>;
      invalid['exercises'][0]['rubric']['criteria'] = [];
      await expectLater(
        repo.saveCustom(jsonEncode(invalid), DateTime.now()),
        throwsFormatException,
      );
    } finally {
      await db.close();
      await root.delete(recursive: true);
    }
  });
}
