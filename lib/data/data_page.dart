import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_provider.dart';
import '../exercises.dart';
import '../storage/database.dart';
import 'archive_format.dart';
import 'data_manager.dart';
import 'platform_files.dart';

final dataFilesProvider = Provider((ref) => DataFiles());
String storageBytes(int value) {
  if (value < 1024) {
    return '$value bytes';
  }
  if (value < 1024 * 1024) {
    return '${(value / 1024).toStringAsFixed(1)} KiB';
  }
  if (value < 1024 * 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MiB';
  }
  return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(2)} GiB';
}

class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});
  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage>
    with WidgetsBindingObserver {
  DataManager? _manager;
  RestorePreview? _preview;
  Map<String, int>? _storage;
  List<PracticeSession> _sessions = [];
  List<AudioRecording> _media = [];
  List<File> _recovery = [];
  String? _session, _recording, _message;
  bool _busy = false, _cancellable = false, _canPop = false;
  OperationToken? _token;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
  }

  Future<void> _reload() async {
    try {
      final manager = await ref.read(dataManagerProvider.future),
          stats = await manager.storage(),
          sessions = await manager.db.select(manager.db.practiceSessions).get(),
          media = await manager.db.select(manager.db.audioRecordings).get(),
          recovery = await manager.recoveryArchives();
      if (mounted) {
        setState(() {
          _manager = manager;
          _storage = stats;
          _sessions = sessions;
          _media = media;
          _recovery = recovery;
          if (!sessions.any((s) => s.id == _session)) {
            _session = null;
          }
          if (!media.any((s) => s.id == _recording)) {
            _recording = null;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'Local storage could not be inspected. Your data has not been reset. Restart if a recovery operation is pending.',
        );
      }
    }
  }

  Future<void> _quiesce() async {
    final current = await ref.read(localAudioProvider.future);
    await current.close();
    ref.invalidate(localAudioProvider);
  }

  Future<void> _run(
    String message,
    Future<void> Function(OperationToken) action, {
    bool cancellable = true,
  }) async {
    if (_busy) {
      return;
    }
    final token = OperationToken();
    setState(() {
      _busy = true;
      _cancellable = cancellable;
      _token = token;
      _message = message;
    });
    try {
      await action(token);
    } on DataCancelled {
      if (mounted) {
        setState(
          () => _message = 'Cancelled. The current library was not replaced.',
        );
      }
    } on DataFailure catch (e) {
      if (mounted) {
        setState(() => _message = e.message);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(
          () => _message = e.code == 'cancelled'
              ? 'Cancelled. The current library was not replaced.'
              : 'The document transfer did not finish. Your library is retained; a partial destination may remain.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'This operation could not finish. Restart to recover any interrupted replacement. Your recovery copies have not been reset.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _token = null;
          _cancellable = false;
        });
        await _reload();
      }
    }
  }

  Future<void> _cancel() async {
    _token?.cancelled = true;
    await ref.read(dataFilesProvider).cancel();
  }

  Future<void> _export() => _run('Creating a consistent library archive…', (
    token,
  ) async {
    await _quiesce();
    final manager = _manager!, snapshot = await manager.export(token);
    try {
      final destination = await ref
          .read(dataFilesProvider)
          .choose(
            true,
            'Articulate-${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.articulate',
          );
      if (destination == null) {
        throw const DataCancelled();
      }
      token.check();
      if (mounted) {
        setState(
          () => _message = 'Streaming and verifying the chosen destination…',
        );
      }
      await ref
          .read(dataFilesProvider)
          .exportTo(
            snapshot.file,
            destination,
            token,
            protectedRoot: manager.root,
          );
      if (mounted) {
        setState(
          () => _message =
              'Export verified. ${(snapshot.manifest['missingMedia'] as List).length} media files were already missing and are listed in the manifest. Keep this plain, unencrypted archive private.',
        );
      }
    } finally {
      await manager.removeStage(snapshot.directory);
    }
  });
  Future<void> _stage([File? recovery]) => _run(
    'Selecting and validating a restore; the live library stays available…',
    (token) async {
      if (_preview != null) {
        await _manager!.removeStage(_preview!.directory);
        _preview = null;
      }
      RestorePreview preview;
      if (recovery != null) {
        preview = await _manager!.stageFile(recovery, token);
      } else {
        final source = await ref.read(dataFilesProvider).choose(false, '');
        if (source == null) {
          throw const DataCancelled();
        }
        preview = await _manager!.stageTransfer(
          (target) => ref
              .read(dataFilesProvider)
              .importTo(
                source,
                target,
                token,
                _manager!.codec.limits.total +
                    _manager!.codec.limits.manifest +
                    16,
              ),
          token,
        );
      }
      if (mounted) {
        setState(() {
          _preview = preview;
          _message = 'Validation passed. Review the preview before choosing whether to replace.';
        });
      }
    },
  );
  Future<bool> _confirm(
    String title,
    String explanation,
    String action,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) {
          var checked = false;
          return StatefulBuilder(
            builder: (c, set) => AlertDialog(
              constraints: const BoxConstraints(maxWidth: 640),
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(explanation),
                    CheckboxListTile(
                      key: const ValueKey('data-confirm-checkbox'),
                      contentPadding: EdgeInsets.zero,
                      value: checked,
                      onChanged: (v) => set(() => checked = v ?? false),
                      title: const Text(
                        'I understand and explicitly confirm this change.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Keep current data'),
                ),
                FilledButton(
                  key: const ValueKey('data-confirm-action'),
                  onPressed: checked ? () => Navigator.pop(c, true) : null,
                  child: Text(action),
                ),
              ],
            ),
          );
        },
      ) ??
      false;
  Future<void> _replace() async {
    final preview = _preview;
    if (preview == null ||
        !await _confirm(
          'Replace the entire current library?',
          '${preview.sessions} saved attempts and ${preview.media} original media files will replace your current library and appearance settings. ${preview.missing} referenced media files are missing from the source. A recovery snapshot and original audio directory will be retained. Replacement cannot be cancelled once it starts.',
          'Replace current library',
        )) {
      return;
    }
    await _run('Preserving recovery data and replacing the library…', (
      token,
    ) async {
      await _quiesce();
      await _manager!.replace(preview, token, confirmed: true);
      if (mounted) {
        setState(() {
          _preview = null;
          _message = 'Library replaced and recovery copy retained. Open History or a module to inspect the restored records.';
        });
      }
    }, cancellable: false);
  }

  Future<void> _deleteSession() async {
    if (_session == null) {
      return;
    }
    final plan = await _manager!.planSession(_session!);
    if (!mounted ||
        !await _confirm(
          'Delete this attempt family?',
          '${plan.ids.length} attempts and ${plan.media.length} recording files will be removed from the live library. Linked Writing versions and Impromptu retries are deleted together so remaining history keeps valid references. Authored Memory speeches remain. Earlier exports and recovery copies are separate and are not erased.',
          'Delete attempt family',
        )) {
      return;
    }
    await _run('Deleting the selected attempt family…', (_) async {
      await _quiesce();
      await _manager!.deleteSession(_session!, confirmed: true);
      if (mounted) {
        setState(
          () => _message = 'Selected attempt family deleted. External exports and earlier recovery snapshots may still contain copies.',
        );
      }
    }, cancellable: false);
  }

  Future<void> _deleteMedia() async {
    if (_recording == null ||
        !await _confirm(
          'Delete the original recording file?',
          'The recording metadata, practice response, observations and review references remain, labelled unavailable. Earlier exports and recovery copies are not erased.',
          'Delete recording file',
        )) {
      return;
    }
    await _run('Deleting the selected recording file…', (_) async {
      await _quiesce();
      await _manager!.deleteMedia(_recording!, confirmed: true);
      if (mounted) {
        setState(
          () => _message = 'Recording file deleted. Its notes, observations and references remain.',
        );
      }
    }, cancellable: false);
  }

  Future<void> _back() async {
    if (_busy) {
      return;
    }
    if (_preview != null) {
      await _manager!.removeStage(_preview!.directory);
      _preview = null;
    }
    if (mounted) {
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (_busy) {
      if (_cancellable) {
        await _cancel();
      }
      return AppExitResponse.cancel;
    }
    if (_preview != null) {
      await _manager!.removeStage(_preview!.directory);
      _preview = null;
    }
    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _card(String title, List<Widget> children) => Card.outlined(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
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
        title: const Text('Data & privacy'),
        leading: IconButton(
          tooltip: 'Back to settings',
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : _back,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Your writing, speech text, ratings and audio are personal content. Archives are plain and unencrypted. Checksums detect corruption; they do not establish authenticity. Choose a private on-device destination.',
                  ),
                  const SizedBox(height: 12),
                  if (_message != null)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _message!,
                        key: const ValueKey('data-status'),
                      ),
                    ),
                  if (_busy) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                    if (_cancellable)
                      TextButton(
                        key: const ValueKey('data-cancel'),
                        onPressed: _cancel,
                        child: const Text('Cancel operation'),
                      ),
                  ],
                  if (_manager == null)
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Retry local storage'),
                    ),
                  if (_manager != null) ...[
                    _card('Export & staged restore', [
                      const Text(
                        'Export includes versioned logical records, original available media, attribution, sizes and SHA-256 checksums. Missing source files are disclosed. No logs, app credentials, caches or recovery copies are exported.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            key: const ValueKey('data-export'),
                            onPressed: _busy ? null : _export,
                            icon: const Icon(Icons.save_alt),
                            label: const Text('Export library'),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('data-restore'),
                            onPressed: _busy ? null : () => _stage(),
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Choose archive to preview'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'User-written content may itself contain sensitive information; it is preserved rather than automatically redacted. Choose only an archive you trust.',
                      ),
                    ]),
                    if (_preview case final preview?)
                      _card('Validated restore preview', [
                        Text(
                          'Archive format 1 · schema ${preview.manifest['schemaVersion']} · app ${preview.manifest['appVersion']}',
                        ),
                        Text('Created UTC: ${preview.manifest['createdUtc']}'),
                        Text(
                          '${preview.sessions} saved attempts · ${preview.media} original media files · ${preview.missing} missing source files',
                        ),
                        for (final e
                            in (preview.manifest['tables'] as Map).entries)
                          Text('${e.key}: ${e.value} records'),
                        const Text(
                          'This is replacement, not merging. Current records remain unchanged until you explicitly confirm.',
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              key: const ValueKey('data-replace'),
                              onPressed: _busy ? null : _replace,
                              child: const Text('Review replace confirmation'),
                            ),
                            TextButton(
                              key: const ValueKey('data-discard-preview'),
                              onPressed: _busy
                                  ? null
                                  : () async {
                                      await _manager!.removeStage(
                                        preview.directory,
                                      );
                                      if (mounted) {
                                        setState(() {
                                          _preview = null;
                                          _message = 'Staged restore discarded. Current data kept.';
                                        });
                                        await _reload();
                                      }
                                    },
                              child: const Text('Discard preview'),
                            ),
                          ],
                        ),
                      ]),
                    if (_storage case final stats?)
                      _card('Storage on this device', [
                        Text(
                          'Database and SQLite journals: ${storageBytes(stats['database']!)}',
                        ),
                        Text(
                          'Current audio files: ${storageBytes(stats['media']!)}',
                        ),
                        Text(
                          'Recovery snapshots and original media: ${storageBytes(stats['recovery']!)}',
                        ),
                        Text(
                          'Temporary staging: ${storageBytes(stats['staging']!)}',
                        ),
                        Text(
                          'Available local space: ${storageBytes(stats['free']!)}',
                        ),
                        Text(
                          '${stats['missingMedia']} missing referenced files · ${stats['unindexedFiles']} unindexed audio-directory files',
                        ),
                        const Text(
                          'Unindexed files are retained and excluded from logical exports. Deletion here does not erase external archives, OS snapshots, or previous recovery copies.',
                        ),
                        TextButton(
                          onPressed: _busy ? null : _reload,
                          child: const Text('Refresh storage report'),
                        ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () async {
                                  if (await _confirm(
                                    'Remove abandoned temporary copies?',
                                    'Temporary export/import stages will be removed, except the current validated preview. The live library and recovery snapshots stay.',
                                    'Remove temporary copies',
                                  )) {
                                    await _run(
                                      'Removing abandoned temporary copies…',
                                      (_) => _manager!.cleanupStaging(
                                        confirmed: true,
                                        keepId: _preview?.id,
                                      ),
                                      cancellable: false,
                                    );
                                  }
                                },
                          child: const Text('Review temporary-copy cleanup'),
                        ),
                      ]),
                    _card('Deliberate deletion', [
                      DropdownButtonFormField<String>(
                        key: ValueKey('data-session-$_session'),
                        initialValue: _session,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Saved attempt',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final s in _sessions)
                            DropdownMenuItem(
                              value: s.id,
                              child: Text(
                                '${s.localPracticeDate} · ${s.moduleId} · ${Exercise.fromSnapshot(s.snapshot).title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _session = v),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const ValueKey('data-delete-session'),
                        onPressed: _busy || _session == null
                            ? null
                            : _deleteSession,
                        child: const Text('Review attempt-family deletion'),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        key: ValueKey('data-media-$_recording'),
                        initialValue: _recording,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Recording file',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final r in _media)
                            DropdownMenuItem(
                              value: r.id,
                              child: Text(
                                '${r.microphoneCheck ? 'Microphone check' : 'Response'} · ${r.state} · ${r.id.substring(0, 8)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _recording = v),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const ValueKey('data-delete-media'),
                        onPressed: _busy || _recording == null
                            ? null
                            : _deleteMedia,
                        child: const Text('Review recording deletion'),
                      ),
                    ]),
                    _card('Recovery snapshots', [
                      if (_recovery.isEmpty)
                        const Text(
                          'No replacement recovery snapshot yet. One is saved before a confirmed replace.',
                        ),
                      for (final file in _recovery)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Recovery ${file.parent.uri.pathSegments.where((s) => s.isNotEmpty).last.substring(9, 17)}',
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _stage(file),
                                    child: const Text(
                                      'Validate recovery preview',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () async {
                                            if (await _confirm(
                                              'Remove this recovery copy?',
                                              'Its archive and retained original audio directory will be permanently removed from app storage. The live library is unchanged.',
                                              'Remove recovery copy',
                                            )) {
                                              await _run(
                                                'Removing selected recovery copy…',
                                                (_) => _manager!.removeRecovery(
                                                  file,
                                                  confirmed: true,
                                                ),
                                                cancellable: false,
                                              );
                                            }
                                          },
                                    child: const Text('Remove recovery copy'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ]),
                    _card('Privacy & Android backup', [
                      const Text(
                        'No account, sync or cloud-storage service is part of Articulate. The system document picker requests local providers; choose an on-device location. The OS or a provider may independently handle files you select.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Android OS cloud backup and device-transfer exclusions are explicitly configured. OEM behavior can vary; no absolute OS-backup or secure-erasure guarantee is claimed. No encryption or password protection is applied to these archives.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Runtime input IDs, diagnostic status notes, development logs and internal commit markers are omitted. All authored content, assessments and required attribution remain. Deletion is not secure erasure; SQLite free pages and OS snapshots may retain copies. External backups and recovery copies must be managed separately.',
                      ),
                    ]),
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
