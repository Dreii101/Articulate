import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class PracticeSessions extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseId => text()();
  IntColumn get exerciseVersion => integer()();
  TextColumn get moduleId => text()();
  TextColumn get snapshot => text()();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('draft','running','paused','interrupted','completed','abandoned'))",
  )();
  TextColumn get stage => text().customConstraint(
    "NOT NULL CHECK (stage IN ('prepare','respond','reflect'))",
  )();
  IntColumn get createdUtcMs => integer()();
  IntColumn get updatedUtcMs => integer()();
  IntColumn get startedUtcMs => integer().nullable()();
  IntColumn get completedUtcMs => integer().nullable()();
  TextColumn get localPracticeDate => text()();
  IntColumn get originalOffsetMinutes => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class Responses extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().unique().references(PracticeSessions, #id)();
  TextColumn get body => text().withDefault(const Constant(''))();
  IntColumn get updatedUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class TimingSegments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get stage => text()();
  IntColumn get startedUtcMs => integer()();
  IntColumn get checkpointUtcMs => integer()();
  IntColumn get endedUtcMs => integer().nullable()();
  IntColumn get elapsedMs =>
      integer().customConstraint('NOT NULL CHECK (elapsed_ms >= 0)')();
  TextColumn get endReason => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class ReviewRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().unique().references(PracticeSessions, #id)();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('inProgress','reviewed'))",
  )();
  TextColumn get notes => text()();
  IntColumn get updatedUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class WritingWorkspaces extends Table {
  @ReferenceName('writingVersions')
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  @ReferenceName('writingRoots')
  TextColumn get rootSessionId => text().references(PracticeSessions, #id)();
  @ReferenceName('writingChildren')
  TextColumn get parentSessionId =>
      text().nullable().unique().references(PracticeSessions, #id)();
  IntColumn get versionNumber => integer()();
  TextColumn get outline => text().withDefault(const Constant(''))();
  TextColumn get audience => text()();
  TextColumn get purpose => text()();
  TextColumn get viewStep => text().withDefault(const Constant('brief'))();
  TextColumn get assessments => text().withDefault(const Constant('{}'))();
  TextColumn get reviewRubric => text()();
  TextColumn get legacyReviewNotes => text().withDefault(const Constant(''))();
  TextColumn get nextAction => text().withDefault(const Constant(''))();
  IntColumn get updatedUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {sessionId};
  @override
  List<Set<Column>> get uniqueKeys => [
    {rootSessionId, versionNumber},
  ];
}

class ReadingWorkspaces extends Table {
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get keyResults => text().nullable()();
  TextColumn get revisionAnswers => text().withDefault(const Constant('{}'))();
  TextColumn get ratings => text().withDefault(const Constant('{}'))();
  TextColumn get viewStep => text().withDefault(const Constant('passage'))();
  BoolColumn get hidePassage => boolean().withDefault(const Constant(false))();
  IntColumn get updatedUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {sessionId};
}

@DataClassName('MemorySpeech')
class MemorySpeeches extends Table {
  TextColumn get id => text()();
  TextColumn get draft => text()();
  IntColumn get updatedUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class MemoryVersions extends Table {
  TextColumn get id => text()();
  TextColumn get speechId => text().references(MemorySpeeches, #id)();
  IntColumn get versionNumber => integer()();
  TextColumn get content => text()();
  IntColumn get createdUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {speechId, versionNumber},
  ];
}

class MemoryWorkspaces extends Table {
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get versionId => text().references(MemoryVersions, #id)();
  TextColumn get sectionId => text()();
  TextColumn get mode => text()();
  TextColumn get recallKind => text()();
  TextColumn get cueStage => text()();
  TextColumn get assistance => text()();
  TextColumn get assessments => text().withDefault(const Constant('{}'))();
  TextColumn get reviewNote => text().withDefault(const Constant(''))();
  BoolColumn get laterReview => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {sessionId};
}

class DebateWorkspaces extends Table {
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get position => text()();
  TextColumn get responseKind => text()();
  TextColumn get preset => text()();
  IntColumn get currentStage => integer().withDefault(const Constant(0))();
  TextColumn get assessments => text().withDefault(const Constant('{}'))();
  TextColumn get reviewNote => text().withDefault(const Constant(''))();
  @override
  Set<Column> get primaryKey => {sessionId};
}

class DebateStages extends Table {
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get stageKey => text()();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('pending','active','completed','skipped'))",
  )();
  TextColumn get fields => text().withDefault(const Constant('{}'))();
  IntColumn get elapsedMs => integer().withDefault(const Constant(0))();
  IntColumn get finishedUtcMs => integer().nullable()();
  @override
  Set<Column> get primaryKey => {sessionId, stageKey};
}

class ImpromptuQueues extends Table {
  TextColumn get poolKey => text()();
  TextColumn get remaining => text()();
  TextColumn get lastQuestion => text()();
  @override
  Set<Column> get primaryKey => {poolKey};
}

class ImpromptuWorkspaces extends Table {
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get requestKey => text().unique()();
  @ReferenceName('impromptuRetries')
  TextColumn get parentSessionId =>
      text().nullable().unique().references(PracticeSessions, #id)();
  TextColumn get improvement => text().withDefault(const Constant(''))();
  TextColumn get responseKind => text()();
  TextColumn get preset => text()();
  TextColumn get viewStep => text().withDefault(const Constant('reveal'))();
  TextColumn get preparation => text().withDefault(const Constant(''))();
  BoolColumn get scaffoldEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get scaffold => text().withDefault(const Constant('{}'))();
  TextColumn get assessments => text().withDefault(const Constant('{}'))();
  TextColumn get reflection => text().withDefault(const Constant(''))();
  IntColumn get confidence => integer().nullable()();
  @override
  Set<Column> get primaryKey => {sessionId};
}

class AudioRecordings extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get contextKey => text().withDefault(const Constant(''))();
  TextColumn get relativePath => text().unique()();
  TextColumn get state => text().customConstraint(
    "NOT NULL CHECK (state IN ('pending','finalized','unavailable'))",
  )();
  BoolColumn get microphoneCheck =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get interrupted => boolean().withDefault(const Constant(false))();
  TextColumn get inputId => text()();
  TextColumn get inputName => text()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  IntColumn get sampleRate => integer().withDefault(const Constant(0))();
  IntColumn get channels => integer().withDefault(const Constant(0))();
  IntColumn get byteCount => integer().withDefault(const Constant(0))();
  RealColumn get peakDb => real().nullable()();
  RealColumn get rmsDb => real().nullable()();
  TextColumn get statusNote => text().withDefault(const Constant(''))();
  IntColumn get createdUtcMs => integer()();
  IntColumn get finalizedUtcMs => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class AudioObservations extends Table {
  TextColumn get id => text()();
  TextColumn get recordingId => text().references(AudioRecordings, #id)();
  IntColumn get positionMs => integer()();
  TextColumn get note => text()();
  IntColumn get createdUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class CustomExercises extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer()();
  TextColumn get snapshot => text()();
  IntColumn get createdUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {id, version};
}

class PracticeContexts extends Table {
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get requestKey => text().unique()();
  @ReferenceName('targetedRetries')
  TextColumn get parentSessionId =>
      text().nullable().unique().references(PracticeSessions, #id)();
  TextColumn get label => text()();
  TextColumn get conditions => text()();
  TextColumn get target => text()();
  @override
  Set<Column> get primaryKey => {sessionId};
}

class RecallSchedules extends Table {
  IntColumn get sequence => integer().unique()();
  TextColumn get sessionId => text().references(PracticeSessions, #id)();
  TextColumn get observation => text()();
  TextColumn get observedLocalDate => text()();
  IntColumn get originalOffsetMinutes => integer()();
  IntColumn get observedUtcMs => integer()();
  IntColumn get intervalIndex => integer()();
  IntColumn get intervalDays => integer()();
  TextColumn get recommendedDate => text()();
  TextColumn get overrideDate => text().nullable()();
  BoolColumn get paused => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {sessionId};
}

@DriftDatabase(
  tables: [
    PracticeSessions,
    Responses,
    TimingSegments,
    ReviewRecords,
    AppSettings,
    WritingWorkspaces,
    ReadingWorkspaces,
    AudioRecordings,
    AudioObservations,
    MemorySpeeches,
    MemoryVersions,
    MemoryWorkspaces,
    DebateWorkspaces,
    DebateStages,
    ImpromptuQueues,
    ImpromptuWorkspaces,
    CustomExercises,
    PracticeContexts,
    RecallSchedules,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  RandomAccessFile? _processLock;
  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 1 || from > 8 || to != 9) {
        throw StateError(
          'Unsupported database migration $from → $to. Data was not reset.',
        );
      }
      if (from == 1) {
        await m.createTable(reviewRecords);
        await m.createTable(appSettings);
      }
      if (from < 3) await m.createTable(writingWorkspaces);
      if (from < 4) await m.createTable(readingWorkspaces);
      if (from < 5) {
        await m.createTable(audioRecordings);
        await m.createTable(audioObservations);
      }
      if (from < 6) {
        await m.createTable(memorySpeeches);
        await m.createTable(memoryVersions);
        await m.createTable(memoryWorkspaces);
      }
      if (from >= 5 && from < 7) {
        await m.addColumn(audioRecordings, audioRecordings.contextKey);
      }
      if (from < 7) {
        await m.createTable(debateWorkspaces);
        await m.createTable(debateStages);
      }
      if (from < 8) {
        await m.createTable(impromptuQueues);
        await m.createTable(impromptuWorkspaces);
      }
      await m.createTable(customExercises);
      await m.createTable(practiceContexts);
      await m.createTable(recallSchedules);
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS one_open_segment ON timing_segments(session_id) WHERE ended_utc_ms IS NULL',
      );
    },
  );

  static Future<AppDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final path = '${directory.path}${Platform.pathSeparator}articulate.sqlite';
    final lock = await File('$path.lock').open(mode: FileMode.append);
    try {
      await lock.lock(FileLock.exclusive);
      return AppDatabase(NativeDatabase.createInBackground(File(path)))
        .._processLock = lock;
    } catch (_) {
      await lock.close();
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    try {
      await super.close();
    } finally {
      await _processLock?.close();
    }
  }
}
