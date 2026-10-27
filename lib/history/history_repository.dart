import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../debate/debate_content.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';

final historyRepositoryProvider = Provider(
  (ref) => HistoryRepository(ref.watch(repositoryProvider)),
);
final historyProvider = StreamProvider(
  (ref) => ref.watch(historyRepositoryProvider).watch(),
);

String assessorLabel(String source) => switch (source) {
  'self' => 'Self-rating',
  'answerKey' => 'Answer-key result',
  'humanAssessor' => 'Human assessor',
  _ => 'Other assessor ($source)',
};
Map<String, dynamic> historyObject(String? value) =>
    value == null || value.isEmpty
    ? {}
    : jsonDecode(value) as Map<String, dynamic>;
Map<String, dynamic> taskContent(Map<String, dynamic> content) => {...content}
  ..remove('rubric')
  ..remove('language')
  ..remove('level')
  ..remove('authorship')
  ..remove('license');
String canonical(Object? value) => jsonEncode(
  value is Map
      ? {
          for (final k in value.keys.map((k) => k.toString()).toList()..sort())
            k: jsonDecode(canonical(value[k])),
        }
      : value is List
      ? value.map((v) => jsonDecode(canonical(v))).toList()
      : value,
);

class HistoryAssessment {
  const HistoryAssessment(
    this.label,
    this.source,
    this.value,
    this.evidence, {
    this.note = '',
  });
  final String label, source, evidence, note;
  final String? value;
  String get display => source == 'answerKey' && value == null
      ? 'Not checked'
      : switch (value) {
          null || 'notAssessed' => 'Not assessed',
          'emerging' => 'Emerging',
          'developing' => 'Developing',
          'effective' => 'Effective',
          'missed' => 'Missed / needs attention',
          'recalled' => 'Recalled — my assessment',
          'correct' => 'Correct',
          'incorrect' => 'Incorrect',
          'unanswered' => 'Unanswered',
          _ => value!,
        };
  bool get assessed => value != null && value != 'notAssessed';
}

class HistoryEvidence {
  const HistoryEvidence(this.label, this.text);
  final String label, text;
}

class HistoryEntry {
  HistoryEntry({
    required this.detail,
    required this.durations,
    required this.openSegments,
    required this.recordings,
    required this.observations,
    required this.stages,
    this.writing,
    this.reading,
    this.memory,
    this.debate,
    this.impromptu,
    this.context,
  });
  final SessionDetail detail;
  final Map<String, int> durations;
  final int openSegments;
  final List<AudioRecording> recordings;
  final List<AudioObservation> observations;
  final List<DebateStage> stages;
  final WritingWorkspace? writing;
  final ReadingWorkspace? reading;
  final MemoryWorkspace? memory;
  final DebateWorkspace? debate;
  final ImpromptuWorkspace? impromptu;
  final PracticeContext? context;
  late final exercise = detail.exercise;
  PracticeSession get session => detail.session;
  String get id => session.id;
  String get taskPrompt => impromptu?.viewStep == 'reveal'
      ? 'Question reserved. Reveal it in the module when ready.'
      : memory != null && !isTerminal(session.status)
      ? 'Source stays concealed during ongoing recall. Use the module reveal to record assistance.'
      : exercise.prompt;
  String? get parentId =>
      context?.parentSessionId ??
      writing?.parentSessionId ??
      impromptu?.parentSessionId;
  String get statusLabel => switch (session.status) {
    'draft' => 'Draft',
    'interrupted' => 'Interrupted',
    'paused' => 'Paused',
    'running' => 'In progress',
    'completed' => 'Completed',
    'abandoned' => 'Abandoned',
    _ => session.status,
  };
  int get timerMs => durations.values.fold(0, (a, b) => a + b);
  int get recordedAudioMs => recordings
      .where((r) => r.state == 'finalized' && !r.microphoneCheck)
      .fold(0, (n, r) => n + r.durationMs);
  Map<String, dynamic> get rubric => writing != null
      ? historyObject(writing!.reviewRubric)
      : exercise.content['rubric'] as Map<String, dynamic>;
  String get relation => context?.parentSessionId != null
      ? 'Targeted retry'
      : writing != null
      ? 'Writing version ${writing!.versionNumber}'
      : impromptu?.parentSessionId != null
      ? 'Linked retry'
      : 'Original attempt';
  int get updatedUtcMs => [
    session.updatedUtcMs,
    detail.review?.updatedUtcMs ?? 0,
    writing?.updatedUtcMs ?? 0,
    reading?.updatedUtcMs ?? 0,
    ...recordings.map((r) => r.finalizedUtcMs ?? r.createdUtcMs),
  ].reduce((a, b) => a > b ? a : b);

