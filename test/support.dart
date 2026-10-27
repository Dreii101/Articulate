import 'dart:io';

import 'package:articulate/app.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/local_audio.dart';

Widget testApplication({PracticeRepository? repository, LocalAudio? audio}) {
  final db = repository?.db ?? AppDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      if (audio != null) localAudioProvider.overrideWith((ref) async => audio),
      repositoryProvider.overrideWithValue(
        repository ?? PracticeRepository(db),
      ),
      exercisesProvider.overrideWithValue([
        ...validateExercisePack(
          File('assets/exercises/core-v1.json').readAsStringSync(),
        ),
        ...validateExercisePack(
          File('assets/exercises/writing-v1.json').readAsStringSync(),
        ),
        ...validateExercisePack(
          File('assets/exercises/reading-v1.json').readAsStringSync(),
        ),
        ...validateExercisePack(
          File('assets/exercises/debate-v1.json').readAsStringSync(),
        ),
        ...validateExercisePack(
          File('assets/exercises/impromptu-v1.json').readAsStringSync(),
        ),
      ]),
    ],
  );
  addTearDown(() async {
    container.dispose();
    if (repository == null) await db.close();
  });
  return UncontrolledProviderScope(
    container: container,
    child: const ArticulateApp(),
  );
}
