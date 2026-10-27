import 'dart:convert';

import 'package:drift/drift.dart';

import '../storage/database.dart';
import '../storage/practice_repository.dart';

const writingCriteria = ['purpose', 'organization', 'support', 'clarity'];
const writingRatings = ['emerging', 'developing', 'effective'];

class WritingRepository {
  WritingRepository(this.practice);
  final PracticeRepository practice;
  AppDatabase get db => practice.db;

  Future<WritingWorkspace> open(String id) => db.transaction(() async {
    final d = await practice.load(id);
    if (d.session.moduleId != 'writing') {
      throw ArgumentError('Not a writing attempt');
    }
    final existing = await (db.select(
      db.writingWorkspaces,
    )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
    if (existing != null) return existing;
    final guidance = d.exercise.content['writing'] as Map?;
    // Legacy attempts keep their old exercise snapshot; freeze a separate writing rubric.
    final rubric = guidance != null
        ? d.exercise.content['rubric']
        : {
            'id': 'writing-legacy-self-review',
            'version': 1,
            'criteria': [
              for (final k in writingCriteria)
                {
                  'id': k,
                  'label': k[0].toUpperCase() + k.substring(1),
                  'description': 'Consider how $k helps this reader.',
                  'anchors': {
                    'emerging':
                        'The $k needs attention before the reader can follow the draft.',
                    'developing':
                        'The $k is partly effective; identify one specific improvement.',
                    'effective':
                        'The $k consistently helps the intended reader.',
                  },
                },
            ],
          };
    await db
        .into(db.writingWorkspaces)
        .insert(
          WritingWorkspacesCompanion.insert(
            sessionId: id,
            rootSessionId: id,
            versionNumber: 1,
            reviewRubric: jsonEncode(rubric),
            legacyReviewNotes: Value(
              guidance == null ? d.review?.notes ?? '' : '',
            ),
            audience:
                guidance?['audience'] as String? ??
                'Choose the reader you want to reach.',
            purpose: guidance?['purpose'] as String? ?? d.exercise.focus,
            viewStep: Value(isTerminal(d.session.status) ? 'review' : 'brief'),
            updatedUtcMs: d.session.updatedUtcMs,
          ),
        );
    return (db.select(
      db.writingWorkspaces,
    )..where((w) => w.sessionId.equals(id))).getSingle();
  });

  Future<List<WritingWorkspace>> versions(String root) =>
      (db.select(db.writingWorkspaces)
            ..where((w) => w.rootSessionId.equals(root))
            ..orderBy([(w) => OrderingTerm.asc(w.versionNumber)]))
          .get();

  Future<void> save(
    String id, {
    required String outline,
    required String audience,
    required String purpose,
    required String step,
    required Map<String, dynamic> assessments,
    required String nextAction,
    required DateTime now,
  }) => db.transaction(() async {
    final d = await practice.load(id);
    final w = await open(id);
    if (!{'brief', 'outline', 'write', 'review'}.contains(step)) {
      throw ArgumentError('Unknown writing view');
    }
    for (final text in [outline, audience, purpose, nextAction]) {
      if (text.length > PracticeRepository.maxResponseLength) {
        throw ArgumentError('Text too long');
      }
    }
    validateAssessments(assessments, d.response.body);
    if (isTerminal(d.session.status) &&
        (outline != w.outline ||
            audience != w.audience ||
            purpose != w.purpose)) {
      throw StateError(
        'The submitted draft and plan are preserved. Create a revision to edit.',
      );
    }
    await (db.update(
      db.writingWorkspaces,
    )..where((r) => r.sessionId.equals(id))).write(
      WritingWorkspacesCompanion(
        outline: Value(outline),
        audience: Value(audience),
        purpose: Value(purpose),
        viewStep: Value(step),
        assessments: Value(jsonEncode(assessments)),
        nextAction: Value(nextAction),
        updatedUtcMs: Value(now.toUtc().millisecondsSinceEpoch),
      ),
    );
    if (d.session.status == 'completed' &&
        (w.assessments != jsonEncode(assessments) ||
            w.nextAction != nextAction)) {
      await practice.saveReview(
        id,
        jsonEncode({
          'rubric': jsonDecode(w.reviewRubric),
          'assessments': assessments,
          'nextAction': nextAction,
        }),
        ReviewStatus.inProgress,
        now,
      );
    }
  });

  static void validateAssessments(Map<String, dynamic> values, String body) {
    if (values.keys.any((k) => !writingCriteria.contains(k))) {
      throw ArgumentError('Unknown criterion');
    }
    for (final entry in values.entries) {
      final v = entry.value;
      if (v is! Map ||
          v.keys.toSet().difference({
            'rating',
            'evidence',
            'start',
            'end',
          }).isNotEmpty ||
          (v['rating'] != null && !writingRatings.contains(v['rating'])) ||
          v['evidence'] is! String ||
          (v['evidence'] as String).length > 100000) {
        throw ArgumentError('Invalid self-review');
      }
      final start = v['start'], end = v['end'];
      if (start != null || end != null) {
        if (start is! int ||
            end is! int ||
            start < 0 ||
            end <= start ||
            end > body.length ||
            body.substring(start, end) != v['evidence']) {
          throw ArgumentError('Evidence no longer matches this version');
        }
      }
    }
  }

  Future<void> finishReview(String id, DateTime now) =>
      db.transaction(() async {
        final w = await open(id);
        final d = await practice.load(id);
        validateAssessments(
          jsonDecode(w.assessments) as Map<String, dynamic>,
          d.response.body,
        );
        await practice.saveReview(
          id,
          jsonEncode({
            'rubric': jsonDecode(w.reviewRubric),
            'assessments': jsonDecode(w.assessments),
            'nextAction': w.nextAction,
          }),
          ReviewStatus.reviewed,
          now,
        );
      });

  Future<String> createRevision(String parentId, DateTime localNow) =>
      db.transaction(() async {
        final parent = await practice.load(parentId);
        if (parent.session.status != 'completed') {
          throw StateError('Review the draft before creating a revision.');
        }
        final w = await open(parentId);
        final child = await (db.select(
          db.writingWorkspaces,
        )..where((r) => r.parentSessionId.equals(parentId))).getSingleOrNull();
        if (child != null) return child.sessionId;
        final id = await practice.createDraft(parent.exercise, localNow);
        await practice.saveResponse(id, parent.response.body, localNow.toUtc());
        await db
            .into(db.writingWorkspaces)
            .insert(
              WritingWorkspacesCompanion.insert(
                sessionId: id,
                rootSessionId: w.rootSessionId,
                parentSessionId: Value(parentId),
                versionNumber: w.versionNumber + 1,
                reviewRubric: w.reviewRubric,
                outline: Value(w.outline),
                audience: w.audience,
                purpose: w.purpose,
                viewStep: const Value('write'),
                updatedUtcMs: localNow.toUtc().millisecondsSinceEpoch,
              ),
            );
        return id;
      });
}
