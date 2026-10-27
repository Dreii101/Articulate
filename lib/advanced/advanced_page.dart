import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exercises.dart';
import '../history/history_page.dart';
import '../history/history_repository.dart';
import '../practice_page.dart';
import '../providers.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'advanced_repository.dart';

class AdvancedPracticeLink extends StatelessWidget {
  const AdvancedPracticeLink({super.key});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: const Icon(Icons.tune),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const AdvancedPracticePage()),
    ),
    label: const Text('Review queue & custom practice'),
  );
}

class AdvancedPracticePage extends ConsumerStatefulWidget {
  const AdvancedPracticePage({super.key});
  @override
  ConsumerState<AdvancedPracticePage> createState() =>
      _AdvancedPracticePageState();
}

class _AdvancedPracticePageState extends ConsumerState<AdvancedPracticePage>
    with WidgetsBindingObserver {
  bool _busy = false;
  String? _error;
  final _intervals = TextEditingController();
  Timer? _dayRefresh;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dayRefresh = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    ref
        .read(advancedRepositoryProvider)
        .intervals()
        .then((v) {
          if (mounted) _intervals.text = v.join(', ');
        })
        .catchError((Object _) {
          if (mounted) {
            setState(
              () => _error = 'Saved intervals could not be loaded. Reopen this page to retry.',
            );
          }
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  @override
  void dispose() {
    _dayRefresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _intervals.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not save this action. Existing work is preserved. Retry when ready.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(String id, String module) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => savedPracticePage(id, module)),
    );
  }

  Future<void> _retry(HistoryEntry e, String target) => _run(() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PracticeConditionsPage(
          exercise: e.exercise,
          parent: e.id,
          target: target,
        ),
      ),
    );
  });
  @override
  Widget build(BuildContext context) {
    ref.watch(advancedChangesProvider);
    final repo = ref.watch(advancedRepositoryProvider);
    final settings = ref.watch(settingsProvider).asData?.value ?? {};
    final recommendations = settings['practiceRecommendations'] != 'false';
    final history =
        ref.watch(historyProvider).asData?.value ?? <HistoryEntry>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Your practice choices')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Keep control of what comes next. Schedules and labels describe practice conditions; they do not measure mastery.',
                  ),
                  if (_error != null)
                    Semantics(liveRegion: true, child: Text(_error!)),
                  historyCard([
                    Text(
                      'Memory review schedule',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(scheduleExplanation),
                    TextField(
                      key: const ValueKey('review-intervals'),
                      controller: _intervals,
                      decoration: const InputDecoration(
                        labelText: 'Intervals in days',
                        helperText: 'Comma-separated, for example 1, 3, 7, 14',
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                              final values = _intervals.text
                                  .split(',')
                                  .map((s) => int.tryParse(s.trim()))
                                  .toList();
                              await repo.saveIntervals(
                                validateIntervals(values),
                              );
                            }),
                      child: const Text(
                        'Save intervals for future observations',
                      ),
                    ),
                    const Text(
                      'Existing due dates remain unchanged. Override a date below or pause its queue item. No catch-up sessions are added.',
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Show optional practice recommendations',
                      ),
                      value: recommendations,
                      onChanged: _busy
                          ? null
                          : (v) => _run(
                              () => ref
                                  .read(repositoryProvider)
                                  .saveSetting('practiceRecommendations', '$v'),
                            ),
                    ),
                  ]),
                  Text(
                    'Due reviews',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Today on this device: ${calendarDate(DateTime.now())}. Dates are local calendar days, not 24-hour countdowns.',
                  ),
                  FutureBuilder(
                    future: repo.queue(),
                    builder: (context, s) {
                      if (s.hasError) {
                        return const Text(
                          'Could not load the queue. Reopen this page to retry.',
                        );
                      }
                      if (!s.hasData) {
                        return const Text('Opening review queue…');
                      }
                      final rows = s.data!;
                      if (rows.isEmpty) {
                        return const Text(
                          'No scheduled reviews. Complete a Memory recall, then record an explicit observation in its review.',
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final r in rows)
                            historyCard([
                              Text(
                                r.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${r.schedule.paused
                                    ? 'Paused'
                                    : r.due(calendarDate(DateTime.now()))
                                    ? 'Due'
                                    : 'Upcoming'} · ${r.date} · ${r.workspace.mode}',
                              ),
                              Text(
                                '${observationLabel(r.schedule.observation)} on ${r.schedule.observedLocalDate}; interval ${r.schedule.intervalDays} days. ${r.schedule.overrideDate == null ? 'Heuristic date.' : 'Date overridden by you.'}',
                              ),
                              if (r.newerVersion)
                                const Text(
                                  'A newer speech version exists. This review keeps the original version; choose the newer version in Memory Trainer to start a separate schedule.',
                                ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => HistoryAttemptPage(
                                          sessionId: r.workspace.sessionId,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Inspect observation & evidence',
                                    ),
                                  ),
                                  if (recommendations)
                                    FilledButton.tonal(
                                      onPressed: _busy
                                          ? null
                                          : () => _run(() async {
                                              final d = await ref
                                                  .read(repositoryProvider)
                                                  .load(r.workspace.sessionId);
                                              final id = await repo.start(
                                                d.exercise,
                                                stableId(),
                                                DateTime.now(),
                                                parent: r.workspace.sessionId,
                                                target:
                                                    'Scheduled recall: ${observationLabel(r.schedule.observation)}; exact practiced version and section.',
                                              );
                                              await _open(id, 'memory');
                                            }),
                                      child: const Text(
                                        'Practice / reopen this review',
                                      ),
                                    ),
                                ],
                              ),
                              RecallScheduleCard(
                                sessionId: r.workspace.sessionId,
                                compact: true,
                              ),
                            ]),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Custom exercises',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    'Create a local version from a validated template. Memory speeches keep their own section editor. Published versions and past attempts are never overwritten.',
                  ),
                  FilledButton.tonal(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const CustomExerciseEditor(),
                      ),
                    ),
                    child: const Text('Create custom exercise'),
                  ),
                  FutureBuilder(
                    future: repo.customVersions(),
                    builder: (context, s) {
                      if (s.hasError) {
                        return const Text(
                          'Custom exercises could not be opened.',
                        );
                      }
                      if (!s.hasData) {
                        return const Text('Opening custom exercises…');
                      }
                      final latest = <String, CustomExercise>{};
                      for (final row in s.data!) {
                        latest.putIfAbsent(row.id, () => row);
                      }
                      return Column(
                        children: [
                          for (final row in latest.values)
                            historyCard([
                              Text(
                                '${Exercise.fromSnapshot(row.snapshot).title} · version ${row.version}',
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            CustomExerciseEditor(existing: row),
                                      ),
                                    ),
                                    child: const Text('Edit as new version'),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => PracticeConditionsPage(
                                          exercise: Exercise.fromSnapshot(
                                            row.snapshot,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Choose conditions & practice',
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Benchmark or unfamiliar task',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    'Benchmark means repeatable conditions you name. Unfamiliar means your own report of no prior exposure; it is not verified. Merely reading this catalogue exposes the title.',
                  ),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Choose a task and label its conditions',
                    ),
                    items: [
                      for (final e
                          in ref
                              .watch(exercisesProvider)
                              .where(
                                (e) =>
                                    e.module != 'memory' &&
                                    (e.module == 'speech' ||
                                        e.content.containsKey(e.module)),
                              ))
                        DropdownMenuItem(
                          value: e.id,
                          child: Text(
                            '${e.title} · ${e.level}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => PracticeConditionsPage(
                              exercise: ref
                                  .read(exercisesProvider)
                                  .firstWhere((e) => e.id == id),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (recommendations) ...[
                    Text(
                      'Target one improvement',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Text(
                      'Suggestions below come only from completed attempts with a saved next action/reflection or explicitly missed recall criteria. Choosing one starts new work on the original task version.',
                    ),
                    if (!history.any(
                      (e) =>
                          e.session.status == 'completed' &&
                          retryBasis(e).isNotEmpty,
                    ))
                      const Text(
                        'No saved retry targets yet. Add a next action in a review or mark a missed Memory criterion.',
                      ),
                    for (final e in history.where(
                      (e) =>
                          e.session.status == 'completed' &&
                          retryBasis(e).isNotEmpty,
                    ))
                      historyCard([
                        Text(e.exercise.title),
                        SelectableText('Basis: ${retryBasis(e)}'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      HistoryAttemptPage(sessionId: e.id),
                                ),
                              ),
                              child: const Text('Inspect saved evidence'),
                            ),
                            FilledButton.tonal(
                              onPressed: _busy
                                  ? null
                                  : () => _retry(e, retryBasis(e)),
                              child: const Text('Targeted retry'),
                            ),
                          ],
                        ),
                      ]),
                  ] else
                    const Text(
                      'Recommendations are hidden. Your queue, custom exercises and all six modules remain available.',
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

String retryBasis(HistoryEntry e) {
  final missed = e.memory == null
      ? <String>[]
      : (jsonDecode(e.memory!.assessments) as Map).entries
            .where((v) => v.value == 'missed')
            .map((v) => v.key.toString())
            .toList();
  return [
    if (missed.isNotEmpty)
      'You marked ${missed.join(', ')} missed in this section.',
    if (e.reviewNote.trim().isNotEmpty) e.reviewNote,
  ].join('\n');
}

class PracticeConditionsPage extends ConsumerStatefulWidget {
  const PracticeConditionsPage({
    super.key,
    required this.exercise,
    this.parent,
    this.target = '',
  });
  final Exercise exercise;
  final String? parent;
  final String target;
  @override
  ConsumerState<PracticeConditionsPage> createState() =>
      _PracticeConditionsPageState();
}

class _PracticeConditionsPageState
    extends ConsumerState<PracticeConditionsPage> {
  String _label = 'practice';
  final _conditions = TextEditingController();
  final _target = TextEditingController();
  final _request = stableId();
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _target.text = widget.target;
  }

  @override
  void dispose() {
    _target.dispose();
    _conditions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice conditions')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercise.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${widget.exercise.language} · ${widget.exercise.level} · content v${widget.exercise.version}',
            ),
            Text(
              widget.parent != null
                  ? 'Retry of saved work. The exact source version and module setup are retained. New timer segments count only new work. ${widget.target}'
                  : 'Practice is untimed initially. Debate starts on the For side; change setup through the regular module for other presets. Record any planned conditions here. Actual timing and assistance remain visible in history.',
            ),
            DropdownButtonFormField<String>(
              initialValue: _label,
              decoration: const InputDecoration(labelText: 'Practice label'),
              items: [
                for (final label in practiceLabels)
                  DropdownMenuItem(value: label, child: Text(label)),
              ],
              onChanged: _busy ? null : (v) => setState(() => _label = v!),
            ),
            const Text(
              'Unfamiliar is a self-report of prior exposure, not a difficulty or performance score. Already practiced and user-authored tasks cannot receive it.',
            ),
            TextField(
              controller: _conditions,
              maxLength: 4000,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Conditions / benchmark name',
                hintText: 'For example: quiet room, hidden cues, untimed',
              ),
            ),
            if (widget.parent != null)
              TextField(
                controller: _target,
                maxLength: 10000,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Focus for this retry',
                  helperText:
                      'Edit the suggestion. The original review is preserved.',
                ),
              ),
            if (_error != null)
              Semantics(liveRegion: true, child: Text(_error!)),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() {
                        _busy = true;
                        _error = null;
                      });
                      try {
                        final id = await ref
                            .read(advancedRepositoryProvider)
                            .start(
                              widget.exercise,
                              _request,
                              DateTime.now(),
                              label: _label,
                              conditions: _conditions.text,
                              parent: widget.parent,
                              target: _target.text,
                            );
                        if (context.mounted) {
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  savedPracticePage(id, widget.exercise.module),
                            ),
                          );
                        }
                      } on FormatException catch (e) {
                        if (mounted) setState(() => _error = e.message);
                      } catch (_) {
                        if (mounted) {
                          setState(
                            () => _error = 'Could not start practice. Retry without losing existing work.',
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: const Text('Start with these conditions'),
            ),
          ],
        ),
      ),
    ),
  );
}