  List<HistoryEvidence> get evidence {
    final e = exercise,
        body = detail.response.body,
        blocks = <HistoryEvidence>[];
    if (reading != null) {
      blocks.add(
        HistoryEvidence(
          'Source passage',
          (reading!.hidePassage && !isTerminal(session.status))
              ? 'Passage hidden for summary practice. Reopen the module to reveal it.'
              : (e.content['reading']['passage'] as List)
                    .map((p) => p['text'])
                    .join('\n\n'),
        ),
      );
      final first = historyObject(body),
          revised = historyObject(reading!.revisionAnswers);
      for (final q in e.content['reading']['questions'] as List) {
        String answer(Object? value) {
          if (value == null || value == '') {
            return 'No answer supplied';
          }
          final options = q['options'] as List?;
          final option = options?.where((o) => o['id'] == value).firstOrNull;
          return option == null
              ? value.toString()
              : '${option['id']}: ${option['text']}';
        }

        blocks.add(
          HistoryEvidence(
            'First answer · ${q['prompt']}',
            answer(first[q['id']]),
          ),
        );
        if (reading!.keyResults != null) {
          blocks.add(
            HistoryEvidence(
              'After explanations · ${q['prompt']}',
              answer(revised[q['id']]),
            ),
          );
        }
      }
    } else if (debate != null) {
      for (final stage in stages) {
        final fields = historyObject(stage.fields);
        blocks.add(
          HistoryEvidence(
            '${stage.stageKey} · ${stage.status}',
            fields.entries
                .map((e) => '${e.key}: ${e.value}')
                .join('\n\n')
                .ifEmpty('No written response supplied'),
          ),
        );
      }
    } else {
      blocks.add(
        HistoryEvidence(
          memory != null ? 'Recall evidence' : 'Saved response / notes',
          body.ifEmpty('No written response supplied'),
        ),
      );
    }
    if (writing != null) {
      blocks.insert(
        0,
        HistoryEvidence(
          'Audience / purpose / outline',
          '${writing!.audience}\n${writing!.purpose}\n\n${writing!.outline}',
        ),
      );
    }
    if (impromptu != null) {
      blocks.add(
        HistoryEvidence(
          'Preparation / optional scaffold',
          '${impromptu!.preparation}\n\n${historyObject(impromptu!.scaffold).entries.map((e) => '${e.key}: ${e.value}').join('\n')}',
        ),
      );
      if (impromptu!.parentSessionId != null) {
        blocks.add(
          HistoryEvidence('Retry improvement', impromptu!.improvement),
        );
      }
    }
    if (memory != null) {
      blocks.insert(
        0,
        HistoryEvidence(
          'Exact practiced source · version ${e.version}',
          taskPrompt,
        ),
      );
      final assistance = jsonDecode(memory!.assistance) as List;
      blocks.add(
        HistoryEvidence(
          'Assistance used · ${memory!.mode} / ${memory!.recallKind}',
          assistance
              .map(
                (v) =>
                    '${v['kind']}: ${v['cue']} · UTC ${DateTime.fromMillisecondsSinceEpoch(v['utcMs'] as int, isUtc: true).toIso8601String()}',
              )
              .join('\n'),
        ),
      );
    }
    blocks.insert(
      blocks.isEmpty ? 0 : 1,
      HistoryEvidence(
        'Practice conditions',
        context == null
            ? 'Unlabelled MVP practice; conditions were not recorded.'
            : '${context!.label} — user label\n${context!.conditions}\n${context!.target}',
      ),
    );
    return blocks;
  }

