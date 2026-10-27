import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

// Run write and read in separate native runner processes; see docs/phase2.md.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phase = String.fromEnvironment('RESTART_PHASE');
  testWidgets('native process restart: $phase', (tester) async {
    expect({'write', 'read'}.contains(phase), isTrue);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Articulate process restart verification')),
      ),
    );
    final support = await getApplicationSupportDirectory();
    final dir = await Directory(
      '${support.path}${Platform.pathSeparator}verification',
    ).create(recursive: true);
    final file = File(
      '${dir.path}${Platform.pathSeparator}phase2-restart.sqlite',
    );
    if (phase == 'write') {
      expect(
        await file.exists(),
        isFalse,
        reason: 'Do not overwrite an unfinished verification database.',
      );
      final db = AppDatabase(NativeDatabase.createInBackground(file));
      final repo = PracticeRepository(db);
      final e = validateExercisePack(
        await rootBundle.loadString('assets/exercises/core-v1.json'),
      ).first;
      final id = await repo.createDraft(e, DateTime.now());
      await repo.saveResponse(
        id,
        'Separate-process saved response',
        DateTime.now().toUtc(),
      );
      final d = await repo.start(id, DateTime.now().toUtc());
      await repo.checkpoint(
        id,
        d.openSegment!.id,
        3500,
        DateTime.now().toUtc(),
      );
      await repo.saveSetting('reduceMotion', 'true');
      // Intentionally omit leave/recovery; persist running work before this runner exits.
      await db.close();
      debugPrint('RESTART_WRITE_OK $id');
    } else {
      expect(await file.exists(), isTrue);
      final db = AppDatabase(NativeDatabase.createInBackground(file));
      final repo = PracticeRepository(db);
      await repo.recoverInterrupted();
      final rows = await db.select(db.practiceSessions).get();
      expect(rows, hasLength(1));
      final d = await repo.load(rows.single.id);
      expect(d.session.status, 'interrupted');
      expect(d.response.body, 'Separate-process saved response');
      expect(d.elapsedMs, 3500);
      expect((await repo.watchSettings().first)['reduceMotion'], 'true');
      debugPrint('RESTART_READ_OK ${d.session.id} elapsed=${d.elapsedMs}');
      await db.close();
      await file.delete();
    }
  });
}
