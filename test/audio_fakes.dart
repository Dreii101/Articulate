import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:articulate/audio/audio_backend.dart';
import 'package:record/record.dart';

// Synthetic PCM is a controller/parser fixture, never hardware verification.
Future<void> writeTestWave(
  String path, {
  bool unfinished = false,
  bool silent = false,
  int sampleRate = 48000,
  int channels = 1,
  int milliseconds = 1000,
}) async {
  final frames = sampleRate * milliseconds ~/ 1000,
      dataBytes = sampleRate * milliseconds ~/ 1000 * channels * 2;
  final bytes = Uint8List(44 + dataBytes),
      data = ByteData.view(Uint8List(44 + dataBytes).buffer);
  void tag(int at, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(at + i, value.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  data.setUint32(4, unfinished ? 36 : 36 + dataBytes, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channels, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * channels * 2, Endian.little);
  data.setUint16(32, channels * 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  tag(36, 'data');
  data.setUint32(40, unfinished ? 0 : dataBytes, Endian.little);
  for (var i = 0; i < frames * channels; i++) {
    data.setInt16(
      44 + i * 2,
      silent
          ? 0
          : (10000 * sin(2 * pi * 440 * i / (sampleRate * channels))).round(),
      Endian.little,
    );
  }
  bytes.setAll(0, data.buffer.asUint8List());
  await File(path).parent.create(recursive: true);
  await File(path).writeAsBytes(bytes, flush: true);
}

class FakeAudioBackend implements AudioBackend {
  bool allowed = true,
      encoder = true,
      recording = false,
      failStart = false,
      failStop = false,
      failReset = false,
      failPlay = false,
      diskError = false;
  int free = 100 * 1024 * 1024, starts = 0, stops = 0, opens = 0, plays = 0;
  double currentRate = 1;
  Duration at = Duration.zero;
  String? path;
  String? errorDuringPlay;
  List<InputDevice> devices = [
    const InputDevice(
      id: 'fixture-mic',
      label: 'Synthetic test input',
      sampleRates: [48000],
    ),
  ];
  final events = <String>[];
  final states = StreamController<RecordState>.broadcast(),
      interrupted = StreamController<String>.broadcast(),
      errors = StreamController<String>.broadcast(),
      position = StreamController<Duration>.broadcast(),
      playingState = StreamController<bool>.broadcast(),
      ended = StreamController<bool>.broadcast();
  @override
  Future<bool> permission() async => allowed;
  @override
  Future<List<InputDevice>> inputs() async => devices;
  @override
  Future<bool> wavSupported() async => encoder;
  @override
  Future<int> freeBytes(String path) async {
    if (diskError) throw StateError('storage probe failed');
    return free;
  }

  @override
  Future<void> start(String output, InputDevice? input) async {
    starts++;
    events.add('capture-start');
    path = output;
    if (failStart) throw StateError('capture failed');
    await writeTestWave(output);
    recording = true;
    states.add(RecordState.record);
  }

  @override
  Future<String?> stop() async {
    stops++;
    events.add('capture-stop');
    if (failStop) throw StateError('stop failed');
    recording = false;
    states.add(RecordState.stop);
    return path;
  }

  @override
  Future<void> pauseCapture() async {
    events.add('capture-pause');
    states.add(RecordState.pause);
  }

  @override
  Future<void> resumeCapture() async {
    events.add('capture-resume');
    states.add(RecordState.record);
  }

  @override
  Future<void> resetCapture() async {
    events.add('capture-reset');
    if (failReset) throw StateError('reset failed');
    recording = false;
  }

  @override
  Future<bool> isRecording() async => recording;
  @override
  Future<double> amplitude() async => -12;
  @override
  Stream<RecordState> get captureStates => states.stream;
  @override
  Stream<String> get interruptions => interrupted.stream;
  @override
  Stream<String> get playbackErrors => errors.stream;
  @override
  Stream<Duration> get positions => position.stream;
  @override
  Stream<bool> get playing => playingState.stream;
  @override
  Stream<bool> get completed => ended.stream;
  @override
  Future<void> open(String path) async {
    opens++;
    events.add('playback-open');
  }

  @override
  Future<void> play() async {
    if (failPlay) throw StateError('output failed');
    if (errorDuringPlay != null) {
      errors.add(errorDuringPlay!);
      await Future<void>.delayed(Duration.zero);
    }
    plays++;
    events.add('playback-play');
    playingState.add(true);
  }

  @override
  Future<void> pausePlayback() async {
    events.add('playback-pause');
    playingState.add(false);
  }

  @override
  Future<void> stopPlayback() async {
    events.add('playback-stop');
    playingState.add(false);
  }

  @override
  Future<void> seek(Duration value) async {
    at = value;
    position.add(value);
  }

  @override
  Future<void> speed(double value) async {
    currentRate = value;
  }

  @override
  Future<void> dispose() async {
    await states.close();
    await interrupted.close();
    await errors.close();
    await position.close();
    await playingState.close();
    await ended.close();
  }
}
