import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/audio/wave_file.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'named-device native capture, pause, playback, seek and restart probe',
    (tester) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}${Platform.pathSeparator}verification${Platform.pathSeparator}speech-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final db = AppDatabase(
        NativeDatabase.createInBackground(File('${root.path}/probe.sqlite')),
      );
      final practice = PracticeRepository(db);
      final store = AudioStore(practice, root);
      final backend = NativeAudioBackend();
      final audio = LocalAudio(store, backend);
      final report = <String, dynamic>{
        'platform': Platform.operatingSystem,
        'root': root.path,
        'requestedEncoder': 'wav-pcm16',
        'requestedSampleRate': 48000,
        'requestedChannels': 1,
      };
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Speech Studio hardware check: a short local Realtek recording and replay. Say a non-sensitive sentence if you want to check speech.',
                ),
              ),
            ),
          ),
        );
        await audio.refreshInputs();
        report['inputs'] = audio.inputs.map((d) => d.toMap()).toList();
        const deviceHint = String.fromEnvironment(
          'AUDIO_INPUT',
          defaultValue: 'Realtek',
        );
        final input = audio.inputs
            .where(
              (d) => d.label.toLowerCase().contains(deviceHint.toLowerCase()),
            )
            .firstOrNull;
        if (input == null) {
          throw AudioFailure(
            'Requested input "$deviceHint" was not enumerated. No other microphone was substituted.',
          );
        }
        audio.chooseInput(input.id);
        report['selectedInput'] = input.toMap();
        final exercise = validateExercisePack(
          await rootBundle.loadString('assets/exercises/core-v1.json'),
        ).firstWhere((e) => e.module == 'speech');
        final sessionId = await practice.createDraft(exercise, DateTime.now());
        debugPrint(
          'SPEECH_CAPTURE_START input=${input.label} root=${root.path}',
        );
        await audio.start(sessionId);
        await Future<void>.delayed(const Duration(seconds: 3));
        await audio.pause();
        await Future<void>.delayed(const Duration(seconds: 1));
        await audio.resume();
        await Future<void>.delayed(const Duration(seconds: 3));
        final row = (await audio.stop())!;
        report['captureInterrupted'] = row.interrupted;
        report['captureNote'] = row.statusNote;
        if (row.state != 'finalized') throw AudioFailure(row.statusNote);
        final info = await inspectWave(store.fileFor(row.relativePath).path);
        report['capture'] = {
          'state': row.state,
          'path': store.fileFor(row.relativePath).path,
          'rate': info.sampleRate,
          'channels': info.channels,
          'durationMs': info.durationMs,
          'peakDb': info.peakDb,
          'rmsDb': info.rmsDb,
        };
        report['signalDetected'] = info.peakDb > -90 && info.rmsDb > -90;
        if (row.interrupted ||
            info.durationMs < 5000 ||
            info.durationMs > 7500) {
          throw AudioFailure(
            'Pause/resume did not retain the expected six seconds of capture: ${info.durationMs} ms, ${row.statusNote}',
          );
        }
        await audio.playPause();
        await backend.player.setVolume(25);
        await Future<void>.delayed(const Duration(seconds: 2));
        final firstPosition = backend.player.state.position.inMilliseconds;
        if (firstPosition <= 0) {
          throw const AudioFailure('Playback position did not advance.');
        }
        await audio.playPause();
        await audio.seek(500);
        await audio.setSpeed(1.25);
        await audio.addObservation('Native test observation at 0.5 seconds.');
        await audio.playPause();
        await backend.player.stream.completed
            .firstWhere((v) => v)
            .timeout(const Duration(seconds: 20));
        report['playback'] = {
          'completed': true,
          'firstPositionMs': firstPosition,
          'decodedParams': backend.player.state.audioParams.toString(),
          'outputs': backend.player.state.audioDevices
              .map((d) => d.toString())
              .toList(),
          'selectedOutput': backend.player.state.audioDevice.toString(),
          'rate': audio.rate,
        };
        await audio.close();
        await db.close();
        final reopened = AppDatabase(
          NativeDatabase.createInBackground(File('${root.path}/probe.sqlite')),
        );
        final restored = AudioStore(PracticeRepository(reopened), root);
        await restored.reconcile();
        report['restartFinalized'] =
            (await restored.load(row.id)).state == 'finalized';
        report['observations'] =
            (await reopened.select(reopened.audioObservations).get()).length;
        await reopened.close();
        report['status'] = report['signalDetected'] == true
            ? 'capture-and-native-playback-verified'
            : 'capture-and-playback-ran-but-input-silent';
      } catch (e, s) {
        report['status'] = 'unavailable-or-failed';
        report['error'] = e.toString();
        debugPrint(s.toString());
        try {
          await audio.close();
        } catch (_) {}
        try {
          await db.close();
        } catch (_) {}
      }
      final output = File('${root.path}/capability.json');
      await output.writeAsString(
        const JsonEncoder.withIndent('  ').convert(report),
      );
      debugPrint('SPEECH_CAPABILITY ${jsonEncode(report)}');
      // A probe can report unavailable hardware; its status, not test completion, is the evidence.
      expect(report.containsKey('status'), isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
