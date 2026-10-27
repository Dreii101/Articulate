import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/debate/debate_page.dart';
import 'package:articulate/debate/debate_repository.dart';
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
import 'debate_repository_test.dart' show debateExercise;

Finder debatePicker() => find.byWidgetPredicate(
  (w) =>
      w is DropdownButtonFormField<String> &&
      w.key is ValueKey<String> &&
      (w.key as ValueKey<String>).value.startsWith('debate-stage-picker'),
);
Future<void> debateView(WidgetTester t, String label) async {
  await memoryTap(t, debatePicker());
  await memoryTap(t, find.text(label).last);
}

Future<void> debateType(WidgetTester t, String field, String value) async {
  final f = find.byKey(ValueKey('debate-field-$field'));
  await t.ensureVisible(f);
  await t.enterText(f, value);
  await memoryWait(t);
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
  late Directory root;
  late AppDatabase db;
  late PracticeRepository p;
  late DebateRepository repo;
  late LocalAudio audio;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('debate-widget-');
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    repo = DebateRepository(p);
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
  Widget direct(Widget page) => ProviderScope(
    overrides: [
      repositoryProvider.overrideWithValue(p),
      localAudioProvider.overrideWith((ref) async => audio),
    ],
    child: MaterialApp(theme: articulateTheme(Brightness.light), home: page),
  );
  void size(WidgetTester t, Size value, double scale) {
    t.view.physicalSize = value;
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets(
    'full written round, source notes, scripted opposition, anchored review and History',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      await t.pumpWidget(testApplication(repository: p, audio: audio));
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('nav-1')));
      await memoryTap(t, find.byKey(const ValueKey('module-debate')));
      await memoryTap(
        t,
        find.byKey(const ValueKey('choose-debate-round-beginner')),
      );
      await memoryTap(t, find.byKey(const ValueKey('debate-start-round')));
      await debateType(t, 'claim', 'A predictable quiet period would help.');
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(FocusManager.instance.primaryFocus, isNotNull);
      await debateType(t, 'reasoning', 'Visitors could choose when to attend.');
      await debateType(
        t,
        'evidence',
        'Imagine a visitor who needs to concentrate.',
      );
      await debateType(
        t,
        'sourceNotes',
        'Hypothetical example; no survey was supplied.',
      );
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      await debateType(
        t,
        'opening',
        'Offer a short, reversible trial and listen to visitors.',
      );
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      expect(
        find.text('Scripted practice — opposing argument'),
        findsOneWidget,
      );
      expect(
        t
            .widget<SelectableText>(find.byKey(const ValueKey('debate-script')))
            .data,
        debateExercise().content['debate']['against']['argument'],
      );
      await debateType(
        t,
        'counterargument',
        'The scheduled time could exclude people who come to socialise.',
      );
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      await debateType(
        t,
        'rebuttal',
        'The timing concern matters. A trial should check who is excluded before keeping the schedule.',
      );
      await debateType(
        t,
        'sourceNotes',
        'We need participation evidence; this is a proposal, not an established outcome.',
      );
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      await debateType(t, 'reflection', 'Ask people affected by the schedule.');
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      expect(find.text('Your anchored self-review'), findsOneWidget);
      expect(find.text('Not assessed'), findsNWidgets(5));
      final response = find.byKey(const ValueKey('debate-field-rebuttal'));
      final editor = t.widget<TextField>(response).controller!;
      expect(t.widget<TextField>(response).readOnly, isTrue);
      editor.selection = const TextSelection(baseOffset: 0, extentOffset: 26);
      await memoryTap(t, find.text('Attach selected passage').first);
      await memoryWait(t);
      final note = find.byKey(const ValueKey('debate-next-action'));
      await t.ensureVisible(note);
      await t.enterText(
        note,
        'Find appropriate evidence before making a factual claim.',
      );
      await memoryWait(t);
      final id = (await t.runAsync(() => db.select(db.practiceSessions).get()))!
          .single
          .id;
      final round = (await t.runAsync(() => repo.load(id)))!;
      expect(
        jsonDecode(round.workspace.assessments)['relevance']['anchor']['quote'],
        editor.text.substring(0, 26),
      );
      expect(
        jsonDecode(round.workspace.assessments)['support']['rating'],
        isNull,
      );
      await debateView(t, '1. Preparation · completed');
      expect(
        t
            .widget<TextField>(
              find.byKey(const ValueKey('debate-field-sourceNotes')),
            )
            .controller!
            .text,
        startsWith('Hypothetical example'),
      );
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byKey(const ValueKey('nav-2')));
      await memoryTap(t, find.byKey(ValueKey('resume-$id')));
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('debate-next-action')))
            .controller!
            .text,
        startsWith('Find appropriate evidence'),
      );
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  testWidgets(
    'draft autosave, skip confirmation and restart retain stage and notes',
    (t) async {
      final id = (await t.runAsync(
        () => repo.create(debateExercise(), 'against', 'written', 'Untimed', [
          0,
          0,
          0,
          0,
          0,
        ], DateTime.now()),
      ))!;
      await t.pumpWidget(direct(DebatePage(sessionId: id)));
      await memoryWait(t);
      await debateType(t, 'claim', 'Keep this preparation.');
      await memoryTap(t, find.byKey(const ValueKey('debate-skip')));
      await memoryTap(t, find.text('Skip stage'));
      await debateType(t, 'opening', 'Opening draft survives restart.');
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
      await t.pumpWidget(direct(DebatePage(sessionId: id)));
      await memoryWait(t);
      expect(
        t
            .widget<TextField>(
              find.byKey(const ValueKey('debate-field-opening')),
            )
            .controller!
            .text,
        'Opening draft survives restart.',
      );
      await debateView(t, '1. Preparation · skipped');
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('debate-field-claim')))
            .controller!
            .text,
        'Keep this preparation.',
      );
      expect(find.textContaining('Skipped stage.'), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  testWidgets(
    'recording completes with its stage and is absent from the other stage; missing media is honest',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      final id = (await t.runAsync(
        () => repo.create(debateExercise(), 'for', 'recorded', 'Untimed', [
          0,
          0,
          0,
          0,
          0,
        ], DateTime.now()),
      ))!;
      await t.pumpWidget(direct(DebatePage(sessionId: id)));
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      await memoryTap(t, find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      expect(audio.capturing, isFalse);
      expect(audio.lastStopped!.contextKey, 'opening');
      final take = audio.lastStopped!;
      await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      expect(find.byKey(ValueKey('listen-${take.id}')), findsNothing);
      expect(
        find.textContaining('No recording was supplied for this stage.'),
        findsOneWidget,
      );
      await debateView(t, '2. Opening · completed');
      await t.runAsync(() => audio.store.fileFor(take.relativePath).delete());
      await memoryTap(t, find.byKey(ValueKey('listen-${take.id}')));
      expect(find.textContaining('Recording file is missing'), findsOneWidget);
      expect(
        t
            .widget<FilledButton>(find.byKey(const ValueKey('speech-record')))
            .onPressed,
        isNull,
      );
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  for (final (viewport, scale) in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets('setup, all stages, review and audio fit $viewport at $scale', (
      t,
    ) async {
      size(t, viewport, scale);
      await t.pumpWidget(direct(DebateSetupPage(exercise: debateExercise())));
      await memoryWait(t);
      expect(t.takeException(), isNull);
      final id = (await t.runAsync(
        () => repo.create(debateExercise(), 'for', 'recorded', 'Untimed', [
          0,
          0,
          0,
          0,
          0,
        ], DateTime.now()),
      ))!;
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
      await t.pumpWidget(direct(DebatePage(sessionId: id)));
      await memoryWait(t);
      for (var i = 0; i < 5; i++) {
        expect(t.takeException(), isNull);
        await memoryTap(t, find.byKey(const ValueKey('debate-next')));
      }
      expect(t.takeException(), isNull);
      expect(find.text('Your anchored self-review'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    });
  }
}
