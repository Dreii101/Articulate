import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'session_controller.dart';
import 'storage/practice_repository.dart';
import 'writing/writing_page.dart';
import 'exercises.dart';
import 'reading/reading_page.dart';
import 'speech/speech_page.dart';
import 'memory/memory_page.dart';
import 'debate/debate_page.dart';
import 'impromptu/impromptu_page.dart';

Widget savedPracticePage(String id, String module) => module == 'writing'
    ? WritingPage(sessionId: id)
    : module == 'reading'
    ? ReadingAttemptPage(sessionId: id)
    : module == 'speech'
    ? SpeechPage(sessionId: id)
    : module == 'memory'
    ? MemorySavedPage(sessionId: id)
    : module == 'debate'
    ? DebateSavedPage(sessionId: id)
    : module == 'impromptu'
    ? ImpromptuSavedPage(sessionId: id)
    : PracticePage(sessionId: id);

// Earlier Impromptu previews keep their original generic workspace.
class ImpromptuSavedPage extends ConsumerStatefulWidget {
  const ImpromptuSavedPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<ImpromptuSavedPage> createState() => _ImpromptuSavedPageState();
}

class _ImpromptuSavedPageState extends ConsumerState<ImpromptuSavedPage> {
  late final _load = ref.read(repositoryProvider).load(widget.sessionId);
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _load,
    builder: (context, s) => s.hasData
        ? s.data!.exercise.content.containsKey('impromptu')
              ? ImpromptuPage(sessionId: widget.sessionId)
              : PracticePage(sessionId: widget.sessionId)
        : Scaffold(
            appBar: AppBar(title: const Text('Impromptu Arena')),
            body: Center(
              child: Text(
                s.hasError
                    ? 'Saved round could not be opened. Your data has not been reset.'
                    : 'Opening saved round…',
              ),
            ),
          ),
  );
}

// Earlier Debate previews keep their original generic workspace.
class DebateSavedPage extends ConsumerStatefulWidget {
  const DebateSavedPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<DebateSavedPage> createState() => _DebateSavedPageState();
}

class _DebateSavedPageState extends ConsumerState<DebateSavedPage> {
  late final _load = ref.read(repositoryProvider).load(widget.sessionId);
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _load,
    builder: (context, s) => s.hasData
        ? s.data!.exercise.content.containsKey('debate')
              ? DebatePage(sessionId: widget.sessionId)
              : PracticePage(sessionId: widget.sessionId)
        : Scaffold(
            appBar: AppBar(title: const Text('Debate Arena')),
            body: Center(
              child: Text(
                s.hasError
                    ? 'Saved round could not be opened. Your data has not been reset.'
                    : 'Opening saved round…',
              ),
            ),
          ),
  );
}

// Legacy Memory previews keep their original generic workspace.
class MemorySavedPage extends ConsumerStatefulWidget {
  const MemorySavedPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<MemorySavedPage> createState() => _MemorySavedPageState();
}

class _MemorySavedPageState extends ConsumerState<MemorySavedPage> {
  late final _load = ref.read(repositoryProvider).load(widget.sessionId);
  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _load,
    builder: (context, s) => s.hasData
        ? s.data!.exercise.content.containsKey('memory')
              ? MemoryAttemptPage(sessionId: widget.sessionId)
              : PracticePage(sessionId: widget.sessionId)
        : Scaffold(
            appBar: AppBar(title: const Text('Memory Trainer')),
            body: Center(
              child: Text(
                s.hasError
                    ? 'Saved recall could not be opened. Your data has not been reset.'
                    : 'Opening saved recall…',
              ),
            ),
          ),
  );
}

// Legacy Reading previews retain their original free-text workspace and data.
class ReadingAttemptPage extends ConsumerWidget {
  const ReadingAttemptPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(repositoryProvider).load(sessionId),
    builder: (context, snapshot) => snapshot.hasData
        ? snapshot.data!.exercise.content.containsKey('reading')
              ? ReadingPage(sessionId: sessionId)
              : PracticePage(sessionId: sessionId)
        : Scaffold(
            body: Center(
              child: Text(
                snapshot.hasError
                    ? 'Saved reading could not be opened. Your data has not been reset.'
                    : 'Opening saved reading…',
              ),
            ),
          ),
  );
}

