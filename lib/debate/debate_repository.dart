import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exercises.dart';
import '../providers.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'debate_content.dart';

final debateRepositoryProvider = Provider(
  (ref) => DebateRepository(ref.watch(repositoryProvider)),
);

class DebateRound {
  DebateRound(this.detail, this.workspace, this.stages);
  final SessionDetail detail;
  final DebateWorkspace workspace;
  final List<DebateStage> stages;
  bool get closed => isTerminal(detail.session.status);
  DebateStage get active => stages[workspace.currentStage];
  List<int> get targets =>
      validateDebateTargets(jsonDecode(workspace.preset)['targets']);
  int get allocatedMs => stages
      .where((s) => s.status == 'completed' || s.status == 'skipped')
      .fold(0, (n, s) => n + s.elapsedMs);
  int elapsed(String key, int total) =>
      stages.singleWhere((s) => s.stageKey == key).status == 'active'
      ? (total - allocatedMs).clamp(0, 1 << 53)
      : stages.singleWhere((s) => s.stageKey == key).elapsedMs;
  Map<String, dynamic> get script =>
      detail.exercise.content['debate'][workspace.position == 'for'
              ? 'against'
              : 'for']
          as Map<String, dynamic>;
}

class DebateRepository {
  DebateRepository(this.practice);
  final PracticeRepository practice;
  AppDatabase get db => practice.db;
  Future<DebateRound> load(String id) async {
    final d = await practice.load(id);
    final w = await (db.select(
      db.debateWorkspaces,
    )..where((w) => w.sessionId.equals(id))).getSingle();
    final rows = await (db.select(
      db.debateStages,
    )..where((s) => s.sessionId.equals(id))).get();
    return DebateRound(d, w, [
      for (final key in debateStageKeys)
        rows.singleWhere((s) => s.stageKey == key),
    ]);
  }

