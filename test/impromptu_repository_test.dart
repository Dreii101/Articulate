import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/impromptu/impromptu_content.dart';
import 'package:articulate/impromptu/impromptu_controller.dart';
import 'package:articulate/impromptu/impromptu_repository.dart';
import 'package:articulate/debate/debate_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';
import 'persistence_test.dart' show FakeClock;
import 'debate_repository_test.dart' show debateExercise;

List<Exercise> impromptuQuestions() => validateExercisePack(
  File('assets/exercises/impromptu-v1.json').readAsStringSync(),
);
Future<void> finishImpromptu(ImpromptuController c) async {
  while (!c.attempt!.closed) {
    await c.advance(c.attempt!.workspace.viewStep);
  }
}

void main() {
  test('original bank covers three levels and categories with anchored human criteria', () {
    final bank = impromptuQuestions();
    expect(bank.length, 18);
    for (final level in exerciseLevels) {
      for (final category in impromptuCategories.keys) {
        expect(
          bank
              .where(
                (e) =>
                    e.level == level &&
                    e.content['impromptu']['category'] == category,
              )
              .length,
          2,
        );
      }
    }
    for (final e in bank) {
      expect(e.criteria.map((c) => c['id']).toSet(), impromptuCriteria.toSet());
    }
    final broken = jsonDecode(bank.first.snapshot);
    broken['exercises'][0]['impromptu']['category'] = 'network';
    expect(
      () => validateExercisePack(jsonEncode(broken)),
      throwsFormatException,
    );
    final missing = jsonDecode(bank.first.snapshot);
    missing['exercises'][0]['rubric']['criteria'][0].remove('anchors');
    expect(
      () => validateExercisePack(jsonEncode(missing)),
      throwsFormatException,
    );
    for (final targets in [
      [],
      [1, -1],
      [0, 3601],
      [0, 1.2],
    ]) {
      expect(() => validateImpromptuTargets(targets), throwsArgumentError);
    }
  });
  test('seeded queue shuffles without repeats, exhausts, and duplicate concurrent starts consume once', () async {
    Future<List<String>> sequence() async {
      final db = AppDatabase(NativeDatabase.memory());
      final p = PracticeRepository(db), now = DateTime.utc(2026);
      final repo = ImpromptuRepository(p, random: Random(42)),
          pool = impromptuQuestions().take(6).toList();
      final starts = await Future.wait([
        for (var i = 0; i < 2; i++)
          repo.start(pool, 'same', 'unrecorded', 'Untimed', [0, 0], now),
      ]);
      expect(starts[0], starts[1]);
      expect((await db.select(db.practiceSessions).get()).length, 1);
      final selected = [(await repo.load(starts[0])).detail.exercise.id];
      for (var i = 1; i < 12; i++) {
        final id = await repo.start(
          pool,
          'request-$i',
          'unrecorded',
          'Untimed',
          [0, 0],
          now,
        );
        selected.add((await repo.load(id)).detail.exercise.id);
      }
      expect(selected.take(6).toSet().length, 6);
      expect(selected.skip(6).toSet().length, 6);
      expect(selected[6], isNot(selected[5]));
      await db.close();
      return selected;
    }

    expect(await sequence(), await sequence());
  });
  test('file restart preserves hidden selection, remaining queue, scaffold, response and only committed time', () async {
    final root = await Directory.systemTemp.createTemp('impromptu-restart-');
    addTearDown(() => root.delete(recursive: true));
    final file = File('${root.path}/practice.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var p = PracticeRepository(db),
        repo = ImpromptuRepository(p, random: Random(5));
    final clock = FakeClock();
    final pool = impromptuQuestions().take(6).toList();
    final id = await repo.start(pool, 'persisted', 'unrecorded', 'Custom', [
      30,
      60,
    ], clock.localNow());
    final original = (await repo.load(id)).detail.session.snapshot;
    final remaining =
        (await db.select(db.impromptuQueues).getSingle()).remaining;
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    repo = ImpromptuRepository(p, random: Random(9));
    expect((await repo.load(id)).workspace.viewStep, 'reveal');
    expect((await repo.load(id)).detail.session.snapshot, original);
    expect(
      (await db.select(db.impromptuQueues).getSingle()).remaining,
      remaining,
    );
    expect(
      await repo.start(pool, 'persisted', 'unrecorded', 'Custom', [
        30,
        60,
      ], clock.localNow()),
      id,
    );
    final c = ImpromptuController(repo, id, clock: clock);
    await c.open();
    await c.advance('reveal');
    await c.startTimer();
    clock.advance(2000);
    await c.checkpoint();
    clock.advance(7000);
    await repo.save(id, 'A direct point', 'Remembered answer', true, {
      'point': 'One point',
    }, clock.localNow());
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    repo = ImpromptuRepository(p);
    final reopened = ImpromptuController(repo, id, clock: clock);
    await reopened.open();
    expect(reopened.attempt!.detail.elapsedMs, 2000);
    expect(reopened.attempt!.detail.session.status, 'interrupted');
    expect(reopened.attempt!.workspace.viewStep, 'prepare');
    expect(reopened.attempt!.workspace.preparation, 'A direct point');
    expect(reopened.attempt!.workspace.scaffoldEnabled, isTrue);
    expect(reopened.attempt!.detail.response.body, 'Remembered answer');
    final next = await repo.start(pool, 'next', 'unrecorded', 'Untimed', [
      0,
      0,
    ], clock.localNow());
    expect(
      (await repo.load(next)).detail.exercise.id,
      (jsonDecode(remaining) as List).first,
    );
    await db.close();
  });
  test('stage timer excludes pauses, wall jumps and interruption gaps and duplicate transitions do not skip', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ImpromptuRepository(PracticeRepository(db)),
        clock = FakeClock();
    final id = await repo.start(
      impromptuQuestions(),
      'timed',
      'unrecorded',
      'Custom',
      [5, 5],
      clock.localNow(),
    );
    final c = ImpromptuController(repo, id, clock: clock);
    await c.open();
    await expectLater(c.startTimer(), throwsStateError);
    await Future.wait([c.advance('reveal'), c.advance('reveal')]);
    expect(c.attempt!.workspace.viewStep, 'prepare');
    await c.startTimer();
    await c.startTimer();
    clock.advance(2000);
    await c.pause();
    clock.advance(5000);
    await c.startTimer();
    clock.wall = clock.wall.subtract(const Duration(days: 3));
    clock.ticks += 1000;
    await c.checkpoint();
    clock.advance(20000);
    await c.checkpoint();
    expect(c.attempt!.detail.elapsedMs, 3000);
    expect(c.attempt!.detail.session.status, 'interrupted');
    await c.advance('prepare');
    await c.advance('prepare');
    expect(c.attempt!.workspace.viewStep, 'respond');
    await c.startTimer();
    clock.advance(1000);
    await c.advance('respond');
    await c.advance('respond');
    expect(c.elapsed(PracticeStage.prepare), 3000);
    expect(c.elapsed(PracticeStage.respond), 1000);
    expect(c.attempt!.detail.session.status, 'completed');
    expect(c.attempt!.detail.reviewStatus, ReviewStatus.unreviewed);
    final untimed = await repo.start(
      impromptuQuestions(),
      'untimed',
      'unrecorded',
      'Untimed',
      [0, 0],
      clock.localNow(),
    );
    final u = ImpromptuController(repo, untimed, clock: clock);
    await u.open();
    await u.advance('reveal');
    await expectLater(u.startTimer(), throwsStateError);
    await finishImpromptu(u);
    expect(u.attempt!.detail.elapsedMs, 0);
  });
  test('retry retains exact question and rubric, preserves original, consumes no queue, confidence is independent', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final p = PracticeRepository(db),
        repo = ImpromptuRepository(p),
        now = DateTime.utc(2026);
    final id = await repo.start(
      impromptuQuestions(),
      'original',
      'unrecorded',
      'Untimed',
      [0, 0],
      now,
    );
    final c = ImpromptuController(repo, id);
    await c.open();
    await c.advance('reveal');
    await repo.save(id, 'Notes', 'My first answer', false, {}, now);
    await finishImpromptu(c);
    await repo.review(
      id,
      {
        'directness': {'rating': null, 'note': 'Not assessed'},
      },
      'Answer earlier.',
      5,
      now,
    );
    final original = await repo.load(id),
        queue = (await db.select(db.impromptuQueues).getSingle()).remaining;
    final retries = await Future.wait([
      repo.retry(id, 'Answer earlier.', now),
      repo.retry(id, 'A duplicate request.', now),
    ]);
    expect(retries.first, retries.last);
    final retry = await repo.load(retries.first);
    expect(retry.workspace.parentSessionId, id);
    expect(retry.workspace.improvement, 'Answer earlier.');
    expect(retry.detail.session.snapshot, original.detail.session.snapshot);
    expect(retry.detail.response.body, isEmpty);
    expect((await db.select(db.impromptuQueues).getSingle()).remaining, queue);
    expect(original.workspace.confidence, 5);
    expect(
      jsonDecode(original.workspace.assessments)['directness']['rating'],
      isNull,
    );
    await expectLater(
      repo.save(id, '', 'Overwritten', false, {}, now),
      throwsStateError,
    );
    await expectLater(repo.review(id, {}, '', 6, now), throwsArgumentError);
    expect((await repo.load(id)).detail.response.body, 'My first answer');
  });
  test('audio is response-only and completion waits for finalization; missing media retains review', () async {
    final root = await Directory.systemTemp.createTemp('impromptu-audio-');
    addTearDown(() => root.delete(recursive: true));
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final p = PracticeRepository(db), repo = ImpromptuRepository(p);
    final audio = LocalAudio(
      AudioStore(p, root),
      FakeAudioBackend(),
      automaticHeartbeat: false,
    );
    addTearDown(audio.close);
    final id = await repo.start(
      impromptuQuestions(),
      'spoken',
      'recorded',
      'Untimed',
      [0, 0],
      DateTime.now(),
    );
    final c = ImpromptuController(repo, id);
    await c.open();
    await expectLater(audio.start(id), throwsStateError);
    await c.advance('reveal');
    await expectLater(audio.start(id), throwsStateError);
    await c.advance('prepare');
    await audio.start(id);
    await expectLater(c.advance('respond'), throwsStateError);
    await audio.stop();
    final take = audio.lastStopped!;
    await c.advance('respond');
    await repo.review(
      id,
      {},
      'Remember a clearer close.',
      null,
      DateTime.now(),
    );
    await audio.store.fileFor(take.relativePath).delete();
    await expectLater(audio.select(take), throwsA(isA<AudioFailure>()));
    expect(
      (await repo.load(id)).workspace.reflection,
      'Remember a clearer close.',
    );
    expect((await audio.store.watch(id).first).single.id, take.id);
  });
  test(
    'v7 to v8 migration preserves Debate fields, snapshots and settings',
    () async {
      final root = await Directory.systemTemp.createTemp('impromptu-v7-');
      addTearDown(() => root.delete(recursive: true));
      final file = File('${root.path}/old.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var p = PracticeRepository(db);
      final debate = DebateRepository(p), now = DateTime.now();
      final id = await debate.create(
        debateExercise(),
        'for',
        'written',
        'Untimed',
        [0, 0, 0, 0, 0],
        now,
      );
      await debate.saveFields(id, 'preparation', {
        'claim': 'Preserve my argument',
      }, now);
      await p.saveSetting('theme', 'dark');
      final snapshot = (await p.load(id)).session.snapshot;
      await db.customStatement('DROP TABLE impromptu_workspaces');
      await db.customStatement('DROP TABLE impromptu_queues');
      await db.customStatement('PRAGMA user_version=7');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      p = PracticeRepository(db);
      expect((await p.load(id)).session.snapshot, snapshot);
      expect(
        (await DebateRepository(p).load(id)).stages.first.fields,
        contains('Preserve my argument'),
      );
      expect(await p.watchSettings().first, {'theme': 'dark'});
      expect(await db.select(db.impromptuWorkspaces).get(), isEmpty);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        9,
      );
      await db.close();
    },
  );
}
