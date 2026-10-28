import 'dart:convert';
import 'dart:io';

import 'package:articulate/audio/audio_backend.dart';
import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/data/archive_format.dart';
import 'package:articulate/data/data_manager.dart';
import 'package:articulate/data/data_page.dart';
import 'package:articulate/data/platform_files.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/theme.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

import '../test/data_fixture.dart';

class NativeTestFiles extends DataFiles {
  NativeTestFiles(this.destination);
  final String destination;
  final String importPath = const String.fromEnvironment('DATA_IMPORT_PATH');
  final String importSource = const String.fromEnvironment(
    'DATA_IMPORT_SOURCE',
  );
  bool first = true;
  final bool real = const bool.fromEnvironment('DATA_REAL_PICKERS');
  String? saved;
  @override
  Future<String?> choose(bool save, String name) async {
    if (real) {
      debugPrint(
        'DATA_PICKER_${save ? (first ? 'CANCEL' : 'SAVE') : 'OPEN'} ${Platform.isWindows ? destination : 'local Android document'}',
      );
      final result = await super.choose(save, name);
      if (save && result != null) {
        saved = result;
      }
      first = false;
      return result;
    }
    if (first) {
      first = false;
      return null;
    }
    if (save) {
      saved = destination;
    }
    return save || importPath.isEmpty ? destination : importPath;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native export, preview, explicit replacement, recovery and playable original media',
    (t) async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final support = await getApplicationSupportDirectory(),
          root = await Directory(
            '${support.path}/verification/data-${DateTime.now().microsecondsSinceEpoch}',
          ).create(recursive: true),
          file = File('${root.path}/articulate.sqlite');
      var db = AppDatabase(NativeDatabase.createInBackground(file)),
          p = PracticeRepository(db),
          manager = DataManager(p, root, space: DataFiles().freeBytes);
      final packs = <String, List<Exercise>>{};
      for (final name in [
        'core',
        'writing',
        'reading',
        'debate',
        'impromptu',
      ]) {
        packs[name] = validateExercisePack(
          await rootBundle.loadString('assets/exercises/$name-v1.json'),
        );
      }
      await populateData(
        p,
        root,
        packs: packs,
        memorySource: await rootBundle.loadString(
          'assets/exercises/memory-v1.json',
        ),
      );
      Future<List<String>> mediaHashes() async {
        final rows = await db.select(db.audioRecordings).get(),
            hashes = <String>[
              for (final row in rows)
                await fileDigest(File('${root.path}/${row.relativePath}')),
            ];
        return hashes..sort();
      }

      final originalHashes = await mediaHashes();
      const chosen = String.fromEnvironment('DATA_EXPORT_PATH');
      final destination = chosen.isEmpty
          ? '${support.path}/verification/Articulate ü data-${DateTime.now().microsecondsSinceEpoch}.articulate'
          : chosen;
      final files = NativeTestFiles(destination), audios = <LocalAudio>[];
      Widget app() => ProviderScope(
        key: UniqueKey(),
        overrides: [
          repositoryProvider.overrideWithValue(p),
          dataManagerProvider.overrideWith((ref) async => manager),
          dataFilesProvider.overrideWithValue(files),
          localAudioProvider.overrideWith((ref) async {
            final a = LocalAudio(AudioStore(p, root), NativeAudioBackend());
            audios.add(a);
            return a;
          }),
        ],
        child: MaterialApp(
          theme: articulateTheme(Brightness.light),
          home: const DataManagementPage(),
        ),
      );
      Future<void> wait({bool Function()? until}) async {
        for (var i = 0; i < 24000; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 25));
          await t.pump();
          if (i > 20 &&
              (until?.call() ??
                  find.byType(LinearProgressIndicator).evaluate().isEmpty)) {
            await t.pumpAndSettle();
            return;
          }
        }
        throw StateError('Native operation or picker did not complete.');
      }

      Future<void> tap(Finder f) async {
        await t.ensureVisible(f);
        await t.tap(f);
        await wait();
      }

      await t.pumpWidget(app());
      await wait(
        until: () =>
            find.byKey(const ValueKey('data-export')).evaluate().isNotEmpty,
      );
      await tap(find.byKey(const ValueKey('data-export')));
      expect(
        find.textContaining('Cancelled. The current library was not replaced.'),
        findsOneWidget,
      );
      expect(await db.select(db.practiceSessions).get(), hasLength(15));
      await tap(find.byKey(const ValueKey('data-export')));
      expect(find.textContaining('Export verified.'), findsOneWidget);
      final sentinel = await p.createDraft(
        packs['core']!.firstWhere((e) => e.module == 'speech'),
        DateTime.now(),
      );
      await p.saveResponse(
        sentinel,
        'Original before replacement, isolated fixture.',
        DateTime.now(),
      );
      await tap(find.byKey(const ValueKey('data-restore')));
      expect(find.text('Validated restore preview'), findsOneWidget);
      expect(await db.select(db.practiceSessions).get(), hasLength(16));
      await tap(find.byKey(const ValueKey('data-replace')));
      expect(
        t
            .widget<FilledButton>(
              find.byKey(const ValueKey('data-confirm-action')),
            )
            .onPressed,
        isNull,
      );
      await tap(find.text('Keep current data'));
      expect(
        (await p.load(sentinel)).response.body,
        contains('Original before replacement'),
      );
      await tap(find.byKey(const ValueKey('data-replace')));
      await tap(find.byKey(const ValueKey('data-confirm-checkbox')));
      await tap(find.byKey(const ValueKey('data-confirm-action')));
      expect(
        find.textContaining('Library replaced and recovery copy retained.'),
        findsOneWidget,
      );
      expect(await db.select(db.practiceSessions).get(), hasLength(15));
      expect(await manager.recoveryArchives(), hasLength(1));
      expect(
        (await db.select(db.responses).get()).any(
          (r) => r.body == 'First draft with an example.',
        ),
        isTrue,
      );
      expect(await mediaHashes(), originalHashes);
      final context = t.element(find.byType(DataManagementPage)),
          container = ProviderScope.containerOf(context),
          audio = await container.read(localAudioProvider.future);
      final take = await audio.store.load(
        (await db.select(db.audioRecordings).get()).first.id,
      );
      await audio.select(take);
      await (audio.backend as NativeAudioBackend).player.setVolume(25);
      await audio.playPause();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      await t.pump();
      final position = audio.position.inMilliseconds;
      expect(position, greaterThan(0));
      await audio.backend.pausePlayback();
      await t.pumpWidget(const SizedBox());
      await wait();
      for (final a in audios) {
        await a.close();
      }
      await db.close();
      db = AppDatabase(NativeDatabase.createInBackground(file));
      p = PracticeRepository(db);
      manager = DataManager(p, root, space: DataFiles().freeBytes);
      await manager.recover();
      expect(await db.select(db.practiceSessions).get(), hasLength(15));
      expect(await mediaHashes(), originalHashes);
      final report = {
        'platform': Platform.operatingSystem,
        'root': root.path,
        'formatVersion': 1,
        'schemaVersion': 8,
        'sessionsRestored': 15,
        'mediaRestored': 3,
        'nativePickers': files.real,
        'destinationKind': Platform.isAndroid
            ? 'content URI'
            : 'Windows filesystem path',
        'exportCancellation': true,
        'previewKeptCurrentLibrary': true,
        'explicitReplaceRequired': true,
        'recoverySnapshots': (await manager.recoveryArchives()).length,
        'originalMediaSha256': originalHashes,
        'restoredMediaSha256': await mediaHashes(),
        'playbackPositionMs': position,
        'humanListening': 'Not requested; native decoding/playback of synthetic PCM verified.',
        'restartPreservedLibrary': true,
        'crossPlatformRoundTrip': files.importSource.isNotEmpty
            ? 'restored ${files.importSource} archive'
            : files.real
            ? 'same-platform document-URI export and restore'
            : files.importPath.isEmpty
            ? 'same-platform filesystem export and restore'
            : 'supplied archive restored; source platform is caller-verified',
        'fixture': 'Synthetic library, isolated from personal history',
      };
      await File('${root.path}/capability.json')
          .writeAsString(jsonEncode(report));
      debugPrint('DATA_NATIVE_OK ${jsonEncode(report)}');
      await db.close();
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
    },
  );
}
