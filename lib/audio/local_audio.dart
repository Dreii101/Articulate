import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:record/record.dart';

import '../storage/database.dart';
import 'audio_backend.dart';
import 'audio_store.dart';

enum AudioMode { idle, preparing, recording, paused, stopping }

class AudioFailure implements Exception {
  const AudioFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class LocalAudio extends ChangeNotifier {
  LocalAudio(
    this.store,
    this.backend, {
    bool? windows,
    this.automaticHeartbeat = true,
  }) : windows = windows ?? Platform.isWindows {
    _subs.addAll([
      backend.captureStates.listen(
        (state) {
          if (mode == AudioMode.recording && state != RecordState.record) {
            interrupt('The microphone was interrupted.');
          }
        },
        onError: (Object e) =>
            interrupt('The input failed or was disconnected.'),
      ),
      backend.interruptions.listen(interrupt),
      backend.playbackErrors.listen((e) {
        playing = false;
        _loadedId = null;
        error = 'Playback failed. Check the output device and try Play again.';
        _emit();
      }),
      backend.positions.listen((v) {
        position = v;
        _emit();
      }),
      backend.playing.listen((v) {
        playing = v && error == null && mode == AudioMode.idle;
        _emit();
      }),
      backend.completed.listen((v) {
        if (v) {
          playing = false;
          _ended = true;
          _emit();
        }
      }),
    ]);
  }
  final AudioStore store;
  final AudioBackend backend;
  final bool windows, automaticHeartbeat;
  final _subs = <StreamSubscription<dynamic>>[];
  Future<void> _tail = Future.value();
  Timer? _heartbeat;
  final _captureWatch = Stopwatch();
  AudioRecording? active, selected, lastStopped;
  AudioMode mode = AudioMode.idle;
  List<InputDevice> inputs = [];
  InputDevice? input;
  String? error;
  String capability =
      'Microphone not checked. Unrecorded rehearsal is available.';
  double amplitudeDb = -120, rate = 1;
  bool playing = false,
      busy = false,
      _ended = false,
      _disposed = false,
      _polling = false;
  Duration position = Duration.zero;
  String? _loadedId;
  Future<void>? _closing;
  int get captureMs => _captureWatch.elapsedMilliseconds;
  bool get capturing => active != null;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<T> _queue<T>(Future<T> Function() operation) {
    final result = _tail.then((_) async {
      busy = true;
      _emit();
      try {
        final value = await operation();
        return value;
      } catch (e) {
        error = e is AudioFailure ? e.message : 'Audio operation failed. Check input/output access and available storage. Unrecorded notes are still available.';
        rethrow;
      } finally {
        busy = false;
        _emit();
      }
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> refreshInputs() => _queue(() async {
    if (capturing) {
      throw const AudioFailure('Stop the take before changing input.');
    }
    if (!await backend.permission()) {
      throw const AudioFailure(
        'Microphone permission denied. Allow microphone access in system settings, then retry. You can rehearse without recording.',
      );
    }
    inputs = await backend.inputs();
    if (input != null && !inputs.any((d) => d.id == input!.id)) input = null;
    final wav = await backend.wavSupported();
    capability =
        'WAV encoder: ${wav ? 'reported supported' : 'unavailable'}. Requested: PCM16, 48 kHz mono. A microphone check verifies the actual file.';
    if (inputs.isEmpty) {
      throw const AudioFailure(
        'No microphone input is available. Connect one and refresh, or use unrecorded rehearsal.',
      );
    }
    error = null;
  });
  void chooseInput(String? id) {
    if (capturing || busy) return;
    input = id == null ? null : inputs.firstWhere((d) => d.id == id);
    _emit();
  }

  Future<AudioRecording> start(
    String sessionId, {
    bool microphoneCheck = false,
    String contextKey = '',
  }) => _queue(() async {
    if (active != null) {
      if (active!.sessionId != sessionId || active!.contextKey != contextKey) {
        throw const AudioFailure(
          'Another rehearsal owns the microphone. Stop it first.',
        );
      }
      return active!;
    }
    mode = AudioMode.preparing;
    _emit();
    try {
      if (!await backend.permission()) {
        throw const AudioFailure(
          'Microphone permission denied. Enable microphone access and retry, or continue with unrecorded rehearsal.',
        );
      }
      final devices = await backend.inputs();
      inputs = devices;
      if (devices.isEmpty ||
          (input != null && !devices.any((d) => d.id == input!.id))) {
        throw const AudioFailure(
          'Selected microphone is unavailable. Refresh inputs or rehearse without recording.',
        );
      }
      if (!await backend.wavSupported()) {
        throw const AudioFailure(
          'This device reports no WAV encoder support. Unrecorded rehearsal remains available.',
        );
      }
      await store.prepare();
      if (await backend.freeBytes(store.root.path) < 20 * 1024 * 1024) {
        throw const AudioFailure(
          'Less than 20 MB storage is available. Free space before recording; your existing takes are retained.',
        );
      }
      await backend.stopPlayback();
      playing = false;
      selected = null;
      position = Duration.zero;
      final row = await store.reserve(
        sessionId,
        input?.id ?? 'system-default',
        input?.label ?? 'System default input',
        microphoneCheck: microphoneCheck,
        contextKey: contextKey,
      );
      active = row;
      await backend.start(store.fileFor(row.relativePath).path, input);
      mode = AudioMode.recording;
      _captureWatch.reset();
      _captureWatch.start();
      error = null;
      amplitudeDb = -120;
      if (automaticHeartbeat) {
        _heartbeat = Timer.periodic(const Duration(seconds: 1), (_) => _poll());
      }
      return row;
    } catch (_) {
      if (active != null) {
        await backend.resetCapture();
        await store.finalize(
          active!.id,
          interrupted: true,
          reason: 'The microphone could not start.',
        );
        active = null;
      }
      mode = AudioMode.idle;
      rethrow;
    }
  });

  Future<void> pause() => _queue(() async {
    if (mode != AudioMode.recording) return;
    mode = AudioMode.paused;
    _captureWatch.stop();
    try {
      await backend.pauseCapture();
    } catch (_) {
      await _stop(
        reason: 'Pause failed; the take was stopped safely.',
        interrupted: true,
      );
      rethrow;
    }
  });
  Future<void> resume() => _queue(() async {
    if (mode != AudioMode.paused) return;
    try {
      await backend.resumeCapture();
      mode = AudioMode.recording;
      _captureWatch.start();
    } catch (_) {
      await _stop(reason: 'Resume failed.', interrupted: true);
      rethrow;
    }
  });

  Future<AudioRecording?> _stop({
    String reason = '',
    bool interrupted = false,
  }) async {
    final row = active;
    if (row == null) return lastStopped;
    mode = AudioMode.stopping;
    _heartbeat?.cancel();
    _heartbeat = null;
    _captureWatch.stop();
    _emit();
    var engineStopped = false;
    try {
      try {
        await backend.stop();
        engineStopped = true;
      } catch (_) {
        await backend.resetCapture();
        engineStopped = true;
        interrupted = true;
        reason =
            '$reason Recorder stop failed; recovered only validated file frames.';
      }
      final saved = await store.finalize(
        row.id,
        interrupted: interrupted,
        reason: reason,
      );
      lastStopped = saved;
      selected = saved;
      _loadedId = null;
      position = Duration.zero;
      _ended = false;
      if (saved.state == 'unavailable') error = saved.statusNote;
      return saved;
    } finally {
      if (engineStopped) {
        active = null;
        mode = AudioMode.idle;
      } else {
        mode = AudioMode.paused;
        error = 'The microphone did not confirm stopping. Retry Stop before leaving or starting playback.';
      }
    }
  }

  Future<AudioRecording?> stop() => _queue(() => _stop());
  Future<void> interrupt(String reason) async {
    final id = active?.id;
    if (id == null) return;
    try {
      await _queue(() async {
        if (active?.id == id) {
          await _stop(reason: reason, interrupted: true);
          error =
              '$reason The take was stopped and any valid audio retained. Start a new take explicitly.';
        }
      });
    } catch (_) {
      /* The pending record remains available for startup reconciliation. */
    }
  }

  Future<void> lifecycle(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed ||
        (windows && state == AppLifecycleState.inactive)) {
      return;
    }
    if (capturing) {
      await interrupt(
        windows
            ? 'Window hidden or desktop interrupted.'
            : 'App left the foreground.',
      );
    }
    if (state != AppLifecycleState.inactive || !windows) {
      await _queue(() async {
        await backend.pausePlayback();
        playing = false;
      });
    }
  }

  Future<void> _poll() async {
    if (_polling || busy || active == null) return;
    _polling = true;
    try {
      await heartbeat();
    } catch (_) {
      /* Visible error is retained by the queued operation. */
    } finally {
      _polling = false;
    }
  }

  Future<void> heartbeat() => _queue(() async {
    final row = active;
    if (row == null) return;
    try {
      String? reason;
      if (await backend.freeBytes(store.root.path) < 5 * 1024 * 1024) {
        reason = 'Storage is nearly full.';
      }
      if (input != null &&
          !(await backend.inputs()).any((d) => d.id == input!.id)) {
        reason = 'The selected input was disconnected.';
      }
      if (!await backend.isRecording()) {
        reason = 'The recorder stopped unexpectedly.';
      }
      if (mode == AudioMode.recording) amplitudeDb = await backend.amplitude();
      if (row.microphoneCheck && captureMs >= 3000) {
        await _stop();
        return;
      }
      if (reason != null) {
        await _stop(interrupted: true, reason: reason);
        error = reason;
      }
    } catch (_) {
      if (active != null) {
        await _stop(
          interrupted: true,
          reason: 'Input or storage monitoring failed.',
        );
      }
      rethrow;
    }
  });

  Future<void> select(AudioRecording row) => _queue(() async {
    if (capturing) {
      throw const AudioFailure('Stop the microphone before playback.');
    }
    if (row.state != 'finalized' ||
        !await store.fileFor(row.relativePath).exists()) {
      throw const AudioFailure(
        'Recording file is missing or unavailable. Notes and observations are retained.',
      );
    }
    error = null;
    await backend.stopPlayback();
    playing = false;
    await backend.open(store.fileFor(row.relativePath).path);
    await backend.speed(rate);
    selected = row;
    _loadedId = row.id;
    position = Duration.zero;
    _ended = false;
  });
  Future<void> playPause() => _queue(() async {
    if (capturing) {
      throw const AudioFailure('Stop recording before playing audio.');
    }
    final row = selected;
    if (row == null ||
        row.state != 'finalized' ||
        !await store.fileFor(row.relativePath).exists()) {
      throw const AudioFailure(
        'Choose an available saved take first. Missing files do not remove your notes.',
      );
    }
    if (playing) {
      await backend.pausePlayback();
      playing = false;
    } else {
      final reload = error != null || _loadedId != row.id;
      error = null;
      if (reload) {
        await backend.open(store.fileFor(row.relativePath).path);
        await backend.speed(rate);
        _loadedId = row.id;
      }
      if (_ended) {
        await backend.seek(Duration.zero);
        _ended = false;
      }
      await backend.play();
      playing = error == null;
    }
  });
  Future<void> seek(int ms) => _queue(() async {
    if (capturing || selected == null || ms < 0 || ms > selected!.durationMs) {
      throw const AudioFailure('Choose a timestamp within the stopped take.');
    }
    if (_loadedId != selected!.id) {
      await backend.open(store.fileFor(selected!.relativePath).path);
      await backend.speed(rate);
      _loadedId = selected!.id;
    }
    await backend.seek(Duration(milliseconds: ms));
    position = Duration(milliseconds: ms);
    _ended = false;
  });
  Future<void> setSpeed(double value) => _queue(() async {
    if (capturing || ![0.75, 1.0, 1.25, 1.5].contains(value)) {
      throw const AudioFailure(
        'Choose an available playback speed after stopping capture.',
      );
    }
    await backend.speed(value);
    rate = value;
  });
  Future<void> addObservation(String text) => _queue(() async {
    if (capturing || selected == null) {
      throw const AudioFailure(
        'Select a saved take before adding an observation.',
      );
    }
    await store.observe(
      selected!.id,
      position.inMilliseconds.clamp(0, selected!.durationMs),
      text,
    );
  });

  Future<void> close() => _closing ??= _close();
  Future<void> _close() async {
    if (_disposed) return;
    try {
      await _queue(() async {
        await _stop(reason: 'Studio closed.', interrupted: true);
        await backend.stopPlayback();
      });
    } finally {
      _heartbeat?.cancel();
      for (final s in _subs) {
        await s.cancel();
      }
      try {
        await backend.dispose();
      } finally {
        _disposed = true;
        super.dispose();
      }
    }
  }
}
