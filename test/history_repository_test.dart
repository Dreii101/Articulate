import 'dart:convert';

import 'package:articulate/history/history_repository.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/impromptu/impromptu_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'history_fixture.dart';

void main() {
  late AppDatabase db;
  late PracticeRepository p;
  late HistoryRepository repo;
  late Map<String, String> ids;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    repo = HistoryRepository(p);
    ids = await seedHistoryFixture(p);
  });
  tearDown(() => db.close());
  test('history does not bypass unrevealed questions or ongoing concealed recall and passage practice', () async {
    final reserved = await ImpromptuRepository(p).start(
      [historyPack('impromptu').first],
      'concealed',
      'unrecorded',
      'Untimed',
      [0, 0],
      DateTime.now(),
    );
    await (db.update(db.practiceSessions)..where(
          (s) => s.id.equals(ids['memory']!) | s.id.equals(ids['reading']!),
        ))
        .write(const PracticeSessionsCompanion(status: Value('interrupted')));
    await (db.update(db.readingWorkspaces)
          ..where((w) => w.sessionId.equals(ids['reading']!)))
        .write(const ReadingWorkspacesCompanion(hidePassage: Value(true)));
    final entries = await repo.load(),
        question = entries.singleWhere((e) => e.id == reserved),
        memory = entries.singleWhere((e) => e.id == ids['memory']),
        reading = entries.singleWhere((e) => e.id == ids['reading']);
    expect(question.taskPrompt, contains('Reveal'));
    expect(question.taskPrompt, isNot(question.exercise.prompt));
    expect(memory.evidence.first.text, contains('concealed'));
    expect(memory.taskPrompt, isNot(memory.exercise.prompt));
    expect(reading.evidence.first.text, contains('Passage hidden'));
  });
  test('independent ledger agrees with finalized stage aggregates despite versions, retries, media and repeated review events', () async {
    final entries = await repo.load(),
        summary = HistorySummary(await repo.load());
    expect(entries.length, 15);
    expect(summary.completed, 12);
    expect(summary.stageMs('prepare'), 3300);
    expect(summary.stageMs('respond'), 12500);
    expect(summary.stageMs('reflect'), 900);
    expect(summary.finalizedMs, 16700);
    expect(summary.openSegments, 1);
    final raw = await db.select(db.timingSegments).get();
    expect(
      raw
          .where((r) => r.endedUtcMs != null)
          .fold<int>(0, (n, r) => n + r.elapsedMs),
      16700,
    );
    final speech = entries.singleWhere((e) => e.id == ids['speech']);
    expect(speech.recordedAudioMs, 12000);
    expect(speech.observations.length, 6);
    expect(speech.durations, isEmpty);
    final w1 = entries.singleWhere((e) => e.id == ids['w1']),
        w2 = entries.singleWhere((e) => e.id == ids['w2']);
    expect(w1.timerMs, 5500);
    expect(w2.timerMs, 2000);
    expect(w2.parentId, w1.id);
    final reviews = await (db.select(
      db.reviewRecords,
    )..where((r) => r.sessionId.equals(w1.id))).get();
    expect(reviews.length, 1);
    await p.saveReview(
      w1.id,
      'An edited reflection',
      ReviewStatus.reviewed,
      DateTime.utc(2027),
    );
    await p.saveReview(
      w1.id,
      'An edited reflection',
      ReviewStatus.reviewed,
      DateTime.utc(2027),
    );
    expect(HistorySummary(await repo.load()).finalizedMs, 16700);
  });
  test('filters use original inclusive local dates, language, module, level and exercise, not updated UTC dates', () async {
    final all = await repo.load(),
        writing = all.singleWhere((e) => e.id == ids['w1']);
    final selected = all
        .where(
          HistoryFilter(
            module: 'writing',
            language: 'en',
            level: 'beginner',
            exercise: writing.session.exerciseId,
            from: '2026-10-25',
            to: '2026-10-25',
            status: 'completed',
          ).matches,
        )
        .toList();
    expect(selected.map((e) => e.id).toSet(), {
      ids['w1'],
      ids['w2'],
      ids['w3'],
    });
    expect(HistorySummary(selected).finalizedMs, 10500);
    expect(
      all.where(const HistoryFilter(language: 'fr').matches).single.id,
      ids['language'],
    );
    final interrupted = all
        .where(
          const HistoryFilter(from: '2026-10-27', to: '2026-10-27').matches,
        )
        .single;
    expect(interrupted.id, ids['interrupted']);
    expect(interrupted.session.originalOffsetMinutes, -300);
    expect(interrupted.statusLabel, 'Interrupted');
    expect(all.singleWhere((e) => e.id == ids['draft']).statusLabel, 'Draft');
  });
  test('provenance preserves missing self-ratings, first keys, revised evidence, confidence, memory assistance and output', () async {
    final entries = await repo.load();
    HistoryEntry entry(String name) =>
        entries.singleWhere((e) => e.id == ids[name]);
    expect(
      entry('w2').assessments
          .every((a) => a.value == null && a.display == 'Not assessed'),
      isTrue,
    );
    expect(entry('w1').assessments.first.evidence, 'First');
    expect(
      entry('w1').evidence.any((e) => e.text.contains('First draft')),
      isTrue,
    );
    final reading = entry('reading');
    expect(
      reading.assessments
          .where((a) => a.source == 'answerKey')
          .map((a) => a.value)
          .toSet(),
      {'correct', 'incorrect', 'unanswered'},
    );
    expect(
      reading.assessments.firstWhere((a) => a.source == 'self').evidence,
      'A revised answer after explanations.',
    );
    expect(
      reading.evidence.any((e) => e.text == 'My first inference and summary.'),
      isTrue,
    );
    expect(
      entry('memory').assessments.map((a) => a.display),
      contains('Not assessed'),
    );
    expect(entry('memory').evidence.last.text, contains('cue: keywords'));
    expect(entry('impromptu').impromptu!.confidence, 5);
    expect(entry('impromptu').assessments.every((a) => !a.assessed), isTrue);
    expect(assessorLabel('humanAssessor'), 'Human assessor');
    expect(
      assessorLabel('future-observer'),
      'Other assessor (future-observer)',
    );
    expect(const HistoryAssessment('Open', 'self', null, '').value, isNull);
  });
  test('comparison allows suitable revisions and retries and refuses other language, rubric, task and incomplete work', () async {
    final entries = await repo.load();
    HistoryEntry e(String name) =>
        entries.singleWhere((e) => e.id == ids[name]);
    expect(e('w1').incompatibility(e('w2')), isNull);
    expect(e('w2').incompatibility(e('w3')), isNull);
    expect(e('impromptu').incompatibility(e('retry')), isNull);
    expect(e('w1').incompatibility(e('rubric')), contains('rubric'));
    expect(e('w1').incompatibility(e('language')), contains('language'));
    expect(e('w1').incompatibility(e('different')), isNotNull);
    expect(e('w1').incompatibility(e('interrupted')), contains('Complete'));
    final rubric = historyObject(e('w2').writing!.reviewRubric);
    rubric['criteria'][0]['description'] =
        'Changed anchors without a version bump';
    await (db.update(
      db.writingWorkspaces,
    )..where((w) => w.sessionId.equals(ids['w2']!))).write(
      WritingWorkspacesCompanion(reviewRubric: Value(jsonEncode(rubric))),
    );
    final changed = await repo.load();
    expect(
      changed
          .singleWhere((e) => e.id == ids['w1'])
          .incompatibility(changed.singleWhere((e) => e.id == ids['w2'])),
      contains('rubric'),
    );
  });
  test('unmeasured time is null while measured zero and finalized interrupted credit remain honest', () async {
    final before = await repo.load(),
        speech = before.singleWhere((e) => e.id == ids['speech']);
    expect(HistorySummary([speech]).stageMs('respond'), isNull);
    await db
        .into(db.timingSegments)
        .insert(
          TimingSegmentsCompanion.insert(
            id: 'zero',
            sessionId: speech.id,
            stage: 'respond',
            startedUtcMs: 0,
            checkpointUtcMs: 0,
            endedUtcMs: const Value(0),
            elapsedMs: 0,
          ),
        );
    final after = await repo.load();
    expect(
      HistorySummary([after.singleWhere((e) => e.id == speech.id)])
          .stageMs('respond'),
      0,
    );
    expect(after.singleWhere((e) => e.id == ids['interrupted']).timerMs, 1000);
    expect(after.singleWhere((e) => e.id == ids['running']).timerMs, 200);
  });
  test('provider observes workspace-only ratings, review-only edits, new audio observations and finalized timing', () async {
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(p)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(historyProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(historyProvider.future);
    Future<List<HistoryEntry>> waitFor(
      bool Function(List<HistoryEntry>) match,
    ) async {
      for (var i = 0; i < 200; i++) {
        final value = container.read(historyProvider).value;
        if (value != null && match(value)) {
          return value;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('Provider did not publish committed history updates');
    }

    await db.transaction(() async {
      await (db.update(
        db.writingWorkspaces,
      )..where((w) => w.sessionId.equals(ids['w2']!))).write(
        const WritingWorkspacesCompanion(
          assessments: Value(
            '{"clarity":{"rating":"developing","evidence":"Second"}}',
          ),
        ),
      );
      await p.saveReview(
        ids['w2']!,
        'Reviewed after editing.',
        ReviewStatus.reviewed,
        DateTime.utc(2026, 10, 28),
      );
    });
    await waitFor(
      (v) => v.any(
        (e) =>
            e.id == ids['w2'] &&
            e.assessments.any((a) => a.value == 'developing') &&
            e.detail.reviewStatus == ReviewStatus.reviewed,
      ),
    );
    final recording = (await db.select(db.audioRecordings).get()).first;
    await db
        .into(db.audioObservations)
        .insert(
          AudioObservationsCompanion.insert(
            id: stableId(),
            recordingId: recording.id,
            positionMs: 0,
            note: 'New observation',
            createdUtcMs: 0,
          ),
        );
    await waitFor(
      (v) =>
          v.any((e) => e.observations.any((o) => o.note == 'New observation')),
    );
    await (db.update(
      db.timingSegments,
    )..where((s) => s.endedUtcMs.isNull())).write(
      const TimingSegmentsCompanion(
        endedUtcMs: Value(123),
        endReason: Value('paused'),
      ),
    );
    final finalized = await waitFor((v) => HistorySummary(v).openSegments == 0);
    expect(HistorySummary(finalized).finalizedMs, 21700);
  });
  test('dashboard next action follows actual recoverable, marked, unreviewed and empty work', () async {
    final all = await repo.load();
    expect(isTerminal(historyNextAction(all)!.entry.session.status), isFalse);
    final completed = all
        .where((e) => e.session.status == 'completed')
        .toList();
    expect(historyNextAction(completed)!.label, 'Revisit marked recall');
    final unmarked = completed.where((e) => e.memory == null).toList();
    expect(historyNextAction(unmarked)!.label, 'Review saved work');
    expect(historyNextAction([]), isNull);
  });
}
