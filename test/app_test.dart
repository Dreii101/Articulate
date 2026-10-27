import 'package:articulate/app.dart';
import 'package:articulate/catalogue.dart';
import 'package:articulate/theme.dart';
import 'package:articulate/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'support.dart';

Future<void> openApp(WidgetTester tester, Size size, {double scale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(testApplication());
  await tester.pumpAndSettle();
}

Future<void> navigate(WidgetTester tester, int destination) async {
  await tester.tap(find.byKey(ValueKey('nav-$destination')));
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
  test(
    'catalogue has six unique modules and three meaningful previews each',
    () {
      expect(modules.map((m) => m.id).toSet().length, 6);
      for (final module in modules) {
        expect(module.previews.length, levels.length);
        for (final preview in module.previews) {
          expect(preview.title, isNotEmpty);
          expect(preview.prompt.length, greaterThan(80));
          expect(preview.focus, isNotEmpty);
        }
      }
    },
  );

  for (final brightness in Brightness.values) {
    test('$brightness primary, body and muted text meet contrast', () {
      final c = articulateTheme(brightness).colorScheme;
      double contrast(Color a, Color b) {
        final values = [a.computeLuminance(), b.computeLuminance()]..sort();
        return (values.last + .05) / (values.first + .05);
      }

      for (final background in [
        c.surface,
        c.surfaceContainerLow,
        c.surfaceContainerHighest,
      ]) {
        expect(contrast(c.onSurface, background), greaterThanOrEqualTo(4.5));
        expect(
          contrast(c.onSurfaceVariant, background),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
    });
  }

  for (final size in [
    const Size(320, 700),
    const Size(375, 812),
    const Size(844, 390),
    const Size(1024, 390),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('navigation and layouts fit $size', (tester) async {
      await openApp(tester, size);
      expect(find.text('Make room for your voice.'), findsOneWidget);
      for (var i = 1; i < 4; i++) {
        await navigate(tester, i);
        expect(tester.takeException(), isNull);
      }
      await navigate(tester, 0);
      await tester.ensureVisible(find.byKey(const ValueKey('explore')));
      await tester.tap(find.byKey(const ValueKey('explore')));
      await tester.pumpAndSettle();
      expect(find.text('Choose your direction.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'writing opens its studio and other modules preserve previews and back navigation',
    (tester) async {
      await openApp(tester, const Size(1440, 900));
      await navigate(tester, 1);
      for (final module in modules) {
        final button = find.byKey(ValueKey('module-${module.id}'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        if (module.id == 'writing') {
          expect(find.text('Give your ideas a clear shape.'), findsOneWidget);
        } else if (module.id == 'reading') {
          expect(
            find.text('Read closely. Think beyond the page.'),
            findsOneWidget,
          );
        } else if (module.id == 'speech') {
          expect(find.text('Make space to speak.'), findsOneWidget);
        } else if (module.id == 'memory') {
          expect(
            find.text('Keep the message. Find your words.'),
            findsOneWidget,
          );
        } else if (module.id == 'debate') {
          expect(find.text('Build a case. Answer with care.'), findsOneWidget);
        } else if (module.id == 'impromptu') {
          expect(find.text('Find your answer in the moment.'), findsOneWidget);
        } else {
          for (var i = 0; i < levels.length; i++) {
            final chip = find.byKey(ValueKey('level-$i'));
            await tester.ensureVisible(chip);
            await tester.tap(chip);
            await tester.pumpAndSettle();
            expect(find.text(module.previews[i].title), findsOneWidget);
            expect(find.text(module.previews[i].prompt), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        }
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Choose your direction.'), findsOneWidget);
      }
      await navigate(tester, 2);
      expect(find.textContaining('No practice sessions yet'), findsOneWidget);
    },
  );

  for (final scale in [2.0, 3.0]) {
    testWidgets('large text $scale fits shell and long preview', (
      tester,
    ) async {
      await openApp(tester, const Size(375, 812), scale: scale);
      for (var i = 0; i < 4; i++) {
        await navigate(tester, i);
        expect(tester.takeException(), isNull);
      }
      await navigate(tester, 1);
      final button = find.byKey(const ValueKey('module-reading'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Read closely. Think beyond the page.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('desktop resizing preserves destination and remains usable', (
    tester,
  ) async {
    await openApp(tester, const Size(1440, 900));
    await navigate(tester, 3);
    for (final size in [
      const Size(1024, 390),
      const Size(375, 812),
      const Size(1440, 900),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(find.text('Your space, your way.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('theme-dark')));
      await tester.tap(find.byKey(const ValueKey('theme-dark')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('theme and reduced motion survive app recreation', (
    tester,
  ) async {
    await openApp(tester, const Size(1024, 768));
    await navigate(tester, 3);
    await tester.tap(find.byKey(const ValueKey('theme-dark')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(
      MediaQuery.disableAnimationsOf(
        tester.element(find.byType(Scaffold).first),
      ),
      isTrue,
    );
    await navigate(tester, 0);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    final repository = ProviderScope.containerOf(
      tester.element(find.byType(ArticulateApp)),
    ).read(repositoryProvider);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(testApplication(repository: repository));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('keyboard can focus and activate desktop navigation', (
    tester,
  ) async {
    await openApp(tester, const Size(1440, 900));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Choose your direction.'), findsOneWidget);
  });

  testWidgets('mobile controls have accessible labels and tap targets', (
    tester,
  ) async {
    await openApp(tester, const Size(375, 812));
    final semantics = tester.ensureSemantics();
    await navigate(tester, 3);
    try {
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    } finally {
      semantics.dispose();
    }
  });
}
