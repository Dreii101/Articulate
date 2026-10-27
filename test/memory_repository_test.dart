import 'dart:convert';
import 'dart:io';

import 'package:articulate/exercises.dart';
import 'package:articulate/memory/memory_document.dart';
import 'package:articulate/memory/memory_repository.dart';
import 'package:articulate/session_controller.dart';
import 'package:articulate/storage/database.dart';
import 'package:articulate/storage/practice_repository.dart';
import 'package:articulate/audio/audio_store.dart';
import 'package:articulate/audio/local_audio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audio_fakes.dart';

MemoryDocument starter() => validateMemoryPack(
  File('assets/exercises/memory-v1.json').readAsStringSync(),
).first;
void main() {
  test(
    'original speeches cover three levels; invalid content and references fail',
    () {
      final pack = validateMemoryPack(
        File('assets/exercises/memory-v1.json').readAsStringSync(),
      );
      expect(pack.map((s) => s.data['level']).toSet(), {
        'beginner',
        'intermediate',
        'advanced',
      });
      for (final doc in pack) {
        expect(doc.sections.length, 3);
        for (final s in doc.sections) {
          expect(s['phrase'], isNotEmpty);
          expect(s['keywords'], isNotEmpty);
          expect(s['ideas'], isNotEmpty);
        }
      }
      for (final value in [
        <String, dynamic>{},
        {...starter().data, 'language': 'not a language'},
        {
          ...starter().data,
          'sections': [starter().sections.first, starter().sections.first],
        },
        {...starter().data, 'level': 'expert'},
      ]) {
        expect(() => MemoryDocument.parse(value), throwsFormatException);
      }
      expect(
        () => validateMemorySnapshot({
          'speechId': 'a',
          'versionId': 'b',
          'versionNumber': 1,
          'sectionId': 'missing',
          'speech': starter().data,
        }),
        throwsFormatException,
      );
      expect(
        () => validateMemoryPack('{"formatVersion":99}'),
        throwsFormatException,
      );
    },
  );
  test(
    'immutable versions preserve source, manual order, cues and old attempts',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final p = PracticeRepository(db),
          m = MemoryRepository(PracticeRepository(db));
      final id = await m.saveDraft(null, starter().data),
          v1 = await m.publish(id);
      final a = await m.createAttempt(
        v1.id,
        'section-1',
        'meaning',
        'typed',
        'full',
      );
      final old = (await p.load(a)).session.snapshot;
      final edit = starter().data;
      (edit['sections'] as List).insert(
        0,
        (edit['sections'] as List).removeLast(),
      );
      edit['sections'][0]['text'] = 'Changed speech text, never old evidence.';
      await m.saveDraft(id, edit);
      final v2 = await m.publish(id);
      expect(v2.versionNumber, 2);
      expect((await m.publish(id)).id, v2.id);
      expect(
        MemoryDocument.parse(jsonDecode(v2.content)).sections.first['id'],
        'section-3',
      );
      expect(
        MemoryDocument.parse(jsonDecode(v1.content)).sections.first['id'],
        'section-1',
      );
      expect((await p.load(a)).session.snapshot, old);
      expect((await m.workspace(a)).versionId, v1.id);
      final snapshot = (await p.load(a)).exercise.content['memory'];
      expect(snapshot['versionNumber'], 1);
      final corrupt = jsonDecode(old) as Map<String, dynamic>;
      corrupt['exercises'][0]['memory']['versionNumber'] = 99;
      expect(
        () => Exercise.fromSnapshot(jsonEncode(corrupt)),
        throwsFormatException,
      );

      expect(
        snapshot['speech']['sections'][0]['text'],
        starter().sections.first['text'],
      );
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    },
  );
  test('cue transitions and reveals persist, same cue is idempotent, closed assistance is frozen', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final p = PracticeRepository(db),
        m = MemoryRepository(PracticeRepository(db));
    final v = await m.publish(await m.saveDraft(null, starter().data));
    final id = await m.createAttempt(
      v.id,
      'section-2',
      'verbatim',
      'typed',
      'full',
    );
    for (final cue in cueStages.skip(1)) {
      await m.assistance(id, cue: cue);
    }
    await m.assistance(id, cue: 'hidden');
    await m.assistance(id, reveal: true);
    await m.assistance(id, reveal: true);
    final w = await m.workspace(id), events = jsonDecode(w.assistance) as List;
    expect(
      events.where((e) => e['kind'] == 'cue').map((e) => e['cue']).toList(),
      cueStages,
    );
    expect(events.where((e) => e['kind'] == 'reveal').length, 2);
    expect(events.every((e) => e['utcMs'] is int), isTrue);
    await p.transition(id, PracticeStatus.completed, DateTime.now());
    await expectLater(m.assistance(id, reveal: true), throwsStateError);
    await expectLater(m.assistance(id, cue: 'full'), throwsStateError);
    expect((await m.workspace(id)).assistance, w.assistance);
    expect(
      cueText(starter().sections.first, 'hidden'),
      isNot(contains(starter().sections.first['text'])),
    );
    expect(
      cueText(starter().sections.first, 'phrase'),
      starter().sections.first['phrase'],
    );
  });
  test('restart restores typed draft, exact references, and review without invented ratings', () async {
    final dir = await Directory.systemTemp.createTemp(
      'articulate-memory-restart-',
    );
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/memory.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    var p = PracticeRepository(db);
    var m = MemoryRepository(p);
    final v = await m.publish(await m.saveDraft(null, starter().data));
    final id = await m.createAttempt(
      v.id,
      'section-1',
      'meaning',
      'typed',
      'keywords',
    );
    var c = SessionController(p, id);
    await c.open();
    await c.saveResponse('My own paraphrase is evidence, not a machine score.');
    await m.assistance(id, reveal: true);
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    m = MemoryRepository(p);
    c = SessionController(p, id);
    await c.open();
    expect(c.detail!.response.body, startsWith('My own paraphrase'));
    expect((await m.workspace(id)).cueStage, 'keywords');
    await c.transition(PracticeStatus.completed);
    await c.transition(PracticeStatus.completed);
    await m.saveReview(id, {}, 'Try the transition again.', true);
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    p = PracticeRepository(db);
    m = MemoryRepository(p);
    expect((await m.workspace(id)).assessments, '{}');
    expect((await m.workspace(id)).laterReview, isTrue);
    expect((await m.workspace(id)).versionId, v.id);
    expect((await p.load(id)).review!.notes, 'Try the transition again.');
    expect((await db.select(db.practiceSessions).get()).length, 1);
    await expectLater(
      p.saveResponse(id, 'overwrite', DateTime.now()),
      throwsStateError,
    );
    await m.saveReview(
      id,
      {'ideas': 'missed', 'transitions': 'recalled'},
      '',
      false,
    );
    expect((await m.workspace(id)).laterReview, isFalse);
    await expectLater(
      m.saveReview(id, {'accuracy': '100'}, '', false),
      throwsArgumentError,
    );
    await db.close();
  });
  test('spoken recall reuses managed audio and keeps evidence attached to practiced version', () async {
    final root = await Directory.systemTemp.createTemp('memory-audio-');
    final db = AppDatabase(NativeDatabase.memory());
    final p = PracticeRepository(db),
        m = MemoryRepository(PracticeRepository(db));
    final a = LocalAudio(
      AudioStore(p, root),
      FakeAudioBackend(),
      automaticHeartbeat: false,
    );
    addTearDown(() async {
      await a.close();
      await db.close();
      await root.delete(recursive: true);
    });
    final v = await m.publish(await m.saveDraft(null, starter().data)),
        id = await m.createAttempt(
          (await m.versions(
            (await db.select(db.memorySpeeches).get()).single.id,
          )).first.id,
          'section-3',
          'meaning',
          'spoken',
          'hidden',
        );
    await a.start(id);
    await a.stop();
    final take = (await db.select(db.audioRecordings).get()).single;
    expect(take.state, 'finalized');
    expect(take.sessionId, id);
    expect((await m.workspace(id)).versionId, v.id);
    expect((await p.load(id)).response.body, isEmpty);
    await a.select(take);
    await a.playPause();
    expect(a.playing, isTrue);
    await p.transition(id, PracticeStatus.completed, DateTime.now());
    await m.saveReview(
      id,
      {'wording': 'notAssessed'},
      'Listen to the transition.',
      true,
    );
    expect((await m.workspace(id)).assessments, contains('notAssessed'));
    expect(
      (await p.load(id)).exercise.content.containsKey('accuracy'),
      isFalse,
    );
  });
  test(
    'v5 migration keeps prior text, audio metadata, observations and settings',
    () async {
      final root = await Directory.systemTemp.createTemp('memory-v5-');
      addTearDown(() => root.delete(recursive: true));
      final file = File('${root.path}/old.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      var p = PracticeRepository(db);
      final ex = validateExercisePack(
        File('assets/exercises/core-v1.json').readAsStringSync(),
      ).firstWhere((e) => e.module == 'speech');
      final id = await p.createDraft(ex, DateTime.now());
      await p.saveResponse(id, 'Prior speech notes.', DateTime.now());
      await p.saveSetting('theme', 'dark');
      final a = LocalAudio(
        AudioStore(p, root),
        FakeAudioBackend(),
        automaticHeartbeat: false,
      );
      await a.start(id);
      await a.stop();
      final take = a.lastStopped!;
      await a.select(take);
      await a.addObservation('Keep this observation.');
      await a.close();
      for (final table in [
        'memory_workspaces',
        'memory_versions',
        'memory_speeches',
      ]) {
        await db.customStatement('DROP TABLE $table');
      }
      await db.customStatement('DROP TABLE impromptu_workspaces');
      await db.customStatement('DROP TABLE impromptu_queues');
      await db.customStatement('DROP TABLE debate_stages');
      await db.customStatement('DROP TABLE debate_workspaces');
      await db.customStatement(
        'ALTER TABLE audio_recordings DROP COLUMN context_key',
      );
      await db.customStatement('PRAGMA user_version=5');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      p = PracticeRepository(db);
      expect((await p.load(id)).response.body, 'Prior speech notes.');
      expect((await db.select(db.audioRecordings).get()).single.id, take.id);
      expect(
        (await db.select(db.audioObservations).get()).single.note,
        'Keep this observation.',
      );
      expect(await p.watchSettings().first, {'theme': 'dark'});
      expect(await db.select(db.memoryVersions).get(), isEmpty);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        9,
      );
      await db.close();
    },
  );
}
