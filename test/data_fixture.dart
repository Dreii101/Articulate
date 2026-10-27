import 'dart:io';
import 'dart:typed_data';

import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/wave_file.dart';
import 'package:articulate/data/data_manager.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/exercises.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'audio_fakes.dart';
import 'history_fixture.dart';

Future<(Directory, AppDatabase, PracticeRepository, DataManager)> dataLibrary({
  bool fixture = false,
}) async {
  final root = await Directory.systemTemp.createTemp('articulate-data-'),
      db = AppDatabase(NativeDatabase(File('${root.path}/articulate.sqlite'))),
      p = PracticeRepository(db);
  final manager = DataManager(
    p,
    root,
    space: (_) async => 50 * 1024 * 1024 * 1024,
  );
  await manager.recover();
  if (fixture) {
    await populateData(p, root);
  }
  return (root, db, p, manager);
}

Future<Map<String, String>> populateData(
  PracticeRepository p,
  Directory root, {
  Map<String, List<Exercise>>? packs,
  String? memorySource,
}) async {
  final ids = await seedHistoryFixture(
    p,
    packs: packs,
    memorySource: memorySource,
  );
  await p.recoverInterrupted();
  await p.saveSetting('theme', 'dark');
  await p.saveSetting('reduceMotion', 'true');
  await p.db
      .into(p.db.appSettings)
      .insert(
        AppSettingsCompanion.insert(
          key: 'apiCredential',
          value: 'NEVER_EXPORT_CREDENTIAL',
        ),
      );
  for (final r in await p.db.select(p.db.audioRecordings).get()) {
    await writeTestWave(
      '${root.path}/${r.relativePath}',
      milliseconds: r.durationMs,
    );
    final info = await inspectWave('${root.path}/${r.relativePath}');
    await (p.db.update(
      p.db.audioRecordings,
    )..where((a) => a.id.equals(r.id))).write(
      AudioRecordingsCompanion(
        byteCount: Value(info.bytes),
        sampleRate: Value(info.sampleRate),
        channels: Value(info.channels),
        peakDb: Value(info.peakDb),
        rmsDb: Value(info.rmsDb),
        inputId: const Value('NEVER_EXPORT_INPUT_ID'),
        statusNote: const Value('NEVER_EXPORT_DIAGNOSTIC_LOG'),
      ),
    );
  }
  return ids;
}

Future<String> sentinelLibrary(PracticeRepository p, Directory root) async {
  final id = await p.createDraft(
    historyPack('core').firstWhere((e) => e.module == 'speech'),
    DateTime.now(),
  );
  await p.saveResponse(id, 'My original library must survive.', DateTime.now());
  final store = AudioStore(p, root),
      r = await store.reserve(id, 'old-input', 'Original input');
  await writeTestWave(store.fileFor(r.relativePath).path);
  await store.finalize(r.id);
  return id;
}

Future<void> largeTestWave(File file, int dataBytes) async {
  await writeTestWave(file.path);
  final handle = await file.open(mode: FileMode.append), header = ByteData(4);
  try {
    await handle.truncate(44);
    await handle.setPosition(4);
    header.setUint32(0, 36 + dataBytes, Endian.little);
    await handle.writeFrom(header.buffer.asUint8List());
    await handle.setPosition(40);
    header.setUint32(0, dataBytes, Endian.little);
    await handle.writeFrom(header.buffer.asUint8List());
    await handle.setPosition(44);
    final chunk = Uint8List(65536);
    for (var n = 0; n < dataBytes; n += chunk.length) {
      await handle.writeFrom(chunk, 0, (dataBytes - n).clamp(0, chunk.length));
    }
    await handle.flush();
  } finally {
    await handle.close();
  }
}
