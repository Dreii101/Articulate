import 'dart:convert';
import 'dart:io';

import 'package:articulate/catalogue.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/session_controller.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

class FakeClock implements PracticeClock {
  DateTime wall = DateTime(2026, 10, 25, 23, 59);
  int ticks = 0;
  @override
  DateTime localNow() => wall;
  @override
  int get monotonicMs => ticks;
  void advance(int ms) {
    ticks += ms;
    wall = wall.add(Duration(milliseconds: ms));
  }
}

class FailingCheckpointRepository extends PracticeRepository {
  FailingCheckpointRepository(super.db);
  bool fail = false;
  @override
  Future<void> checkpoint(
    String id,
    String segmentId,
    int elapsed,
    DateTime now,
  ) {
    if (fail) throw StateError('Simulated storage failure');
    return super.checkpoint(id, segmentId, elapsed, now);
  }
}

void main() {
  // Restart tests intentionally use independent in-memory and file executors.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);
  final source = File('assets/exercises/core-v1.json').readAsStringSync();
  final exercises = validateExercisePack(source);
  late AppDatabase db;
  late PracticeRepository repository;
  late FakeClock clock;
  late SessionController controller;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = PracticeRepository(db);
    clock = FakeClock();
    final id = await repository.createDraft(exercises.first, clock.localNow());
    controller = SessionController(repository, id, clock: clock);
    await controller.open();
  });
  tearDown(() => db.close());

  test(
    'all versioned content preserves the existing 18 previews and metadata',
    () {
      expect(exercises, hasLength(18));
      for (final module in modules) {
        for (var i = 0; i < levels.length; i++) {
          final e = exercises.singleWhere(
            (e) => e.module == module.id && e.level == levels[i].toLowerCase(),
          );
          expect(e.prompt, module.previews[i].prompt);
          expect(e.title, module.previews[i].title);
          expect(e.criteria, isNotEmpty);
          expect(e.content['authorship']['kind'], 'original');
          expect(e.content['license']['notice'], isNotEmpty);
        }
      }
    },
  );

  for (final invalid in [
    'format',
    'duplicate',
    'language',
    'level',
    'rubric',
    'author',
    'license',
    'unknown',
    'empty',
    'fractional-version',
  ]) {
    test('invalid content rejected atomically: $invalid', () {
      final root = jsonDecode(source) as Map<String, dynamic>;
      final e = (root['exercises'] as List).first as Map<String, dynamic>;
      switch (invalid) {
        case 'format':
          root['formatVersion'] = 2;
        case 'duplicate':
          (root['exercises'] as List).add(e);
        case 'language':
          e['language'] = 'not a language';
        case 'level':
          e['level'] = 'expert';
        case 'rubric':
          e['rubric']['criteria'] = [];
        case 'author':
          e.remove('authorship');
        case 'license':
          e['license']['notice'] = '';
        case 'unknown':
          e['typo'] = true;
        case 'empty':
          root['exercises'] = [];
        case 'fractional-version':
          e['version'] = 1.5;
      }
      expect(
        () => validateExercisePack(jsonEncode(root)),
        throwsFormatException,
      );
    });
  }
  test('malformed JSON and oversized input rejected', () {
    expect(() => validateExercisePack('{broken'), throwsFormatException);
    expect(() => validateExercisePack('x' * 1000001), throwsFormatException);
  });

  test('draft saves response, stable ids, original date, UTC timestamp and content snapshot', () async {
    final before = controller.detail!;
    await controller.saveResponse('A saved response with café and 日本語.');
    final d = await repository.load(controller.id);
    expect(d.session.id, before.session.id);
    expect(d.response.id, before.response.id);
    expect(d.session.localPracticeDate, '2026-10-25');
    expect(
      d.session.originalOffsetMinutes,
      clock.localNow().timeZoneOffset.inMinutes,
    );
    expect(
      d.session.createdUtcMs,
      clock.localNow().toUtc().millisecondsSinceEpoch,
    );
    final edited = jsonDecode(source) as Map<String, dynamic>;
    edited['exercises'][0]['prompt'] = 'A different future prompt';
    edited['exercises'][0]['rubric']['criteria'][0]['description'] =
        'Different future rubric';
    validateExercisePack(jsonEncode(edited));
    expect(d.exercise.prompt, exercises.first.prompt);
    expect(d.exercise.criteria, exercises.first.criteria);
    expect(d.response.body, contains('日本語'));
    expect(d.session.status, 'draft');
    expect(d.reviewStatus, ReviewStatus.unreviewed);
  });

  test(
    'pause/resume and stage changes exclude pauses and separate stage totals',
    () async {
      await controller.start();
      clock.advance(3000);
      await controller.checkpoint();
      clock.advance(2000);
      await controller.transition(PracticeStatus.paused);
      clock.advance(60000);
      await controller.start();
      clock.advance(2000);
      await controller.changeStage(PracticeStage.respond);
      clock.advance(4000);
      await controller.transition(PracticeStatus.completed);
      final d = await repository.load(controller.id);
      expect(d.elapsedMs, 11000);
      expect(d.elapsedFor(PracticeStage.prepare), 7000);
      expect(d.elapsedFor(PracticeStage.respond), 4000);
      expect(d.segments, hasLength(3));
      expect(d.openSegment, isNull);
    },
  );

  test('wall clock jumps and midnight do not change elapsed or original practice date', () async {
    await controller.start();
    clock.advance(3000);
    clock.wall = clock.wall.subtract(const Duration(days: 10));
    await controller.checkpoint();
    clock.advance(2000);
    clock.wall = clock.wall.add(const Duration(days: 100));
    await controller.transition(PracticeStatus.completed);
    final d = controller.detail!;
    expect(d.elapsedMs, 5000);
    expect(d.session.localPracticeDate, '2026-10-25');
    expect(
      d.session.originalOffsetMinutes,
      clock.localNow().timeZoneOffset.inMinutes,
    );
  });

  test(
    'delayed heartbeat or sleep excludes the entire uncertain interval',
    () async {
      await controller.start();
      clock.advance(2000);
      await controller.checkpoint();
      clock.advance(60000);
      await controller.checkpoint();
      expect(controller.detail!.session.status, 'interrupted');
      expect(controller.detail!.elapsedMs, 2000);
      await controller.start();
      clock.advance(1000);
      await controller.transition(PracticeStatus.completed);
      expect(controller.detail!.elapsedMs, 3000);
    },
  );

  test(
    'checkpoint retries cannot double count or reduce saved elapsed',
    () async {
      await controller.start();
      final segment = controller.detail!.openSegment!;
      await repository.checkpoint(controller.id, segment.id, 4000, clock.wall);
      await repository.checkpoint(controller.id, segment.id, 4000, clock.wall);
      await repository.checkpoint(controller.id, segment.id, 1000, clock.wall);
      expect((await repository.load(controller.id)).elapsedMs, 4000);
    },
  );

  test('a failed checkpoint stops timing and excludes the failed-write gap on retry', () async {
    final failing = FailingCheckpointRepository(db);
    final session = SessionController(failing, controller.id, clock: clock);
    await session.open();
    await session.start();
    clock.advance(2000);
    await session.checkpoint();
    failing.fail = true;
    clock.advance(1000);
    await expectLater(session.checkpoint(), throwsStateError);
    expect(session.detail!.session.status, 'interrupted');
    clock.advance(60000);
    expect(session.elapsedMs, 2000);
    failing.fail = false;
    await session.start();
    clock.advance(1000);
    await session.transition(PracticeStatus.completed);
    expect(session.detail!.elapsedMs, 3000);
  });

  test('repeated and concurrent completions create one attempt and keep review separate', () async {
    await controller.saveResponse('Final answer');
    await controller.start();
    clock.advance(4000);
    await Future.wait([
      controller.transition(PracticeStatus.completed),
      controller.transition(PracticeStatus.completed),
    ]);
    await repository.transition(
      controller.id,
      PracticeStatus.completed,
      clock.wall.add(const Duration(hours: 1)),
    );
    final d = await repository.load(controller.id);
    expect(d.elapsedMs, 4000);
    expect((await db.select(db.practiceSessions).get()), hasLength(1));
    expect((await db.select(db.responses).get()), hasLength(1));
    final completedAt = d.session.completedUtcMs;
    await controller.saveReview(
      'One specific improvement',
      ReviewStatus.reviewed,
    );
    final reviewId = controller.detail!.review!.id;
    await controller.saveReview('A refined reflection', ReviewStatus.reviewed);
    expect(controller.detail!.review!.id, reviewId);
    expect(controller.detail!.session.completedUtcMs, completedAt);
    expect(controller.detail!.session.status, 'completed');
    expect(controller.detail!.reviewStatus, ReviewStatus.reviewed);
    expect(await db.select(db.reviewRecords).get(), hasLength(1));
    await expectLater(controller.saveResponse('Overwrite'), throwsStateError);
    await expectLater(controller.start(), throwsStateError);
  });

  test('abandon keeps response and saved time and cannot resume', () async {
    await controller.saveResponse('Keep this draft');
    await controller.start();
    clock.advance(1000);
    await controller.transition(PracticeStatus.abandoned);
    expect(controller.detail!.response.body, 'Keep this draft');
    expect(controller.detail!.elapsedMs, 1000);
    await expectLater(controller.start(), throwsStateError);
    await expectLater(
      controller.saveReview('review', ReviewStatus.reviewed),
      throwsStateError,
    );
  });

  test(
    'on-disk reopen recovers running work and never credits the restart gap',
    () async {
      final dir = await Directory.systemTemp.createTemp('articulate-restart-');
      final file = File('${dir.path}/practice.sqlite');
      var disk = AppDatabase(NativeDatabase(file));
      var repo = PracticeRepository(disk);
      final id = await repo.createDraft(exercises.first, clock.wall);
      var session = SessionController(repo, id, clock: clock);
      await session.open();
      await session.saveResponse('Survives an abrupt restart');
      await repo.saveSetting('theme', 'dark');
      await session.start();
      clock.advance(3000);
      await session.checkpoint();
      clock.advance(
        7000,
      ); // No leave() or lifecycle callback: simulate process death.
      await disk.close();
      clock.wall = clock.wall.add(const Duration(days: 4));
      disk = AppDatabase(NativeDatabase(file));
      repo = PracticeRepository(disk);
      await repo.recoverInterrupted();
      await repo.recoverInterrupted();
      session = SessionController(repo, id, clock: FakeClock());
      final recovered = await session.open();
      expect(recovered.session.status, 'interrupted');
      expect(recovered.response.body, 'Survives an abrupt restart');
      expect(recovered.elapsedMs, 3000);
      expect(
        recovered.segments.single.endedUtcMs,
        recovered.segments.single.checkpointUtcMs,
      );
      expect((await repo.watchSettings().first)['theme'], 'dark');
      await disk.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'plain draft survives file close/reopen without becoming interrupted',
    () async {
      final dir = await Directory.systemTemp.createTemp('articulate-draft-');
      final file = File('${dir.path}/practice.sqlite');
      var disk = AppDatabase(NativeDatabase(file));
      var repo = PracticeRepository(disk);
      final id = await repo.createDraft(exercises.first, clock.wall);
      await repo.saveResponse(id, 'Draft, not started', clock.wall);
      await disk.close();
      disk = AppDatabase(NativeDatabase(file));
      repo = PracticeRepository(disk);
      await repo.recoverInterrupted();
      final d = await repo.load(id);
      expect(d.session.status, 'draft');
      expect(d.response.body, 'Draft, not started');
      expect(d.segments, isEmpty);
      await disk.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'settings and response validation fail without overwriting saved values',
    () async {
      await repository.saveSetting('theme', 'dark');
      await expectLater(
        repository.saveSetting('theme', 'bad'),
        throwsArgumentError,
      );
      await expectLater(
        repository.saveSetting('unknown', 'true'),
        throwsArgumentError,
      );
      await controller.saveResponse('Keep');
      await expectLater(
        controller.saveResponse('x' * 100001),
        throwsArgumentError,
      );
      expect((await repository.load(controller.id)).response.body, 'Keep');
      expect((await repository.watchSettings().first)['theme'], 'dark');
    },
  );
}
