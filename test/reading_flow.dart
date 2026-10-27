import 'dart:convert';

import 'package:articulate/reading/reading_repository.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> readingTap(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pumpAndSettle();
}

Future<void> readingEnter(WidgetTester tester, String key, String text) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
}

Future<String> readingFlow(WidgetTester tester, PracticeRepository repo) async {
  await readingTap(tester, find.byKey(const ValueKey('nav-1')));
  await readingTap(tester, find.byKey(const ValueKey('module-reading')));
  await readingTap(
    tester,
    find.byKey(const ValueKey('choose-reading-seed-shelf')),
  );
  expect(find.text('The seed shelf'), findsOneWidget);
  await readingTap(
    tester,
    find.byKey(const ValueKey('reading-view-questions')),
  );
  await readingTap(
    tester,
    find.byKey(const ValueKey('reading-option-literal-c')),
  );
  await readingTap(
    tester,
    find.byKey(const ValueKey('reading-option-evidence-c')),
  );
  await readingEnter(
    tester,
    'reading-answer-summary',
    'The library shared seeds; plant survival was unknown.',
  );
  await tester.sendKeyEvent(LogicalKeyboardKey.end);
  await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
  final id = (await repo.db.select(repo.db.practiceSessions).get()).single.id;
  expect(
    readingAnswers((await repo.load(id)).response.body)['summary'],
    'The library shared seeds; plant survival was unknown',
  );
  await readingTap(tester, find.byKey(const ValueKey('hide-reading-passage')));
  expect(find.text('Passage hidden for summary practice'), findsOneWidget);
  await readingTap(tester, find.byType(BackButton).first);
  await readingTap(tester, find.byType(BackButton).first);
  await readingTap(tester, find.byKey(const ValueKey('nav-0')));
  await readingTap(tester, find.byKey(ValueKey('resume-$id')));
  expect(find.text('Passage hidden for summary practice'), findsOneWidget);
  expect(
    tester
        .widget<TextField>(find.byKey(const ValueKey('reading-answer-summary')))
        .controller!
        .text,
    'The library shared seeds; plant survival was unknown',
  );
  await readingTap(tester, find.byKey(const ValueKey('check-reading')));
  expect(
    find.text('First attempt · 1/3 keyed answers correct · 1 unanswered'),
    findsOneWidget,
  );
  expect(find.text('Not assessed'), findsNWidgets(2));
  expect(
    find.textContaining('Sample reasoning · one possible answer'),
    findsNWidgets(2),
  );
  await readingTap(
    tester,
    find.byKey(const ValueKey('reading-option-literal-a')),
  );
  await readingEnter(
    tester,
    'reading-answer-summary',
    'Mara tested a seed shelf, adapted guidance and storage, and still lacked plant-survival evidence.',
  );
  await readingTap(tester, find.byKey(const ValueKey('save-reading-review')));
  final w = await ReadingRepository(repo).open(id);
  expect(jsonDecode(w.keyResults!)['literal']['status'], 'incorrect');
  expect(jsonDecode(w.revisionAnswers)['literal'], 'a');
  expect((await repo.load(id)).reviewStatus, ReviewStatus.reviewed);
  expect((await repo.load(id)).session.exerciseVersion, 1);
  expect((await repo.load(id)).elapsedMs, 0);
  return id;
}

Future<void> reopenReading(WidgetTester tester, String id) async {
  await readingTap(tester, find.byKey(const ValueKey('nav-2')));
  await readingTap(tester, find.byKey(ValueKey('resume-$id')));
  expect(
    find.text('The library shared seeds; plant survival was unknown'),
    findsOneWidget,
  );
  expect(
    tester
        .widget<TextField>(find.byKey(const ValueKey('reading-answer-summary')))
        .controller!
        .text,
    startsWith('Mara tested a seed shelf'),
  );
  expect(
    find.text('First attempt · 1/3 keyed answers correct · 1 unanswered'),
    findsOneWidget,
  );
  await readingTap(tester, find.byKey(const ValueKey('reading-view-passage')));
  expect(find.text('The seed shelf'), findsOneWidget);
  await readingTap(tester, find.byKey(const ValueKey('reading-view-review')));
  expect(find.text('Human self-review · reviewed'), findsOneWidget);
}