  List<HistoryAssessment> get assessments {
    if (reading != null) {
      final values = <HistoryAssessment>[],
          first = historyObject(reading!.keyResults),
          ratings = historyObject(reading!.ratings),
          revised = historyObject(reading!.revisionAnswers);
      for (final q in exercise.content['reading']['questions'] as List) {
        if (q['kind'] == 'summary' || q['kind'] == 'critical') {
          values.add(
            HistoryAssessment(
              q['prompt'] as String,
              'self',
              ratings[q['id']] as String?,
              (revised[q['id']] as String?) ?? '',
              note: 'Self-review of the revised open answer. Sample reasoning is guidance, not a paraphrase grade.',
            ),
          );
        } else {
          final result = first[q['id']] as Map?;
          values.add(
            HistoryAssessment(
              q['prompt'] as String,
              'answerKey',
              result?['status'] as String?,
              result == null
                  ? 'Not checked'
                  : 'First selection: ${result['selected'].toString().ifEmpty('Unanswered')} · Key: ${result['key']}',
              note:
                  result?['rationale'] as String? ??
                  'First-answer key check has not been performed.',
            ),
          );
        }
      }
      return values;
    }
    final raw = historyObject(
      writing?.assessments ??
          memory?.assessments ??
          debate?.assessments ??
          impromptu?.assessments,
    );
    return [
      for (final c in rubric['criteria'] as List)
        HistoryAssessment(
          c['label'] as String,
          'self',
          raw[c['id']] is Map
              ? (raw[c['id']] as Map)['rating'] as String?
              : raw[c['id']] as String?,
          _assessmentEvidence(raw[c['id']]),
          note: c['description'] as String,
        ),
    ];
  }

  String _assessmentEvidence(Object? value) {
    if (value is! Map) {
      return '';
    }
    final anchor = value['anchor'] as Map?;
    return [
      value['evidence'] ?? value['note'] ?? '',
      if (anchor?['kind'] == 'text')
        'Saved quote: ${anchor!['quote']} (${anchor['stage']}/${anchor['field']})',
      if (anchor?['kind'] == 'audio')
        'Recording ${anchor!['recordingId']} at ${anchor['positionMs']} ms',
    ].where((s) => s.toString().isNotEmpty).join('\n');
  }

