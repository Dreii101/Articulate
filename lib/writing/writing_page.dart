import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exercises.dart';
import '../providers.dart';
import '../session_controller.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'writing_repository.dart';

class WritingStudioPage extends ConsumerStatefulWidget {
  const WritingStudioPage({super.key});
  @override
  ConsumerState<WritingStudioPage> createState() => _WritingStudioPageState();
}

class _WritingStudioPageState extends ConsumerState<WritingStudioPage> {
  String _level = 'beginner';
  bool _opening = false;
  @override
  Widget build(BuildContext context) {
    final items = ref
        .watch(exercisesProvider)
        .where((e) => e.content.containsKey('writing') && e.level == _level);
    return Scaffold(
      appBar: AppBar(title: const Text('Writing Studio')),
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
                    'Give your ideas a clear shape.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose a brief. Plan if it helps, write in plain text, then review and revise. Timing is optional.',
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final level in [
                        'beginner',
                        'intermediate',
                        'advanced',
                      ])
                        ChoiceChip(
                          key: ValueKey('writing-level-$level'),
                          label: Text(
                            level[0].toUpperCase() + level.substring(1),
                          ),
                          selected: level == _level,
                          onSelected: _opening
                              ? null
                              : (_) => setState(() => _level = level),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  for (final e in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${e.level.toUpperCase()} · ${e.content['writing']['kind']}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                e.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(e.prompt),
                              const SizedBox(height: 12),
                              Text(
                                'Audience: ${e.content['writing']['audience']}',
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                key: ValueKey('choose-${e.id}'),
                                onPressed: _opening
                                    ? null
                                    : () async {
                                        setState(() => _opening = true);
                                        try {
                                          final repo = ref.read(
                                            repositoryProvider,
                                          );
                                          final id = await repo.createDraft(
                                            e,
                                            DateTime.now(),
                                          );
                                          await WritingRepository(repo)
                                              .open(id);
                                          if (context.mounted) {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    WritingPage(sessionId: id),
                                              ),
                                            );
                                          }
                                        } catch (_) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Could not open the writing draft. Please try again.',
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
                                child: const Text('Open brief'),
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
}

class WritingPage extends ConsumerStatefulWidget {
  const WritingPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends ConsumerState<WritingPage>
    with WidgetsBindingObserver {
  late final SessionController _session;
  late final WritingRepository _writing;
  WritingWorkspace? _workspace;
  List<WritingWorkspace> _versions = [];
  final _body = TextEditingController(),
      _outline = TextEditingController(),
      _audience = TextEditingController(),
      _purpose = TextEditingController(),
      _nextAction = TextEditingController();
  final _evidence = {
    for (final k in writingCriteria) k: TextEditingController(),
  };
  Map<String, dynamic> _assessments = {};
  String _step = 'brief';
  bool _dirty = false,
      _busy = false,
      _canPop = false,
      _active = true,
      _ticking = false;
  String? _error;
  Timer? _saveTimer, _heartbeat;
  Future<void> _tail = Future.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = SessionController(
      ref.read(repositoryProvider),
      widget.sessionId,
    );
    _writing = WritingRepository(_session.repository);
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _session.open();
      final w = await _writing.open(widget.sessionId);
      final versions = await _writing.versions(w.rootSessionId);
      if (!mounted) return;
      _body.text = d.response.body;
      _outline.text = w.outline;
      _audience.text = w.audience;
      _purpose.text = w.purpose;
      _nextAction.text = w.nextAction;
      _assessments = jsonDecode(w.assessments) as Map<String, dynamic>;
      for (final k in writingCriteria) {
        _evidence[k]!.text = (_assessments[k]?['evidence'] as String?) ?? '';
      }
      setState(() {
        _workspace = w;
        _versions = versions;
        _step = isTerminal(d.session.status) ? 'review' : w.viewStep;
        _error = null;
      });
      _heartbeat ??= Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Your writing could not be opened. Go back and try again. Your data has not been reset.',
        );
      }
    }
  }

