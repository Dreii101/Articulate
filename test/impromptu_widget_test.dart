import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/impromptu/impromptu_page.dart';
import 'package:articulate/impromptu/impromptu_repository.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/theme.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';
import 'support.dart';
import 'memory_widget_test.dart' show memoryWait, memoryTap;
import 'impromptu_repository_test.dart' show impromptuQuestions;

Future<void> impromptuType(WidgetTester t, String key, String text) async {
  final f = find.byKey(ValueKey('impromptu-$key'));
  await t.ensureVisible(f);
  await t.enterText(f, text);
  await memoryWait(t);
}

Future<void> impromptuChoose(
  WidgetTester t,
  String label,
  String option,
) async {
  final f = find.byWidgetPredicate(
    (w) =>
        w is DropdownButtonFormField<String> &&
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('impromptu-$label-'),
  );
  await memoryTap(t, f);
  await memoryTap(t, find.text(option).last);
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
  late Directory root;
  late AppDatabase db;
  late PracticeRepository p;
  late ImpromptuRepository repo;
  late LocalAudio audio;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('impromptu-widget-');
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    repo = ImpromptuRepository(p);
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
  Widget app(Widget page) => ProviderScope(
    key: UniqueKey(),
    overrides: [
      repositoryProvider.overrideWithValue(p),
      exercisesProvider.overrideWithValue(impromptuQuestions()),
      localAudioProvider.overrideWith((ref) async => audio),
    ],
    child: MaterialApp(theme: articulateTheme(Brightness.light), home: page),
  );
  void size(WidgetTester t, Size size, double scale) {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets(
    'surprise, scaffold, unrecorded response, human review, retry and History preserve exact question',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      await t.pumpWidget(testApplication(repository: p, audio: audio));
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('nav-1')));
      await memoryTap(t, find.byKey(const ValueKey('module-impromptu')));
      await memoryTap(t, find.byKey(const ValueKey('impromptu-start')));
      final original = (await t.runAsync(
        () => db.select(db.practiceSessions).getSingle(),
      ))!;
      final question = (await t.runAsync(() => p.load(original.id)))!
          .exercise
          .prompt;
      expect(find.text(question), findsNothing);
      await memoryTap(t, find.byKey(const ValueKey('impromptu-reveal')));
      expect(find.text(question), findsOneWidget);
      await impromptuType(t, 'preparation', 'One direct answer.');
      await memoryTap(t, find.byType(SwitchListTile));
      await impromptuType(t, 'point', 'State the answer first.');
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(FocusManager.instance.primaryFocus, isNotNull);
      await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
      await impromptuType(
        t,
        'response',
        'My first response with a relevant example.',
      );
      await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
      expect(find.text('Not assessed'), findsNWidgets(4));
      await impromptuChoose(t, 'Directness rating', 'Developing');
      await impromptuChoose(t, 'Confidence', '5 — Very confident');
      await impromptuType(t, 'reflection', 'Give the example earlier.');
      await memoryTap(t, find.byKey(const ValueKey('impromptu-save-review')));
      final saved = (await t.runAsync(() => repo.load(original.id)))!;
      expect(saved.workspace.confidence, 5);
      expect(
        jsonDecode(saved.workspace.assessments)['directness']['rating'],
        'developing',
      );
      await memoryTap(t, find.byKey(const ValueKey('impromptu-retry')));
      expect(
        find.textContaining('Retry improvement: Give the example earlier.'),
        findsOneWidget,
      );
      await memoryTap(t, find.byKey(const ValueKey('impromptu-reveal')));
      expect(find.text(question), findsOneWidget);
      await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
      await impromptuType(
        t,
        'response',
        'Improved response, separate from the first.',
      );
      await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
      await memoryTap(t, find.byTooltip('Save and go back'));
      await memoryTap(t, find.byTooltip('Save and go back'));
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byKey(const ValueKey('nav-2')));
      final sessions = (await t.runAsync(
        () => db.select(db.practiceSessions).get(),
      ))!;
      expect(sessions.length, 2);
      final retry = (await t.runAsync(
        () => (db.select(
          db.impromptuWorkspaces,
        )..where((w) => w.parentSessionId.equals(original.id))).getSingle(),
      ))!;
      expect(
        (await t.runAsync(() => p.load(retry.sessionId)))!.response.body,
        'Improved response, separate from the first.',
      );
      expect(
        (await t.runAsync(() => p.load(original.id)))!.response.body,
        'My first response with a relevant example.',
      );
      final open = find.byKey(ValueKey('resume-${original.id}'));
      expect(open, findsOneWidget);
      await memoryTap(t, open);
      expect(find.text(question), findsOneWidget);
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('impromptu-response')))
            .controller!
            .text,
        'My first response with a relevant example.',
      );
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  testWidgets(
    'autosave survives page restart and recording finalizes before review; missing media stays honest',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      final id = (await t.runAsync(
        () => repo.start(
          impromptuQuestions(),
          'spoken',
          'recorded',
          'Untimed',
          [0, 0],
          DateTime.now(),
        ),
      ))!;
      await t.pumpWidget(app(ImpromptuPage(sessionId: id)));
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('impromptu-reveal')));
      await impromptuType(t, 'preparation', 'Autosaved preparation.');
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
      await t.pumpWidget(app(ImpromptuPage(sessionId: id)));
      await memoryWait(t);
      expect(
        t
            .widget<TextField>(
              find.byKey(const ValueKey('impromptu-preparation')),
            )
            .controller!
            .text,
        'Autosaved preparation.',
      );
      await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
      await memoryTap(t, find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
      expect(audio.capturing, isFalse);
      final take = audio.lastStopped!;
      expect(take.state, 'finalized');
      await impromptuType(t, 'reflection', 'A clearer close next time.');
      await t.runAsync(() => audio.store.fileFor(take.relativePath).delete());
      await memoryTap(t, find.byKey(ValueKey('listen-${take.id}')));
      expect(audio.error, isNotNull);
      expect(find.textContaining('A clearer close next time.'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  for (final entry in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets(
      'setup, reveal, editing and review fit ${entry.$1} at ${entry.$2}',
      (t) async {
        size(t, entry.$1, entry.$2);
        await t.pumpWidget(app(const ImpromptuSetupPage()));
        await memoryWait(t);
        await memoryTap(t, find.byKey(const ValueKey('impromptu-start')));
        expect(t.takeException(), isNull);
        await memoryTap(t, find.byKey(const ValueKey('impromptu-reveal')));
        expect(t.takeException(), isNull);
        await memoryTap(t, find.byType(SwitchListTile));
        await impromptuType(t, 'point', 'A brief point that remains editable.');
        await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
        await impromptuType(t, 'response', 'An unrecorded answer.');
        await memoryTap(t, find.byKey(const ValueKey('impromptu-advance')));
        expect(t.takeException(), isNull);
        await impromptuType(t, 'reflection', 'One improvement.');
        await memoryTap(t, find.byKey(const ValueKey('impromptu-save-review')));
        expect(find.text('Not assessed'), findsNWidgets(4));
        expect(t.takeException(), isNull);
        t.view.physicalSize = const Size(375, 812);
        await memoryWait(t);
        expect(t.takeException(), isNull);
        expect(
          t
              .widget<TextField>(
                find.byKey(const ValueKey('impromptu-response')),
              )
              .controller!
              .text,
          'An unrecorded answer.',
        );
        await t.pumpWidget(const SizedBox());
        await memoryWait(t);
      },
    );
  }
}
