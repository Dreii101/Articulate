import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_panel.dart';
import '../audio/audio_provider.dart';
import '../audio/local_audio.dart';
import '../exercises.dart';
import '../providers.dart';
import 'debate_content.dart';
import 'debate_controller.dart';
import 'debate_repository.dart';

Widget debateCard(List<Widget> children) => Card.outlined(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  ),
);
Widget debateScroll(Widget child) => SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: child,
    ),
  ),
);

class DebateLibraryPage extends ConsumerWidget {
  const DebateLibraryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Debate Arena')),
    body: SafeArea(
      child: debateScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Build a case. Answer with care.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose a position, develop your reasons, and respond to a scripted opposing argument. These are authored practice scenarios. Articulate does not fact-check claims, determine truth, or declare a winner.',
            ),
            const SizedBox(height: 24),
            for (final e
                in ref
                    .watch(exercisesProvider)
                    .where((e) => e.content.containsKey('debate')))
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: debateCard([
                  Text('${e.level.toUpperCase()} · Scripted practice'),
                  const SizedBox(height: 8),
                  Text(e.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(e.prompt),
                  const SizedBox(height: 12),
                  Text(e.focus),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: ValueKey('choose-${e.id}'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DebateSetupPage(exercise: e),
                      ),
                    ),
                    child: const Text('Set up a round'),
                  ),
                ]),
              ),
          ],
        ),
      ),
    ),
  );
}

class DebateSetupPage extends ConsumerStatefulWidget {
  const DebateSetupPage({super.key, required this.exercise});
  final Exercise exercise;
  @override
  ConsumerState<DebateSetupPage> createState() => _DebateSetupPageState();
}

