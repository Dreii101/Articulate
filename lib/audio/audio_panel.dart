import 'package:flutter/material.dart';

import '../storage/database.dart';
import 'local_audio.dart';

String audioTime(int ms) {
  final seconds = ms ~/ 1000;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class LocalAudioPanel extends StatefulWidget {
  const LocalAudioPanel({
    super.key,
    required this.sessionId,
    required this.audio,
    required this.readOnly,
    required this.observationController,
    this.emptyMessage = 'No recording yet. Notes and unrecorded rehearsal are ready whenever you are.',
    this.takeLabel = 'Speech take',
    this.contextKey = '',
  });
  final String sessionId, contextKey;
  final LocalAudio audio;
  final bool readOnly;
  final TextEditingController observationController;
  final String emptyMessage, takeLabel;
  @override
  State<LocalAudioPanel> createState() => _LocalAudioPanelState();
}

class _LocalAudioPanelState extends State<LocalAudioPanel> {
  LocalAudio? _audio;
  String? _scope;
  Stream<List<AudioRecording>>? _takes;
  Stream<List<AudioObservation>>? _observations;
  String? _observationId;
  double? _seekPreview;
  TextEditingController get _observation => widget.observationController;
  Future<void> _audioAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      /* Service exposes the error beside its controls. */
    }
  }

  Widget _card(List<Widget> children) => Card.outlined(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final a = widget.audio;
    if (!identical(_audio, a) ||
        _scope != '${widget.sessionId}/${widget.contextKey}') {
      _scope = '${widget.sessionId}/${widget.contextKey}';
      _audio = a;
      _takes = a.store.watch(widget.sessionId, contextKey: widget.contextKey);
      _observationId = null;
    }
    final closed = widget.readOnly;
    return ListenableBuilder(
      listenable: a,
      builder: (context, child) {
        final selected =
            a.selected?.sessionId == widget.sessionId &&
                a.selected?.contextKey == widget.contextKey
            ? a.selected
            : null;
        final other =
            a.active != null &&
            (a.active!.sessionId != widget.sessionId ||
                a.active!.contextKey != widget.contextKey);
        if (selected != null && selected.id != _observationId) {
          _observationId = selected.id;
          _seekPreview = null;
          _observations = a.store.observations(selected.id);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _card([
              Text(
                'Microphone & local capture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Requested format: PCM16 WAV · 48 kHz · mono. Starting capture stops playback. The 3-second microphone check is saved so you can listen to it.',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const ValueKey('refresh-speech-inputs'),
                onPressed: a.busy || a.capturing
                    ? null
                    : () => _audioAction(a.refreshInputs),
                child: const Text('Refresh microphone inputs'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'speech-input-${a.input?.id ?? 'default'}-${a.inputs.length}',
                ),
                initialValue: a.input?.id ?? 'default',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Input device',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'default',
                    child: Text('System default input'),
                  ),
                  for (final d in a.inputs)
                    DropdownMenuItem(
                      value: d.id,
                      child: Text(
                        d.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: a.busy || a.capturing
                    ? null
                    : (v) => a.chooseInput(v == 'default' ? null : v),
              ),
              if (a.input != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: ${a.input!.label}\nReported sample rates: ${a.input!.sampleRates.isEmpty ? 'not reported' : a.input!.sampleRates.join(', ')}',
                  ),
                ),
              const SizedBox(height: 12),
              Text(a.capability),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(switch (a.mode) {
                  AudioMode.preparing => 'Preparing microphone…',
                  AudioMode.stopping => 'Finalizing WAV…',
                  AudioMode.idle => 'Microphone idle',
                  _ =>
                    a.mode == AudioMode.paused
                        ? 'Microphone paused'
                        : 'Microphone recording',
                }, key: const ValueKey('speech-audio-status')),
              ),
              if (a.capturing)
                Text(
                  'Elapsed ${audioTime(a.captureMs)} · input ${a.amplitudeDb.toStringAsFixed(1)} dBFS',
                ),
              if (a.capturing)
                LinearProgressIndicator(
                  value: ((a.amplitudeDb + 60) / 60).clamp(0, 1),
                  semanticsLabel: 'Microphone input level',
                ),
              if (a.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      a.error!,
                      key: const ValueKey('speech-audio-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              if (other)
                const Text(
                  'Another rehearsal owns the microphone. Return there and stop its take.',
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!a.capturing) ...[
                    FilledButton(
                      key: const ValueKey('speech-record'),
                      onPressed: closed || a.busy
                          ? null
                          : () => _audioAction(() async {
                              await a.start(
                                widget.sessionId,
                                contextKey: widget.contextKey,
                              );
                            }),
                      child: const Text('Record take'),
                    ),
                    OutlinedButton(
                      key: const ValueKey('speech-mic-check'),
                      onPressed: closed || a.busy
                          ? null
                          : () => _audioAction(() async {
                              await a.start(
                                widget.sessionId,
                                microphoneCheck: true,
                                contextKey: widget.contextKey,
                              );
                            }),
                      child: const Text('3-second microphone check'),
                    ),
                  ],
                  if (a.capturing && !other) ...[
                    OutlinedButton(
                      key: const ValueKey('speech-pause-recording'),
                      onPressed: a.busy
                          ? null
                          : () => _audioAction(
                              a.mode == AudioMode.paused ? a.resume : a.pause,
                            ),
                      child: Text(
                        a.mode == AudioMode.paused
                            ? 'Resume capture'
                            : 'Pause capture',
                      ),
                    ),
                    FilledButton(
                      key: const ValueKey('speech-stop'),
                      onPressed: a.busy
                          ? null
                          : () => _audioAction(() async {
                              await a.stop();
                            }),
                      child: const Text('Stop & save take'),
                    ),
                  ],
                ],
              ),
            ]),
            const SizedBox(height: 16),
            StreamBuilder<List<AudioRecording>>(
              stream: _takes,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Saved takes could not be loaded. Retry by reopening the rehearsal; files have not been reset.',
                  );
                }
                final rows = snapshot.data ?? [];
                return _card([
                  Text(
                    'Saved takes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (rows.isEmpty) Text(widget.emptyMessage),
                  for (final r in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${r.microphoneCheck ? 'Microphone check' : widget.takeLabel} · ${audioTime(r.durationMs)} · ${r.state}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(r.inputName),
                          if (r.state == 'finalized')
                            Text(
                              'Actual PCM16 WAV: ${r.sampleRate} Hz · ${r.channels} channel(s) · ${r.byteCount} bytes\nRMS ${r.rmsDb?.toStringAsFixed(1)} dBFS · peak ${r.peakDb?.toStringAsFixed(1)} dBFS',
                            ),
                          if (r.statusNote.isNotEmpty) Text(r.statusNote),
                          if (r.state == 'finalized')
                            OutlinedButton(
                              key: ValueKey('listen-${r.id}'),
                              onPressed: a.busy || a.capturing
                                  ? null
                                  : () => _audioAction(() => a.select(r)),
                              child: Text(
                                selected?.id == r.id
                                    ? 'Selected for listening'
                                    : 'Listen to this take',
                              ),
                            ),
                        ],
                      ),
                    ),
                ]);
              },
            ),
            if (selected != null) ...[
              const SizedBox(height: 16),
              _card([
                Text(
                  'Listen & notice',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '${audioTime(a.position.inMilliseconds.clamp(0, selected.durationMs))} / ${audioTime(selected.durationMs)}',
                ),
                Slider(
                  key: const ValueKey('speech-seek'),
                  value: (_seekPreview ?? a.position.inMilliseconds.toDouble())
                      .clamp(0, selected.durationMs.toDouble()),
                  min: 0,
                  max: selected.durationMs.toDouble().clamp(1, double.infinity),
                  onChanged: a.busy || a.capturing
                      ? null
                      : (v) => setState(() => _seekPreview = v),
                  onChangeEnd: a.capturing
                      ? null
                      : (v) => _audioAction(() async {
                          try {
                            await a.seek(v.round());
                          } finally {
                            if (mounted) setState(() => _seekPreview = null);
                          }
                        }),
                  semanticFormatterCallback: (v) =>
                      'Playback position ${audioTime(v.round())}',
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      key: const ValueKey('speech-play'),
                      onPressed: a.busy || a.capturing
                          ? null
                          : () => _audioAction(a.playPause),
                      child: Text(a.playing ? 'Pause playback' : 'Play take'),
                    ),
                    SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<double>(
                        key: ValueKey('speech-speed-${a.rate}'),
                        initialValue: a.rate,
                        decoration: const InputDecoration(
                          labelText: 'Playback speed',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final speed in [0.75, 1.0, 1.25, 1.5])
                            DropdownMenuItem(
                              value: speed,
                              child: Text('$speed×'),
                            ),
                        ],
                        onChanged: a.busy || a.capturing
                            ? null
                            : (v) => _audioAction(() => a.setSpeed(v!)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  key: const ValueKey('speech-observation'),
                  controller: _observation,
                  minLines: 2,
                  maxLines: 5,
                  maxLength: 4000,
                  decoration: const InputDecoration(
                    labelText: 'Observation at the playback position',
                    hintText: 'For example: pause here and make the main point clearer.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const ValueKey('add-speech-observation'),
                  onPressed: a.busy || a.capturing
                      ? null
                      : () => _audioAction(() async {
                          await a.addObservation(_observation.text);
                          _observation.clear();
                        }),
                  child: const Text('Save timestamped observation'),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<AudioObservation>>(
                  stream: _observations,
                  builder: (context, snapshot) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (snapshot.hasError)
                        const Text(
                          'Observations could not be loaded. Reopen this rehearsal to retry.',
                        ),
                      for (final o in snapshot.data ?? <AudioObservation>[])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: a.busy || a.capturing
                                    ? null
                                    : () => _audioAction(
                                        () => a.seek(o.positionMs),
                                      ),
                                child: Text(
                                  'Jump to ${audioTime(o.positionMs)}',
                                ),
                              ),
                              SelectableText(o.note),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ]),
            ],
          ],
        );
      },
    );
  }
}