  void _changed([String? value]) {
    setState(() => _dirty = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 400),
      () => _run(() async {}, autosave: true),
    );
  }

  Future<void> _flush() async {
    _saveTimer?.cancel();
    if (_workspace == null || !_dirty) return;
    final body = _body.text,
        outline = _outline.text,
        audience = _audience.text,
        purpose = _purpose.text,
        next = _nextAction.text;
    final assessmentJson = jsonEncode(_assessments);
    if (!isTerminal(_session.detail!.session.status) &&
        body != _session.detail!.response.body) {
      await _session.saveResponse(body);
    }
    await _writing.save(
      widget.sessionId,
      outline: outline,
      audience: audience,
      purpose: purpose,
      step: _step,
      assessments: jsonDecode(assessmentJson) as Map<String, dynamic>,
      nextAction: next,
      now: DateTime.now().toUtc(),
    );
    if (mounted) {
      setState(
        () => _dirty =
            body != _body.text ||
            outline != _outline.text ||
            audience != _audience.text ||
            purpose != _purpose.text ||
            next != _nextAction.text ||
            assessmentJson != jsonEncode(_assessments),
      );
    }
  }

  Future<bool> _run(
    Future<void> Function() operation, {
    bool autosave = false,
  }) async {
    if (_busy && !autosave) return false;
    if (!autosave && mounted) setState(() => _busy = true);
    final result = _tail.then((_) async {
      try {
        await _flush();
        await operation();
        if (mounted) setState(() => _error = null);
        return true;
      } catch (_) {
        if (mounted) {
          setState(
            () => _error = 'Could not save your writing. Keep this window open and try Save again.',
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

  Future<void> _tick() async {
    if (!_active || _ticking || _busy || _workspace == null) return;
    _ticking = true;
    await _run(_session.checkpoint, autosave: true);
    _ticking = false;
  }

  Future<void> _view(String step) async {
    await _run(() async {
      if (step == 'review' && !isTerminal(_session.detail!.session.status)) {
        await _session.transition(PracticeStatus.completed);
      }
      if (!isTerminal(_session.detail!.session.status)) {
        await _session.changeStage(
          step == 'write' ? PracticeStage.respond : PracticeStage.prepare,
        );
      }
      setState(() {
        _step = step;
        _dirty = true;
      });
      await _flush();
    });
  }

  Future<void> _openVersion(String id) async {
    final saved = await _run(_session.leave);
    if (saved && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => WritingPage(sessionId: id)),
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _revision() async {
    String? id;
    final saved = await _run(() async {
      id = await _writing.createRevision(widget.sessionId, DateTime.now());
      _versions = await _writing.versions(_workspace!.rootSessionId);
    });
    if (saved && id != null && mounted) await _openVersion(id!);
  }

  Future<void> _back() async {
    if (await _run(_session.leave) && mounted) {
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active) _run(_session.leave, autosave: true);
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _run(_session.leave, autosave: true)
      ? AppExitResponse.exit
      : AppExitResponse.cancel;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _heartbeat?.cancel();
    for (final c in [
      _body,
      _outline,
      _audience,
      _purpose,
      _nextAction,
      ..._evidence.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String key, {
    int lines = 2,
    bool readOnly = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      key: ValueKey(key),
      controller: controller,
      readOnly: readOnly,
      enabled: !_busy,
      minLines: lines,
      maxLines: lines + 8,
      maxLength: PracticeRepository.maxResponseLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      onChanged: _changed,
    ),
  );

  Widget _brief(Exercise exercise, bool closed) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('The brief', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      SelectableText(
        exercise.prompt,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 20),
      _field('Audience', _audience, 'writing-audience', readOnly: closed),
      _field('Purpose', _purpose, 'writing-purpose', readOnly: closed),
      Text(
        'Content v${exercise.version} · rubric v${exercise.content['rubric']['version']} · ${exercise.language}',
      ),
      const SizedBox(height: 12),
      Text(
        'Original content · ${exercise.content['authorship']['creator']}\n${exercise.content['license']['notice']}',
      ),
    ],
  );

  Widget _review(Exercise exercise) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Self-review', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      const Text(
        'Use the anchors to describe this version. Not assessed is always valid; there is no overall score. Select text in the draft to attach evidence.',
      ),
      const SizedBox(height: 16),
      if (_workspace!.legacyReviewNotes.isNotEmpty) ...[
        const Text('Earlier reflection (preserved)'),
        SelectableText(_workspace!.legacyReviewNotes),
        const SizedBox(height: 16),
      ],
      for (final key in writingCriteria) _criterion(exercise, key),
      _field(
        'Next action (optional)',
        _nextAction,
        'writing-next-action',
        readOnly: _session.detail!.session.status != 'completed',
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          OutlinedButton(
            key: const ValueKey('finish-writing-review'),
            onPressed: _busy || _session.detail!.session.status != 'completed'
                ? null
                : () => _run(() async {
                    await _writing.finishReview(
                      widget.sessionId,
                      DateTime.now().toUtc(),
                    );
                    await _session.open();
                  }),
            child: const Text('Save self-review'),
          ),
          FilledButton(
            key: const ValueKey('create-revision'),
            onPressed: _busy || _session.detail!.session.status != 'completed'
                ? null
                : _revision,
            child: const Text('Create revision'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Review: ${switch (_session.detail!.reviewStatus) {
          ReviewStatus.unreviewed => 'Not assessed yet',
          ReviewStatus.inProgress => 'In progress',
          ReviewStatus.reviewed => 'Saved self-review',
        }}',
      ),
    ],
  );

  Widget _criterion(Exercise exercise, String key) {
    final criteria = (jsonDecode(_workspace!.reviewRubric)['criteria'] as List)
        .cast<Map<String, dynamic>>()
        .where((c) => c['id'] == key);
    final c = criteria.firstOrNull;
    final anchors =
        c?['anchors'] as Map? ??
        {
          'emerging':
              'The $key needs attention before the reader can follow the draft.',
          'developing':
              'The $key is partly effective; identify one specific improvement.',
          'effective': 'The $key consistently helps the intended reader.',
        };
    final value =
        _assessments[key] as Map? ??
        {'rating': null, 'evidence': '', 'start': null, 'end': null};
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            c?['label'] as String? ?? key[0].toUpperCase() + key.substring(1),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            c?['description'] as String? ??
                'Consider how $key helps this reader.',
          ),
          const SizedBox(height: 12),
          for (final rating in writingRatings)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${_ratingLabel(rating)}: ${anchors[rating]}'),
            ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('rating-$key'),
            initialValue: value['rating'] as String? ?? 'notAssessed',
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '${c?['label'] ?? key} assessment',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final r in ['notAssessed', ...writingRatings])
                DropdownMenuItem(
                  value: r,
                  child: Text(_ratingLabel(r), overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: _busy || _session.detail!.session.status != 'completed'
                ? null
                : (r) {
                    _assessments[key] = {
                      ...value,
                      'rating': r == 'notAssessed' ? null : r,
                    };
                    _changed();
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            key: ValueKey('evidence-$key'),
            controller: _evidence[key],
            readOnly: _session.detail!.session.status != 'completed',
            enabled: !_busy,
            minLines: 2,
            maxLines: 5,
            maxLength: 100000,
            decoration: const InputDecoration(
              labelText: 'Evidence or comment (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) {
              _assessments[key] = {
                ...value,
                'evidence': text,
                'start': null,
                'end': null,
              };
              _changed();
            },
          ),
          TextButton(
            onPressed: _busy || _session.detail!.session.status != 'completed'
                ? null
                : () {
                    final selection = _body.selection;
                    if (!selection.isValid || selection.isCollapsed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Select a passage in the draft first.'),
                        ),
                      );
                      return;
                    }
                    final quote = selection.textInside(_body.text);
                    _evidence[key]!.text = quote;
                    _assessments[key] = {
                      ...value,
                      'evidence': quote,
                      'start': selection.start,
                      'end': selection.end,
                    };
                    _changed();
                  },
            child: const Text('Use selected draft text'),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(String value) => switch (value) {
    'notAssessed' => 'Not assessed',
    'emerging' => 'Needs attention',
    'developing' => 'Developing',
    _ => 'Effective',
  };

  @override
  Widget build(BuildContext context) {
    final d = _session.detail, w = _workspace;
    final closed = d != null && isTerminal(d.session.status);
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _busy ? null : _back),
          title: const Text('Writing Studio'),
        ),
        body: SafeArea(
          child: w == null || d == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error ?? 'Opening your writing…'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final wide =
                        constraints.maxWidth >= 1180 &&
                        MediaQuery.textScalerOf(context).scale(1) <= 1.3;
                    Widget pane(Widget child) => SizedBox(
                      height: (constraints.maxHeight - 260)
                          .clamp(360, 900)
                          .toDouble(),
                      child: SingleChildScrollView(
                        primary: false,
                        padding: const EdgeInsets.only(right: 8),
                        child: child,
                      ),
                    );
                    final editor = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_step == 'outline') ...[
                          const Text(
                            'An outline is optional. Skip it when you are ready to write.',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            d.exercise.content['writing']?['outlineHint']
                                    as String? ??
                                'Main point → supporting ideas → ending.',
                          ),
                          const SizedBox(height: 12),
                          _field(
                            'Optional outline',
                            _outline,
                            'writing-outline',
                            lines: 6,
                            readOnly: closed,
                          ),
                        ],
                        if (_step == 'write' || _step == 'review') ...[
                          Text(
                            closed
                                ? 'Preserved draft · Version ${w.versionNumber}'
                                : w.parentSessionId == null
                                ? 'Your draft'
                                : 'Your revision',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            'Plain-text writing',
                            _body,
                            'writing-body',
                            lines: 12,
                            readOnly: closed,
                          ),
                          Text(
                            '${_body.text.trim().isEmpty ? 0 : _body.text.trim().split(RegExp(r'\s+')).length} words · ${_dirty ? 'Saving…' : 'Saved on this device'}',
                          ),
                          if (!closed) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Timing is optional. It does not affect the review.',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                OutlinedButton(
                                  key: const ValueKey('writing-timer'),
                                  onPressed: _busy
                                      ? null
                                      : () => _run(
                                          d.session.status == 'running'
                                              ? () => _session.transition(
                                                  PracticeStatus.paused,
                                                )
                                              : _session.start,
                                        ),
                                  child: Text(
                                    d.session.status == 'running'
                                        ? 'Pause timer'
                                        : 'Start / resume timer',
                                  ),
                                ),
                                Text(
                                  'Known active time: ${_session.elapsedMs ~/ 1000}s',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pauses and unknown interruption periods are excluded.',
                            ),
                          ],
                        ],
                      ],
                    );
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(
                        constraints.maxWidth < 600 ? 20 : 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                d.exercise.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Version ${w.versionNumber} · ${d.session.localPracticeDate} · ${d.session.status}',
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final step in [
                                    'brief',
                                    'outline',
                                    'write',
                                    'review',
                                  ])
                                    ChoiceChip(
                                      key: ValueKey('writing-view-$step'),
                                      label: Text(switch (step) {
                                        'brief' => 'Brief',
                                        'outline' => 'Outline (optional)',
                                        'write' =>
                                          w.parentSessionId == null
                                              ? 'Write'
                                              : 'Revise',
                                        _ => 'Review',
                                      }),
                                      selected: _step == step,
                                      onSelected: _busy
                                          ? null
                                          : (_) => _view(step),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _dirty ? 'Saving…' : 'Saved on this device',
                                key: const ValueKey('writing-save-status'),
                              ),
                              if (_error != null) ...[
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _run(() async {}),
                                  child: const Text('Save again'),
                                ),
                              ],
                              if (_step == 'review')
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'This draft is preserved. Create a revision to make changes. Assess only what you want to assess.',
                                  ),
                                ),
                              const SizedBox(height: 20),
                              if (_step == 'brief')
                                _brief(d.exercise, closed)
                              else if (wide &&
                                  (_step == 'write' || _step == 'review'))
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: pane(_brief(d.exercise, closed)),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 5, child: pane(editor)),
                                    if (_step == 'review') ...[
                                      const SizedBox(width: 24),
                                      Expanded(
                                        flex: 4,
                                        child: pane(_review(d.exercise)),
                                      ),
                                    ],
                                  ],
                                )
                              else ...[
                                editor,
                                if (_step == 'review') ...[
                                  const SizedBox(height: 24),
                                  _review(d.exercise),
                                ],
                              ],
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _run(() async {}),
                                    child: const Text('Save now'),
                                  ),
                                  if (!closed && _step != 'review')
                                    FilledButton(
                                      key: const ValueKey('review-writing'),
                                      onPressed: _busy
                                          ? null
                                          : () => _view(
                                              _step == 'brief' ||
                                                      _step == 'outline'
                                                  ? 'write'
                                                  : 'review',
                                            ),
                                      child: Text(
                                        _step == 'write'
                                            ? 'Review and preserve draft'
                                            : 'Continue to writing',
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Saved versions',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final v in _versions)
                                    OutlinedButton(
                                      key: ValueKey(
                                        'version-${v.versionNumber}',
                                      ),
                                      onPressed:
                                          v.sessionId == widget.sessionId ||
                                              _busy
                                          ? null
                                          : () => _openVersion(v.sessionId),
                                      child: Text(
                                        'Version ${v.versionNumber}${v.versionNumber == 1 ? ' · Original' : ' · Revision'}',
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
