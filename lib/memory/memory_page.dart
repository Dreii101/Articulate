import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_panel.dart';
import '../audio/audio_provider.dart';
import '../audio/local_audio.dart';
import '../providers.dart';
import '../advanced/advanced_page.dart';
import '../session_controller.dart';
import '../storage/database.dart';
import '../storage/practice_repository.dart';
import 'memory_document.dart';
import 'memory_repository.dart';

Widget memoryCard(List<Widget> children) => Card.outlined(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  ),
);
Widget memoryScroll(Widget child) => SingleChildScrollView(
  padding: const EdgeInsets.all(24),
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: child,
    ),
  ),
);

class MemoryLibraryPage extends ConsumerStatefulWidget {
  const MemoryLibraryPage({super.key});
  @override
  ConsumerState<MemoryLibraryPage> createState() => _MemoryLibraryPageState();
}

class _MemoryLibraryPageState extends ConsumerState<MemoryLibraryPage> {
  late final _starters = rootBundle
      .loadString('assets/exercises/memory-v1.json')
      .then(validateMemoryPack);
  bool _busy = false;
  String? _error;
  Future<void> _edit([MemoryDocument? starter, MemorySpeech? speech]) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(memoryRepositoryProvider);
      final id =
          speech?.id ??
          await repo.saveDraft(
            null,
            starter?.data ??
                {
                  'title': '',
                  'language': 'en',
                  'level': 'beginner',
                  'author': 'User supplied',
                  'license':
                      'Personal local text; rights have not been assessed.',
                  'sections': [
                    {
                      'id': 's-${stableId()}',
                      'title': '',
                      'text': '',
                      'phrase': '',
                      'keywords': '',
                      'ideas': '',
                      'transition': '',
                    },
                  ],
                },
          );
      final row = await repo.speech(id);
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => MemoryEditorPage(speech: row),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not open this speech. Your saved work has not been reset.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Memory Trainer')),
    body: SafeArea(
      child: memoryScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Keep the message. Find your words.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Build a speech from meaningful sections, then recall one section with as much or as little help as you choose. Review the evidence yourself; there are no automatic accuracy or mastery scores.',
            ),
            const SizedBox(height: 20),
            const AdvancedPracticeLink(),
            FilledButton.icon(
              key: const ValueKey('memory-create'),
              onPressed: _busy ? null : () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Create a speech'),
            ),
            if (_error != null) Text(_error!),
            const SizedBox(height: 24),
            Text(
              'Your speeches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ref
                .watch(memorySpeechesProvider)
                .when(
                  loading: () => const Text('Opening speeches…'),
                  error: (e, s) => const Text(
                    'Speeches could not be loaded. Reopen Memory Trainer to retry.',
                  ),
                  data: (rows) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Start with your own text or make an editable copy of an exercise below.',
                          ),
                        ),
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: memoryCard([
                            Text(
                              MemoryDocument.parse(
                                    jsonDecode(row.draft),
                                    draft: true,
                                  ).title.isEmpty
                                  ? 'Untitled speech'
                                  : MemoryDocument.parse(
                                      jsonDecode(row.draft),
                                      draft: true,
                                    ).title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _edit(null, row),
                                  child: const Text('Edit speech'),
                                ),
                                FilledButton.tonal(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          MemorySetupPage(speechId: row.id),
                                    ),
                                  ),
                                  child: const Text('Choose a section'),
                                ),
                              ],
                            ),
                          ]),
                        ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            Text(
              'Marked for later review',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ref
                .watch(memoryFlagsProvider)
                .when(
                  loading: () => const Text('Opening review flags…'),
                  error: (e, s) =>
                      const Text('Review flags could not be loaded.'),
                  data: (rows) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (rows.isEmpty)
                        const Text(
                          'No attempts flagged. This is a manual reminder list, without a schedule.',
                        ),
                      for (final row in rows)
                        FutureBuilder(
                          future: ref
                              .read(repositoryProvider)
                              .load(row.sessionId),
                          builder: (context, s) => s.hasData
                              ? ListTile(
                                  title: Text(s.data!.exercise.title),
                                  subtitle: const Text(
                                    'You marked this attempt for later review.',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => MemoryAttemptPage(
                                        sessionId: row.sessionId,
                                      ),
                                    ),
                                  ),
                                )
                              : const Text('Opening flagged attempt…'),
                        ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),
            Text(
              'Original practice speeches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            FutureBuilder(
              future: _starters,
              builder: (context, s) => s.hasData
                  ? Column(
                      children: [
                        for (final d in s.data!)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: memoryCard([
                              Text(
                                '${d.data['level']} · ${d.sections.length} sections',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                d.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(d.sections.first['text'] as String),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                key: ValueKey(
                                  'memory-starter-${d.data['level']}',
                                ),
                                onPressed: _busy ? null : () => _edit(d),
                                child: const Text('Use editable copy'),
                              ),
                            ]),
                          ),
                      ],
                    )
                  : Text(
                      s.hasError
                          ? 'Practice speeches could not be loaded.'
                          : 'Opening practice speeches…',
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

class MemoryEditorPage extends ConsumerStatefulWidget {
  const MemoryEditorPage({super.key, required this.speech});
  final MemorySpeech speech;
  @override
  ConsumerState<MemoryEditorPage> createState() => _MemoryEditorPageState();
}

class _MemoryEditorPageState extends ConsumerState<MemoryEditorPage>
    with WidgetsBindingObserver {
  late final Map<String, dynamic> _data =
      jsonDecode(widget.speech.draft) as Map<String, dynamic>;
  List<dynamic> get _sections => _data['sections'] as List;
  Timer? _autosave;
  Future<void> _tail = Future.value();
  bool _dirty = false, _busy = false, _canPop = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _change() {
    setState(() => _dirty = true);
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 400), _save);
  }

  Future<bool> _save() async {
    _autosave?.cancel();
    final result = _tail.then((_) async {
      if (!_dirty) return true;
      final text = jsonEncode(_data);
      try {
        await ref
            .read(memoryRepositoryProvider)
            .saveDraft(
              widget.speech.id,
              jsonDecode(text) as Map<String, dynamic>,
            );
        if (mounted) {
          setState(() {
            _dirty = text != jsonEncode(_data);
            _error = null;
          });
        }
        return true;
      } catch (_) {
        if (mounted) {
          setState(
            () => _error =
                'Draft could not be saved. Keep this page open and retry.',
          );
        }
        return false;
      }
    });
    _tail = result.then<void>((_) {});
    return result;
  }

  Future<void> _back() async {
    if (await _save() && mounted) {
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _publish() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      if (!await _save()) return;
      await ref.read(memoryRepositoryProvider).publish(widget.speech.id);
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => MemorySetupPage(speechId: widget.speech.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is FormatException
              ? e.message
              : 'Version could not be saved. Your draft remains available.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _save();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _save() ? AppExitResponse.exit : AppExitResponse.cancel;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    super.dispose();
  }

  Widget _field(
    Map<String, dynamic> map,
    String field,
    String label, {
    int lines = 1,
    int max = 2000,
  }) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextFormField(
      key: ValueKey('memory-edit-${map['id'] ?? 'speech'}-$field'),
      initialValue: map[field] as String,
      minLines: lines,
      maxLines: lines == 1 ? 1 : lines + 5,
      maxLength: max,
      enabled: !_busy,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (v) {
        map[field] = v;
        _change();
      },
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canPop,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _busy ? null : _back),
        title: const Text('Edit speech'),
      ),
      body: SafeArea(
        child: memoryScroll(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Make each section a meaningful unit. Move sections with the arrow buttons. Phrase and keyword cues are yours to write; no text is generated.',
              ),
              const SizedBox(height: 8),
              Text(
                _dirty ? 'Saving draft…' : 'Draft saved on this device',
                key: const ValueKey('memory-editor-save-status'),
              ),
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
              _field(_data, 'title', 'Speech title', max: 500),
              DropdownButtonFormField<String>(
                initialValue: _data['level'] as String,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Level'),
                items: [
                  for (final l in ['beginner', 'intermediate', 'advanced'])
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: _busy
                    ? null
                    : (v) {
                        _data['level'] = v!;
                        _change();
                      },
              ),
              _field(_data, 'language', 'Language code', max: 35),
              for (var i = 0; i < _sections.length; i++)
                Padding(
                  key: ValueKey(_sections[i]['id']),
                  padding: const EdgeInsets.only(top: 16),
                  child: memoryCard([
                    Text(
                      'Section ${i + 1}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          tooltip: 'Move section ${i + 1} up',
                          onPressed: _busy || i == 0
                              ? null
                              : () {
                                  final item = _sections.removeAt(i);
                                  _sections.insert(i - 1, item);
                                  _change();
                                },
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          tooltip: 'Move section ${i + 1} down',
                          onPressed: _busy || i == _sections.length - 1
                              ? null
                              : () {
                                  final item = _sections.removeAt(i);
                                  _sections.insert(i + 1, item);
                                  _change();
                                },
                          icon: const Icon(Icons.arrow_downward),
                        ),
                        TextButton(
                          onPressed: _busy || _sections.length == 1
                              ? null
                              : () async {
                                  final yes = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text(
                                        'Remove this draft section?',
                                      ),
                                      content: const Text(
                                        'Published versions and past attempts will stay unchanged.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text('Keep section'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text('Remove section'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (yes == true && mounted) {
                                    _sections.removeAt(i);
                                    _change();
                                  }
                                },
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                    _field(
                      _sections[i] as Map<String, dynamic>,
                      'title',
                      'Section title',
                    ),
                    _field(
                      _sections[i] as Map<String, dynamic>,
                      'text',
                      'Section text',
                      lines: 4,
                      max: 10000,
                    ),
                    _field(
                      _sections[i] as Map<String, dynamic>,
                      'phrase',
                      'Phrase cue (optional)',
                      lines: 2,
                    ),
                    _field(
                      _sections[i] as Map<String, dynamic>,
                      'keywords',
                      'Keyword cues (optional)',
                    ),
                    _field(
                      _sections[i] as Map<String, dynamic>,
                      'ideas',
                      'Important ideas for review (optional)',
                      lines: 2,
                    ),
                    _field(
                      _sections[i] as Map<String, dynamic>,
                      'transition',
                      'Transition to the next section (optional)',
                      lines: 2,
                    ),
                  ]),
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                key: const ValueKey('memory-add-section'),
                onPressed: _busy || _sections.length >= 30
                    ? null
                    : () {
                        _sections.add({
                          'id': 's-${stableId()}',
                          'title': '',
                          'text': '',
                          'phrase': '',
                          'keywords': '',
                          'ideas': '',
                          'transition': '',
                        });
                        _change();
                      },
                child: const Text('Add section'),
              ),
              _field(_data, 'author', 'Author / source', max: 500),
              _field(
                _data,
                'license',
                'License / rights note',
                lines: 2,
                max: 500,
              ),
              const SizedBox(height: 12),
              const Text(
                'Saving a practice version freezes its text, section order and cues. Future edits create a new version; historical attempts keep the version they practiced.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: _busy ? null : _save,
                    child: const Text('Save draft'),
                  ),
                  FilledButton(
                    key: const ValueKey('memory-publish'),
                    onPressed: _busy ? null : _publish,
                    child: const Text('Save version & practice'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MemorySetupPage extends ConsumerStatefulWidget {
  const MemorySetupPage({super.key, required this.speechId});
  final String speechId;
  @override
  ConsumerState<MemorySetupPage> createState() => _MemorySetupPageState();
}

class _MemorySetupPageState extends ConsumerState<MemorySetupPage> {
  late final _versions = ref
      .read(memoryRepositoryProvider)
      .versions(widget.speechId);
  MemoryVersion? _version;
  String? _section;
  String _mode = 'meaning', _kind = 'typed', _cue = 'full';
  bool _busy = false;
  String? _error;
  Widget _choice(
    String label,
    String value,
    List<String> values,
    List<String> labels,
    void Function(String) change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      key: ValueKey('memory-setup-$label-$value'),
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
            child: Text(labels[i], overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: _busy ? null : (v) => setState(() => change(v!)),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose your recall practice')),
    body: SafeArea(
      child: FutureBuilder(
        future: _versions,
        builder: (context, s) {
          if (!s.hasData) {
            return Center(
              child: Text(
                s.hasError
                    ? 'Speech versions could not be opened.'
                    : 'Opening versions…',
              ),
            );
          }
          final versions = s.data!;
          if (versions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'This speech is still a draft. Go back, edit it, and choose Save version & practice.',
              ),
            );
          }
          final v = _version ?? versions.first;
          final doc = MemoryDocument.parse(jsonDecode(v.content));
          final section = _section ?? doc.sections.first['id'] as String;
          return memoryScroll(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  doc.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                _choice(
                  'Speech version',
                  v.id,
                  versions.map((v) => v.id).toList(),
                  versions.map((v) => 'Version ${v.versionNumber}').toList(),
                  (id) {
                    _version = versions.singleWhere((v) => v.id == id);
                    _section = null;
                  },
                ),
                _choice(
                  'Section',
                  section,
                  doc.sections.map((s) => s['id'] as String).toList(),
                  [
                    for (var i = 0; i < doc.sections.length; i++)
                      '${i + 1}. ${doc.sections[i]['title']}',
                  ],
                  (v) => _section = v,
                ),
                _choice('Practice mode', _mode, memoryModes, [
                  'Verbatim — keep the wording',
                  'Meaning-based — keep the ideas',
                ], (v) => _mode = v),
                _choice('Recall evidence', _kind, recallKinds, [
                  'Typed recall',
                  'Recorded spoken recall (optional)',
                ], (v) => _kind = v),
                _choice(
                  'Starting cues',
                  _cue,
                  cueStages,
                  cueLabels,
                  (v) => _cue = v,
                ),
                const Text(
                  'One section per attempt. You can reduce or restore cues during recall; every change and full-text reveal is recorded. Spoken recall stays audio, without a transcript or an accuracy score.',
                ),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!),
                FilledButton(
                  key: const ValueKey('memory-start'),
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          try {
                            final id = await ref
                                .read(memoryRepositoryProvider)
                                .createAttempt(
                                  v.id,
                                  section,
                                  _mode,
                                  _kind,
                                  _cue,
                                );
                            if (context.mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      MemoryAttemptPage(sessionId: id),
                                ),
                              );
                            }
                          } catch (_) {
                            if (mounted) {
                              setState(
                                () => _error =
                                    'Could not start recall. Please retry.',
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        },
                  child: const Text('Start recall'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class MemoryAttemptPage extends ConsumerStatefulWidget {
  const MemoryAttemptPage({super.key, required this.sessionId});
  final String sessionId;
  @override
  ConsumerState<MemoryAttemptPage> createState() => _MemoryAttemptPageState();
}

class _MemoryAttemptPageState extends ConsumerState<MemoryAttemptPage>
    with WidgetsBindingObserver {
  late final _session = SessionController(
    ref.read(repositoryProvider),
    widget.sessionId,
  );
  MemoryWorkspace? _work;
  LocalAudio? _audio;
  final _response = TextEditingController(), _note = TextEditingController();
  final _observation = TextEditingController();
  Map<String, String> _ratings = {};
  bool _dirty = false,
      _busy = false,
      _canPop = false,
      _revealed = false,
      _later = false;
  String? _error;
  Timer? _autosave;
  Future<void> _tail = Future.value();
  bool get _closed => isTerminal(_session.detail!.session.status);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _load() async {
    try {
      await _session.open();
      final w = await ref
          .read(memoryRepositoryProvider)
          .workspace(widget.sessionId);
      if (mounted) {
        setState(() {
          _work = w;
          _response.text = _session.detail!.response.body;
          _note.text = w.reviewNote;
          _ratings = Map<String, String>.from(jsonDecode(w.assessments) as Map);
          _later = w.laterReview;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Saved recall could not be opened. Your data has not been reset.',
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
    if (!_dirty || _work == null) return;
    final response = _response.text,
        note = _note.text,
        ratings = Map<String, String>.from(_ratings),
        later = _later;
    if (_closed) {
      await ref
          .read(memoryRepositoryProvider)
          .saveReview(widget.sessionId, ratings, note, later);
    } else if (_work!.recallKind == 'typed') {
      await _session.saveResponse(response);
    }
    if (mounted) {
      setState(
        () => _dirty =
            response != _response.text ||
            note != _note.text ||
            jsonEncode(ratings) != jsonEncode(_ratings) ||
            later != _later,
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
                'Could not save this change. Keep this page open and retry.',
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

  Future<void> _stopAudio() async {
    final a = _audio;
    if (a == null) return;
    if (a.active?.sessionId == widget.sessionId) await a.stop();
    await a.backend.pausePlayback();
  }

  Future<void> _back() async {
    if (await _run(() async {
          await _stopAudio();
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
      _audio?.lifecycle(state).catchError((Object _) {});
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async =>
      await _run(_stopAudio, autosave: true)
      ? AppExitResponse.exit
      : AppExitResponse.cancel;
  @override
  void dispose() {
    _observation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _autosave?.cancel();
    _response.dispose();
    _note.dispose();
    super.dispose();
  }

  Widget _source() {
    final w = _work!,
        memory =
            _session.detail!.exercise.content['memory'] as Map<String, dynamic>;
    final doc = MemoryDocument.parse(memory['speech']);
    final index = doc.sections.indexWhere((s) => s['id'] == w.sectionId),
        section = doc.sections.singleWhere((s) => s['id'] == w.sectionId);
    final events = (jsonDecode(w.assistance) as List)
        .cast<Map<String, dynamic>>();
    final reveals = events.where((e) => e['kind'] == 'reveal').length;
    return memoryCard([
      Text(doc.title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(
        'Speech v${memory['versionNumber']} · section ${index + 1} of ${doc.sections.length} · ${w.mode == 'meaning' ? 'Meaning-based' : 'Verbatim'}',
      ),
      const SizedBox(height: 12),
      if (!_closed)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < cueStages.length; i++)
              ChoiceChip(
                key: ValueKey('memory-cue-${cueStages[i]}'),
                label: Text(cueLabels[i]),
                selected: w.cueStage == cueStages[i],
                onSelected: _busy
                    ? null
                    : (_) => _run(() async {
                        _work = await ref
                            .read(memoryRepositoryProvider)
                            .assistance(widget.sessionId, cue: cueStages[i]);
                        _revealed = false;
                      }),
              ),
          ],
        ),
      const SizedBox(height: 16),
      if (_closed)
        Text(
          'Source · ${section['title']}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      SelectableText(
        _closed || _revealed
            ? section['text'] as String
            : cueText(section, w.cueStage),
        key: const ValueKey('memory-source'),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      if (!_closed && w.cueStage != 'full')
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: OutlinedButton(
            key: const ValueKey('memory-reveal'),
            onPressed: _busy
                ? null
                : () => _run(() async {
                    if (!_revealed) {
                      _work = await ref
                          .read(memoryRepositoryProvider)
                          .assistance(widget.sessionId, reveal: true);
                    }
                    _revealed = !_revealed;
                  }),
            child: Text(_revealed ? 'Hide revealed text' : 'Reveal full text'),
          ),
        ),
      const SizedBox(height: 16),
      Text(
        'Assistance: $reveals full-text reveal${reveals == 1 ? '' : 's'}',
        key: const ValueKey('memory-reveals'),
      ),
      Text(
        'Cue path: ${events.where((e) => e['kind'] == 'cue').map((e) => cueLabels[cueStages.indexOf(e['cue'] as String)]).join(' → ')}',
      ),
      if (_closed) ...[
        const SizedBox(height: 16),
        Text(
          'Ideas to compare: ${section['ideas'].toString().isEmpty ? 'Use the source text above.' : section['ideas']}',
        ),
        Text(
          'Transition: ${section['transition'].toString().isEmpty ? 'No transition note supplied.' : section['transition']}',
        ),
        const SizedBox(height: 12),
        Text('Source: ${doc.data['author']}\n${doc.data['license']}'),
      ],
    ]);
  }

  Widget _evidence() {
    final w = _work!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        memoryCard([
          Text(
            _closed ? 'Your recall evidence' : 'Recall in your own time',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            w.mode == 'verbatim'
                ? 'Aim to retain the original wording. You will compare it yourself.'
                : 'Retain the ideas and their relationships. Different wording is welcome.',
          ),
          const SizedBox(height: 12),
          if (w.recallKind == 'typed')
            TextField(
              key: const ValueKey('memory-response'),
              controller: _response,
              readOnly: _closed || _busy,
              minLines: 7,
              maxLines: 18,
              maxLength: PracticeRepository.maxResponseLength,
              decoration: const InputDecoration(
                labelText: 'Typed recall',
                border: OutlineInputBorder(),
              ),
              onChanged: _changed,
            )
          else
            const Text(
              'Spoken evidence is stored as local audio. Listen and judge it yourself. No spoken accuracy has been assessed.',
            ),
          if (_closed && w.recallKind == 'typed' && _response.text.isEmpty)
            const Text('No typed response was supplied.'),
          if (!_closed) ...[
            const SizedBox(height: 16),
            const Text(
              'Complete recall to freeze your evidence and compare with the source. You can return to a saved draft before completing.',
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('memory-complete'),
              onPressed: _busy
                  ? null
                  : () => _run(() async {
                      await _stopAudio();
                      await _session.changeStage(PracticeStage.reflect);
                      await _session.transition(PracticeStatus.completed);
                      _revealed = false;
                    }),
              child: const Text('Complete recall & review'),
            ),
          ],
        ]),
        if (w.recallKind == 'spoken')
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ref
                .watch(localAudioProvider)
                .when(
                  data: (a) {
                    _audio = a;
                    return LocalAudioPanel(
                      observationController: _observation,
                      sessionId: widget.sessionId,
                      audio: a,
                      readOnly: _closed || _busy,
                      takeLabel: 'Spoken recall',
                      emptyMessage: 'No spoken recording was supplied. This attempt has no recorded recall evidence yet.',
                    );
                  },
                  loading: () => const Text('Opening local audio…'),
                  error: (e, s) => Column(
                    children: [
                      const Text(
                        'Audio unavailable. Your attempt remains saved.',
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(localAudioProvider),
                        child: const Text('Retry audio'),
                      ),
                    ],
                  ),
                ),
          ),
        if (_session.detail!.session.status == 'completed')
          RecallScheduleCard(sessionId: widget.sessionId),
        if (_closed)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: memoryCard([
              Text(
                'Your self-review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Not assessed is a valid choice. Mark what you missed, then describe the idea, wording, or transition in the note. These are your judgments, not an automatic grade.',
              ),
              for (final key in ['ideas', 'wording', 'transitions'])
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('memory-rating-$key-${_ratings[key]}'),
                    initialValue: _ratings[key] ?? 'notAssessed',
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '${key[0].toUpperCase()}${key.substring(1)}',
                      border: const OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'notAssessed',
                        child: Text('Not assessed'),
                      ),
                      DropdownMenuItem(
                        value: 'missed',
                        child: Text('Missed / needs attention'),
                      ),
                      DropdownMenuItem(
                        value: 'recalled',
                        child: Text('Recalled — my assessment'),
                      ),
                    ],
                    onChanged: (v) {
                      _ratings[key] = v!;
                      _changed();
                    },
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('memory-review-note'),
                controller: _note,
                enabled: !_busy,
                minLines: 3,
                maxLines: 7,
                maxLength: 10000,
                decoration: const InputDecoration(
                  labelText:
                      'What did you miss or want to try next? (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: _changed,
              ),
              CheckboxListTile(
                key: const ValueKey('memory-later'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark for later review'),
                subtitle: const Text(
                  'A manual flag, without an automatic schedule.',
                ),
                value: _later,
                onChanged: (v) {
                  _later = v!;
                  _changed();
                },
              ),
            ]),
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
        title: const Text('Memory Trainer'),
      ),
      body: SafeArea(
        child: _work == null
            ? Center(child: Text(_error ?? 'Opening saved recall…'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _dirty ? 'Saving…' : 'Saved on this device',
                          key: const ValueKey('memory-save-status'),
                        ),
                        Text(
                          _closed
                              ? 'Completed · review is separate'
                              : 'Untimed recall · draft',
                        ),
                        TextButton(
                          onPressed: () => _run(() async {}),
                          child: const Text('Save'),
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
                      builder: (context, c) =>
                          c.maxWidth >= 1100 &&
                              MediaQuery.textScalerOf(context).scale(16) <= 21
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: memoryScroll(_source())),
                                const VerticalDivider(width: 1),
                                Expanded(child: memoryScroll(_evidence())),
                              ],
                            )
                          : memoryScroll(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _source(),
                                  const SizedBox(height: 16),
                                  _evidence(),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
