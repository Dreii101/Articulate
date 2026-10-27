import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_panel.dart';
import '../audio/audio_provider.dart';
import '../audio/local_audio.dart';
import '../providers.dart';
import '../storage/practice_repository.dart';
import 'impromptu_content.dart';
import 'impromptu_controller.dart';
import 'impromptu_repository.dart';

Widget _card(List<Widget> children) => Card.outlined(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  ),
);
Widget _scroll(Widget child) => SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: child,
    ),
  ),
);
Widget _choice(
  String label,
  String value,
  Map<String, String> choices,
  ValueChanged<String>? changed,
) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: DropdownButtonFormField<String>(
    key: ValueKey('impromptu-$label-$value'),
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    items: [
      for (final e in choices.entries)
        DropdownMenuItem(
          value: e.key,
          child: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: changed == null ? null : (v) => changed(v!),
  ),
);

class ImpromptuSetupPage extends ConsumerStatefulWidget {
  const ImpromptuSetupPage({super.key});
  @override
  ConsumerState<ImpromptuSetupPage> createState() => _ImpromptuSetupPageState();
}

class _ImpromptuSetupPageState extends ConsumerState<ImpromptuSetupPage> {
  final _form = GlobalKey<FormState>();
  final _targets = [
    TextEditingController(text: '0'),
    TextEditingController(text: '0'),
  ];
  String _level = 'beginner',
      _category = 'all',
      _kind = 'unrecorded',
      _preset = 'Untimed',
      _request = stableId();
  String? _error;
  bool _busy = false;
  @override
  void dispose() {
    for (final c in _targets) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy || !_form.currentState!.validate()) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final pool = ref
          .read(exercisesProvider)
          .where(
            (e) =>
                e.content.containsKey('impromptu') &&
                e.level == _level &&
                (_category == 'all' ||
                    e.content['impromptu']['category'] == _category),
          )
          .toList();
      final id = await ref
          .read(impromptuRepositoryProvider)
          .start(
            pool,
            _request,
            _kind,
            _preset,
            _targets.map((c) => int.parse(c.text)).toList(),
            DateTime.now(),
          );
      if (!mounted) {
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => ImpromptuPage(sessionId: id)),
      );
      _request = stableId();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not start this challenge. Retry to reopen the same reserved question.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = ref
        .watch(exercisesProvider)
        .where(
          (e) =>
              e.content.containsKey('impromptu') &&
              e.level == _level &&
              (_category == 'all' ||
                  e.content['impromptu']['category'] == _category),
        )
        .length;
    return Scaffold(
      appBar: AppBar(title: const Text('Impromptu Arena')),
      body: SafeArea(
        child: _scroll(
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Find your answer in the moment.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Original local questions. Prepare, speak or write, then reflect. No generated questions, transcript or automatic performance analysis.',
                ),
                const SizedBox(height: 20),
                _choice('Level', _level, const {
                  'beginner': 'Beginner',
                  'intermediate': 'Intermediate',
                  'advanced': 'Advanced',
                }, _busy ? null : (v) => setState(() => _level = v)),
                _choice('Category', _category, {
                  'all': 'All categories',
                  ...impromptuCategories,
                }, _busy ? null : (v) => setState(() => _category = v)),
                Text(
                  '$count questions in this pool. A shuffled queue avoids repeats until exhausted. Each level/category selection has its own queue. A retry keeps the same question without consuming the queue.',
                ),
                _choice('Response format', _kind, const {
                  'unrecorded': 'Unrecorded response + reflection',
                  'recorded': 'Optional recording + reflection',
                }, _busy ? null : (v) => setState(() => _kind = v)),
                _choice(
                  'Timing preset',
                  _preset,
                  {for (final k in impromptuPresets.keys) k: k},
                  _busy
                      ? null
                      : (v) => setState(() {
                          _preset = v;
                          for (var i = 0; i < 2; i++) {
                            _targets[i].text = '${impromptuPresets[v]![i]}';
                          }
                        }),
                ),
                for (var i = 0; i < 2; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      key: ValueKey('impromptu-target-$i'),
                      controller: _targets[i],
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            '${i == 0 ? 'Preparation' : 'Response'} target in seconds',
                        helperText: '0 = untimed · maximum 3600',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n < 0 || n > 3600
                            ? 'Enter a whole number from 0 to 3600.'
                            : null;
                      },
                    ),
                  ),
                const Text(
                  'Targets guide practice; they never cut off a response. Start and pause each timer yourself.',
                ),
                const SizedBox(height: 20),
                if (_error != null) Text(_error!, semanticsLabel: _error),
                FilledButton(
                  key: const ValueKey('impromptu-start'),
                  onPressed: _busy ? null : _start,
                  child: Text(
                    _busy ? 'Opening challenge…' : 'Start surprise challenge',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImpromptuPage extends ConsumerStatefulWidget {
  const ImpromptuPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<ImpromptuPage> createState() => _ImpromptuPageState();
}

class _ImpromptuPageState extends ConsumerState<ImpromptuPage>
    with WidgetsBindingObserver {
  late final _controller = ImpromptuController(
    ref.read(impromptuRepositoryProvider),
    widget.sessionId,
  );
  final _prep = TextEditingController(),
      _response = TextEditingController(),
      _reflection = TextEditingController(),
      _observation = TextEditingController();
  final _scaffold = {
    for (final k in impromptuScaffold.keys) k: TextEditingController(),
  };
  final _notes = {
    for (final k in impromptuCriteria) k: TextEditingController(),
  };
  Map<String, dynamic> _ratings = {};
  int? _confidence;
  int _revision = 0;
  bool _enabled = false,
      _dirty = false,
      _busy = false,
      _canPop = false,
      _ticking = false;
  String? _error;
  LocalAudio? _audio;
  Timer? _autosave, _heartbeat;
  Future<void> _tail = Future.value();
  ImpromptuAttempt? get _attempt => _controller.attempt;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    try {
      await _controller.open();
      if (!mounted) {
        return;
      }
      final w = _attempt!.workspace;
      _prep.text = w.preparation;
      _response.text = _attempt!.detail.response.body;
      _reflection.text = w.reflection;
      _enabled = w.scaffoldEnabled;
      _confidence = w.confidence;
      final fields = jsonDecode(w.scaffold) as Map;
      for (final k in _scaffold.keys) {
        _scaffold[k]!.text = fields[k] as String? ?? '';
      }
      _ratings = jsonDecode(w.assessments) as Map<String, dynamic>;
      for (final k in _notes.keys) {
        _notes[k]!.text = (_ratings[k] as Map?)?['note'] as String? ?? '';
      }
      setState(() {});
      _heartbeat = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'This challenge could not be opened. Your data has not been reset.',
        );
      }
    }
  }

  void _changed() {
    setState(() {
      _dirty = true;
      _revision++;
    });
    _autosave?.cancel();
    _autosave = Timer(
      const Duration(milliseconds: 400),
      () => _run(() async {}, autosave: true),
    );
  }

  Future<void> _flush() async {
    _autosave?.cancel();
    if (!_dirty || _attempt == null) {
      return;
    }
    final revision = _revision;
    final repo = ref.read(impromptuRepositoryProvider);
    if (_attempt!.closed) {
      await repo.review(
        widget.sessionId,
        {
          for (final k in impromptuCriteria)
            k: {
              'rating': (_ratings[k] as Map?)?['rating'],
              'note': _notes[k]!.text,
            },
        },
        _reflection.text,
        _confidence,
        DateTime.now(),
      );
    } else {
      await repo.save(widget.sessionId, _prep.text, _response.text, _enabled, {
        for (final k in _scaffold.keys) k: _scaffold[k]!.text,
      }, DateTime.now());
    }
    await _controller.refresh();
    if (mounted) {
      setState(() => _dirty = revision != _revision);
    }
  }

  Future<bool> _run(
    Future<void> Function() action, {
    bool autosave = false,
  }) async {
    if (_busy && !autosave) {
      return false;
    }
    if (!autosave && mounted) {
      setState(() => _busy = true);
    }
    final result = _tail.then((_) async {
      try {
        await _flush();
        await action();
        if (mounted) {
          setState(() => _error = null);
        }
        return true;
      } catch (_) {
        if (mounted) {
          setState(
            () => _error = 'Could not save this change. Keep this challenge open and retry Save.',
          );
        }
        return false;
      }
    });
    _tail = result.then<void>((_) {});
    final ok = await result;
    if (!autosave && mounted) {
      setState(() => _busy = false);
    }
    return ok;
  }

  Future<void> _tick() async {
    if (!mounted ||
        _busy ||
        _ticking ||
        _controller.session.detail?.session.status != 'running') {
      return;
    }
    _ticking = true;
    try {
      await _run(_controller.checkpoint, autosave: true);
    } finally {
      _ticking = false;
    }
  }

  Future<void> _stopAudio() async {
    final a = _audio;
    if (a == null) {
      return;
    }
    if (a.active == null || a.active!.sessionId == widget.sessionId) {
      await a.stop();
    }
    await a.backend.pausePlayback();
  }

  Future<void> _advance() async {
    final expected = _attempt!.workspace.viewStep;
    await _run(() async {
      await _stopAudio();
      await _controller.advance(expected);
    });
  }

  Future<void> _back() async {
    if (await _run(() async {
          await _stopAudio();
          await _controller.leave();
        }) &&
        mounted) {
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _retry() async {
    if (_reflection.text.trim().isEmpty) {
      setState(
        () => _error = 'Write one improvement in Reflection before retrying.',
      );
      return;
    }
    String? id;
    if (await _run(() async {
          await _stopAudio();
          id = await ref
              .read(impromptuRepositoryProvider)
              .retry(widget.sessionId, _reflection.text, DateTime.now());
        }) &&
        mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => ImpromptuPage(sessionId: id!)),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _run(_controller.leave, autosave: true);
      _audio?.lifecycle(state).catchError((Object _) {});
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _run(() async {
        await _stopAudio();
        await _controller.leave();
      }, autosave: true)
      ? AppExitResponse.exit
      : AppExitResponse.cancel;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    _heartbeat?.cancel();
    for (final c in [
      _prep,
      _response,
      _reflection,
      _observation,
      ..._scaffold.values,
      ..._notes.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(
    String key,
    String label,
    TextEditingController c, {
    bool readOnly = false,
    int max = 20000,
    int lines = 3,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextField(
      key: ValueKey('impromptu-$key'),
      controller: c,
      readOnly: readOnly || _busy,
      minLines: lines,
      maxLines: null,
      maxLength: max,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => _changed(),
    ),
  );
  Widget _question() {
    final a = _attempt!, e = a.detail.exercise;
    final hidden = a.workspace.viewStep == 'reveal';
    return _card([
      Text(
        '${e.level.toUpperCase()} · ${impromptuCategories[e.content['impromptu']['category']]}',
      ),
      const SizedBox(height: 12),
      Text(
        hidden ? 'Your question is ready.' : e.prompt,
        key: const ValueKey('impromptu-question'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      Text(
        hidden
            ? 'The selected question is saved. Reveal it when you are ready; no timer has started.'
            : e.focus,
      ),
      if (a.workspace.parentSessionId != null) ...[
        const Divider(height: 24),
        Text('Retry improvement: ${a.workspace.improvement}'),
        TextButton(
          onPressed: _busy
              ? null
              : () async {
                  if (await _run(() async {
                        await _stopAudio();
                        await _controller.leave();
                      }) &&
                      mounted) {
                    if (!context.mounted) {
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ImpromptuPage(
                          sessionId: a.workspace.parentSessionId!,
                        ),
                      ),
                    );
                  }
                },
          child: const Text('Open original attempt'),
        ),
      ],
      if (hidden)
        FilledButton(
          key: const ValueKey('impromptu-reveal'),
          onPressed: _busy ? null : _advance,
          child: const Text('Reveal question'),
        ),
      if (!hidden) ...[
        const SizedBox(height: 12),
        Text(
          'Preparation ${audioTime(_controller.elapsed(PracticeStage.prepare))} · Response ${audioTime(_controller.elapsed(PracticeStage.respond))}',
        ),
        const Text(
          'Only confirmed active time is saved. Pauses and unknown interruption periods are excluded.',
        ),
      ],
    ]);
  }

  Widget _timer() {
    final a = _attempt!,
        step = a.workspace.viewStep,
        index = step == 'prepare' ? 0 : 1;
    final target = a.targets[index],
        running = _controller.session.detail?.session.status == 'running';
    final elapsed = _controller.elapsed(
      index == 0 ? PracticeStage.prepare : PracticeStage.respond,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          target == 0
              ? 'Untimed practice'
              : '${audioTime(elapsed)} elapsed · target ${audioTime(target * 1000)}',
        ),
        if (target > 0) ...[
          if (elapsed >= target * 1000)
            const Text(
              'Target reached. Continue at your pace or finish this stage.',
            ),
          OutlinedButton(
            key: const ValueKey('impromptu-timer'),
            onPressed: _busy
                ? null
                : () => _run(
                    running ? _controller.pause : _controller.startTimer,
                  ),
            child: Text(
              running
                  ? 'Pause timer'
                  : elapsed > 0
                  ? 'Resume timer'
                  : 'Start timer',
            ),
          ),
        ],
      ],
    );
  }

  Widget _evidence() {
    final a = _attempt!, step = a.workspace.viewStep, closed = a.closed;
    return _card([
      Text(
        closed
            ? 'Your preserved response'
            : step == 'prepare'
            ? 'Preparation'
            : 'Your response',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (!closed) _timer(),
      if (step == 'respond' || closed) ...[
        _field(
          'response',
          'Response or recall notes (optional)',
          _response,
          readOnly: closed,
          max: 100000,
          lines: 5,
        ),
        if (a.workspace.responseKind == 'unrecorded')
          const Text(
            'Unrecorded response. Speak aloud or write here, then reflect on what you actually did. No spoken performance was measured.',
          ),
        if (a.workspace.responseKind == 'recorded')
          ref
              .watch(localAudioProvider)
              .when(
                data: (audio) {
                  _audio = audio;
                  return LocalAudioPanel(
                    sessionId: widget.sessionId,
                    audio: audio,
                    readOnly: closed,
                    observationController: _observation,
                    takeLabel: 'Impromptu response',
                    emptyMessage: 'No recording supplied. An unrecorded response and reflection are still available.',
                  );
                },
                error: (_, _) => const Text(
                  'Audio unavailable. You can continue unrecorded and reflect.',
                ),
                loading: () => const Text('Opening local audio…'),
              ),
      ],
      _field(
        'preparation',
        'Preparation notes (optional)',
        _prep,
        readOnly: closed,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Point / reason / example / close scaffold'),
        subtitle: const Text('Optional guidance, not a required formula.'),
        value: _enabled,
        onChanged: closed || _busy
            ? null
            : (v) {
                _enabled = v;
                _changed();
              },
      ),
      if (_enabled)
        for (final e in impromptuScaffold.entries)
          _field(
            e.key,
            e.value,
            _scaffold[e.key]!,
            readOnly: closed,
            max: 10000,
            lines: 2,
          ),
      if (!closed)
        FilledButton(
          key: const ValueKey('impromptu-advance'),
          onPressed: _busy ? null : _advance,
          child: Text(
            step == 'prepare' ? 'Begin response' : 'Preserve response & review',
          ),
        ),
    ]);
  }

  Widget _review() => _card([
    Text('Your self-review', style: Theme.of(context).textTheme.titleLarge),
    const Text(
      'Use your saved notes or listen to your recording. These are your judgments, not automatic analysis. Leave any criterion Not assessed.',
    ),
    for (final c in _attempt!.detail.exercise.criteria) ...[
      const Divider(height: 32),
      Text(
        c['label'] as String,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(c['description'] as String),
      _choice(
        '${c['label']} rating',
        (_ratings[c['id']] as Map?)?['rating'] as String? ?? 'none',
        const {
          'none': 'Not assessed',
          'emerging': 'Emerging',
          'developing': 'Developing',
          'effective': 'Effective',
        },
        _busy
            ? null
            : (v) {
                _ratings[c['id'] as String] = {
                  'rating': v == 'none' ? null : v,
                };
                _changed();
              },
      ),
      for (final key in ['emerging', 'developing', 'effective'])
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('$key: ${c['anchors'][key]}'),
        ),
      _field(
        'note-${c['id']}',
        'Evidence or improvement note (optional)',
        _notes[c['id']]!,
        max: 4000,
        lines: 2,
      ),
    ],
    const Divider(height: 32),
    const Text(
      'Confidence is how you feel, separate from performance ratings. It is never converted into a score.',
    ),
    _choice(
      'Confidence',
      _confidence?.toString() ?? 'none',
      const {
        'none': 'Not recorded',
        '1': '1 — Very unsure',
        '2': '2 — Unsure',
        '3': '3 — Mixed',
        '4': '4 — Confident',
        '5': '5 — Very confident',
      },
      _busy
          ? null
          : (v) {
              _confidence = int.tryParse(v);
              _changed();
            },
    ),
    _field(
      'reflection',
      'Reflection / one improvement for a retry',
      _reflection,
      max: 4000,
    ),
    FilledButton(
      key: const ValueKey('impromptu-save-review'),
      onPressed: _busy
          ? null
          : () {
              _changed();
              _run(() async {});
            },
      child: const Text('Save review'),
    ),
    const SizedBox(height: 12),
    OutlinedButton(
      key: const ValueKey('impromptu-retry'),
      onPressed: _busy ? null : _retry,
      child: const Text('Retry this question with one improvement'),
    ),
    const Text(
      'The original stays preserved. Reopening this retry action returns the same linked retry; retry that attempt to continue the chain.',
    ),
  ]);
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canPop,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        _back();
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Impromptu Arena'),
        leading: IconButton(
          tooltip: 'Save and go back',
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : _back,
        ),
      ),
      body: SafeArea(
        child: _attempt == null
            ? Center(child: Text(_error ?? 'Opening saved challenge…'))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              _error ??
                                  (_dirty
                                      ? 'Saving changes…'
                                      : 'Saved on this device'),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _busy ? null : () => _run(() async {}),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, size) {
                        final revealed =
                            _attempt!.workspace.viewStep != 'reveal';
                        final wide =
                            size.maxWidth >= 1180 &&
                            MediaQuery.textScalerOf(context).scale(16) <= 20;
                        if (wide && revealed) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _scroll(
                                  Column(
                                    children: [
                                      _question(),
                                      if (_attempt!.closed) _evidence(),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(
                                child: _scroll(
                                  _attempt!.closed ? _review() : _evidence(),
                                ),
                              ),
                            ],
                          );
                        }
                        return _scroll(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _question(),
                              if (revealed) _evidence(),
                              if (_attempt!.closed) _review(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
