import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/debate/debate_page.dart';
import 'package:articulate/debate/debate_repository.dart';
import 'package:articulate/exercises.dart';
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
    'native structured Debate round preserves stages, timer, sources and real response audio on reopen',
    (t) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/debate-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final file = File('${root.path}/debate.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var p = PracticeRepository(db);
      var repo = DebateRepository(p);
      var backend = NativeAudioBackend();
      var audio = LocalAudio(AudioStore(p, root), backend);
      final exercise = validateExercisePack(
        await rootBundle.loadString('assets/exercises/debate-v1.json'),
      ).first;
      final id = await repo.create(
        exercise,
        'against',
        'recorded',
        'Native check',
        [60, 0, 0, 0, 0],
        DateTime.now(),
      );
      Widget app() => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(p),
          localAudioProvider.overrideWith((ref) async => audio),
        ],
        child: MaterialApp(
          theme: articulateTheme(Brightness.light),
          home: DebatePage(sessionId: id),
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

      Future<void> type(String field, String text) async {
        final f = find.byKey(ValueKey('debate-field-$field'));
        await t.ensureVisible(f);
        await t.enterText(f, text);
        await wait();
      }

      Future<void> view(String label) async {
        await tap(
          find.byWidgetPredicate(
            (w) =>
                w is DropdownButtonFormField<String> &&
                w.key is ValueKey<String> &&
                (w.key as ValueKey<String>).value.startsWith(
                  'debate-stage-picker',
                ),
          ),
        );
        await tap(find.text(label).last);
      }

      await t.pumpWidget(app());
      await wait();
      await type(
        'claim',
        'The centre should keep its limited shared time flexible.',
      );
      await type(
        'reasoning',
        'Visitors may have only one available time to meet.',
      );
      await type(
        'evidence',
        'Imagine someone who can attend only the first half-hour.',
      );
      await type(
        'sourceNotes',
        'Hypothetical example, not observed participation data.',
      );
      await tap(find.byKey(const ValueKey('debate-timer')));
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await t.pump();
      await tap(find.byKey(const ValueKey('debate-timer')));
      await tap(find.byKey(const ValueKey('debate-next')));
      await type(
        'opening',
        'A fixed quiet period could exclude social visitors; try flexible expectations first.',
      );
      await tap(find.byKey(const ValueKey('refresh-speech-inputs')));
      if (Platform.isWindows) {
        final input = audio.inputs
            .where((i) => i.label == 'Microphone (Realtek(R) Audio)')
            .firstOrNull;
        if (input == null) {
          throw StateError(
            'Selected Realtek input unavailable; no audio verification claimed.',
          );
        }
        audio.chooseInput(input.id);
        await t.pump();
      }
      await tap(find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await Future<void>.delayed(const Duration(seconds: 2));
      await t.pump();
      await tap(find.byKey(const ValueKey('debate-next')));
      expect(audio.capturing, isFalse);
      final opening = audio.lastStopped!;
      expect(opening.contextKey, 'opening');
      expect(opening.state, 'finalized');
      expect(
        find.text('Scripted practice — opposing argument'),
        findsOneWidget,
      );
      expect(
        t
            .widget<SelectableText>(find.byKey(const ValueKey('debate-script')))
            .data,
        exercise.content['debate']['for']['argument'],
      );
      await type(
        'counterargument',
        'The other position values predictability and proposes a short trial.',
      );
      await tap(find.byKey(const ValueKey('debate-next')));
      expect(find.byKey(ValueKey('listen-${opening.id}')), findsNothing);
      await type(
        'rebuttal',
        'Predictability helps, but access at the available time also matters. A trial must include those excluded by its schedule.',
      );
      await type(
        'sourceNotes',
        'Participation effects need observation; no measured result is claimed.',
      );
      await tap(find.byKey(const ValueKey('speech-record')));
      await Future<void>.delayed(const Duration(seconds: 2));
      await t.pump();
      await tap(find.byKey(const ValueKey('speech-stop')));
      final rebuttal = audio.lastStopped!;
      expect(rebuttal.contextKey, 'rebuttal');
      expect(rebuttal.durationMs, greaterThan(1500));
      await backend.player.setVolume(25);
      await tap(find.byKey(const ValueKey('speech-play')));
      expect(backend.player.state.position.inMilliseconds, greaterThan(0));
      await tap(find.byKey(const ValueKey('debate-next')));
      await type(
        'reflection',
        'Investigate who is excluded rather than assuming the answer.',
      );
      await tap(find.byKey(const ValueKey('debate-next')));
      await tap(find.byKey(ValueKey('listen-${rebuttal.id}')));
      await tap(find.text('Attach playback position').first);
      final next = find.byKey(const ValueKey('debate-next-action'));
      await t.ensureVisible(next);
      await t.enterText(
        next,
        'Gather relevant local evidence before making a factual claim.',
      );
      await wait();
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      repo = DebateRepository(p);
      backend = NativeAudioBackend();
      audio = LocalAudio(AudioStore(p, root), backend);
      await audio.store.reconcile();
      await t.pumpWidget(app());
      await wait();
      final round = await repo.load(id);
      expect(round.stages.every((s) => s.status == 'completed'), isTrue);
      expect(round.stages.first.elapsedMs, greaterThan(1000));
      expect(round.detail.session.status, 'completed');
      expect(
        jsonDecode(
          round.workspace.assessments,
        )['relevance']['anchor']['recordingId'],
        rebuttal.id,
      );
      await tap(find.byKey(ValueKey('listen-${rebuttal.id}')));
      await backend.player.setVolume(25);
      await tap(find.byKey(const ValueKey('speech-play')));
      final playback = backend.player.state.position.inMilliseconds;
      expect(playback, greaterThan(0));
      for (final label in [
        '1. Preparation · completed',
        '2. Opening · completed',
        '3. Scripted opposition · completed',
        '4. Rebuttal · completed',
        '5. Reflection · completed',
      ]) {
        await view(label);
      }
      expect(
        t
            .widget<TextField>(
              find.byKey(const ValueKey('debate-field-reflection')),
            )
            .controller!
            .text,
        startsWith('Investigate who is excluded'),
      );
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('debate-next-action')))
            .controller!
            .text,
        startsWith('Gather relevant'),
      );
      final report = {
        'platform': Platform.operatingSystem,
        'root': root.path,
        'position': 'against',
        'allStagesReopened': true,
        'preparationElapsedMs': round.stages.first.elapsedMs,
        'input': rebuttal.inputName,
        'openingDurationMs': opening.durationMs,
        'rebuttalDurationMs': rebuttal.durationMs,
        'sampleRate': rebuttal.sampleRate,
        'channels': rebuttal.channels,
        'peakDb': rebuttal.peakDb,
        'rmsDb': rebuttal.rmsDb,
        'reopenedPlaybackPositionMs': playback,
        'audioAnchorPreserved': true,
        'humanListening':
            'No new listening confirmation; native playback verified.',
      };
      await File('${root.path}/capability.json')
          .writeAsString(jsonEncode(report));
      debugPrint('DEBATE_NATIVE_OK ${jsonEncode(report)}');
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
    },
  );
}
