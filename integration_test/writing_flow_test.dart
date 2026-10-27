import 'dart:io';

import 'package:articulate/app.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/writing/writing_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native write-review-revise persists and reopens both versions', (
    tester,
  ) async {
    final support = await getApplicationSupportDirectory();
    final dir = await Directory(
      '${support.path}${Platform.pathSeparator}verification',
    ).create(recursive: true);
    final file = File(
      '${dir.path}${Platform.pathSeparator}writing-${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    var db = AppDatabase(NativeDatabase.createInBackground(file));
    var repo = PracticeRepository(db);
    final exercises = [
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/core-v1.json'),
      ),
      ...validateExercisePack(
        await rootBundle.loadString('assets/exercises/writing-v1.json'),
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
    Future<void> tap(Finder finder) async {
      for (var i = 0; i < 30 && finder.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
    }

    Future<void> enter(String key, String text) async {
      final field = find.byKey(ValueKey(key));
      await tester.ensureVisible(field);
      await tester.enterText(field, text);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tap(find.byKey(const ValueKey('nav-1')));
    await tap(find.byKey(const ValueKey('module-writing')));
    await tap(find.byKey(const ValueKey('choose-writing-one-place')));
    await tap(find.byKey(const ValueKey('writing-view-outline')));
    await enter(
      'writing-outline',
      'One point, a concrete detail, a clear close.',
    );
    await tap(find.byKey(const ValueKey('writing-view-write')));
    await enter(
      'writing-body',
      'Native original: the library corner has a wide table and quiet light.',
    );
    final original = (await db.select(db.practiceSessions).get()).single.id;
    await tap(find.byType(BackButton).first);
    await tap(find.byType(BackButton).first);
    await tap(find.byKey(const ValueKey('nav-0')));
    await tap(find.byKey(ValueKey('resume-$original')));
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('writing-body')))
          .controller!
          .text,
      startsWith('Native original:'),
    );
    await tap(find.byKey(const ValueKey('writing-view-review')));
    await enter(
      'writing-next-action',
      'Add one detail that serves the audience.',
    );
    await tap(find.byKey(const ValueKey('finish-writing-review')));
    await tap(find.byKey(const ValueKey('create-revision')));
    final child = (await WritingRepository(repo).versions(original))
        .last
        .sessionId;
    await enter(
      'writing-body',
      'Native revision: a wide table leaves room for notes, while the quiet light helps a new visitor settle in.',
    );
    await tap(find.byKey(const ValueKey('writing-view-review')));
    await tap(find.byKey(const ValueKey('finish-writing-review')));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await db.close();
    db = AppDatabase(NativeDatabase.createInBackground(file));
    repo = PracticeRepository(db);
    await repo.recoverInterrupted();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tap(find.byKey(const ValueKey('nav-2')));
    await tap(find.byKey(ValueKey('resume-$original')));
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('writing-body')))
          .controller!
          .text,
      startsWith('Native original:'),
    );
    await tap(find.byKey(const ValueKey('version-2')));
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('writing-body')))
          .controller!
          .text,
      startsWith('Native revision:'),
    );
    expect((await repo.load(original)).reviewStatus, ReviewStatus.reviewed);
    expect(
      (await repo.load(child)).session.snapshot,
      (await repo.load(original)).session.snapshot,
    );
    expect(
      (await repo.load(original)).elapsedMs,
      0,
      reason: 'Untimed writing must not earn time',
    );
    expect((await db.select(db.practiceSessions).get()).length, 2);
    debugPrint(
      'WRITING_FLOW_OK platform=${Platform.operatingSystem} original=$original revision=$child versions=2 root=${file.path}',
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await db.close();
    await file.delete();
  });
}
