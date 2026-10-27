import 'dart:convert';
import 'dart:io';

import 'package:articulate/advanced/advanced_repository.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/history/history_repository.dart';
import 'package:articulate/memory/memory_document.dart';
import 'package:articulate/memory/memory_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Exercise customTemplate() => validateExercisePack(
  File('assets/exercises/writing-v1.json').readAsStringSync(),
).first;
Future<(MemoryVersion, String)> completedRecall(
  PracticeRepository p, {
  MemoryVersion? version,
  DateTime? at,
}) async {
  final memory = MemoryRepository(p);
  final doc = validateMemoryPack(
    File('assets/exercises/memory-v1.json').readAsStringSync(),
  ).first;
  final v =
      version ?? await memory.publish(await memory.saveDraft(null, doc.data));
  final section =
      (jsonDecode(v.content)['sections'] as List).first['id'] as String;
  final now = at ?? DateTime(2026, 10, 27, 23, 50);
  final id = await memory.createAttempt(
    v.id,
    section,
    'meaning',
    'typed',
    'hidden',
    now: now,
  );
  await p.saveResponse(id, 'My recalled ideas.', now);
  await p.transition(id, PracticeStatus.completed, now);
  return (v, id);
}

void main() {
  late AppDatabase db;
  late PracticeRepository p;
  late AdvancedRepository advanced;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    advanced = AdvancedRepository(p);
  });
  tearDown(() => db.close());

  test('local calendar days cross leap days and daylight-saving dates without 24-hour assumptions', () {
    expect(plusDays('2028-02-28', 1), '2028-02-29');
    expect(plusDays('2026-03-08', 1), '2026-03-09');
    expect(plusDays('2026-12-31', 1), '2027-01-01');
    expect(() => parseCalendarDate('2026-02-30'), throwsFormatException);
    expect(() => validateIntervals([1, 1, 7]), throwsFormatException);
    expect(() => validateIntervals([0, 3]), throwsFormatException);
    expect(() => validateIntervals([1, 366]), throwsFormatException);
  });
  test('explicit observations are idempotent, missed days stay due and dates are overridable', () async {
    final (v, id) = await completedRecall(p);
    final now = DateTime(2026, 10, 27, 23, 59);
    final first = await advanced.observe(id, 'independent', now);
    expect(first.recommendedDate, '2026-10-28');
    expect(first.originalOffsetMinutes, now.timeZoneOffset.inMinutes);
    expect(
      (await advanced.observe(
        id,
        'needsWork',
        DateTime(2026, 11, 10),
      )).observation,
      'independent',
    );
    expect((await advanced.queue()).single.due('2026-11-15'), isTrue);
    expect((await advanced.queue()).single.schedule.intervalDays, 1);
    await advanced.override(id, date: '2026-12-01', paused: true);
    expect((await advanced.queue()).single.due('2027-01-01'), isFalse);
    await advanced.override(id, date: '2026-12-01', paused: false);
    expect((await advanced.queue()).single.due('2026-11-15'), isFalse);
    await advanced.saveIntervals([2, 5, 10]);
    expect(
      (await advanced.queue()).single.schedule.recommendedDate,
      '2026-10-28',
    );
    final (_, second) = await completedRecall(
      p,
      version: v,
      at: DateTime(2026, 11, 15),
    );
    final next = await advanced.observe(
      second,
      'independent',
      DateTime(2026, 11, 15),
    );
    expect(next.intervalDays, 5);
    expect(next.recommendedDate, '2026-11-20');
    final (_, third) = await completedRecall(
      p,
      version: v,
      at: DateTime(2026, 11, 16),
    );
    // Wall clock moves backwards; committed observation order still defines the queue.
    final reset = await advanced.observe(
      third,
      'withHelp',
      DateTime(2026, 11, 14),
    );
    expect(reset.intervalDays, 2);
    expect((await advanced.queue()).single.schedule.sessionId, third);
    await validateAdvancedLibrary(db);
  });
  test(
    'speech edits do not move a historical queue or retry onto the new version',
    () async {
      final (v, id) = await completedRecall(p);
      await advanced.observe(id, 'needsWork', DateTime(2026, 10, 27));
      final memory = MemoryRepository(p),
          doc = jsonDecode(v.content) as Map<String, dynamic>;
      (doc['sections'] as List).first['text'] =
          'Changed message, preserved separately.';
      await memory.saveDraft(v.speechId, doc);
      final v2 = await memory.publish(v.speechId);
      expect(v2.versionNumber, 2);
      expect((await advanced.queue()).single.newerVersion, isTrue);
      final retry = await advanced.start(
        (await p.load(id)).exercise,
        'memory-retry',
        DateTime(2026, 10, 28),
        parent: id,
        target: 'Missed transitions',
      );
      expect((await memory.workspace(retry)).versionId, v.id);
      expect(
        (await p.load(retry)).session.snapshot,
        (await p.load(id)).session.snapshot,
      );
      expect(
        await advanced.start(
          (await p.load(id)).exercise,
          'repeat-click',
          DateTime(2026, 10, 28),
          parent: id,
          target: 'Missed transitions',
        ),
        retry,
      );
      await validateAdvancedLibrary(db);
    },
  );
  test('custom versions preserve snapshots, validate module metadata and reject broken content', () async {
    final first = await advanced.saveCustom(
      customTemplate().snapshot,
      DateTime(2026, 10, 27),
    );
    final old = Exercise.fromSnapshot(first.snapshot);
    final attempt = await advanced.start(
      old,
      'custom-start',
      DateTime(2026, 10, 27),
      label: 'benchmark',
      conditions: 'Untimed, same audience',
    );
    expect(
      await advanced.start(old, 'custom-start', DateTime(2026, 10, 27)),
      attempt,
    );
    final changed = old.document;
    changed['exercises'][0]['prompt'] = 'Write a different explanation.';
    changed['exercises'][0]['rubric']['criteria'][0]['description'] =
        'Revised guidance.';
    final second = await advanced.saveCustom(
      jsonEncode(changed),
      DateTime(2026, 10, 28),
      id: first.id,
    );
    expect(second.version, 2);
    expect(
      Exercise.fromSnapshot(second.snapshot).content['rubric']['version'],
      2,
    );
    expect((await p.load(attempt)).session.snapshot, first.snapshot);
    expect(await advanced.customVersions(), hasLength(2));
    changed['exercises'][0]['language'] = 'bad language';
    await expectLater(
      advanced.saveCustom(jsonEncode(changed), DateTime.now(), id: first.id),
      throwsFormatException,
    );
    expect(await advanced.customVersions(), hasLength(2));
    await expectLater(
      advanced.start(old, 'false-novelty', DateTime.now(), label: 'unfamiliar'),
      throwsFormatException,
    );
    await validateAdvancedLibrary(db);
  });
  test('labels and related comparisons preserve missing assessments and expose condition differences', () async {
    final e = customTemplate(), now = DateTime(2026, 10, 27);
    final a = await advanced.start(
      e,
      'a',
      now,
      label: 'benchmark',
      conditions: 'quiet, untimed',
    );
    final b = await advanced.start(
      e,
      'b',
      now,
      label: 'benchmark',
      conditions: 'quiet, untimed',
    );
    final c = await advanced.start(e, 'c', now, label: 'practice');
    for (final id in [a, b, c]) {
      await p.transition(id, PracticeStatus.completed, now);
    }
    final entries = await HistoryRepository(p).load();
    HistoryEntry entry(String id) => entries.singleWhere((e) => e.id == id);
    expect(entry(a).incompatibility(entry(b)), isNull);
    expect(entry(a).incompatibility(entry(c)), contains('declared'));
    expect(entry(a).relatedEvidence(entry(c)), isTrue);
    expect(entry(a).assessments.every((a) => !a.assessed), isTrue);
    expect(
      entry(a).evidence.any((e) => e.text.contains('quiet, untimed')),
      isTrue,
    );
    await expectLater(
      advanced.start(e, 'seen', now, label: 'unfamiliar'),
      throwsFormatException,
    );
  });
  test(
    'v8 migration preserves old rows and adds only empty advanced tables',
    () async {
      final legacy = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute(File('test/fixtures/schema_v8.sql').readAsStringSync());
            raw.execute("INSERT INTO app_settings VALUES ('theme','dark')");
          },
        ),
      );
      try {
        expect(
          (await legacy.select(legacy.appSettings).get()).single.value,
          'dark',
        );
        expect(await legacy.select(legacy.customExercises).get(), isEmpty);
        expect(await legacy.select(legacy.practiceContexts).get(), isEmpty);
        expect(await legacy.select(legacy.recallSchedules).get(), isEmpty);
        expect(
          (await legacy.customSelect('PRAGMA user_version').getSingle())
              .data
              .values
              .single,
          9,
        );
        expect(
          await legacy.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await legacy.close();
      }
    },
  );
}
