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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const source = String.fromEnvironment('AUDIO_COMPAT_FILE');
  const origin = String.fromEnvironment('AUDIO_COMPAT_ORIGIN');
  testWidgets('replay an actual capture transferred from the other target', (
    tester,
  ) async {
    expect({'android', 'windows'}.contains(origin), isTrue);
    expect(origin, isNot(Platform.operatingSystem));
    final support = await getApplicationSupportDirectory();
    final root = await Directory(
      '${support.path}/verification/compat-${DateTime.now().microsecondsSinceEpoch}',
    ).create(recursive: true);
    final db = AppDatabase(
      NativeDatabase.createInBackground(File('${root.path}/test.sqlite')),
    );
    final p = PracticeRepository(db);
    final store = AudioStore(p, root);
    final backend = NativeAudioBackend();
    final audio = LocalAudio(store, backend);
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Replaying a transferred compatibility recording.'),
            ),
          ),
        ),
      );
      final e = validateExercisePack(
        await rootBundle.loadString('assets/exercises/core-v1.json'),
      ).firstWhere((e) => e.module == 'speech');
      final session = await p.createDraft(e, DateTime.now());
      final pending = await store.reserve(
        session,
        'transferred-fixture',
        '$origin capture supplied for cross-platform verification',
      );
      await File(source).copy(store.fileFor(pending.relativePath).path);
      final row = await store.finalize(pending.id);
      expect(row.state, 'finalized');
      expect(row.sampleRate, 48000);
      expect(row.channels, 1);
      await audio.select(row);
      await backend.player.setVolume(25);
      await audio.playPause();
      await backend.player.stream.completed
          .firstWhere((v) => v)
          .timeout(const Duration(seconds: 60));
      expect(audio.error, isNull);
      debugPrint(
        'AUDIO_CROSS_PLATFORM_OK origin=$origin target=${Platform.operatingSystem} rate=${row.sampleRate} durationMs=${row.durationMs} source=$source root=${root.path}',
      );
    } finally {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await audio.close();
      await db.close();
    }
  }, skip: source.isEmpty || origin.isEmpty);
}
