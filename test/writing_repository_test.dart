import 'dart:convert';
import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/writing/writing_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File('assets/exercises/writing-v1.json').readAsStringSync();
  final exercises = validateExercisePack(source);
  late AppDatabase db;
  late PracticeRepository practice;
  late WritingRepository writing;
  late String id;
  final now = DateTime(2026, 10, 25, 15);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    practice = PracticeRepository(db);
    writing = WritingRepository(practice);
    id = await practice.createDraft(exercises.first, now);
    await writing.open(id);
  });
  tearDown(() => db.close());

  Future<void> save(
    String id, {
    Map<String, dynamic> assessments = const {},
    String? outline,
    String step = 'review',
    String note = '',
  }) async {
    final w = await writing.open(id);
    await writing.save(
      id,
      outline: outline ?? w.outline,
      audience: w.audience,
      purpose: w.purpose,
      step: step,
      assessments: assessments,
      nextAction: note,
      now: now,
    );
  }

  test(
    'twelve original exercises cover all levels, kinds and anchored criteria',
    () {
      expect(exercises, hasLength(12));
      for (final level in exerciseLevels) {
        expect(exercises.where((e) => e.level == level), hasLength(4));
      }
      expect(
        exercises.map((e) => e.content['writing']['kind']).toSet(),
        containsAll({
          'paragraph',
          'explanation',
          'essay',
          'argument',
          'revision',
        }),
      );
      for (final e in exercises) {
        expect(e.criteria.map((c) => c['id']).toList(), writingCriteria);
        for (final c in e.criteria) {
          expect((c['anchors'] as Map).keys, containsAll(writingRatings));
        }
        expect(e.content['authorship']['kind'], 'original');
      }
    },
  );
  test('invalid writing metadata and incomplete anchors reject the pack', () {
    final root = jsonDecode(source);
    root['exercises'][0]['writing']['kind'] = 'novel';
    expect(() => validateExercisePack(jsonEncode(root)), throwsFormatException);
    root['exercises'][0]['writing']['kind'] = 'paragraph';
    root['exercises'][0]['rubric']['criteria'][0]['anchors'].remove(
      'effective',
    );
    expect(() => validateExercisePack(jsonEncode(root)), throwsFormatException);
  });
  test(
    'review allows all missing ratings and an empty next action without scores',
    () async {
      await practice.saveResponse(id, 'A plain original.', now);
      await practice.transition(id, PracticeStatus.completed, now);
      await save(id);
      await writing.finishReview(id, now);
      final d = await practice.load(id);
      expect(d.reviewStatus, ReviewStatus.reviewed);
      expect(jsonDecode(d.review!.notes)['assessments'], isEmpty);
      expect(jsonDecode(d.review!.notes)['nextAction'], '');
      expect(jsonDecode(d.review!.notes)['rubric']['version'], 1);
    },
  );
  test('anchored evidence matches frozen text and invalid ranges cannot overwrite it', () async {
    await practice.saveResponse(id, 'Specific details help readers.', now);
    await practice.transition(id, PracticeStatus.completed, now);
    final values = {
      'clarity': {
        'rating': 'effective',
        'evidence': 'Specific details',
        'start': 0,
        'end': 16,
      },
    };
    await save(id, assessments: values);
    await writing.finishReview(id, now);
    await expectLater(
      save(
        id,
        assessments: {
          'clarity': {
            'rating': 'effective',
            'evidence': 'Wrong quote',
            'start': 0,
            'end': 16,
          },
        },
      ),
      throwsArgumentError,
    );
    expect(jsonDecode((await writing.open(id)).assessments), values);
    await expectLater(
      save(
        id,
        assessments: {
          'clarity': {'rating': 'perfect', 'evidence': ''},
        },
      ),
      throwsArgumentError,
    );
    await expectLater(
      practice.saveResponse(id, 'Overwrite original', now),
      throwsStateError,
    );
    await expectLater(
      save(id, outline: 'Overwrite preserved plan'),
      throwsStateError,
    );
  });
  test(
    'revision links and snapshots are stable; originals stay unchanged',
    () async {
      await practice.saveResponse(id, 'Original body', now);
      await save(id, outline: 'A saved plan', step: 'write');
      await practice.transition(id, PracticeStatus.completed, now);
      final children = await Future.wait([
        writing.createRevision(id, now),
        writing.createRevision(id, now),
      ]);
      expect(children.toSet(), hasLength(1));
      final child = children.first;
      expect(child, isNot(id));
      final w = await writing.open(child);
      expect(w.parentSessionId, id);
      expect(w.rootSessionId, id);
      expect(w.versionNumber, 2);
      expect(w.outline, 'A saved plan');
      expect(w.assessments, '{}');
      expect(w.nextAction, '');
      expect(
        (await practice.load(child)).session.snapshot,
        (await practice.load(id)).session.snapshot,
      );
      expect(w.reviewRubric, (await writing.open(id)).reviewRubric);
      await practice.saveResponse(child, 'Revised body', now);
      await practice.transition(child, PracticeStatus.completed, now);
      final third = await writing.createRevision(child, now);
      expect((await writing.open(third)).versionNumber, 3);
      expect((await practice.load(id)).response.body, 'Original body');
      expect((await practice.load(child)).response.body, 'Revised body');
      expect((await writing.versions(id)).map((w) => w.versionNumber), [
        1,
        2,
        3,
      ]);
    },
  );
  test(
    'legacy writing drafts open without changing their original snapshots',
    () async {
      final legacy = validateExercisePack(
        File('assets/exercises/core-v1.json').readAsStringSync(),
      ).first;
      final legacyId = await practice.createDraft(legacy, now);
      await practice.saveResponse(legacyId, 'Earlier draft', now);
      final w = await writing.open(legacyId);
      expect(jsonDecode(w.reviewRubric)['criteria'], hasLength(4));
      expect((await practice.load(legacyId)).session.snapshot, legacy.snapshot);
      expect((await practice.load(legacyId)).response.body, 'Earlier draft');
    },
  );
  test(
    'original and revision reopen after native file close/restart',
    () async {
      await db.close();
      final dir = await Directory.systemTemp.createTemp('writing-restart-');
      final file = File('${dir.path}/writing.sqlite');
      db = AppDatabase(NativeDatabase(file));
      practice = PracticeRepository(db);
      writing = WritingRepository(practice);
      final root = await practice.createDraft(exercises.first, now);
      await writing.open(root);
      await practice.saveResponse(root, 'Original survives', now);
      await practice.transition(root, PracticeStatus.completed, now);
      await save(root, note: 'Add one example');
      final child = await writing.createRevision(root, now);
      await practice.saveResponse(child, 'Revision survives', now);
      await save(child, step: 'write');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      practice = PracticeRepository(db);
      writing = WritingRepository(practice);
      await practice.recoverInterrupted();
      expect((await practice.load(root)).response.body, 'Original survives');
      expect((await practice.load(child)).response.body, 'Revision survives');
      expect((await writing.open(root)).nextAction, 'Add one example');
      expect((await writing.open(child)).parentSessionId, root);
      await db.close();
      await dir.delete(recursive: true);
      db = AppDatabase(NativeDatabase.memory());
    },
  );
}
