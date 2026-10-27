import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
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
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native Memory Trainer typed restart and spoken capture/replay retain exact version',
    (t) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/memory-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final file = File('${root.path}/memory.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var p = PracticeRepository(db);
      var m = MemoryRepository(p);
      var backend = NativeAudioBackend();
      var audio = LocalAudio(AudioStore(p, root), backend);
      final doc = validateMemoryPack(
        await rootBundle.loadString('assets/exercises/memory-v1.json'),
      ).first;
      final speech = await m.saveDraft(null, doc.data);
      final v = await m.publish(speech);
      final typed = await m.createAttempt(
        v.id,
        'section-1',
        'meaning',
        'typed',
        'hidden',
      );
      Widget app(String id) => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(p),
          localAudioProvider.overrideWith((ref) async => audio),
        ],
        child: MaterialApp(
          theme: articulateTheme(Brightness.light),
          home: MemoryAttemptPage(sessionId: id),
        ),
      );
      Future<void> wait() async {
        for (var i = 0; i < 40; i++) {
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

      await t.pumpWidget(app(typed));
      await wait();
      await t.ensureVisible(find.byKey(const ValueKey('memory-response')));
      await t.enterText(
        find.byKey(const ValueKey('memory-response')),
        'Native recall: listen for the question before choosing an answer.',
      );
      await wait();
      await tap(find.byKey(const ValueKey('memory-reveal')));
      await tap(find.byKey(const ValueKey('memory-reveal')));
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      m = MemoryRepository(p);
      backend = NativeAudioBackend();
      audio = LocalAudio(AudioStore(p, root), backend);
      await t.pumpWidget(app(typed));
      await wait();
      expect(
        t
            .widget<TextField>(find.byKey(const ValueKey('memory-response')))
            .controller!
            .text,
        startsWith('Native recall:'),
      );
      expect(find.text('Assistance: 1 full-text reveal'), findsOneWidget);
      await tap(find.byKey(const ValueKey('memory-complete')));
      await tap(find.byKey(const ValueKey('memory-later')));
      final edit = doc.data;
      edit['sections'][0]['text'] =
          'A newer version must not rewrite a practiced source.';
      await m.saveDraft(speech, edit);
      final v2 = await m.publish(speech);
      expect(v2.versionNumber, 2);
      expect(
        (await p.load(typed))
            .exercise
            .content['memory']['speech']['sections'][0]['text'],
        doc.sections.first['text'],
      );
      final spoken = await m.createAttempt(
        v.id,
        'section-2',
        'verbatim',
        'spoken',
        'phrase',
      );
      await t.pumpWidget(const SizedBox());
      await wait();
      await t.pumpWidget(app(spoken));
      await wait();
      await tap(find.byKey(const ValueKey('refresh-speech-inputs')));
      if (Platform.isWindows) {
        final input = audio.inputs
            .where((i) => i.label == 'Microphone (Realtek(R) Audio)')
            .firstOrNull;
        if (input == null) {
          throw StateError(
            'Selected Realtek microphone unavailable; no hardware verification claimed.',
          );
        }
        audio.chooseInput(input.id);
        await t.pump();
      }
      await tap(find.byKey(const ValueKey('speech-record')));
      expect(audio.capturing, isTrue);
      await Future<void>.delayed(const Duration(seconds: 3));
      await t.pump();
      await tap(find.byKey(const ValueKey('speech-stop')));
      final take = audio.lastStopped!;
      expect(take.state, 'finalized');
      expect(take.durationMs, greaterThan(2000));
      expect(take.sessionId, spoken);
      await backend.player.setVolume(25);
      await tap(find.byKey(const ValueKey('speech-play')));
      expect(backend.player.state.position.inMilliseconds, greaterThan(0));
      await tap(find.byKey(const ValueKey('memory-complete')));
      expect(audio.capturing, isFalse);
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      m = MemoryRepository(p);
      backend = NativeAudioBackend();
      audio = LocalAudio(AudioStore(p, root), backend);
      await audio.store.reconcile();
      await t.pumpWidget(app(spoken));
      await wait();
      await tap(find.byKey(ValueKey('listen-${take.id}')));
      await backend.player.setVolume(25);
      await tap(find.byKey(const ValueKey('speech-play')));
      expect(backend.player.state.position.inMilliseconds, greaterThan(0));
      expect((await m.workspace(spoken)).versionId, v.id);
      expect((await p.load(spoken)).response.body, isEmpty);
      expect((await m.workspace(typed)).laterReview, isTrue);
      expect(
        find.textContaining('No spoken accuracy has been assessed.'),
        findsOneWidget,
      );
      final report = {
        'platform': Platform.operatingSystem,
        'input': take.inputName,
        'sampleRate': take.sampleRate,
        'channels': take.channels,
        'durationMs': take.durationMs,
        'peakDb': take.peakDb,
        'rmsDb': take.rmsDb,
        'playbackPositionMs': backend.player.state.position.inMilliseconds,
        'typedRestart': true,
        'spokenRestart': true,
        'speechVersion': v.versionNumber,
        'newVersion': v2.versionNumber,
        'spokenSessionId': spoken,
        'root': root.path,
        'listeningCheck': 'Native playback position verified; no new human listening confirmation.',
      };
      await File('${root.path}/capability.json')
          .writeAsString(jsonEncode(report));
      debugPrint('MEMORY_NATIVE_OK ${jsonEncode(report)}');
      await t.pumpWidget(const SizedBox());
      await wait();
      await audio.close();
      await db.close();
    },
  );
}
