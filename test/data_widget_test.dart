import 'dart:io';

import 'package:articulate/audio/audio_provider.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:articulate/data/data_page.dart';
import 'package:articulate/data/data_manager.dart';
import 'package:articulate/data/platform_files.dart';
import 'package:articulate/providers.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';
import 'data_fixture.dart';

class TestDataFiles extends DataFiles {
  TestDataFiles(this.file);
  final File file;
  bool cancelNext = false;
  @override
  Future<String?> choose(bool save, String name) async {
    if (cancelNext) {
      cancelNext = false;
      return null;
    }
    return file.path;
  }
}

Future<void> dataWait(WidgetTester t, {bool Function()? until}) async {
  for (var i = 0; i < 800; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await t.pump(const Duration(milliseconds: 20));
    if (i > 20 &&
        (until?.call() ??
            find.byType(LinearProgressIndicator).evaluate().isEmpty)) {
      return;
    }
  }
  final status = find.byKey(const ValueKey('data-status'));
  fail(
    'Data UI operation did not settle: ${status.evaluate().isEmpty ? 'no status' : t.widget<Text>(status).data}',
  );
}

Future<void> dataTap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.runAsync(() async {
    await t.tap(f);
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });
  await dataWait(t);
}

Future<void> dataConfirm(WidgetTester t) async {
  await dataTap(
    t,
    find.descendant(
      of: find.byKey(const ValueKey('data-confirm-checkbox')),
      matching: find.byType(Checkbox),
    ),
  );
  expect(
    t
        .widget<Checkbox>(
          find.descendant(
            of: find.byKey(const ValueKey('data-confirm-checkbox')),
            matching: find.byType(Checkbox),
          ),
        )
        .value,
    isTrue,
  );
  await dataTap(t, find.byKey(const ValueKey('data-confirm-action')));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final f in ['Manrope', 'Lora']) {
      await (FontLoader(
        f,
      )..addFont(rootBundle.load('assets/fonts/$f.ttf'))).load();
    }
  });
  late Directory root, external;
  late AppDatabase db;
  late PracticeRepository p;
  late DataManager manager;
  late TestDataFiles files;
  final audios = <LocalAudio>[];
  setUp(() async {
    (root, db, p, manager) = await dataLibrary(fixture: true);
    external = await Directory.systemTemp.createTemp('articulate-transfer-');
    files = TestDataFiles(File('${external.path}/Test ü library.articulate'));
  });
  tearDown(() async {
    for (final a in audios) {
      await a.close();
    }
    audios.clear();
    await db.close();
    await root.delete(recursive: true);
    await external.delete(recursive: true);
  });
  Widget app() => ProviderScope(
    key: UniqueKey(),
    overrides: [
      repositoryProvider.overrideWithValue(p),
      dataManagerProvider.overrideWith((ref) async => manager),
      dataFilesProvider.overrideWithValue(files),
      localAudioProvider.overrideWith((ref) async {
        final a = LocalAudio(
          AudioStore(p, root),
          FakeAudioBackend(),
          automaticHeartbeat: false,
        );
        audios.add(a);
        return a;
      }),
    ],
    child: MaterialApp(
      theme: articulateTheme(Brightness.light),
      home: const DataManagementPage(),
    ),
  );
  void size(WidgetTester t, Size value, double scale) {
    t.view.physicalSize = value;
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets(
    'export cancellation, preview without mutation, explicit replace and recovery-copy retention',
    (t) async {
      size(t, const Size(1440, 1000), 1);
      await t.pumpWidget(app());
      await dataWait(
        t,
        until: () =>
            find.byKey(const ValueKey('data-export')).evaluate().isNotEmpty,
      );
      files.cancelNext = true;
      await dataTap(t, find.byKey(const ValueKey('data-export')));
      expect(
        find.textContaining('Cancelled. The current library was not replaced.'),
        findsOneWidget,
      );
      await dataTap(t, find.byKey(const ValueKey('data-export')));
      expect(await t.runAsync(files.file.exists), isTrue);
      expect(find.textContaining('Export verified.'), findsOneWidget);
      final sentinel = (await t.runAsync(() => sentinelLibrary(p, root)))!;
      await dataTap(t, find.byKey(const ValueKey('data-restore')));
      expect(find.text('Validated restore preview'), findsOneWidget);
      expect(
        (await t.runAsync(() => p.load(sentinel)))!.response.body,
        contains('original library'),
      );
      await dataTap(t, find.byKey(const ValueKey('data-replace')));
      expect(
        t
            .widget<FilledButton>(
              find.byKey(const ValueKey('data-confirm-action')),
            )
            .onPressed,
        isNull,
      );
      await dataTap(t, find.text('Keep current data'));
      expect(
        await t.runAsync(() => db.select(db.practiceSessions).get()),
        hasLength(16),
      );
      await dataTap(t, find.byKey(const ValueKey('data-replace')));
      await dataConfirm(t);
      expect(
        find.textContaining('Library replaced and recovery copy retained.'),
        findsOneWidget,
      );
      expect(
        await t.runAsync(() => db.select(db.practiceSessions).get()),
        hasLength(15),
      );
      expect(await t.runAsync(manager.recoveryArchives), hasLength(1));
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await dataWait(t);
    },
  );
  for (final entry in [
    (const Size(375, 812), 2.0),
    (const Size(844, 390), 2.0),
    (const Size(1440, 1000), 1.0),
  ]) {
    testWidgets(
      'storage, restore preview and deliberate deletion controls fit ${entry.$1} scale ${entry.$2}',
      (t) async {
        size(t, entry.$1, entry.$2);
        await t.pumpWidget(app());
        await dataWait(
          t,
          until: () =>
              find.byKey(const ValueKey('data-export')).evaluate().isNotEmpty,
        );
        await dataTap(t, find.byKey(const ValueKey('data-export')));
        await dataTap(t, find.byKey(const ValueKey('data-restore')));
        expect(t.takeException(), isNull);
        await dataTap(t, find.byKey(const ValueKey('data-replace')));
        await dataTap(
          t,
          find.descendant(
            of: find.byKey(const ValueKey('data-confirm-checkbox')),
            matching: find.byType(Checkbox),
          ),
        );
        expect(
          t
              .widget<Checkbox>(
                find.descendant(
                  of: find.byKey(const ValueKey('data-confirm-checkbox')),
                  matching: find.byType(Checkbox),
                ),
              )
              .value,
          isTrue,
        );
        expect(t.takeException(), isNull);
        await dataTap(t, find.text('Keep current data'));
        await dataTap(t, find.byKey(const ValueKey('data-discard-preview')));
        final picker = find.byWidgetPredicate(
          (w) =>
              w is DropdownButtonFormField<String> &&
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('data-media-'),
        );
        await dataTap(t, picker);
        final row = (await t.runAsync(
          () => db.select(db.audioRecordings).get(),
        ))!.first;
        await dataTap(
          t,
          find
              .text(
                '${row.microphoneCheck ? 'Microphone check' : 'Response'} · ${row.state} · ${row.id.substring(0, 8)}',
              )
              .last,
        );
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        expect(FocusManager.instance.primaryFocus, isNotNull);
        await dataTap(t, find.byKey(const ValueKey('data-delete-media')));
        await dataConfirm(t);
        expect(find.textContaining('Recording file deleted.'), findsOneWidget);
        expect(t.takeException(), isNull);
        t.view.physicalSize = const Size(375, 812);
        await dataWait(t);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await dataWait(t);
      },
    );
  }
}
