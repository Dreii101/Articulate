import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'advanced_rules.dart';
export 'advanced_rules.dart';

import '../debate/debate_repository.dart';
import '../exercises.dart';
import '../impromptu/impromptu_repository.dart';
import '../memory/memory_repository.dart';
import '../providers.dart';
import '../writing/writing_repository.dart';
import '../reading/reading_repository.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';

final advancedRepositoryProvider = Provider(
  (ref) => AdvancedRepository(ref.watch(repositoryProvider)),
);
final advancedChangesProvider = StreamProvider((ref) {
  final db = ref.watch(repositoryProvider).db;
  return db
      .customSelect(
        'SELECT id FROM practice_sessions',
        readsFrom: {
          db.practiceSessions,
          db.customExercises,
          db.practiceContexts,
          db.recallSchedules,
          db.memoryWorkspaces,
          db.memoryVersions,
          db.appSettings,
        },
      )
      .watch();
});

class DueReview {
  DueReview(this.schedule, this.workspace, this.title, this.newerVersion);
  final RecallSchedule schedule;
  final MemoryWorkspace workspace;
  final String title;
  final bool newerVersion;
  String get date => schedule.overrideDate ?? schedule.recommendedDate;
  bool due(String today) => !schedule.paused && date.compareTo(today) <= 0;
}

class AdvancedRepository {
  AdvancedRepository(this.practice);
  final PracticeRepository practice;
  AppDatabase get db => practice.db;
  Future<List<int>> intervals() async {
    final row = await (db.select(
      db.appSettings,
    )..where((s) => s.key.equals('reviewIntervals'))).getSingleOrNull();
    return row == null
        ? defaultIntervals
        : validateIntervals(jsonDecode(row.value));
  }

  Future<void> saveIntervals(List<int> days) => practice.saveSetting(
    'reviewIntervals',
    jsonEncode(validateIntervals(days)),
  );
  Future<List<CustomExercise>> customVersions() => (db.select(
    db.customExercises,
  )..orderBy([(e) => OrderingTerm.desc(e.version)])).get();
  Future<CustomExercise> saveCustom(
    String source,
    DateTime now, {
    String? id,
  }) => db.transaction(() async {
    final input = Exercise.fromSnapshot(source);
    validateCustomExercise(input);
    final previous = id == null
        ? <CustomExercise>[]
        : await (db.select(
            db.customExercises,
          )..where((e) => e.id.equals(id))).get();
    if (id != null && previous.isEmpty) {
      throw StateError('Custom exercise unavailable.');
    }
    previous.sort((a, b) => b.version.compareTo(a.version));
    final key = id ?? 'custom-${stableId()}',
        version = previous.isEmpty ? 1 : previous.first.version + 1;
    if (previous.isNotEmpty &&
        Exercise.fromSnapshot(previous.first.snapshot).module != input.module) {
      throw const FormatException('Keep the module when editing a version.');
    }
    final document = input.document;
    final content =
        (document['exercises'] as List).single as Map<String, dynamic>;
    content['id'] = key;
    content['version'] = version;
    if (previous.isNotEmpty) {
      final oldRubric =
          Exercise.fromSnapshot(previous.first.snapshot).content['rubric']
              as Map;
      final rubric = content['rubric'] as Map;
      if (jsonEncode(oldRubric) != jsonEncode(rubric)) {
        rubric['version'] = (oldRubric['version'] as int) + 1;
      }
    }
    document['packId'] = 'custom-local';
    document['packVersion'] = version;
    final validated = Exercise.fromSnapshot(jsonEncode(document));
    await db
        .into(db.customExercises)
        .insert(
          CustomExercisesCompanion.insert(
            id: key,
            version: version,
            snapshot: validated.snapshot,
            createdUtcMs: now.toUtc().millisecondsSinceEpoch,
          ),
        );
    return (db.select(
      db.customExercises,
    )..where((e) => e.id.equals(key) & e.version.equals(version))).getSingle();
  });