  Future<String> create(
    Exercise exercise,
    String position,
    String kind,
    String preset,
    List<int> targets,
    DateTime now,
  ) => db.transaction(() async {
    final e = Exercise.fromSnapshot(exercise.snapshot);
    if (!e.content.containsKey('debate') ||
        !{'for', 'against'}.contains(position) ||
        !{'written', 'recorded'}.contains(kind) ||
        preset.isEmpty ||
        preset.length > 100) {
      throw ArgumentError('Invalid debate setup');
    }
    validateDebateTargets(targets);
    final id = await practice.createDraft(e, now);
    await db
        .into(db.debateWorkspaces)
        .insert(
          DebateWorkspacesCompanion.insert(
            sessionId: id,
            position: position,
            responseKind: kind,
            preset: jsonEncode({'name': preset, 'targets': targets}),
          ),
        );
    for (final key in debateStageKeys) {
      await db
          .into(db.debateStages)
          .insert(
            DebateStagesCompanion.insert(
              sessionId: id,
              stageKey: key,
              status: key == 'preparation' ? 'active' : 'pending',
            ),
          );
    }
    return id;
  });
  Future<void> saveFields(
    String id,
    String key,
    Map<String, String> fields,
    DateTime now,
  ) => db.transaction(() async {
    final round = await load(id);
    if (round.closed ||
        round.active.stageKey != key ||
        round.active.status != 'active') {
      throw StateError(
        'This stage is preserved. Continue the current stage or start another round.',
      );
    }
    final allowed = {
      ...debateFields[key]!,
      if (key == 'preparation' || key == 'rebuttal') 'supportKind',
    };
    if (fields.keys.toSet().difference(allowed).isNotEmpty ||
        fields.values.any((v) => v.length > 20000) ||
        fields.containsKey('supportKind') &&
            !supportKinds.contains(fields['supportKind'])) {
      throw ArgumentError('Invalid argument fields');
    }
    await (db.update(db.debateStages)
          ..where((s) => s.sessionId.equals(id) & s.stageKey.equals(key)))
        .write(DebateStagesCompanion(fields: Value(jsonEncode(fields))));
    await (db.update(db.practiceSessions)..where((s) => s.id.equals(id))).write(
      PracticeSessionsCompanion(
        updatedUtcMs: Value(now.toUtc().millisecondsSinceEpoch),
      ),
    );
  });
  // expectedKey makes double clicks and delayed actions idempotent without skipping the next stage.
  Future<void> advance(
    String id,
    String expectedKey,
    bool skip,
    DateTime now,
  ) => db.transaction(() async {
    final r = await load(id);
    if (r.closed || r.active.stageKey != expectedKey) return;
    if (r.detail.session.status == 'running') {
      throw StateError('Stop/checkpoint timing before advancing.');
    }
    if (await (db.select(
              db.audioRecordings,
            )..where((a) => a.sessionId.equals(id) & a.state.equals('pending')))
            .getSingleOrNull() !=
        null) {
      throw StateError('Finalize the active recording before advancing.');
    }
    final index = r.workspace.currentStage;
    await (db.update(db.debateStages)..where(
          (s) => s.sessionId.equals(id) & s.stageKey.equals(expectedKey),
        ))
        .write(
          DebateStagesCompanion(
            status: Value(skip ? 'skipped' : 'completed'),
            elapsedMs: Value(r.elapsed(expectedKey, r.detail.elapsedMs)),
            finishedUtcMs: Value(now.toUtc().millisecondsSinceEpoch),
          ),
        );
    if (index == 4) {
      await practice.transition(id, PracticeStatus.completed, now);
      return;
    }
    await (db.update(db.debateWorkspaces)..where((w) => w.sessionId.equals(id)))
        .write(DebateWorkspacesCompanion(currentStage: Value(index + 1)));
    await (db.update(db.debateStages)..where(
          (s) =>
              s.sessionId.equals(id) &
              s.stageKey.equals(debateStageKeys[index + 1]),
        ))
        .write(const DebateStagesCompanion(status: Value('active')));
    await practice.transition(
      id,
      PracticeStatus.interrupted,
      now,
      nextStage: index + 1 == 4 ? PracticeStage.reflect : PracticeStage.respond,
    );
  });
  Future<void> review(
    String id,
    Map<String, dynamic> assessments,
    String note,
    DateTime now,
  ) => db.transaction(() async {
    final r = await load(id);
    if (r.detail.session.status != 'completed') {
      throw StateError('Finish the round before self-review.');
    }
    if (note.length > 10000 ||
        assessments.keys
            .toSet()
            .difference(debateCriteria.toSet())
            .isNotEmpty) {
      throw ArgumentError('Invalid review');
    }
    for (final v in assessments.values) {
      if (v is! Map<String, dynamic> ||
          v.keys.toSet().difference({'rating', 'note', 'anchor'}).isNotEmpty ||
          v['rating'] != null &&
              !{'emerging', 'developing', 'effective'}.contains(v['rating']) ||
          v['note'] is! String ||
          (v['note'] as String).length > 4000) {
        throw ArgumentError('Invalid criterion');
      }
      final a = v['anchor'];
      if (a == null) continue;
      if (a is! Map<String, dynamic>) throw ArgumentError('Invalid anchor');
      if (a['kind'] == 'text') {
        if (a.keys.toSet().difference({
              'kind',
              'stage',
              'field',
              'start',
              'end',
              'quote',
            }).isNotEmpty ||
            !debateStageKeys.contains(a['stage']) ||
            !debateFields[a['stage']]!.contains(a['field'])) {
          throw ArgumentError('Invalid text reference');
        }
        final body =
            (jsonDecode(
                      r.stages
                          .singleWhere((s) => s.stageKey == a['stage'])
                          .fields,
                    )[a['field']] ??
                    '')
                as String;
        final start = a['start'], end = a['end'];
        if (start is! int ||
            end is! int ||
            start < 0 ||
            end <= start ||
            end > body.length ||
            body.substring(start, end) != a['quote']) {
          throw ArgumentError('Quote does not match this saved stage');
        }
      } else if (a['kind'] == 'audio') {
        if (a.keys.toSet().difference({
              'kind',
              'recordingId',
              'positionMs',
            }).isNotEmpty ||
            a['recordingId'] is! String ||
            a['positionMs'] is! int) {
          throw ArgumentError('Invalid audio reference');
        }
        final row =
            await (db.select(db.audioRecordings)
                  ..where((s) => s.id.equals(a['recordingId'] as String)))
                .getSingleOrNull();
        if (row == null ||
            row.sessionId != id ||
            row.microphoneCheck ||
            !{'opening', 'rebuttal'}.contains(row.contextKey) ||
            a['positionMs'] < 0 ||
            a['positionMs'] > row.durationMs) {
          throw ArgumentError('Audio anchor must belong to this round');
        }
      } else {
        throw ArgumentError('Unknown evidence reference');
      }
    }
    await (db.update(
      db.debateWorkspaces,
    )..where((w) => w.sessionId.equals(id))).write(
      DebateWorkspacesCompanion(
        assessments: Value(jsonEncode(assessments)),
        reviewNote: Value(note),
      ),
    );
    await practice.saveReview(id, note, ReviewStatus.reviewed, now);
  });
}
