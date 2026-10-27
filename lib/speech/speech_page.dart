import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_provider.dart';
import '../audio/local_audio.dart';
import '../providers.dart';
import '../session_controller.dart';
import '../audio/audio_panel.dart';
import '../storage/practice_repository.dart';

class SpeechStudioPage extends ConsumerStatefulWidget {
  const SpeechStudioPage({super.key});
  @override
  ConsumerState<SpeechStudioPage> createState() => _SpeechStudioPageState();
}

class _SpeechStudioPageState extends ConsumerState<SpeechStudioPage> {
  bool _opening = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Speech Studio')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Make space to speak.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Prepare notes, rehearse freely, or record a local take and listen back. You decide what to notice; no speech is transcribed or automatically graded.',
                ),
                const SizedBox(height: 24),
                for (final e
                    in ref
                        .watch(exercisesProvider)
                        .where((e) => e.module == 'speech'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.level.toUpperCase()),
                            const SizedBox(height: 8),
                            Text(
                              e.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(e.prompt),
                            const SizedBox(height: 16),
                            FilledButton(
                              key: ValueKey('choose-${e.id}'),
                              onPressed: _opening
                                  ? null
                                  : () async {
                                      setState(() => _opening = true);
                                      try {
                                        final id = await ref
                                            .read(repositoryProvider)
                                            .createDraft(e, DateTime.now());
                                        if (context.mounted) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  SpeechPage(sessionId: id),
                                            ),
                                          );
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Could not open this rehearsal. Try again.',
                                                  ),
                                                ),
                                              );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _opening = false);
                                        }
                                      }
                                    },
                              child: const Text('Open rehearsal'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SpeechPage extends ConsumerStatefulWidget {
  const SpeechPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends ConsumerState<SpeechPage>
    with WidgetsBindingObserver {
  late final SessionController _session;
  final _notes = TextEditingController(), _reflection = TextEditingController();
  final _observation = TextEditingController();
  Timer? _autosave;
  Future<void> _tail = Future.value();
  bool _dirty = false, _reviewDirty = false, _busy = false, _canPop = false;
  String? _error;
  LocalAudio? _audio;
  bool _audioView = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = SessionController(
      ref.read(repositoryProvider),
      widget.sessionId,
    );
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _session.open();
      if (mounted) {
        setState(() {
          _notes.text = d.response.body;
          _reflection.text = d.review?.notes ?? '';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Saved rehearsal could not be opened. Your data has not been reset.',
        );
      }
    }
  }

  void _changed([String? value]) {
    setState(() => _dirty = true);
    _autosave?.cancel();
    _autosave = Timer(
      const Duration(milliseconds: 400),
      () => _run(() async {}, autosave: true),
    );
  }

  Future<void> _flush() async {
    _autosave?.cancel();
    if (_session.detail == null || !_dirty) return;
    final notes = _notes.text, reflection = _reflection.text;
    if (!isTerminal(_session.detail!.session.status) &&
        notes != _session.detail!.response.body) {
      await _session.saveResponse(notes);
    }
    if (_reviewDirty) {
      await _session.saveReview(reflection, ReviewStatus.inProgress);
      _reviewDirty = false;
    }
    if (mounted) {
      setState(
        () => _dirty = notes != _notes.text || reflection != _reflection.text,
      );
    }
  }

  Future<bool> _run(
    Future<void> Function() action, {
    bool autosave = false,
  }) async {
    if (_busy && !autosave) return false;
    if (!autosave && mounted) setState(() => _busy = true);
    final result = _tail.then((_) async {
      try {
        await _flush();
        await action();
        if (mounted) setState(() => _error = null);
        return true;
      } catch (_) {
        if (mounted) {
          setState(
            () => _error = 'Could not save your rehearsal. Keep this window open and try Save again.',
          );
        }
        return false;
      }
    });
    _tail = result.then<void>((_) {});
    final success = await result;
    if (!autosave && mounted) setState(() => _busy = false);
    return success;
  }

  Future<void> _audioAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      /* The shared service exposes the actionable error beside its controls. */
    }
  }

  Future<void> _leaveAudio() async {
    final a = _audio;
    if (a == null) return;
    await a.stop();
    await a.backend.pausePlayback();
  }

  Future<void> _back() async {
    if (await _run(() async {
          await _leaveAudio();
          await _session.leave();
        }) &&
        mounted) {
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _run(_session.leave, autosave: true);
      final a = _audio;
      if (a != null) _audioAction(() => a.lifecycle(state));
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _run(_leaveAudio, autosave: true)
      ? AppExitResponse.exit
      : AppExitResponse.cancel;
  @override
  void dispose() {
    _observation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    _notes.dispose();
    _reflection.dispose();
    super.dispose();
  }

  Widget _notesPanel() {
    final d = _session.detail!,
        terminal = isTerminal(_session.detail!.session.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          d.exercise.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        SelectableText(d.exercise.prompt),
        const SizedBox(height: 12),
        Text(
          'Exercise v${d.session.exerciseVersion} · rubric v${d.exercise.content['rubric']['version']} · ${d.session.localPracticeDate}',
        ),
        const SizedBox(height: 24),
        TextField(
          key: const ValueKey('speech-notes'),
          controller: _notes,
          readOnly: terminal,
          enabled: !_busy,
          minLines: 6,
          maxLines: 14,
          maxLength: PracticeRepository.maxResponseLength,
          decoration: const InputDecoration(
            labelText: 'Speech notes',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          onChanged: _changed,
        ),
        const SizedBox(height: 8),
        Text(
          _busy
              ? 'Saving rehearsal…'
              : _dirty
              ? 'Saving…'
              : 'Notes saved on this device',
          key: const ValueKey('speech-save-status'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy ? null : () => _run(() async {}),
              child: const Text('Save notes'),
            ),
            if (!terminal)
              OutlinedButton(
                key: const ValueKey('speech-unrecorded'),
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        await _leaveAudio();
                        await _session.changeStage(PracticeStage.respond);
                      }),
                child: const Text('Rehearse without recording'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Unrecorded rehearsal needs no microphone permission. Switching desktop focus keeps a take running; minimizing, hiding, locking, suspension or mobile backgrounding stops it. Start again explicitly after an interruption.',
        ),
        const SizedBox(height: 24),
        Text(
          'Your listening guide',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (final c in d.exercise.criteria)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('${c['label']}\n${c['description']}'),
          ),
        const SizedBox(height: 24),
        if (!terminal)
          FilledButton(
            key: const ValueKey('complete-speech'),
            onPressed: _busy
                ? null
                : () => _run(() async {
                    await _leaveAudio();
                    await _session.transition(PracticeStatus.completed);
                  }),
            child: const Text('Complete rehearsal'),
          ),
        if (d.session.status == 'completed') ...[
          TextField(
            key: const ValueKey('speech-reflection'),
            controller: _reflection,
            minLines: 3,
            maxLines: 8,
            maxLength: PracticeRepository.maxResponseLength,
            decoration: const InputDecoration(
              labelText: 'Your self-review (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              _reviewDirty = true;
              _changed(v);
            },
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _busy
                ? null
                : () => _run(
                    () => _session.saveReview(
                      _reflection.text,
                      ReviewStatus.reviewed,
                    ),
                  ),
            child: const Text('Save self-review'),
          ),
          const SizedBox(height: 8),
          Text('Human self-review · ${d.reviewStatus.name}'),
        ],
        const SizedBox(height: 24),
        Text(
          'Authorship: ${d.exercise.content['authorship']['creator']}\n${d.exercise.content['license']['notice']}',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canPop,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _back),
        title: const Text('Speech Studio'),
      ),
      body: SafeArea(
        child: _session.detail == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error ?? 'Opening your rehearsal…'),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final audio = ref.watch(localAudioProvider);
                  final panel = audio.when(
                    data: (a) {
                      _audio = a;
                      return LocalAudioPanel(
                        observationController: _observation,
                        sessionId: widget.sessionId,
                        audio: a,
                        readOnly: isTerminal(_session.detail!.session.status),
                      );
                    },
                    loading: () => const Text(
                      'Opening local audio. Your notes remain available.',
                    ),
                    error: (e, s) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Audio could not be opened. You can continue with unrecorded rehearsal.',
                        ),
                        TextButton(
                          onPressed: () => ref.invalidate(localAudioProvider),
                          child: const Text('Retry audio'),
                        ),
                      ],
                    ),
                  );
                  Widget scroll(Widget child, String name) =>
                      SingleChildScrollView(
                        key: PageStorageKey('speech-${widget.sessionId}-$name'),
                        padding: const EdgeInsets.all(24),
                        child: child,
                      );
                  final notes = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null)
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      _notesPanel(),
                    ],
                  );
                  return constraints.maxWidth >= 1180 &&
                          MediaQuery.textScalerOf(context).scale(16) <= 21
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: scroll(notes, 'notes')),
                            const VerticalDivider(width: 1),
                            Expanded(child: scroll(panel, 'audio')),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    key: const ValueKey('speech-view-notes'),
                                    label: const Text('Notes & rehearsal'),
                                    selected: !_audioView,
                                    onSelected: (_) =>
                                        setState(() => _audioView = false),
                                  ),
                                  ChoiceChip(
                                    key: const ValueKey('speech-view-audio'),
                                    label: const Text('Record & listen'),
                                    selected: _audioView,
                                    onSelected: (_) =>
                                        setState(() => _audioView = true),
                                  ),
                                ],
                              ),
                            ),
                            if (audio.value case final a?)
                              ListenableBuilder(
                                listenable: a,
                                builder: (context, child) => a.capturing
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        child: Text(
                                          '${a.mode == AudioMode.paused ? 'Microphone paused' : 'Microphone active'} · ${audioTime(a.captureMs)}',
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            if (_audioView && _error != null)
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 900,
                                  ),
                                  child: scroll(
                                    _audioView ? panel : notes,
                                    _audioView ? 'audio' : 'notes',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
      ),
    ),
  );
}
