import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

class ProbeLifecycle with WidgetsBindingObserver {
  ProbeLifecycle(this.audio);
  final LocalAudio audio;
  final states = <String>[];
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    states.add(state.name);
    audio.lifecycle(state);
  }
}

// Manually change focus, then minimize this specific verification window when prompted.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native focus change keeps capture; genuine minimize finalizes it',
    (tester) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/lifecycle-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final db = AppDatabase(
        NativeDatabase.createInBackground(File('${root.path}/test.sqlite')),
      );
      final p = PracticeRepository(db);
      final backend = NativeAudioBackend();
      final audio = LocalAudio(AudioStore(p, root), backend);
      final observer = ProbeLifecycle(audio);
      WidgetsBinding.instance.addObserver(observer);
      final report = <String, dynamic>{
        'platform': Platform.operatingSystem,
        'root': root.path,
      };
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Speech lifecycle verification. First switch focus away; then minimize this test window when the log requests it.',
                ),
              ),
            ),
          ),
        );
        await audio.refreshInputs();
        final input = audio.inputs.firstWhere(
          (d) => d.label.toLowerCase().contains('realtek'),
        );
        audio.chooseInput(input.id);
        report['input'] = input.label;
        final e = validateExercisePack(
          await rootBundle.loadString('assets/exercises/core-v1.json'),
        ).firstWhere((e) => e.module == 'speech');
        final session = await p.createDraft(e, DateTime.now());
        final row = await audio.start(session);
        debugPrint(
          'SPEECH_FOCUS_CHECK_READY: switch focus to the existing release app; leave this recording for 15 seconds.',
        );
        await Future<void>.delayed(const Duration(seconds: 15));
        report['focusStates'] = List<String>.from(observer.states);
        report['recordingAfterFocusChange'] = audio.capturing;
        if (!observer.states.contains('inactive') || !audio.capturing) {
          throw StateError(
            'An actual ordinary focus change was not observed with capture retained.',
          );
        }
        debugPrint(
          'SPEECH_MINIMIZE_READY: minimize the debug Articulate window now.',
        );
        final stopped = await audio.store
            .watch(session)
            .firstWhere(
              (rows) => rows.any((r) => r.id == row.id && r.state != 'pending'),
            )
            .timeout(const Duration(seconds: 40));
        final saved = stopped.firstWhere((r) => r.id == row.id);
        report['afterMinimize'] = {
          'state': saved.state,
          'interrupted': saved.interrupted,
          'note': saved.statusNote,
          'durationMs': saved.durationMs,
        };
        if (saved.state != 'finalized' || !saved.interrupted) {
          throw StateError(
            'Minimized capture was not finalized as interrupted.',
          );
        }
        report['status'] = 'focus-and-minimize-verified';
      } catch (e) {
        report['status'] = 'unavailable-or-failed';
        report['error'] = e.toString();
      } finally {
        WidgetsBinding.instance.removeObserver(observer);
        await audio.close();
        await db.close();
      }
      await File('${root.path}/lifecycle.json')
          .writeAsString(const JsonEncoder.withIndent('  ').convert(report));
      debugPrint('SPEECH_LIFECYCLE ${jsonEncode(report)}');
      expect(report['status'], 'focus-and-minimize-verified');
      await tester.pumpWidget(const SizedBox());
    },
  );
}
