import 'package:articulate/advanced/advanced_page.dart';
import 'package:articulate/advanced/advanced_repository.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'advanced_repository_test.dart' show customTemplate, completedRecall;
import 'memory_widget_test.dart' show memoryWait, memoryTap;

void main() {
  late AppDatabase db;
  late PracticeRepository p;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    final (_, id) = await completedRecall(p);
    await AdvancedRepository(p).observe(id, 'needsWork', DateTime(2026, 1, 1));
  });
  tearDown(() async => db.close());
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    for (final size in [
      const Size(375, 812),
      const Size(844, 390),
      const Size(1280, 720),
    ]) {
      testWidgets(
        '$platform advanced controls at $size with large text and keyboard focus',
        (t) async {
          t.view.physicalSize = size;
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          await t.pumpWidget(
            ProviderScope(
              overrides: [
                repositoryProvider.overrideWithValue(p),
                exercisesProvider.overrideWithValue([customTemplate()]),
              ],
              child: MaterialApp(
                theme: ThemeData(platform: platform, useMaterial3: true),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      size.width < 600 || size.height < 500 ? 2 : 1,
                    ),
                  ),
                  child: child!,
                ),
                home: const AdvancedPracticePage(),
              ),
            ),
          );
          await memoryWait(t);
          expect(find.text(scheduleExplanation), findsOneWidget);
          await t.enterText(
            find.byKey(const ValueKey('review-intervals')),
            '2, 5, 10',
          );
          await memoryTap(
            t,
            find.text('Save intervals for future observations'),
          );
          expect(await t.runAsync(() => AdvancedRepository(p).intervals()), [
            2,
            5,
            10,
          ]);
          await t.sendKeyEvent(LogicalKeyboardKey.tab);
          await t.pump();
          expect(FocusManager.instance.primaryFocus, isNotNull);
          await memoryTap(
            t,
            find.text('Show optional practice recommendations'),
          );
          expect(
            (await t.runAsync(() => db.select(db.appSettings).get()))!
                .singleWhere((s) => s.key == 'practiceRecommendations')
                .value,
            'false',
          );
          expect(t.takeException(), isNull);
          await t.pumpWidget(const SizedBox());
          await memoryWait(t);
        },
      );
    }
  }
  testWidgets('custom version editor validates and keeps the old snapshot', (
    t,
  ) async {
    final repo = AdvancedRepository(p);
    final old = (await t.runAsync(
      () => repo.saveCustom(customTemplate().snapshot, DateTime(2026, 10, 27)),
    ))!;
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(p),
          exercisesProvider.overrideWithValue([customTemplate()]),
        ],
        child: MaterialApp(home: CustomExerciseEditor(existing: old)),
      ),
    );
    await memoryWait(t);
    await t.enterText(
      find.widgetWithText(TextFormField, 'Exercise title'),
      'My revised exercise',
    );
    await memoryTap(t, find.text('Validate & publish local version'));
    final versions = (await t.runAsync(() => repo.customVersions()))!;
    expect(versions, hasLength(2));
    expect(versions.singleWhere((e) => e.version == 1).snapshot, old.snapshot);
    expect(versions.first.snapshot, contains('My revised exercise'));
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await memoryWait(t);
  });
}
