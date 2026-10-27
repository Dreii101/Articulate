import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/memory/memory_document.dart';
import 'package:articulate/memory/memory_page.dart';
import 'package:articulate/memory/memory_repository.dart';
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

Future<void> memoryWait(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 30));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  await tester.pumpAndSettle();
}

Future<void> memoryTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await memoryWait(tester);
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
  late MemoryRepository m;
  late LocalAudio audio;
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('memory-widget-');
    db = AppDatabase(NativeDatabase.memory());
    p = PracticeRepository(db);
    m = MemoryRepository(p);
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
  Future<String> seed(String kind) async {
    final doc = validateMemoryPack(
      File('assets/exercises/memory-v1.json').readAsStringSync(),
    ).first;
    final v = await m.publish(await m.saveDraft(null, doc.data));
    return m.createAttempt(v.id, 'section-1', 'meaning', kind, 'hidden');
  }

  void size(WidgetTester t, Size value, double scale) {
    t.view.physicalSize = value;
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets(
    'create speech, publish, cues, typed evidence, review and history navigation',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      await t.pumpWidget(testApplication(repository: p, audio: audio));
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('nav-1')));
      await memoryTap(t, find.byKey(const ValueKey('module-memory')));
      await memoryTap(t, find.byKey(const ValueKey('memory-starter-beginner')));
      final title = find.byKey(const ValueKey('memory-edit-speech-title'));
      await t.ensureVisible(title);
      await t.enterText(title, 'My practice speech');
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(FocusManager.instance.primaryFocus, isNotNull);
      await memoryTap(t, find.byKey(const ValueKey('memory-publish')));
      await memoryTap(t, find.byKey(const ValueKey('memory-start')));
      await memoryTap(t, find.byKey(const ValueKey('memory-cue-hidden')));
      expect(find.byKey(const ValueKey('memory-source')), findsOneWidget);
      expect(
        t
            .widget<SelectableText>(find.byKey(const ValueKey('memory-source')))
            .data,
        startsWith('Cues are hidden'),
      );
      await memoryTap(t, find.byKey(const ValueKey('memory-reveal')));
      expect(find.text('Assistance: 1 full-text reveal'), findsOneWidget);
      await memoryTap(t, find.byKey(const ValueKey('memory-reveal')));
      final response = find.byKey(const ValueKey('memory-response'));
      await t.ensureVisible(response);
      await t.enterText(
        response,
        'Listen for the question. Pause before choosing an answer.',
      );
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('memory-complete')));
      expect(t.widget<TextField>(response).readOnly, isTrue);
      await memoryTap(t, find.byKey(const ValueKey('memory-later')));
      final note = find.byKey(const ValueKey('memory-review-note'));
      await t.ensureVisible(note);
      await t.enterText(note, 'Missed the link from listening to choosing.');
      await memoryWait(t);
      final rows = await t.runAsync(() => db.select(db.practiceSessions).get());
      final id = rows!.single.id;
      expect((await t.runAsync(() => m.workspace(id)))!.laterReview, isTrue);
      expect(
        jsonDecode((await t.runAsync(() => m.workspace(id)))!.assessments),
        isEmpty,
      );
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byType(BackButton));
      await memoryTap(t, find.byKey(const ValueKey('nav-2')));
      await memoryTap(t, find.byKey(ValueKey('resume-$id')));
      expect(
        t.widget<TextField>(response).controller!.text,
        startsWith('Listen for the question'),
      );
      expect(
        t.widget<TextField>(note).controller!.text,
        startsWith('Missed the link'),
      );
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  testWidgets(
    'draft autosave and reveal count survive widget restart; completed response freezes',
    (t) async {
      final id = (await t.runAsync(() => seed('typed')))!;
      await t.pumpWidget(direct(MemoryAttemptPage(sessionId: id)));
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('memory-reveal')));
      await t.enterText(
        find.byKey(const ValueKey('memory-response')),
        'A saved draft.',
      );
      await memoryWait(t);
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
      await t.pumpWidget(direct(MemoryAttemptPage(sessionId: id)));
      await memoryWait(t);
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('memory-response')))
            .controller!
            .text,
        'A saved draft.',
      );
      expect(find.text('Assistance: 1 full-text reveal'), findsOneWidget);
      expect(
        t
            .widget<SelectableText>(find.byKey(const ValueKey('memory-source')))
            .data,
        startsWith('Cues are hidden'),
      );
      await t.pumpWidget(const SizedBox());
      await memoryWait(t);
    },
  );
  testWidgets(
    'spoken controls reuse capture and replay; review has no transcript or score',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      final id = (await t.runAsync(() => seed('spoken')))!;
      await t.pumpWidget(direct(MemoryAttemptPage(sessionId: id)));
      await memoryWait(t);
      expect(find.byKey(const ValueKey('memory-response')), findsNothing);
      await memoryTap(t, find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await memoryTap(t, find.byKey(const ValueKey('speech-stop')));
      expect(audio.lastStopped!.sessionId, id);
      await memoryTap(t, find.byKey(const ValueKey('speech-play')));
      expect(audio.playing, isTrue);
      final observation = find.byKey(const ValueKey('speech-observation'));
      await t.ensureVisible(observation);
      await t.enterText(
        observation,
        'Keep this unsaved observation while resizing.',
      );
      t.view.physicalSize = const Size(375, 812);
      await memoryWait(t);
      expect(
        t.widget<TextField>(observation).controller!.text,
        'Keep this unsaved observation while resizing.',
      );
      t.view.physicalSize = const Size(1440, 1000);
      await memoryWait(t);
      await memoryTap(t, find.byKey(const ValueKey('memory-complete')));
      expect(audio.playing, isFalse);
      expect(
        find.textContaining('No spoken accuracy has been assessed.'),
        findsOneWidget,
      );
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
    testWidgets(
      'recall, review and editor fit $viewport at $scale text scale',
      (t) async {
        size(t, viewport, scale);
        final id = (await t.runAsync(() => seed('typed')))!;
        await t.pumpWidget(direct(MemoryAttemptPage(sessionId: id)));
        await memoryWait(t);
        expect(t.takeException(), isNull);
        await memoryTap(t, find.byKey(const ValueKey('memory-complete')));
        expect(t.takeException(), isNull);
        final speech = (await t.runAsync(
          () => db.select(db.memorySpeeches).get(),
        ))!.single;
        await t.pumpWidget(const SizedBox());
        await memoryWait(t);
        await t.pumpWidget(direct(MemoryEditorPage(speech: speech)));
        await memoryWait(t);
        expect(t.takeException(), isNull);
        await memoryTap(t, find.byTooltip('Move section 1 down'));
        await memoryWait(t);
        final saved = (await t.runAsync(() => m.speech(speech.id)))!;
        expect(
          MemoryDocument.parse(jsonDecode(saved.draft)).sections.first['id'],
          'section-2',
        );
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await memoryWait(t);
      },
    );
  }
}
