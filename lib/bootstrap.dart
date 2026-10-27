import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'exercises.dart';
import 'providers.dart';
import 'storage/database.dart';
import 'storage/practice_repository.dart';
import 'theme.dart';
import 'audio/audio_store.dart';
import 'data/data_manager.dart';
import 'data/platform_files.dart';

class ArticulateBootstrap extends StatefulWidget {
  const ArticulateBootstrap({super.key});
  @override
  State<ArticulateBootstrap> createState() => _ArticulateBootstrapState();
}

class _ArticulateBootstrapState extends State<ArticulateBootstrap> {
  AppDatabase? _database;
  late Future<(PracticeRepository, List<Exercise>)> _ready = _open();
  Future<(PracticeRepository, List<Exercise>)> _open() async {
    final exercises = [
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/core-v1.json'),
      ),
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/writing-v1.json'),
      ),
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/reading-v1.json'),
      ),
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/debate-v1.json'),
      ),
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/impromptu-v1.json'),
      ),
    ];
    if (exercises.map((e) => e.id).toSet().length != exercises.length) {
      throw const FormatException('Duplicate exercise ID across packs');
    }
    final db = await AppDatabase.open();
    try {
      final repository = PracticeRepository(db);
      final store = await AudioStore.open(repository);
      await DataManager(
        repository,
        store.root,
        space: DataFiles().freeBytes,
      ).recover();
      await repository.recoverInterrupted();
      await store.reconcile();
      _database = db;
      return (repository, exercises);
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _ready,
    builder: (context, snapshot) {
      if (snapshot.data case final data?) {
        return ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(data.$1),
            exercisesProvider.overrideWithValue(data.$2),
          ],
          child: const ArticulateApp(),
        );
      }
      return MaterialApp(
        theme: articulateTheme(Brightness.light),
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Your saved work could not be opened.'),
                          const SizedBox(height: 12),
                          const Text(
                            'Close another Articulate window if one is open, then try again. Your database has not been reset.',
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Local storage or recovery could not be validated. Original files have not been reset.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() => _ready = _open()),
                            child: const Text('Try again'),
                          ),
                        ],
                      )
                    : const Text('Opening your local practice…'),
              ),
            ),
          ),
        ),
      );
    },
  );
}