class RecallScheduleCard extends ConsumerStatefulWidget {
  const RecallScheduleCard({
    super.key,
    required this.sessionId,
    this.compact = false,
  });
  final String sessionId;
  final bool compact;
  @override
  ConsumerState<RecallScheduleCard> createState() => _RecallScheduleCardState();
}

class _RecallScheduleCardState extends ConsumerState<RecallScheduleCard> {
  String? _observation, _error;
  bool _busy = false;
  final _date = TextEditingController();
  @override
  void dispose() {
    _date.dispose();
    super.dispose();
  }

  Future<void> _save(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save the schedule. Retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(advancedChangesProvider);
    final repo = ref.watch(advancedRepositoryProvider), db = repo.db;
    return FutureBuilder(
      future: (db.select(
        db.recallSchedules,
      )..where((s) => s.sessionId.equals(widget.sessionId))).getSingleOrNull(),
      builder: (context, s) {
        if (s.connectionState != ConnectionState.done) {
          return const Text('Opening schedule…');
        }
        if (s.hasError) {
          return const Text('Schedule unavailable. Reopen to retry.');
        }
        final row = s.data;
        return historyCard([
          if (!widget.compact) ...[
            Text(
              'Optional next recall',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(scheduleExplanation),
          ],
          if (row == null) ...[
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _observation,
              decoration: const InputDecoration(
                labelText: 'My explicit recall observation',
              ),
              items: [
                for (final o in recallObservations)
                  DropdownMenuItem(
                    value: o,
                    child: Text(
                      observationLabel(o),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _busy ? null : (v) => setState(() => _observation = v),
            ),
            FilledButton.tonal(
              onPressed: _busy || _observation == null
                  ? null
                  : () => _save(() async {
                      await repo.observe(
                        widget.sessionId,
                        _observation!,
                        DateTime.now(),
                      );
                    }),
              child: const Text('Record observation & schedule'),
            ),
          ] else ...[
            Text(
              '${observationLabel(row.observation)} · ${row.observedLocalDate}',
            ),
            Text(
              'Heuristic date ${row.recommendedDate} (${row.intervalDays} days). Current: ${row.overrideDate ?? row.recommendedDate}${row.paused ? ' · paused' : ''}.',
            ),
            const Text(
              'The observation is preserved. A new completed recall can add a new observation.',
            ),
            TextField(
              controller: _date,
              decoration: const InputDecoration(
                labelText: 'Override due date (YYYY-MM-DD)',
                helperText: 'Leave blank to restore the heuristic date.',
              ),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _save(
                      () => repo.override(
                        widget.sessionId,
                        date: _date.text.trim().isEmpty
                            ? null
                            : _date.text.trim(),
                        paused: row.paused,
                      ),
                    ),
              child: const Text('Apply date override'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pause this scheduled review'),
              value: row.paused,
              onChanged: _busy
                  ? null
                  : (v) => _save(
                      () => repo.override(
                        widget.sessionId,
                        date: row.overrideDate,
                        paused: v,
                      ),
                    ),
            ),
          ],
          if (_error != null) Semantics(liveRegion: true, child: Text(_error!)),
        ]);
      },
    );
  }
}

class CustomExerciseEditor extends ConsumerStatefulWidget {
  const CustomExerciseEditor({super.key, this.existing});
  final CustomExercise? existing;
  @override
  ConsumerState<CustomExerciseEditor> createState() =>
      _CustomExerciseEditorState();
}

class _CustomExerciseEditorState extends ConsumerState<CustomExerciseEditor> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _prompt = TextEditingController(),
      _source = TextEditingController();
  final _author = TextEditingController(text: 'User supplied'),
      _license = TextEditingController(
        text: 'Personal local use; rights supplied by the author.',
      );
  String? _template, _error;
  bool _busy = false, _dirty = false;
  void _load(Exercise e) {
    _template = e.id;
    _title.text = e.title;
    _prompt.text = e.prompt;
    final document = e.document;
    if (widget.existing == null) {
      final content =
          (document['exercises'] as List).single as Map<String, dynamic>;
      final author = content['authorship'] as Map,
          license = content['license'] as Map;
      content['authorship'] = {
        ...author,
        'source':
            'Adapted from ${author['creator']}: ${author['source']} Original terms: ${license['id']} — ${license['notice']}',
      };
    }
    _source.text = const JsonEncoder.withIndent('  ').convert(document);
    if (widget.existing != null) {
      _author.text = e.content['authorship']['creator'];
      _license.text = e.content['license']['notice'];
    }
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) _load(Exercise.fromSnapshot(e.snapshot));
  }

  @override
  void dispose() {
    for (final c in [_title, _prompt, _source, _author, _license]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref
        .watch(exercisesProvider)
        .where(
          (e) =>
              e.module != 'memory' &&
              (e.module == 'speech' || e.content.containsKey(e.module)),
        )
        .toList();
    return PopScope(
      canPop: !_busy && !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _busy || !_dirty) return;
        final discard = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Leave unpublished changes?'),
            content: const Text(
              'Published versions are safe. This editor has unsaved changes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Keep editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Discard unpublished changes'),
              ),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          setState(() => _dirty = false);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existing == null
                ? 'Create custom exercise'
                : 'Publish a new exercise version',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Start from a complete template, then make it yours. The structured content keeps language, level, rubric anchors, module questions and source metadata. Saving validates everything before publishing a local version.',
                      ),
                      if (widget.existing == null)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _template,
                          decoration: const InputDecoration(
                            labelText: 'Template',
                          ),
                          items: [
                            for (final e in templates)
                              DropdownMenuItem(
                                value: e.id,
                                child: Text(
                                  '${e.title} · ${e.module}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: _busy || _dirty
                              ? null
                              : (id) => setState(
                                  () => _load(
                                    templates.firstWhere((e) => e.id == id),
                                  ),
                                ),
                        ),
                      if (_template != null) ...[
                        for (final f in [
                          (
                            controller: _title,
                            label: 'Exercise title',
                            lines: 1,
                          ),
                          (controller: _prompt, label: 'Your prompt', lines: 4),
                          (
                            controller: _author,
                            label: 'Creator / attribution',
                            lines: 1,
                          ),
                          (
                            controller: _license,
                            label: 'License / permitted use',
                            lines: 3,
                          ),
                        ])
                          TextFormField(
                            controller: f.controller,
                            minLines: f.lines,
                            maxLines: f.lines + 4,
                            maxLength: 50000,
                            decoration: InputDecoration(labelText: f.label),
                            onChanged: (_) {
                              if (!_dirty) setState(() => _dirty = true);
                            },
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ExpansionTile(
                          title: const Text(
                            'Edit language, level, rubric and full module content',
                          ),
                          subtitle: const Text(
                            'Validated JSON · title, prompt, creator and license above take precedence',
                          ),
                          children: [
                            TextFormField(
                              key: const ValueKey('custom-json'),
                              controller: _source,
                              minLines: 12,
                              maxLines: 25,
                              maxLength: 1000000,
                              decoration: const InputDecoration(
                                labelText: 'Complete exercise JSON',
                              ),
                              onChanged: (_) {
                                if (!_dirty) setState(() => _dirty = true);
                              },
                            ),
                          ],
                        ),
                        const Text(
                          'For Reading, edit the passage, answer keys and rationales together. For Debate, opposition remains labelled scripted practice. Memory speeches use Memory Trainer. Save publishes a version; this editor does not autosave unsaved changes.',
                        ),
                        if (_error != null)
                          Semantics(liveRegion: true, child: Text(_error!)),
                        FilledButton(
                          onPressed: _busy
                              ? null
                              : () async {
                                  if (!_form.currentState!.validate()) return;
                                  setState(() {
                                    _busy = true;
                                    _error = null;
                                  });
                                  try {
                                    final document = Exercise.fromSnapshot(
                                      _source.text,
                                    ).document;
                                    final e =
                                        (document['exercises'] as List).single
                                            as Map<String, dynamic>;
                                    e['title'] = _title.text.trim();
                                    e['prompt'] = _prompt.text.trim();
                                    final origin = e['authorship'] as Map;
                                    e['authorship'] = {
                                      'creator': _author.text.trim(),
                                      'kind': 'adapted',
                                      'source': origin['source'],
                                    };
                                    e['license'] = {
                                      'id': 'user-supplied',
                                      'notice': _license.text.trim(),
                                    };
                                    await ref
                                        .read(advancedRepositoryProvider)
                                        .saveCustom(
                                          jsonEncode(document),
                                          DateTime.now(),
                                          id: widget.existing?.id,
                                        );
                                    if (context.mounted) {
                                      setState(() {
                                        _busy = false;
                                        _dirty = false;
                                      });
                                      Navigator.pop(context);
                                    }
                                  } on FormatException catch (e) {
                                    if (mounted) {
                                      setState(() => _error = e.message);
                                    }
                                  } catch (_) {
                                    if (mounted) {
                                      setState(
                                        () => _error = 'Could not publish. Check the content and retry; existing versions are unchanged.',
                                      );
                                    }
                                  } finally {
                                    if (mounted) setState(() => _busy = false);
                                  }
                                },
                          child: const Text('Validate & publish local version'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
