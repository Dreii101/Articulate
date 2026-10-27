import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'wave_file.dart';

class AudioStore {
  AudioStore(this.practice, this.root);
  final PracticeRepository practice;
  final Directory root;
  AppDatabase get db => practice.db;
  static Future<AudioStore> open(PracticeRepository practice) async =>
      AudioStore(practice, await getApplicationSupportDirectory());
  Future<void> prepare() =>
      Directory('${root.path}${Platform.pathSeparator}audio')
          .create(recursive: true);
  File fileFor(String relative) {
    if (!RegExp(r'^audio/[a-f0-9]{32}\.wav$').hasMatch(relative)) {
      throw ArgumentError('Invalid managed recording path');
    }
    return File(
      '${root.path}${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}',
    );
  }

  Stream<List<AudioRecording>> watch(String sessionId, {String? contextKey}) =>
      (db.select(db.audioRecordings)
            ..where(
              (r) =>
                  r.sessionId.equals(sessionId) &
                  (contextKey == null
                      ? const Constant(true)
                      : r.contextKey.equals(contextKey)),
            )
            ..orderBy([(r) => OrderingTerm.desc(r.createdUtcMs)]))
          .watch();
  Stream<List<AudioObservation>> observations(String recordingId) =>
      (db.select(db.audioObservations)
            ..where((o) => o.recordingId.equals(recordingId))
            ..orderBy([(o) => OrderingTerm.asc(o.positionMs)]))
          .watch();
  Future<AudioRecording> load(String id) => (db.select(
    db.audioRecordings,
  )..where((r) => r.id.equals(id))).getSingle();

  Future<AudioRecording> reserve(
    String sessionId,
    String inputId,
    String inputName, {
    bool microphoneCheck = false,
    String contextKey = '',
  }) => db.transaction(() async {
    final d = await practice.load(sessionId);
    if (isTerminal(d.session.status)) {
      throw StateError('Start a new rehearsal to record another take.');
    }
    if (contextKey.length > 80) {
      throw ArgumentError('Invalid recording context');
    }
    if (d.session.moduleId == 'debate' &&
        d.exercise.content.containsKey('debate')) {
      final round = await (db.select(
        db.debateWorkspaces,
      )..where((w) => w.sessionId.equals(sessionId))).getSingle();
      final stage =
          await (db.select(db.debateStages)..where(
                (s) =>
                    s.sessionId.equals(sessionId) &
                    s.stageKey.equals(contextKey),
              ))
              .getSingleOrNull();
      if (round.responseKind != 'recorded' ||
          !{'opening', 'rebuttal'}.contains(contextKey) ||
          stage?.status != 'active') {
        throw StateError('Only the active spoken response stage can record.');
      }
    } else if (d.exercise.content.containsKey('impromptu')) {
      final attempt = await (db.select(
        db.impromptuWorkspaces,
      )..where((w) => w.sessionId.equals(sessionId))).getSingle();
      if (attempt.responseKind != 'recorded' ||
          attempt.viewStep != 'respond' ||
          contextKey != '') {
        throw StateError('Only the recorded response stage can record.');
      }
    } else if (contextKey.isNotEmpty) {
      throw ArgumentError('This practice has no recording stages');
    }
    await prepare();
    final id = stableId();
    await db
        .into(db.audioRecordings)
        .insert(
          AudioRecordingsCompanion.insert(
            id: id,
            sessionId: sessionId,
            contextKey: Value(contextKey),
            relativePath: 'audio/$id.wav',
            state: 'pending',
            inputId: inputId,
            inputName: inputName,
            microphoneCheck: Value(microphoneCheck),
            createdUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
    return load(id);
  });

  Future<AudioRecording> finalize(
    String id, {
    bool interrupted = false,
    String reason = '',
  }) async {
    final row = await load(id);
    if (row.state != 'pending') return row;
    try {
      final info = await inspectWave(
        fileFor(row.relativePath).path,
        repair: interrupted,
      );
      final notes = [
        if (reason.isNotEmpty) reason,
        if (interrupted) 'Interrupted take; its end may be abrupt.',
        if (info.repaired)
          'Recovered complete PCM frames and repaired the WAV header.',
        if (info.rmsDb <= -60) 'Very low or silent signal. Check input and listen before relying on this take.',
        if (info.peakDb >= -0.5) 'Peaks are near full scale. If playback sounds distorted, lower input gain or move farther from the microphone.',
        if (info.sampleRate != 48000 || info.channels != 1)
          'Device adjusted the requested 48 kHz mono format. Actual: ${info.sampleRate} Hz, ${info.channels} channels.',
      ];
      await (db.update(
        db.audioRecordings,
      )..where((r) => r.id.equals(id) & r.state.equals('pending'))).write(
        AudioRecordingsCompanion(
          state: const Value('finalized'),
          interrupted: Value(interrupted),
          durationMs: Value(info.durationMs),
          sampleRate: Value(info.sampleRate),
          channels: Value(info.channels),
          byteCount: Value(info.bytes),
          peakDb: Value(info.peakDb),
          rmsDb: Value(info.rmsDb),
          statusNote: Value(notes.join(' ')),
          finalizedUtcMs: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
        ),
      );
    } catch (e) {
      if (e is! FormatException &&
          e is! FileSystemException &&
          e is! ArgumentError) {
        rethrow;
      }
      await (db.update(
        db.audioRecordings,
      )..where((r) => r.id.equals(id) & r.state.equals('pending'))).write(
        AudioRecordingsCompanion(
          state: const Value('unavailable'),
          interrupted: Value(interrupted),
          statusNote: Value(
            '${reason.isEmpty ? 'Recording could not be finalized.' : reason} No playable PCM file was recovered. Any existing file is retained.',
          ),
          finalizedUtcMs: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
        ),
      );
    }
    return load(id);
  }

  Future<void> reconcile() async {
    await prepare();
    final rows = await (db.select(
      db.audioRecordings,
    )..where((r) => r.state.equals('pending'))).get();
    for (final r in rows) {
      await finalize(
        r.id,
        interrupted: true,
        reason: 'Recovered after app interruption.',
      );
    }
  }

  Future<void> observe(String recordingId, int positionMs, String text) async {
    final row = await load(recordingId);
    if (row.state != 'finalized' ||
        positionMs < 0 ||
        positionMs > row.durationMs ||
        text.trim().isEmpty ||
        text.length > 4000) {
      throw ArgumentError('Invalid timestamped observation');
    }
    await db
        .into(db.audioObservations)
        .insert(
          AudioObservationsCompanion.insert(
            id: stableId(),
            recordingId: recordingId,
            positionMs: positionMs,
            note: text.trim(),
            createdUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }
}
