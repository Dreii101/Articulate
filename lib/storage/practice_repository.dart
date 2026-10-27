import 'dart:math';

import 'package:drift/drift.dart';

import '../exercises.dart';
import 'database.dart';
import '../advanced/advanced_rules.dart' show validAdvancedSetting;

enum PracticeStatus {
  draft,
  running,
  paused,
  interrupted,
  completed,
  abandoned,
}

enum PracticeStage { prepare, respond, reflect }

enum ReviewStatus { unreviewed, inProgress, reviewed }

bool isTerminal(String status) =>
    status == 'completed' || status == 'abandoned';
String stableId() => List.generate(
  16,
  (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();

class SessionDetail {
  const SessionDetail(this.session, this.response, this.segments, this.review);
  final PracticeSession session;
  final Response response;
  final List<TimingSegment> segments;
  final ReviewRecord? review;
  Exercise get exercise => Exercise.fromSnapshot(session.snapshot);
  ReviewStatus get reviewStatus => review == null
      ? ReviewStatus.unreviewed
      : ReviewStatus.values.byName(review!.status);
  int elapsedFor(PracticeStage stage) => segments
      .where((s) => s.stage == stage.name)
      .fold(0, (sum, s) => sum + s.elapsedMs);
  int get elapsedMs => segments.fold(0, (sum, s) => sum + s.elapsedMs);
  TimingSegment? get openSegment =>
      segments.where((s) => s.endedUtcMs == null).firstOrNull;
}

class PracticeRepository {
  PracticeRepository(this.db);
  final AppDatabase db;
  static const maxResponseLength = 100000;

  Stream<List<PracticeSession>> watchSessions() =>
      (db.select(db.practiceSessions)..orderBy([
            (s) => OrderingTerm.desc(s.updatedUtcMs),
            (s) => OrderingTerm.asc(s.id),
          ]))
          .watch();

  Future<SessionDetail> load(String id) async {
    final session = await (db.select(
      db.practiceSessions,
    )..where((s) => s.id.equals(id))).getSingle();
    Exercise.fromSnapshot(session.snapshot);
    return SessionDetail(
      session,
      await (db.select(
        db.responses,
      )..where((r) => r.sessionId.equals(id))).getSingle(),
      await (db.select(
        db.timingSegments,
      )..where((s) => s.sessionId.equals(id))).get(),
      await (db.select(
        db.reviewRecords,
      )..where((r) => r.sessionId.equals(id))).getSingleOrNull(),
    );
  }

  Future<String> createDraft(
    Exercise exercise,
    DateTime localNow,
  ) => db.transaction(() async {
    // Revalidate the serialized boundary, including rubric and source metadata.
    final validated = Exercise.fromSnapshot(exercise.snapshot);
    final id = stableId();
    final utc = localNow.toUtc().millisecondsSinceEpoch;
    String two(int n) => n.toString().padLeft(2, '0');
    await db
        .into(db.practiceSessions)
        .insert(
          PracticeSessionsCompanion.insert(
            id: id,
            exerciseId: validated.id,
            exerciseVersion: validated.version,
            moduleId: validated.module,
            snapshot: validated.snapshot,
            status: 'draft',
            stage: 'prepare',
            createdUtcMs: utc,
            updatedUtcMs: utc,
            localPracticeDate:
                '${localNow.year}-${two(localNow.month)}-${two(localNow.day)}',
            originalOffsetMinutes: localNow.timeZoneOffset.inMinutes,
          ),
        );
    await db
        .into(db.responses)
        .insert(
          ResponsesCompanion.insert(
            id: stableId(),
            sessionId: id,
            updatedUtcMs: utc,
          ),
        );
    return id;
  });

  Future<void> saveResponse(
    String id,
    String body,
    DateTime utcNow,
  ) => db.transaction(() async {
    if (body.length > maxResponseLength) {
      throw ArgumentError('Response exceeds $maxResponseLength characters');
    }
    final detail = await load(id);
    if (isTerminal(detail.session.status)) {
      throw StateError('This attempt is closed; its response is preserved.');
    }
    final now = utcNow.toUtc().millisecondsSinceEpoch;
    await (db.update(db.responses)..where((r) => r.sessionId.equals(id))).write(
      ResponsesCompanion(body: Value(body), updatedUtcMs: Value(now)),
    );
    await _touch(id, now);
  });

  Future<void> _touch(String id, int utc) async {
    await (db.update(db.practiceSessions)..where((s) => s.id.equals(id))).write(
      PracticeSessionsCompanion(updatedUtcMs: Value(utc)),
    );
  }

  Future<SessionDetail> start(String id, DateTime utcNow) =>
      db.transaction(() async {
        final d = await load(id);
        if (isTerminal(d.session.status)) {
          throw StateError('This attempt is closed.');
        }
        if (d.session.status == 'running') return d;
        final now = utcNow.toUtc().millisecondsSinceEpoch;
        await db
            .into(db.timingSegments)
            .insert(
              TimingSegmentsCompanion.insert(
                id: stableId(),
                sessionId: id,
                stage: d.session.stage,
                startedUtcMs: now,
                checkpointUtcMs: now,
                elapsedMs: 0,
              ),
            );
        await (db.update(
          db.practiceSessions,
        )..where((s) => s.id.equals(id))).write(
          PracticeSessionsCompanion(
            status: const Value('running'),
            updatedUtcMs: Value(now),
            startedUtcMs: Value(d.session.startedUtcMs ?? now),
          ),
        );
        return load(id);
      });

  Future<void> checkpoint(
    String id,
    String segmentId,
    int absoluteElapsedMs,
    DateTime utcNow,
  ) => db.transaction(() async {
    if (absoluteElapsedMs < 0) throw ArgumentError('Negative elapsed time');
    final d = await load(id);
    final segment = d.openSegment;
    if (d.session.status != 'running' ||
        segment == null ||
        segment.id != segmentId) {
      return;
    }
    await (db.update(
      db.timingSegments,
    )..where((s) => s.id.equals(segmentId))).write(
      TimingSegmentsCompanion(
        elapsedMs: Value(max(segment.elapsedMs, absoluteElapsedMs)),
        checkpointUtcMs: Value(utcNow.toUtc().millisecondsSinceEpoch),
      ),
    );
    await _touch(id, utcNow.toUtc().millisecondsSinceEpoch);
  });

  Future<SessionDetail> transition(
    String id,
    PracticeStatus target,
    DateTime utcNow, {
    PracticeStage? nextStage,
  }) => db.transaction(() async {
    final d = await load(id);
    if (isTerminal(d.session.status)) {
      if (d.session.status == target.name && nextStage == null) return d;
      throw StateError('This attempt is already ${d.session.status}.');
    }
    if (target == PracticeStatus.running || target == PracticeStatus.draft) {
      throw ArgumentError('Use start to run a session');
    }
    if (target == PracticeStatus.paused &&
        d.session.status != 'running' &&
        d.session.status != 'paused') {
      throw StateError('Only a running session can be paused.');
    }
    final now = utcNow.toUtc().millisecondsSinceEpoch;
    if (d.openSegment case final segment?) {
      await (db.update(
        db.timingSegments,
      )..where((s) => s.id.equals(segment.id))).write(
        TimingSegmentsCompanion(
          endedUtcMs: Value(now),
          endReason: Value(nextStage == null ? target.name : 'stageChanged'),
        ),
      );
    }
    final status = nextStage == null ? target.name : d.session.status;
    await (db.update(db.practiceSessions)..where((s) => s.id.equals(id))).write(
      PracticeSessionsCompanion(
        status: Value(status),
        stage: Value(nextStage?.name ?? d.session.stage),
        updatedUtcMs: Value(now),
        completedUtcMs: status == 'completed'
            ? Value(now)
            : const Value.absent(),
      ),
    );
    if (nextStage != null && status == 'running') {
      await db
          .into(db.timingSegments)
          .insert(
            TimingSegmentsCompanion.insert(
              id: stableId(),
              sessionId: id,
              stage: nextStage.name,
              startedUtcMs: now,
              checkpointUtcMs: now,
              elapsedMs: 0,
            ),
          );
    }
    return load(id);
  });

  // Startup only: the time after the last committed checkpoint is unknowable.
  Future<void> recoverInterrupted() => db.transaction(() async {
    final running = await (db.select(
      db.practiceSessions,
    )..where((s) => s.status.equals('running'))).get();
    for (final s in running) {
      final segments = await (db.select(
        db.timingSegments,
      )..where((t) => t.sessionId.equals(s.id) & t.endedUtcMs.isNull())).get();
      for (final segment in segments) {
        await (db.update(
          db.timingSegments,
        )..where((t) => t.id.equals(segment.id))).write(
          TimingSegmentsCompanion(
            endedUtcMs: Value(segment.checkpointUtcMs),
            endReason: const Value('interrupted'),
          ),
        );
      }
      await (db.update(db.practiceSessions)..where((t) => t.id.equals(s.id)))
          .write(const PracticeSessionsCompanion(status: Value('interrupted')));
    }
  });

  Future<void> saveReview(
    String id,
    String notes,
    ReviewStatus status,
    DateTime utcNow,
  ) => db.transaction(() async {
    if (notes.length > maxResponseLength || status == ReviewStatus.unreviewed) {
      throw ArgumentError('Invalid review');
    }
    final d = await load(id);
    if (d.session.status != 'completed') {
      throw StateError('Complete the attempt before reviewing.');
    }
    await db
        .into(db.reviewRecords)
        .insertOnConflictUpdate(
          ReviewRecordsCompanion.insert(
            id: d.review?.id ?? stableId(),
            sessionId: id,
            status: status.name,
            notes: notes,
            updatedUtcMs: utcNow.toUtc().millisecondsSinceEpoch,
          ),
        );
  });

  Stream<Map<String, String>> watchSettings() => db
      .select(db.appSettings)
      .watch()
      .map((rows) => {for (final row in rows) row.key: row.value});
  Future<void> saveSetting(String key, String value) async {
    final valid = key == 'theme'
        ? {'system', 'light', 'dark'}.contains(value)
        : key == 'reduceMotion'
        ? {'true', 'false'}.contains(value)
        : validAdvancedSetting(key, value);
    if (!valid) throw ArgumentError('Invalid setting');
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }
}