  Future<String> start(
    Exercise exercise,
    String requestKey,
    DateTime now, {
    String label = 'practice',
    String conditions = '',
    String target = '',
    String? parent,
  }) => db.transaction(() async {
    final existing = await (db.select(
      db.practiceContexts,
    )..where((c) => c.requestKey.equals(requestKey))).getSingleOrNull();
    if (existing != null) return existing.sessionId;
    if (!practiceLabels.contains(label) ||
        requestKey.isEmpty ||
        requestKey.length > 100 ||
        conditions.length > 4000 ||
        target.length > 10000 ||
        label == 'benchmark' && conditions.trim().isEmpty) {
      throw const FormatException(
        'Benchmark practice needs a named condition; keep notes within the field limits.',
      );
    }
    final e = Exercise.fromSnapshot(exercise.snapshot);
    if (label == 'unfamiliar') {
      final seen = await (db.select(
        db.practiceSessions,
      )..where((s) => s.exerciseId.equals(e.id))).get();
      if (seen.isNotEmpty || e.id.startsWith('custom-') || parent != null) {
        throw const FormatException(
          'This task is already practiced or user-authored. Choose Practice or Benchmark. Unfamiliar is a self-report, not proof of novelty.',
        );
      }
    }
    if (parent != null) {
      final old = await practice.load(parent);
      if (old.session.status != 'completed' ||
          old.exercise.snapshot != e.snapshot ||
          target.trim().isEmpty) {
        throw const FormatException(
          'A targeted retry needs completed source work and a saved target.',
        );
      }
      final prior = await (db.select(
        db.practiceContexts,
      )..where((c) => c.parentSessionId.equals(parent))).getSingleOrNull();
      if (prior != null) {
        if (prior.label != label ||
            prior.conditions != conditions.trim() ||
            prior.target != target.trim()) {
          throw const FormatException(
            'This source already has a linked retry with saved conditions. Open that retry in History; complete it before starting its next retry.',
          );
        }
        return prior.sessionId;
      }
      if (e.content.containsKey('impromptu') &&
          await (db.select(db.impromptuWorkspaces)
                    ..where((w) => w.parentSessionId.equals(parent)))
                  .getSingleOrNull() !=
              null) {
        throw const FormatException(
          'This source already has an Impromptu retry. Open it from the original module or History; its saved conditions will not be rewritten.',
        );
      }
    }
    String id;
    if (e.content.containsKey('memory')) {
      if (parent == null) {
        throw const FormatException('Choose a saved recall to retry.');
      }
      final w = await MemoryRepository(practice).workspace(parent);
      id = await MemoryRepository(practice).createAttempt(
        w.versionId,
        w.sectionId,
        w.mode,
        w.recallKind,
        w.cueStage,
        now: now,
      );
    } else if (e.content.containsKey('impromptu')) {
      id = parent == null
          ? await ImpromptuRepository(practice)
                .start([e], requestKey, 'unrecorded', 'Untimed', [0, 0], now)
          : await ImpromptuRepository(practice).retry(parent, target, now);
    } else if (e.content.containsKey('debate')) {
      final old = parent == null
          ? null
          : await DebateRepository(practice).load(parent);
      id = await DebateRepository(practice).create(
        e,
        old?.workspace.position ?? 'for',
        old?.workspace.responseKind ?? 'written',
        old == null
            ? 'Untimed'
            : jsonDecode(old.workspace.preset)['name'] as String,
        old?.targets ?? [0, 0, 0, 0, 0],
        now,
      );
    } else {
      id = await practice.createDraft(e, now);
    }
    if (parent != null && e.module == 'writing') {
      final old = await (db.select(
        db.writingWorkspaces,
      )..where((w) => w.sessionId.equals(parent))).getSingleOrNull();
      if (old != null) {
        await WritingRepository(practice).open(id);
        await (db.update(
          db.writingWorkspaces,
        )..where((w) => w.sessionId.equals(id))).write(
          WritingWorkspacesCompanion(
            audience: Value(old.audience),
            purpose: Value(old.purpose),
            reviewRubric: Value(old.reviewRubric),
          ),
        );
      }
    }
    if (parent != null && e.content.containsKey('reading')) {
      final old = await (db.select(
        db.readingWorkspaces,
      )..where((w) => w.sessionId.equals(parent))).getSingleOrNull();
      if (old != null) {
        await ReadingRepository(practice).open(id);
        await (db.update(
          db.readingWorkspaces,
        )..where((w) => w.sessionId.equals(id))).write(
          ReadingWorkspacesCompanion(hidePassage: Value(old.hidePassage)),
        );
      }
    }
    if (parent != null && e.content.containsKey('impromptu')) {
      final old = await ImpromptuRepository(practice).load(parent);
      await (db.update(
        db.impromptuWorkspaces,
      )..where((w) => w.sessionId.equals(id))).write(
        ImpromptuWorkspacesCompanion(
          scaffoldEnabled: Value(old.workspace.scaffoldEnabled),
        ),
      );
    }
    await db
        .into(db.practiceContexts)
        .insert(
          PracticeContextsCompanion.insert(
            sessionId: id,
            requestKey: requestKey,
            parentSessionId: Value(parent),
            label: label,
            conditions: conditions.trim(),
            target: target.trim(),
          ),
        );
    return id;
  });

