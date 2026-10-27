import 'dart:convert';

import 'package:drift/drift.dart';

import '../exercises.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';

List<Map<String, dynamic>> readingQuestions(Exercise exercise) =>
    (exercise.content['reading']['questions'] as List)
        .cast<Map<String, dynamic>>();
bool isOpenQuestion(Map<String, dynamic> question) =>
    question['kind'] == 'summary' || question['kind'] == 'critical';
const readingRatings = ['emerging', 'developing', 'effective'];

Map<String, dynamic> readingAnswers(String body) => body.isEmpty
    ? <String, dynamic>{}
    : jsonDecode(body) as Map<String, dynamic>;

class ReadingRepository {
  ReadingRepository(this.practice);
  final PracticeRepository practice;
  AppDatabase get db => practice.db;

  Future<ReadingWorkspace> open(String id) => db.transaction(() async {
    final d = await practice.load(id);
    if (d.exercise.module != 'reading' ||
        !d.exercise.content.containsKey('reading')) {
      throw ArgumentError(
        'This is a saved preview, not a Reading Lab attempt.',
      );
    }
    final existing = await (db.select(
      db.readingWorkspaces,
    )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
    if (existing != null) return existing;
    validateAnswers(d.exercise, readingAnswers(d.response.body));
    await db
        .into(db.readingWorkspaces)
        .insert(
          ReadingWorkspacesCompanion.insert(
            sessionId: id,
            updatedUtcMs: d.session.updatedUtcMs,
          ),
        );
    return (db.select(
      db.readingWorkspaces,
    )..where((w) => w.sessionId.equals(id))).getSingle();
  });

  static void validateAnswers(Exercise exercise, Map<String, dynamic> answers) {
    final questions = {
      for (final q in readingQuestions(exercise)) q['id'] as String: q,
    };
    if (jsonEncode(answers).length > PracticeRepository.maxResponseLength) {
      throw ArgumentError('Answers too long');
    }
    for (final entry in answers.entries) {
      final q = questions[entry.key];
      if (q == null ||
          entry.value is! String ||
          (entry.value as String).length > 16000) {
        throw ArgumentError('Invalid answer');
      }
      if (!isOpenQuestion(q) &&
          entry.value != '' &&
          !(q['options'] as List).any((o) => o['id'] == entry.value)) {
        throw ArgumentError('Unknown option');
      }
    }
  }

  static Map<String, dynamic> keyedResults(
    Exercise exercise,
    Map<String, dynamic> answers,
  ) {
    validateAnswers(exercise, answers);
    return {
      for (final q in readingQuestions(
        exercise,
      ).where((q) => !isOpenQuestion(q)))
        q['id'] as String: {
          'selected': answers[q['id']] ?? '',
          'key': q['answerKey'],
          'status': (answers[q['id']] ?? '') == ''
              ? 'unanswered'
              : answers[q['id']] == q['answerKey']
              ? 'correct'
              : 'incorrect',
          'rationale': q['rationale'],
        },
    };
  }

  Future<void> save(
    String id, {
    required Map<String, dynamic> answers,
    required Map<String, dynamic> revisions,
    required Map<String, dynamic> ratings,
    required String step,
    required bool hidePassage,
    required DateTime now,
    bool reviewed = false,
  }) => db.transaction(() async {
    final d = await practice.load(id);
    final w = await open(id);
    validateAnswers(d.exercise, answers);
    validateAnswers(d.exercise, revisions);
    final openIds = readingQuestions(d.exercise)
        .where(isOpenQuestion)
        .map((q) => q['id'])
        .toSet();
    if (!{'passage', 'questions', 'review'}.contains(step) ||
        ratings.entries.any(
          (e) =>
              !openIds.contains(e.key) ||
              (e.value != null && !readingRatings.contains(e.value)),
        )) {
      throw ArgumentError('Invalid reading review');
    }
    if (d.session.status == 'abandoned') {
      throw StateError('This attempt is closed.');
    }
    if (w.keyResults == null) {
      if (isTerminal(d.session.status) ||
          revisions.isNotEmpty ||
          ratings.isNotEmpty ||
          reviewed ||
          step == 'review') {
        throw StateError('Check first answers before reviewing.');
      }
      await practice.saveResponse(id, jsonEncode(answers), now);
    } else if (answers.length != readingAnswers(d.response.body).length ||
        answers.entries.any(
          (e) => readingAnswers(d.response.body)[e.key] != e.value,
        )) {
      throw StateError(
        'First answers are preserved. Edit the separate revision.',
      );
    }
    await (db.update(
      db.readingWorkspaces,
    )..where((w) => w.sessionId.equals(id))).write(
      ReadingWorkspacesCompanion(
        revisionAnswers: Value(jsonEncode(revisions)),
        ratings: Value(jsonEncode(ratings)),
        viewStep: Value(step),
        hidePassage: Value(hidePassage),
        updatedUtcMs: Value(now.toUtc().millisecondsSinceEpoch),
      ),
    );
    if (w.keyResults != null &&
        (reviewed ||
            w.revisionAnswers != jsonEncode(revisions) ||
            w.ratings != jsonEncode(ratings))) {
      await practice.saveReview(
        id,
        jsonEncode({
          'rubric': d.exercise.content['rubric'],
          'firstAttemptKeyedResults': jsonDecode(w.keyResults!),
          'revisionAnswers': revisions,
          'revisionKeyedResults': keyedResults(d.exercise, revisions),
          'humanRatings': ratings,
          'ratingSource':
              'Self-review of revised open answers; not an automatic grade',
        }),
        reviewed ? ReviewStatus.reviewed : ReviewStatus.inProgress,
        now,
      );
    }
  });

  // One transaction freezes answers, keys and completion; retries never rescore revisions.
  Future<ReadingWorkspace> check(String id, DateTime now) =>
      db.transaction(() async {
        final w = await open(id);
        if (w.keyResults != null) return w;
        final d = await practice.load(id);
        final answers = readingAnswers(d.response.body);
        final results = keyedResults(d.exercise, answers);
        await practice.transition(id, PracticeStatus.completed, now);
        await (db.update(
          db.readingWorkspaces,
        )..where((w) => w.sessionId.equals(id))).write(
          ReadingWorkspacesCompanion(
            keyResults: Value(jsonEncode(results)),
            revisionAnswers: Value(jsonEncode(answers)),
            viewStep: const Value('review'),
            updatedUtcMs: Value(now.toUtc().millisecondsSinceEpoch),
          ),
        );
        await practice.saveReview(
          id,
          jsonEncode({
            'rubric': d.exercise.content['rubric'],
            'firstAttemptKeyedResults': results,
            'humanRatings': <String, dynamic>{},
          }),
          ReviewStatus.inProgress,
          now,
        );
        return open(id);
      });
}
