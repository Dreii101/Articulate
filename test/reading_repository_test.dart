import 'dart:convert';
import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/reading/reading_repository.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // File-restart coverage uses independent executors alongside the memory fixture.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);
  final source = File('assets/exercises/reading-v1.json').readAsStringSync();
  final pack = validateExercisePack(source);
  final now = DateTime(2026, 10, 25, 15);
  late AppDatabase db;
  late PracticeRepository practice;
  late ReadingRepository reading;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    practice = PracticeRepository(db);
    reading = ReadingRepository(practice);
  });
  tearDown(() => db.close());
  Future<String> draft() => practice.createDraft(pack.first, now);
  Future<void> save(
    String id,
    Map<String, dynamic> answers, {
    Map<String, dynamic> revisions = const {},
    Map<String, dynamic> ratings = const {},
    String step = 'questions',
    bool reviewed = false,
  }) => reading.save(
    id,
    answers: answers,
    revisions: revisions,
    ratings: ratings,
    step: step,
    hidePassage: true,
    now: now,
    reviewed: reviewed,
  );

  test('six original passages cover levels and five question kinds with honest metadata', () {
    expect(pack.length, 6);
    for (final level in exerciseLevels) {
      expect(pack.where((e) => e.level == level).length, 2);
    }
    for (final e in pack) {
      expect(e.content['authorship']['kind'], 'original');
      expect(e.content['license']['notice'], isNotEmpty);
      expect(readingQuestions(e).map((q) => q['kind']).toSet(), {
        'literal',
        'inference',
        'evidence',
        'summary',
        'critical',
      });
    }
  });

  test(
    'every authored key matches its intended answer and includes a rationale',
    () {
      const keys = [
        ['a', 'b', 'c'],
        ['b', 'a', 'c'],
        ['b', 'a', 'c'],
        ['a', 'b', 'c'],
        ['b', 'b', 'b'],
        ['b', 'c', 'b'],
      ];
      for (var i = 0; i < pack.length; i++) {
        final questions = readingQuestions(pack[i])
            .where((q) => !isOpenQuestion(q))
            .toList();
        final answers = {
          for (var n = 0; n < 3; n++) questions[n]['id'] as String: keys[i][n],
        };
        final results = ReadingRepository.keyedResults(pack[i], answers);
        expect(results.values.every((v) => v['status'] == 'correct'), isTrue);
        expect(
          questions.every((q) => (q['rationale'] as String).length > 60),
          isTrue,
        );
      }
    },
  );

  test('invalid keys, rationale, evidence references, duplicate IDs and open-answer keys fail validation', () {
    for (var mutation = 0; mutation < 6; mutation++) {
      final root = jsonDecode(source) as Map<String, dynamic>;
      final qs = root['exercises'][0]['reading']['questions'] as List;
      switch (mutation) {
        case 0:
          qs[0]['answerKey'] = 'unknown';
        case 1:
          qs[0]['rationale'] = ' ';
        case 2:
          qs[2]['options'][0]['paragraphId'] = 'missing';
        case 3:
          qs[1]['id'] = qs[0]['id'];
        case 4:
          qs[3]['answerKey'] = 'the only permitted wording';
        case 5:
          qs[4]['sampleReasoning'] = '';
      }
      expect(
        () => validateExercisePack(jsonEncode(root)),
        throwsFormatException,
      );
    }
  });

  test(
    'unanswered is distinct from incorrect and open wording is never keyed',
    () {
      final results = ReadingRepository.keyedResults(pack.first, {
        'literal': 'c',
        'summary': 'An entirely different paraphrase.',
      });
      expect(results.length, 3);
      expect(results['literal']['status'], 'incorrect');
      expect(results['inference']['status'], 'unanswered');
      expect(results.containsKey('summary'), isFalse);
      expect(
        () =>
            ReadingRepository.keyedResults(pack.first, {'literal': 'made-up'}),
        throwsArgumentError,
      );
      expect(
        () => ReadingRepository.keyedResults(pack.first, {'unknown': 'a'}),
        throwsArgumentError,
      );
    },
  );

  test('check is idempotent; revisions and human ratings never change frozen first results', () async {
    final id = await draft();
    final first = {
      'literal': 'c',
      'summary': 'Seeds were shared, but survival was not counted.',
    };
    await save(id, first);
    final checks = await Future.wait([
      reading.check(id, now),
      reading.check(id, now),
    ]);
    expect(checks[0].keyResults, checks[1].keyResults);
    final snapshot = (await practice.load(id)).session.snapshot;
    await save(
      id,
      first,
      revisions: {
        'literal': 'a',
        'summary':
            'A library seed trial attracted use but did not measure survival.',
      },
      ratings: {'summary': 'effective'},
      step: 'review',
      reviewed: true,
    );
    expect((await reading.check(id, now)).keyResults, checks[0].keyResults);
    await save(
      id,
      {'summary': first['summary'], 'literal': first['literal']},
      revisions: {'literal': 'a'},
      ratings: {'summary': 'effective'},
      step: 'review',
      reviewed: true,
    );
    final d = await practice.load(id);
    expect(readingAnswers(d.response.body), first);
    expect(d.session.snapshot, snapshot);
    expect(d.reviewStatus, ReviewStatus.reviewed);
    final review = jsonDecode(d.review!.notes);
    expect(
      review['firstAttemptKeyedResults']['literal']['status'],
      'incorrect',
    );
    expect(review['revisionKeyedResults']['literal']['status'], 'correct');
    expect(review['humanRatings']['summary'], 'effective');
    expect((await db.select(db.practiceSessions).get()).length, 1);
    await expectLater(save(id, {'literal': 'a'}), throwsStateError);
    await expectLater(
      practice.saveResponse(id, 'overwrite', now),
      throwsStateError,
    );
  });

  test('all unanswered and Not assessed reviews are valid; editing marks review in progress', () async {
    final id = await draft();
    await save(id, {});
    await reading.check(id, now);
    await save(
      id,
      {},
      revisions: {},
      ratings: {'summary': null},
      step: 'review',
      reviewed: true,
    );
    final w = await reading.open(id);
    expect(
      (jsonDecode(w.keyResults!) as Map).values.every(
        (r) => r['status'] == 'unanswered',
      ),
      isTrue,
    );
    expect((await practice.load(id)).reviewStatus, ReviewStatus.reviewed);
    await save(
      id,
      {},
      revisions: {'summary': 'Now I can explain the main point.'},
      step: 'review',
    );
    expect((await practice.load(id)).reviewStatus, ReviewStatus.inProgress);
    await expectLater(
      save(id, {}, ratings: {'literal': 'effective'}, step: 'review'),
      throwsArgumentError,
    );
  });

  test('draft and checked revisions survive native SQLite file reopen without crediting offline time', () async {
    final dir = await Directory.systemTemp.createTemp('articulate-reading-');
    final file = File('${dir.path}/reading.sqlite');
    var disk = AppDatabase(NativeDatabase(file));
    var p = PracticeRepository(disk);
    var r = ReadingRepository(p);
    final id = await p.createDraft(pack.first, now);
    await r.save(
      id,
      answers: {'summary': 'My saved first words.'},
      revisions: {},
      ratings: {},
      step: 'questions',
      hidePassage: true,
      now: now,
    );
    await disk.close();
    disk = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(disk);
    r = ReadingRepository(p);
    await p.recoverInterrupted();
    expect(
      readingAnswers((await p.load(id)).response.body)['summary'],
      'My saved first words.',
    );
    expect((await r.open(id)).hidePassage, isTrue);
    await r.check(id, now);
    await r.save(
      id,
      answers: {'summary': 'My saved first words.'},
      revisions: {'summary': 'My saved revision.'},
      ratings: {},
      step: 'review',
      hidePassage: true,
      now: now,
      reviewed: true,
    );
    await disk.close();
    disk = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(disk);
    r = ReadingRepository(p);
    expect(
      jsonDecode((await r.open(id)).revisionAnswers)['summary'],
      'My saved revision.',
    );
    expect((await p.load(id)).elapsedMs, 0);
    expect((await p.load(id)).session.exerciseVersion, 1);
    await disk.close();
    await file.delete();
    await dir.delete();
  });
}
