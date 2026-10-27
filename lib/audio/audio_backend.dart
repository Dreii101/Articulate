import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:record/record.dart';

abstract class AudioBackend {
  Future<bool> permission();
  Future<List<InputDevice>> inputs();
  Future<bool> wavSupported();
  Future<int> freeBytes(String path);
  Future<void> start(String path, InputDevice? device);
  Future<String?> stop();
  Future<void> pauseCapture();
  Future<void> resumeCapture();
  Future<void> resetCapture();
  Future<bool> isRecording();
  Future<double> amplitude();
  Stream<RecordState> get captureStates;
  Stream<String> get interruptions;
  Stream<String> get playbackErrors;
  Stream<Duration> get positions;
  Stream<bool> get playing;
  Stream<bool> get completed;
  Future<void> open(String path);
  Future<void> play();
  Future<void> pausePlayback();
  Future<void> stopPlayback();
  Future<void> seek(Duration position);
  Future<void> speed(double value);
  Future<void> dispose();
}

class NativeAudioBackend implements AudioBackend {
  AudioRecorder? _recorder;
  Player? _player;
  final _states = StreamController<RecordState>.broadcast(),
      _playing = StreamController<bool>.broadcast(),
      _completed = StreamController<bool>.broadcast();
  final _interruptions = StreamController<String>.broadcast(),
      _errors = StreamController<String>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  StreamSubscription<RecordState>? _recordSub;
  final _playerSubs = <StreamSubscription<dynamic>>[];
  static const channel = MethodChannel('articulate/audio_platform');
  NativeAudioBackend() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'audioInterrupted') {
        _interruptions.add(call.arguments as String);
      }
    });
  }
  AudioRecorder get recorder {
    if (_recorder == null) {
      _recorder = AudioRecorder();
      _recordSub = _recorder!.onStateChanged().listen(
        _states.add,
        onError: (Object e, StackTrace s) => _states.addError(e, s),
      );
    }
    return _recorder!;
  }

  Player get player {
    if (_player == null) {
      MediaKit.ensureInitialized();
      _player = Player(
        configuration: const PlayerConfiguration(
          title: 'Articulate audio',
          protocolWhitelist: ['file'],
        ),
      );
      _playerSubs.addAll([
        _player!.stream.position.listen(_positions.add),
        _player!.stream.playing.listen(_playing.add),
        _player!.stream.completed.listen(_completed.add),
        _player!.stream.error.listen(_errors.add),
      ]);
    }
    return _player!;
  }

  @override
  Future<bool> permission() => recorder.hasPermission();
  @override
  Future<List<InputDevice>> inputs() => recorder.listInputDevices();
  @override
  Future<bool> wavSupported() => recorder.isEncoderSupported(AudioEncoder.wav);
  @override
  Future<int> freeBytes(String path) async =>
      (await channel.invokeMethod<int>('freeBytes', path))!;
  @override
  Future<void> start(String path, InputDevice? device) => recorder.start(
    RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 48000,
      numChannels: 1,
      device: device,
      audioInterruption: AudioInterruptionMode.pause,
      androidConfig: const AndroidRecordConfig(manageBluetooth: false),
    ),
    path: path,
  );
  @override
  Future<String?> stop() => recorder.stop();
  @override
  Future<void> pauseCapture() => recorder.pause();
  @override
  Future<void> resumeCapture() => recorder.resume();
  @override
  // Windows reports false from isRecording while paused; both states own the input.
  Future<bool> isRecording() async =>
      await recorder.isRecording() || await recorder.isPaused();
  @override
  Future<double> amplitude() async => (await recorder.getAmplitude()).current;
  @override
  Future<void> resetCapture() async {
    await _recordSub?.cancel();
    _recordSub = null;
    await _recorder?.dispose();
    _recorder = null;
  }

  @override
  Stream<RecordState> get captureStates => _states.stream;
  @override
  Stream<String> get interruptions => _interruptions.stream;
  @override
  Stream<String> get playbackErrors => _errors.stream;
  @override
  Stream<Duration> get positions => _positions.stream;
  @override
  Stream<bool> get playing => _playing.stream;
  @override
  Stream<bool> get completed => _completed.stream;
  @override
  Future<void> open(String path) async {
    if (!File(path).isAbsolute ||
        path.startsWith(r'\\') ||
        path.startsWith('//')) {
      throw ArgumentError('Playback requires an absolute local file path.');
    }
    await player.open(Media(path), play: false);
  }

  @override
  Future<void> play() => player.play();
  @override
  Future<void> pausePlayback() async {
    await _player?.pause();
  }

  @override
  Future<void> stopPlayback() async {
    await _player?.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);
  @override
  Future<void> speed(double value) => player.setRate(value);
  @override
  Future<void> dispose() async {
    channel.setMethodCallHandler(null);
    await resetCapture();
    for (final s in _playerSubs) {
      await s.cancel();
    }
    await _player?.dispose();
    await _states.close();
    await _playing.close();
    await _completed.close();
    await _interruptions.close();
    await _errors.close();
    await _positions.close();
  }
}
