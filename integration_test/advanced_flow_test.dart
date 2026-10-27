import 'dart:convert';
import 'dart:io';

import 'package:articulate/advanced/advanced_page.dart';
import 'package:articulate/advanced/advanced_repository.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/memory/memory_document.dart';
import 'package:articulate/memory/memory_repository.dart';
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native advanced queue, versioned custom content and restart in isolated storage',
    (t) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/advanced-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final file = File('${root.path}/advanced.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file));
      try {
        var p = PracticeRepository(db), advanced = AdvancedRepository(p);
        final exercises = validateExercisePack(
          await rootBundle.loadString('assets/exercises/writing-v1.json'),
        );
        final custom = await advanced.saveCustom(
          exercises.first.snapshot,
          DateTime.now(),
        );
        final id = await advanced.start(
          Exercise.fromSnapshot(custom.snapshot),
          'native-benchmark',
          DateTime.now(),
          label: 'benchmark',
          conditions: 'Untimed isolated native verification',
        );
        await p.saveResponse(
          id,
          'Saved native custom response.',
          DateTime.now(),
        );
        await p.transition(id, PracticeStatus.completed, DateTime.now());
        final memory = MemoryRepository(p);
        final speech = validateMemoryPack(
          await rootBundle.loadString('assets/exercises/memory-v1.json'),
        ).first;
        final version = await memory.publish(
          await memory.saveDraft(null, speech.data),
        );
        final recall = await memory.createAttempt(
          version.id,
          speech.sections.first['id']!,
          'meaning',
          'typed',
          'hidden',
        );
        await p.saveResponse(
          recall,
          'I recalled the main idea and missed the transition.',
          DateTime.now(),
        );
        await p.transition(recall, PracticeStatus.completed, DateTime.now());
        await advanced.observe(recall, 'needsWork', DateTime.now());
        await advanced.override(
          recall,
          date: calendarDate(DateTime.now()),
          paused: false,
        );
        Widget page() => ProviderScope(
          key: UniqueKey(),
          overrides: [
            repositoryProvider.overrideWithValue(p),
            exercisesProvider.overrideWithValue(exercises),
          ],
          child: const MaterialApp(home: AdvancedPracticePage()),
        );
        Future<void> settle() async {
          for (var i = 0; i < 40; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 25));
            await t.pump();
          }
        }

        await t.pumpWidget(page());
        await settle();
        expect(find.text(scheduleExplanation), findsOneWidget);
        final practiceButton = find.text('Practice / reopen this review');
        await t.ensureVisible(practiceButton);
        await t.tap(practiceButton);
        await settle();
        final retries = await db.select(db.practiceContexts).get();
        final retry = retries.singleWhere((c) => c.parentSessionId == recall);
        expect(
          (await MemoryRepository(p).workspace(retry.sessionId)).versionId,
          version.id,
        );
        expect(
          (await p.load(retry.sessionId)).session.snapshot,
          (await p.load(recall)).session.snapshot,
        );
        await t.pageBack();
        await settle();
        final edit = find.text('Edit as new version');
        await t.ensureVisible(edit);
        await t.tap(edit);
        await settle();
        await t.enterText(
          find.widgetWithText(TextFormField, 'Exercise title'),
          'My native custom exercise',
        );
        final publish = find.text('Validate & publish local version');
        await t.ensureVisible(publish);
        await t.tap(publish);
        await settle();
        expect(await advanced.customVersions(), hasLength(2));
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await settle();
        await db.close();
        db = AppDatabase(NativeDatabase.createInBackground(file));
        p = PracticeRepository(db);
        advanced = AdvancedRepository(p);
        expect(
          (await p.load(id)).response.body,
          'Saved native custom response.',
        );
        expect(
          (await advanced.customVersions())
              .singleWhere((e) => e.version == 1)
              .snapshot,
          custom.snapshot,
        );
        expect(
          (await advanced.customVersions())
              .singleWhere((e) => e.version == 2)
              .snapshot,
          contains('My native custom exercise'),
        );
        expect(
          (await p.load(retry.sessionId)).session.snapshot,
          (await p.load(recall)).session.snapshot,
        );
        expect((await advanced.queue()).single.workspace.versionId, version.id);
        await validateAdvancedLibrary(db);
        await t.pumpWidget(page());
        await settle();
        expect(t.takeException(), isNull);
        await File('${root.path}/result.json').writeAsString(
          jsonEncode({
            'platform': Platform.operatingSystem,
            'status': 'advanced-native-restart-verified',
            'customVersions': [1, 2],
            'schema': db.schemaVersion,
            'recallSession': recall,
          }),
        );
        await t.pumpWidget(const SizedBox());
        await settle();
      } finally {
        await db.close();
      }
    },
  );
}