class _DebateSetupPageState extends ConsumerState<DebateSetupPage> {
  String _position = 'for', _kind = 'written', _preset = 'Untimed round';
  final _targets = [
    for (var i = 0; i < 5; i++) TextEditingController(text: '0'),
  ];
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    for (final c in _targets) {
      c.dispose();
    }
    super.dispose();
  }

  Widget choice(
    String label,
    String value,
    List<String> values,
    List<String> labels,
    void Function(String) change,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DropdownButtonFormField<String>(
      key: ValueKey('debate-setup-$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (var i = 0; i < values.length; i++)
          DropdownMenuItem(
            value: values[i],
            child: Text(
              labels[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: _busy ? null : (v) => setState(() => change(v!)),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Set up your round')),
    body: SafeArea(
      child: debateScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercise.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(widget.exercise.prompt),
            const SizedBox(height: 12),
            Text(widget.exercise.content['debate']['scenario'] as String),
            choice(
              'Your position',
              _position,
              ['for', 'against'],
              ['For the motion', 'Against the motion'],
              (v) => _position = v,
            ),
            choice(
              'Response format',
              _kind,
              ['written', 'recorded'],
              [
                'Written responses',
                'Optional recorded responses + written notes',
              ],
              (v) => _kind = v,
            ),
            const Text(
              'Written fields remain available in either format. Recorded opening and rebuttal takes stay attached to their own stage; there is no transcription.',
            ),
            choice(
              'Practice preset',
              _preset,
              debatePresets.keys.toList(),
              debatePresets.keys.toList(),
              (v) {
                _preset = v;
                for (var i = 0; i < 5; i++) {
                  _targets[i].text = '${debatePresets[v]![i]}';
                }
              },
            ),
            const Text(
              'Customize targets in seconds (0 = untimed, up to 3600). Timers start only when you choose Start timer. Reaching a target never cuts off recording or advances the stage.',
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  key: ValueKey('debate-target-$i'),
                  controller: _targets[i],
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${debateStageLabels[i]} target (seconds)',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const Text(
              'Round order: preparation → opening → scripted opposition → rebuttal → reflection. You may explicitly skip a stage; its saved work and skipped label remain in the round.',
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              key: const ValueKey('debate-start-round'),
              onPressed: _busy
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      setState(() => _busy = true);
                      try {
                        final targets = validateDebateTargets(
                          _targets
                              .map((c) => int.tryParse(c.text.trim()))
                              .toList(),
                        );
                        final id = await ref
                            .read(debateRepositoryProvider)
                            .create(
                              widget.exercise,
                              _position,
                              _kind,
                              _preset,
                              targets,
                              DateTime.now(),
                            );
                        if (context.mounted) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => DebatePage(sessionId: id),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(
                            () => _error = e is ArgumentError
                                ? 'Use a whole number from 0 to 3600 for each target.'
                                : 'Could not create the round. Please retry.',
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: const Text('Start structured round'),
            ),
          ],
        ),
      ),
    ),
  );
}

class DebatePage extends ConsumerStatefulWidget {
  const DebatePage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<DebatePage> createState() => _DebatePageState();
}

class _DebatePageState extends ConsumerState<DebatePage>
    with WidgetsBindingObserver {
  late final _controller = DebateController(
    ref.read(debateRepositoryProvider),
    widget.sessionId,
  );
  final _editors = <String, TextEditingController>{};
  final _reviewEditors = <String, TextEditingController>{};
  final _observations = {
    for (final key in ['opening', 'rebuttal']) key: TextEditingController(),
  };
  final _nextAction = TextEditingController();
  Map<String, dynamic> _assessments = {};
  String _view = 'preparation', _support = 'assertion', _anchorField = 'claim';
  bool _dirty = false,
      _reviewDirty = false,
      _busy = false,
      _canPop = false,
      _ticking = false;
  String? _error;
  int _reviewRevision = 0;
  LocalAudio? _audio;
  Timer? _autosave, _heartbeat;
  Future<void> _tail = Future.value();
  DebateRound? get _round => _controller.round;
  bool get _editable =>
      _round != null && !_round!.closed && _round!.active.stageKey == _view;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  void _setView(String key) {
    _view = key;
    final fields = jsonDecode(
      _round!.stages.singleWhere((s) => s.stageKey == key).fields,
    ) as Map<String, dynamic>;
    for (final field in debateFieldLabels.keys) {
      (_editors[field] ??= TextEditingController()).text =
          fields[field] as String? ?? '';
    }
    _support = fields['supportKind'] as String? ?? 'assertion';
    _anchorField = debateFields[key]!.first;
  }

  Future<void> _load() async {
    try {
      await _controller.open();
      if (!mounted) return;
      _setView(_round!.closed ? 'rebuttal' : _round!.active.stageKey);
      _assessments =
          jsonDecode(_round!.workspace.assessments) as Map<String, dynamic>;
      _nextAction.text = _round!.workspace.reviewNote;
      for (final key in debateCriteria) {
        _reviewEditors[key] = TextEditingController(
          text: (_assessments[key] as Map?)?['note'] as String? ?? '',
        );
      }
      setState(() {});
      _heartbeat = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'This round could not be opened. Your saved data has not been reset.',
        );
      }
    }
  }

  void _changed({bool review = false}) {
    setState(() {
      if (review) {
        _reviewDirty = true;
        _reviewRevision++;
      } else {
        _dirty = true;
      }
    });
    _autosave?.cancel();
    _autosave = Timer(
      const Duration(milliseconds: 400),
      () => _run(() async {}, autosave: true),
    );
  }

  Future<void> _flush() async {
    _autosave?.cancel();
    if (_round == null) return;
    if (_dirty) {
      final key = _view;
      final fields = {
        for (final f in debateFields[key]!) f: _editors[f]!.text,
        if (key == 'preparation' || key == 'rebuttal') 'supportKind': _support,
      };
      await _controller.save(key, fields);
      if (mounted) {
        setState(
          () => _dirty = fields.entries.any(
            (e) =>
                e.value !=
                (e.key == 'supportKind' ? _support : _editors[e.key]!.text),
          ),
        );
      }
    }
    if (_reviewDirty) {
      final revision = _reviewRevision;
      final assessments =
          jsonDecode(jsonEncode(_assessments)) as Map<String, dynamic>;
      for (final key in debateCriteria) {
        assessments[key] = {
          ...?(assessments[key] as Map<String, dynamic>?),
          'note': _reviewEditors[key]!.text,
        };
      }
      final note = _nextAction.text;
      await ref
          .read(debateRepositoryProvider)
          .review(widget.sessionId, assessments, note, DateTime.now());
      if (mounted) setState(() => _reviewDirty = revision != _reviewRevision);
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
            () => _error = 'Could not save this change. Keep the round open and retry Save.',
          );
        }
        return false;
      }
    });
    _tail = result.then<void>((_) {});
    final ok = await result;
    if (!autosave && mounted) setState(() => _busy = false);
    return ok;
  }

  Future<void> _tick() async {
    if (!mounted ||
        _ticking ||
        _busy ||
        _round == null ||
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
    if (a == null) return;
    if (a.active == null || a.active!.sessionId == widget.sessionId) {
      await a.stop();
    }
    await a.backend.pausePlayback();
  }

  Future<void> _viewStage(String key) => _run(() async {
    await _stopAudio();
    await _controller.leave();
    _setView(key);
  }).then((_) {});
  Future<void> _advance({bool skip = false}) async {
    final key = _view;
    if (skip) {
      final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Skip this stage?'),
          content: const Text(
            'Saved text and recordings will remain, labelled skipped. The round will move to the next stage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Keep working'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Skip stage'),
            ),
          ],
        ),
      );
      if (yes != true) return;
    }
    await _run(() async {
      await _stopAudio();
      await _controller.advance(key, skip: skip);
      _setView(_round!.closed ? 'rebuttal' : _round!.active.stageKey);
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
        if (mounted) Navigator.pop(context);
      });
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
      ..._editors.values,
      ..._reviewEditors.values,
      ..._observations.values,
      _nextAction,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _brief() {
    final e = _round!.detail.exercise;
    return debateCard([
      Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(e.prompt),
      const SizedBox(height: 8),
      Text(
        'Your position: ${_round!.workspace.position == 'for' ? 'For' : 'Against'} · ${_round!.workspace.responseKind}',
      ),
      const SizedBox(height: 12),
      Text(e.content['debate']['scenario'] as String),
      const SizedBox(height: 12),
      Text(e.focus),
      const SizedBox(height: 12),
      const Text(
        'Authored scenario · no external fact-checking. Examples are not proof, and a source note is not verification.',
      ),
      if (_view == 'opposition' || _view == 'rebuttal' || _round!.closed) ...[
        const Divider(height: 32),
        Text(
          'Scripted practice — opposing argument',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SelectableText(
          _round!.script['argument'] as String,
          key: const ValueKey('debate-script'),
        ),
        const SizedBox(height: 12),
        Text('Practice challenge: ${_round!.script['challenge']}'),
        const SizedBox(height: 8),
        const Text(
          'This authored argument is fixed for your selected position. It is not an AI opponent or a factual verdict.',
        ),
      ],
      if (_view == 'opening' || _view == 'rebuttal') ...[
        const Divider(height: 32),
        Text(
          'Your preserved preparation',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final f in debateFields['preparation']!)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SelectableText(
              '${debateFieldLabels[f]}: ${(jsonDecode(_round!.stages.first.fields) as Map)[f] ?? 'Not supplied'}',
            ),
          ),
        Text(
          'Support label: ${supportLabels[supportKinds.indexOf((jsonDecode(_round!.stages.first.fields) as Map)['supportKind'] as String? ?? 'assertion')]}',
        ),
      ],
    ]);
  }

  Widget _stage() {
    final r = _round!,
        stage = r.stages.singleWhere((s) => s.stageKey == _view),
        index = debateStageKeys.indexOf(_view),
        target = r.targets[index],
        elapsed = _controller.elapsed(_view);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        debateCard([
          Text(
            '${index + 1}. ${debateStageLabels[index]}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Stage: ${stage.status} · ${target == 0 ? 'Untimed' : '${audioTime(elapsed)} elapsed / ${audioTime(target * 1000)} target'}',
            key: const ValueKey('debate-stage-status'),
          ),
          if (target > 0 && elapsed >= target * 1000)
            const Text(
              'Target reached. Continue at your own pace or finish this stage.',
            ),
          if (_editable && target > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  key: const ValueKey('debate-timer'),
                  onPressed: _busy
                      ? null
                      : () => _run(
                          _controller.session.detail!.session.status ==
                                  'running'
                              ? _controller.pauseTimer
                              : _controller.startTimer,
                        ),
                  child: Text(
                    _controller.session.detail!.session.status == 'running'
                        ? 'Pause timer'
                        : 'Start / resume timer',
                  ),
                ),
                Text('Timing: ${_controller.session.detail!.session.status}'),
              ],
            ),
            const Text(
              'Pauses and unknown interruption periods are excluded. Viewing a saved stage stops timing; resume it explicitly.',
            ),
          ],
          if (!_editable)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Preserved stage — text and recordings are read-only.',
              ),
            ),
          for (final f in debateFields[_view]!)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextField(
                key: ValueKey('debate-field-$f'),
                controller: _editors[f],
                readOnly: !_editable || _busy,
                minLines: f == 'sourceNotes' ? 3 : 4,
                maxLines: 12,
                maxLength: 20000,
                decoration: InputDecoration(
                  labelText: debateFieldLabels[f],
                  hintText: f == 'sourceNotes'
                      ? 'Name the source, what it supports, and any limitations. If invented, label it hypothetical.'
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => _changed(),
              ),
            ),
          if (_view == 'preparation' || _view == 'rebuttal') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('debate-support-$_view-$_support'),
              initialValue: _support,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'How are you using this support?',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var i = 0; i < supportKinds.length; i++)
                  DropdownMenuItem(
                    value: supportKinds[i],
                    child: Text(
                      supportLabels[i],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: !_editable || _busy
                  ? null
                  : (v) {
                      _support = v!;
                      _changed();
                    },
            ),
            const SizedBox(height: 8),
            Text(supportLabels[supportKinds.indexOf(_support)]),
            const Text(
              'This is your label. The app does not verify the source or decide whether the claim is true.',
            ),
          ],
          if (stage.status == 'skipped')
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Skipped stage. Any saved work remains visible; skipping is not completion.',
              ),
            ),
          if (_editable) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  key: const ValueKey('debate-next'),
                  onPressed: _busy ? null : () => _advance(),
                  child: Text(
                    index == 4
                        ? 'Complete round & review'
                        : 'Finish stage & continue',
                  ),
                ),
                TextButton(
                  key: const ValueKey('debate-skip'),
                  onPressed: _busy ? null : () => _advance(skip: true),
                  child: const Text('Skip this stage'),
                ),
              ],
            ),
          ],
        ]),
        if (r.workspace.responseKind == 'recorded' &&
            {'opening', 'rebuttal'}.contains(_view))
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ref
                .watch(localAudioProvider)
                .when(
                  data: (a) {
                    _audio = a;
                    return LocalAudioPanel(
                      key: ValueKey('debate-audio-$_view'),
                      sessionId: widget.sessionId,
                      contextKey: _view,
                      audio: a,
                      readOnly: !_editable || _busy,
                      observationController: _observations[_view]!,
                      takeLabel: '${debateStageLabels[index]} response',
                      emptyMessage: 'No recording was supplied for this stage. Written notes remain available; spoken content has not been assessed.',
                    );
                  },
                  loading: () => const Text('Opening local audio…'),
                  error: (e, s) => Column(
                    children: [
                      const Text(
                        'Audio unavailable. Continue in writing or retry.',
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(localAudioProvider),
                        child: const Text('Retry audio'),
                      ),
                    ],
                  ),
                ),
          ),
      ],
    );
  }

  void _attachText(String criterion) {
    final c = _editors[_anchorField]!, selection = c.selection;
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a passage in the chosen response field first.'),
        ),
      );
      return;
    }
    _assessments[criterion] = {
      ...?(_assessments[criterion] as Map<String, dynamic>?),
      'anchor': {
        'kind': 'text',
        'stage': _view,
        'field': _anchorField,
        'start': selection.start,
        'end': selection.end,
        'quote': selection.textInside(c.text),
      },
    };
    _changed(review: true);
  }

  void _attachAudio(String criterion) {
    final a = _audio, r = a?.selected;
    if (a == null ||
        r == null ||
        r.sessionId != widget.sessionId ||
        r.contextKey != _view ||
        r.microphoneCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select an opening or rebuttal response take in this stage first.',
          ),
        ),
      );
      return;
    }
    _assessments[criterion] = {
      ...?(_assessments[criterion] as Map<String, dynamic>?),
      'anchor': {
        'kind': 'audio',
        'recordingId': r.id,
        'positionMs': a.position.inMilliseconds.clamp(0, r.durationMs),
      },
    };
    _changed(review: true);
  }

  Widget _review() => debateCard([
    Text(
      'Your anchored self-review',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 8),
    const Text(
      'These anchors describe practice behaviours, not argument truth or an objective winner. Leave any criterion Not assessed. Attach selected text or a response recording timestamp if useful.',
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      key: ValueKey('debate-anchor-field-$_view-$_anchorField'),
      initialValue: _anchorField,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Response field for a text anchor',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final f in debateFields[_view]!)
          DropdownMenuItem(
            value: f,
            child: Text(debateFieldLabels[f]!, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: _busy ? null : (v) => setState(() => _anchorField = v!),
    ),
    for (final c in _round!.detail.exercise.criteria) ...[
      const Divider(height: 32),
      Text(
        c['label'] as String,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Text(c['description'] as String),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        key: ValueKey(
          'debate-rating-${c['id']}-${(_assessments[c['id']] as Map?)?['rating']}',
        ),
        initialValue:
            (_assessments[c['id']] as Map?)?['rating'] as String? ??
            'notAssessed',
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Your assessment',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(
            value: 'notAssessed',
            child: Text('Not assessed'),
          ),
          for (final v in ['emerging', 'developing', 'effective'])
            DropdownMenuItem(
              value: v,
              child: Text(
                '${v[0].toUpperCase()}${v.substring(1)} — my assessment',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: _busy
            ? null
            : (v) {
                _assessments[c['id'] as String] = {
                  ...?(_assessments[c['id']] as Map<String, dynamic>?),
                  'rating': v == 'notAssessed' ? null : v,
                };
                _changed(review: true);
              },
      ),
      const SizedBox(height: 8),
      for (final entry in (c['anchors'] as Map<String, dynamic>).entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${entry.key[0].toUpperCase()}${entry.key.substring(1)}: ${entry.value}',
          ),
        ),
      TextField(
        key: ValueKey('debate-review-${c['id']}'),
        controller: _reviewEditors[c['id']],
        enabled: !_busy,
        minLines: 2,
        maxLines: 5,
        maxLength: 4000,
        decoration: const InputDecoration(
          labelText: 'Evidence or improvement note (optional)',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => _changed(review: true),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          TextButton(
            onPressed: _busy ? null : () => _attachText(c['id'] as String),
            child: const Text('Attach selected passage'),
          ),
          if (_round!.workspace.responseKind == 'recorded')
            TextButton(
              onPressed: _busy ? null : () => _attachAudio(c['id'] as String),
              child: const Text('Attach playback position'),
            ),
        ],
      ),
      if ((_assessments[c['id']] as Map?)?['anchor'] case final Map a) ...[
        SelectableText(
          a['kind'] == 'text'
              ? 'Saved ${a['stage']} / ${a['field']} passage: “${a['quote']}”'
              : 'Saved response take ${a['recordingId']} at ${audioTime(a['positionMs'] as int)}',
        ),
        TextButton(
          onPressed: () {
            _assessments[c['id'] as String] = {
              ...?(_assessments[c['id']] as Map<String, dynamic>?),
              'anchor': null,
            };
            _changed(review: true);
          },
          child: const Text('Remove reference'),
        ),
      ],
    ],
    const Divider(height: 32),
    TextField(
      key: const ValueKey('debate-next-action'),
      controller: _nextAction,
      enabled: !_busy,
      minLines: 3,
      maxLines: 6,
      maxLength: 10000,
      decoration: const InputDecoration(
        labelText: 'Next action (optional)',
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _changed(review: true),
    ),
  ]);
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canPop,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _back),
        title: const Text('Debate Arena'),
      ),
      body: SafeArea(
        child: _round == null
            ? Center(child: Text(_error ?? 'Opening your round…'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('debate-stage-picker-$_view'),
                      initialValue: _view,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Round stages — reopen saved work',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (var i = 0; i < 5; i++)
                          DropdownMenuItem(
                            value: debateStageKeys[i],
                            enabled: _round!.stages[i].status != 'pending',
                            child: Text(
                              '${i + 1}. ${debateStageLabels[i]} · ${_round!.stages[i].status}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _busy ? null : (v) => _viewStage(v!),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _dirty || _reviewDirty
                              ? 'Saving…'
                              : 'Saved on this device',
                          key: const ValueKey('debate-save-status'),
                        ),
                        TextButton(
                          onPressed: _busy ? null : () => _run(() async {}),
                          child: const Text('Save'),
                        ),
                        if (!_round!.closed && !_editable)
                          TextButton(
                            onPressed: () =>
                                _viewStage(_round!.active.stageKey),
                            child: const Text('Return to current stage'),
                          ),
                      ],
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final left = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_round!.closed) ...[_stage(), const SizedBox(height: 16)],
                            _brief(),
                          ],
                        );
                        final right = _round!.closed ? _review() : _stage();
                        return c.maxWidth >= 1180 &&
                                MediaQuery.textScalerOf(context).scale(16) <= 21
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: debateScroll(left)),
                                  const VerticalDivider(width: 1),
                                  Expanded(child: debateScroll(right)),
                                ],
                              )
                            : debateScroll(
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Card.outlined(child: ExpansionTile(
                                      key: ValueKey('debate-brief-$_view'),
                                      initiallyExpanded: _view == 'opposition',
                                      title: Text(_round!.detail.exercise.title),
                                      subtitle: Text('Motion & scripted practice · ${_round!.workspace.position == 'for' ? 'For' : 'Against'}'),
                                      children: [_brief()],
                                    )),
                                    const SizedBox(height: 16),
                                    _stage(),
                                    if (_round!.closed) ...[const SizedBox(height: 16), _review()],
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
