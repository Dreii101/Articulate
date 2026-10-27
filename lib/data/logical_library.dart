import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../storage/database.dart';
import '../advanced/advanced_repository.dart';
import '../storage/practice_repository.dart';
import '../exercises.dart';
import '../writing/writing_repository.dart';
import '../reading/reading_repository.dart';
import '../memory/memory_document.dart';
import '../debate/debate_content.dart';
import '../impromptu/impromptu_content.dart';
import '../audio/wave_file.dart';
import 'archive_format.dart';

Object? safeJson(String text) {
  var depth = 0, quoted = false, escaped = false;
  for (final c in text.codeUnits) {
    if (quoted) {
      if (escaped) {
        escaped = false;
      } else if (c == 92) {
        escaped = true;
      } else if (c == 34) {
        quoted = false;
      }
    } else if (c == 34) {
      quoted = true;
    } else if (c == 123 || c == 91) {
      if (++depth > 64) {
        throw const DataFailure('Logical data is nested too deeply.');
      }
    } else if (c == 125 || c == 93) {
      depth--;
    }
  }
  return jsonDecode(text);
}

Map<String, dynamic> jsonMap(String value) =>
    safeJson(value) as Map<String, dynamic>;
String canonicalData(Object? value) => jsonEncode(
  value is Map
      ? {
          for (final k in value.keys.map((k) => k.toString()).toList()..sort())
            k: safeJson(canonicalData(value[k])),
        }
      : value is List
      ? value.map((v) => safeJson(canonicalData(v))).toList()
      : value,
);
Stream<Map<String, dynamic>> logicalRows(
  File file,
  ArchiveLimits limits,
  OperationToken token,
) async* {
  var pending = BytesBuilder(copy: false), rows = 0;
  await for (final chunk in file.openRead()) {
    token.check();
    var start = 0;
    for (var i = 0; i < chunk.length; i++) {
      if (chunk[i] != 10) {
        continue;
      }
      if (pending.length + i - start > limits.line) {
        throw const DataFailure('Logical row exceeds the supported limit.');
      }
      pending.add(chunk.sublist(start, i));
      final value = safeJson(utf8.decode(pending.takeBytes()));
      start = i + 1;
      if (value is! Map<String, dynamic> || ++rows > limits.rows) {
        throw const DataFailure('Invalid logical row.');
      }
      yield value;
    }
    if (pending.length + chunk.length - start > limits.line) {
      throw const DataFailure('Logical row exceeds the supported limit.');
    }
    pending.add(chunk.sublist(start));
  }
  if (pending.length != 0) {
    throw const DataFailure('Logical data has an incomplete row.');
  }
}

