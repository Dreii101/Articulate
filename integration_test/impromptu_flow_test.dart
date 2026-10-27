import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/exercises.dart';
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
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native surprise response, real audio, review and linked retry survive reopen',
    (t) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/impromptu-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final file = File('${root.path}/impromptu.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var p = PracticeRepository(db), repo = ImpromptuRepository(p);
      var backend = NativeAudioBackend();
      var audio = LocalAudio(AudioStore(p, root), backend);
      final pool = validateExercisePack(
        await rootBundle.loadString('assets/exercises/impromptu-v1.json'),
      ).where((e) => e.level == 'beginner').toList();
      final id = await repo.start(
        pool,
        'native-start',
        'recorded',
        'Native check',
        [30, 60],
        DateTime.now(),
      );
      final question = (await repo.load(id)).detail.exercise.prompt;
      Widget app(String attemptId) => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(p),
          localAudioProvider.overrideWith((ref) async => audio),
        ],
        child: MaterialApp(
          theme: articulateTheme(Brightness.light),
          home: ImpromptuPage(sessionId: attemptId),
        ),
      );
      Future<void> wait() async {
        for (var i = 0; i < 30; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 25));
          await t.pump();
        }
        await t.pumpAndSettle();
      }

      Future<void> tap(Finder f) async {
        await t.ensureVisible(f);
        await t.tap(f);
        await wait();
      }

      Future<void> type(String key, String text) async {
        final f = find.byKey(ValueKey('impromptu-$key'));
        await t.ensureVisible(f);
        await t.enterText(f, text);
        await wait();
      }

      await t.pumpWidget(app(id));
      await wait();
      expect(find.text(question), findsNothing);
      await tap(find.byKey(const ValueKey('impromptu-reveal')));
      expect(find.text(question), findsOneWidget);
      await type('preparation', 'Answer directly and illustrate the reason.');
      await tap(find.byKey(const ValueKey('impromptu-timer')));
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await t.pump();
      await tap(find.byKey(const ValueKey('impromptu-timer')));
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      repo = ImpromptuRepository(p);
      backend = NativeAudioBackend();
      audio = LocalAudio(AudioStore(p, root), backend);
      await t.pumpWidget(app(id));
      await wait();
      expect(find.text(question), findsOneWidget);
      expect(
        t
            .widget<TextField>(
              find.byKey(const ValueKey('impromptu-preparation')),
            )
            .controller!
            .text,
        'Answer directly and illustrate the reason.',
      );
      await tap(find.byKey(const ValueKey('impromptu-advance')));
      await type(
        'response',
        'Native verification: remembered response notes, not a transcript.',
      );
      await tap(find.byKey(const ValueKey('refresh-speech-inputs')));
      if (Platform.isWindows) {
        final input = audio.inputs
            .where((i) => i.label == 'Microphone (Realtek(R) Audio)')
            .firstOrNull;
        if (input == null) {
          throw StateError(
            'Realtek input unavailable; no capture verification claimed.',
          );
        }
        audio.chooseInput(input.id);
        await t.pump();
      }
      await tap(find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await Future<void>.delayed(const Duration(seconds: 2));
      await t.pump();
      await tap(find.byKey(const ValueKey('impromptu-advance')));
      expect(audio.capturing, isFalse);
      final take = audio.lastStopped!;
      expect(take.state, 'finalized');
      expect(take.durationMs, greaterThan(1500));
      await type('reflection', 'Start with a shorter direct answer.');
      final confidence = find.byWidgetPredicate(
        (w) =>
            w is DropdownButtonFormField<String> &&
            w.key is ValueKey<String> &&
            (w.key as ValueKey<String>).value.startsWith(
              'impromptu-Confidence-',
            ),
      );
      await tap(confidence);
      await tap(find.text('4 — Confident').last);
      await tap(find.byKey(const ValueKey('impromptu-save-review')));
      await tap(find.byKey(const ValueKey('impromptu-retry')));
      await tap(find.byKey(const ValueKey('impromptu-reveal')));
      expect(find.text(question), findsOneWidget);
      await tap(find.byKey(const ValueKey('impromptu-advance')));
      await type('response', 'A shorter answer in an unrecorded retry.');
      await tap(find.byKey(const ValueKey('impromptu-advance')));
      await type('reflection', 'The shorter opening felt easier to follow.');
      await tap(find.byKey(const ValueKey('impromptu-save-review')));
      final retry = await (db.select(
        db.impromptuWorkspaces,
      )..where((w) => w.parentSessionId.equals(id))).getSingle();
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      repo = ImpromptuRepository(p);
      backend = NativeAudioBackend();
      audio = LocalAudio(AudioStore(p, root), backend);
      await audio.store.reconcile();
      await t.pumpWidget(app(id));
      await wait();
      final original = await repo.load(id),
          child = await repo.load(retry.sessionId);
      expect(original.detail.session.snapshot, child.detail.session.snapshot);
      expect(original.workspace.confidence, 4);
      expect(
        jsonDecode(original.workspace.assessments)['directness']['rating'],
        isNull,
      );
      expect(
        original.detail.elapsedFor(PracticeStage.prepare),
        greaterThan(1000),
      );
      expect(
        child.detail.response.body,
        'A shorter answer in an unrecorded retry.',
      );
      expect(child.detail.session.status, 'completed');
      await tap(find.byKey(ValueKey('listen-${take.id}')));
      await backend.player.setVolume(25);
      await tap(find.byKey(const ValueKey('speech-play')));
      final playback = backend.player.state.position.inMilliseconds;
      expect(playback, greaterThan(0));
      await audio.backend.pausePlayback();
      await t.pumpWidget(const SizedBox());
      await wait();
      await t.pumpWidget(app(retry.sessionId));
      await wait();
      expect(find.text(question), findsOneWidget);
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('impromptu-response')))
            .controller!
            .text,
        child.detail.response.body,
      );
      final report = {
        'platform': Platform.operatingSystem,
        'root': root.path,
        'questionId': original.detail.exercise.id,
        'questionPreserved': true,
        'retryLinked': child.workspace.parentSessionId == id,
        'bothAttemptsReopened': true,
        'preparationElapsedMs': original.detail.elapsedFor(
          PracticeStage.prepare,
        ),
        'confidence': original.workspace.confidence,
        'performanceRating': jsonDecode(
          original.workspace.assessments,
        )['directness']['rating'],
        'input': take.inputName,
        'durationMs': take.durationMs,
        'sampleRate': take.sampleRate,
        'channels': take.channels,
        'peakDb': take.peakDb,
        'rmsDb': take.rmsDb,
        'reopenedPlaybackPositionMs': playback,
        'humanListening':
            'No new listening confirmation; native playback verified.',
      };
      await File('${root.path}/capability.json')
          .writeAsString(jsonEncode(report));
      debugPrint('IMPROMPTU_NATIVE_OK ${jsonEncode(report)}');
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
    },
  );
}
