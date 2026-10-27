import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalogue.dart';
import '../advanced/advanced_page.dart';
import '../practice_page.dart';
import '../audio/audio_panel.dart';
import '../audio/audio_provider.dart';
import '../audio/local_audio.dart';
import 'history_repository.dart';

String historyTime(int? ms) {
  if (ms == null) {
    return 'Not measured';
  }
  final s = ms ~/ 1000;
  final fraction = (ms % 1000)
      .toString()
      .padLeft(3, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '${s ~/ 3600}h ${(s % 3600) ~/ 60}m ${s % 60}${fraction.isEmpty ? '' : '.$fraction'}s';
}

String moduleName(String id) =>
    modules.where((m) => m.id == id).firstOrNull?.name ?? id;
Widget historyCard(List<Widget> children) => Card.outlined(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  ),
);
const metricDefinitions = '''Finalized timer time adds each closed timing segment once. It includes confirmed work from completed attempts, drafts, interrupted and abandoned attempts. Open segments and unknown interruption periods are excluded. Timers are optional: no recorded time does not mean no practice.



Preparation, response and review-stage time use the stage selected by the practice timer. Debate scripted-opposition time belongs to response; its reflection stage belongs to review. Post-completion self-review was generally not timed. A recorded zero is different from an unmeasured duration.



Playback listening time was not measured. Audio file length is retained media duration, not listening time or additional practice credit. It is never added to timer totals.



Retries and writing revisions have independent timing segments. Their own new work counts once; inherited text and parent durations add nothing. Editing or saving a review does not create more practice credit. Completed-attempt counts include separately saved versions and retries.



Dates use the original local practice date and stored offset, even after travel or midnight. All confirmed time for an attempt stays on that date. Date filters are inclusive.



Self-ratings remain human judgments. Answer-key results apply only to Reading first answers; revised open answers use separate self-review. Missing ratings stay Not assessed. Confidence is separate. No universal score or average of unlike rubrics is calculated.



Comparison requires completed attempts with the same task/version, language, level, rubric content/version and compatible practice settings. It shows evidence and the original assessor labels without claiming that changes prove improvement.''';
void showMetricDefinitions(BuildContext context) => showDialog<void>(
  context: context,
  builder: (c) => AlertDialog(
    title: const Text('What these numbers measure'),
    content: const SingleChildScrollView(
      child: SelectableText(metricDefinitions),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
    ],
  ),
);

class HistoryMetrics extends StatelessWidget {
  const HistoryMetrics({super.key, required this.summary});
  final HistorySummary summary;
  @override
  Widget build(BuildContext context) => historyCard([
    Text('Confirmed work', style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 12),
    const Text('For the current filters; clear filters to see all saved work.'),
    Text(
      '${summary.completed} completed attempts · ${summary.entries.length - summary.completed} other saved attempts',
    ),
    const Text(
      'Counts include saved versions and retries; they are not counts of unique skills mastered.',
    ),
    const SizedBox(height: 12),
    Text(
      'Finalized timer time: ${summary.entries.any((e) => e.durations.isNotEmpty) ? historyTime(summary.finalizedMs) : 'Not measured'}',
      key: const ValueKey('history-total'),
    ),
    Text('Preparation: ${historyTime(summary.stageMs('prepare'))}'),
    Text('Response: ${historyTime(summary.stageMs('respond'))}'),
    Text('Review stage: ${historyTime(summary.stageMs('reflect'))}'),
    const Text('Playback: Not measured · later review may also be unmeasured'),
    if (summary.openSegments > 0)
      Text(
        '${summary.openSegments} open timer segments excluded until finalized.',
      ),
    const SizedBox(height: 12),
    Text(
      'Self-ratings: ${summary.rated} provided · ${summary.unassessed} Not assessed. No combined score.',
    ),
    TextButton(
      onPressed: () => showMetricDefinitions(context),
      child: const Text('What these numbers measure'),
    ),
  ]);
}