Future<void> importLogical(
  AppDatabase db,
  Directory stage,
  Map<String, dynamic> manifest,
  ArchiveLimits limits,
  OperationToken token, {
  bool replace = false,
}) => db.transaction(() async {
  await db.customStatement('PRAGMA defer_foreign_keys = ON');
  if (replace) {
    for (final table in logicalTables.reversed) {
      await db.customStatement('DELETE FROM "$table"');
    }
  }
  for (final table in archiveTables(manifest)) {
    final columns = await db.customSelect('PRAGMA table_info("$table")').get();
    final types = {
          for (final c in columns)
            c.read<String>('name'): c.read<String>('type').toUpperCase(),
        },
        required = {
          for (final c in columns)
            if (c.read<int>('notnull') == 1) c.read<String>('name'),
        };
    var count = 0;
    await for (final row in logicalRows(
      File('${stage.path}/data/$table.jsonl'),
      limits,
      token,
    )) {
      if (row.length != types.length ||
          row.keys.toSet().difference(types.keys.toSet()).isNotEmpty) {
        throw const DataFailure('Unsupported logical fields.');
      }
      for (final e in row.entries) {
        final v = e.value;
        if (v == null) {
          if (required.contains(e.key)) {
            throw const DataFailure('Required logical data is missing.');
          }
          continue;
        }
        final valid = switch (types[e.key]) {
          'TEXT' => v is String,
          'INTEGER' => v is int,
          'REAL' => v is num && v.isFinite,
          _ => false,
        };
        if (!valid) {
          throw const DataFailure('Invalid logical field type.');
        }
        if (e.key.endsWith('_utc_ms') &&
            v is int &&
            v.abs() > 8640000000000000) {
          throw const DataFailure('Timestamp is outside the supported range.');
        }
      }
      if (table == 'practice_sessions' || table == 'custom_exercises') {
        safeJson(row['snapshot'] as String);
      }
      if (table == 'app_settings' && row['key'] == 'reviewIntervals') {
        safeJson(row['value'] as String);
      }
      if (table == 'app_settings' &&
          (!{
                'theme',
                'reduceMotion',
                ...advancedSettingKeys,
              }.contains(row['key']) ||
              advancedSettingKeys.contains(row['key']) &&
                  !validAdvancedSetting(
                    row['key'] as String,
                    row['value'] as String,
                  ) ||
              row['key'] == 'theme' &&
                  !{'light', 'dark', 'system'}.contains(row['value']) ||
              row['key'] == 'reduceMotion' &&
                  !{'true', 'false'}.contains(row['value']))) {
        throw const DataFailure(
          'Unsupported settings or credentials in archive.',
        );
      }
      await db.customStatement(
        'INSERT INTO "$table" (${row.keys.map((k) => '"$k"').join(',')}) VALUES (${List.filled(row.length, '?').join(',')})',
        row.values.toList(),
      );
      count++;
    }
    if (count != manifest['tables'][table]) {
      throw const DataFailure('Manifest record counts do not match.');
    }
  }
  if ((await db.customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
    throw const DataFailure('Archive contains broken references.');
  }
});

class LogicalValidator {
  LogicalValidator(this.db, this.stage, this.manifest, this.token);
  final AppDatabase db;
  final Directory stage;
  final Map<String, dynamic> manifest;
  final OperationToken token;
  Never bad() => throw const DataFailure(
    'Archive contains inconsistent records or assessment references.',
  );
  bool text(Object? value, int max) => value is String && value.length <= max;
  Future<void> validate() async {
    await validateAdvancedLibrary(db);
    final practice = PracticeRepository(db),
        present = (manifest['entries'] as List).map((e) => e['path']).toSet(),
        missing = (manifest['missingMedia'] as List).cast<String>().toSet(),
        owned = <String>{};
    for (var offset = 0; ; offset += 128) {
      final rows = await db
          .customSelect(
            'SELECT id,snapshot FROM practice_sessions ORDER BY id LIMIT 128 OFFSET $offset',
          )
          .get();
      if (rows.isEmpty) {
        break;
      }
      for (final row in rows) {
        token.check();
        safeJson(row.read<String>('snapshot'));
        final id = row.read<String>('id'),
            d = await practice.load(id),
            s = d.session;
        safeJson(s.snapshot);
        final e = Exercise.fromSnapshot(s.snapshot);
        if (s.moduleId != e.module ||
            s.exerciseId != e.id ||
            s.exerciseVersion != e.version ||
            s.id.isEmpty ||
            s.id.length > 100 ||
            !text(d.response.body, 100000) ||
            !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s.localPracticeDate) ||
            DateTime.tryParse(s.localPracticeDate)
                    ?.toIso8601String()
                    .substring(0, 10) !=
                s.localPracticeDate ||
            s.originalOffsetMinutes.abs() > 1440 ||
            s.status == 'running' ||
            d.openSegment != null ||
            d.segments.any(
              (t) =>
                  !{'prepare', 'respond', 'reflect'}.contains(t.stage) ||
                  t.elapsedMs < 0,
            ) ||
            d.review != null && s.status != 'completed') {
          bad();
        }
        final writing = await (db.select(
          db.writingWorkspaces,
        )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
        if (writing != null) {
          if (e.module != 'writing' ||
              !{
                'brief',
                'outline',
                'write',
                'review',
              }.contains(writing.viewStep) ||
              writing.versionNumber < 1) {
            bad();
          }
          WritingRepository.validateAssessments(
            jsonMap(writing.assessments),
            d.response.body,
          );
          final document = e.document;
          document['exercises'][0]['rubric'] = jsonMap(writing.reviewRubric);
          Exercise.fromSnapshot(jsonEncode(document));
          final root =
              await (db.select(db.writingWorkspaces)
                    ..where((w) => w.sessionId.equals(writing.rootSessionId)))
                  .getSingleOrNull();
          if (root == null ||
              root.parentSessionId != null ||
              root.rootSessionId != root.sessionId ||
              root.versionNumber != 1) {
            bad();
          }
          if (writing.parentSessionId != null) {
            final parent =
                await (db.select(db.writingWorkspaces)..where(
                      (w) => w.sessionId.equals(writing.parentSessionId!),
                    ))
                    .getSingleOrNull();
            if (parent == null ||
                parent.rootSessionId != writing.rootSessionId ||
                parent.versionNumber + 1 != writing.versionNumber) {
              bad();
            }
          } else if (writing.rootSessionId != id) {
            bad();
          }
        }
        final reading = await (db.select(
          db.readingWorkspaces,
        )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
        if (reading != null) {
          if (e.module != 'reading' ||
              !e.content.containsKey('reading') ||
              !{'passage', 'questions', 'review'}.contains(reading.viewStep)) {
            bad();
          }
          final answers = d.response.body.isEmpty
                  ? <String, dynamic>{}
                  : jsonMap(d.response.body),
              revisions = jsonMap(reading.revisionAnswers),
              ratings = jsonMap(reading.ratings);
          ReadingRepository.validateAnswers(e, answers);
          ReadingRepository.validateAnswers(e, revisions);
          final openIds = readingQuestions(e)
              .where(isOpenQuestion)
              .map((q) => q['id'])
              .toSet();
          if (ratings.entries.any(
            (v) =>
                !openIds.contains(v.key) ||
                v.value != null && !readingRatings.contains(v.value),
          )) {
            bad();
          }
          if (reading.keyResults != null) {
            if (canonicalData(jsonMap(reading.keyResults!)) !=
                    canonicalData(ReadingRepository.keyedResults(e, answers)) ||
                s.status != 'completed') {
              bad();
            }
          } else if (revisions.isNotEmpty || ratings.isNotEmpty) {
            bad();
          }
        }
        final memory = await (db.select(
          db.memoryWorkspaces,
        )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
        if (memory != null) {
          final version = await (db.select(
            db.memoryVersions,
          )..where((v) => v.id.equals(memory.versionId))).getSingle();
          if (e.module != 'memory' ||
              !e.content.containsKey('memory') ||
              !memoryModes.contains(memory.mode) ||
              !recallKinds.contains(memory.recallKind) ||
              !cueStages.contains(memory.cueStage)) {
            bad();
          }
          final source = e.content['memory'];
          if (source['versionId'] != version.id ||
              source['speechId'] != version.speechId ||
              source['sectionId'] != memory.sectionId ||
              source['versionNumber'] != version.versionNumber ||
              canonicalData(source['speech']) !=
                  canonicalData(safeJson(version.content))) {
            bad();
          }
          final assistance = safeJson(memory.assistance);
          if (assistance is! List ||
              assistance.length > 200000 ||
              assistance.any(
                (v) =>
                    v is! Map ||
                    !{'cue', 'reveal'}.contains(v['kind']) ||
                    !cueStages.contains(v['cue']) ||
                    v['utcMs'] is! int,
              )) {
            bad();
          }
          final ratings = jsonMap(memory.assessments);
          if (ratings.entries.any(
            (v) =>
                !{'ideas', 'wording', 'transitions'}.contains(v.key) ||
                !recallRatings.contains(v.value),
          )) {
            bad();
          }
        }
        final debate = await (db.select(
          db.debateWorkspaces,
        )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
        if (debate != null) {
          if (!e.content.containsKey('debate') ||
              !{'for', 'against'}.contains(debate.position) ||
              !{'written', 'recorded'}.contains(debate.responseKind) ||
              debate.currentStage < 0 ||
              debate.currentStage > 4) {
            bad();
          }
          validateDebateTargets(jsonMap(debate.preset)['targets']);
          final stages = await (db.select(
            db.debateStages,
          )..where((v) => v.sessionId.equals(id))).get();
          if (stages.length != 5 ||
              stages
                  .map((v) => v.stageKey)
                  .toSet()
                  .difference(debateStageKeys.toSet())
                  .isNotEmpty) {
            bad();
          }
          for (final st in stages) {
            final fields = jsonMap(st.fields),
                allowed = {
                  ...debateFields[st.stageKey]!,
                  if (st.stageKey == 'preparation' || st.stageKey == 'rebuttal')
                    'supportKind',
                };
            if (st.elapsedMs < 0 ||
                fields.entries.any(
                  (v) => !allowed.contains(v.key) || !text(v.value, 20000),
                ) ||
                fields.containsKey('supportKind') &&
                    !supportKinds.contains(fields['supportKind'])) {
              bad();
            }
          }
          if (s.status == 'completed' &&
              stages.any(
                (v) => v.status != 'completed' && v.status != 'skipped',
              )) {
            bad();
          }
          await _ratings(
            id,
            jsonMap(debate.assessments),
            debateCriteria,
            stages: stages,
          );
        }
        final impromptu = await (db.select(
          db.impromptuWorkspaces,
        )..where((w) => w.sessionId.equals(id))).getSingleOrNull();
        if (impromptu != null) {
          if (!e.content.containsKey('impromptu') ||
              !{'recorded', 'unrecorded'}.contains(impromptu.responseKind) ||
              !{
                'reveal',
                'prepare',
                'respond',
                'review',
              }.contains(impromptu.viewStep) ||
              s.status == 'completed' && impromptu.viewStep != 'review' ||
              impromptu.confidence != null &&
                  (impromptu.confidence! < 1 || impromptu.confidence! > 5)) {
            bad();
          }
          validateImpromptuTargets(jsonMap(impromptu.preset)['targets']);
          if (jsonMap(impromptu.scaffold).entries.any(
            (v) =>
                !impromptuScaffold.containsKey(v.key) || !text(v.value, 10000),
          )) {
            bad();
          }
          await _ratings(id, jsonMap(impromptu.assessments), impromptuCriteria);
          if (impromptu.parentSessionId != null) {
            final parent = await practice.load(impromptu.parentSessionId!);
            if (parent.session.status != 'completed' ||
                parent.exercise.snapshot != e.snapshot) {
              bad();
            }
          }
        }
        if (e.content.containsKey('memory') && memory == null ||
            e.content.containsKey('debate') && debate == null ||
            e.content.containsKey('impromptu') && impromptu == null) {
          bad();
        }
        final recordings = await (db.select(
          db.audioRecordings,
        )..where((r) => r.sessionId.equals(id))).get();
        for (final r in recordings) {
          if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(r.id) ||
              r.relativePath != 'audio/${r.id}.wav' ||
              r.state == 'pending' ||
              r.durationMs < 0 ||
              r.byteCount < 0 ||
              !owned.add(r.relativePath)) {
            bad();
          }
          if (debate != null
              ? !{'opening', 'rebuttal'}.contains(r.contextKey)
              : r.contextKey.isNotEmpty) {
            bad();
          }
          if (!present.contains(r.relativePath) &&
              !missing.contains(r.relativePath)) {
            bad();
          }
          if (present.contains(r.relativePath) && r.state == 'finalized') {
            final info = await inspectWave('${stage.path}/${r.relativePath}');
            if (info.durationMs != r.durationMs ||
                info.sampleRate != r.sampleRate ||
                info.channels != r.channels ||
                info.bytes != r.byteCount) {
              bad();
            }
          }
          final observations = await (db.select(
            db.audioObservations,
          )..where((o) => o.recordingId.equals(r.id))).get();
          if (observations.any(
            (o) =>
                o.positionMs < 0 ||
                o.positionMs > r.durationMs ||
                !text(o.note, 4000),
          )) {
            bad();
          }
        }
      }
    }
    if (present
            .whereType<String>()
            .where((p) => p.startsWith('audio/'))
            .any((p) => !owned.contains(p)) ||
        missing.any((p) => !owned.contains(p))) {
      bad();
    }
    for (final s in await db.select(db.memorySpeeches).get()) {
      MemoryDocument.parse(safeJson(s.draft), draft: true);
    }
    for (final v in await db.select(db.memoryVersions).get()) {
      if (v.versionNumber < 1) {
        bad();
      }
      MemoryDocument.parse(safeJson(v.content));
    }
    for (final q in await db.select(db.impromptuQueues).get()) {
      final pool = safeJson(q.poolKey), remaining = safeJson(q.remaining);
      if (pool is! List ||
          remaining is! List ||
          pool.isEmpty ||
          remaining.length > pool.length) {
        bad();
      }
      final poolIds = <String>{};
      for (final v in pool) {
        if (v is! List ||
            v.length != 3 ||
            v[0] is! String ||
            v[1] is! int ||
            v[2] is! int ||
            !poolIds.add(v[0] as String)) {
          bad();
        }
      }
      if (remaining.toSet().length != remaining.length ||
          remaining.any((v) => !poolIds.contains(v)) ||
          !poolIds.contains(q.lastQuestion)) {
        bad();
      }
    }
    await _chains('impromptu_workspaces');
  }

  Future<void> _chains(String table) async {
    final parents = {
      for (final r
          in await db
              .customSelect('SELECT session_id,parent_session_id FROM $table')
              .get())
        r.read<String>('session_id'): r.readNullable<String>(
          'parent_session_id',
        ),
    };
    final checked = <String>{};
    for (final id in parents.keys) {
      final seen = <String>{};
      String? at = id;
      while (at != null && !checked.contains(at)) {
        if (!parents.containsKey(at) || !seen.add(at) || seen.length > 1000) {
          bad();
        }
        at = parents[at];
      }
      checked.addAll(seen);
    }
  }

  Future<void> _ratings(
    String id,
    Map<String, dynamic> ratings,
    List<String> criteria, {
    List<DebateStage>? stages,
  }) async {
    if (ratings.keys.toSet().difference(criteria.toSet()).isNotEmpty) {
      bad();
    }
    for (final v in ratings.values) {
      if (v is! Map ||
          v.keys.toSet().difference({
            'rating',
            'note',
            if (stages != null) 'anchor',
          }).isNotEmpty ||
          v['rating'] != null &&
              !{'emerging', 'developing', 'effective'}.contains(v['rating']) ||
          !text(v['note'], 4000)) {
        bad();
      }
      final a = v['anchor'];
      if (a == null) {
        continue;
      }
      if (stages == null || a is! Map) {
        bad();
      }
      if (a['kind'] == 'audio') {
        if (a.keys.toSet().difference({
          'kind',
          'recordingId',
          'positionMs',
        }).isNotEmpty) {
          bad();
        }
        final row =
            await (db.select(db.audioRecordings)
                  ..where((r) => r.id.equals(a['recordingId'] as String)))
                .getSingleOrNull();
        if (row == null ||
            row.sessionId != id ||
            row.microphoneCheck ||
            !{'opening', 'rebuttal'}.contains(row.contextKey) ||
            a['positionMs'] is! int ||
            a['positionMs'] < 0 ||
            a['positionMs'] > row.durationMs) {
          bad();
        }
      } else if (a['kind'] == 'text') {
        if (a.keys.toSet().difference({
          'kind',
          'stage',
          'field',
          'start',
          'end',
          'quote',
        }).isNotEmpty) {
          bad();
        }
        final st = stages.where((s) => s.stageKey == a['stage']).firstOrNull;
        if (st == null || !debateFields[st.stageKey]!.contains(a['field'])) {
          bad();
        }
        final body = jsonMap(st.fields)[a['field']] as String? ?? '',
            start = a['start'],
            end = a['end'];
        if (start is! int ||
            end is! int ||
            start < 0 ||
            end <= start ||
            end > body.length ||
            body.substring(start, end) != a['quote']) {
          bad();
        }
      } else {
        bad();
      }
    }
  }
}
