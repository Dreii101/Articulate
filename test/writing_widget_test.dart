import 'package:articulate/providers.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/writing/writing_page.dart';
import 'package:articulate/writing/writing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String key, String text) async {
  final field = find.byKey(ValueKey(key));
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

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
    'phone write-review-revise flow autosaves and reopens both versions from history',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(testApplication());
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final repo = container.read(repositoryProvider);
      await tap(tester, find.byKey(const ValueKey('nav-1')));
      await tap(tester, find.byKey(const ValueKey('module-writing')));
      await tap(tester, find.byKey(const ValueKey('choose-writing-one-place')));
      expect(find.byType(WritingPage), findsOneWidget);
      final id =
          (await repo.db.select(repo.db.practiceSessions).get()).single.id;
      await tap(tester, find.byKey(const ValueKey('writing-view-outline')));
      await enter(
        tester,
        'writing-outline',
        'One impression. Two details. A close.',
      );
      await tap(tester, find.byKey(const ValueKey('writing-view-write')));
      await enter(
        tester,
        'writing-body',
        'A quiet corner helps me concentrate.',
      );
      // Exercise the keyboard editing path, not only direct form replacement.
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(
        (await repo.load(id)).response.body,
        'A quiet corner helps me concentrate',
      );
      await tap(
        tester,
        find.byType(BackButton).first,
      ); // Leaving flushes and returns to library.
      await tap(tester, find.byType(BackButton).first);
      await tap(tester, find.byKey(const ValueKey('nav-0')));
      await tap(tester, find.byKey(ValueKey('resume-$id')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('writing-body')))
            .controller!
            .text,
        'A quiet corner helps me concentrate',
      );
      await tap(tester, find.byKey(const ValueKey('writing-view-review')));
      expect((await repo.load(id)).session.status, 'completed');
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('writing-body')))
            .readOnly,
        isTrue,
      );
      expect(find.text('Not assessed'), findsNWidgets(4));
      final bodyController = tester
          .widget<TextField>(find.byKey(const ValueKey('writing-body')))
          .controller!;
      bodyController.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 14,
      );
      await tap(tester, find.text('Use selected draft text').first);
      await tap(tester, find.byKey(const ValueKey('finish-writing-review')));
      expect((await repo.load(id)).reviewStatus, ReviewStatus.reviewed);
      await tap(tester, find.byKey(const ValueKey('create-revision')));
      final versions = await WritingRepository(repo).versions(id);
      final child = versions.last.sessionId;
      expect(versions, hasLength(2));
      await enter(
        tester,
        'writing-body',
        'A quiet corner with soft light helps me concentrate.',
      );
      await tap(tester, find.byKey(const ValueKey('writing-view-review')));
      await tap(tester, find.byKey(const ValueKey('version-1')).last);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('writing-body')))
            .controller!
            .text,
        'A quiet corner helps me concentrate',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(testApplication(repository: repo));
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(const ValueKey('nav-2')));
      await tap(tester, find.byKey(ValueKey('resume-$child')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('writing-body')))
            .controller!
            .text,
        'A quiet corner with soft light helps me concentrate.',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  testWidgets(
    'writing timer stays optional and start/pause/review retain stage state',
    (tester) async {
      await tester.pumpWidget(testApplication());
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final repo = c.read(repositoryProvider);
      final id = await repo.createDraft(
        c
            .read(exercisesProvider)
            .firstWhere((e) => e.id == 'writing-one-place'),
        DateTime.now(),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(ValueKey('resume-$id')));
      await tap(tester, find.byKey(const ValueKey('writing-view-write')));
      expect((await repo.load(id)).elapsedMs, 0);
      expect((await repo.load(id)).session.status, 'draft');
      await tap(tester, find.byKey(const ValueKey('writing-timer')));
      expect((await repo.load(id)).session.status, 'running');
      expect((await repo.load(id)).session.stage, 'respond');
      await tap(tester, find.byKey(const ValueKey('writing-timer')));
      expect((await repo.load(id)).session.status, 'paused');
      await tap(tester, find.byKey(const ValueKey('writing-view-review')));
      expect((await repo.load(id)).session.status, 'completed');
      expect((await repo.load(id)).openSegment, isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  for (final (size, scale) in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets('writing views fit $size at $scale text scale', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(testApplication());
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final repo = c.read(repositoryProvider);
      await repo.saveSetting('theme', 'dark');
      await repo.saveSetting('reduceMotion', 'true');
      final id = await repo.createDraft(
        c
            .read(exercisesProvider)
            .firstWhere((e) => e.id == 'writing-public-space'),
        DateTime.now(),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(ValueKey('resume-$id')));
      for (final step in ['outline', 'write', 'review', 'brief']) {
        await tap(tester, find.byKey(ValueKey('writing-view-$step')));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
