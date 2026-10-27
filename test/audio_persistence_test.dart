import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/reading/reading_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/writing/writing_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';

void main() {
  test(
    'v4 → v6 preserves writing versions and reading first/revised answers',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'articulate-v4-audio-',
      );
      final file = File('${root.path}/test.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var p = PracticeRepository(db);
      final now = DateTime(2026, 10, 25);
      final writing = validateExercisePack(
        File('assets/exercises/writing-v1.json').readAsStringSync(),
      ).first;
      final w = WritingRepository(p);
      final parent = await p.createDraft(writing, now);
      await w.open(parent);
      await p.saveResponse(parent, 'Keep the original.', now);
      await p.transition(parent, PracticeStatus.completed, now);
      final child = await w.createRevision(parent, now);
      await p.saveResponse(child, 'Keep the revision too.', now);
      final reading = validateExercisePack(
        File('assets/exercises/reading-v1.json').readAsStringSync(),
      ).first;
      final id = await p.createDraft(reading, now);
      final r = ReadingRepository(p);
      await r.save(
        id,
        answers: {'literal': 'c', 'summary': 'Keep my reading answer.'},
        revisions: {},
        ratings: {},
        step: 'questions',
        hidePassage: true,
        now: now,
      );
      await r.check(id, now);
      await r.save(
        id,
        answers: {'literal': 'c', 'summary': 'Keep my reading answer.'},
        revisions: {'literal': 'a'},
        ratings: {'summary': null},
        step: 'review',
        hidePassage: true,
        now: now,
        reviewed: true,
      );
      await p.saveSetting('theme', 'dark');
      // These empty v5 tables are absent in the otherwise unchanged v4 schema.
      await db.customStatement('DROP TABLE impromptu_workspaces');
      await db.customStatement('DROP TABLE impromptu_queues');
      await db.customStatement('DROP TABLE debate_stages');
      await db.customStatement('DROP TABLE debate_workspaces');
      await db.customStatement('DROP TABLE memory_workspaces');
      await db.customStatement('DROP TABLE memory_versions');
      await db.customStatement('DROP TABLE memory_speeches');
      await db.customStatement('DROP TABLE audio_observations');
      await db.customStatement('DROP TABLE audio_recordings');
      await db.customStatement('PRAGMA user_version = 4');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      p = PracticeRepository(db);
      expect((await p.load(parent)).response.body, 'Keep the original.');
      expect((await p.load(child)).response.body, 'Keep the revision too.');
      expect((await WritingRepository(p).versions(parent)).length, 2);
      final restored = await ReadingRepository(p).open(id);
      expect(
        jsonDecode(restored.keyResults!)['literal']['status'],
        'incorrect',
      );
      expect(jsonDecode(restored.revisionAnswers)['literal'], 'a');
      expect((await p.load(id)).session.snapshot, reading.snapshot);
      expect((await p.watchSettings().first)['theme'], 'dark');
      expect(await db.select(db.audioRecordings).get(), isEmpty);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      await db.close();
      await root.delete(recursive: true);
    },
  );

  test('a pending recording survives database/process-style reopen and is reconciled once', () async {
    final root = await Directory.systemTemp.createTemp(
      'articulate-pending-audio-',
    );
    final file = File('${root.path}/test.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var p = PracticeRepository(db);
    var store = AudioStore(p, root);
    final exercise = validateExercisePack(
      File('assets/exercises/core-v1.json').readAsStringSync(),
    ).firstWhere((e) => e.module == 'speech');
    final id = await p.createDraft(exercise, DateTime(2026, 10, 25));
    await p.saveResponse(id, 'Notes survive the interruption.', DateTime.now());
    final row = await store.reserve(id, 'fixture', 'Synthetic pending input');
    await writeTestWave(store.fileFor(row.relativePath).path, unfinished: true);
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    store = AudioStore(p, root);
    await store.reconcile();
    final recovered = await store.load(row.id);
    expect(recovered.state, 'finalized');
    expect(recovered.interrupted, isTrue);
    expect(recovered.relativePath, row.relativePath);
    expect(recovered.durationMs, 1000);
    expect((await p.load(id)).response.body, 'Notes survive the interruption.');
    await store.reconcile();
    expect((await db.select(db.audioRecordings).get()).length, 1);
    await db.close();
    await root.delete(recursive: true);
  });
}