class TodayProgress extends ConsumerWidget {
  const TodayProgress({
    super.key,
    required this.onExplore,
    required this.onHistory,
  });
  final VoidCallback onExplore, onHistory;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(historyProvider)
      .when(
        loading: () => const Text('Opening your next action…'),
        error: (_, _) => historyCard([
          const Text('Saved work could not be loaded.'),
          TextButton(
            onPressed: () => ref.invalidate(historyProvider),
            child: const Text('Retry saved work'),
          ),
        ]),
        data: (entries) {
          final action = historyNextAction(entries);
          return historyCard([
            Text(
              'Your next action',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (action == null) ...[
              const Text(
                'No recoverable or completed work yet. Choose a module and begin at your pace.',
              ),
              FilledButton(
                onPressed: onExplore,
                child: const Text('Choose a practice'),
              ),
            ] else ...[
              Text(
                '${moduleName(action.entry.session.moduleId)} · ${action.entry.statusLabel}',
              ),
              Text(action.entry.exercise.title),
              FilledButton(
                key: ValueKey('resume-${action.entry.id}'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => savedPracticePage(
                      action.entry.id,
                      action.entry.session.moduleId,
                    ),
                  ),
                ),
                child: Text(action.label),
              ),
            ],
            TextButton(
              onPressed: onHistory,
              child: const Text('View history & confirmed time'),
            ),
          ]);
        },
      );
}

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key, required this.onExplore});
  final VoidCallback onExplore;
  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  final _form = GlobalKey<FormState>(),
      _from = TextEditingController(),
      _to = TextEditingController();
  String? _module, _language, _level, _exercise, _status;
  String? _appliedFrom, _appliedTo;
  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  String? _dateError(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final date = DateTime.tryParse(value);
    return !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
            date == null ||
            date.toIso8601String().substring(0, 10) != value
        ? 'Use a real date: YYYY-MM-DD'
        : null;
  }

  Widget _select(
    String label,
    String? value,
    Map<String, String> options,
    ValueChanged<String?> onChange,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('history-filter-$label-$value'),
    initialValue: value ?? '',
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    items: [
      DropdownMenuItem(value: '', child: Text('All ${label.toLowerCase()}')),
      for (final e in options.entries)
        DropdownMenuItem(
          value: e.key,
          child: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (v) => setState(() => onChange(v == '' ? null : v)),
  );
  void _clear() => setState(() {
    _form.currentState?.reset();
    _module = null;
    _language = null;
    _level = null;
    _exercise = null;
    _status = null;
    _appliedFrom = null;
    _appliedTo = null;
    _from.clear();
    _to.clear();
  });
  @override
  Widget build(BuildContext context) => ref
      .watch(historyProvider)
      .when(
        loading: () => const Text('Opening saved history…'),
        error: (_, _) => historyCard([
          const Text(
            'History could not be loaded. Your data has not been reset.',
          ),
          TextButton(
            onPressed: () => ref.invalidate(historyProvider),
            child: const Text('Retry history'),
          ),
        ]),
        data: (all) {
          final filter = HistoryFilter(
            module: _module,
            language: _language,
            level: _level,
            exercise: _exercise,
            status: _status,
            from: _appliedFrom,
            to: _appliedTo,
          );
          final visible = all.where(filter.matches).toList();
          final languages = all.map((e) => e.exercise.language).toSet().toList()
            ..sort();
          final exercises = {
            for (final e in all)
              e.session.exerciseId:
                  '${e.exercise.title} · ${e.session.exerciseId}',
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              historyCard([
                Text(
                  'Find your work',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Form(
                  key: _form,
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final width =
                          box.maxWidth >= 700 &&
                              MediaQuery.textScalerOf(context).scale(16) <= 24
                          ? (box.maxWidth - 16) / 2
                          : box.maxWidth;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final field in [
                            _select('Module', _module, {
                              for (final m in modules) m.id: m.name,
                            }, (v) => _module = v),
                            _select('Language', _language, {
                              for (final l in languages) l: l,
                            }, (v) => _language = v),
                            _select('Level', _level, const {
                              'beginner': 'Beginner',
                              'intermediate': 'Intermediate',
                              'advanced': 'Advanced',
                            }, (v) => _level = v),
                            _select(
                              'Exercise',
                              _exercise,
                              exercises,
                              (v) => _exercise = v,
                            ),
                            _select('Status', _status, const {
                              'completed': 'Completed',
                              'draft': 'Draft',
                              'interrupted': 'Interrupted',
                              'paused': 'Paused',
                              'running': 'In progress',
                              'abandoned': 'Abandoned',
                            }, (v) => _status = v),
                            TextFormField(
                              key: const ValueKey('history-from'),
                              controller: _from,
                              decoration: const InputDecoration(
                                labelText: 'From local practice date',
                                hintText: 'YYYY-MM-DD',
                                border: OutlineInputBorder(),
                              ),
                              validator: _dateError,
                            ),
                            TextFormField(
                              key: const ValueKey('history-to'),
                              controller: _to,
                              decoration: const InputDecoration(
                                labelText: 'Through local practice date',
                                hintText: 'YYYY-MM-DD',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  _dateError(v) ??
                                  (v != null &&
                                          v.isNotEmpty &&
                                          _from.text.isNotEmpty &&
                                          _from.text.compareTo(v) > 0
                                      ? 'End date must be on or after start.'
                                      : null),
                            ),
                          ])
                            SizedBox(width: width, child: field),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      key: const ValueKey('history-apply-dates'),
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          setState(() {
                            _appliedFrom = _from.text.isEmpty
                                ? null
                                : _from.text;
                            _appliedTo = _to.text.isEmpty ? null : _to.text;
                          });
                        }
                      },
                      child: const Text('Apply dates'),
                    ),
                    TextButton(
                      key: const ValueKey('history-clear'),
                      onPressed: _clear,
                      child: const Text('Clear filters'),
                    ),
                  ],
                ),
                const Text(
                  'Dates include both endpoints and use each attempt’s original local date. Other filters update immediately.',
                ),
              ]),
              const SizedBox(height: 16),
              HistoryMetrics(summary: HistorySummary(visible)),
              const SizedBox(height: 20),
              Text(
                '${visible.length} saved attempts',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (visible.isEmpty)
                historyCard([
                  Text(
                    all.isEmpty
                        ? 'No practice sessions yet. Start a practice to keep your work here.'
                        : 'No saved work matches these filters.',
                  ),
                  TextButton(
                    onPressed: all.isEmpty ? widget.onExplore : _clear,
                    child: Text(
                      all.isEmpty ? 'Choose a practice' : 'Clear filters',
                    ),
                  ),
                ]),
              for (final e in visible)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: historyCard([
                    Text(
                      '${moduleName(e.session.moduleId)} · ${e.statusLabel}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(e.exercise.title),
                    Text(
                      '${e.session.localPracticeDate} · ${e.exercise.language} · ${e.exercise.level} · ${e.relation}',
                    ),
                    Text(
                      'Exercise v${e.session.exerciseVersion} · rubric ${e.rubric['id']} v${e.rubric['version']}',
                    ),
                    Text(
                      'Review: ${e.detail.reviewStatus.name} · finalized timer ${e.durations.isEmpty ? 'Not measured' : historyTime(e.timerMs)}',
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          key: ValueKey('inspect-${e.id}'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  HistoryAttemptPage(sessionId: e.id),
                            ),
                          ),
                          child: const Text('Inspect evidence & compare'),
                        ),
                        TextButton(
                          key: ValueKey('resume-${e.id}'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  savedPracticePage(e.id, e.session.moduleId),
                            ),
                          ),
                          child: Text(
                            e.session.status == 'completed' ||
                                    e.session.status == 'abandoned'
                                ? 'Open saved attempt'
                                : 'Resume',
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
            ],
          );
        },
      );
}

class HistoryAttemptPage extends ConsumerStatefulWidget {
  const HistoryAttemptPage({
    super.key,
    required this.sessionId,
    this.compareId,
    this.evidenceOnly = false,
  });
  final String sessionId;
  final String? compareId;
  final bool evidenceOnly;
  @override
  ConsumerState<HistoryAttemptPage> createState() => _HistoryAttemptPageState();
}

class _HistoryAttemptPageState extends ConsumerState<HistoryAttemptPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _audio?.lifecycle(state).catchError((Object _) {});
  }

  final _observation = TextEditingController();
  LocalAudio? _audio;
  String? _context;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _observation.dispose();
    super.dispose();
  }

  Future<void> _pause() async {
    await _audio?.backend.pausePlayback();
  }

  Widget _ratings(HistoryEntry e) => historyCard([
    Text(
      'Assessment provenance',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const Text(
      'Only the assessor recorded with this result is represented. No external assessor record is present in these modules.',
    ),
    for (final a in e.assessments) ...[
      const Divider(height: 28),
      Text(
        '${assessorLabel(a.source)} · ${a.label}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(a.display),
      Text(a.note),
      if (a.evidence.isNotEmpty) SelectableText('Evidence: ${a.evidence}'),
      if (a.evidence.isEmpty && a.source == 'self')
        const Text(
          'No criterion-specific evidence note supplied; inspect the saved output alongside.',
        ),
    ],
    if (e.impromptu != null) ...[
      const Divider(height: 28),
      Text(
        'Confidence self-report: ${e.impromptu!.confidence?.toString() ?? 'Not recorded'} / 5 (separate from performance)',
      ),
    ],
    if (e.reviewNote.isNotEmpty) ...[
      const Divider(height: 28),
      const Text('Saved reflection / next action'),
      SelectableText(e.reviewNote),
    ],
  ]);
  Widget _output(HistoryEntry e, {bool audio = true}) => historyCard([
    Text(
      'Saved output evidence',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    SelectableText(e.taskPrompt),
    for (final block in e.evidence) ...[
      const Divider(height: 28),
      Text(block.label, style: Theme.of(context).textTheme.titleMedium),
      SelectableText(block.text),
    ],
    for (final r in e.recordings) ...[
      const Divider(height: 24),
      Text(
        '${r.microphoneCheck ? 'Microphone check' : 'Response recording'} · ${r.contextKey} · ${r.state}',
      ),
      Text(
        'Take ${r.id} · retained file ${historyTime(r.durationMs)} · ${r.sampleRate} Hz / ${r.channels} channels',
      ),
      const Text(
        'File duration is media evidence; it is not added to active timer time.',
      ),
      for (final o in e.observations.where((o) => o.recordingId == r.id))
        SelectableText('Observation at ${o.positionMs} ms: ${o.note}'),
    ],
    if (audio && e.recordings.isNotEmpty) ...[
      const Divider(height: 28),
      if (e.recordings.map((r) => r.contextKey).toSet().length > 1)
        DropdownButtonFormField<String>(
          key: ValueKey('history-audio-${e.id}-$_context'),
          initialValue: _context ?? e.recordings.first.contextKey,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Recording stage',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final c in e.recordings.map((r) => r.contextKey).toSet())
              DropdownMenuItem(
                value: c,
                child: Text(c.isEmpty ? 'Response' : c),
              ),
          ],
          onChanged: (v) async {
            await _pause();
            if (mounted) {
              setState(() => _context = v);
            }
          },
        ),
      ref
          .watch(localAudioProvider)
          .when(
            data: (a) {
              _audio = a;
              return LocalAudioPanel(
                sessionId: e.id,
                contextKey: _context ?? e.recordings.first.contextKey,
                audio: a,
                readOnly: true,
                observationController: _observation,
                takeLabel: 'Saved evidence',
              );
            },
            error: (_, _) => const Text(
              'Playback unavailable. Saved text and recording metadata remain available.',
            ),
            loading: () => const Text('Opening local playback…'),
          ),
    ],
  ]);
  Widget _scroll(Widget child) =>
      SingleChildScrollView(padding: const EdgeInsets.all(20), child: child);
  Widget _pane(HistoryEntry e) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        '${e.session.localPracticeDate} · ${e.relation}',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (widget.evidenceOnly)
        const Text(
          'Evidence only: task versions, conditions or assistance may differ. No like-for-like improvement claim.',
        ),
      Text(
        'Content v${e.exercise.version} · ${e.exercise.language} · rubric ${e.rubric['id']} v${e.rubric['version']}',
      ),
      _output(e, audio: false),
      _ratings(e),
    ],
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) async {
      if (!didPop) {
        await _pause();
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.compareId == null
              ? 'Saved evidence'
              : widget.evidenceOnly
              ? 'Related evidence · different conditions'
              : 'Compatible attempts',
        ),
        leading: IconButton(
          tooltip: 'Back to history',
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _pause();
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: ref
            .watch(historyProvider)
            .when(
              loading: () =>
                  const Center(child: Text('Opening saved evidence…')),
              error: (_, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(historyProvider),
                  child: const Text('Could not load saved evidence. Retry'),
                ),
              ),
              data: (all) {
                final entry = all
                    .where((e) => e.id == widget.sessionId)
                    .firstOrNull;
                final other = all
                    .where((e) => e.id == widget.compareId)
                    .firstOrNull;
                if (entry == null) {
                  return const Center(
                    child: Text('This saved attempt is unavailable.'),
                  );
                }
                if (widget.compareId != null) {
                  if (other == null ||
                      (widget.evidenceOnly
                          ? !entry.relatedEvidence(other)
                          : entry.incompatibility(other) != null)) {
                    return Center(
                      child: Text(
                        other == null
                            ? 'Comparison attempt unavailable.'
                            : entry.incompatibility(other)!,
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, box) =>
                        box.maxWidth >= 1100 &&
                            MediaQuery.textScalerOf(context).scale(16) <= 20
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _scroll(_pane(entry))),
                              const VerticalDivider(width: 1),
                              Expanded(child: _scroll(_pane(other))),
                            ],
                          )
                        : _scroll(
                            Column(
                              children: [
                                Text(
                                  widget.evidenceOnly
                                      ? 'Different conditions: ${entry.incompatibility(other) ?? 'Related saved evidence'}. Inspect artifacts; no improvement score is inferred.'
                                      : 'Compatible task and rubric; ratings keep their original assessor. Compare evidence, not a combined score.',
                                ),
                                _pane(entry),
                                const Divider(height: 40),
                                _pane(other),
                              ],
                            ),
                          ),
                  );
                }
                final candidates = all
                    .where((e) => entry.incompatibility(e) == null)
                    .toList();
                final header = historyCard([
                  Text(
                    entry.exercise.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '${entry.statusLabel} · ${entry.session.localPracticeDate} · ${entry.exercise.language} · ${entry.exercise.level}',
                  ),
                  Text(
                    '${entry.relation} · exercise v${entry.session.exerciseVersion} · rubric ${entry.rubric['id']} v${entry.rubric['version']}',
                  ),
                  Text(
                    'Original UTC offset: ${entry.session.originalOffsetMinutes} minutes · created UTC ${DateTime.fromMillisecondsSinceEpoch(entry.session.createdUtcMs, isUtc: true).toIso8601String()}',
                  ),
                  if (entry.parentId != null)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              HistoryAttemptPage(sessionId: entry.parentId!),
                        ),
                      ),
                      child: const Text('Inspect parent attempt'),
                    ),
                  if (entry.memory != null &&
                      entry.session.status == 'completed')
                    RecallScheduleCard(sessionId: entry.id),
                  const AdvancedPracticeLink(),
                  if (entry.session.status == 'completed')
                    OutlinedButton(
                      onPressed: () async {
                        await _pause();
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => PracticeConditionsPage(
                                exercise: entry.exercise,
                                parent: entry.id,
                                target: retryBasis(entry).isEmpty
                                    ? 'Repeat under declared conditions.'
                                    : retryBasis(entry),
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Retry with declared conditions'),
                    ),
                  if (all.any(
                    (e) =>
                        entry.relatedEvidence(e) &&
                        entry.incompatibility(e) != null,
                  ))
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText:
                            'Compare related evidence (different conditions)',
                      ),
                      items: [
                        for (final e in all.where(
                          (e) =>
                              entry.relatedEvidence(e) &&
                              entry.incompatibility(e) != null,
                        ))
                          DropdownMenuItem(
                            value: e.id,
                            child: Text(
                              '${e.session.localPracticeDate} · v${e.exercise.version} · ${e.context?.label ?? 'unlabelled'}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (id) async {
                        if (id != null) {
                          await _pause();
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => HistoryAttemptPage(
                                  sessionId: entry.id,
                                  compareId: id,
                                  evidenceOnly: true,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  TextButton(
                    onPressed: () async {
                      await _pause();
                      if (context.mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => savedPracticePage(
                              entry.id,
                              entry.session.moduleId,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Open original module workspace'),
                  ),
                  Text(
                    'Preparation ${historyTime(entry.durations['prepare'])} · response ${historyTime(entry.durations['respond'])} · review stage ${historyTime(entry.durations['reflect'])}',
                  ),
                  const Text(
                    'Playback and later review may be unmeasured. Retained media length is separate.',
                  ),
                  TextButton(
                    onPressed: () => showMetricDefinitions(context),
                    child: const Text('What these numbers measure'),
                  ),
                  if (candidates.isEmpty)
                    const Text(
                      'No compatible completed attempt. Comparison requires the same task/version, language, level, rubric and practice settings.',
                    ),
                  if (candidates.isNotEmpty)
                    DropdownButtonFormField<String>(
                      key: ValueKey('history-compare-${entry.id}'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Compare with compatible attempt',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final c in candidates)
                          DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '${c.session.localPracticeDate} · ${c.relation} · ${c.id.substring(0, 6)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (id) async {
                        await _pause();
                        if (context.mounted) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => HistoryAttemptPage(
                                sessionId: entry.id,
                                compareId: id,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                ]);
                return LayoutBuilder(
                  builder: (context, box) {
                    if (box.maxWidth >= 1180 &&
                        box.maxHeight >= 650 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 20) {
                      return Column(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: _scroll(header),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _scroll(_output(entry))),
                                const VerticalDivider(width: 1),
                                Expanded(child: _scroll(_ratings(entry))),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return _scroll(
                      Column(
                        children: [header, _output(entry), _ratings(entry)],
                      ),
                    );
                  },
                );
              },
            ),
      ),
    ),
  );
}
