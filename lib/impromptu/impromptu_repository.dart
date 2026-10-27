import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exercises.dart';
import '../providers.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'impromptu_content.dart';

final impromptuRepositoryProvider = Provider(
  (ref) => ImpromptuRepository(ref.watch(repositoryProvider)),
);

class ImpromptuAttempt {
  ImpromptuAttempt(this.detail, this.workspace);
  final SessionDetail detail;
  final ImpromptuWorkspace workspace;
  bool get closed => isTerminal(detail.session.status);
  List<int> get targets =>
      validateImpromptuTargets(jsonDecode(workspace.preset)['targets']);
}

class ImpromptuRepository {
  ImpromptuRepository(this.practice, {Random? random})
    : random = random ?? Random.secure();
  final PracticeRepository practice;
  final Random random;
  AppDatabase get db => practice.db;
  Future<ImpromptuAttempt> load(String id) async => ImpromptuAttempt(
    await practice.load(id),
    await (db.select(
      db.impromptuWorkspaces,
    )..where((w) => w.sessionId.equals(id))).getSingle(),
  );

  void _setup(String key, String kind, String preset, List<int> targets) {
    if (key.isEmpty ||
        key.length > 100 ||
        !{'recorded', 'unrecorded'}.contains(kind) ||
        preset.isEmpty ||
        preset.length > 100) {
      throw ArgumentError('Invalid challenge setup');
    }
    validateImpromptuTargets(targets);
  }

  // Selection and reservation commit together; the same request never consumes two questions.
  Future<String> start(
    List<Exercise> pool,
    String requestKey,
    String kind,
    String preset,
    List<int> targets,
    DateTime now,
  ) => db.transaction(() async {
    _setup(requestKey, kind, preset, targets);
    final existing = await (db.select(
      db.impromptuWorkspaces,
    )..where((w) => w.requestKey.equals(requestKey))).getSingleOrNull();
    if (existing != null) {
      return existing.sessionId;
    }
    final validated =
        pool.map((e) => Exercise.fromSnapshot(e.snapshot)).toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    if (validated.isEmpty ||
        validated.any((e) => !e.content.containsKey('impromptu')) ||
        validated.map((e) => e.id).toSet().length != validated.length) {
      throw ArgumentError('Choose a nonempty question pool');
    }
    final key = jsonEncode(
      validated.map((e) => [e.id, e.version, e.packVersion]).toList(),
    );
    final queue = await (db.select(
      db.impromptuQueues,
    )..where((q) => q.poolKey.equals(key))).getSingleOrNull();
    final ids = validated.map((e) => e.id).toList();
    var remaining = queue == null
        ? <String>[]
        : (jsonDecode(queue.remaining) as List).cast<String>();
    if (remaining.toSet().length != remaining.length ||
        remaining.any((id) => !ids.contains(id))) {
      throw StateError(
        'Saved question queue is invalid. It has not been reset.',
      );
    }
    if (remaining.isEmpty) {
      remaining = [...ids]..shuffle(random);
      if (remaining.length > 1 && remaining.first == queue?.lastQuestion) {
        final first = remaining.removeAt(0);
        remaining.add(first);
      }
    }
    final selected = remaining.removeAt(0);
    final id = await _create(
      validated.singleWhere((e) => e.id == selected),
      requestKey,
      kind,
      preset,
      targets,
      now,
    );
    await db
        .into(db.impromptuQueues)
        .insertOnConflictUpdate(
          ImpromptuQueuesCompanion.insert(
            poolKey: key,
            remaining: jsonEncode(remaining),
            lastQuestion: selected,
          ),
        );
    return id;
  });

  Future<String> _create(
    Exercise e,
    String key,
    String kind,
    String preset,
    List<int> targets,
    DateTime now, {
    String? parent,
    String improvement = '',
  }) async {
    final id = await practice.createDraft(e, now);
    await db
        .into(db.impromptuWorkspaces)
        .insert(
          ImpromptuWorkspacesCompanion.insert(
            sessionId: id,
            requestKey: key,
            responseKind: kind,
            preset: jsonEncode({'name': preset, 'targets': targets}),
            parentSessionId: Value(parent),
            improvement: Value(improvement),
          ),
        );
    return id;
  }

