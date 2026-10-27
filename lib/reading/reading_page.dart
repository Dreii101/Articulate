import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../session_controller.dart';
import '../storage/database.dart';
import 'reading_repository.dart';

class ReadingLabPage extends ConsumerStatefulWidget {
  const ReadingLabPage({super.key});
  @override
  ConsumerState<ReadingLabPage> createState() => _ReadingLabPageState();
}

class _ReadingLabPageState extends ConsumerState<ReadingLabPage> {
  String _level = 'beginner';
  bool _opening = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reading Lab')),
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
                  'Read closely. Think beyond the page.',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Original passages, thoughtful questions, and explanations. First answers stay preserved when you revise. Open answers are yours to assess.',
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
                        key: ValueKey('reading-level-$level'),
                        label: Text(
                          level[0].toUpperCase() + level.substring(1),
                        ),
                        selected: _level == level,
                        onSelected: _opening
                            ? null
                            : (_) => setState(() => _level = level),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                for (final e
                    in ref
                        .watch(exercisesProvider)
                        .where(
                          (e) =>
                              e.content.containsKey('reading') &&
                              e.level == _level,
                        ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card.outlined(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.level.toUpperCase()} · 5 questions · English',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              e.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              e.content['reading']['passage'][0]['text']
                                  as String,
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
                                        await ReadingRepository(repo).open(id);
                                        if (context.mounted) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  ReadingPage(sessionId: id),
                                            ),
                                          );
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Could not open this passage. Please try again.',
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
                              child: const Text('Read passage'),
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

class ReadingPage extends ConsumerStatefulWidget {
  const ReadingPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage>
    with WidgetsBindingObserver {
  late final SessionController _session;
  late final ReadingRepository _reading;
  ReadingWorkspace? _workspace;
  final _text = <String, TextEditingController>{};
  Map<String, dynamic> _first = {}, _ratings = {};
  final _choices = <String, dynamic>{};
  String _step = 'passage';
  bool _hide = false, _dirty = false, _busy = false, _canPop = false;
  String? _error;
  Timer? _autosave;
  Future<void> _tail = Future.value();
  bool get _checked => _workspace?.keyResults != null;
  List<Map<String, dynamic>> get _questions =>
      readingQuestions(_session.detail!.exercise);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = SessionController(
      ref.read(repositoryProvider),
      widget.sessionId,
    );
    _reading = ReadingRepository(_session.repository);
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await _session.open();
      final w = await _reading.open(widget.sessionId);
      if (!mounted) return;
      _first = readingAnswers(d.response.body);
      final answers = w.keyResults == null
          ? _first
          : jsonDecode(w.revisionAnswers) as Map<String, dynamic>;
      for (final q in _questions) {
        final id = q['id'] as String;
        if (isOpenQuestion(q)) {
          _text[id] = TextEditingController(text: answers[id] as String? ?? '');
        } else {
          _choices[id] = answers[id] ?? '';
        }
      }
      setState(() {
        _workspace = w;
        _step = w.viewStep;
        _hide = w.hidePassage;
        _ratings = jsonDecode(w.ratings) as Map<String, dynamic>;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Your reading could not be opened. Go back and try again. Your data has not been reset.',
        );
      }
    }
  }

