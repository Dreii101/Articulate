import 'dart:convert';
import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/writing/writing_repository.dart';
import 'package:articulate/reading/reading_repository.dart';
import 'package:articulate/memory/memory_document.dart';
import 'package:articulate/memory/memory_repository.dart';
import 'package:articulate/debate/debate_repository.dart';
import 'package:articulate/debate/debate_controller.dart';
import 'package:articulate/impromptu/impromptu_repository.dart';
import 'package:articulate/impromptu/impromptu_controller.dart';
import 'package:drift/drift.dart';

List<Exercise> historyPack(String name) => validateExercisePack(
  File('assets/exercises/$name-v1.json').readAsStringSync(),
);

// One transactional fixture; the independent ledger is 3300 prepare + 12500 respond + 900 reflect = 16700 ms.
Future<Map<String, String>> seedHistoryFixture(
  PracticeRepository p, {
  Map<String, List<Exercise>>? packs,
  String? memorySource,
}) => p.db.transaction(() async {
  final db = p.db, ids = <String, String>{}, now = DateTime.utc(2026, 10, 26);
  List<Exercise> pack(String name) => packs?[name] ?? historyPack(name);
  final w = WritingRepository(p), e = pack('writing').first;
  Future<String> writing(Exercise exercise, String text) async {
    final id = await p.createDraft(exercise, now);
    await w.open(id);
    await p.saveResponse(id, text, now);
    await p.transition(id, PracticeStatus.completed, now);
    return id;
  }

  ids['w1'] = await writing(e, 'First draft with an example.');
  final workspace = await w.open(ids['w1']!);
  await w.save(
    ids['w1']!,
    outline: workspace.outline,
    audience: workspace.audience,
    purpose: workspace.purpose,
    step: 'review',
    assessments: {
      'purpose': {
        'rating': 'effective',
        'evidence': 'First',
        'start': 0,
        'end': 5,
      },
    },
    nextAction: 'Use a sharper example.',
    now: now,
  );
  await w.finishReview(ids['w1']!, now);
  await w.finishReview(ids['w1']!, now);
  ids['w2'] = await w.createRevision(ids['w1']!, now);
  await p.saveResponse(ids['w2']!, 'Second draft: a revised example.', now);
  await p.transition(ids['w2']!, PracticeStatus.completed, now);
  ids['w3'] = await w.createRevision(ids['w2']!, now);
  await p.saveResponse(ids['w3']!, 'Third draft: a clearer close.', now);
  await p.transition(ids['w3']!, PracticeStatus.completed, now);
  final altered = jsonDecode(e.snapshot);
  altered['exercises'][0]['rubric']['version'] = 2;
  ids['rubric'] = await writing(
    Exercise.fromSnapshot(jsonEncode(altered)),
    'A later rubric version.',
  );
  final translated = jsonDecode(e.snapshot);
  translated['exercises'][0]['language'] = 'fr';
  ids['language'] = await writing(
    Exercise.fromSnapshot(jsonEncode(translated)),
    'Une réponse personnelle.',
  );
  ids['different'] = await writing(
    pack('writing').last,
    'A different task and level.',
  );
  final re = pack('reading').first, reading = ReadingRepository(p);
  ids['reading'] = await p.createDraft(re, now);
  await reading.open(ids['reading']!);
  final qs = readingQuestions(re),
      closed = qs.where((q) => !isOpenQuestion(q)).toList(),
      open = qs.where(isOpenQuestion).toList();
  final answers = <String, dynamic>{
    closed[0]['id'] as String: closed[0]['answerKey'],
    closed[1]['id'] as String: (closed[1]['options'] as List).firstWhere(
      (o) => o['id'] != closed[1]['answerKey'],
    )['id'],
    open.first['id'] as String: 'My first inference and summary.',
  };
  await reading.save(
    ids['reading']!,
    answers: answers,
    revisions: {},
    ratings: {},
    step: 'questions',
    hidePassage: false,
    now: now,
  );
  await reading.check(ids['reading']!, now);
  await reading.check(ids['reading']!, now);
  await reading.save(
    ids['reading']!,
    answers: answers,
    revisions: {
      ...answers,
      open.first['id'] as String: 'A revised answer after explanations.',
    },
    ratings: {open.first['id'] as String: 'developing'},
    step: 'review',
    hidePassage: false,
    now: now,
    reviewed: true,
  );
  ids['speech'] = await p.createDraft(
    pack('core').firstWhere((e) => e.module == 'speech'),
    now,
  );
  await p.saveResponse(ids['speech']!, 'Notes for an unscored rehearsal.', now);
  await p.transition(ids['speech']!, PracticeStatus.completed, now);
  final memory = MemoryRepository(p),
      doc = validateMemoryPack(
        memorySource ??
            File('assets/exercises/memory-v1.json').readAsStringSync(),
      ).first;
  final version = await memory.publish(await memory.saveDraft(null, doc.data));
  ids['memory'] = await memory.createAttempt(
    version.id,
    doc.sections.first['id'] as String,
    'meaning',
    'typed',
    'keywords',
  );
  await p.saveResponse(
    ids['memory']!,
    'Recall notes with one missing transition.',
    now,
  );
  await p.transition(ids['memory']!, PracticeStatus.completed, now);
  await memory.saveReview(
    ids['memory']!,
    {'ideas': 'recalled', 'wording': 'notAssessed', 'transitions': 'missed'},
    'Review the transition.',
    true,
  );
  final debate = DebateRepository(p);
  ids['debate'] = await debate.create(
    pack('debate').first,
    'for',
    'written',
    'Untimed',
    [0, 0, 0, 0, 0],
    now,
  );
  final d = DebateController(debate, ids['debate']!);
  await d.open();
  await d.save('preparation', {'claim': 'A short trial might help.'});
  while (!d.round!.closed) {
    await d.advance(d.round!.active.stageKey);
  }
  // Mirrored stage totals are deliberately nonzero; they must not be added to session-segment totals again.
  await (db.update(db.debateStages)..where(
        (r) =>
            r.sessionId.equals(ids['debate']!) & r.stageKey.equals('opening'),
      ))
      .write(const DebateStagesCompanion(elapsedMs: Value(1000)));
  final imp = ImpromptuRepository(p);
  ids['impromptu'] = await imp.start(
    [pack('impromptu').first],
    'history-root',
    'unrecorded',
    'Untimed',
    [0, 0],
    now,
  );
  Future<void> finish(String id) async {
    final c = ImpromptuController(imp, id);
    await c.open();
    await c.advance('reveal');
    await imp.save(
      id,
      'One point',
      'An answer with one example.',
      false,
      {},
      now,
    );
    await c.advance('prepare');
    await c.advance('respond');
  }

  await finish(ids['impromptu']!);
  await imp.review(ids['impromptu']!, {}, 'Answer earlier.', 5, now);
  ids['retry'] = await imp.retry(ids['impromptu']!, 'Answer earlier.', now);
  await finish(ids['retry']!);
  ids['interrupted'] = await p.createDraft(e, now);
  await p.saveResponse(ids['interrupted']!, 'Interrupted draft survives.', now);
  await p.transition(ids['interrupted']!, PracticeStatus.interrupted, now);
  ids['draft'] = await p.createDraft(e, now);
  ids['running'] = await p.createDraft(e, now);
  var event = 0;
  Future<void> segment(
    String name,
    String stage,
    int ms, {
    bool open = false,
  }) async {
    await db
        .into(db.timingSegments)
        .insert(
          TimingSegmentsCompanion.insert(
            id: 'fixture-segment-${event++}',
            sessionId: ids[name]!,
            stage: stage,
            startedUtcMs: now.millisecondsSinceEpoch,
            checkpointUtcMs: now.millisecondsSinceEpoch + ms,
            elapsedMs: ms,
            endedUtcMs: open
                ? const Value.absent()
                : Value(now.millisecondsSinceEpoch + ms),
            endReason: open ? const Value.absent() : const Value('paused'),
          ),
        );
  }

  await segment('w1', 'prepare', 1000);
  await segment('w1', 'respond', 4000);
  await segment('w1', 'reflect', 500);
  await segment('w2', 'respond', 2000);
  await segment('w3', 'respond', 3000);
  await segment('debate', 'prepare', 600);
  await segment('debate', 'respond', 1000);
  await segment('debate', 'reflect', 400);
  await segment('impromptu', 'prepare', 800);
  await segment('impromptu', 'respond', 1200);
  await segment('retry', 'prepare', 400);
  await segment('retry', 'respond', 600);
  await segment('interrupted', 'prepare', 300);
  await segment('interrupted', 'respond', 700);
  await segment('running', 'prepare', 200);
  await segment('running', 'respond', 5000, open: true);
  await (db.update(db.practiceSessions)
        ..where((s) => s.id.equals(ids['running']!)))
      .write(const PracticeSessionsCompanion(status: Value('running')));
  // Memory creation uses the real clock; pin its date so date-boundary fixtures
  // do not change meaning when the test machine reaches October 27.
  await (db.update(
    db.practiceSessions,
  )..where((s) => s.id.equals(ids['memory']!))).write(
    const PracticeSessionsCompanion(
      localPracticeDate: Value('2026-10-26'),
      originalOffsetMinutes: Value(0),
    ),
  );
  for (final name in ['w1', 'w2', 'w3']) {
    await (db.update(
      db.practiceSessions,
    )..where((s) => s.id.equals(ids[name]!))).write(
      const PracticeSessionsCompanion(
        localPracticeDate: Value('2026-10-25'),
        originalOffsetMinutes: Value(480),
      ),
    );
  }
  await (db.update(
    db.practiceSessions,
  )..where((s) => s.id.equals(ids['interrupted']!))).write(
    const PracticeSessionsCompanion(
      localPracticeDate: Value('2026-10-27'),
      originalOffsetMinutes: Value(-300),
    ),
  );
  for (var i = 0; i < 3; i++) {
    final id = stableId();
    await db
        .into(db.audioRecordings)
        .insert(
          AudioRecordingsCompanion.insert(
            id: id,
            sessionId: ids['speech']!,
            relativePath: 'audio/$id.wav',
            state: 'finalized',
            inputId: 'fixture',
            inputName: 'Synthetic metadata only',
            createdUtcMs: now.millisecondsSinceEpoch,
            durationMs: Value([9000, 3000, 5000][i]),
            microphoneCheck: Value(i == 2),
          ),
        );
    for (var j = 0; j < 2; j++) {
      await db
          .into(db.audioObservations)
          .insert(
            AudioObservationsCompanion.insert(
              id: stableId(),
              recordingId: id,
              positionMs: 100,
              note: 'Fixture observation $j',
              createdUtcMs: now.millisecondsSinceEpoch,
            ),
          );
    }
  }
  return ids;
});
