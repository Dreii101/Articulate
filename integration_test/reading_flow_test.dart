import 'dart:io';

import 'package:articulate/app.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test/reading_flow.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native read-answer-explain-revise survives SQLite and app recreation',
    (tester) async {
      final support = await getApplicationSupportDirectory();
      final dir = await Directory(
        '${support.path}${Platform.pathSeparator}verification',
      ).create(recursive: true);
      final file = File(
        '${dir.path}${Platform.pathSeparator}reading-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      var repo = PracticeRepository(db);
      final exercises = [
        for (final name in ['core', 'writing', 'reading'])
          ...validateExercisePack(
            await rootBundle.loadString('assets/exercises/$name-v1.json'),
          ),
      ];
      Widget app() => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          exercisesProvider.overrideWithValue(exercises),
        ],
        child: const ArticulateApp(),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final id = await readingFlow(tester, repo);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      repo = PracticeRepository(db);
      await repo.recoverInterrupted();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await reopenReading(tester, id);
      expect((await db.select(db.practiceSessions).get()).length, 1);
      debugPrint(
        'READING_FLOW_OK platform=${Platform.operatingSystem} first=$id firstScore=1/3 unanswered=1 revisionPreserved=true root=${file.path}',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await db.close();
      await file.delete();
    },
  );
}
