import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/debate/debate_content.dart';
import 'package:articulate/debate/debate_controller.dart';
import 'package:articulate/debate/debate_repository.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/memory/memory_document.dart';
import 'package:articulate/memory/memory_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';
import 'persistence_test.dart' show FakeClock;

Exercise debateExercise() => validateExercisePack(
  File('assets/exercises/debate-v1.json').readAsStringSync(),
).first;
Future<void> finish(DebateController c) async {
  while (!c.round!.closed) {
    await c.advance(c.round!.active.stageKey);
  }
}

void main() {
  test('three original levels have fixed scripts for both positions and all five anchored rubric labels', () {
    final source = File('assets/exercises/debate-v1.json').readAsStringSync(),
        pack = validateExercisePack(source);
    expect(pack.map((e) => e.level).toSet(), {
      'beginner',
      'intermediate',
      'advanced',
    });
    for (final e in pack) {
      expect(e.criteria.map((c) => c['id']).toSet(), debateCriteria.toSet());
      for (final side in ['for', 'against']) {
        expect(e.content['debate'][side]['kind'], 'scripted');
        expect(e.content['debate'][side]['argument'], isNotEmpty);
      }
    }
    final bad = jsonDecode(source);
    bad['exercises'][0]['debate']['for']['kind'] = 'live opponent';
    expect(() => validateExercisePack(jsonEncode(bad)), throwsFormatException);
    final broken = jsonDecode(source);
    broken['exercises'][0]['rubric']['criteria'][0].remove('anchors');
    expect(
      () => validateExercisePack(jsonEncode(broken)),
      throwsFormatException,
    );
    for (final value in [
      [],
      [0, 0, 0, 0, -1],
      [0, 0, 0, 0, 3601],
      [0, 0, 0, 0, 1.5],
    ]) {
      expect(() => validateDebateTargets(value), throwsArgumentError);
    }
  });
  test('stage order, explicit skips and duplicate advancement preserve all fields and do not invent a winner', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final p = PracticeRepository(db),
        repo = DebateRepository(PracticeRepository(db));
    final id = await repo.create(
      debateExercise(),
      'for',
      'written',
      'Untimed round',
      [0, 0, 0, 0, 0],
      DateTime.now(),
    );
    final c = DebateController(repo, id);
    await c.open();
    expect(
      c.round!.script['argument'],
      debateExercise().content['debate']['against']['argument'],
    );
    await expectLater(c.startTimer(), throwsStateError);
    expect(c.round!.detail.elapsedMs, 0);
    await c.save('preparation', {
      'claim': 'A predictable option.',
      'reasoning': 'Visitors can plan.',
      'evidence': 'Imagine a visitor who needs quiet.',
      'sourceNotes': 'Hypothetical example; no measured outcomes.',
      'supportKind': 'example',
    });
    await expectLater(
      c.save('rebuttal', {'rebuttal': 'Future stage'}),
      throwsStateError,
    );
    await c.advance('preparation');
    await c.advance('preparation');
    expect(c.round!.active.stageKey, 'opening');
    await c.save('opening', {'opening': 'A saved opening even when skipped.'});
    await c.advance('opening', skip: true);
    await c.save('opposition', {
      'counterargument':
          'Some visitors can only attend during the quiet period.',
    });
    await c.advance('opposition');
    await c.save('rebuttal', {
      'rebuttal': 'A trial could reveal that scheduling problem; I concede the schedule needs review.',
      'supportKind': 'assertion',
    });
    await c.advance('rebuttal');
    await c.save('reflection', {
      'reflection': 'Ask what evidence would change the schedule.',
    });
    await c.advance('reflection');
    await c.advance('reflection');
    final r = await repo.load(id);
    expect(r.stages.map((s) => s.stageKey).toList(), debateStageKeys);
    expect(r.stages.map((s) => s.status).toList(), [
      'completed',
      'skipped',
      'completed',
      'completed',
      'completed',
    ]);
    expect(
      jsonDecode(r.stages[1].fields)['opening'],
      contains('saved opening'),
    );
    expect(r.detail.session.status, 'completed');
    expect((await db.select(db.practiceSessions).get()).length, 1);
    expect(r.detail.review, isNull);
    await expectLater(
      c.save('rebuttal', {'rebuttal': 'overwrite'}),
      throwsStateError,
    );
    await repo.review(id, {}, '', DateTime.now());
    expect(jsonDecode((await repo.load(id)).workspace.assessments), isEmpty);
    expect((await p.load(id)).review!.status, 'reviewed');
    expect(r.detail.exercise.content.containsKey('winner'), isFalse);
  });
  test('optional per-stage timing excludes pause, wall-clock jumps and unknown interruption gaps', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DebateRepository(PracticeRepository(db)), clock = FakeClock();
    final id = await repo.create(
      debateExercise(),
      'against',
      'written',
      'Custom',
      [10, 0, 10, 10, 0],
      clock.localNow(),
    );
    final c = DebateController(repo, id, clock: clock);
    await c.open();
    await c.startTimer();
    clock.advance(2000);
    await c.checkpoint();
    await c.pauseTimer();
    clock.advance(50000);
    await c.startTimer();
    clock.wall = clock.wall.subtract(const Duration(days: 2));
    clock.ticks += 3000;
    await c.checkpoint();
    await c.advance('preparation');
    expect(c.round!.stages.first.elapsedMs, 5000);
    await expectLater(c.startTimer(), throwsStateError);
    clock.advance(90000);
    await c.advance('opening');
    expect(c.round!.stages[1].elapsedMs, 0);
    await c.startTimer();
    clock.advance(1500);
    await c.checkpoint();
    clock.advance(20000);
    await c.checkpoint();
    expect(c.round!.detail.session.status, 'interrupted');
    expect(c.elapsed('opposition'), 1500);
    await c.advance('opposition', skip: true);
    expect(c.round!.stages[2].elapsedMs, 1500);
    expect(c.round!.detail.elapsedMs, 6500);
  });
  test('native file reopen restores active stage, sources, presets and only committed time', () async {
    final root = await Directory.systemTemp.createTemp('debate-restart-');
    addTearDown(() => root.delete(recursive: true));
    final file = File('${root.path}/round.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var p = PracticeRepository(db);
    var repo = DebateRepository(p);
    final clock = FakeClock();
    final id = await repo.create(
      debateExercise(),
      'for',
      'written',
      'Short custom',
      [30, 60, 0, 90, 0],
      clock.localNow(),
    );
    var c = DebateController(repo, id, clock: clock);
    await c.open();
    await c.save('preparation', {
      'claim': 'Keep this claim.',
      'sourceNotes': 'Source not yet checked.',
      'supportKind': 'assertion',
    });
    await c.startTimer();
    clock.advance(2000);
    await c.checkpoint();
    clock.advance(7000);
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    repo = DebateRepository(p);
    await p.recoverInterrupted();
    c = DebateController(repo, id, clock: FakeClock());
    await c.open();
    expect(c.round!.detail.session.status, 'interrupted');
    expect(c.elapsed('preparation'), 2000);
    expect(c.round!.targets, [30, 60, 0, 90, 0]);
    expect(
      jsonDecode(c.round!.active.fields)['sourceNotes'],
      'Source not yet checked.',
    );
    await c.advance('preparation');
    await finish(c);
    final snapshot = c.round!.detail.session.snapshot;
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    final r = await DebateRepository(PracticeRepository(db)).load(id);
    expect(r.detail.session.snapshot, snapshot);
    expect(r.stages.first.elapsedMs, 2000);
    await db.close();
  });
  test('text review anchors must match the saved stage and ratings allow Not assessed', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DebateRepository(PracticeRepository(db));
    final id = await repo.create(
      debateExercise(),
      'against',
      'written',
      'Untimed',
      [0, 0, 0, 0, 0],
      DateTime.now(),
    );
    final c = DebateController(repo, id);
    await c.open();
    await c.advance('preparation');
    await c.save('opening', {'opening': 'A careful opening.'});
    await finish(c);
    final review = {
      'relevance': {
        'rating': null,
        'note': 'Check the link.',
        'anchor': {
          'kind': 'text',
          'stage': 'opening',
          'field': 'opening',
          'start': 0,
          'end': 9,
          'quote': 'A careful',
        },
      },
    };
    await repo.review(id, review, 'Next action', DateTime.now());
    expect(
      jsonDecode(
        (await repo.load(id)).workspace.assessments,
      )['relevance']['rating'],
      isNull,
    );
    review['relevance']!['anchor'] = {
      'kind': 'text',
      'stage': 'opening',
      'field': 'opening',
      'start': 0,
      'end': 9,
      'quote': 'not equal',
    };
    await expectLater(
      repo.review(id, review, '', DateTime.now()),
      throwsArgumentError,
    );
    expect((await repo.load(id)).workspace.reviewNote, 'Next action');
    await expectLater(
      repo.review(
        id,
        {
          'truth': {'rating': 'effective', 'note': ''},
        },
        '',
        DateTime.now(),
      ),
      throwsArgumentError,
    );
  });
  test('shared audio binds to its active stage, survives missing files, and cannot cross stage capture ownership', () async {
    final root = await Directory.systemTemp.createTemp('debate-audio-');
    final db = AppDatabase(NativeDatabase.memory());
    final p = PracticeRepository(db),
        repo = DebateRepository(PracticeRepository(db));
    final store = AudioStore(p, root),
        audio = LocalAudio(
          AudioStore(p, root),
          FakeAudioBackend(),
          automaticHeartbeat: false,
        );
    addTearDown(() async {
      await audio.close();
      await db.close();
      await root.delete(recursive: true);
    });
    final id = await repo.create(
      debateExercise(),
      'for',
      'recorded',
      'Untimed',
      [0, 0, 0, 0, 0],
      DateTime.now(),
    );
    final c = DebateController(repo, id);
    await c.open();
    await expectLater(audio.start(id, contextKey: 'opening'), throwsStateError);
    await c.advance('preparation');
    await audio.start(id, contextKey: 'opening');
    await expectLater(
      audio.start(id, contextKey: 'rebuttal'),
      throwsA(isA<AudioFailure>()),
    );
    await expectLater(c.advance('opening'), throwsStateError);
    await audio.stop();
    final opening = audio.lastStopped!;
    await c.advance('opening');
    await c.advance('opposition');
    await audio.start(id, contextKey: 'rebuttal');
    await audio.stop();
    final rebuttal = audio.lastStopped!;
    expect(
      (await store.watch(id, contextKey: 'opening').first).single.id,
      opening.id,
    );
    expect(
      (await store.watch(id, contextKey: 'rebuttal').first).single.id,
      rebuttal.id,
    );
    await finish(c);
    await repo.review(
      id,
      {
        'response': {
          'rating': 'developing',
          'note': 'Review this response.',
          'anchor': {
            'kind': 'audio',
            'recordingId': rebuttal.id,
            'positionMs': 500,
          },
        },
      },
      '',
      DateTime.now(),
    );
    await store.fileFor(rebuttal.relativePath).delete();
    await expectLater(audio.select(rebuttal), throwsA(isA<AudioFailure>()));
    expect((await repo.load(id)).workspace.assessments, contains(rebuttal.id));
    expect(
      (await repo.load(id)).detail.exercise.content.containsKey('truth'),
      isFalse,
    );
  });
  test('v6 to v7 migration preserves Memory versions, historical snapshots, audio and settings', () async {
    final root = await Directory.systemTemp.createTemp('debate-v6-');
    addTearDown(() => root.delete(recursive: true));
    final file = File('${root.path}/old.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var p = PracticeRepository(db);
    final m = MemoryRepository(p);
    final doc = validateMemoryPack(
      File('assets/exercises/memory-v1.json').readAsStringSync(),
    ).first;
    final v = await m.publish(await m.saveDraft(null, doc.data));
    final id = await m.createAttempt(
      v.id,
      'section-1',
      'meaning',
      'spoken',
      'keywords',
    );
    await p.saveSetting('theme', 'dark');
    final a = LocalAudio(
      AudioStore(p, root),
      FakeAudioBackend(),
      automaticHeartbeat: false,
    );
    await a.start(id);
    await a.stop();
    final take = a.lastStopped!;
    await a.close();
    final snapshot = (await p.load(id)).session.snapshot;
    await db.customStatement('DROP TABLE impromptu_workspaces');
    await db.customStatement('DROP TABLE impromptu_queues');
    await db.customStatement('DROP TABLE debate_stages');
    await db.customStatement('DROP TABLE debate_workspaces');
    await db.customStatement(
      'ALTER TABLE audio_recordings DROP COLUMN context_key',
    );
    await db.customStatement('PRAGMA user_version=6');
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    expect((await p.load(id)).session.snapshot, snapshot);
    expect((await MemoryRepository(p).workspace(id)).versionId, v.id);
    expect((await db.select(db.audioRecordings).get()).single.id, take.id);
    expect((await db.select(db.audioRecordings).get()).single.contextKey, '');
    expect(await p.watchSettings().first, {'theme': 'dark'});
    expect(await db.select(db.debateStages).get(), isEmpty);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle())
          .data
          .values
          .single,
      9,
    );
    await db.close();
  });
}