  Map<String, dynamic> _current() => {
    for (final q in _questions)
      q['id'] as String: isOpenQuestion(q)
          ? _text[q['id']]!.text
          : _choices[q['id']] ?? '',
  };
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
    if (!_dirty || _workspace == null) return;
    final current = _current(),
        ratings = Map<String, dynamic>.from(_ratings),
        step = _step,
        hide = _hide;
    await _reading.save(
      widget.sessionId,
      answers: _checked ? _first : current,
      revisions: _checked ? current : {},
      ratings: ratings,
      step: step,
      hidePassage: hide,
      now: DateTime.now(),
    );
    _session.detail = await _session.repository.load(widget.sessionId);
    if (mounted) {
      setState(
        () => _dirty =
            jsonEncode(current) != jsonEncode(_current()) ||
            jsonEncode(ratings) != jsonEncode(_ratings) ||
            step != _step ||
            hide != _hide,
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
            () => _error =
                'Could not save. Keep this window open and try Save now again.',
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

  Future<void> _view(String step) => _run(() async {
    setState(() {
      _step = step;
      _dirty = true;
    });
    await _flush();
  });

  Future<void> _check() => _run(() async {
    final w = await _reading.check(widget.sessionId, DateTime.now());
    _session.detail = await _session.repository.load(widget.sessionId);
    if (mounted) {
      setState(() {
        _first = readingAnswers(_session.detail!.response.body);
        _workspace = w;
        _step = 'review';
      });
    }
  });

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
    if (state != AppLifecycleState.resumed) {
      _run(_session.leave, autosave: true);
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _run(_session.leave, autosave: true)
      ? AppExitResponse.exit
      : AppExitResponse.cancel;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _card(List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
  Widget _scroll(String name, Widget child) => SingleChildScrollView(
    key: PageStorageKey('reading-$name'),
    padding: const EdgeInsets.all(24),
    child: child,
  );

  Widget _passage() {
    final e = _session.detail!.exercise;
    final paragraphs = e.content['reading']['passage'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(e.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          '${e.level.toUpperCase()} · ${e.language} · exercise v${e.version} · rubric v${e.content['rubric']['version']}',
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < paragraphs.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paragraph ${i + 1}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  paragraphs[i]['text'] as String,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.65),
                ),
              ],
            ),
          ),
        Text(
          'Original passage · ${e.content['authorship']['creator']}\n${e.content['license']['id']}\n${e.content['license']['notice']}',
        ),
        const SizedBox(height: 24),
        if (!_checked && _step == 'passage')
          FilledButton(
            onPressed: _busy ? null : () => _view('questions'),
            child: const Text('Answer questions'),
          ),
      ],
    );
  }

  String _answerLabel(Map<String, dynamic> q, dynamic value) {
    if (value == null || value == '') return 'Unanswered';
    if (isOpenQuestion(q)) return value as String;
    return ((q['options'] as List).firstWhere((o) => o['id'] == value)['text'])
        as String;
  }

  Widget _input(Map<String, dynamic> q) {
    final id = q['id'] as String;
    if (isOpenQuestion(q)) {
      return TextField(
        key: ValueKey('reading-answer-$id'),
        controller: _text[id],
        enabled: !_busy,
        minLines: 4,
        maxLines: 10,
        maxLength: 16000,
        decoration: InputDecoration(
          labelText: _checked
              ? 'Revision after explanations'
              : 'Your ${q['kind']} answer',
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: _changed,
      );
    }
    return RadioGroup<String>(
      groupValue: _choices[id] as String? ?? '',
      onChanged: _busy
          ? (_) {}
          : (v) {
              _choices[id] = v ?? '';
              _changed();
            },
      child: Column(
        children: [
          for (final o in [
            {'id': '', 'text': 'Unanswered'},
            ...q['options'] as List,
          ])
            RadioListTile<String>(
              key: ValueKey('reading-option-$id-${o['id']}'),
              value: o['id'] as String,
              title: Text(o['text'] as String),
              enabled: !_busy,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _questionsView() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Your first answers',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      const Text(
        'Answer what you can. Checking preserves this first attempt, including unanswered items, and reveals explanations. You can then make a separate revision.',
      ),
      SwitchListTile(
        key: const ValueKey('hide-reading-passage'),
        contentPadding: EdgeInsets.zero,
        value: _hide,
        onChanged: _busy
            ? null
            : (v) {
                _hide = v;
                _changed();
              },
        title: const Text('Hide passage for summary practice'),
        subtitle: const Text(
          'An optional memory aid. You can reveal it at any time; no penalty.',
        ),
      ),
      const SizedBox(height: 16),
      for (final q in _questions)
        _card([
          Text(
            (q['kind'] as String).toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            q['prompt'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _input(q),
        ]),
      FilledButton(
        key: const ValueKey('check-reading'),
        onPressed: _busy ? null : _check,
        child: const Text('Preserve answers and check explanations'),
      ),
    ],
  );

  Widget _review() {
    final results = jsonDecode(_workspace!.keyResults!) as Map<String, dynamic>;
    final correct = results.values
        .where((r) => r['status'] == 'correct')
        .length;
    final unanswered = results.values
        .where((r) => r['status'] == 'unanswered')
        .length;
    final revised = ReadingRepository.keyedResults(
      _session.detail!.exercise,
      _current(),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review, then revise',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          'First attempt · $correct/${results.length} keyed answers correct · $unanswered unanswered',
          key: const ValueKey('reading-first-score'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Only the three closed questions are scored. Open answers are not automatically graded. Your first answers stay unchanged; revisions below were made after seeing explanations.',
        ),
        const SizedBox(height: 24),
        for (final q in _questions)
          _card([
            Text(
              q['prompt'] as String,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text('Preserved first answer'),
            const SizedBox(height: 8),
            SelectableText(
              _answerLabel(q, _first[q['id']]),
              key: ValueKey('reading-first-${q['id']}'),
            ),
            const SizedBox(height: 16),
            if (!isOpenQuestion(q)) ...[
              Text('First-attempt key result: ${results[q['id']]['status']}'),
              const SizedBox(height: 8),
              Text('Key: ${_answerLabel(q, q['answerKey'])}'),
              const SizedBox(height: 8),
              Text(q['rationale'] as String),
              const SizedBox(height: 16),
              const Text('Revise your choice (after explanation)'),
              _input(q),
              Text(
                'Revision key result: ${revised[q['id']]['status']} · does not change the first-attempt result',
              ),
            ] else ...[
              const Text(
                'Sample reasoning · one possible answer, not a required wording',
              ),
              const SizedBox(height: 8),
              SelectableText(q['sampleReasoning'] as String),
              const SizedBox(height: 16),
              for (final prompt in q['reviewPrompts'] as List)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• $prompt'),
                ),
              const SizedBox(height: 8),
              _input(q),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('reading-rating-${q['id']}'),
                initialValue: _ratings[q['id']] as String? ?? 'none',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Your assessment of the revised answer',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Not assessed')),
                  DropdownMenuItem(
                    value: 'emerging',
                    child: Text('Needs attention'),
                  ),
                  DropdownMenuItem(
                    value: 'developing',
                    child: Text('Developing'),
                  ),
                  DropdownMenuItem(
                    value: 'effective',
                    child: Text('Effective'),
                  ),
                ],
                onChanged: _busy
                    ? null
                    : (v) {
                        _ratings[q['id'] as String] = v == 'none' ? null : v;
                        _changed();
                      },
              ),
              const SizedBox(height: 8),
              const Text(
                'Needs attention: key meaning or support is missing. Developing: mostly sound, with a specific gap. Effective: accurate, supported and clear. Not assessed is always allowed.',
              ),
            ],
          ]),
        FilledButton(
          key: const ValueKey('save-reading-review'),
          onPressed: _busy
              ? null
              : () => _run(() async {
                  await _reading.save(
                    widget.sessionId,
                    answers: _first,
                    revisions: _current(),
                    ratings: _ratings,
                    step: _step,
                    hidePassage: _hide,
                    now: DateTime.now(),
                    reviewed: true,
                  );
                  _session.detail = await _session.repository.load(
                    widget.sessionId,
                  );
                }),
          child: const Text('Save review and revisions'),
        ),
        const SizedBox(height: 12),
        Text('Human self-review · ${_session.detail!.reviewStatus.name}'),
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
        title: const Text('Reading Lab'),
      ),
      body: SafeArea(
        child: _workspace == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error ?? 'Opening your reading…'),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final split =
                      constraints.maxWidth >= 1100 &&
                      MediaQuery.textScalerOf(context).scale(16) <= 21;
                  final hidden = _step == 'questions' && _hide;
                  final content = _step == 'passage'
                      ? _passage()
                      : _checked
                      ? _review()
                      : _questionsView();
                  return Column(
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
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final step in [
                              'passage',
                              if (!_checked) 'questions',
                              if (_checked) 'review',
                            ])
                              ChoiceChip(
                                key: ValueKey('reading-view-$step'),
                                selected: _step == step,
                                label: Text(
                                  step[0].toUpperCase() + step.substring(1),
                                ),
                                onSelected: _busy ? null : (_) => _view(step),
                              ),
                            Text(
                              _dirty ? 'Saving…' : 'Saved on this device',
                              key: const ValueKey('reading-save-status'),
                            ),
                            TextButton(
                              key: const ValueKey('reading-save-now'),
                              onPressed: _busy ? null : () => _run(() async {}),
                              child: const Text('Save now'),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      if (hidden)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text('Passage hidden for summary practice'),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : () {
                                        _hide = false;
                                        _changed();
                                      },
                                child: const Text('Reveal passage'),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: split && _step != 'passage' && !hidden
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _scroll('passage-side', _passage()),
                                  ),
                                  const VerticalDivider(width: 1),
                                  Expanded(child: _scroll(_step, content)),
                                ],
                              )
                            : Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 900,
                                  ),
                                  child: _scroll(_step, content),
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
