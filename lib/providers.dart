import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exercises.dart';
import 'storage/database.dart';
import 'storage/practice_repository.dart';

final writingWorkspacesProvider = StreamProvider<Map<String, WritingWorkspace>>(
  (ref) {
    final db = ref.watch(repositoryProvider).db;
    return db
        .select(db.writingWorkspaces)
        .watch()
        .map((rows) => {for (final row in rows) row.sessionId: row});
  },
);

final repositoryProvider = Provider<PracticeRepository>(
  (ref) => throw StateError('Storage has not initialized'),
);
final exercisesProvider = Provider<List<Exercise>>(
  (ref) => throw StateError('Exercises have not loaded'),
);
final sessionsProvider = StreamProvider<List<PracticeSession>>(
  (ref) => ref.watch(repositoryProvider).watchSessions(),
);
final settingsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(repositoryProvider).watchSettings(),
);
