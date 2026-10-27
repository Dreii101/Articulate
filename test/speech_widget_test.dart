import 'dart:io';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:articulate/audio/audio_provider.dart';

import 'audio_fakes.dart';
import 'support.dart';

Future<void> speechTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  final audio = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(localAudioProvider).value;
  for (var i = 0; i < 300; i++) {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    final status = find.byKey(const ValueKey('speech-save-status'));
    final saving =
        status.evaluate().isNotEmpty &&
        (tester.widget<Text>(status).data ?? '').startsWith('Saving');
    if (!(audio?.busy ?? false) && !saving) break;
  }
  await tester.pumpAndSettle();
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
  late PracticeRepository practice;
  late FakeAudioBackend backend;
  late LocalAudio audio;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('articulate-speech-widget-');
    db = AppDatabase(NativeDatabase.memory());
    practice = PracticeRepository(db);
    backend = FakeAudioBackend();
    audio = LocalAudio(
      AudioStore(practice, root),
      backend,
      windows: true,
      automaticHeartbeat: false,
    );
  });
  tearDown(() async {
    await audio.close();
    await db.close();
    await root.delete(recursive: true);
  });

  testWidgets(
    'notes, unrecorded practice, capture controls, playback and observations survive navigation and restart',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        testApplication(repository: practice, audio: audio),
      );
      await tester.pumpAndSettle();
      await speechTap(tester, find.byKey(const ValueKey('nav-1')));
      await speechTap(tester, find.byKey(const ValueKey('module-speech')));
      await speechTap(
        tester,
        find.byKey(const ValueKey('choose-speech-beginner')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('speech-notes')),
        'One point, a concrete example, and a clear close.',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await speechTap(tester, find.byKey(const ValueKey('speech-unrecorded')));
      expect(backend.starts, 0);
      final id = (await db.select(db.practiceSessions).get()).single.id;
      await speechTap(
        tester,
        find.byKey(const ValueKey('refresh-speech-inputs')),
      );
      await speechTap(tester, find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await speechTap(
        tester,
        find.byKey(const ValueKey('speech-pause-recording')),
      );
      expect(audio.mode, AudioMode.paused);
      await speechTap(
        tester,
        find.byKey(const ValueKey('speech-pause-recording')),
      );
      expect(audio.mode, AudioMode.recording);
      await speechTap(tester, find.byKey(const ValueKey('speech-stop')));
      expect(audio.capturing, isFalse);
      await speechTap(tester, find.byKey(const ValueKey('speech-play')));
      expect(backend.plays, 1);
      await speechTap(tester, find.byKey(const ValueKey('speech-play')));
      await tester.runAsync(() => audio.seek(500));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('speech-observation')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('speech-observation')),
        'Give this detail a little room.',
      );
      await speechTap(
        tester,
        find.byKey(const ValueKey('add-speech-observation')),
      );
      expect(
        (await db.select(db.audioObservations).get()).single.positionMs,
        500,
      );
      await speechTap(tester, find.byType(BackButton).first);
      await speechTap(tester, find.byType(BackButton).first);
      await speechTap(tester, find.byKey(const ValueKey('nav-0')));
      await speechTap(tester, find.byKey(ValueKey('resume-$id')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('speech-notes')))
            .controller!
            .text,
        startsWith('One point'),
      );
      await speechTap(tester, find.byKey(const ValueKey('complete-speech')));
      expect((await practice.load(id)).session.status, 'completed');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        testApplication(repository: practice, audio: audio),
      );
      await tester.pumpAndSettle();
      await speechTap(tester, find.byKey(const ValueKey('nav-2')));
      await speechTap(tester, find.byKey(ValueKey('resume-$id')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('speech-notes')))
            .readOnly,
        isTrue,
      );
      expect(find.text('Give this detail a little room.'), findsOneWidget);
      expect((await db.select(db.audioRecordings).get()).length, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  for (final layout in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets(
      'speech notes, denied input and playback fit ${layout.$1} at ${layout.$2}',
      (tester) async {
        tester.view.physicalSize = layout.$1;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = layout.$2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await practice.saveSetting('theme', 'dark');
        await practice.saveSetting('reduceMotion', 'true');
        final e = validateExercisePack(
          File('assets/exercises/core-v1.json').readAsStringSync(),
        ).firstWhere((e) => e.id == 'speech-advanced');
        final id = await practice.createDraft(e, DateTime.now());
        await tester.runAsync(() async {
          await audio.start(id);
          await audio.stop();
        });
        await tester.pumpWidget(
          testApplication(repository: practice, audio: audio),
        );
        await tester.pumpAndSettle();
        await speechTap(tester, find.byKey(ValueKey('resume-$id')));
        expect(tester.takeException(), isNull);
        backend.allowed = false;
        if (find
            .byKey(const ValueKey('speech-view-audio'))
            .evaluate()
            .isNotEmpty) {
          await speechTap(
            tester,
            find.byKey(const ValueKey('speech-view-audio')),
          );
        }
        await speechTap(
          tester,
          find.byKey(const ValueKey('refresh-speech-inputs')),
        );
        expect(
          find.textContaining('Microphone permission denied'),
          findsOneWidget,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('speech-observation')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('speech-observation')),
          'A human observation.',
        );
        await speechTap(
          tester,
          find.byKey(const ValueKey('add-speech-observation')),
        );
        expect(tester.takeException(), isNull);
        await speechTap(tester, find.byType(BackButton).first);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
}
