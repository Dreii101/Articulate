import 'dart:io';

import 'package:articulate/history/history_page.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/theme.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';
import 'history_fixture.dart';
import 'memory_widget_test.dart' show memoryWait, memoryTap;
import 'support.dart';

Future<void> historyChoose(WidgetTester t, String label, String value) async {
  await memoryTap(
    t,
    find.byWidgetPredicate(
      (w) =>
          w is DropdownButtonFormField<String> &&
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith(
            'history-filter-$label-',
          ),
    ),
  );
  await memoryTap(t, find.text(value).last);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final f in ['Manrope', 'Lora']) {
      await (FontLoader(
        f,
      )..addFont(rootBundle.load('assets/fonts/$f.ttf'))).load();
    }
  });
  late AppDatabase db;
  late PracticeRepository p;
  late Map<String, String> ids;
  late LocalAudio audio;
  late Directory root;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    ids = await seedHistoryFixture(p);
    root = await Directory.systemTemp.createTemp('history-widget-');
    audio = LocalAudio(
      AudioStore(p, root),
      FakeAudioBackend(),
      automaticHeartbeat: false,
    );
  });
  tearDown(() async {
    await audio.close();
    await db.close();
    await root.delete(recursive: true);
  });
  void size(WidgetTester t, Size value, double scale) {
    t.view.physicalSize = value;
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Widget direct(Widget child) => ProviderScope(
    key: UniqueKey(),
    overrides: [
      repositoryProvider.overrideWithValue(p),
      localAudioProvider.overrideWith((ref) async => audio),
    ],
    child: MaterialApp(theme: articulateTheme(Brightness.light), home: child),
  );
  testWidgets(
    'filter dates and all fields, inspect ratings beside output, compare compatible versions and open old work',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      await t.pumpWidget(testApplication(repository: p, audio: audio));
      await memoryWait(t);
      expect(find.text('Your next action'), findsOneWidget);
      await memoryTap(t, find.byKey(const ValueKey('nav-2')));
      expect(find.text('Finalized timer time: 0h 0m 16.7s'), findsOneWidget);
      await historyChoose(t, 'Module', 'Writing Studio');
      await historyChoose(t, 'Language', 'en');
      await historyChoose(t, 'Level', 'Beginner');
      final original = (await t.runAsync(() => p.load(ids['w1']!)))!;
      await historyChoose(
        t,
        'Exercise',
        '${original.exercise.title} · ${original.exercise.id}',
      );
      await historyChoose(t, 'Status', 'Completed');
      final from = find.byKey(const ValueKey('history-from')),
          to = find.byKey(const ValueKey('history-to'));
      await t.ensureVisible(from);
      await t.enterText(from, '2026-10-25');
      await t.ensureVisible(to);
      await t.enterText(to, '2026-10-25');
      await memoryTap(t, find.byKey(const ValueKey('history-apply-dates')));
      expect(find.text('3 saved attempts'), findsOneWidget);
      expect(find.text('Finalized timer time: 0h 0m 10.5s'), findsOneWidget);
      await memoryTap(t, find.byKey(ValueKey('inspect-${ids['w1']}')));
      expect(find.text('Assessment provenance'), findsOneWidget);
      expect(
        find.textContaining('First draft with an example.'),
        findsOneWidget,
      );
      expect(find.text('Effective'), findsOneWidget);
      final compare = find.byKey(ValueKey('history-compare-${ids['w1']}'));
      await memoryTap(t, compare);
      await memoryTap(t, find.textContaining('Writing version 2').last);
      expect(find.text('Compatible attempts'), findsOneWidget);
      expect(find.text('Not assessed'), findsWidgets);
      expect(
        find.textContaining('Second draft: a revised example.'),
        findsOneWidget,
      );
      await memoryTap(t, find.byTooltip('Back to history'));
      await memoryTap(t, find.byTooltip('Back to history'));
      await memoryTap(t, find.byKey(const ValueKey('history-clear')));
      expect(find.text('15 saved attempts'), findsOneWidget);
      await t.ensureVisible(from);
      await t.enterText(from, '2026-02-31');
      await memoryTap(t, find.byKey(const ValueKey('history-apply-dates')));
      expect(find.text('Use a real date: YYYY-MM-DD'), findsOneWidget);
      await memoryTap(t, find.byKey(const ValueKey('history-clear')));
      await historyChoose(t, 'Language', 'fr');
      expect(find.text('1 saved attempts'), findsOneWidget);
      await historyChoose(t, 'Module', 'Reading Lab');
      expect(find.text('No saved work matches these filters.'), findsOneWidget);
      await memoryTap(t, find.byKey(const ValueKey('history-clear')));
      await memoryTap(t, find.byKey(ValueKey('resume-${ids['w1']}')));
      expect(
        find.textContaining('First draft with an example.'),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  testWidgets(
    'every module exposes its evidence with honest assessment and media labels; UI updates after review-only changes',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      for (final name in [
        'writing',
        'reading',
        'speech',
        'memory',
        'debate',
        'impromptu',
      ]) {
        final id = ids[name == 'writing' ? 'w2' : name]!;
        await t.pumpWidget(direct(HistoryAttemptPage(sessionId: id)));
        await memoryWait(t);
        expect(find.text('Saved output evidence'), findsOneWidget);
        expect(find.text('Assessment provenance'), findsOneWidget);
        expect(t.takeException(), isNull);
        if (name == 'reading') {
          expect(find.text('Correct'), findsOneWidget);
          expect(find.text('Incorrect'), findsOneWidget);
          expect(find.text('Unanswered'), findsOneWidget);
        }
        if (name == 'impromptu') {
          expect(
            find.textContaining('Confidence self-report: 5 / 5'),
            findsOneWidget,
          );
        }
        if (name == 'writing') {
          expect(find.text('Not assessed'), findsNWidgets(4));
          await t.runAsync(
            () =>
                (db.update(
                  db.writingWorkspaces,
                )..where((w) => w.sessionId.equals(id))).write(
                  const WritingWorkspacesCompanion(
                    assessments: Value(
                      '{"clarity":{"rating":"developing","evidence":"Second"}}',
                    ),
                  ),
                ),
          );
          await memoryWait(t);
          expect(find.text('Developing'), findsOneWidget);
        }
        await t.pumpWidget(const SizedBox());
        await memoryWait(t);
      }
    },
  );
  for (final entry in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets(
      'filters, definitions, evidence and comparison adapt at ${entry.$1} scale ${entry.$2}',
      (t) async {
        size(t, entry.$1, entry.$2);
        await t.pumpWidget(
          direct(
            Scaffold(
              body: SingleChildScrollView(
                child: HistoryPanel(onExplore: () {}),
              ),
            ),
          ),
        );
        await memoryWait(t);
        await historyChoose(t, 'Module', 'Writing Studio');
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        expect(FocusManager.instance.primaryFocus, isNotNull);
        await memoryTap(t, find.text('What these numbers measure'));
        expect(find.text(metricDefinitions), findsOneWidget);
        await memoryTap(t, find.text('Close'));
        await memoryTap(t, find.byKey(ValueKey('inspect-${ids['w1']}')));
        expect(t.takeException(), isNull);
        t.view.physicalSize = const Size(1440, 390);
        await memoryWait(t);
        expect(t.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
        await t.ensureVisible(find.text('Assessment provenance'));
        await memoryWait(t);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await memoryWait(t);
        await t.pumpWidget(
          direct(
            HistoryAttemptPage(sessionId: ids['w1']!, compareId: ids['w3']),
          ),
        );
        await memoryWait(t);
        expect(
          find.textContaining('Third draft: a clearer close.'),
          findsOneWidget,
        );
        expect(t.takeException(), isNull);
        t.view.physicalSize = const Size(375, 812);
        await memoryWait(t);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await memoryWait(t);
      },
    );
  }
}
