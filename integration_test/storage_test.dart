import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/session_controller.dart';
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
    'native app-support SQLite survives close/reopen and excludes recovery gap',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Articulate storage verification')),
        ),
      );
      final exercises = validateExercisePack(
        await rootBundle.loadString('assets/exercises/core-v1.json'),
      );
      final support = await getApplicationSupportDirectory();
      // Isolated test data; never seed or clear the user's articulate.sqlite.
      final directory = await Directory(
        '${support.path}${Platform.pathSeparator}verification',
      ).create(recursive: true);
      final file = File(
        '${directory.path}${Platform.pathSeparator}storage-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var repo = PracticeRepository(db);
      final id = await repo.createDraft(exercises.first, DateTime.now());
      await repo.saveResponse(
        id,
        'Native platform persistence sentinel',
        DateTime.now().toUtc(),
      );
      await repo.saveSetting('theme', 'dark');
      final running = await repo.start(id, DateTime.now().toUtc());
      await repo.checkpoint(
        id,
        running.openSegment!.id,
        2500,
        DateTime.now().toUtc(),
      );
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      repo = PracticeRepository(db);
      await repo.recoverInterrupted();
      final recovered = await repo.load(id);
      expect(recovered.response.body, 'Native platform persistence sentinel');
      expect(recovered.elapsedMs, 2500);
      expect(recovered.session.status, 'interrupted');
      expect((await repo.watchSettings().first)['theme'], 'dark');
      final controller = SessionController(repo, id);
      await controller.open();
      await controller.transition(PracticeStatus.completed);
      await controller.transition(PracticeStatus.completed);
      expect(await db.select(db.practiceSessions).get(), hasLength(1));
      await db.close();
      // Delete only this test's exact file after its native connection is closed.
      await file.delete();
      debugPrint(
        'Native SQLite verified on ${Platform.operatingSystem}; support path: ${support.path}; saved=$id',
      );
    },
  );
}