String practiceDuration(int ms) {
  final seconds = ms ~/ 1000;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class SavedSessions extends ConsumerWidget {
  const SavedSessions({super.key, this.recoverableOnly = false});
  final bool recoverableOnly;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(sessionsProvider);
    final writing = ref.watch(writingWorkspacesProvider).value ?? {};
    return saved.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Text('Opening saved work…'),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved work could not be loaded. Your data has not been reset.',
            ),
            TextButton(
              onPressed: () => ref.invalidate(sessionsProvider),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
      data: (rows) {
        final items = rows
            .where((s) => !recoverableOnly || !isTerminal(s.status))
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                recoverableOnly ? 'Continue your practice' : 'Saved practice',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final s in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.moduleId[0].toUpperCase()}${s.moduleId.substring(1)} · ${s.localPracticeDate}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(Exercise.fromSnapshot(s.snapshot).title),
                          Text(
                            'Exercise v${s.exerciseVersion} · rubric v${Exercise.fromSnapshot(s.snapshot).content['rubric']['version']}',
                          ),
                          if (writing[s.id] case final version?)
                            Text(
                              'Version ${version.versionNumber} · ${version.parentSessionId == null ? 'Original' : 'Revision'}',
                            ),
                          Text('${s.status} · ${s.stage}'),
                          const SizedBox(height: 8),
                          FilledButton.tonal(
                            key: ValueKey('resume-${s.id}'),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    savedPracticePage(s.id, s.moduleId),
                              ),
                            ),
                            child: Text(
                              isTerminal(s.status)
                                  ? 'Open saved attempt'
                                  : 'Resume',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage>
    with WidgetsBindingObserver {
  late final SessionController _controller;
  final _response = TextEditingController();
  final _review = TextEditingController();
  Timer? _autosave;
  Timer? _heartbeat;
  String? _error;
  bool _busy = false;
  bool _saving = false;
  bool _ticking = false;
  bool _active = true;
  bool _canPop = false;
  bool _reviewDirty = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = SessionController(
      ref.read(repositoryProvider),
      widget.sessionId,
    );
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await _controller.open();
      if (!mounted) return;
      _response.text = detail.response.body;
      _review.text = detail.review?.notes ?? '';
      setState(() => _error = null);
      _heartbeat ??= Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Saved work could not be opened. Go back and try again; your data has not been reset.',
        );
      }
    }
  }

  void _changed(String _) {
    setState(() => _saving = true);
    _autosave?.cancel();
    _autosave = Timer(
      const Duration(milliseconds: 400),
      () => _action(() async {}, savingOnly: true),
    );
  }

  Future<void> _flush() async {
    _autosave?.cancel();
    final d = _controller.detail;
    if (d == null) return;
    if (!isTerminal(d.session.status) && _response.text != d.response.body) {
      await _controller.saveResponse(_response.text);
    }
    if (_reviewDirty && d.session.status == 'completed') {
      final notes = _review.text;
      await _controller.saveReview(notes, ReviewStatus.inProgress);
      if (_review.text == notes) _reviewDirty = false;
    }
    if (mounted) {
      setState(
        () => _saving =
            _response.text != _controller.detail?.response.body || _reviewDirty,
      );
    }
  }

  Future<void> _action(
    Future<void> Function() operation, {
    bool savingOnly = false,
  }) async {
    if (_busy && !savingOnly) return;
    if (mounted && !savingOnly) setState(() => _busy = true);
    try {
      await _flush();
      await operation();
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save this change. Keep this window open and try Save again.',
        );
      }
    } finally {
      if (mounted && !savingOnly) setState(() => _busy = false);
    }
  }

  Future<void> _tick() async {
    if (!_active || _busy || _ticking || _controller.detail == null) return;
    _ticking = true;
    try {
      await _controller.checkpoint();
      if (mounted) setState(() {});
    } catch (_) {
      // Stop crediting time after a failed checkpoint until the user explicitly resumes.
      await _controller.leave().catchError((Object _) {});
      if (mounted) {
        setState(
          () => _error = 'The timing checkpoint could not be saved. Check storage and try Save again.',
        );
      }
    } finally {
      _ticking = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active) _action(_controller.leave, savingOnly: true);
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    try {
      await _flush();
      await _controller.leave();
      return AppExitResponse.exit;
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save before closing. Try Save again.',
        );
      }
      return AppExitResponse.cancel;
    }
  }

  Future<void> _back() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _flush();
      await _controller.leave();
      if (!mounted) return;
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Your latest edits could not be saved. Try Save again before leaving.';
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    _heartbeat?.cancel();
    _response.dispose();
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _controller.detail;
    final terminal = d != null && isTerminal(d.session.status);
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _busy ? null : _back),
          title: const Text('Saved practice'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      TextButton(
                        onPressed: d == null
                            ? _load
                            : () => _action(() async {}),
                        child: Text(d == null ? 'Try again' : 'Save again'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (d == null && _error == null)
                      const Text('Opening your draft…'),
                    if (d != null) ...[
                      Text(
                        d.exercise.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${d.session.status.toUpperCase()} · ${d.session.localPracticeDate} · ${d.exercise.language} · content v${d.exercise.version}',
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        d.exercise.prompt,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Known active time: ${practiceDuration(_controller.elapsedMs)}',
                        key: const ValueKey('elapsed'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      for (final stage in PracticeStage.values)
                        Text(
                          '${stage.name}: ${practiceDuration(d.elapsedFor(stage))}',
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pauses and time away are excluded. After an unexpected stop, only the last saved checkpoint counts. The timer stays stopped until you resume.',
                      ),
                      if (d.session.status == 'interrupted') ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Interrupted work recovered. Your response and saved time are intact; no unknown time was added.',
                        ),
                      ],
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final stage in PracticeStage.values)
                            ChoiceChip(
                              label: Text(
                                stage.name[0].toUpperCase() +
                                    stage.name.substring(1),
                              ),
                              key: ValueKey('stage-${stage.name}'),
                              selected: d.session.stage == stage.name,
                              onSelected: terminal || _busy
                                  ? null
                                  : (_) => _action(
                                      () => _controller.changeStage(stage),
                                    ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _response,
                        key: const ValueKey('response'),
                        readOnly: terminal,
                        enabled: !_busy,
                        minLines: 5,
                        maxLines: 14,
                        maxLength: PracticeRepository.maxResponseLength,
                        decoration: const InputDecoration(
                          labelText: 'Your response or practice notes',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _changed,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _saving ? 'Saving…' : 'Saved on this device',
                        key: const ValueKey('save-status'),
                      ),
                      const SizedBox(height: 12),
                      if (!terminal)
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              key: const ValueKey('start-pause'),
                              onPressed: _busy
                                  ? null
                                  : () => _action(
                                      d.session.status == 'running'
                                          ? () => _controller.transition(
                                              PracticeStatus.paused,
                                            )
                                          : _controller.start,
                                    ),
                              child: Text(
                                d.session.status == 'running'
                                    ? 'Pause'
                                    : d.session.status == 'draft'
                                    ? 'Start timer'
                                    : 'Resume timer',
                              ),
                            ),
                            OutlinedButton(
                              onPressed: _busy
                                  ? null
                                  : () => _action(() async {}),
                              child: const Text('Save now'),
                            ),
                            OutlinedButton(
                              key: const ValueKey('complete'),
                              onPressed: _busy
                                  ? null
                                  : () => _action(
                                      () => _controller.transition(
                                        PracticeStatus.completed,
                                      ),
                                    ),
                              child: const Text('Complete attempt'),
                            ),
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () async {
                                      final abandon = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Abandon this attempt?',
                                          ),
                                          content: const Text(
                                            'Your response and saved time will stay in History. This closes the attempt.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text(
                                                'Keep practicing',
                                              ),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Abandon'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (abandon == true && mounted) {
                                        await _action(
                                          () => _controller.transition(
                                            PracticeStatus.abandoned,
                                          ),
                                        );
                                      }
                                    },
                              child: const Text('Abandon'),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Your saved rubric',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      for (final c in d.exercise.criteria)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('${c['label']}\n${c['description']}'),
                        ),
                      if (d.session.status == 'completed') ...[
                        const SizedBox(height: 24),
                        Text(
                          'Self-review · ${d.reviewStatus.name}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _review,
                          key: const ValueKey('review-notes'),
                          minLines: 3,
                          maxLines: 8,
                          maxLength: PracticeRepository.maxResponseLength,
                          decoration: const InputDecoration(
                            labelText: 'Reflection notes',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _reviewDirty = true;
                            _changed(value);
                          },
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: _busy
                              ? null
                              : () => _action(
                                  () => _controller.saveReview(
                                    _review.text,
                                    ReviewStatus.reviewed,
                                  ),
                                ),
                          child: const Text('Mark reviewed'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Authorship: ${d.exercise.content['authorship']['creator']}\nLicense: ${d.exercise.content['license']['id']}\n${d.exercise.content['license']['notice']}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
