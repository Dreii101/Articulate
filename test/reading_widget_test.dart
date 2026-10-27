import 'package:articulate/providers.dart';
import 'package:articulate/reading/reading_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reading_flow.dart';
import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Manrope', 'Lora']) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$family.ttf'))).load();
    }
  });
  testWidgets(
    'phone reading flow preserves first answers through autosave, navigation, explanations, revisions and restart',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(testApplication());
      await tester.pumpAndSettle();
      final repo = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      ).read(repositoryProvider);
      final id = await readingFlow(tester, repo);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(testApplication(repository: repo));
      await tester.pumpAndSettle();
      await reopenReading(tester, id);
      expect(tester.takeException(), isNull);
    },
  );

  for (final layout in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets(
      'passage questions and review fit ${layout.$1} at ${layout.$2} scale',
      (tester) async {
        tester.view.physicalSize = layout.$1;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = layout.$2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(testApplication());
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final repo = container.read(repositoryProvider);
        await repo.saveSetting('theme', 'dark');
        await repo.saveSetting('reduceMotion', 'true');
        final id = await repo.createDraft(
          container
              .read(exercisesProvider)
              .firstWhere((e) => e.id == 'reading-water-dashboard'),
          DateTime.now(),
        );
        await tester.pumpAndSettle();
        await readingTap(tester, find.byKey(ValueKey('resume-$id')));
        expect(tester.takeException(), isNull);
        await readingTap(
          tester,
          find.byKey(const ValueKey('reading-view-questions')),
        );
        expect(tester.takeException(), isNull);
        await readingTap(tester, find.byKey(const ValueKey('check-reading')));
        expect(
          find.text('First attempt · 0/3 keyed answers correct · 3 unanswered'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await readingTap(
          tester,
          find.byKey(const ValueKey('save-reading-review')),
        );
        expect(tester.takeException(), isNull);
        // Reflow the live editor without replacing the route or losing its first results.
        tester.view.physicalSize = const Size(600, 800);
        await tester.pumpAndSettle();
        expect(
          find.text('First attempt · 0/3 keyed answers correct · 3 unanswered'),
          findsOneWidget,
        );
        expect((await ReadingRepository(repo).open(id)).keyResults, isNotNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'phone question controls have accessible labels and editing stays visible above the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(testApplication());
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final repo = container.read(repositoryProvider);
      final id = await repo.createDraft(
        container
            .read(exercisesProvider)
            .firstWhere((e) => e.id == 'reading-seed-shelf'),
        DateTime.now(),
      );
      await tester.pumpAndSettle();
      await readingTap(tester, find.byKey(ValueKey('resume-$id')));
      await readingTap(
        tester,
        find.byKey(const ValueKey('reading-view-questions')),
      );
      final semantics = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      semantics.dispose();
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await readingEnter(
        tester,
        'reading-answer-summary',
        'A keyboard-safe summary.',
      );
      final field = find.byKey(const ValueKey('reading-answer-summary'));
      expect(tester.getRect(field).top, greaterThanOrEqualTo(0));
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.hasPrimaryFocus, isTrue);
      await readingTap(tester, find.byType(BackButton).first);
      expect(
        readingAnswers((await repo.load(id)).response.body)['summary'],
        'A keyboard-safe summary.',
      );
    },
  );
}
