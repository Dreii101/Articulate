import 'dart:io';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/audio/wave_file.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

import 'audio_fakes.dart';

void main() {
  late Directory root;
  late AppDatabase db;
  late PracticeRepository practice;
  late AudioStore store;
  late FakeAudioBackend backend;
  late LocalAudio audio;
  late String sessionId;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('articulate-audio-test-');
    db = AppDatabase(NativeDatabase.memory());
    practice = PracticeRepository(db);
    store = AudioStore(practice, root);
    backend = FakeAudioBackend();
    audio = LocalAudio(
      store,
      backend,
      windows: true,
      automaticHeartbeat: false,
    );
    final exercise = validateExercisePack(
      File('assets/exercises/core-v1.json').readAsStringSync(),
    ).firstWhere((e) => e.module == 'speech');
    sessionId = await practice.createDraft(exercise, DateTime(2026, 10, 25));
  });
  tearDown(() async {
    backend.failStop = false;
    backend.failReset = false;
    backend.diskError = false;
    await audio.close();
    await db.close();
    await root.delete(recursive: true);
  });

  test('PCM inspection reports actual frames/rate and silence; unfinished headers recover without losing data', () async {
    await store.prepare();
    final file = File('${root.path}/fixture.wav');
    await writeTestWave(
      file.path,
      sampleRate: 44100,
      silent: true,
      unfinished: true,
    );
    await expectLater(inspectWave(file.path), throwsFormatException);
    final before = await file.length();
    final fixed = await inspectWave(file.path, repair: true);
    expect(fixed.sampleRate, 44100);
    expect(fixed.durationMs, 1000);
    expect(fixed.rmsDb, closeTo(-120, 0.0001));
    expect(fixed.repaired, isTrue);
    expect(await file.length(), before);
    expect((await inspectWave(file.path)).repaired, isFalse);
    await file.writeAsString('not a wave');
    await expectLater(
      inspectWave(file.path, repair: true),
      throwsFormatException,
    );
    final silent = await store.reserve(sessionId, 'fixture', 'Silent fixture');
    await writeTestWave(store.fileFor(silent.relativePath).path, silent: true);
    final kept = await store.finalize(silent.id);
    expect(kept.state, 'finalized');
    expect(kept.statusNote, contains('silent signal'));
  });

  test('duplicate starts/stops produce one pending/finalized take and playback first loads its exact file', () async {
    final rows = await Future.wait([
      audio.start(sessionId),
      audio.start(sessionId),
    ]);
    expect(rows[0].id, rows[1].id);
    expect(backend.starts, 1);
    expect((await store.load(rows[0].id)).state, 'pending');
    await expectLater(audio.playPause(), throwsA(isA<AudioFailure>()));
    await audio.pause();
    await audio.pause();
    expect(backend.events.where((e) => e == 'capture-pause').length, 1);
    await audio.resume();
    await audio.resume();
    final stopped = await Future.wait([audio.stop(), audio.stop()]);
    expect(stopped[0]!.id, stopped[1]!.id);
    expect(backend.stops, 1);
    expect(stopped[0]!.state, 'finalized');
    await audio.playPause();
    expect(backend.opens, 1);
    expect(backend.plays, 1);
    await audio.start(sessionId);
    expect(
      backend.events.lastIndexOf('playback-stop'),
      lessThan(backend.events.lastIndexOf('capture-start')),
    );
    expect((await db.select(db.audioRecordings).get()).length, 2);
  });

  test('permission/input/encoder/low storage failures leave unrecorded notes intact and retry works', () async {
    await practice.saveResponse(
      sessionId,
      'Keep my rehearsal notes',
      DateTime.now(),
    );
    backend.allowed = false;
    await expectLater(audio.start(sessionId), throwsA(isA<AudioFailure>()));
    backend.allowed = true;
    backend.devices = [];
    await expectLater(audio.start(sessionId), throwsA(isA<AudioFailure>()));
    backend.devices = [const InputDevice(id: 'fixture-mic', label: 'Test')];
    backend.encoder = false;
    await expectLater(audio.start(sessionId), throwsA(isA<AudioFailure>()));
    backend.encoder = true;
    backend.free = 1024;
    await expectLater(audio.start(sessionId), throwsA(isA<AudioFailure>()));
    expect(await db.select(db.audioRecordings).get(), isEmpty);
    expect(
      (await practice.load(sessionId)).response.body,
      'Keep my rehearsal notes',
    );
    backend.free = 100 * 1024 * 1024;
    await audio.start(sessionId);
    expect(audio.capturing, isTrue);
  });

  test('desktop focus changes keep capture but hidden/minimized stop; mobile inactive stops without resuming', () async {
    final row = await audio.start(sessionId);
    await audio.lifecycle(AppLifecycleState.inactive);
    expect(audio.capturing, isTrue);
    await audio.lifecycle(AppLifecycleState.hidden);
    expect(audio.capturing, isFalse);
    expect((await store.load(row.id)).interrupted, isTrue);
    await audio.lifecycle(AppLifecycleState.resumed);
    expect(backend.starts, 1);
    await audio.close();
    backend = FakeAudioBackend();
    audio = LocalAudio(
      store,
      backend,
      windows: false,
      automaticHeartbeat: false,
    );
    await audio.start(sessionId);
    await audio.lifecycle(AppLifecycleState.inactive);
    expect(audio.capturing, isFalse);
  });

  test('device loss, unexpected pause and low storage stop capture and retain valid data', () async {
    await audio.refreshInputs();
    audio.chooseInput('fixture-mic');
    final one = await audio.start(sessionId);
    backend.devices = [];
    await audio.heartbeat();
    expect((await store.load(one.id)).interrupted, isTrue);
    backend.devices = [const InputDevice(id: 'fixture-mic', label: 'Test')];
    final two = await audio.start(sessionId);
    backend.free = 1024;
    await audio.heartbeat();
    expect((await store.load(two.id)).interrupted, isTrue);
    backend.free = 100 * 1024 * 1024;
    await audio.start(sessionId);
    backend.states.add(RecordState.pause);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(audio.capturing, isFalse);
  });

  test('failed storage monitoring and failed native stop do not silently permit conflicting capture', () async {
    await audio.start(sessionId);
    backend.diskError = true;
    await expectLater(audio.heartbeat(), throwsStateError);
    expect(audio.capturing, isFalse);
    backend.diskError = false;
    await audio.start(sessionId);
    backend.failStop = true;
    backend.failReset = true;
    await expectLater(audio.stop(), throwsStateError);
    expect(audio.capturing, isTrue);
    await expectLater(audio.playPause(), throwsA(isA<AudioFailure>()));
    backend.failStop = false;
    backend.failReset = false;
    await audio.stop();
    expect(audio.capturing, isFalse);
  });

  test('missing media and playback failure keep observations, support retry, seek and rate', () async {
    await audio.start(sessionId);
    final row = (await audio.stop())!;
    await audio.seek(500);
    await audio.addObservation('Slow down here.');
    await audio.setSpeed(1.25);
    expect(backend.at.inMilliseconds, 500);
    expect(backend.currentRate, 1.25);
    backend.failPlay = true;
    await expectLater(audio.playPause(), throwsStateError);
    expect(audio.error, isNotNull);
    backend.failPlay = false;
    backend.errorDuringPlay = 'decoder rejected output';
    await audio.playPause();
    expect(audio.playing, isFalse);
    expect(audio.error, contains('Playback failed'));
    backend.errorDuringPlay = null;
    await audio.playPause();
    backend.errors.add('lost output');
    await Future<void>.delayed(Duration.zero);
    expect(audio.playing, isFalse);
    await audio.playPause();
    await store.fileFor(row.relativePath).delete();
    await expectLater(audio.select(row), throwsA(isA<AudioFailure>()));
    expect(
      (await db.select(db.audioObservations).get()).single.note,
      'Slow down here.',
    );
    await expectLater(
      store.observe(row.id, 5000, 'outside file'),
      throwsArgumentError,
    );
    expect(() => store.fileFor('../private.wav'), throwsArgumentError);
  });

  test('pending recovery repairs interrupted frames, marks missing files and preserves stable IDs', () async {
    final row = await store.reserve(sessionId, 'test', 'Fixture input');
    await writeTestWave(store.fileFor(row.relativePath).path, unfinished: true);
    final missing = await store.reserve(sessionId, 'test', 'Missing input');
    await store.reconcile();
    final recovered = await store.load(row.id);
    expect(recovered.state, 'finalized');
    expect(recovered.interrupted, isTrue);
    expect(recovered.durationMs, 1000);
    expect((await store.load(missing.id)).state, 'unavailable');
    await store.reconcile();
    expect((await store.load(row.id)).relativePath, row.relativePath);
    expect((await db.select(db.audioRecordings).get()).length, 2);
  });
}