  Future<String> retry(String parent, String improvement, DateTime now) =>
      db.transaction(() async {
        final old = await load(parent);
        if (old.detail.session.status != 'completed') {
          throw StateError('Complete this response before retrying.');
        }
        final existing = await (db.select(
          db.impromptuWorkspaces,
        )..where((w) => w.parentSessionId.equals(parent))).getSingleOrNull();
        if (existing != null) {
          return existing.sessionId;
        }
        if (improvement.trim().isEmpty || improvement.length > 4000) {
          throw ArgumentError('Name one improvement for your retry.');
        }
        return _create(
          old.detail.exercise,
          stableId(),
          old.workspace.responseKind,
          jsonDecode(old.workspace.preset)['name'] as String,
          old.targets,
          now,
          parent: parent,
          improvement: improvement.trim(),
        );
      });

  Future<void> save(
    String id,
    String preparation,
    String response,
    bool scaffoldEnabled,
    Map<String, String> scaffold,
    DateTime now,
  ) => db.transaction(() async {
    final a = await load(id);
    if (a.closed || a.workspace.viewStep == 'reveal') {
      throw StateError('This response is not editable.');
    }
    if (preparation.length > 20000 ||
        scaffold.keys
            .toSet()
            .difference(impromptuScaffold.keys.toSet())
            .isNotEmpty ||
        scaffold.values.any((v) => v.length > 10000)) {
      throw ArgumentError('Invalid preparation or scaffold');
    }
    await practice.saveResponse(id, response, now);
    await (db.update(
      db.impromptuWorkspaces,
    )..where((w) => w.sessionId.equals(id))).write(
      ImpromptuWorkspacesCompanion(
        preparation: Value(preparation),
        scaffoldEnabled: Value(scaffoldEnabled),
        scaffold: Value(jsonEncode(scaffold)),
      ),
    );
  });

  Future<void> advance(
    String id,
    String expected,
    DateTime now,
  ) => db.transaction(() async {
    final a = await load(id);
    if (a.closed || a.workspace.viewStep != expected) {
      return;
    }
    if (a.detail.session.status == 'running') {
      throw StateError('Checkpoint and stop timing before changing stages.');
    }
    final pending = await (db.select(
      db.audioRecordings,
    )..where((r) => r.sessionId.equals(id) & r.state.equals('pending'))).get();
    if (pending.isNotEmpty) {
      throw StateError('Finalize the response recording first.');
    }
    final next = switch (expected) {
      'reveal' => 'prepare',
      'prepare' => 'respond',
      'respond' => 'review',
      _ => throw StateError('Invalid stage'),
    };
    await (db.update(db.impromptuWorkspaces)
          ..where((w) => w.sessionId.equals(id)))
        .write(ImpromptuWorkspacesCompanion(viewStep: Value(next)));
    if (next == 'review') {
      await practice.transition(
        id,
        PracticeStatus.interrupted,
        now,
        nextStage: PracticeStage.reflect,
      );
      await practice.transition(id, PracticeStatus.completed, now);
    } else {
      await practice.transition(
        id,
        PracticeStatus.interrupted,
        now,
        nextStage: next == 'prepare'
            ? PracticeStage.prepare
            : PracticeStage.respond,
      );
    }
  });

  Future<void> review(
    String id,
    Map<String, dynamic> assessments,
    String reflection,
    int? confidence,
    DateTime now,
  ) => db.transaction(() async {
    final a = await load(id);
    if (a.detail.session.status != 'completed') {
      throw StateError('Finish the response before review.');
    }
    if (reflection.length > 10000 ||
        confidence != null && (confidence < 1 || confidence > 5) ||
        assessments.keys
            .toSet()
            .difference(impromptuCriteria.toSet())
            .isNotEmpty) {
      throw ArgumentError('Invalid review');
    }
    for (final v in assessments.values) {
      if (v is! Map<String, dynamic> ||
          v.keys.toSet().difference({'rating', 'note'}).isNotEmpty ||
          v['note'] is! String ||
          (v['note'] as String).length > 4000 ||
          v['rating'] != null &&
              !{'emerging', 'developing', 'effective'}.contains(v['rating'])) {
        throw ArgumentError('Invalid human assessment');
      }
    }
    await (db.update(
      db.impromptuWorkspaces,
    )..where((w) => w.sessionId.equals(id))).write(
      ImpromptuWorkspacesCompanion(
        assessments: Value(jsonEncode(assessments)),
        reflection: Value(reflection),
        confidence: Value(confidence),
      ),
    );
    await practice.saveReview(id, reflection, ReviewStatus.reviewed, now);
  });
}