  String get reviewNote =>
      writing?.nextAction ??
      memory?.reviewNote ??
      debate?.reviewNote ??
      impromptu?.reflection ??
      detail.review?.notes ??
      '';
  bool relatedEvidence(HistoryEntry other) =>
      id != other.id &&
      session.status == 'completed' &&
      other.session.status == 'completed' &&
      exercise.module == other.exercise.module &&
      (exercise.id == other.exercise.id ||
          memory != null &&
              other.memory != null &&
              exercise.content['memory']['speechId'] ==
                  other.exercise.content['memory']['speechId'] &&
              memory!.sectionId == other.memory!.sectionId);
  String? incompatibility(HistoryEntry other) {
    if (id == other.id) {
      return 'Choose another attempt.';
    }
    if (session.status != 'completed' || other.session.status != 'completed') {
      return 'Complete both attempts first.';
    }
    if ((context?.label ?? 'unlabelled') !=
            (other.context?.label ?? 'unlabelled') ||
        (context?.conditions ?? '') != (other.context?.conditions ?? '')) {
      return 'Different declared labels or conditions; these are user reports, not verified controls.';
    }
    final a = exercise, b = other.exercise;
    if (a.module != b.module ||
        a.id != b.id ||
        a.version != b.version ||
        canonical(taskContent(a.content)) !=
            canonical(taskContent(b.content))) {
      return 'Different task or exercise version.';
    }
    if (a.language != b.language) {
      return 'Different language.';
    }
    if (a.level != b.level) {
      return 'Different level.';
    }
    if (canonical(rubric) != canonical(other.rubric)) {
      return 'Different rubric or rubric version.';
    }
    String practiceConditions(HistoryEntry e) => canonical([
      e.writing == null ? null : [e.writing!.audience, e.writing!.purpose],
      e.memory == null
          ? null
          : [
              e.memory!.versionId,
              e.memory!.sectionId,
              e.memory!.mode,
              e.memory!.recallKind,
              e.memory!.assistance,
            ],
      e.debate == null
          ? null
          : [
              e.debate!.position,
              e.debate!.responseKind,
              historyObject(e.debate!.preset)['targets'],
            ],
      e.impromptu == null
          ? null
          : [
              e.impromptu!.responseKind,
              historyObject(e.impromptu!.preset)['targets'],
              e.impromptu!.scaffoldEnabled,
            ],
      e.reading?.hidePassage,
    ]);
    // Assistance timestamps differ naturally; compare cue/reveal sequence, not event times.
    String normalized(HistoryEntry e) {
      final value = jsonDecode(practiceConditions(e)) as List;
      if (e.memory != null) {
        (value[1] as List)[4] = (jsonDecode(e.memory!.assistance) as List)
            .map((v) => [v['kind'], v['cue']])
            .toList();
      }
      return canonical(value);
    }

    return normalized(this) == normalized(other)
        ? null
        : 'Different audience, response format, assistance, passage visibility, scaffold, position or timing targets.';
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class HistoryFilter {
  const HistoryFilter({
    this.module,
    this.language,
    this.level,
    this.exercise,
    this.from,
    this.to,
    this.status,
  });
  final String? module, language, level, exercise, from, to, status;
  bool matches(HistoryEntry e) =>
      (module == null || e.session.moduleId == module) &&
      (language == null || e.exercise.language == language) &&
      (level == null || e.exercise.level == level) &&
      (exercise == null || e.session.exerciseId == exercise) &&
      (from == null || e.session.localPracticeDate.compareTo(from!) >= 0) &&
      (to == null || e.session.localPracticeDate.compareTo(to!) <= 0) &&
      (status == null || e.session.status == status);
}

class HistorySummary {
  HistorySummary(this.entries);
  final List<HistoryEntry> entries;
  int get completed =>
      entries.where((e) => e.session.status == 'completed').length;
  int get finalizedMs => entries.fold(0, (n, e) => n + e.timerMs);
  int? stageMs(String stage) {
    final values = entries.where((e) => e.durations.containsKey(stage));
    return values.isEmpty
        ? null
        : values.fold<int>(0, (n, e) => n + e.durations[stage]!);
  }

  int get openSegments => entries.fold(0, (n, e) => n + e.openSegments);
  int get rated => entries
      .expand((e) => e.assessments)
      .where((a) => a.source == 'self' && a.assessed)
      .length;
  int get unassessed => entries
      .expand((e) => e.assessments)
      .where((a) => a.source == 'self' && !a.assessed)
      .length;
}

class HistoryRepository {
  HistoryRepository(this.practice);
  final PracticeRepository practice;
  AppDatabase get db => practice.db;
  Stream<List<HistoryEntry>> watch() => db
      .customSelect(
        'SELECT id FROM practice_sessions',
        readsFrom: {
          db.practiceSessions,
          db.responses,
          db.timingSegments,
          db.reviewRecords,
          db.writingWorkspaces,
          db.readingWorkspaces,
          db.memoryWorkspaces,
          db.debateWorkspaces,
          db.debateStages,
          db.impromptuWorkspaces,
          db.audioRecordings,
          db.audioObservations,
          db.practiceContexts,
        },
      )
      .watch()
      .asyncMap((_) => load());
  Future<List<HistoryEntry>> load() => db.transaction(() async {
    final sessions = await db.select(db.practiceSessions).get();
    final contexts = {
      for (final c in await db.select(db.practiceContexts).get())
        c.sessionId: c,
    };
    final responses = {
      for (final r in await db.select(db.responses).get()) r.sessionId: r,
    };
    final reviews = {
      for (final r in await db.select(db.reviewRecords).get()) r.sessionId: r,
    };
    final writing = {
      for (final r in await db.select(db.writingWorkspaces).get())
        r.sessionId: r,
    };
    final reading = {
      for (final r in await db.select(db.readingWorkspaces).get())
        r.sessionId: r,
    };
    final memory = {
      for (final r in await db.select(db.memoryWorkspaces).get())
        r.sessionId: r,
    };
    final debate = {
      for (final r in await db.select(db.debateWorkspaces).get())
        r.sessionId: r,
    };
    final impromptu = {
      for (final r in await db.select(db.impromptuWorkspaces).get())
        r.sessionId: r,
    };
    final audio = await db.select(db.audioRecordings).get(),
        observations = await db.select(db.audioObservations).get(),
        stages = await db.select(db.debateStages).get();
    // Aggregate before touching one-to-many evidence/review tables: each segment contributes once.
    final timing = await db
        .customSelect(
          'SELECT session_id, stage, SUM(elapsed_ms) AS ms FROM timing_segments WHERE ended_utc_ms IS NOT NULL GROUP BY session_id, stage',
        )
        .get();
    final pending = await db
        .customSelect(
          'SELECT session_id, COUNT(*) AS n FROM timing_segments WHERE ended_utc_ms IS NULL GROUP BY session_id',
        )
        .get();
    final times = <String, Map<String, int>>{};
    for (final row in timing) {
      (times[row.read<String>('session_id')] ??= {})[row.read<String>(
        'stage',
      )] = row.read<int>(
        'ms',
      );
    }
    final open = {
      for (final row in pending)
        row.read<String>('session_id'): row.read<int>('n'),
    };
    final audioBySession = <String, List<AudioRecording>>{},
        observationsBySession = <String, List<AudioObservation>>{},
        stagesBySession = <String, List<DebateStage>>{};
    final owners = {for (final r in audio) r.id: r.sessionId};
    for (final r in audio) {
      (audioBySession[r.sessionId] ??= []).add(r);
    }
    for (final o in observations) {
      final owner = owners[o.recordingId];
      if (owner != null) {
        (observationsBySession[owner] ??= []).add(o);
      }
    }
    for (final stage in stages) {
      (stagesBySession[stage.sessionId] ??= []).add(stage);
    }
    for (final list in stagesBySession.values) {
      list.sort(
        (a, b) => debateStageKeys
            .indexOf(a.stageKey)
            .compareTo(debateStageKeys.indexOf(b.stageKey)),
      );
    }
    final entries = [
      for (final s in sessions)
        HistoryEntry(
          detail: SessionDetail(s, responses[s.id]!, const [], reviews[s.id]),
          durations: times[s.id] ?? {},
          openSegments: open[s.id] ?? 0,
          writing: writing[s.id],
          reading: reading[s.id],
          memory: memory[s.id],
          debate: debate[s.id],
          impromptu: impromptu[s.id],
          context: contexts[s.id],
          recordings: audioBySession[s.id] ?? [],
          observations: observationsBySession[s.id] ?? [],
          stages: stagesBySession[s.id] ?? [],
        ),
    ];
    entries.sort((a, b) {
      final c = b.updatedUtcMs.compareTo(a.updatedUtcMs);
      return c == 0 ? a.id.compareTo(b.id) : c;
    });
    return entries;
  });
}

({HistoryEntry entry, String label})? historyNextAction(
  List<HistoryEntry> entries,
) {
  final unfinished = entries
      .where((e) => !isTerminal(e.session.status))
      .firstOrNull;
  if (unfinished != null) {
    return (
      entry: unfinished,
      label: 'Resume ${unfinished.statusLabel.toLowerCase()}',
    );
  }
  final marked = entries
      .where(
        (e) => e.memory?.laterReview == true && e.session.status == 'completed',
      )
      .firstOrNull;
  if (marked != null) {
    return (entry: marked, label: 'Revisit marked recall');
  }
  final unreviewed = entries
      .where(
        (e) =>
            e.session.status == 'completed' &&
            e.detail.reviewStatus != ReviewStatus.reviewed,
      )
      .firstOrNull;
  if (unreviewed != null) {
    return (entry: unreviewed, label: 'Review saved work');
  }
  final completed = entries
      .where((e) => e.session.status == 'completed')
      .firstOrNull;
  return completed == null
      ? null
      : (entry: completed, label: 'Revisit latest work');
}
