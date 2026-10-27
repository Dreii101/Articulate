import 'dart:io';

import 'package:articulate/app.dart';
import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native Speech Studio UI records, replays, observes and reopens a Realtek take',
    (tester) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/studio-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final file = File('${root.path}/studio.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var practice = PracticeRepository(db);
      var backend = NativeAudioBackend();
      var audio = LocalAudio(AudioStore(practice, root), backend);
      final exercises = [
        for (final name in ['core', 'writing', 'reading'])
          ...validateExercisePack(
            await rootBundle.loadString('assets/exercises/$name-v1.json'),
          ),
      ];
      Widget app() => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(practice),
          exercisesProvider.overrideWithValue(exercises),
          localAudioProvider.overrideWith((ref) async => audio),
        ],
        child: const ArticulateApp(),
      );
      Future<void> wait() async {
        for (var i = 0; i < 200; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await tester.pump();
          if (!audio.busy) break;
        }
        await tester.pumpAndSettle();
      }

      Future<void> tap(Finder finder) async {
        for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await wait();
      }

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tap(find.byKey(const ValueKey('nav-1')));
      await tap(find.byKey(const ValueKey('module-speech')));
      await tap(find.byKey(const ValueKey('choose-speech-beginner')));
      await tester.ensureVisible(find.byKey(const ValueKey('speech-notes')));
      await tester.enterText(
        find.byKey(const ValueKey('speech-notes')),
        'Native speech notes: one point, one example, a clear close.',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await wait();
      await tap(find.byKey(const ValueKey('refresh-speech-inputs')));
      await tap(find.byType(DropdownButtonFormField<String>).first);
      await tap(find.text('Microphone (Realtek(R) Audio)').last);
      expect(audio.input!.label, 'Microphone (Realtek(R) Audio)');
      await tap(find.byKey(const ValueKey('speech-mic-check')));
      for (var i = 0; i < 160 && audio.capturing; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
      await wait();
      expect(audio.capturing, isFalse);
      final rows = await db.select(db.audioRecordings).get();
      expect(rows.length, 1);
      final take = rows.single;
      expect(take.state, 'finalized');
      expect(take.durationMs, greaterThan(2000));
      expect(take.sampleRate, 48000);
      await backend.player.setVolume(25);
      await tap(find.byKey(const ValueKey('speech-play')));
      await Future<void>.delayed(const Duration(seconds: 1));
      await tester.pump();
      expect(backend.player.state.position.inMilliseconds, greaterThan(0));
      await tap(find.byKey(const ValueKey('speech-play')));
      final slider = find.byKey(const ValueKey('speech-seek'));
      await tester.ensureVisible(slider);
      final rect = tester.getRect(slider);
      await tester.tapAt(Offset(rect.left + rect.width * .4, rect.center.dy));
      await wait();
      expect(audio.position.inMilliseconds, greaterThan(0));
      await tap(find.byType(DropdownButtonFormField<double>));
      await tap(find.text('1.25×').last);
      expect(audio.rate, 1.25);
      await tester.ensureVisible(
        find.byKey(const ValueKey('speech-observation')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('speech-observation')),
        'Native observation: give the example more space.',
      );
      await tap(find.byKey(const ValueKey('add-speech-observation')));
      await tap(find.byKey(const ValueKey('complete-speech')));
      await wait();
      expect((await practice.load(take.sessionId)).session.status, 'completed');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await audio.close();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      practice = PracticeRepository(db);
      backend = NativeAudioBackend();
      audio = LocalAudio(AudioStore(practice, root), backend);
      await audio.store.reconcile();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tap(find.byKey(const ValueKey('nav-2')));
      await tap(find.byKey(ValueKey('resume-${take.sessionId}')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('speech-notes')))
            .controller!
            .text,
        startsWith('Native speech notes:'),
      );
      await tap(find.byKey(ValueKey('listen-${take.id}')));
      expect(
        find.text('Native observation: give the example more space.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('speech-notes')))
            .readOnly,
        isTrue,
      );
      debugPrint(
        'SPEECH_STUDIO_OK input=${take.inputName} rate=${take.sampleRate} durationMs=${take.durationMs} observations=1 root=${root.path}',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await audio.close();
      await db.close();
    },
  );
}
