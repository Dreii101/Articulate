import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exercises.dart';
import '../providers.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'memory_document.dart';

final memoryRepositoryProvider = Provider(
  (ref) => MemoryRepository(ref.watch(repositoryProvider)),
);
final memorySpeechesProvider = StreamProvider((ref) {
  final db = ref.watch(repositoryProvider).db;
  return (db.select(
    db.memorySpeeches,
  )..orderBy([(s) => OrderingTerm.desc(s.updatedUtcMs)])).watch();
});
final memoryFlagsProvider = StreamProvider((ref) {
  final db = ref.watch(repositoryProvider).db;
  return (db.select(
    db.memoryWorkspaces,
  )..where((w) => w.laterReview.equals(true))).watch();
});

class MemoryRepository {
  MemoryRepository(this.practice);
  final PracticeRepository practice;
  AppDatabase get db => practice.db;
  Future<String> saveDraft(String? id, Map<String, dynamic> value) async {
    final document = MemoryDocument.parse(value, draft: true);
    final key = id ?? stableId();
    await db
        .into(db.memorySpeeches)
        .insertOnConflictUpdate(
          MemorySpeechesCompanion.insert(
            id: key,
            draft: document.json,
            updatedUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
    return key;
  }

  Future<MemorySpeech> speech(String id) =>
      (db.select(db.memorySpeeches)..where((s) => s.id.equals(id))).getSingle();
  Future<List<MemoryVersion>> versions(String id) =>
      (db.select(db.memoryVersions)
            ..where((v) => v.speechId.equals(id))
            ..orderBy([(v) => OrderingTerm.desc(v.versionNumber)]))
          .get();
  Future<MemoryVersion> publish(String id) => db.transaction(() async {
    final doc = MemoryDocument.parse(jsonDecode((await speech(id)).draft));
    final previous = await versions(id);
    if (previous.isNotEmpty && previous.first.content == doc.json) {
      return previous.first;
    }
    final key = stableId();
    await db
        .into(db.memoryVersions)
        .insert(
          MemoryVersionsCompanion.insert(
            id: key,
            speechId: id,
            versionNumber: previous.isEmpty
                ? 1
                : previous.first.versionNumber + 1,
            content: doc.json,
            createdUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
    return (db.select(
      db.memoryVersions,
    )..where((v) => v.id.equals(key))).getSingle();
  });
  Future<MemoryWorkspace> workspace(String id) => (db.select(
    db.memoryWorkspaces,
  )..where((w) => w.sessionId.equals(id))).getSingle();
  Future<String> createAttempt(
    String versionId,
    String sectionId,
    String mode,
    String kind,
    String cue, {
    DateTime? now,
  }) => db.transaction(() async {
    if (!memoryModes.contains(mode) ||
        !recallKinds.contains(kind) ||
        !cueStages.contains(cue)) {
      throw ArgumentError('Invalid recall setup');
    }
    final v = await (db.select(
      db.memoryVersions,
    )..where((v) => v.id.equals(versionId))).getSingle();
    final doc = MemoryDocument.parse(jsonDecode(v.content));
    final section = doc.sections.singleWhere((s) => s['id'] == sectionId);
    final exercise = Exercise.fromSnapshot(
      jsonEncode({
        'formatVersion': 1,
        'packId': 'memory-personal',
        'packVersion': 1,
        'exercises': [
          {
            'id': 'memory-${v.id}',
            'version': v.versionNumber,
            'module': 'memory',
            'language': doc.data['language'],
            'level': doc.data['level'],
            'title': '${doc.title} · ${section['title']}',
            'prompt': section['text'],
            'focus': mode == 'verbatim'
                ? 'Compare exact wording yourself, including links between ideas.'
                : 'Recall ideas and their relationships in your own words.',
            'authorship': {
              'creator': doc.data['author'],
              'kind': 'adapted',
              'source': 'Local speech supplied by the user; provenance retained in the speech version.',
            },
            'license': {'id': 'local-speech', 'notice': doc.data['license']},
            'rubric': {
              'id': 'memory-self-review',
              'version': 1,
              'criteria': [
                {
                  'id': 'ideas',
                  'label': 'Ideas',
                  'description':
                      'Which important ideas did you recall or miss?',
                },
                {
                  'id': 'wording',
                  'label': 'Wording',
                  'description': 'Compare wording for verbatim recall; for meaning-based recall, judge whether your wording preserves the message.',
                },
                {
                  'id': 'transitions',
                  'label': 'Transitions',
                  'description':
                      'Did you preserve the link to the next idea or section?',
                },
              ],
            },
            'memory': {
              'speechId': v.speechId,
              'versionId': v.id,
              'versionNumber': v.versionNumber,
              'sectionId': sectionId,
              'speech': doc.data,
            },
          },
        ],
      }),
    );
    final id = await practice.createDraft(exercise, now ?? DateTime.now());
    await db
        .into(db.memoryWorkspaces)
        .insert(
          MemoryWorkspacesCompanion.insert(
            sessionId: id,
            versionId: v.id,
            sectionId: sectionId,
            mode: mode,
            recallKind: kind,
            cueStage: cue,
            assistance: jsonEncode([_event('cue', cue)]),
          ),
        );
    return id;
  });
  Map<String, dynamic> _event(String kind, String cue) => {
    'kind': kind,
    'cue': cue,
    'utcMs': DateTime.now().toUtc().millisecondsSinceEpoch,
  };
  Future<MemoryWorkspace> assistance(
    String id, {
    String? cue,
    bool reveal = false,
  }) => db.transaction(() async {
    if (isTerminal((await practice.load(id)).session.status)) {
      throw StateError('Recall evidence is closed. Start another attempt.');
    }
    final w = await workspace(id);
    if (cue != null && !cueStages.contains(cue)) {
      throw ArgumentError('Invalid cue');
    }
    if (!reveal && (cue == null || cue == w.cueStage)) return w;
    final events = (jsonDecode(w.assistance) as List);
    events.add(_event(reveal ? 'reveal' : 'cue', cue ?? w.cueStage));
    await (db.update(
      db.memoryWorkspaces,
    )..where((w) => w.sessionId.equals(id))).write(
      MemoryWorkspacesCompanion(
        cueStage: Value(cue ?? w.cueStage),
        assistance: Value(jsonEncode(events)),
      ),
    );
    return workspace(id);
  });
  Future<void> saveReview(
    String id,
    Map<String, String> ratings,
    String note,
    bool later,
  ) => db.transaction(() async {
    if (ratings.keys.toSet().difference({
          'ideas',
          'wording',
          'transitions',
        }).isNotEmpty ||
        ratings.values.any((v) => !recallRatings.contains(v)) ||
        note.length > 10000) {
      throw ArgumentError('Invalid self-review');
    }
    await practice.saveReview(id, note, ReviewStatus.reviewed, DateTime.now());
    await (db.update(
      db.memoryWorkspaces,
    )..where((w) => w.sessionId.equals(id))).write(
      MemoryWorkspacesCompanion(
        assessments: Value(jsonEncode(ratings)),
        reviewNote: Value(note),
        laterReview: Value(later),
      ),
    );
  });
}