  Future<List<DueReview>> queue() async {
    final schedules =
        await (db.select(db.recallSchedules)..orderBy([
              (s) => OrderingTerm.desc(s.sequence),
              (s) => OrderingTerm.desc(s.sessionId),
            ]))
            .get();
    final seen = <String>{}, result = <DueReview>[];
    for (final schedule in schedules) {
      final w = await MemoryRepository(practice).workspace(schedule.sessionId);
      if (!seen.add('${w.versionId}/${w.sectionId}/${w.mode}')) continue;
      final v = await (db.select(
        db.memoryVersions,
      )..where((v) => v.id.equals(w.versionId))).getSingle();
      final versions = await MemoryRepository(practice).versions(v.speechId);
      result.add(
        DueReview(
          schedule,
          w,
          (await practice.load(w.sessionId)).exercise.title,
          versions.first.versionNumber > v.versionNumber,
        ),
      );
    }
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  Future<RecallSchedule> observe(
    String sessionId,
    String observation,
    DateTime now,
  ) => db.transaction(() async {
    final existing = await (db.select(
      db.recallSchedules,
    )..where((s) => s.sessionId.equals(sessionId))).getSingleOrNull();
    if (existing != null) return existing;
    if (!recallObservations.contains(observation) ||
        (await practice.load(sessionId)).session.status != 'completed') {
      throw const FormatException(
        'Complete recall and explicitly choose an observation.',
      );
    }
    final w = await MemoryRepository(practice).workspace(sessionId);
    final previous = (await queue())
        .where(
          (r) =>
              r.workspace.versionId == w.versionId &&
              r.workspace.sectionId == w.sectionId &&
              r.workspace.mode == w.mode,
        )
        .firstOrNull;
    final days = await intervals();
    final index = observation == 'independent' && previous != null
        ? (previous.schedule.intervalIndex + 1).clamp(0, days.length - 1)
        : 0;
    final localDate = calendarDate(now);
    final sequence =
        (await db
                .customSelect(
                  'SELECT COALESCE(MAX(sequence), 0) AS n FROM recall_schedules',
                )
                .getSingle())
            .read<int>('n') +
        1;
    await db
        .into(db.recallSchedules)
        .insert(
          RecallSchedulesCompanion.insert(
            sessionId: sessionId,
            observation: observation,
            sequence: sequence,
            observedLocalDate: localDate,
            originalOffsetMinutes: now.timeZoneOffset.inMinutes,
            observedUtcMs: now.toUtc().millisecondsSinceEpoch,
            intervalIndex: index,
            intervalDays: days[index],
            recommendedDate: plusDays(localDate, days[index]),
          ),
        );
    return (db.select(
      db.recallSchedules,
    )..where((s) => s.sessionId.equals(sessionId))).getSingle();
  });
  Future<void> override(
    String sessionId, {
    String? date,
    required bool paused,
  }) async {
    if (date != null) parseCalendarDate(date);
    await (db.update(
      db.recallSchedules,
    )..where((s) => s.sessionId.equals(sessionId))).write(
      RecallSchedulesCompanion(
        overrideDate: Value(date),
        paused: Value(paused),
      ),
    );
  }
}

void validateCustomExercise(Exercise e) {
  if (e.module == 'memory') {
    throw const FormatException(
      'Create and version speeches in Memory Trainer.',
    );
  }
  if ({'writing', 'reading', 'debate', 'impromptu'}.contains(e.module) &&
      !e.content.containsKey(e.module)) {
    throw const FormatException(
      'Custom content needs the complete module structure. Start from a template.',
    );
  }
}

// Run after importing into staging, before any live-library replacement.
Future<void> validateAdvancedLibrary(AppDatabase db) async {
  Never invalid() =>
      throw const FormatException('Invalid advanced practice records.');
  final practice = PracticeRepository(db);
  final versions = <String, List<int>>{};
  final snapshots = <String, String>{};
  for (final row in await db.select(db.customExercises).get()) {
    (versions[row.id] ??= []).add(row.version);
    snapshots['${row.id}/${row.version}'] = row.snapshot;
    final e = Exercise.fromSnapshot(row.snapshot);
    validateCustomExercise(e);
    if (!RegExp(r'^custom-[a-f0-9]{32}$').hasMatch(row.id) ||
        e.id != row.id ||
        e.version != row.version ||
        e.document['packId'] != 'custom-local' ||
        e.packVersion != row.version) {
      invalid();
    }
  }
  for (final numbers in versions.values) {
    numbers.sort();
    for (var i = 0; i < numbers.length; i++) {
      if (numbers[i] != i + 1) invalid();
    }
  }
  for (final session in await db.select(db.practiceSessions).get()) {
    if (session.exerciseId.startsWith('custom-') &&
        snapshots['${session.exerciseId}/${session.exerciseVersion}'] !=
            session.snapshot) {
      invalid();
    }
  }
  final contexts = {
    for (final c in await db.select(db.practiceContexts).get()) c.sessionId: c,
  };
  for (final c in contexts.values) {
    if (!practiceLabels.contains(c.label) ||
        c.requestKey.isEmpty ||
        c.requestKey.length > 100 ||
        c.conditions.length > 4000 ||
        c.target.length > 10000 ||
        c.label == 'benchmark' && c.conditions.trim().isEmpty) {
      invalid();
    }
    if (c.parentSessionId != null) {
      final parent = await practice.load(c.parentSessionId!);
      final child = await practice.load(c.sessionId);
      if (parent.session.status != 'completed' ||
          parent.session.snapshot != child.session.snapshot ||
          c.target.trim().isEmpty ||
          c.label == 'unfamiliar') {
        invalid();
      }
    }
    final seen = <String>{c.sessionId};
    var at = c.parentSessionId;
    while (at != null) {
      if (!seen.add(at)) invalid();
      at = contexts[at]?.parentSessionId;
    }
  }
  for (final r in await db.select(db.recallSchedules).get()) {
    final detail = await practice.load(r.sessionId);
    if (r.sequence < 1 ||
        detail.session.status != 'completed' ||
        (await (db.select(db.memoryWorkspaces)
                  ..where((w) => w.sessionId.equals(r.sessionId)))
                .getSingleOrNull()) ==
            null ||
        !recallObservations.contains(r.observation) ||
        r.intervalIndex < 0 ||
        r.intervalIndex > 11 ||
        r.intervalDays < 1 ||
        r.intervalDays > 365 ||
        r.originalOffsetMinutes.abs() > 1440 ||
        plusDays(r.observedLocalDate, r.intervalDays) != r.recommendedDate ||
        calendarDate(
              DateTime.fromMillisecondsSinceEpoch(
                r.observedUtcMs,
                isUtc: true,
              ).add(Duration(minutes: r.originalOffsetMinutes)),
            ) !=
            r.observedLocalDate) {
      invalid();
    }
    if (r.overrideDate != null) parseCalendarDate(r.overrideDate!);
  }
}
