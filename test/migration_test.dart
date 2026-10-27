import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/writing/writing_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final snapshot = validateExercisePack(
    File('assets/exercises/core-v1.json').readAsStringSync(),
  ).first.snapshot;
  test('v1 → v8 preserves core data and adds module workspaces', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(File('test/fixtures/schema_v1.sql').readAsStringSync());
          raw.execute(
            'INSERT INTO practice_sessions (id, exercise_id, exercise_version, module_id, snapshot, status, stage, created_utc_ms, updated_utc_ms, started_utc_ms, local_practice_date, original_offset_minutes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              'legacy-attempt',
              'writing-beginner',
              1,
              'writing',
              snapshot,
              'running',
              'respond',
              1000,
              2000,
              1000,
              '2026-10-25',
              480,
            ],
          );
          raw.execute(
            "INSERT INTO responses VALUES ('legacy-response', 'legacy-attempt', 'Keep my draft', 2000)",
          );
          raw.execute(
            "INSERT INTO timing_segments VALUES ('legacy-segment', 'legacy-attempt', 'respond', 1000, 2000, NULL, 1000, NULL)",
          );
        },
      ),
    );
    addTearDown(db.close);
    final repo = PracticeRepository(db);
    await repo.recoverInterrupted();
    final d = await repo.load('legacy-attempt');
    expect(d.response.id, 'legacy-response');
    expect(d.response.body, 'Keep my draft');
    expect(d.session.snapshot, snapshot);
    expect(d.session.originalOffsetMinutes, 480);
    expect(d.elapsedMs, 1000);
    expect(d.session.status, 'interrupted');
    await repo.saveSetting('theme', 'dark');
    await repo.transition(
      'legacy-attempt',
      PracticeStatus.completed,
      DateTime.utc(2026),
    );
    await repo.saveReview(
      'legacy-attempt',
      'Preserved and reviewed',
      ReviewStatus.reviewed,
      DateTime.utc(2026),
    );
    expect(
      (await repo.load('legacy-attempt')).reviewStatus,
      ReviewStatus.reviewed,
    );
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle())
          .data
          .values
          .single,
      9,
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    await expectLater(
      db
          .into(db.responses)
          .insert(
            ResponsesCompanion.insert(
              id: 'orphan',
              sessionId: 'missing',
              updatedUtcMs: 0,
            ),
          ),
      throwsA(anything),
    );
    await expectLater(
      db
          .into(db.timingSegments)
          .insert(
            TimingSegmentsCompanion.insert(
              id: 'negative',
              sessionId: 'legacy-attempt',
              stage: 'respond',
              startedUtcMs: 0,
              checkpointUtcMs: 0,
              elapsedMs: -1,
            ),
          ),
      throwsA(anything),
    );
  });

  test(
    'v2 → v7 preserves existing response, review, settings and rubric snapshot',
    () async {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute(File('test/fixtures/schema_v2.sql').readAsStringSync());
            raw.execute(
              'INSERT INTO practice_sessions (id, exercise_id, exercise_version, module_id, snapshot, status, stage, created_utc_ms, updated_utc_ms, completed_utc_ms, local_practice_date, original_offset_minutes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
              [
                'v2-writing',
                'writing-beginner',
                1,
                'writing',
                snapshot,
                'completed',
                'respond',
                1000,
                2000,
                2000,
                '2026-10-25',
                480,
              ],
            );
            raw.execute(
              "INSERT INTO responses VALUES ('old-response', 'v2-writing', 'Original Phase 2 writing', 2000)",
            );
            raw.execute(
              "INSERT INTO review_records VALUES ('old-review', 'v2-writing', 'reviewed', 'My earlier reflection', 2000)",
            );
            raw.execute("INSERT INTO app_settings VALUES ('theme', 'dark')");
          },
        ),
      );
      addTearDown(db.close);
      final repo = PracticeRepository(db);
      final writing = WritingRepository(repo);
      final w = await writing.open('v2-writing');
      expect(w.legacyReviewNotes, 'My earlier reflection');
      expect((await repo.load('v2-writing')).response.id, 'old-response');
      expect((await repo.load('v2-writing')).session.snapshot, snapshot);
      expect((await repo.load('v2-writing')).review!.id, 'old-review');
      expect((await repo.watchSettings().first)['theme'], 'dark');
      await writing.finishReview('v2-writing', DateTime.now());
      expect(
        (await writing.open('v2-writing')).legacyReviewNotes,
        'My earlier reflection',
      );
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    },
  );

  test('unsupported future schema fails without resetting user data', () async {
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('PRAGMA user_version = 99');
          raw.execute('CREATE TABLE user_sentinel (value TEXT)');
          raw.execute("INSERT INTO user_sentinel VALUES ('keep')");
        },
      ),
    );
    addTearDown(db.close);
    await expectLater(
      db.customSelect('SELECT * FROM user_sentinel').get(),
      throwsStateError,
    );
  });

  test('v3 → v7 preserves a Writing Studio workspace and adds later tables without rewriting snapshots', () async {
    final writingExercise = validateExercisePack(
      File('assets/exercises/writing-v1.json').readAsStringSync(),
    ).first;
    final db = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute(File('test/fixtures/schema_v2.sql').readAsStringSync());
          raw.execute(
            "CREATE TABLE writing_workspaces (session_id TEXT NOT NULL PRIMARY KEY REFERENCES practice_sessions(id), root_session_id TEXT NOT NULL REFERENCES practice_sessions(id), parent_session_id TEXT UNIQUE REFERENCES practice_sessions(id), version_number INTEGER NOT NULL, outline TEXT NOT NULL DEFAULT '', audience TEXT NOT NULL, purpose TEXT NOT NULL, view_step TEXT NOT NULL DEFAULT 'brief', assessments TEXT NOT NULL DEFAULT '{}', review_rubric TEXT NOT NULL, legacy_review_notes TEXT NOT NULL DEFAULT '', next_action TEXT NOT NULL DEFAULT '', updated_utc_ms INTEGER NOT NULL, UNIQUE(root_session_id, version_number))",
          );
          raw.execute('PRAGMA user_version = 3');
          raw.execute(
            "INSERT INTO practice_sessions (id, exercise_id, exercise_version, module_id, snapshot, status, stage, created_utc_ms, updated_utc_ms, local_practice_date, original_offset_minutes) VALUES ('keep-writing', ?, 1, 'writing', ?, 'draft', 'respond', 1, 2, '2026-10-25', 480)",
            [writingExercise.id, writingExercise.snapshot],
          );
          raw.execute(
            "INSERT INTO responses VALUES ('keep-response', 'keep-writing', 'My original writing', 2)",
          );
          raw.execute(
            "INSERT INTO writing_workspaces (session_id, root_session_id, version_number, outline, audience, purpose, review_rubric, next_action, updated_utc_ms) VALUES ('keep-writing', 'keep-writing', 1, 'My outline', 'My audience', 'My purpose', ?, 'Keep my next action', 2)",
            ['{"id":"saved-rubric","version":1,"criteria":[]}'],
          );
        },
      ),
    );
    addTearDown(db.close);
    final practice = PracticeRepository(db);
    final w = await WritingRepository(practice).open('keep-writing');
    expect(w.outline, 'My outline');
    expect(w.audience, 'My audience');
    expect(w.nextAction, 'Keep my next action');
    expect(
      (await practice.load('keep-writing')).session.snapshot,
      writingExercise.snapshot,
    );
    expect((await practice.load('keep-writing')).response.id, 'keep-response');
    expect(
      (await practice.load('keep-writing')).response.body,
      'My original writing',
    );
    expect(await db.select(db.readingWorkspaces).get(), isEmpty);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    expect(
      (await db.customSelect('PRAGMA user_version').getSingle())
          .data
          .values
          .single,
      9,
    );
  });
}
