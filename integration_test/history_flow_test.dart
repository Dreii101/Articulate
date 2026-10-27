import 'dart:convert';
import 'dart:io';

import 'package:articulate/app.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/history/history_repository.dart';
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

import '../test/history_fixture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native history filters, evidence, compatible comparison and recovered accounting persist',
    (t) async {
      final support = await getApplicationSupportDirectory();
      final root = await Directory(
        '${support.path}/verification/history-${DateTime.now().microsecondsSinceEpoch}',
      ).create(recursive: true);
      final file = File('${root.path}/history.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file)),
          p = PracticeRepository(db);
      final packs = <String, List<Exercise>>{};
      for (final name in [
        'core',
        'writing',
        'reading',
        'debate',
        'impromptu',
      ]) {
        packs[name] = validateExercisePack(
          await rootBundle.loadString('assets/exercises/$name-v1.json'),
        );
      }
      final ids = await seedHistoryFixture(
        p,
        packs: packs,
        memorySource: await rootBundle.loadString(
          'assets/exercises/memory-v1.json',
        ),
      );
      Widget app() => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(p),
          exercisesProvider.overrideWithValue(
            packs.values.expand((e) => e).toList(),
          ),
        ],
        child: const ArticulateApp(),
      );
      Future<void> wait() async {
        for (var i = 0; i < 30; i++) {
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

      Future<void> choose(String label, String option) async {
        await tap(
          find.byWidgetPredicate(
            (w) =>
                w is DropdownButtonFormField<String> &&
                w.key is ValueKey<String> &&
                (w.key as ValueKey<String>).value.startsWith(
                  'history-filter-$label-',
                ),
          ),
        );
        await tap(find.text(option).last);
      }

      await t.pumpWidget(app());
      await wait();
      expect(find.text('Your next action'), findsOneWidget);
      await tap(find.byKey(const ValueKey('nav-2')));
      expect(find.text('Finalized timer time: 0h 0m 16.7s'), findsOneWidget);
      await choose('Module', 'Writing Studio');
      await choose('Language', 'en');
      await choose('Level', 'Beginner');
      for (final key in ['from', 'to']) {
        final f = find.byKey(ValueKey('history-$key'));
        await t.ensureVisible(f);
        await t.enterText(f, '2026-10-25');
        await wait();
      }
      await tap(find.byKey(const ValueKey('history-apply-dates')));
      expect(find.text('3 saved attempts'), findsOneWidget);
      expect(find.text('Finalized timer time: 0h 0m 10.5s'), findsOneWidget);
      await tap(find.byKey(ValueKey('inspect-${ids['w1']}')));
      expect(
        find.textContaining('First draft with an example.'),
        findsOneWidget,
      );
      expect(find.text('Effective'), findsOneWidget);
      await tap(find.byKey(ValueKey('history-compare-${ids['w1']}')));
      await tap(find.textContaining('Writing version 2').last);
      expect(find.text('Compatible attempts'), findsOneWidget);
      expect(
        find.textContaining('Second draft: a revised example.'),
        findsOneWidget,
      );
      expect(find.text('Not assessed'), findsWidgets);
      await tap(find.byTooltip('Back to history'));
      await tap(find.byTooltip('Back to history'));
      await tap(find.byKey(const ValueKey('history-clear')));
      expect(find.text('15 saved attempts'), findsOneWidget);
      await p.saveReview(
        ids['w2']!,
        'A review edit adds no practice duration.',
        ReviewStatus.reviewed,
        DateTime.now(),
      );
      await wait();
      expect(find.text('Finalized timer time: 0h 0m 16.7s'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await wait();
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      await p.recoverInterrupted();
      await t.pumpWidget(app());
      await wait();
      await tap(find.byKey(const ValueKey('nav-2')));
      expect(find.text('Finalized timer time: 0h 0m 21.7s'), findsOneWidget);
      final entries = await HistoryRepository(p).load(),
          summary = HistorySummary(entries);
      expect(summary.finalizedMs, 21700);
      expect(summary.openSegments, 0);
      expect(summary.completed, 12);
      final report = {
        'platform': Platform.operatingSystem,
        'root': root.path,
        'fixtureAttempts': entries.length,
        'completedAttempts': summary.completed,
        'initialFinalizedMs': 16700,
        'filteredLocalDateMs': 10500,
        'recoveredFinalizedMs': summary.finalizedMs,
        'recoveredCheckpointMs': 5000,
        'preparationMs': summary.stageMs('prepare'),
        'responseMs': summary.stageMs('respond'),
        'reviewStageMs': summary.stageMs('reflect'),
        'filtersExercised': true,
        'compatibleEvidenceComparison': true,
        'missingRatingsRemainUnassessed': true,
        'playbackDuration': 'Not measured; audio length excluded',
        'laterReviewDuration': 'Not measured; no timestamp-based estimate',
        'fixtureData':
            'Synthetic transactional fixture, isolated from personal history',
        'newAudioCapture': false,
      };
      await File('${root.path}/capability.json')
          .writeAsString(jsonEncode(report));
      debugPrint('HISTORY_NATIVE_OK ${jsonEncode(report)}');
      await t.pumpWidget(const SizedBox());
      await wait();
      await db.close();
    },
  );
}
