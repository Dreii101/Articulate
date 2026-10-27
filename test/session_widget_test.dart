import 'package:articulate/practice_page.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  testWidgets('draft autosaves, reopens from dashboard, and completes once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(testApplication());
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(MaterialApp));
    final repository = ProviderScope.containerOf(context)
        .read(repositoryProvider);
    final exercises = ProviderScope.containerOf(context)
        .read(exercisesProvider);
    final id = await repository.createDraft(
      exercises.firstWhere((e) => e.module == 'reading'),
      DateTime.now(),
    );
    await tester.pumpAndSettle();
    final resume = find.byKey(ValueKey('resume-$id'));
    await tester.ensureVisible(resume);
    await tester.tap(resume);
    await tester.pumpAndSettle();
    expect(find.byType(PracticePage), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('response')));
    await tester.enterText(
      find.byKey(const ValueKey('response')),
      'My restart-safe response',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(
      (await repository.load(id)).response.body,
      'My restart-safe response',
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(PracticePage), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(testApplication(repository: repository));
    await tester.pumpAndSettle();
    await tester.ensureVisible(resume);
    await tester.tap(resume);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('response')))
          .controller!
          .text,
      'My restart-safe response',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('complete')));
    await tester.tap(find.byKey(const ValueKey('complete')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('complete')), findsNothing);
    expect((await repository.load(id)).session.status, 'completed');
    expect(
      (await repository.db.select(repository.db.practiceSessions).get()),
      hasLength(1),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('review-notes')));
    await tester.enterText(
      find.byKey(const ValueKey('review-notes')),
      'One improvement to make next time',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect((await repository.load(id)).reviewStatus, ReviewStatus.inProgress);
    // Dispose the page explicitly so the real periodic checkpoint timer is cancelled.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  for (final size in [const Size(375, 812), const Size(844, 390)]) {
    testWidgets('saved workspace fits $size at 2x text with reduced motion', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(testApplication());
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final repository = container.read(repositoryProvider);
      await repository.saveSetting('reduceMotion', 'true');
      await repository.saveSetting('theme', 'dark');
      final id = await repository.createDraft(
        container
            .read(exercisesProvider)
            .firstWhere((e) => e.module == 'reading'),
        DateTime.now(),
      );
      await tester.pumpAndSettle();
      final resume = find.byKey(ValueKey('resume-$id'));
      await tester.ensureVisible(resume);
      await tester.tap(resume);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('response')));
      expect(tester.takeException(), isNull);
      expect(
        MediaQuery.disableAnimationsOf(
          tester.element(find.byType(PracticePage)),
        ),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
