// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PracticeSessionsTable extends PracticeSessions
    with TableInfo<$PracticeSessionsTable, PracticeSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseVersionMeta = const VerificationMeta(
    'exerciseVersion',
  );
  @override
  late final GeneratedColumn<int> exerciseVersion = GeneratedColumn<int>(
    'exercise_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleIdMeta = const VerificationMeta(
    'moduleId',
  );
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
    'module_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotMeta = const VerificationMeta(
    'snapshot',
  );
  @override
  late final GeneratedColumn<String> snapshot = GeneratedColumn<String>(
    'snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'draft\',\'running\',\'paused\',\'interrupted\',\'completed\',\'abandoned\'))',
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (stage IN (\'prepare\',\'respond\',\'reflect\'))',
  );
  static const VerificationMeta _createdUtcMsMeta = const VerificationMeta(
    'createdUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdUtcMs = GeneratedColumn<int>(
    'created_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedUtcMsMeta = const VerificationMeta(
    'updatedUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedUtcMs = GeneratedColumn<int>(
    'updated_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedUtcMsMeta = const VerificationMeta(
    'startedUtcMs',
  );
  @override
  late final GeneratedColumn<int> startedUtcMs = GeneratedColumn<int>(
    'started_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedUtcMsMeta = const VerificationMeta(
    'completedUtcMs',
  );
  @override
  late final GeneratedColumn<int> completedUtcMs = GeneratedColumn<int>(
    'completed_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPracticeDateMeta = const VerificationMeta(
    'localPracticeDate',
  );
  @override
  late final GeneratedColumn<String> localPracticeDate =
      GeneratedColumn<String>(
        'local_practice_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originalOffsetMinutesMeta =
      const VerificationMeta('originalOffsetMinutes');
  @override
  late final GeneratedColumn<int> originalOffsetMinutes = GeneratedColumn<int>(
    'original_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    exerciseVersion,
    moduleId,
    snapshot,
    status,
    stage,
    createdUtcMs,
    updatedUtcMs,
    startedUtcMs,
    completedUtcMs,
    localPracticeDate,
    originalOffsetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_version')) {
      context.handle(
        _exerciseVersionMeta,
        exerciseVersion.isAcceptableOrUnknown(
          data['exercise_version']!,
          _exerciseVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseVersionMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(
        _moduleIdMeta,
        moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('snapshot')) {
      context.handle(
        _snapshotMeta,
        snapshot.isAcceptableOrUnknown(data['snapshot']!, _snapshotMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('created_utc_ms')) {
      context.handle(
        _createdUtcMsMeta,
        createdUtcMs.isAcceptableOrUnknown(
          data['created_utc_ms']!,
          _createdUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMsMeta);
    }
    if (data.containsKey('updated_utc_ms')) {
      context.handle(
        _updatedUtcMsMeta,
        updatedUtcMs.isAcceptableOrUnknown(
          data['updated_utc_ms']!,
          _updatedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMsMeta);
    }
    if (data.containsKey('started_utc_ms')) {
      context.handle(
        _startedUtcMsMeta,
        startedUtcMs.isAcceptableOrUnknown(
          data['started_utc_ms']!,
          _startedUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('completed_utc_ms')) {
      context.handle(
        _completedUtcMsMeta,
        completedUtcMs.isAcceptableOrUnknown(
          data['completed_utc_ms']!,
          _completedUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('local_practice_date')) {
      context.handle(
        _localPracticeDateMeta,
        localPracticeDate.isAcceptableOrUnknown(
          data['local_practice_date']!,
          _localPracticeDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPracticeDateMeta);
    }
    if (data.containsKey('original_offset_minutes')) {
      context.handle(
        _originalOffsetMinutesMeta,
        originalOffsetMinutes.isAcceptableOrUnknown(
          data['original_offset_minutes']!,
          _originalOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalOffsetMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_version'],
      )!,
      moduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_id'],
      )!,
      snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      createdUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc_ms'],
      )!,
      updatedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc_ms'],
      )!,
      startedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_utc_ms'],
      ),
      completedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_utc_ms'],
      ),
      localPracticeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_practice_date'],
      )!,
      originalOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_offset_minutes'],
      )!,
    );
  }

  @override
  $PracticeSessionsTable createAlias(String alias) {
    return $PracticeSessionsTable(attachedDatabase, alias);
  }
}

class PracticeSession extends DataClass implements Insertable<PracticeSession> {
  final String id;
  final String exerciseId;
  final int exerciseVersion;
  final String moduleId;
  final String snapshot;
  final String status;
  final String stage;
  final int createdUtcMs;
  final int updatedUtcMs;
  final int? startedUtcMs;
  final int? completedUtcMs;
  final String localPracticeDate;
  final int originalOffsetMinutes;
  const PracticeSession({
    required this.id,
    required this.exerciseId,
    required this.exerciseVersion,
    required this.moduleId,
    required this.snapshot,
    required this.status,
    required this.stage,
    required this.createdUtcMs,
    required this.updatedUtcMs,
    this.startedUtcMs,
    this.completedUtcMs,
    required this.localPracticeDate,
    required this.originalOffsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['exercise_version'] = Variable<int>(exerciseVersion);
    map['module_id'] = Variable<String>(moduleId);
    map['snapshot'] = Variable<String>(snapshot);
    map['status'] = Variable<String>(status);
    map['stage'] = Variable<String>(stage);
    map['created_utc_ms'] = Variable<int>(createdUtcMs);
    map['updated_utc_ms'] = Variable<int>(updatedUtcMs);
    if (!nullToAbsent || startedUtcMs != null) {
      map['started_utc_ms'] = Variable<int>(startedUtcMs);
    }
    if (!nullToAbsent || completedUtcMs != null) {
      map['completed_utc_ms'] = Variable<int>(completedUtcMs);
    }
    map['local_practice_date'] = Variable<String>(localPracticeDate);
    map['original_offset_minutes'] = Variable<int>(originalOffsetMinutes);
    return map;
  }

  PracticeSessionsCompanion toCompanion(bool nullToAbsent) {
    return PracticeSessionsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      exerciseVersion: Value(exerciseVersion),
      moduleId: Value(moduleId),
      snapshot: Value(snapshot),
      status: Value(status),
      stage: Value(stage),
      createdUtcMs: Value(createdUtcMs),
      updatedUtcMs: Value(updatedUtcMs),
      startedUtcMs: startedUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(startedUtcMs),
      completedUtcMs: completedUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(completedUtcMs),
      localPracticeDate: Value(localPracticeDate),
      originalOffsetMinutes: Value(originalOffsetMinutes),
    );
  }

  factory PracticeSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeSession(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      exerciseVersion: serializer.fromJson<int>(json['exerciseVersion']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      snapshot: serializer.fromJson<String>(json['snapshot']),
      status: serializer.fromJson<String>(json['status']),
      stage: serializer.fromJson<String>(json['stage']),
      createdUtcMs: serializer.fromJson<int>(json['createdUtcMs']),
      updatedUtcMs: serializer.fromJson<int>(json['updatedUtcMs']),
      startedUtcMs: serializer.fromJson<int?>(json['startedUtcMs']),
      completedUtcMs: serializer.fromJson<int?>(json['completedUtcMs']),
      localPracticeDate: serializer.fromJson<String>(json['localPracticeDate']),
      originalOffsetMinutes: serializer.fromJson<int>(
        json['originalOffsetMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'exerciseVersion': serializer.toJson<int>(exerciseVersion),
      'moduleId': serializer.toJson<String>(moduleId),
      'snapshot': serializer.toJson<String>(snapshot),
      'status': serializer.toJson<String>(status),
      'stage': serializer.toJson<String>(stage),
      'createdUtcMs': serializer.toJson<int>(createdUtcMs),
      'updatedUtcMs': serializer.toJson<int>(updatedUtcMs),
      'startedUtcMs': serializer.toJson<int?>(startedUtcMs),
      'completedUtcMs': serializer.toJson<int?>(completedUtcMs),
      'localPracticeDate': serializer.toJson<String>(localPracticeDate),
      'originalOffsetMinutes': serializer.toJson<int>(originalOffsetMinutes),
    };
  }

  PracticeSession copyWith({
    String? id,
    String? exerciseId,
    int? exerciseVersion,
    String? moduleId,
    String? snapshot,
    String? status,
    String? stage,
    int? createdUtcMs,
    int? updatedUtcMs,
    Value<int?> startedUtcMs = const Value.absent(),
    Value<int?> completedUtcMs = const Value.absent(),
    String? localPracticeDate,
    int? originalOffsetMinutes,
  }) => PracticeSession(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseVersion: exerciseVersion ?? this.exerciseVersion,
    moduleId: moduleId ?? this.moduleId,
    snapshot: snapshot ?? this.snapshot,
    status: status ?? this.status,
    stage: stage ?? this.stage,
    createdUtcMs: createdUtcMs ?? this.createdUtcMs,
    updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
    startedUtcMs: startedUtcMs.present ? startedUtcMs.value : this.startedUtcMs,
    completedUtcMs: completedUtcMs.present
        ? completedUtcMs.value
        : this.completedUtcMs,
    localPracticeDate: localPracticeDate ?? this.localPracticeDate,
    originalOffsetMinutes: originalOffsetMinutes ?? this.originalOffsetMinutes,
  );
  PracticeSession copyWithCompanion(PracticeSessionsCompanion data) {
    return PracticeSession(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseVersion: data.exerciseVersion.present
          ? data.exerciseVersion.value
          : this.exerciseVersion,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
      status: data.status.present ? data.status.value : this.status,
      stage: data.stage.present ? data.stage.value : this.stage,
      createdUtcMs: data.createdUtcMs.present
          ? data.createdUtcMs.value
          : this.createdUtcMs,
      updatedUtcMs: data.updatedUtcMs.present
          ? data.updatedUtcMs.value
          : this.updatedUtcMs,
      startedUtcMs: data.startedUtcMs.present
          ? data.startedUtcMs.value
          : this.startedUtcMs,
      completedUtcMs: data.completedUtcMs.present
          ? data.completedUtcMs.value
          : this.completedUtcMs,
      localPracticeDate: data.localPracticeDate.present
          ? data.localPracticeDate.value
          : this.localPracticeDate,
      originalOffsetMinutes: data.originalOffsetMinutes.present
          ? data.originalOffsetMinutes.value
          : this.originalOffsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSession(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseVersion: $exerciseVersion, ')
          ..write('moduleId: $moduleId, ')
          ..write('snapshot: $snapshot, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('startedUtcMs: $startedUtcMs, ')
          ..write('completedUtcMs: $completedUtcMs, ')
          ..write('localPracticeDate: $localPracticeDate, ')
          ..write('originalOffsetMinutes: $originalOffsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    exerciseVersion,
    moduleId,
    snapshot,
    status,
    stage,
    createdUtcMs,
    updatedUtcMs,
    startedUtcMs,
    completedUtcMs,
    localPracticeDate,
    originalOffsetMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeSession &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.exerciseVersion == this.exerciseVersion &&
          other.moduleId == this.moduleId &&
          other.snapshot == this.snapshot &&
          other.status == this.status &&
          other.stage == this.stage &&
          other.createdUtcMs == this.createdUtcMs &&
          other.updatedUtcMs == this.updatedUtcMs &&
          other.startedUtcMs == this.startedUtcMs &&
          other.completedUtcMs == this.completedUtcMs &&
          other.localPracticeDate == this.localPracticeDate &&
          other.originalOffsetMinutes == this.originalOffsetMinutes);
}

class PracticeSessionsCompanion extends UpdateCompanion<PracticeSession> {
  final Value<String> id;
  final Value<String> exerciseId;
  final Value<int> exerciseVersion;
  final Value<String> moduleId;
  final Value<String> snapshot;
  final Value<String> status;
  final Value<String> stage;
  final Value<int> createdUtcMs;
  final Value<int> updatedUtcMs;
  final Value<int?> startedUtcMs;
  final Value<int?> completedUtcMs;
  final Value<String> localPracticeDate;
  final Value<int> originalOffsetMinutes;
  final Value<int> rowid;
  const PracticeSessionsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseVersion = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.status = const Value.absent(),
    this.stage = const Value.absent(),
    this.createdUtcMs = const Value.absent(),
    this.updatedUtcMs = const Value.absent(),
    this.startedUtcMs = const Value.absent(),
    this.completedUtcMs = const Value.absent(),
    this.localPracticeDate = const Value.absent(),
    this.originalOffsetMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeSessionsCompanion.insert({
    required String id,
    required String exerciseId,
    required int exerciseVersion,
    required String moduleId,
    required String snapshot,
    required String status,
    required String stage,
    required int createdUtcMs,
    required int updatedUtcMs,
    this.startedUtcMs = const Value.absent(),
    this.completedUtcMs = const Value.absent(),
    required String localPracticeDate,
    required int originalOffsetMinutes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       exerciseVersion = Value(exerciseVersion),
       moduleId = Value(moduleId),
       snapshot = Value(snapshot),
       status = Value(status),
       stage = Value(stage),
       createdUtcMs = Value(createdUtcMs),
       updatedUtcMs = Value(updatedUtcMs),
       localPracticeDate = Value(localPracticeDate),
       originalOffsetMinutes = Value(originalOffsetMinutes);
  static Insertable<PracticeSession> custom({
    Expression<String>? id,
    Expression<String>? exerciseId,
    Expression<int>? exerciseVersion,
    Expression<String>? moduleId,
    Expression<String>? snapshot,
    Expression<String>? status,
    Expression<String>? stage,
    Expression<int>? createdUtcMs,
    Expression<int>? updatedUtcMs,
    Expression<int>? startedUtcMs,
    Expression<int>? completedUtcMs,
    Expression<String>? localPracticeDate,
    Expression<int>? originalOffsetMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseVersion != null) 'exercise_version': exerciseVersion,
      if (moduleId != null) 'module_id': moduleId,
      if (snapshot != null) 'snapshot': snapshot,
      if (status != null) 'status': status,
      if (stage != null) 'stage': stage,
      if (createdUtcMs != null) 'created_utc_ms': createdUtcMs,
      if (updatedUtcMs != null) 'updated_utc_ms': updatedUtcMs,
      if (startedUtcMs != null) 'started_utc_ms': startedUtcMs,
      if (completedUtcMs != null) 'completed_utc_ms': completedUtcMs,
      if (localPracticeDate != null) 'local_practice_date': localPracticeDate,
      if (originalOffsetMinutes != null)
        'original_offset_minutes': originalOffsetMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseId,
    Value<int>? exerciseVersion,
    Value<String>? moduleId,
    Value<String>? snapshot,
    Value<String>? status,
    Value<String>? stage,
    Value<int>? createdUtcMs,
    Value<int>? updatedUtcMs,
    Value<int?>? startedUtcMs,
    Value<int?>? completedUtcMs,
    Value<String>? localPracticeDate,
    Value<int>? originalOffsetMinutes,
    Value<int>? rowid,
  }) {
    return PracticeSessionsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseVersion: exerciseVersion ?? this.exerciseVersion,
      moduleId: moduleId ?? this.moduleId,
      snapshot: snapshot ?? this.snapshot,
      status: status ?? this.status,
      stage: stage ?? this.stage,
      createdUtcMs: createdUtcMs ?? this.createdUtcMs,
      updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      startedUtcMs: startedUtcMs ?? this.startedUtcMs,
      completedUtcMs: completedUtcMs ?? this.completedUtcMs,
      localPracticeDate: localPracticeDate ?? this.localPracticeDate,
      originalOffsetMinutes:
          originalOffsetMinutes ?? this.originalOffsetMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseVersion.present) {
      map['exercise_version'] = Variable<int>(exerciseVersion.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(snapshot.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (createdUtcMs.present) {
      map['created_utc_ms'] = Variable<int>(createdUtcMs.value);
    }
    if (updatedUtcMs.present) {
      map['updated_utc_ms'] = Variable<int>(updatedUtcMs.value);
    }
    if (startedUtcMs.present) {
      map['started_utc_ms'] = Variable<int>(startedUtcMs.value);
    }
    if (completedUtcMs.present) {
      map['completed_utc_ms'] = Variable<int>(completedUtcMs.value);
    }
    if (localPracticeDate.present) {
      map['local_practice_date'] = Variable<String>(localPracticeDate.value);
    }
    if (originalOffsetMinutes.present) {
      map['original_offset_minutes'] = Variable<int>(
        originalOffsetMinutes.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeSessionsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseVersion: $exerciseVersion, ')
          ..write('moduleId: $moduleId, ')
          ..write('snapshot: $snapshot, ')
          ..write('status: $status, ')
          ..write('stage: $stage, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('startedUtcMs: $startedUtcMs, ')
          ..write('completedUtcMs: $completedUtcMs, ')
          ..write('localPracticeDate: $localPracticeDate, ')
          ..write('originalOffsetMinutes: $originalOffsetMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResponsesTable extends Responses
    with TableInfo<$ResponsesTable, Response> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedUtcMsMeta = const VerificationMeta(
    'updatedUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedUtcMs = GeneratedColumn<int>(
    'updated_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessionId, body, updatedUtcMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Response> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('updated_utc_ms')) {
      context.handle(
        _updatedUtcMsMeta,
        updatedUtcMs.isAcceptableOrUnknown(
          data['updated_utc_ms']!,
          _updatedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Response map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Response(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      updatedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc_ms'],
      )!,
    );
  }

  @override
  $ResponsesTable createAlias(String alias) {
    return $ResponsesTable(attachedDatabase, alias);
  }
}

class Response extends DataClass implements Insertable<Response> {
  final String id;
  final String sessionId;
  final String body;
  final int updatedUtcMs;
  const Response({
    required this.id,
    required this.sessionId,
    required this.body,
    required this.updatedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['body'] = Variable<String>(body);
    map['updated_utc_ms'] = Variable<int>(updatedUtcMs);
    return map;
  }

  ResponsesCompanion toCompanion(bool nullToAbsent) {
    return ResponsesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      body: Value(body),
      updatedUtcMs: Value(updatedUtcMs),
    );
  }

  factory Response.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Response(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      body: serializer.fromJson<String>(json['body']),
      updatedUtcMs: serializer.fromJson<int>(json['updatedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'body': serializer.toJson<String>(body),
      'updatedUtcMs': serializer.toJson<int>(updatedUtcMs),
    };
  }

  Response copyWith({
    String? id,
    String? sessionId,
    String? body,
    int? updatedUtcMs,
  }) => Response(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    body: body ?? this.body,
    updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
  );
  Response copyWithCompanion(ResponsesCompanion data) {
    return Response(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      body: data.body.present ? data.body.value : this.body,
      updatedUtcMs: data.updatedUtcMs.present
          ? data.updatedUtcMs.value
          : this.updatedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Response(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('body: $body, ')
          ..write('updatedUtcMs: $updatedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, body, updatedUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Response &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.body == this.body &&
          other.updatedUtcMs == this.updatedUtcMs);
}

class ResponsesCompanion extends UpdateCompanion<Response> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> body;
  final Value<int> updatedUtcMs;
  final Value<int> rowid;
  const ResponsesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.body = const Value.absent(),
    this.updatedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResponsesCompanion.insert({
    required String id,
    required String sessionId,
    this.body = const Value.absent(),
    required int updatedUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       updatedUtcMs = Value(updatedUtcMs);
  static Insertable<Response> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? body,
    Expression<int>? updatedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (body != null) 'body': body,
      if (updatedUtcMs != null) 'updated_utc_ms': updatedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResponsesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? body,
    Value<int>? updatedUtcMs,
    Value<int>? rowid,
  }) {
    return ResponsesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      body: body ?? this.body,
      updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (updatedUtcMs.present) {
      map['updated_utc_ms'] = Variable<int>(updatedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResponsesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('body: $body, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimingSegmentsTable extends TimingSegments
    with TableInfo<$TimingSegmentsTable, TimingSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimingSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedUtcMsMeta = const VerificationMeta(
    'startedUtcMs',
  );
  @override
  late final GeneratedColumn<int> startedUtcMs = GeneratedColumn<int>(
    'started_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkpointUtcMsMeta = const VerificationMeta(
    'checkpointUtcMs',
  );
  @override
  late final GeneratedColumn<int> checkpointUtcMs = GeneratedColumn<int>(
    'checkpoint_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedUtcMsMeta = const VerificationMeta(
    'endedUtcMs',
  );
  @override
  late final GeneratedColumn<int> endedUtcMs = GeneratedColumn<int>(
    'ended_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (elapsed_ms >= 0)',
  );
  static const VerificationMeta _endReasonMeta = const VerificationMeta(
    'endReason',
  );
  @override
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
    'end_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    stage,
    startedUtcMs,
    checkpointUtcMs,
    endedUtcMs,
    elapsedMs,
    endReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timing_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimingSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('started_utc_ms')) {
      context.handle(
        _startedUtcMsMeta,
        startedUtcMs.isAcceptableOrUnknown(
          data['started_utc_ms']!,
          _startedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedUtcMsMeta);
    }
    if (data.containsKey('checkpoint_utc_ms')) {
      context.handle(
        _checkpointUtcMsMeta,
        checkpointUtcMs.isAcceptableOrUnknown(
          data['checkpoint_utc_ms']!,
          _checkpointUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkpointUtcMsMeta);
    }
    if (data.containsKey('ended_utc_ms')) {
      context.handle(
        _endedUtcMsMeta,
        endedUtcMs.isAcceptableOrUnknown(
          data['ended_utc_ms']!,
          _endedUtcMsMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('end_reason')) {
      context.handle(
        _endReasonMeta,
        endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimingSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimingSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      startedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_utc_ms'],
      )!,
      checkpointUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}checkpoint_utc_ms'],
      )!,
      endedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_utc_ms'],
      ),
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      endReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_reason'],
      ),
    );
  }

  @override
  $TimingSegmentsTable createAlias(String alias) {
    return $TimingSegmentsTable(attachedDatabase, alias);
  }
}

class TimingSegment extends DataClass implements Insertable<TimingSegment> {
  final String id;
  final String sessionId;
  final String stage;
  final int startedUtcMs;
  final int checkpointUtcMs;
  final int? endedUtcMs;
  final int elapsedMs;
  final String? endReason;
  const TimingSegment({
    required this.id,
    required this.sessionId,
    required this.stage,
    required this.startedUtcMs,
    required this.checkpointUtcMs,
    this.endedUtcMs,
    required this.elapsedMs,
    this.endReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['stage'] = Variable<String>(stage);
    map['started_utc_ms'] = Variable<int>(startedUtcMs);
    map['checkpoint_utc_ms'] = Variable<int>(checkpointUtcMs);
    if (!nullToAbsent || endedUtcMs != null) {
      map['ended_utc_ms'] = Variable<int>(endedUtcMs);
    }
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    return map;
  }

  TimingSegmentsCompanion toCompanion(bool nullToAbsent) {
    return TimingSegmentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      stage: Value(stage),
      startedUtcMs: Value(startedUtcMs),
      checkpointUtcMs: Value(checkpointUtcMs),
      endedUtcMs: endedUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endedUtcMs),
      elapsedMs: Value(elapsedMs),
      endReason: endReason == null && nullToAbsent
          ? const Value.absent()
          : Value(endReason),
    );
  }

  factory TimingSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimingSegment(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      stage: serializer.fromJson<String>(json['stage']),
      startedUtcMs: serializer.fromJson<int>(json['startedUtcMs']),
      checkpointUtcMs: serializer.fromJson<int>(json['checkpointUtcMs']),
      endedUtcMs: serializer.fromJson<int?>(json['endedUtcMs']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      endReason: serializer.fromJson<String?>(json['endReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'stage': serializer.toJson<String>(stage),
      'startedUtcMs': serializer.toJson<int>(startedUtcMs),
      'checkpointUtcMs': serializer.toJson<int>(checkpointUtcMs),
      'endedUtcMs': serializer.toJson<int?>(endedUtcMs),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'endReason': serializer.toJson<String?>(endReason),
    };
  }

  TimingSegment copyWith({
    String? id,
    String? sessionId,
    String? stage,
    int? startedUtcMs,
    int? checkpointUtcMs,
    Value<int?> endedUtcMs = const Value.absent(),
    int? elapsedMs,
    Value<String?> endReason = const Value.absent(),
  }) => TimingSegment(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    stage: stage ?? this.stage,
    startedUtcMs: startedUtcMs ?? this.startedUtcMs,
    checkpointUtcMs: checkpointUtcMs ?? this.checkpointUtcMs,
    endedUtcMs: endedUtcMs.present ? endedUtcMs.value : this.endedUtcMs,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    endReason: endReason.present ? endReason.value : this.endReason,
  );
  TimingSegment copyWithCompanion(TimingSegmentsCompanion data) {
    return TimingSegment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      stage: data.stage.present ? data.stage.value : this.stage,
      startedUtcMs: data.startedUtcMs.present
          ? data.startedUtcMs.value
          : this.startedUtcMs,
      checkpointUtcMs: data.checkpointUtcMs.present
          ? data.checkpointUtcMs.value
          : this.checkpointUtcMs,
      endedUtcMs: data.endedUtcMs.present
          ? data.endedUtcMs.value
          : this.endedUtcMs,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimingSegment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('stage: $stage, ')
          ..write('startedUtcMs: $startedUtcMs, ')
          ..write('checkpointUtcMs: $checkpointUtcMs, ')
          ..write('endedUtcMs: $endedUtcMs, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('endReason: $endReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    stage,
    startedUtcMs,
    checkpointUtcMs,
    endedUtcMs,
    elapsedMs,
    endReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimingSegment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.stage == this.stage &&
          other.startedUtcMs == this.startedUtcMs &&
          other.checkpointUtcMs == this.checkpointUtcMs &&
          other.endedUtcMs == this.endedUtcMs &&
          other.elapsedMs == this.elapsedMs &&
          other.endReason == this.endReason);
}

class TimingSegmentsCompanion extends UpdateCompanion<TimingSegment> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> stage;
  final Value<int> startedUtcMs;
  final Value<int> checkpointUtcMs;
  final Value<int?> endedUtcMs;
  final Value<int> elapsedMs;
  final Value<String?> endReason;
  final Value<int> rowid;
  const TimingSegmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.stage = const Value.absent(),
    this.startedUtcMs = const Value.absent(),
    this.checkpointUtcMs = const Value.absent(),
    this.endedUtcMs = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.endReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimingSegmentsCompanion.insert({
    required String id,
    required String sessionId,
    required String stage,
    required int startedUtcMs,
    required int checkpointUtcMs,
    this.endedUtcMs = const Value.absent(),
    required int elapsedMs,
    this.endReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       stage = Value(stage),
       startedUtcMs = Value(startedUtcMs),
       checkpointUtcMs = Value(checkpointUtcMs),
       elapsedMs = Value(elapsedMs);
  static Insertable<TimingSegment> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? stage,
    Expression<int>? startedUtcMs,
    Expression<int>? checkpointUtcMs,
    Expression<int>? endedUtcMs,
    Expression<int>? elapsedMs,
    Expression<String>? endReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (stage != null) 'stage': stage,
      if (startedUtcMs != null) 'started_utc_ms': startedUtcMs,
      if (checkpointUtcMs != null) 'checkpoint_utc_ms': checkpointUtcMs,
      if (endedUtcMs != null) 'ended_utc_ms': endedUtcMs,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (endReason != null) 'end_reason': endReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimingSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? stage,
    Value<int>? startedUtcMs,
    Value<int>? checkpointUtcMs,
    Value<int?>? endedUtcMs,
    Value<int>? elapsedMs,
    Value<String?>? endReason,
    Value<int>? rowid,
  }) {
    return TimingSegmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      stage: stage ?? this.stage,
      startedUtcMs: startedUtcMs ?? this.startedUtcMs,
      checkpointUtcMs: checkpointUtcMs ?? this.checkpointUtcMs,
      endedUtcMs: endedUtcMs ?? this.endedUtcMs,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      endReason: endReason ?? this.endReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (startedUtcMs.present) {
      map['started_utc_ms'] = Variable<int>(startedUtcMs.value);
    }
    if (checkpointUtcMs.present) {
      map['checkpoint_utc_ms'] = Variable<int>(checkpointUtcMs.value);
    }
    if (endedUtcMs.present) {
      map['ended_utc_ms'] = Variable<int>(endedUtcMs.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimingSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('stage: $stage, ')
          ..write('startedUtcMs: $startedUtcMs, ')
          ..write('checkpointUtcMs: $checkpointUtcMs, ')
          ..write('endedUtcMs: $endedUtcMs, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('endReason: $endReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewRecordsTable extends ReviewRecords
    with TableInfo<$ReviewRecordsTable, ReviewRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'inProgress\',\'reviewed\'))',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedUtcMsMeta = const VerificationMeta(
    'updatedUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedUtcMs = GeneratedColumn<int>(
    'updated_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    status,
    notes,
    updatedUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('updated_utc_ms')) {
      context.handle(
        _updatedUtcMsMeta,
        updatedUtcMs.isAcceptableOrUnknown(
          data['updated_utc_ms']!,
          _updatedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      updatedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc_ms'],
      )!,
    );
  }

  @override
  $ReviewRecordsTable createAlias(String alias) {
    return $ReviewRecordsTable(attachedDatabase, alias);
  }
}

class ReviewRecord extends DataClass implements Insertable<ReviewRecord> {
  final String id;
  final String sessionId;
  final String status;
  final String notes;
  final int updatedUtcMs;
  const ReviewRecord({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.notes,
    required this.updatedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['status'] = Variable<String>(status);
    map['notes'] = Variable<String>(notes);
    map['updated_utc_ms'] = Variable<int>(updatedUtcMs);
    return map;
  }

  ReviewRecordsCompanion toCompanion(bool nullToAbsent) {
    return ReviewRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      status: Value(status),
      notes: Value(notes),
      updatedUtcMs: Value(updatedUtcMs),
    );
  }

  factory ReviewRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewRecord(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String>(json['notes']),
      updatedUtcMs: serializer.fromJson<int>(json['updatedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String>(notes),
      'updatedUtcMs': serializer.toJson<int>(updatedUtcMs),
    };
  }

  ReviewRecord copyWith({
    String? id,
    String? sessionId,
    String? status,
    String? notes,
    int? updatedUtcMs,
  }) => ReviewRecord(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
  );
  ReviewRecord copyWithCompanion(ReviewRecordsCompanion data) {
    return ReviewRecord(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedUtcMs: data.updatedUtcMs.present
          ? data.updatedUtcMs.value
          : this.updatedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRecord(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('updatedUtcMs: $updatedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, status, notes, updatedUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewRecord &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.updatedUtcMs == this.updatedUtcMs);
}

class ReviewRecordsCompanion extends UpdateCompanion<ReviewRecord> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> status;
  final Value<String> notes;
  final Value<int> updatedUtcMs;
  final Value<int> rowid;
  const ReviewRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewRecordsCompanion.insert({
    required String id,
    required String sessionId,
    required String status,
    required String notes,
    required int updatedUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       status = Value(status),
       notes = Value(notes),
       updatedUtcMs = Value(updatedUtcMs);
  static Insertable<ReviewRecord> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<int>? updatedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (updatedUtcMs != null) 'updated_utc_ms': updatedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? status,
    Value<String>? notes,
    Value<int>? updatedUtcMs,
    Value<int>? rowid,
  }) {
    return ReviewRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedUtcMs.present) {
      map['updated_utc_ms'] = Variable<int>(updatedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WritingWorkspacesTable extends WritingWorkspaces
    with TableInfo<$WritingWorkspacesTable, WritingWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WritingWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _rootSessionIdMeta = const VerificationMeta(
    'rootSessionId',
  );
  @override
  late final GeneratedColumn<String> rootSessionId = GeneratedColumn<String>(
    'root_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _parentSessionIdMeta = const VerificationMeta(
    'parentSessionId',
  );
  @override
  late final GeneratedColumn<String> parentSessionId = GeneratedColumn<String>(
    'parent_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _versionNumberMeta = const VerificationMeta(
    'versionNumber',
  );
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
    'version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outlineMeta = const VerificationMeta(
    'outline',
  );
  @override
  late final GeneratedColumn<String> outline = GeneratedColumn<String>(
    'outline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _audienceMeta = const VerificationMeta(
    'audience',
  );
  @override
  late final GeneratedColumn<String> audience = GeneratedColumn<String>(
    'audience',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewStepMeta = const VerificationMeta(
    'viewStep',
  );
  @override
  late final GeneratedColumn<String> viewStep = GeneratedColumn<String>(
    'view_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('brief'),
  );
  static const VerificationMeta _assessmentsMeta = const VerificationMeta(
    'assessments',
  );
  @override
  late final GeneratedColumn<String> assessments = GeneratedColumn<String>(
    'assessments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _reviewRubricMeta = const VerificationMeta(
    'reviewRubric',
  );
  @override
  late final GeneratedColumn<String> reviewRubric = GeneratedColumn<String>(
    'review_rubric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legacyReviewNotesMeta = const VerificationMeta(
    'legacyReviewNotes',
  );
  @override
  late final GeneratedColumn<String> legacyReviewNotes =
      GeneratedColumn<String>(
        'legacy_review_notes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedUtcMsMeta = const VerificationMeta(
    'updatedUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedUtcMs = GeneratedColumn<int>(
    'updated_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    rootSessionId,
    parentSessionId,
    versionNumber,
    outline,
    audience,
    purpose,
    viewStep,
    assessments,
    reviewRubric,
    legacyReviewNotes,
    nextAction,
    updatedUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'writing_workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<WritingWorkspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('root_session_id')) {
      context.handle(
        _rootSessionIdMeta,
        rootSessionId.isAcceptableOrUnknown(
          data['root_session_id']!,
          _rootSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootSessionIdMeta);
    }
    if (data.containsKey('parent_session_id')) {
      context.handle(
        _parentSessionIdMeta,
        parentSessionId.isAcceptableOrUnknown(
          data['parent_session_id']!,
          _parentSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('version_number')) {
      context.handle(
        _versionNumberMeta,
        versionNumber.isAcceptableOrUnknown(
          data['version_number']!,
          _versionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionNumberMeta);
    }
    if (data.containsKey('outline')) {
      context.handle(
        _outlineMeta,
        outline.isAcceptableOrUnknown(data['outline']!, _outlineMeta),
      );
    }
    if (data.containsKey('audience')) {
      context.handle(
        _audienceMeta,
        audience.isAcceptableOrUnknown(data['audience']!, _audienceMeta),
      );
    } else if (isInserting) {
      context.missing(_audienceMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('view_step')) {
      context.handle(
        _viewStepMeta,
        viewStep.isAcceptableOrUnknown(data['view_step']!, _viewStepMeta),
      );
    }
    if (data.containsKey('assessments')) {
      context.handle(
        _assessmentsMeta,
        assessments.isAcceptableOrUnknown(
          data['assessments']!,
          _assessmentsMeta,
        ),
      );
    }
    if (data.containsKey('review_rubric')) {
      context.handle(
        _reviewRubricMeta,
        reviewRubric.isAcceptableOrUnknown(
          data['review_rubric']!,
          _reviewRubricMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewRubricMeta);
    }
    if (data.containsKey('legacy_review_notes')) {
      context.handle(
        _legacyReviewNotesMeta,
        legacyReviewNotes.isAcceptableOrUnknown(
          data['legacy_review_notes']!,
          _legacyReviewNotesMeta,
        ),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('updated_utc_ms')) {
      context.handle(
        _updatedUtcMsMeta,
        updatedUtcMs.isAcceptableOrUnknown(
          data['updated_utc_ms']!,
          _updatedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rootSessionId, versionNumber},
  ];
  @override
  WritingWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WritingWorkspace(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      rootSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_session_id'],
      )!,
      parentSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_session_id'],
      ),
      versionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_number'],
      )!,
      outline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outline'],
      )!,
      audience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      viewStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_step'],
      )!,
      assessments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessments'],
      )!,
      reviewRubric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_rubric'],
      )!,
      legacyReviewNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_review_notes'],
      )!,
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      )!,
      updatedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc_ms'],
      )!,
    );
  }

  @override
  $WritingWorkspacesTable createAlias(String alias) {
    return $WritingWorkspacesTable(attachedDatabase, alias);
  }
}

class WritingWorkspace extends DataClass
    implements Insertable<WritingWorkspace> {
  final String sessionId;
  final String rootSessionId;
  final String? parentSessionId;
  final int versionNumber;
  final String outline;
  final String audience;
  final String purpose;
  final String viewStep;
  final String assessments;
  final String reviewRubric;
  final String legacyReviewNotes;
  final String nextAction;
  final int updatedUtcMs;
  const WritingWorkspace({
    required this.sessionId,
    required this.rootSessionId,
    this.parentSessionId,
    required this.versionNumber,
    required this.outline,
    required this.audience,
    required this.purpose,
    required this.viewStep,
    required this.assessments,
    required this.reviewRubric,
    required this.legacyReviewNotes,
    required this.nextAction,
    required this.updatedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['root_session_id'] = Variable<String>(rootSessionId);
    if (!nullToAbsent || parentSessionId != null) {
      map['parent_session_id'] = Variable<String>(parentSessionId);
    }
    map['version_number'] = Variable<int>(versionNumber);
    map['outline'] = Variable<String>(outline);
    map['audience'] = Variable<String>(audience);
    map['purpose'] = Variable<String>(purpose);
    map['view_step'] = Variable<String>(viewStep);
    map['assessments'] = Variable<String>(assessments);
    map['review_rubric'] = Variable<String>(reviewRubric);
    map['legacy_review_notes'] = Variable<String>(legacyReviewNotes);
    map['next_action'] = Variable<String>(nextAction);
    map['updated_utc_ms'] = Variable<int>(updatedUtcMs);
    return map;
  }

  WritingWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WritingWorkspacesCompanion(
      sessionId: Value(sessionId),
      rootSessionId: Value(rootSessionId),
      parentSessionId: parentSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentSessionId),
      versionNumber: Value(versionNumber),
      outline: Value(outline),
      audience: Value(audience),
      purpose: Value(purpose),
      viewStep: Value(viewStep),
      assessments: Value(assessments),
      reviewRubric: Value(reviewRubric),
      legacyReviewNotes: Value(legacyReviewNotes),
      nextAction: Value(nextAction),
      updatedUtcMs: Value(updatedUtcMs),
    );
  }

  factory WritingWorkspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WritingWorkspace(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      rootSessionId: serializer.fromJson<String>(json['rootSessionId']),
      parentSessionId: serializer.fromJson<String?>(json['parentSessionId']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      outline: serializer.fromJson<String>(json['outline']),
      audience: serializer.fromJson<String>(json['audience']),
      purpose: serializer.fromJson<String>(json['purpose']),
      viewStep: serializer.fromJson<String>(json['viewStep']),
      assessments: serializer.fromJson<String>(json['assessments']),
      reviewRubric: serializer.fromJson<String>(json['reviewRubric']),
      legacyReviewNotes: serializer.fromJson<String>(json['legacyReviewNotes']),
      nextAction: serializer.fromJson<String>(json['nextAction']),
      updatedUtcMs: serializer.fromJson<int>(json['updatedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'rootSessionId': serializer.toJson<String>(rootSessionId),
      'parentSessionId': serializer.toJson<String?>(parentSessionId),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'outline': serializer.toJson<String>(outline),
      'audience': serializer.toJson<String>(audience),
      'purpose': serializer.toJson<String>(purpose),
      'viewStep': serializer.toJson<String>(viewStep),
      'assessments': serializer.toJson<String>(assessments),
      'reviewRubric': serializer.toJson<String>(reviewRubric),
      'legacyReviewNotes': serializer.toJson<String>(legacyReviewNotes),
      'nextAction': serializer.toJson<String>(nextAction),
      'updatedUtcMs': serializer.toJson<int>(updatedUtcMs),
    };
  }

  WritingWorkspace copyWith({
    String? sessionId,
    String? rootSessionId,
    Value<String?> parentSessionId = const Value.absent(),
    int? versionNumber,
    String? outline,
    String? audience,
    String? purpose,
    String? viewStep,
    String? assessments,
    String? reviewRubric,
    String? legacyReviewNotes,
    String? nextAction,
    int? updatedUtcMs,
  }) => WritingWorkspace(
    sessionId: sessionId ?? this.sessionId,
    rootSessionId: rootSessionId ?? this.rootSessionId,
    parentSessionId: parentSessionId.present
        ? parentSessionId.value
        : this.parentSessionId,
    versionNumber: versionNumber ?? this.versionNumber,
    outline: outline ?? this.outline,
    audience: audience ?? this.audience,
    purpose: purpose ?? this.purpose,
    viewStep: viewStep ?? this.viewStep,
    assessments: assessments ?? this.assessments,
    reviewRubric: reviewRubric ?? this.reviewRubric,
    legacyReviewNotes: legacyReviewNotes ?? this.legacyReviewNotes,
    nextAction: nextAction ?? this.nextAction,
    updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
  );
  WritingWorkspace copyWithCompanion(WritingWorkspacesCompanion data) {
    return WritingWorkspace(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      rootSessionId: data.rootSessionId.present
          ? data.rootSessionId.value
          : this.rootSessionId,
      parentSessionId: data.parentSessionId.present
          ? data.parentSessionId.value
          : this.parentSessionId,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      outline: data.outline.present ? data.outline.value : this.outline,
      audience: data.audience.present ? data.audience.value : this.audience,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      viewStep: data.viewStep.present ? data.viewStep.value : this.viewStep,
      assessments: data.assessments.present
          ? data.assessments.value
          : this.assessments,
      reviewRubric: data.reviewRubric.present
          ? data.reviewRubric.value
          : this.reviewRubric,
      legacyReviewNotes: data.legacyReviewNotes.present
          ? data.legacyReviewNotes.value
          : this.legacyReviewNotes,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      updatedUtcMs: data.updatedUtcMs.present
          ? data.updatedUtcMs.value
          : this.updatedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WritingWorkspace(')
          ..write('sessionId: $sessionId, ')
          ..write('rootSessionId: $rootSessionId, ')
          ..write('parentSessionId: $parentSessionId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('outline: $outline, ')
          ..write('audience: $audience, ')
          ..write('purpose: $purpose, ')
          ..write('viewStep: $viewStep, ')
          ..write('assessments: $assessments, ')
          ..write('reviewRubric: $reviewRubric, ')
          ..write('legacyReviewNotes: $legacyReviewNotes, ')
          ..write('nextAction: $nextAction, ')
          ..write('updatedUtcMs: $updatedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    rootSessionId,
    parentSessionId,
    versionNumber,
    outline,
    audience,
    purpose,
    viewStep,
    assessments,
    reviewRubric,
    legacyReviewNotes,
    nextAction,
    updatedUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WritingWorkspace &&
          other.sessionId == this.sessionId &&
          other.rootSessionId == this.rootSessionId &&
          other.parentSessionId == this.parentSessionId &&
          other.versionNumber == this.versionNumber &&
          other.outline == this.outline &&
          other.audience == this.audience &&
          other.purpose == this.purpose &&
          other.viewStep == this.viewStep &&
          other.assessments == this.assessments &&
          other.reviewRubric == this.reviewRubric &&
          other.legacyReviewNotes == this.legacyReviewNotes &&
          other.nextAction == this.nextAction &&
          other.updatedUtcMs == this.updatedUtcMs);
}

class WritingWorkspacesCompanion extends UpdateCompanion<WritingWorkspace> {
  final Value<String> sessionId;
  final Value<String> rootSessionId;
  final Value<String?> parentSessionId;
  final Value<int> versionNumber;
  final Value<String> outline;
  final Value<String> audience;
  final Value<String> purpose;
  final Value<String> viewStep;
  final Value<String> assessments;
  final Value<String> reviewRubric;
  final Value<String> legacyReviewNotes;
  final Value<String> nextAction;
  final Value<int> updatedUtcMs;
  final Value<int> rowid;
  const WritingWorkspacesCompanion({
    this.sessionId = const Value.absent(),
    this.rootSessionId = const Value.absent(),
    this.parentSessionId = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.outline = const Value.absent(),
    this.audience = const Value.absent(),
    this.purpose = const Value.absent(),
    this.viewStep = const Value.absent(),
    this.assessments = const Value.absent(),
    this.reviewRubric = const Value.absent(),
    this.legacyReviewNotes = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.updatedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WritingWorkspacesCompanion.insert({
    required String sessionId,
    required String rootSessionId,
    this.parentSessionId = const Value.absent(),
    required int versionNumber,
    this.outline = const Value.absent(),
    required String audience,
    required String purpose,
    this.viewStep = const Value.absent(),
    this.assessments = const Value.absent(),
    required String reviewRubric,
    this.legacyReviewNotes = const Value.absent(),
    this.nextAction = const Value.absent(),
    required int updatedUtcMs,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       rootSessionId = Value(rootSessionId),
       versionNumber = Value(versionNumber),
       audience = Value(audience),
       purpose = Value(purpose),
       reviewRubric = Value(reviewRubric),
       updatedUtcMs = Value(updatedUtcMs);
  static Insertable<WritingWorkspace> custom({
    Expression<String>? sessionId,
    Expression<String>? rootSessionId,
    Expression<String>? parentSessionId,
    Expression<int>? versionNumber,
    Expression<String>? outline,
    Expression<String>? audience,
    Expression<String>? purpose,
    Expression<String>? viewStep,
    Expression<String>? assessments,
    Expression<String>? reviewRubric,
    Expression<String>? legacyReviewNotes,
    Expression<String>? nextAction,
    Expression<int>? updatedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (rootSessionId != null) 'root_session_id': rootSessionId,
      if (parentSessionId != null) 'parent_session_id': parentSessionId,
      if (versionNumber != null) 'version_number': versionNumber,
      if (outline != null) 'outline': outline,
      if (audience != null) 'audience': audience,
      if (purpose != null) 'purpose': purpose,
      if (viewStep != null) 'view_step': viewStep,
      if (assessments != null) 'assessments': assessments,
      if (reviewRubric != null) 'review_rubric': reviewRubric,
      if (legacyReviewNotes != null) 'legacy_review_notes': legacyReviewNotes,
      if (nextAction != null) 'next_action': nextAction,
      if (updatedUtcMs != null) 'updated_utc_ms': updatedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WritingWorkspacesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? rootSessionId,
    Value<String?>? parentSessionId,
    Value<int>? versionNumber,
    Value<String>? outline,
    Value<String>? audience,
    Value<String>? purpose,
    Value<String>? viewStep,
    Value<String>? assessments,
    Value<String>? reviewRubric,
    Value<String>? legacyReviewNotes,
    Value<String>? nextAction,
    Value<int>? updatedUtcMs,
    Value<int>? rowid,
  }) {
    return WritingWorkspacesCompanion(
      sessionId: sessionId ?? this.sessionId,
      rootSessionId: rootSessionId ?? this.rootSessionId,
      parentSessionId: parentSessionId ?? this.parentSessionId,
      versionNumber: versionNumber ?? this.versionNumber,
      outline: outline ?? this.outline,
      audience: audience ?? this.audience,
      purpose: purpose ?? this.purpose,
      viewStep: viewStep ?? this.viewStep,
      assessments: assessments ?? this.assessments,
      reviewRubric: reviewRubric ?? this.reviewRubric,
      legacyReviewNotes: legacyReviewNotes ?? this.legacyReviewNotes,
      nextAction: nextAction ?? this.nextAction,
      updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (rootSessionId.present) {
      map['root_session_id'] = Variable<String>(rootSessionId.value);
    }
    if (parentSessionId.present) {
      map['parent_session_id'] = Variable<String>(parentSessionId.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (outline.present) {
      map['outline'] = Variable<String>(outline.value);
    }
    if (audience.present) {
      map['audience'] = Variable<String>(audience.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (viewStep.present) {
      map['view_step'] = Variable<String>(viewStep.value);
    }
    if (assessments.present) {
      map['assessments'] = Variable<String>(assessments.value);
    }
    if (reviewRubric.present) {
      map['review_rubric'] = Variable<String>(reviewRubric.value);
    }
    if (legacyReviewNotes.present) {
      map['legacy_review_notes'] = Variable<String>(legacyReviewNotes.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (updatedUtcMs.present) {
      map['updated_utc_ms'] = Variable<int>(updatedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WritingWorkspacesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('rootSessionId: $rootSessionId, ')
          ..write('parentSessionId: $parentSessionId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('outline: $outline, ')
          ..write('audience: $audience, ')
          ..write('purpose: $purpose, ')
          ..write('viewStep: $viewStep, ')
          ..write('assessments: $assessments, ')
          ..write('reviewRubric: $reviewRubric, ')
          ..write('legacyReviewNotes: $legacyReviewNotes, ')
          ..write('nextAction: $nextAction, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingWorkspacesTable extends ReadingWorkspaces
    with TableInfo<$ReadingWorkspacesTable, ReadingWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _keyResultsMeta = const VerificationMeta(
    'keyResults',
  );
  @override
  late final GeneratedColumn<String> keyResults = GeneratedColumn<String>(
    'key_results',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionAnswersMeta = const VerificationMeta(
    'revisionAnswers',
  );
  @override
  late final GeneratedColumn<String> revisionAnswers = GeneratedColumn<String>(
    'revision_answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _ratingsMeta = const VerificationMeta(
    'ratings',
  );
  @override
  late final GeneratedColumn<String> ratings = GeneratedColumn<String>(
    'ratings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _viewStepMeta = const VerificationMeta(
    'viewStep',
  );
  @override
  late final GeneratedColumn<String> viewStep = GeneratedColumn<String>(
    'view_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('passage'),
  );
  static const VerificationMeta _hidePassageMeta = const VerificationMeta(
    'hidePassage',
  );
  @override
  late final GeneratedColumn<bool> hidePassage = GeneratedColumn<bool>(
    'hide_passage',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_passage" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedUtcMsMeta = const VerificationMeta(
    'updatedUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedUtcMs = GeneratedColumn<int>(
    'updated_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    keyResults,
    revisionAnswers,
    ratings,
    viewStep,
    hidePassage,
    updatedUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingWorkspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('key_results')) {
      context.handle(
        _keyResultsMeta,
        keyResults.isAcceptableOrUnknown(data['key_results']!, _keyResultsMeta),
      );
    }
    if (data.containsKey('revision_answers')) {
      context.handle(
        _revisionAnswersMeta,
        revisionAnswers.isAcceptableOrUnknown(
          data['revision_answers']!,
          _revisionAnswersMeta,
        ),
      );
    }
    if (data.containsKey('ratings')) {
      context.handle(
        _ratingsMeta,
        ratings.isAcceptableOrUnknown(data['ratings']!, _ratingsMeta),
      );
    }
    if (data.containsKey('view_step')) {
      context.handle(
        _viewStepMeta,
        viewStep.isAcceptableOrUnknown(data['view_step']!, _viewStepMeta),
      );
    }
    if (data.containsKey('hide_passage')) {
      context.handle(
        _hidePassageMeta,
        hidePassage.isAcceptableOrUnknown(
          data['hide_passage']!,
          _hidePassageMeta,
        ),
      );
    }
    if (data.containsKey('updated_utc_ms')) {
      context.handle(
        _updatedUtcMsMeta,
        updatedUtcMs.isAcceptableOrUnknown(
          data['updated_utc_ms']!,
          _updatedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  ReadingWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingWorkspace(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      keyResults: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_results'],
      ),
      revisionAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_answers'],
      )!,
      ratings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ratings'],
      )!,
      viewStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_step'],
      )!,
      hidePassage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_passage'],
      )!,
      updatedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc_ms'],
      )!,
    );
  }

  @override
  $ReadingWorkspacesTable createAlias(String alias) {
    return $ReadingWorkspacesTable(attachedDatabase, alias);
  }
}

class ReadingWorkspace extends DataClass
    implements Insertable<ReadingWorkspace> {
  final String sessionId;
  final String? keyResults;
  final String revisionAnswers;
  final String ratings;
  final String viewStep;
  final bool hidePassage;
  final int updatedUtcMs;
  const ReadingWorkspace({
    required this.sessionId,
    this.keyResults,
    required this.revisionAnswers,
    required this.ratings,
    required this.viewStep,
    required this.hidePassage,
    required this.updatedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || keyResults != null) {
      map['key_results'] = Variable<String>(keyResults);
    }
    map['revision_answers'] = Variable<String>(revisionAnswers);
    map['ratings'] = Variable<String>(ratings);
    map['view_step'] = Variable<String>(viewStep);
    map['hide_passage'] = Variable<bool>(hidePassage);
    map['updated_utc_ms'] = Variable<int>(updatedUtcMs);
    return map;
  }

  ReadingWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return ReadingWorkspacesCompanion(
      sessionId: Value(sessionId),
      keyResults: keyResults == null && nullToAbsent
          ? const Value.absent()
          : Value(keyResults),
      revisionAnswers: Value(revisionAnswers),
      ratings: Value(ratings),
      viewStep: Value(viewStep),
      hidePassage: Value(hidePassage),
      updatedUtcMs: Value(updatedUtcMs),
    );
  }

  factory ReadingWorkspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingWorkspace(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      keyResults: serializer.fromJson<String?>(json['keyResults']),
      revisionAnswers: serializer.fromJson<String>(json['revisionAnswers']),
      ratings: serializer.fromJson<String>(json['ratings']),
      viewStep: serializer.fromJson<String>(json['viewStep']),
      hidePassage: serializer.fromJson<bool>(json['hidePassage']),
      updatedUtcMs: serializer.fromJson<int>(json['updatedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'keyResults': serializer.toJson<String?>(keyResults),
      'revisionAnswers': serializer.toJson<String>(revisionAnswers),
      'ratings': serializer.toJson<String>(ratings),
      'viewStep': serializer.toJson<String>(viewStep),
      'hidePassage': serializer.toJson<bool>(hidePassage),
      'updatedUtcMs': serializer.toJson<int>(updatedUtcMs),
    };
  }

  ReadingWorkspace copyWith({
    String? sessionId,
    Value<String?> keyResults = const Value.absent(),
    String? revisionAnswers,
    String? ratings,
    String? viewStep,
    bool? hidePassage,
    int? updatedUtcMs,
  }) => ReadingWorkspace(
    sessionId: sessionId ?? this.sessionId,
    keyResults: keyResults.present ? keyResults.value : this.keyResults,
    revisionAnswers: revisionAnswers ?? this.revisionAnswers,
    ratings: ratings ?? this.ratings,
    viewStep: viewStep ?? this.viewStep,
    hidePassage: hidePassage ?? this.hidePassage,
    updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
  );
  ReadingWorkspace copyWithCompanion(ReadingWorkspacesCompanion data) {
    return ReadingWorkspace(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      keyResults: data.keyResults.present
          ? data.keyResults.value
          : this.keyResults,
      revisionAnswers: data.revisionAnswers.present
          ? data.revisionAnswers.value
          : this.revisionAnswers,
      ratings: data.ratings.present ? data.ratings.value : this.ratings,
      viewStep: data.viewStep.present ? data.viewStep.value : this.viewStep,
      hidePassage: data.hidePassage.present
          ? data.hidePassage.value
          : this.hidePassage,
      updatedUtcMs: data.updatedUtcMs.present
          ? data.updatedUtcMs.value
          : this.updatedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingWorkspace(')
          ..write('sessionId: $sessionId, ')
          ..write('keyResults: $keyResults, ')
          ..write('revisionAnswers: $revisionAnswers, ')
          ..write('ratings: $ratings, ')
          ..write('viewStep: $viewStep, ')
          ..write('hidePassage: $hidePassage, ')
          ..write('updatedUtcMs: $updatedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    keyResults,
    revisionAnswers,
    ratings,
    viewStep,
    hidePassage,
    updatedUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingWorkspace &&
          other.sessionId == this.sessionId &&
          other.keyResults == this.keyResults &&
          other.revisionAnswers == this.revisionAnswers &&
          other.ratings == this.ratings &&
          other.viewStep == this.viewStep &&
          other.hidePassage == this.hidePassage &&
          other.updatedUtcMs == this.updatedUtcMs);
}

class ReadingWorkspacesCompanion extends UpdateCompanion<ReadingWorkspace> {
  final Value<String> sessionId;
  final Value<String?> keyResults;
  final Value<String> revisionAnswers;
  final Value<String> ratings;
  final Value<String> viewStep;
  final Value<bool> hidePassage;
  final Value<int> updatedUtcMs;
  final Value<int> rowid;
  const ReadingWorkspacesCompanion({
    this.sessionId = const Value.absent(),
    this.keyResults = const Value.absent(),
    this.revisionAnswers = const Value.absent(),
    this.ratings = const Value.absent(),
    this.viewStep = const Value.absent(),
    this.hidePassage = const Value.absent(),
    this.updatedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingWorkspacesCompanion.insert({
    required String sessionId,
    this.keyResults = const Value.absent(),
    this.revisionAnswers = const Value.absent(),
    this.ratings = const Value.absent(),
    this.viewStep = const Value.absent(),
    this.hidePassage = const Value.absent(),
    required int updatedUtcMs,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       updatedUtcMs = Value(updatedUtcMs);
  static Insertable<ReadingWorkspace> custom({
    Expression<String>? sessionId,
    Expression<String>? keyResults,
    Expression<String>? revisionAnswers,
    Expression<String>? ratings,
    Expression<String>? viewStep,
    Expression<bool>? hidePassage,
    Expression<int>? updatedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (keyResults != null) 'key_results': keyResults,
      if (revisionAnswers != null) 'revision_answers': revisionAnswers,
      if (ratings != null) 'ratings': ratings,
      if (viewStep != null) 'view_step': viewStep,
      if (hidePassage != null) 'hide_passage': hidePassage,
      if (updatedUtcMs != null) 'updated_utc_ms': updatedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingWorkspacesCompanion copyWith({
    Value<String>? sessionId,
    Value<String?>? keyResults,
    Value<String>? revisionAnswers,
    Value<String>? ratings,
    Value<String>? viewStep,
    Value<bool>? hidePassage,
    Value<int>? updatedUtcMs,
    Value<int>? rowid,
  }) {
    return ReadingWorkspacesCompanion(
      sessionId: sessionId ?? this.sessionId,
      keyResults: keyResults ?? this.keyResults,
      revisionAnswers: revisionAnswers ?? this.revisionAnswers,
      ratings: ratings ?? this.ratings,
      viewStep: viewStep ?? this.viewStep,
      hidePassage: hidePassage ?? this.hidePassage,
      updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (keyResults.present) {
      map['key_results'] = Variable<String>(keyResults.value);
    }
    if (revisionAnswers.present) {
      map['revision_answers'] = Variable<String>(revisionAnswers.value);
    }
    if (ratings.present) {
      map['ratings'] = Variable<String>(ratings.value);
    }
    if (viewStep.present) {
      map['view_step'] = Variable<String>(viewStep.value);
    }
    if (hidePassage.present) {
      map['hide_passage'] = Variable<bool>(hidePassage.value);
    }
    if (updatedUtcMs.present) {
      map['updated_utc_ms'] = Variable<int>(updatedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingWorkspacesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('keyResults: $keyResults, ')
          ..write('revisionAnswers: $revisionAnswers, ')
          ..write('ratings: $ratings, ')
          ..write('viewStep: $viewStep, ')
          ..write('hidePassage: $hidePassage, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioRecordingsTable extends AudioRecordings
    with TableInfo<$AudioRecordingsTable, AudioRecording> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioRecordingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _contextKeyMeta = const VerificationMeta(
    'contextKey',
  );
  @override
  late final GeneratedColumn<String> contextKey = GeneratedColumn<String>(
    'context_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (state IN (\'pending\',\'finalized\',\'unavailable\'))',
  );
  static const VerificationMeta _microphoneCheckMeta = const VerificationMeta(
    'microphoneCheck',
  );
  @override
  late final GeneratedColumn<bool> microphoneCheck = GeneratedColumn<bool>(
    'microphone_check',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("microphone_check" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _interruptedMeta = const VerificationMeta(
    'interrupted',
  );
  @override
  late final GeneratedColumn<bool> interrupted = GeneratedColumn<bool>(
    'interrupted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("interrupted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _inputIdMeta = const VerificationMeta(
    'inputId',
  );
  @override
  late final GeneratedColumn<String> inputId = GeneratedColumn<String>(
    'input_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputNameMeta = const VerificationMeta(
    'inputName',
  );
  @override
  late final GeneratedColumn<String> inputName = GeneratedColumn<String>(
    'input_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sampleRateMeta = const VerificationMeta(
    'sampleRate',
  );
  @override
  late final GeneratedColumn<int> sampleRate = GeneratedColumn<int>(
    'sample_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _channelsMeta = const VerificationMeta(
    'channels',
  );
  @override
  late final GeneratedColumn<int> channels = GeneratedColumn<int>(
    'channels',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _byteCountMeta = const VerificationMeta(
    'byteCount',
  );
  @override
  late final GeneratedColumn<int> byteCount = GeneratedColumn<int>(
    'byte_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _peakDbMeta = const VerificationMeta('peakDb');
  @override
  late final GeneratedColumn<double> peakDb = GeneratedColumn<double>(
    'peak_db',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rmsDbMeta = const VerificationMeta('rmsDb');
  @override
  late final GeneratedColumn<double> rmsDb = GeneratedColumn<double>(
    'rms_db',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusNoteMeta = const VerificationMeta(
    'statusNote',
  );
  @override
  late final GeneratedColumn<String> statusNote = GeneratedColumn<String>(
    'status_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdUtcMsMeta = const VerificationMeta(
    'createdUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdUtcMs = GeneratedColumn<int>(
    'created_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finalizedUtcMsMeta = const VerificationMeta(
    'finalizedUtcMs',
  );
  @override
  late final GeneratedColumn<int> finalizedUtcMs = GeneratedColumn<int>(
    'finalized_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    contextKey,
    relativePath,
    state,
    microphoneCheck,
    interrupted,
    inputId,
    inputName,
    durationMs,
    sampleRate,
    channels,
    byteCount,
    peakDb,
    rmsDb,
    statusNote,
    createdUtcMs,
    finalizedUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_recordings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioRecording> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('context_key')) {
      context.handle(
        _contextKeyMeta,
        contextKey.isAcceptableOrUnknown(data['context_key']!, _contextKeyMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('microphone_check')) {
      context.handle(
        _microphoneCheckMeta,
        microphoneCheck.isAcceptableOrUnknown(
          data['microphone_check']!,
          _microphoneCheckMeta,
        ),
      );
    }
    if (data.containsKey('interrupted')) {
      context.handle(
        _interruptedMeta,
        interrupted.isAcceptableOrUnknown(
          data['interrupted']!,
          _interruptedMeta,
        ),
      );
    }
    if (data.containsKey('input_id')) {
      context.handle(
        _inputIdMeta,
        inputId.isAcceptableOrUnknown(data['input_id']!, _inputIdMeta),
      );
    } else if (isInserting) {
      context.missing(_inputIdMeta);
    }
    if (data.containsKey('input_name')) {
      context.handle(
        _inputNameMeta,
        inputName.isAcceptableOrUnknown(data['input_name']!, _inputNameMeta),
      );
    } else if (isInserting) {
      context.missing(_inputNameMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('sample_rate')) {
      context.handle(
        _sampleRateMeta,
        sampleRate.isAcceptableOrUnknown(data['sample_rate']!, _sampleRateMeta),
      );
    }
    if (data.containsKey('channels')) {
      context.handle(
        _channelsMeta,
        channels.isAcceptableOrUnknown(data['channels']!, _channelsMeta),
      );
    }
    if (data.containsKey('byte_count')) {
      context.handle(
        _byteCountMeta,
        byteCount.isAcceptableOrUnknown(data['byte_count']!, _byteCountMeta),
      );
    }
    if (data.containsKey('peak_db')) {
      context.handle(
        _peakDbMeta,
        peakDb.isAcceptableOrUnknown(data['peak_db']!, _peakDbMeta),
      );
    }
    if (data.containsKey('rms_db')) {
      context.handle(
        _rmsDbMeta,
        rmsDb.isAcceptableOrUnknown(data['rms_db']!, _rmsDbMeta),
      );
    }
    if (data.containsKey('status_note')) {
      context.handle(
        _statusNoteMeta,
        statusNote.isAcceptableOrUnknown(data['status_note']!, _statusNoteMeta),
      );
    }
    if (data.containsKey('created_utc_ms')) {
      context.handle(
        _createdUtcMsMeta,
        createdUtcMs.isAcceptableOrUnknown(
          data['created_utc_ms']!,
          _createdUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMsMeta);
    }
    if (data.containsKey('finalized_utc_ms')) {
      context.handle(
        _finalizedUtcMsMeta,
        finalizedUtcMs.isAcceptableOrUnknown(
          data['finalized_utc_ms']!,
          _finalizedUtcMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioRecording map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioRecording(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      contextKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_key'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      microphoneCheck: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}microphone_check'],
      )!,
      interrupted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}interrupted'],
      )!,
      inputId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_id'],
      )!,
      inputName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}input_name'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      sampleRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_rate'],
      )!,
      channels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}channels'],
      )!,
      byteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_count'],
      )!,
      peakDb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_db'],
      ),
      rmsDb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rms_db'],
      ),
      statusNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_note'],
      )!,
      createdUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc_ms'],
      )!,
      finalizedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finalized_utc_ms'],
      ),
    );
  }

  @override
  $AudioRecordingsTable createAlias(String alias) {
    return $AudioRecordingsTable(attachedDatabase, alias);
  }
}

class AudioRecording extends DataClass implements Insertable<AudioRecording> {
  final String id;
  final String sessionId;
  final String contextKey;
  final String relativePath;
  final String state;
  final bool microphoneCheck;
  final bool interrupted;
  final String inputId;
  final String inputName;
  final int durationMs;
  final int sampleRate;
  final int channels;
  final int byteCount;
  final double? peakDb;
  final double? rmsDb;
  final String statusNote;
  final int createdUtcMs;
  final int? finalizedUtcMs;
  const AudioRecording({
    required this.id,
    required this.sessionId,
    required this.contextKey,
    required this.relativePath,
    required this.state,
    required this.microphoneCheck,
    required this.interrupted,
    required this.inputId,
    required this.inputName,
    required this.durationMs,
    required this.sampleRate,
    required this.channels,
    required this.byteCount,
    this.peakDb,
    this.rmsDb,
    required this.statusNote,
    required this.createdUtcMs,
    this.finalizedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['context_key'] = Variable<String>(contextKey);
    map['relative_path'] = Variable<String>(relativePath);
    map['state'] = Variable<String>(state);
    map['microphone_check'] = Variable<bool>(microphoneCheck);
    map['interrupted'] = Variable<bool>(interrupted);
    map['input_id'] = Variable<String>(inputId);
    map['input_name'] = Variable<String>(inputName);
    map['duration_ms'] = Variable<int>(durationMs);
    map['sample_rate'] = Variable<int>(sampleRate);
    map['channels'] = Variable<int>(channels);
    map['byte_count'] = Variable<int>(byteCount);
    if (!nullToAbsent || peakDb != null) {
      map['peak_db'] = Variable<double>(peakDb);
    }
    if (!nullToAbsent || rmsDb != null) {
      map['rms_db'] = Variable<double>(rmsDb);
    }
    map['status_note'] = Variable<String>(statusNote);
    map['created_utc_ms'] = Variable<int>(createdUtcMs);
    if (!nullToAbsent || finalizedUtcMs != null) {
      map['finalized_utc_ms'] = Variable<int>(finalizedUtcMs);
    }
    return map;
  }

  AudioRecordingsCompanion toCompanion(bool nullToAbsent) {
    return AudioRecordingsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      contextKey: Value(contextKey),
      relativePath: Value(relativePath),
      state: Value(state),
      microphoneCheck: Value(microphoneCheck),
      interrupted: Value(interrupted),
      inputId: Value(inputId),
      inputName: Value(inputName),
      durationMs: Value(durationMs),
      sampleRate: Value(sampleRate),
      channels: Value(channels),
      byteCount: Value(byteCount),
      peakDb: peakDb == null && nullToAbsent
          ? const Value.absent()
          : Value(peakDb),
      rmsDb: rmsDb == null && nullToAbsent
          ? const Value.absent()
          : Value(rmsDb),
      statusNote: Value(statusNote),
      createdUtcMs: Value(createdUtcMs),
      finalizedUtcMs: finalizedUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedUtcMs),
    );
  }

  factory AudioRecording.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioRecording(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      contextKey: serializer.fromJson<String>(json['contextKey']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      state: serializer.fromJson<String>(json['state']),
      microphoneCheck: serializer.fromJson<bool>(json['microphoneCheck']),
      interrupted: serializer.fromJson<bool>(json['interrupted']),
      inputId: serializer.fromJson<String>(json['inputId']),
      inputName: serializer.fromJson<String>(json['inputName']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      sampleRate: serializer.fromJson<int>(json['sampleRate']),
      channels: serializer.fromJson<int>(json['channels']),
      byteCount: serializer.fromJson<int>(json['byteCount']),
      peakDb: serializer.fromJson<double?>(json['peakDb']),
      rmsDb: serializer.fromJson<double?>(json['rmsDb']),
      statusNote: serializer.fromJson<String>(json['statusNote']),
      createdUtcMs: serializer.fromJson<int>(json['createdUtcMs']),
      finalizedUtcMs: serializer.fromJson<int?>(json['finalizedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'contextKey': serializer.toJson<String>(contextKey),
      'relativePath': serializer.toJson<String>(relativePath),
      'state': serializer.toJson<String>(state),
      'microphoneCheck': serializer.toJson<bool>(microphoneCheck),
      'interrupted': serializer.toJson<bool>(interrupted),
      'inputId': serializer.toJson<String>(inputId),
      'inputName': serializer.toJson<String>(inputName),
      'durationMs': serializer.toJson<int>(durationMs),
      'sampleRate': serializer.toJson<int>(sampleRate),
      'channels': serializer.toJson<int>(channels),
      'byteCount': serializer.toJson<int>(byteCount),
      'peakDb': serializer.toJson<double?>(peakDb),
      'rmsDb': serializer.toJson<double?>(rmsDb),
      'statusNote': serializer.toJson<String>(statusNote),
      'createdUtcMs': serializer.toJson<int>(createdUtcMs),
      'finalizedUtcMs': serializer.toJson<int?>(finalizedUtcMs),
    };
  }

  AudioRecording copyWith({
    String? id,
    String? sessionId,
    String? contextKey,
    String? relativePath,
    String? state,
    bool? microphoneCheck,
    bool? interrupted,
    String? inputId,
    String? inputName,
    int? durationMs,
    int? sampleRate,
    int? channels,
    int? byteCount,
    Value<double?> peakDb = const Value.absent(),
    Value<double?> rmsDb = const Value.absent(),
    String? statusNote,
    int? createdUtcMs,
    Value<int?> finalizedUtcMs = const Value.absent(),
  }) => AudioRecording(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    contextKey: contextKey ?? this.contextKey,
    relativePath: relativePath ?? this.relativePath,
    state: state ?? this.state,
    microphoneCheck: microphoneCheck ?? this.microphoneCheck,
    interrupted: interrupted ?? this.interrupted,
    inputId: inputId ?? this.inputId,
    inputName: inputName ?? this.inputName,
    durationMs: durationMs ?? this.durationMs,
    sampleRate: sampleRate ?? this.sampleRate,
    channels: channels ?? this.channels,
    byteCount: byteCount ?? this.byteCount,
    peakDb: peakDb.present ? peakDb.value : this.peakDb,
    rmsDb: rmsDb.present ? rmsDb.value : this.rmsDb,
    statusNote: statusNote ?? this.statusNote,
    createdUtcMs: createdUtcMs ?? this.createdUtcMs,
    finalizedUtcMs: finalizedUtcMs.present
        ? finalizedUtcMs.value
        : this.finalizedUtcMs,
  );
  AudioRecording copyWithCompanion(AudioRecordingsCompanion data) {
    return AudioRecording(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      contextKey: data.contextKey.present
          ? data.contextKey.value
          : this.contextKey,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      state: data.state.present ? data.state.value : this.state,
      microphoneCheck: data.microphoneCheck.present
          ? data.microphoneCheck.value
          : this.microphoneCheck,
      interrupted: data.interrupted.present
          ? data.interrupted.value
          : this.interrupted,
      inputId: data.inputId.present ? data.inputId.value : this.inputId,
      inputName: data.inputName.present ? data.inputName.value : this.inputName,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      sampleRate: data.sampleRate.present
          ? data.sampleRate.value
          : this.sampleRate,
      channels: data.channels.present ? data.channels.value : this.channels,
      byteCount: data.byteCount.present ? data.byteCount.value : this.byteCount,
      peakDb: data.peakDb.present ? data.peakDb.value : this.peakDb,
      rmsDb: data.rmsDb.present ? data.rmsDb.value : this.rmsDb,
      statusNote: data.statusNote.present
          ? data.statusNote.value
          : this.statusNote,
      createdUtcMs: data.createdUtcMs.present
          ? data.createdUtcMs.value
          : this.createdUtcMs,
      finalizedUtcMs: data.finalizedUtcMs.present
          ? data.finalizedUtcMs.value
          : this.finalizedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioRecording(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('contextKey: $contextKey, ')
          ..write('relativePath: $relativePath, ')
          ..write('state: $state, ')
          ..write('microphoneCheck: $microphoneCheck, ')
          ..write('interrupted: $interrupted, ')
          ..write('inputId: $inputId, ')
          ..write('inputName: $inputName, ')
          ..write('durationMs: $durationMs, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('channels: $channels, ')
          ..write('byteCount: $byteCount, ')
          ..write('peakDb: $peakDb, ')
          ..write('rmsDb: $rmsDb, ')
          ..write('statusNote: $statusNote, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('finalizedUtcMs: $finalizedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    contextKey,
    relativePath,
    state,
    microphoneCheck,
    interrupted,
    inputId,
    inputName,
    durationMs,
    sampleRate,
    channels,
    byteCount,
    peakDb,
    rmsDb,
    statusNote,
    createdUtcMs,
    finalizedUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioRecording &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.contextKey == this.contextKey &&
          other.relativePath == this.relativePath &&
          other.state == this.state &&
          other.microphoneCheck == this.microphoneCheck &&
          other.interrupted == this.interrupted &&
          other.inputId == this.inputId &&
          other.inputName == this.inputName &&
          other.durationMs == this.durationMs &&
          other.sampleRate == this.sampleRate &&
          other.channels == this.channels &&
          other.byteCount == this.byteCount &&
          other.peakDb == this.peakDb &&
          other.rmsDb == this.rmsDb &&
          other.statusNote == this.statusNote &&
          other.createdUtcMs == this.createdUtcMs &&
          other.finalizedUtcMs == this.finalizedUtcMs);
}

class AudioRecordingsCompanion extends UpdateCompanion<AudioRecording> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> contextKey;
  final Value<String> relativePath;
  final Value<String> state;
  final Value<bool> microphoneCheck;
  final Value<bool> interrupted;
  final Value<String> inputId;
  final Value<String> inputName;
  final Value<int> durationMs;
  final Value<int> sampleRate;
  final Value<int> channels;
  final Value<int> byteCount;
  final Value<double?> peakDb;
  final Value<double?> rmsDb;
  final Value<String> statusNote;
  final Value<int> createdUtcMs;
  final Value<int?> finalizedUtcMs;
  final Value<int> rowid;
  const AudioRecordingsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.contextKey = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.state = const Value.absent(),
    this.microphoneCheck = const Value.absent(),
    this.interrupted = const Value.absent(),
    this.inputId = const Value.absent(),
    this.inputName = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.channels = const Value.absent(),
    this.byteCount = const Value.absent(),
    this.peakDb = const Value.absent(),
    this.rmsDb = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.createdUtcMs = const Value.absent(),
    this.finalizedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioRecordingsCompanion.insert({
    required String id,
    required String sessionId,
    this.contextKey = const Value.absent(),
    required String relativePath,
    required String state,
    this.microphoneCheck = const Value.absent(),
    this.interrupted = const Value.absent(),
    required String inputId,
    required String inputName,
    this.durationMs = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.channels = const Value.absent(),
    this.byteCount = const Value.absent(),
    this.peakDb = const Value.absent(),
    this.rmsDb = const Value.absent(),
    this.statusNote = const Value.absent(),
    required int createdUtcMs,
    this.finalizedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       relativePath = Value(relativePath),
       state = Value(state),
       inputId = Value(inputId),
       inputName = Value(inputName),
       createdUtcMs = Value(createdUtcMs);
  static Insertable<AudioRecording> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? contextKey,
    Expression<String>? relativePath,
    Expression<String>? state,
    Expression<bool>? microphoneCheck,
    Expression<bool>? interrupted,
    Expression<String>? inputId,
    Expression<String>? inputName,
    Expression<int>? durationMs,
    Expression<int>? sampleRate,
    Expression<int>? channels,
    Expression<int>? byteCount,
    Expression<double>? peakDb,
    Expression<double>? rmsDb,
    Expression<String>? statusNote,
    Expression<int>? createdUtcMs,
    Expression<int>? finalizedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (contextKey != null) 'context_key': contextKey,
      if (relativePath != null) 'relative_path': relativePath,
      if (state != null) 'state': state,
      if (microphoneCheck != null) 'microphone_check': microphoneCheck,
      if (interrupted != null) 'interrupted': interrupted,
      if (inputId != null) 'input_id': inputId,
      if (inputName != null) 'input_name': inputName,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (channels != null) 'channels': channels,
      if (byteCount != null) 'byte_count': byteCount,
      if (peakDb != null) 'peak_db': peakDb,
      if (rmsDb != null) 'rms_db': rmsDb,
      if (statusNote != null) 'status_note': statusNote,
      if (createdUtcMs != null) 'created_utc_ms': createdUtcMs,
      if (finalizedUtcMs != null) 'finalized_utc_ms': finalizedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioRecordingsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? contextKey,
    Value<String>? relativePath,
    Value<String>? state,
    Value<bool>? microphoneCheck,
    Value<bool>? interrupted,
    Value<String>? inputId,
    Value<String>? inputName,
    Value<int>? durationMs,
    Value<int>? sampleRate,
    Value<int>? channels,
    Value<int>? byteCount,
    Value<double?>? peakDb,
    Value<double?>? rmsDb,
    Value<String>? statusNote,
    Value<int>? createdUtcMs,
    Value<int?>? finalizedUtcMs,
    Value<int>? rowid,
  }) {
    return AudioRecordingsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      contextKey: contextKey ?? this.contextKey,
      relativePath: relativePath ?? this.relativePath,
      state: state ?? this.state,
      microphoneCheck: microphoneCheck ?? this.microphoneCheck,
      interrupted: interrupted ?? this.interrupted,
      inputId: inputId ?? this.inputId,
      inputName: inputName ?? this.inputName,
      durationMs: durationMs ?? this.durationMs,
      sampleRate: sampleRate ?? this.sampleRate,
      channels: channels ?? this.channels,
      byteCount: byteCount ?? this.byteCount,
      peakDb: peakDb ?? this.peakDb,
      rmsDb: rmsDb ?? this.rmsDb,
      statusNote: statusNote ?? this.statusNote,
      createdUtcMs: createdUtcMs ?? this.createdUtcMs,
      finalizedUtcMs: finalizedUtcMs ?? this.finalizedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (contextKey.present) {
      map['context_key'] = Variable<String>(contextKey.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (microphoneCheck.present) {
      map['microphone_check'] = Variable<bool>(microphoneCheck.value);
    }
    if (interrupted.present) {
      map['interrupted'] = Variable<bool>(interrupted.value);
    }
    if (inputId.present) {
      map['input_id'] = Variable<String>(inputId.value);
    }
    if (inputName.present) {
      map['input_name'] = Variable<String>(inputName.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sampleRate.present) {
      map['sample_rate'] = Variable<int>(sampleRate.value);
    }
    if (channels.present) {
      map['channels'] = Variable<int>(channels.value);
    }
    if (byteCount.present) {
      map['byte_count'] = Variable<int>(byteCount.value);
    }
    if (peakDb.present) {
      map['peak_db'] = Variable<double>(peakDb.value);
    }
    if (rmsDb.present) {
      map['rms_db'] = Variable<double>(rmsDb.value);
    }
    if (statusNote.present) {
      map['status_note'] = Variable<String>(statusNote.value);
    }
    if (createdUtcMs.present) {
      map['created_utc_ms'] = Variable<int>(createdUtcMs.value);
    }
    if (finalizedUtcMs.present) {
      map['finalized_utc_ms'] = Variable<int>(finalizedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioRecordingsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('contextKey: $contextKey, ')
          ..write('relativePath: $relativePath, ')
          ..write('state: $state, ')
          ..write('microphoneCheck: $microphoneCheck, ')
          ..write('interrupted: $interrupted, ')
          ..write('inputId: $inputId, ')
          ..write('inputName: $inputName, ')
          ..write('durationMs: $durationMs, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('channels: $channels, ')
          ..write('byteCount: $byteCount, ')
          ..write('peakDb: $peakDb, ')
          ..write('rmsDb: $rmsDb, ')
          ..write('statusNote: $statusNote, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('finalizedUtcMs: $finalizedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AudioObservationsTable extends AudioObservations
    with TableInfo<$AudioObservationsTable, AudioObservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AudioObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordingIdMeta = const VerificationMeta(
    'recordingId',
  );
  @override
  late final GeneratedColumn<String> recordingId = GeneratedColumn<String>(
    'recording_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audio_recordings (id)',
    ),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdUtcMsMeta = const VerificationMeta(
    'createdUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdUtcMs = GeneratedColumn<int>(
    'created_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordingId,
    positionMs,
    note,
    createdUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audio_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AudioObservation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recording_id')) {
      context.handle(
        _recordingIdMeta,
        recordingId.isAcceptableOrUnknown(
          data['recording_id']!,
          _recordingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recordingIdMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_utc_ms')) {
      context.handle(
        _createdUtcMsMeta,
        createdUtcMs.isAcceptableOrUnknown(
          data['created_utc_ms']!,
          _createdUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AudioObservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AudioObservation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recordingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recording_id'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc_ms'],
      )!,
    );
  }

  @override
  $AudioObservationsTable createAlias(String alias) {
    return $AudioObservationsTable(attachedDatabase, alias);
  }
}

class AudioObservation extends DataClass
    implements Insertable<AudioObservation> {
  final String id;
  final String recordingId;
  final int positionMs;
  final String note;
  final int createdUtcMs;
  const AudioObservation({
    required this.id,
    required this.recordingId,
    required this.positionMs,
    required this.note,
    required this.createdUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recording_id'] = Variable<String>(recordingId);
    map['position_ms'] = Variable<int>(positionMs);
    map['note'] = Variable<String>(note);
    map['created_utc_ms'] = Variable<int>(createdUtcMs);
    return map;
  }

  AudioObservationsCompanion toCompanion(bool nullToAbsent) {
    return AudioObservationsCompanion(
      id: Value(id),
      recordingId: Value(recordingId),
      positionMs: Value(positionMs),
      note: Value(note),
      createdUtcMs: Value(createdUtcMs),
    );
  }

  factory AudioObservation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AudioObservation(
      id: serializer.fromJson<String>(json['id']),
      recordingId: serializer.fromJson<String>(json['recordingId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      note: serializer.fromJson<String>(json['note']),
      createdUtcMs: serializer.fromJson<int>(json['createdUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordingId': serializer.toJson<String>(recordingId),
      'positionMs': serializer.toJson<int>(positionMs),
      'note': serializer.toJson<String>(note),
      'createdUtcMs': serializer.toJson<int>(createdUtcMs),
    };
  }

  AudioObservation copyWith({
    String? id,
    String? recordingId,
    int? positionMs,
    String? note,
    int? createdUtcMs,
  }) => AudioObservation(
    id: id ?? this.id,
    recordingId: recordingId ?? this.recordingId,
    positionMs: positionMs ?? this.positionMs,
    note: note ?? this.note,
    createdUtcMs: createdUtcMs ?? this.createdUtcMs,
  );
  AudioObservation copyWithCompanion(AudioObservationsCompanion data) {
    return AudioObservation(
      id: data.id.present ? data.id.value : this.id,
      recordingId: data.recordingId.present
          ? data.recordingId.value
          : this.recordingId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      note: data.note.present ? data.note.value : this.note,
      createdUtcMs: data.createdUtcMs.present
          ? data.createdUtcMs.value
          : this.createdUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AudioObservation(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('positionMs: $positionMs, ')
          ..write('note: $note, ')
          ..write('createdUtcMs: $createdUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recordingId, positionMs, note, createdUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AudioObservation &&
          other.id == this.id &&
          other.recordingId == this.recordingId &&
          other.positionMs == this.positionMs &&
          other.note == this.note &&
          other.createdUtcMs == this.createdUtcMs);
}

class AudioObservationsCompanion extends UpdateCompanion<AudioObservation> {
  final Value<String> id;
  final Value<String> recordingId;
  final Value<int> positionMs;
  final Value<String> note;
  final Value<int> createdUtcMs;
  final Value<int> rowid;
  const AudioObservationsCompanion({
    this.id = const Value.absent(),
    this.recordingId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.note = const Value.absent(),
    this.createdUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AudioObservationsCompanion.insert({
    required String id,
    required String recordingId,
    required int positionMs,
    required String note,
    required int createdUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordingId = Value(recordingId),
       positionMs = Value(positionMs),
       note = Value(note),
       createdUtcMs = Value(createdUtcMs);
  static Insertable<AudioObservation> custom({
    Expression<String>? id,
    Expression<String>? recordingId,
    Expression<int>? positionMs,
    Expression<String>? note,
    Expression<int>? createdUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordingId != null) 'recording_id': recordingId,
      if (positionMs != null) 'position_ms': positionMs,
      if (note != null) 'note': note,
      if (createdUtcMs != null) 'created_utc_ms': createdUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AudioObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? recordingId,
    Value<int>? positionMs,
    Value<String>? note,
    Value<int>? createdUtcMs,
    Value<int>? rowid,
  }) {
    return AudioObservationsCompanion(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      positionMs: positionMs ?? this.positionMs,
      note: note ?? this.note,
      createdUtcMs: createdUtcMs ?? this.createdUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recordingId.present) {
      map['recording_id'] = Variable<String>(recordingId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdUtcMs.present) {
      map['created_utc_ms'] = Variable<int>(createdUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioObservationsCompanion(')
          ..write('id: $id, ')
          ..write('recordingId: $recordingId, ')
          ..write('positionMs: $positionMs, ')
          ..write('note: $note, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemorySpeechesTable extends MemorySpeeches
    with TableInfo<$MemorySpeechesTable, MemorySpeech> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemorySpeechesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftMeta = const VerificationMeta('draft');
  @override
  late final GeneratedColumn<String> draft = GeneratedColumn<String>(
    'draft',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedUtcMsMeta = const VerificationMeta(
    'updatedUtcMs',
  );
  @override
  late final GeneratedColumn<int> updatedUtcMs = GeneratedColumn<int>(
    'updated_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, draft, updatedUtcMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_speeches';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemorySpeech> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('draft')) {
      context.handle(
        _draftMeta,
        draft.isAcceptableOrUnknown(data['draft']!, _draftMeta),
      );
    } else if (isInserting) {
      context.missing(_draftMeta);
    }
    if (data.containsKey('updated_utc_ms')) {
      context.handle(
        _updatedUtcMsMeta,
        updatedUtcMs.isAcceptableOrUnknown(
          data['updated_utc_ms']!,
          _updatedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemorySpeech map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemorySpeech(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      draft: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft'],
      )!,
      updatedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_utc_ms'],
      )!,
    );
  }

  @override
  $MemorySpeechesTable createAlias(String alias) {
    return $MemorySpeechesTable(attachedDatabase, alias);
  }
}

class MemorySpeech extends DataClass implements Insertable<MemorySpeech> {
  final String id;
  final String draft;
  final int updatedUtcMs;
  const MemorySpeech({
    required this.id,
    required this.draft,
    required this.updatedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['draft'] = Variable<String>(draft);
    map['updated_utc_ms'] = Variable<int>(updatedUtcMs);
    return map;
  }

  MemorySpeechesCompanion toCompanion(bool nullToAbsent) {
    return MemorySpeechesCompanion(
      id: Value(id),
      draft: Value(draft),
      updatedUtcMs: Value(updatedUtcMs),
    );
  }

  factory MemorySpeech.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemorySpeech(
      id: serializer.fromJson<String>(json['id']),
      draft: serializer.fromJson<String>(json['draft']),
      updatedUtcMs: serializer.fromJson<int>(json['updatedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'draft': serializer.toJson<String>(draft),
      'updatedUtcMs': serializer.toJson<int>(updatedUtcMs),
    };
  }

  MemorySpeech copyWith({String? id, String? draft, int? updatedUtcMs}) =>
      MemorySpeech(
        id: id ?? this.id,
        draft: draft ?? this.draft,
        updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      );
  MemorySpeech copyWithCompanion(MemorySpeechesCompanion data) {
    return MemorySpeech(
      id: data.id.present ? data.id.value : this.id,
      draft: data.draft.present ? data.draft.value : this.draft,
      updatedUtcMs: data.updatedUtcMs.present
          ? data.updatedUtcMs.value
          : this.updatedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemorySpeech(')
          ..write('id: $id, ')
          ..write('draft: $draft, ')
          ..write('updatedUtcMs: $updatedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, draft, updatedUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemorySpeech &&
          other.id == this.id &&
          other.draft == this.draft &&
          other.updatedUtcMs == this.updatedUtcMs);
}

class MemorySpeechesCompanion extends UpdateCompanion<MemorySpeech> {
  final Value<String> id;
  final Value<String> draft;
  final Value<int> updatedUtcMs;
  final Value<int> rowid;
  const MemorySpeechesCompanion({
    this.id = const Value.absent(),
    this.draft = const Value.absent(),
    this.updatedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemorySpeechesCompanion.insert({
    required String id,
    required String draft,
    required int updatedUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       draft = Value(draft),
       updatedUtcMs = Value(updatedUtcMs);
  static Insertable<MemorySpeech> custom({
    Expression<String>? id,
    Expression<String>? draft,
    Expression<int>? updatedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (draft != null) 'draft': draft,
      if (updatedUtcMs != null) 'updated_utc_ms': updatedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemorySpeechesCompanion copyWith({
    Value<String>? id,
    Value<String>? draft,
    Value<int>? updatedUtcMs,
    Value<int>? rowid,
  }) {
    return MemorySpeechesCompanion(
      id: id ?? this.id,
      draft: draft ?? this.draft,
      updatedUtcMs: updatedUtcMs ?? this.updatedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (draft.present) {
      map['draft'] = Variable<String>(draft.value);
    }
    if (updatedUtcMs.present) {
      map['updated_utc_ms'] = Variable<int>(updatedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemorySpeechesCompanion(')
          ..write('id: $id, ')
          ..write('draft: $draft, ')
          ..write('updatedUtcMs: $updatedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryVersionsTable extends MemoryVersions
    with TableInfo<$MemoryVersionsTable, MemoryVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speechIdMeta = const VerificationMeta(
    'speechId',
  );
  @override
  late final GeneratedColumn<String> speechId = GeneratedColumn<String>(
    'speech_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_speeches (id)',
    ),
  );
  static const VerificationMeta _versionNumberMeta = const VerificationMeta(
    'versionNumber',
  );
  @override
  late final GeneratedColumn<int> versionNumber = GeneratedColumn<int>(
    'version_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdUtcMsMeta = const VerificationMeta(
    'createdUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdUtcMs = GeneratedColumn<int>(
    'created_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speechId,
    versionNumber,
    content,
    createdUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('speech_id')) {
      context.handle(
        _speechIdMeta,
        speechId.isAcceptableOrUnknown(data['speech_id']!, _speechIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speechIdMeta);
    }
    if (data.containsKey('version_number')) {
      context.handle(
        _versionNumberMeta,
        versionNumber.isAcceptableOrUnknown(
          data['version_number']!,
          _versionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionNumberMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_utc_ms')) {
      context.handle(
        _createdUtcMsMeta,
        createdUtcMs.isAcceptableOrUnknown(
          data['created_utc_ms']!,
          _createdUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {speechId, versionNumber},
  ];
  @override
  MemoryVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      speechId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speech_id'],
      )!,
      versionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_number'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc_ms'],
      )!,
    );
  }

  @override
  $MemoryVersionsTable createAlias(String alias) {
    return $MemoryVersionsTable(attachedDatabase, alias);
  }
}

class MemoryVersion extends DataClass implements Insertable<MemoryVersion> {
  final String id;
  final String speechId;
  final int versionNumber;
  final String content;
  final int createdUtcMs;
  const MemoryVersion({
    required this.id,
    required this.speechId,
    required this.versionNumber,
    required this.content,
    required this.createdUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['speech_id'] = Variable<String>(speechId);
    map['version_number'] = Variable<int>(versionNumber);
    map['content'] = Variable<String>(content);
    map['created_utc_ms'] = Variable<int>(createdUtcMs);
    return map;
  }

  MemoryVersionsCompanion toCompanion(bool nullToAbsent) {
    return MemoryVersionsCompanion(
      id: Value(id),
      speechId: Value(speechId),
      versionNumber: Value(versionNumber),
      content: Value(content),
      createdUtcMs: Value(createdUtcMs),
    );
  }

  factory MemoryVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryVersion(
      id: serializer.fromJson<String>(json['id']),
      speechId: serializer.fromJson<String>(json['speechId']),
      versionNumber: serializer.fromJson<int>(json['versionNumber']),
      content: serializer.fromJson<String>(json['content']),
      createdUtcMs: serializer.fromJson<int>(json['createdUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'speechId': serializer.toJson<String>(speechId),
      'versionNumber': serializer.toJson<int>(versionNumber),
      'content': serializer.toJson<String>(content),
      'createdUtcMs': serializer.toJson<int>(createdUtcMs),
    };
  }

  MemoryVersion copyWith({
    String? id,
    String? speechId,
    int? versionNumber,
    String? content,
    int? createdUtcMs,
  }) => MemoryVersion(
    id: id ?? this.id,
    speechId: speechId ?? this.speechId,
    versionNumber: versionNumber ?? this.versionNumber,
    content: content ?? this.content,
    createdUtcMs: createdUtcMs ?? this.createdUtcMs,
  );
  MemoryVersion copyWithCompanion(MemoryVersionsCompanion data) {
    return MemoryVersion(
      id: data.id.present ? data.id.value : this.id,
      speechId: data.speechId.present ? data.speechId.value : this.speechId,
      versionNumber: data.versionNumber.present
          ? data.versionNumber.value
          : this.versionNumber,
      content: data.content.present ? data.content.value : this.content,
      createdUtcMs: data.createdUtcMs.present
          ? data.createdUtcMs.value
          : this.createdUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryVersion(')
          ..write('id: $id, ')
          ..write('speechId: $speechId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('content: $content, ')
          ..write('createdUtcMs: $createdUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, speechId, versionNumber, content, createdUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryVersion &&
          other.id == this.id &&
          other.speechId == this.speechId &&
          other.versionNumber == this.versionNumber &&
          other.content == this.content &&
          other.createdUtcMs == this.createdUtcMs);
}

class MemoryVersionsCompanion extends UpdateCompanion<MemoryVersion> {
  final Value<String> id;
  final Value<String> speechId;
  final Value<int> versionNumber;
  final Value<String> content;
  final Value<int> createdUtcMs;
  final Value<int> rowid;
  const MemoryVersionsCompanion({
    this.id = const Value.absent(),
    this.speechId = const Value.absent(),
    this.versionNumber = const Value.absent(),
    this.content = const Value.absent(),
    this.createdUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryVersionsCompanion.insert({
    required String id,
    required String speechId,
    required int versionNumber,
    required String content,
    required int createdUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       speechId = Value(speechId),
       versionNumber = Value(versionNumber),
       content = Value(content),
       createdUtcMs = Value(createdUtcMs);
  static Insertable<MemoryVersion> custom({
    Expression<String>? id,
    Expression<String>? speechId,
    Expression<int>? versionNumber,
    Expression<String>? content,
    Expression<int>? createdUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speechId != null) 'speech_id': speechId,
      if (versionNumber != null) 'version_number': versionNumber,
      if (content != null) 'content': content,
      if (createdUtcMs != null) 'created_utc_ms': createdUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? speechId,
    Value<int>? versionNumber,
    Value<String>? content,
    Value<int>? createdUtcMs,
    Value<int>? rowid,
  }) {
    return MemoryVersionsCompanion(
      id: id ?? this.id,
      speechId: speechId ?? this.speechId,
      versionNumber: versionNumber ?? this.versionNumber,
      content: content ?? this.content,
      createdUtcMs: createdUtcMs ?? this.createdUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (speechId.present) {
      map['speech_id'] = Variable<String>(speechId.value);
    }
    if (versionNumber.present) {
      map['version_number'] = Variable<int>(versionNumber.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdUtcMs.present) {
      map['created_utc_ms'] = Variable<int>(createdUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryVersionsCompanion(')
          ..write('id: $id, ')
          ..write('speechId: $speechId, ')
          ..write('versionNumber: $versionNumber, ')
          ..write('content: $content, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryWorkspacesTable extends MemoryWorkspaces
    with TableInfo<$MemoryWorkspacesTable, MemoryWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memory_versions (id)',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recallKindMeta = const VerificationMeta(
    'recallKind',
  );
  @override
  late final GeneratedColumn<String> recallKind = GeneratedColumn<String>(
    'recall_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cueStageMeta = const VerificationMeta(
    'cueStage',
  );
  @override
  late final GeneratedColumn<String> cueStage = GeneratedColumn<String>(
    'cue_stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assistanceMeta = const VerificationMeta(
    'assistance',
  );
  @override
  late final GeneratedColumn<String> assistance = GeneratedColumn<String>(
    'assistance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assessmentsMeta = const VerificationMeta(
    'assessments',
  );
  @override
  late final GeneratedColumn<String> assessments = GeneratedColumn<String>(
    'assessments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _reviewNoteMeta = const VerificationMeta(
    'reviewNote',
  );
  @override
  late final GeneratedColumn<String> reviewNote = GeneratedColumn<String>(
    'review_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _laterReviewMeta = const VerificationMeta(
    'laterReview',
  );
  @override
  late final GeneratedColumn<bool> laterReview = GeneratedColumn<bool>(
    'later_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("later_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    versionId,
    sectionId,
    mode,
    recallKind,
    cueStage,
    assistance,
    assessments,
    reviewNote,
    laterReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryWorkspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('recall_kind')) {
      context.handle(
        _recallKindMeta,
        recallKind.isAcceptableOrUnknown(data['recall_kind']!, _recallKindMeta),
      );
    } else if (isInserting) {
      context.missing(_recallKindMeta);
    }
    if (data.containsKey('cue_stage')) {
      context.handle(
        _cueStageMeta,
        cueStage.isAcceptableOrUnknown(data['cue_stage']!, _cueStageMeta),
      );
    } else if (isInserting) {
      context.missing(_cueStageMeta);
    }
    if (data.containsKey('assistance')) {
      context.handle(
        _assistanceMeta,
        assistance.isAcceptableOrUnknown(data['assistance']!, _assistanceMeta),
      );
    } else if (isInserting) {
      context.missing(_assistanceMeta);
    }
    if (data.containsKey('assessments')) {
      context.handle(
        _assessmentsMeta,
        assessments.isAcceptableOrUnknown(
          data['assessments']!,
          _assessmentsMeta,
        ),
      );
    }
    if (data.containsKey('review_note')) {
      context.handle(
        _reviewNoteMeta,
        reviewNote.isAcceptableOrUnknown(data['review_note']!, _reviewNoteMeta),
      );
    }
    if (data.containsKey('later_review')) {
      context.handle(
        _laterReviewMeta,
        laterReview.isAcceptableOrUnknown(
          data['later_review']!,
          _laterReviewMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  MemoryWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryWorkspace(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      recallKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recall_kind'],
      )!,
      cueStage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cue_stage'],
      )!,
      assistance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assistance'],
      )!,
      assessments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessments'],
      )!,
      reviewNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_note'],
      )!,
      laterReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}later_review'],
      )!,
    );
  }

  @override
  $MemoryWorkspacesTable createAlias(String alias) {
    return $MemoryWorkspacesTable(attachedDatabase, alias);
  }
}

class MemoryWorkspace extends DataClass implements Insertable<MemoryWorkspace> {
  final String sessionId;
  final String versionId;
  final String sectionId;
  final String mode;
  final String recallKind;
  final String cueStage;
  final String assistance;
  final String assessments;
  final String reviewNote;
  final bool laterReview;
  const MemoryWorkspace({
    required this.sessionId,
    required this.versionId,
    required this.sectionId,
    required this.mode,
    required this.recallKind,
    required this.cueStage,
    required this.assistance,
    required this.assessments,
    required this.reviewNote,
    required this.laterReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['version_id'] = Variable<String>(versionId);
    map['section_id'] = Variable<String>(sectionId);
    map['mode'] = Variable<String>(mode);
    map['recall_kind'] = Variable<String>(recallKind);
    map['cue_stage'] = Variable<String>(cueStage);
    map['assistance'] = Variable<String>(assistance);
    map['assessments'] = Variable<String>(assessments);
    map['review_note'] = Variable<String>(reviewNote);
    map['later_review'] = Variable<bool>(laterReview);
    return map;
  }

  MemoryWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return MemoryWorkspacesCompanion(
      sessionId: Value(sessionId),
      versionId: Value(versionId),
      sectionId: Value(sectionId),
      mode: Value(mode),
      recallKind: Value(recallKind),
      cueStage: Value(cueStage),
      assistance: Value(assistance),
      assessments: Value(assessments),
      reviewNote: Value(reviewNote),
      laterReview: Value(laterReview),
    );
  }

  factory MemoryWorkspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryWorkspace(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      versionId: serializer.fromJson<String>(json['versionId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      mode: serializer.fromJson<String>(json['mode']),
      recallKind: serializer.fromJson<String>(json['recallKind']),
      cueStage: serializer.fromJson<String>(json['cueStage']),
      assistance: serializer.fromJson<String>(json['assistance']),
      assessments: serializer.fromJson<String>(json['assessments']),
      reviewNote: serializer.fromJson<String>(json['reviewNote']),
      laterReview: serializer.fromJson<bool>(json['laterReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'versionId': serializer.toJson<String>(versionId),
      'sectionId': serializer.toJson<String>(sectionId),
      'mode': serializer.toJson<String>(mode),
      'recallKind': serializer.toJson<String>(recallKind),
      'cueStage': serializer.toJson<String>(cueStage),
      'assistance': serializer.toJson<String>(assistance),
      'assessments': serializer.toJson<String>(assessments),
      'reviewNote': serializer.toJson<String>(reviewNote),
      'laterReview': serializer.toJson<bool>(laterReview),
    };
  }

  MemoryWorkspace copyWith({
    String? sessionId,
    String? versionId,
    String? sectionId,
    String? mode,
    String? recallKind,
    String? cueStage,
    String? assistance,
    String? assessments,
    String? reviewNote,
    bool? laterReview,
  }) => MemoryWorkspace(
    sessionId: sessionId ?? this.sessionId,
    versionId: versionId ?? this.versionId,
    sectionId: sectionId ?? this.sectionId,
    mode: mode ?? this.mode,
    recallKind: recallKind ?? this.recallKind,
    cueStage: cueStage ?? this.cueStage,
    assistance: assistance ?? this.assistance,
    assessments: assessments ?? this.assessments,
    reviewNote: reviewNote ?? this.reviewNote,
    laterReview: laterReview ?? this.laterReview,
  );
  MemoryWorkspace copyWithCompanion(MemoryWorkspacesCompanion data) {
    return MemoryWorkspace(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      mode: data.mode.present ? data.mode.value : this.mode,
      recallKind: data.recallKind.present
          ? data.recallKind.value
          : this.recallKind,
      cueStage: data.cueStage.present ? data.cueStage.value : this.cueStage,
      assistance: data.assistance.present
          ? data.assistance.value
          : this.assistance,
      assessments: data.assessments.present
          ? data.assessments.value
          : this.assessments,
      reviewNote: data.reviewNote.present
          ? data.reviewNote.value
          : this.reviewNote,
      laterReview: data.laterReview.present
          ? data.laterReview.value
          : this.laterReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryWorkspace(')
          ..write('sessionId: $sessionId, ')
          ..write('versionId: $versionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('mode: $mode, ')
          ..write('recallKind: $recallKind, ')
          ..write('cueStage: $cueStage, ')
          ..write('assistance: $assistance, ')
          ..write('assessments: $assessments, ')
          ..write('reviewNote: $reviewNote, ')
          ..write('laterReview: $laterReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    versionId,
    sectionId,
    mode,
    recallKind,
    cueStage,
    assistance,
    assessments,
    reviewNote,
    laterReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryWorkspace &&
          other.sessionId == this.sessionId &&
          other.versionId == this.versionId &&
          other.sectionId == this.sectionId &&
          other.mode == this.mode &&
          other.recallKind == this.recallKind &&
          other.cueStage == this.cueStage &&
          other.assistance == this.assistance &&
          other.assessments == this.assessments &&
          other.reviewNote == this.reviewNote &&
          other.laterReview == this.laterReview);
}

class MemoryWorkspacesCompanion extends UpdateCompanion<MemoryWorkspace> {
  final Value<String> sessionId;
  final Value<String> versionId;
  final Value<String> sectionId;
  final Value<String> mode;
  final Value<String> recallKind;
  final Value<String> cueStage;
  final Value<String> assistance;
  final Value<String> assessments;
  final Value<String> reviewNote;
  final Value<bool> laterReview;
  final Value<int> rowid;
  const MemoryWorkspacesCompanion({
    this.sessionId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.mode = const Value.absent(),
    this.recallKind = const Value.absent(),
    this.cueStage = const Value.absent(),
    this.assistance = const Value.absent(),
    this.assessments = const Value.absent(),
    this.reviewNote = const Value.absent(),
    this.laterReview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryWorkspacesCompanion.insert({
    required String sessionId,
    required String versionId,
    required String sectionId,
    required String mode,
    required String recallKind,
    required String cueStage,
    required String assistance,
    this.assessments = const Value.absent(),
    this.reviewNote = const Value.absent(),
    this.laterReview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       versionId = Value(versionId),
       sectionId = Value(sectionId),
       mode = Value(mode),
       recallKind = Value(recallKind),
       cueStage = Value(cueStage),
       assistance = Value(assistance);
  static Insertable<MemoryWorkspace> custom({
    Expression<String>? sessionId,
    Expression<String>? versionId,
    Expression<String>? sectionId,
    Expression<String>? mode,
    Expression<String>? recallKind,
    Expression<String>? cueStage,
    Expression<String>? assistance,
    Expression<String>? assessments,
    Expression<String>? reviewNote,
    Expression<bool>? laterReview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (versionId != null) 'version_id': versionId,
      if (sectionId != null) 'section_id': sectionId,
      if (mode != null) 'mode': mode,
      if (recallKind != null) 'recall_kind': recallKind,
      if (cueStage != null) 'cue_stage': cueStage,
      if (assistance != null) 'assistance': assistance,
      if (assessments != null) 'assessments': assessments,
      if (reviewNote != null) 'review_note': reviewNote,
      if (laterReview != null) 'later_review': laterReview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryWorkspacesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? versionId,
    Value<String>? sectionId,
    Value<String>? mode,
    Value<String>? recallKind,
    Value<String>? cueStage,
    Value<String>? assistance,
    Value<String>? assessments,
    Value<String>? reviewNote,
    Value<bool>? laterReview,
    Value<int>? rowid,
  }) {
    return MemoryWorkspacesCompanion(
      sessionId: sessionId ?? this.sessionId,
      versionId: versionId ?? this.versionId,
      sectionId: sectionId ?? this.sectionId,
      mode: mode ?? this.mode,
      recallKind: recallKind ?? this.recallKind,
      cueStage: cueStage ?? this.cueStage,
      assistance: assistance ?? this.assistance,
      assessments: assessments ?? this.assessments,
      reviewNote: reviewNote ?? this.reviewNote,
      laterReview: laterReview ?? this.laterReview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (recallKind.present) {
      map['recall_kind'] = Variable<String>(recallKind.value);
    }
    if (cueStage.present) {
      map['cue_stage'] = Variable<String>(cueStage.value);
    }
    if (assistance.present) {
      map['assistance'] = Variable<String>(assistance.value);
    }
    if (assessments.present) {
      map['assessments'] = Variable<String>(assessments.value);
    }
    if (reviewNote.present) {
      map['review_note'] = Variable<String>(reviewNote.value);
    }
    if (laterReview.present) {
      map['later_review'] = Variable<bool>(laterReview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryWorkspacesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('versionId: $versionId, ')
          ..write('sectionId: $sectionId, ')
          ..write('mode: $mode, ')
          ..write('recallKind: $recallKind, ')
          ..write('cueStage: $cueStage, ')
          ..write('assistance: $assistance, ')
          ..write('assessments: $assessments, ')
          ..write('reviewNote: $reviewNote, ')
          ..write('laterReview: $laterReview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebateWorkspacesTable extends DebateWorkspaces
    with TableInfo<$DebateWorkspacesTable, DebateWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebateWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseKindMeta = const VerificationMeta(
    'responseKind',
  );
  @override
  late final GeneratedColumn<String> responseKind = GeneratedColumn<String>(
    'response_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetMeta = const VerificationMeta('preset');
  @override
  late final GeneratedColumn<String> preset = GeneratedColumn<String>(
    'preset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStageMeta = const VerificationMeta(
    'currentStage',
  );
  @override
  late final GeneratedColumn<int> currentStage = GeneratedColumn<int>(
    'current_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assessmentsMeta = const VerificationMeta(
    'assessments',
  );
  @override
  late final GeneratedColumn<String> assessments = GeneratedColumn<String>(
    'assessments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _reviewNoteMeta = const VerificationMeta(
    'reviewNote',
  );
  @override
  late final GeneratedColumn<String> reviewNote = GeneratedColumn<String>(
    'review_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    position,
    responseKind,
    preset,
    currentStage,
    assessments,
    reviewNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debate_workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebateWorkspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('response_kind')) {
      context.handle(
        _responseKindMeta,
        responseKind.isAcceptableOrUnknown(
          data['response_kind']!,
          _responseKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseKindMeta);
    }
    if (data.containsKey('preset')) {
      context.handle(
        _presetMeta,
        preset.isAcceptableOrUnknown(data['preset']!, _presetMeta),
      );
    } else if (isInserting) {
      context.missing(_presetMeta);
    }
    if (data.containsKey('current_stage')) {
      context.handle(
        _currentStageMeta,
        currentStage.isAcceptableOrUnknown(
          data['current_stage']!,
          _currentStageMeta,
        ),
      );
    }
    if (data.containsKey('assessments')) {
      context.handle(
        _assessmentsMeta,
        assessments.isAcceptableOrUnknown(
          data['assessments']!,
          _assessmentsMeta,
        ),
      );
    }
    if (data.containsKey('review_note')) {
      context.handle(
        _reviewNoteMeta,
        reviewNote.isAcceptableOrUnknown(data['review_note']!, _reviewNoteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  DebateWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebateWorkspace(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      )!,
      responseKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_kind'],
      )!,
      preset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset'],
      )!,
      currentStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_stage'],
      )!,
      assessments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessments'],
      )!,
      reviewNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_note'],
      )!,
    );
  }

  @override
  $DebateWorkspacesTable createAlias(String alias) {
    return $DebateWorkspacesTable(attachedDatabase, alias);
  }
}

class DebateWorkspace extends DataClass implements Insertable<DebateWorkspace> {
  final String sessionId;
  final String position;
  final String responseKind;
  final String preset;
  final int currentStage;
  final String assessments;
  final String reviewNote;
  const DebateWorkspace({
    required this.sessionId,
    required this.position,
    required this.responseKind,
    required this.preset,
    required this.currentStage,
    required this.assessments,
    required this.reviewNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['position'] = Variable<String>(position);
    map['response_kind'] = Variable<String>(responseKind);
    map['preset'] = Variable<String>(preset);
    map['current_stage'] = Variable<int>(currentStage);
    map['assessments'] = Variable<String>(assessments);
    map['review_note'] = Variable<String>(reviewNote);
    return map;
  }

  DebateWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return DebateWorkspacesCompanion(
      sessionId: Value(sessionId),
      position: Value(position),
      responseKind: Value(responseKind),
      preset: Value(preset),
      currentStage: Value(currentStage),
      assessments: Value(assessments),
      reviewNote: Value(reviewNote),
    );
  }

  factory DebateWorkspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebateWorkspace(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      position: serializer.fromJson<String>(json['position']),
      responseKind: serializer.fromJson<String>(json['responseKind']),
      preset: serializer.fromJson<String>(json['preset']),
      currentStage: serializer.fromJson<int>(json['currentStage']),
      assessments: serializer.fromJson<String>(json['assessments']),
      reviewNote: serializer.fromJson<String>(json['reviewNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'position': serializer.toJson<String>(position),
      'responseKind': serializer.toJson<String>(responseKind),
      'preset': serializer.toJson<String>(preset),
      'currentStage': serializer.toJson<int>(currentStage),
      'assessments': serializer.toJson<String>(assessments),
      'reviewNote': serializer.toJson<String>(reviewNote),
    };
  }

  DebateWorkspace copyWith({
    String? sessionId,
    String? position,
    String? responseKind,
    String? preset,
    int? currentStage,
    String? assessments,
    String? reviewNote,
  }) => DebateWorkspace(
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    responseKind: responseKind ?? this.responseKind,
    preset: preset ?? this.preset,
    currentStage: currentStage ?? this.currentStage,
    assessments: assessments ?? this.assessments,
    reviewNote: reviewNote ?? this.reviewNote,
  );
  DebateWorkspace copyWithCompanion(DebateWorkspacesCompanion data) {
    return DebateWorkspace(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      responseKind: data.responseKind.present
          ? data.responseKind.value
          : this.responseKind,
      preset: data.preset.present ? data.preset.value : this.preset,
      currentStage: data.currentStage.present
          ? data.currentStage.value
          : this.currentStage,
      assessments: data.assessments.present
          ? data.assessments.value
          : this.assessments,
      reviewNote: data.reviewNote.present
          ? data.reviewNote.value
          : this.reviewNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebateWorkspace(')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('responseKind: $responseKind, ')
          ..write('preset: $preset, ')
          ..write('currentStage: $currentStage, ')
          ..write('assessments: $assessments, ')
          ..write('reviewNote: $reviewNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    position,
    responseKind,
    preset,
    currentStage,
    assessments,
    reviewNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebateWorkspace &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.responseKind == this.responseKind &&
          other.preset == this.preset &&
          other.currentStage == this.currentStage &&
          other.assessments == this.assessments &&
          other.reviewNote == this.reviewNote);
}

class DebateWorkspacesCompanion extends UpdateCompanion<DebateWorkspace> {
  final Value<String> sessionId;
  final Value<String> position;
  final Value<String> responseKind;
  final Value<String> preset;
  final Value<int> currentStage;
  final Value<String> assessments;
  final Value<String> reviewNote;
  final Value<int> rowid;
  const DebateWorkspacesCompanion({
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.responseKind = const Value.absent(),
    this.preset = const Value.absent(),
    this.currentStage = const Value.absent(),
    this.assessments = const Value.absent(),
    this.reviewNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebateWorkspacesCompanion.insert({
    required String sessionId,
    required String position,
    required String responseKind,
    required String preset,
    this.currentStage = const Value.absent(),
    this.assessments = const Value.absent(),
    this.reviewNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       position = Value(position),
       responseKind = Value(responseKind),
       preset = Value(preset);
  static Insertable<DebateWorkspace> custom({
    Expression<String>? sessionId,
    Expression<String>? position,
    Expression<String>? responseKind,
    Expression<String>? preset,
    Expression<int>? currentStage,
    Expression<String>? assessments,
    Expression<String>? reviewNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (responseKind != null) 'response_kind': responseKind,
      if (preset != null) 'preset': preset,
      if (currentStage != null) 'current_stage': currentStage,
      if (assessments != null) 'assessments': assessments,
      if (reviewNote != null) 'review_note': reviewNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebateWorkspacesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? position,
    Value<String>? responseKind,
    Value<String>? preset,
    Value<int>? currentStage,
    Value<String>? assessments,
    Value<String>? reviewNote,
    Value<int>? rowid,
  }) {
    return DebateWorkspacesCompanion(
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      responseKind: responseKind ?? this.responseKind,
      preset: preset ?? this.preset,
      currentStage: currentStage ?? this.currentStage,
      assessments: assessments ?? this.assessments,
      reviewNote: reviewNote ?? this.reviewNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (responseKind.present) {
      map['response_kind'] = Variable<String>(responseKind.value);
    }
    if (preset.present) {
      map['preset'] = Variable<String>(preset.value);
    }
    if (currentStage.present) {
      map['current_stage'] = Variable<int>(currentStage.value);
    }
    if (assessments.present) {
      map['assessments'] = Variable<String>(assessments.value);
    }
    if (reviewNote.present) {
      map['review_note'] = Variable<String>(reviewNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebateWorkspacesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('responseKind: $responseKind, ')
          ..write('preset: $preset, ')
          ..write('currentStage: $currentStage, ')
          ..write('assessments: $assessments, ')
          ..write('reviewNote: $reviewNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DebateStagesTable extends DebateStages
    with TableInfo<$DebateStagesTable, DebateStage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DebateStagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _stageKeyMeta = const VerificationMeta(
    'stageKey',
  );
  @override
  late final GeneratedColumn<String> stageKey = GeneratedColumn<String>(
    'stage_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'pending\',\'active\',\'completed\',\'skipped\'))',
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _finishedUtcMsMeta = const VerificationMeta(
    'finishedUtcMs',
  );
  @override
  late final GeneratedColumn<int> finishedUtcMs = GeneratedColumn<int>(
    'finished_utc_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    stageKey,
    status,
    fields,
    elapsedMs,
    finishedUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'debate_stages';
  @override
  VerificationContext validateIntegrity(
    Insertable<DebateStage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('stage_key')) {
      context.handle(
        _stageKeyMeta,
        stageKey.isAcceptableOrUnknown(data['stage_key']!, _stageKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_stageKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    }
    if (data.containsKey('finished_utc_ms')) {
      context.handle(
        _finishedUtcMsMeta,
        finishedUtcMs.isAcceptableOrUnknown(
          data['finished_utc_ms']!,
          _finishedUtcMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId, stageKey};
  @override
  DebateStage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DebateStage(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      stageKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      finishedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_utc_ms'],
      ),
    );
  }

  @override
  $DebateStagesTable createAlias(String alias) {
    return $DebateStagesTable(attachedDatabase, alias);
  }
}

class DebateStage extends DataClass implements Insertable<DebateStage> {
  final String sessionId;
  final String stageKey;
  final String status;
  final String fields;
  final int elapsedMs;
  final int? finishedUtcMs;
  const DebateStage({
    required this.sessionId,
    required this.stageKey,
    required this.status,
    required this.fields,
    required this.elapsedMs,
    this.finishedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['stage_key'] = Variable<String>(stageKey);
    map['status'] = Variable<String>(status);
    map['fields'] = Variable<String>(fields);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    if (!nullToAbsent || finishedUtcMs != null) {
      map['finished_utc_ms'] = Variable<int>(finishedUtcMs);
    }
    return map;
  }

  DebateStagesCompanion toCompanion(bool nullToAbsent) {
    return DebateStagesCompanion(
      sessionId: Value(sessionId),
      stageKey: Value(stageKey),
      status: Value(status),
      fields: Value(fields),
      elapsedMs: Value(elapsedMs),
      finishedUtcMs: finishedUtcMs == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedUtcMs),
    );
  }

  factory DebateStage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DebateStage(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      stageKey: serializer.fromJson<String>(json['stageKey']),
      status: serializer.fromJson<String>(json['status']),
      fields: serializer.fromJson<String>(json['fields']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      finishedUtcMs: serializer.fromJson<int?>(json['finishedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'stageKey': serializer.toJson<String>(stageKey),
      'status': serializer.toJson<String>(status),
      'fields': serializer.toJson<String>(fields),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'finishedUtcMs': serializer.toJson<int?>(finishedUtcMs),
    };
  }

  DebateStage copyWith({
    String? sessionId,
    String? stageKey,
    String? status,
    String? fields,
    int? elapsedMs,
    Value<int?> finishedUtcMs = const Value.absent(),
  }) => DebateStage(
    sessionId: sessionId ?? this.sessionId,
    stageKey: stageKey ?? this.stageKey,
    status: status ?? this.status,
    fields: fields ?? this.fields,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    finishedUtcMs: finishedUtcMs.present
        ? finishedUtcMs.value
        : this.finishedUtcMs,
  );
  DebateStage copyWithCompanion(DebateStagesCompanion data) {
    return DebateStage(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      stageKey: data.stageKey.present ? data.stageKey.value : this.stageKey,
      status: data.status.present ? data.status.value : this.status,
      fields: data.fields.present ? data.fields.value : this.fields,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      finishedUtcMs: data.finishedUtcMs.present
          ? data.finishedUtcMs.value
          : this.finishedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DebateStage(')
          ..write('sessionId: $sessionId, ')
          ..write('stageKey: $stageKey, ')
          ..write('status: $status, ')
          ..write('fields: $fields, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('finishedUtcMs: $finishedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    stageKey,
    status,
    fields,
    elapsedMs,
    finishedUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DebateStage &&
          other.sessionId == this.sessionId &&
          other.stageKey == this.stageKey &&
          other.status == this.status &&
          other.fields == this.fields &&
          other.elapsedMs == this.elapsedMs &&
          other.finishedUtcMs == this.finishedUtcMs);
}

class DebateStagesCompanion extends UpdateCompanion<DebateStage> {
  final Value<String> sessionId;
  final Value<String> stageKey;
  final Value<String> status;
  final Value<String> fields;
  final Value<int> elapsedMs;
  final Value<int?> finishedUtcMs;
  final Value<int> rowid;
  const DebateStagesCompanion({
    this.sessionId = const Value.absent(),
    this.stageKey = const Value.absent(),
    this.status = const Value.absent(),
    this.fields = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.finishedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DebateStagesCompanion.insert({
    required String sessionId,
    required String stageKey,
    required String status,
    this.fields = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.finishedUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       stageKey = Value(stageKey),
       status = Value(status);
  static Insertable<DebateStage> custom({
    Expression<String>? sessionId,
    Expression<String>? stageKey,
    Expression<String>? status,
    Expression<String>? fields,
    Expression<int>? elapsedMs,
    Expression<int>? finishedUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (stageKey != null) 'stage_key': stageKey,
      if (status != null) 'status': status,
      if (fields != null) 'fields': fields,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (finishedUtcMs != null) 'finished_utc_ms': finishedUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DebateStagesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? stageKey,
    Value<String>? status,
    Value<String>? fields,
    Value<int>? elapsedMs,
    Value<int?>? finishedUtcMs,
    Value<int>? rowid,
  }) {
    return DebateStagesCompanion(
      sessionId: sessionId ?? this.sessionId,
      stageKey: stageKey ?? this.stageKey,
      status: status ?? this.status,
      fields: fields ?? this.fields,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      finishedUtcMs: finishedUtcMs ?? this.finishedUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (stageKey.present) {
      map['stage_key'] = Variable<String>(stageKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (finishedUtcMs.present) {
      map['finished_utc_ms'] = Variable<int>(finishedUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DebateStagesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('stageKey: $stageKey, ')
          ..write('status: $status, ')
          ..write('fields: $fields, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('finishedUtcMs: $finishedUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImpromptuQueuesTable extends ImpromptuQueues
    with TableInfo<$ImpromptuQueuesTable, ImpromptuQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImpromptuQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _poolKeyMeta = const VerificationMeta(
    'poolKey',
  );
  @override
  late final GeneratedColumn<String> poolKey = GeneratedColumn<String>(
    'pool_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingMeta = const VerificationMeta(
    'remaining',
  );
  @override
  late final GeneratedColumn<String> remaining = GeneratedColumn<String>(
    'remaining',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastQuestionMeta = const VerificationMeta(
    'lastQuestion',
  );
  @override
  late final GeneratedColumn<String> lastQuestion = GeneratedColumn<String>(
    'last_question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [poolKey, remaining, lastQuestion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'impromptu_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImpromptuQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pool_key')) {
      context.handle(
        _poolKeyMeta,
        poolKey.isAcceptableOrUnknown(data['pool_key']!, _poolKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_poolKeyMeta);
    }
    if (data.containsKey('remaining')) {
      context.handle(
        _remainingMeta,
        remaining.isAcceptableOrUnknown(data['remaining']!, _remainingMeta),
      );
    } else if (isInserting) {
      context.missing(_remainingMeta);
    }
    if (data.containsKey('last_question')) {
      context.handle(
        _lastQuestionMeta,
        lastQuestion.isAcceptableOrUnknown(
          data['last_question']!,
          _lastQuestionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastQuestionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {poolKey};
  @override
  ImpromptuQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImpromptuQueue(
      poolKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_key'],
      )!,
      remaining: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remaining'],
      )!,
      lastQuestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_question'],
      )!,
    );
  }

  @override
  $ImpromptuQueuesTable createAlias(String alias) {
    return $ImpromptuQueuesTable(attachedDatabase, alias);
  }
}

class ImpromptuQueue extends DataClass implements Insertable<ImpromptuQueue> {
  final String poolKey;
  final String remaining;
  final String lastQuestion;
  const ImpromptuQueue({
    required this.poolKey,
    required this.remaining,
    required this.lastQuestion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pool_key'] = Variable<String>(poolKey);
    map['remaining'] = Variable<String>(remaining);
    map['last_question'] = Variable<String>(lastQuestion);
    return map;
  }

  ImpromptuQueuesCompanion toCompanion(bool nullToAbsent) {
    return ImpromptuQueuesCompanion(
      poolKey: Value(poolKey),
      remaining: Value(remaining),
      lastQuestion: Value(lastQuestion),
    );
  }

  factory ImpromptuQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImpromptuQueue(
      poolKey: serializer.fromJson<String>(json['poolKey']),
      remaining: serializer.fromJson<String>(json['remaining']),
      lastQuestion: serializer.fromJson<String>(json['lastQuestion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'poolKey': serializer.toJson<String>(poolKey),
      'remaining': serializer.toJson<String>(remaining),
      'lastQuestion': serializer.toJson<String>(lastQuestion),
    };
  }

  ImpromptuQueue copyWith({
    String? poolKey,
    String? remaining,
    String? lastQuestion,
  }) => ImpromptuQueue(
    poolKey: poolKey ?? this.poolKey,
    remaining: remaining ?? this.remaining,
    lastQuestion: lastQuestion ?? this.lastQuestion,
  );
  ImpromptuQueue copyWithCompanion(ImpromptuQueuesCompanion data) {
    return ImpromptuQueue(
      poolKey: data.poolKey.present ? data.poolKey.value : this.poolKey,
      remaining: data.remaining.present ? data.remaining.value : this.remaining,
      lastQuestion: data.lastQuestion.present
          ? data.lastQuestion.value
          : this.lastQuestion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImpromptuQueue(')
          ..write('poolKey: $poolKey, ')
          ..write('remaining: $remaining, ')
          ..write('lastQuestion: $lastQuestion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(poolKey, remaining, lastQuestion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImpromptuQueue &&
          other.poolKey == this.poolKey &&
          other.remaining == this.remaining &&
          other.lastQuestion == this.lastQuestion);
}

class ImpromptuQueuesCompanion extends UpdateCompanion<ImpromptuQueue> {
  final Value<String> poolKey;
  final Value<String> remaining;
  final Value<String> lastQuestion;
  final Value<int> rowid;
  const ImpromptuQueuesCompanion({
    this.poolKey = const Value.absent(),
    this.remaining = const Value.absent(),
    this.lastQuestion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImpromptuQueuesCompanion.insert({
    required String poolKey,
    required String remaining,
    required String lastQuestion,
    this.rowid = const Value.absent(),
  }) : poolKey = Value(poolKey),
       remaining = Value(remaining),
       lastQuestion = Value(lastQuestion);
  static Insertable<ImpromptuQueue> custom({
    Expression<String>? poolKey,
    Expression<String>? remaining,
    Expression<String>? lastQuestion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (poolKey != null) 'pool_key': poolKey,
      if (remaining != null) 'remaining': remaining,
      if (lastQuestion != null) 'last_question': lastQuestion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImpromptuQueuesCompanion copyWith({
    Value<String>? poolKey,
    Value<String>? remaining,
    Value<String>? lastQuestion,
    Value<int>? rowid,
  }) {
    return ImpromptuQueuesCompanion(
      poolKey: poolKey ?? this.poolKey,
      remaining: remaining ?? this.remaining,
      lastQuestion: lastQuestion ?? this.lastQuestion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (poolKey.present) {
      map['pool_key'] = Variable<String>(poolKey.value);
    }
    if (remaining.present) {
      map['remaining'] = Variable<String>(remaining.value);
    }
    if (lastQuestion.present) {
      map['last_question'] = Variable<String>(lastQuestion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImpromptuQueuesCompanion(')
          ..write('poolKey: $poolKey, ')
          ..write('remaining: $remaining, ')
          ..write('lastQuestion: $lastQuestion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImpromptuWorkspacesTable extends ImpromptuWorkspaces
    with TableInfo<$ImpromptuWorkspacesTable, ImpromptuWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImpromptuWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parentSessionIdMeta = const VerificationMeta(
    'parentSessionId',
  );
  @override
  late final GeneratedColumn<String> parentSessionId = GeneratedColumn<String>(
    'parent_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _improvementMeta = const VerificationMeta(
    'improvement',
  );
  @override
  late final GeneratedColumn<String> improvement = GeneratedColumn<String>(
    'improvement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _responseKindMeta = const VerificationMeta(
    'responseKind',
  );
  @override
  late final GeneratedColumn<String> responseKind = GeneratedColumn<String>(
    'response_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetMeta = const VerificationMeta('preset');
  @override
  late final GeneratedColumn<String> preset = GeneratedColumn<String>(
    'preset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _viewStepMeta = const VerificationMeta(
    'viewStep',
  );
  @override
  late final GeneratedColumn<String> viewStep = GeneratedColumn<String>(
    'view_step',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('reveal'),
  );
  static const VerificationMeta _preparationMeta = const VerificationMeta(
    'preparation',
  );
  @override
  late final GeneratedColumn<String> preparation = GeneratedColumn<String>(
    'preparation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _scaffoldEnabledMeta = const VerificationMeta(
    'scaffoldEnabled',
  );
  @override
  late final GeneratedColumn<bool> scaffoldEnabled = GeneratedColumn<bool>(
    'scaffold_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scaffold_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scaffoldMeta = const VerificationMeta(
    'scaffold',
  );
  @override
  late final GeneratedColumn<String> scaffold = GeneratedColumn<String>(
    'scaffold',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _assessmentsMeta = const VerificationMeta(
    'assessments',
  );
  @override
  late final GeneratedColumn<String> assessments = GeneratedColumn<String>(
    'assessments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _reflectionMeta = const VerificationMeta(
    'reflection',
  );
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
    'reflection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<int> confidence = GeneratedColumn<int>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    requestKey,
    parentSessionId,
    improvement,
    responseKind,
    preset,
    viewStep,
    preparation,
    scaffoldEnabled,
    scaffold,
    assessments,
    reflection,
    confidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'impromptu_workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImpromptuWorkspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    if (data.containsKey('parent_session_id')) {
      context.handle(
        _parentSessionIdMeta,
        parentSessionId.isAcceptableOrUnknown(
          data['parent_session_id']!,
          _parentSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('improvement')) {
      context.handle(
        _improvementMeta,
        improvement.isAcceptableOrUnknown(
          data['improvement']!,
          _improvementMeta,
        ),
      );
    }
    if (data.containsKey('response_kind')) {
      context.handle(
        _responseKindMeta,
        responseKind.isAcceptableOrUnknown(
          data['response_kind']!,
          _responseKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseKindMeta);
    }
    if (data.containsKey('preset')) {
      context.handle(
        _presetMeta,
        preset.isAcceptableOrUnknown(data['preset']!, _presetMeta),
      );
    } else if (isInserting) {
      context.missing(_presetMeta);
    }
    if (data.containsKey('view_step')) {
      context.handle(
        _viewStepMeta,
        viewStep.isAcceptableOrUnknown(data['view_step']!, _viewStepMeta),
      );
    }
    if (data.containsKey('preparation')) {
      context.handle(
        _preparationMeta,
        preparation.isAcceptableOrUnknown(
          data['preparation']!,
          _preparationMeta,
        ),
      );
    }
    if (data.containsKey('scaffold_enabled')) {
      context.handle(
        _scaffoldEnabledMeta,
        scaffoldEnabled.isAcceptableOrUnknown(
          data['scaffold_enabled']!,
          _scaffoldEnabledMeta,
        ),
      );
    }
    if (data.containsKey('scaffold')) {
      context.handle(
        _scaffoldMeta,
        scaffold.isAcceptableOrUnknown(data['scaffold']!, _scaffoldMeta),
      );
    }
    if (data.containsKey('assessments')) {
      context.handle(
        _assessmentsMeta,
        assessments.isAcceptableOrUnknown(
          data['assessments']!,
          _assessmentsMeta,
        ),
      );
    }
    if (data.containsKey('reflection')) {
      context.handle(
        _reflectionMeta,
        reflection.isAcceptableOrUnknown(data['reflection']!, _reflectionMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  ImpromptuWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImpromptuWorkspace(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
      parentSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_session_id'],
      ),
      improvement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}improvement'],
      )!,
      responseKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_kind'],
      )!,
      preset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset'],
      )!,
      viewStep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}view_step'],
      )!,
      preparation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preparation'],
      )!,
      scaffoldEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scaffold_enabled'],
      )!,
      scaffold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scaffold'],
      )!,
      assessments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessments'],
      )!,
      reflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence'],
      ),
    );
  }

  @override
  $ImpromptuWorkspacesTable createAlias(String alias) {
    return $ImpromptuWorkspacesTable(attachedDatabase, alias);
  }
}

class ImpromptuWorkspace extends DataClass
    implements Insertable<ImpromptuWorkspace> {
  final String sessionId;
  final String requestKey;
  final String? parentSessionId;
  final String improvement;
  final String responseKind;
  final String preset;
  final String viewStep;
  final String preparation;
  final bool scaffoldEnabled;
  final String scaffold;
  final String assessments;
  final String reflection;
  final int? confidence;
  const ImpromptuWorkspace({
    required this.sessionId,
    required this.requestKey,
    this.parentSessionId,
    required this.improvement,
    required this.responseKind,
    required this.preset,
    required this.viewStep,
    required this.preparation,
    required this.scaffoldEnabled,
    required this.scaffold,
    required this.assessments,
    required this.reflection,
    this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['request_key'] = Variable<String>(requestKey);
    if (!nullToAbsent || parentSessionId != null) {
      map['parent_session_id'] = Variable<String>(parentSessionId);
    }
    map['improvement'] = Variable<String>(improvement);
    map['response_kind'] = Variable<String>(responseKind);
    map['preset'] = Variable<String>(preset);
    map['view_step'] = Variable<String>(viewStep);
    map['preparation'] = Variable<String>(preparation);
    map['scaffold_enabled'] = Variable<bool>(scaffoldEnabled);
    map['scaffold'] = Variable<String>(scaffold);
    map['assessments'] = Variable<String>(assessments);
    map['reflection'] = Variable<String>(reflection);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<int>(confidence);
    }
    return map;
  }

  ImpromptuWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return ImpromptuWorkspacesCompanion(
      sessionId: Value(sessionId),
      requestKey: Value(requestKey),
      parentSessionId: parentSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentSessionId),
      improvement: Value(improvement),
      responseKind: Value(responseKind),
      preset: Value(preset),
      viewStep: Value(viewStep),
      preparation: Value(preparation),
      scaffoldEnabled: Value(scaffoldEnabled),
      scaffold: Value(scaffold),
      assessments: Value(assessments),
      reflection: Value(reflection),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
    );
  }

  factory ImpromptuWorkspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImpromptuWorkspace(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      requestKey: serializer.fromJson<String>(json['requestKey']),
      parentSessionId: serializer.fromJson<String?>(json['parentSessionId']),
      improvement: serializer.fromJson<String>(json['improvement']),
      responseKind: serializer.fromJson<String>(json['responseKind']),
      preset: serializer.fromJson<String>(json['preset']),
      viewStep: serializer.fromJson<String>(json['viewStep']),
      preparation: serializer.fromJson<String>(json['preparation']),
      scaffoldEnabled: serializer.fromJson<bool>(json['scaffoldEnabled']),
      scaffold: serializer.fromJson<String>(json['scaffold']),
      assessments: serializer.fromJson<String>(json['assessments']),
      reflection: serializer.fromJson<String>(json['reflection']),
      confidence: serializer.fromJson<int?>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'requestKey': serializer.toJson<String>(requestKey),
      'parentSessionId': serializer.toJson<String?>(parentSessionId),
      'improvement': serializer.toJson<String>(improvement),
      'responseKind': serializer.toJson<String>(responseKind),
      'preset': serializer.toJson<String>(preset),
      'viewStep': serializer.toJson<String>(viewStep),
      'preparation': serializer.toJson<String>(preparation),
      'scaffoldEnabled': serializer.toJson<bool>(scaffoldEnabled),
      'scaffold': serializer.toJson<String>(scaffold),
      'assessments': serializer.toJson<String>(assessments),
      'reflection': serializer.toJson<String>(reflection),
      'confidence': serializer.toJson<int?>(confidence),
    };
  }

  ImpromptuWorkspace copyWith({
    String? sessionId,
    String? requestKey,
    Value<String?> parentSessionId = const Value.absent(),
    String? improvement,
    String? responseKind,
    String? preset,
    String? viewStep,
    String? preparation,
    bool? scaffoldEnabled,
    String? scaffold,
    String? assessments,
    String? reflection,
    Value<int?> confidence = const Value.absent(),
  }) => ImpromptuWorkspace(
    sessionId: sessionId ?? this.sessionId,
    requestKey: requestKey ?? this.requestKey,
    parentSessionId: parentSessionId.present
        ? parentSessionId.value
        : this.parentSessionId,
    improvement: improvement ?? this.improvement,
    responseKind: responseKind ?? this.responseKind,
    preset: preset ?? this.preset,
    viewStep: viewStep ?? this.viewStep,
    preparation: preparation ?? this.preparation,
    scaffoldEnabled: scaffoldEnabled ?? this.scaffoldEnabled,
    scaffold: scaffold ?? this.scaffold,
    assessments: assessments ?? this.assessments,
    reflection: reflection ?? this.reflection,
    confidence: confidence.present ? confidence.value : this.confidence,
  );
  ImpromptuWorkspace copyWithCompanion(ImpromptuWorkspacesCompanion data) {
    return ImpromptuWorkspace(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
      parentSessionId: data.parentSessionId.present
          ? data.parentSessionId.value
          : this.parentSessionId,
      improvement: data.improvement.present
          ? data.improvement.value
          : this.improvement,
      responseKind: data.responseKind.present
          ? data.responseKind.value
          : this.responseKind,
      preset: data.preset.present ? data.preset.value : this.preset,
      viewStep: data.viewStep.present ? data.viewStep.value : this.viewStep,
      preparation: data.preparation.present
          ? data.preparation.value
          : this.preparation,
      scaffoldEnabled: data.scaffoldEnabled.present
          ? data.scaffoldEnabled.value
          : this.scaffoldEnabled,
      scaffold: data.scaffold.present ? data.scaffold.value : this.scaffold,
      assessments: data.assessments.present
          ? data.assessments.value
          : this.assessments,
      reflection: data.reflection.present
          ? data.reflection.value
          : this.reflection,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImpromptuWorkspace(')
          ..write('sessionId: $sessionId, ')
          ..write('requestKey: $requestKey, ')
          ..write('parentSessionId: $parentSessionId, ')
          ..write('improvement: $improvement, ')
          ..write('responseKind: $responseKind, ')
          ..write('preset: $preset, ')
          ..write('viewStep: $viewStep, ')
          ..write('preparation: $preparation, ')
          ..write('scaffoldEnabled: $scaffoldEnabled, ')
          ..write('scaffold: $scaffold, ')
          ..write('assessments: $assessments, ')
          ..write('reflection: $reflection, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    requestKey,
    parentSessionId,
    improvement,
    responseKind,
    preset,
    viewStep,
    preparation,
    scaffoldEnabled,
    scaffold,
    assessments,
    reflection,
    confidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImpromptuWorkspace &&
          other.sessionId == this.sessionId &&
          other.requestKey == this.requestKey &&
          other.parentSessionId == this.parentSessionId &&
          other.improvement == this.improvement &&
          other.responseKind == this.responseKind &&
          other.preset == this.preset &&
          other.viewStep == this.viewStep &&
          other.preparation == this.preparation &&
          other.scaffoldEnabled == this.scaffoldEnabled &&
          other.scaffold == this.scaffold &&
          other.assessments == this.assessments &&
          other.reflection == this.reflection &&
          other.confidence == this.confidence);
}

class ImpromptuWorkspacesCompanion extends UpdateCompanion<ImpromptuWorkspace> {
  final Value<String> sessionId;
  final Value<String> requestKey;
  final Value<String?> parentSessionId;
  final Value<String> improvement;
  final Value<String> responseKind;
  final Value<String> preset;
  final Value<String> viewStep;
  final Value<String> preparation;
  final Value<bool> scaffoldEnabled;
  final Value<String> scaffold;
  final Value<String> assessments;
  final Value<String> reflection;
  final Value<int?> confidence;
  final Value<int> rowid;
  const ImpromptuWorkspacesCompanion({
    this.sessionId = const Value.absent(),
    this.requestKey = const Value.absent(),
    this.parentSessionId = const Value.absent(),
    this.improvement = const Value.absent(),
    this.responseKind = const Value.absent(),
    this.preset = const Value.absent(),
    this.viewStep = const Value.absent(),
    this.preparation = const Value.absent(),
    this.scaffoldEnabled = const Value.absent(),
    this.scaffold = const Value.absent(),
    this.assessments = const Value.absent(),
    this.reflection = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImpromptuWorkspacesCompanion.insert({
    required String sessionId,
    required String requestKey,
    this.parentSessionId = const Value.absent(),
    this.improvement = const Value.absent(),
    required String responseKind,
    required String preset,
    this.viewStep = const Value.absent(),
    this.preparation = const Value.absent(),
    this.scaffoldEnabled = const Value.absent(),
    this.scaffold = const Value.absent(),
    this.assessments = const Value.absent(),
    this.reflection = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       requestKey = Value(requestKey),
       responseKind = Value(responseKind),
       preset = Value(preset);
  static Insertable<ImpromptuWorkspace> custom({
    Expression<String>? sessionId,
    Expression<String>? requestKey,
    Expression<String>? parentSessionId,
    Expression<String>? improvement,
    Expression<String>? responseKind,
    Expression<String>? preset,
    Expression<String>? viewStep,
    Expression<String>? preparation,
    Expression<bool>? scaffoldEnabled,
    Expression<String>? scaffold,
    Expression<String>? assessments,
    Expression<String>? reflection,
    Expression<int>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (requestKey != null) 'request_key': requestKey,
      if (parentSessionId != null) 'parent_session_id': parentSessionId,
      if (improvement != null) 'improvement': improvement,
      if (responseKind != null) 'response_kind': responseKind,
      if (preset != null) 'preset': preset,
      if (viewStep != null) 'view_step': viewStep,
      if (preparation != null) 'preparation': preparation,
      if (scaffoldEnabled != null) 'scaffold_enabled': scaffoldEnabled,
      if (scaffold != null) 'scaffold': scaffold,
      if (assessments != null) 'assessments': assessments,
      if (reflection != null) 'reflection': reflection,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImpromptuWorkspacesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? requestKey,
    Value<String?>? parentSessionId,
    Value<String>? improvement,
    Value<String>? responseKind,
    Value<String>? preset,
    Value<String>? viewStep,
    Value<String>? preparation,
    Value<bool>? scaffoldEnabled,
    Value<String>? scaffold,
    Value<String>? assessments,
    Value<String>? reflection,
    Value<int?>? confidence,
    Value<int>? rowid,
  }) {
    return ImpromptuWorkspacesCompanion(
      sessionId: sessionId ?? this.sessionId,
      requestKey: requestKey ?? this.requestKey,
      parentSessionId: parentSessionId ?? this.parentSessionId,
      improvement: improvement ?? this.improvement,
      responseKind: responseKind ?? this.responseKind,
      preset: preset ?? this.preset,
      viewStep: viewStep ?? this.viewStep,
      preparation: preparation ?? this.preparation,
      scaffoldEnabled: scaffoldEnabled ?? this.scaffoldEnabled,
      scaffold: scaffold ?? this.scaffold,
      assessments: assessments ?? this.assessments,
      reflection: reflection ?? this.reflection,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    if (parentSessionId.present) {
      map['parent_session_id'] = Variable<String>(parentSessionId.value);
    }
    if (improvement.present) {
      map['improvement'] = Variable<String>(improvement.value);
    }
    if (responseKind.present) {
      map['response_kind'] = Variable<String>(responseKind.value);
    }
    if (preset.present) {
      map['preset'] = Variable<String>(preset.value);
    }
    if (viewStep.present) {
      map['view_step'] = Variable<String>(viewStep.value);
    }
    if (preparation.present) {
      map['preparation'] = Variable<String>(preparation.value);
    }
    if (scaffoldEnabled.present) {
      map['scaffold_enabled'] = Variable<bool>(scaffoldEnabled.value);
    }
    if (scaffold.present) {
      map['scaffold'] = Variable<String>(scaffold.value);
    }
    if (assessments.present) {
      map['assessments'] = Variable<String>(assessments.value);
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<int>(confidence.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImpromptuWorkspacesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('requestKey: $requestKey, ')
          ..write('parentSessionId: $parentSessionId, ')
          ..write('improvement: $improvement, ')
          ..write('responseKind: $responseKind, ')
          ..write('preset: $preset, ')
          ..write('viewStep: $viewStep, ')
          ..write('preparation: $preparation, ')
          ..write('scaffoldEnabled: $scaffoldEnabled, ')
          ..write('scaffold: $scaffold, ')
          ..write('assessments: $assessments, ')
          ..write('reflection: $reflection, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotMeta = const VerificationMeta(
    'snapshot',
  );
  @override
  late final GeneratedColumn<String> snapshot = GeneratedColumn<String>(
    'snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdUtcMsMeta = const VerificationMeta(
    'createdUtcMs',
  );
  @override
  late final GeneratedColumn<int> createdUtcMs = GeneratedColumn<int>(
    'created_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version, snapshot, createdUtcMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('snapshot')) {
      context.handle(
        _snapshotMeta,
        snapshot.isAcceptableOrUnknown(data['snapshot']!, _snapshotMeta),
      );
    } else if (isInserting) {
      context.missing(_snapshotMeta);
    }
    if (data.containsKey('created_utc_ms')) {
      context.handle(
        _createdUtcMsMeta,
        createdUtcMs.isAcceptableOrUnknown(
          data['created_utc_ms']!,
          _createdUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, version};
  @override
  CustomExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot'],
      )!,
      createdUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_utc_ms'],
      )!,
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }
}

class CustomExercise extends DataClass implements Insertable<CustomExercise> {
  final String id;
  final int version;
  final String snapshot;
  final int createdUtcMs;
  const CustomExercise({
    required this.id,
    required this.version,
    required this.snapshot,
    required this.createdUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['snapshot'] = Variable<String>(snapshot);
    map['created_utc_ms'] = Variable<int>(createdUtcMs);
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      version: Value(version),
      snapshot: Value(snapshot),
      createdUtcMs: Value(createdUtcMs),
    );
  }

  factory CustomExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExercise(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      snapshot: serializer.fromJson<String>(json['snapshot']),
      createdUtcMs: serializer.fromJson<int>(json['createdUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'snapshot': serializer.toJson<String>(snapshot),
      'createdUtcMs': serializer.toJson<int>(createdUtcMs),
    };
  }

  CustomExercise copyWith({
    String? id,
    int? version,
    String? snapshot,
    int? createdUtcMs,
  }) => CustomExercise(
    id: id ?? this.id,
    version: version ?? this.version,
    snapshot: snapshot ?? this.snapshot,
    createdUtcMs: createdUtcMs ?? this.createdUtcMs,
  );
  CustomExercise copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExercise(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      snapshot: data.snapshot.present ? data.snapshot.value : this.snapshot,
      createdUtcMs: data.createdUtcMs.present
          ? data.createdUtcMs.value
          : this.createdUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercise(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('snapshot: $snapshot, ')
          ..write('createdUtcMs: $createdUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, snapshot, createdUtcMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExercise &&
          other.id == this.id &&
          other.version == this.version &&
          other.snapshot == this.snapshot &&
          other.createdUtcMs == this.createdUtcMs);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> snapshot;
  final Value<int> createdUtcMs;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.snapshot = const Value.absent(),
    this.createdUtcMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    required String id,
    required int version,
    required String snapshot,
    required int createdUtcMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       version = Value(version),
       snapshot = Value(snapshot),
       createdUtcMs = Value(createdUtcMs);
  static Insertable<CustomExercise> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? snapshot,
    Expression<int>? createdUtcMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (snapshot != null) 'snapshot': snapshot,
      if (createdUtcMs != null) 'created_utc_ms': createdUtcMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? snapshot,
    Value<int>? createdUtcMs,
    Value<int>? rowid,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      snapshot: snapshot ?? this.snapshot,
      createdUtcMs: createdUtcMs ?? this.createdUtcMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (snapshot.present) {
      map['snapshot'] = Variable<String>(snapshot.value);
    }
    if (createdUtcMs.present) {
      map['created_utc_ms'] = Variable<int>(createdUtcMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('snapshot: $snapshot, ')
          ..write('createdUtcMs: $createdUtcMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PracticeContextsTable extends PracticeContexts
    with TableInfo<$PracticeContextsTable, PracticeContext> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _parentSessionIdMeta = const VerificationMeta(
    'parentSessionId',
  );
  @override
  late final GeneratedColumn<String> parentSessionId = GeneratedColumn<String>(
    'parent_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionsMeta = const VerificationMeta(
    'conditions',
  );
  @override
  late final GeneratedColumn<String> conditions = GeneratedColumn<String>(
    'conditions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    requestKey,
    parentSessionId,
    label,
    conditions,
    target,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeContext> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    if (data.containsKey('parent_session_id')) {
      context.handle(
        _parentSessionIdMeta,
        parentSessionId.isAcceptableOrUnknown(
          data['parent_session_id']!,
          _parentSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('conditions')) {
      context.handle(
        _conditionsMeta,
        conditions.isAcceptableOrUnknown(data['conditions']!, _conditionsMeta),
      );
    } else if (isInserting) {
      context.missing(_conditionsMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  PracticeContext map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeContext(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
      parentSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_session_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      conditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
    );
  }

  @override
  $PracticeContextsTable createAlias(String alias) {
    return $PracticeContextsTable(attachedDatabase, alias);
  }
}

class PracticeContext extends DataClass implements Insertable<PracticeContext> {
  final String sessionId;
  final String requestKey;
  final String? parentSessionId;
  final String label;
  final String conditions;
  final String target;
  const PracticeContext({
    required this.sessionId,
    required this.requestKey,
    this.parentSessionId,
    required this.label,
    required this.conditions,
    required this.target,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['request_key'] = Variable<String>(requestKey);
    if (!nullToAbsent || parentSessionId != null) {
      map['parent_session_id'] = Variable<String>(parentSessionId);
    }
    map['label'] = Variable<String>(label);
    map['conditions'] = Variable<String>(conditions);
    map['target'] = Variable<String>(target);
    return map;
  }

  PracticeContextsCompanion toCompanion(bool nullToAbsent) {
    return PracticeContextsCompanion(
      sessionId: Value(sessionId),
      requestKey: Value(requestKey),
      parentSessionId: parentSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentSessionId),
      label: Value(label),
      conditions: Value(conditions),
      target: Value(target),
    );
  }

  factory PracticeContext.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeContext(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      requestKey: serializer.fromJson<String>(json['requestKey']),
      parentSessionId: serializer.fromJson<String?>(json['parentSessionId']),
      label: serializer.fromJson<String>(json['label']),
      conditions: serializer.fromJson<String>(json['conditions']),
      target: serializer.fromJson<String>(json['target']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'requestKey': serializer.toJson<String>(requestKey),
      'parentSessionId': serializer.toJson<String?>(parentSessionId),
      'label': serializer.toJson<String>(label),
      'conditions': serializer.toJson<String>(conditions),
      'target': serializer.toJson<String>(target),
    };
  }

  PracticeContext copyWith({
    String? sessionId,
    String? requestKey,
    Value<String?> parentSessionId = const Value.absent(),
    String? label,
    String? conditions,
    String? target,
  }) => PracticeContext(
    sessionId: sessionId ?? this.sessionId,
    requestKey: requestKey ?? this.requestKey,
    parentSessionId: parentSessionId.present
        ? parentSessionId.value
        : this.parentSessionId,
    label: label ?? this.label,
    conditions: conditions ?? this.conditions,
    target: target ?? this.target,
  );
  PracticeContext copyWithCompanion(PracticeContextsCompanion data) {
    return PracticeContext(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
      parentSessionId: data.parentSessionId.present
          ? data.parentSessionId.value
          : this.parentSessionId,
      label: data.label.present ? data.label.value : this.label,
      conditions: data.conditions.present
          ? data.conditions.value
          : this.conditions,
      target: data.target.present ? data.target.value : this.target,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeContext(')
          ..write('sessionId: $sessionId, ')
          ..write('requestKey: $requestKey, ')
          ..write('parentSessionId: $parentSessionId, ')
          ..write('label: $label, ')
          ..write('conditions: $conditions, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    requestKey,
    parentSessionId,
    label,
    conditions,
    target,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeContext &&
          other.sessionId == this.sessionId &&
          other.requestKey == this.requestKey &&
          other.parentSessionId == this.parentSessionId &&
          other.label == this.label &&
          other.conditions == this.conditions &&
          other.target == this.target);
}

class PracticeContextsCompanion extends UpdateCompanion<PracticeContext> {
  final Value<String> sessionId;
  final Value<String> requestKey;
  final Value<String?> parentSessionId;
  final Value<String> label;
  final Value<String> conditions;
  final Value<String> target;
  final Value<int> rowid;
  const PracticeContextsCompanion({
    this.sessionId = const Value.absent(),
    this.requestKey = const Value.absent(),
    this.parentSessionId = const Value.absent(),
    this.label = const Value.absent(),
    this.conditions = const Value.absent(),
    this.target = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PracticeContextsCompanion.insert({
    required String sessionId,
    required String requestKey,
    this.parentSessionId = const Value.absent(),
    required String label,
    required String conditions,
    required String target,
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       requestKey = Value(requestKey),
       label = Value(label),
       conditions = Value(conditions),
       target = Value(target);
  static Insertable<PracticeContext> custom({
    Expression<String>? sessionId,
    Expression<String>? requestKey,
    Expression<String>? parentSessionId,
    Expression<String>? label,
    Expression<String>? conditions,
    Expression<String>? target,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (requestKey != null) 'request_key': requestKey,
      if (parentSessionId != null) 'parent_session_id': parentSessionId,
      if (label != null) 'label': label,
      if (conditions != null) 'conditions': conditions,
      if (target != null) 'target': target,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PracticeContextsCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? requestKey,
    Value<String?>? parentSessionId,
    Value<String>? label,
    Value<String>? conditions,
    Value<String>? target,
    Value<int>? rowid,
  }) {
    return PracticeContextsCompanion(
      sessionId: sessionId ?? this.sessionId,
      requestKey: requestKey ?? this.requestKey,
      parentSessionId: parentSessionId ?? this.parentSessionId,
      label: label ?? this.label,
      conditions: conditions ?? this.conditions,
      target: target ?? this.target,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    if (parentSessionId.present) {
      map['parent_session_id'] = Variable<String>(parentSessionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (conditions.present) {
      map['conditions'] = Variable<String>(conditions.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeContextsCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('requestKey: $requestKey, ')
          ..write('parentSessionId: $parentSessionId, ')
          ..write('label: $label, ')
          ..write('conditions: $conditions, ')
          ..write('target: $target, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecallSchedulesTable extends RecallSchedules
    with TableInfo<$RecallSchedulesTable, RecallSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecallSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES practice_sessions (id)',
    ),
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedLocalDateMeta = const VerificationMeta(
    'observedLocalDate',
  );
  @override
  late final GeneratedColumn<String> observedLocalDate =
      GeneratedColumn<String>(
        'observed_local_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originalOffsetMinutesMeta =
      const VerificationMeta('originalOffsetMinutes');
  @override
  late final GeneratedColumn<int> originalOffsetMinutes = GeneratedColumn<int>(
    'original_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedUtcMsMeta = const VerificationMeta(
    'observedUtcMs',
  );
  @override
  late final GeneratedColumn<int> observedUtcMs = GeneratedColumn<int>(
    'observed_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalIndexMeta = const VerificationMeta(
    'intervalIndex',
  );
  @override
  late final GeneratedColumn<int> intervalIndex = GeneratedColumn<int>(
    'interval_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedDateMeta = const VerificationMeta(
    'recommendedDate',
  );
  @override
  late final GeneratedColumn<String> recommendedDate = GeneratedColumn<String>(
    'recommended_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overrideDateMeta = const VerificationMeta(
    'overrideDate',
  );
  @override
  late final GeneratedColumn<String> overrideDate = GeneratedColumn<String>(
    'override_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  @override
  late final GeneratedColumn<bool> paused = GeneratedColumn<bool>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    sessionId,
    observation,
    observedLocalDate,
    originalOffsetMinutes,
    observedUtcMs,
    intervalIndex,
    intervalDays,
    recommendedDate,
    overrideDate,
    paused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recall_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecallSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationMeta);
    }
    if (data.containsKey('observed_local_date')) {
      context.handle(
        _observedLocalDateMeta,
        observedLocalDate.isAcceptableOrUnknown(
          data['observed_local_date']!,
          _observedLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observedLocalDateMeta);
    }
    if (data.containsKey('original_offset_minutes')) {
      context.handle(
        _originalOffsetMinutesMeta,
        originalOffsetMinutes.isAcceptableOrUnknown(
          data['original_offset_minutes']!,
          _originalOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalOffsetMinutesMeta);
    }
    if (data.containsKey('observed_utc_ms')) {
      context.handle(
        _observedUtcMsMeta,
        observedUtcMs.isAcceptableOrUnknown(
          data['observed_utc_ms']!,
          _observedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observedUtcMsMeta);
    }
    if (data.containsKey('interval_index')) {
      context.handle(
        _intervalIndexMeta,
        intervalIndex.isAcceptableOrUnknown(
          data['interval_index']!,
          _intervalIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalIndexMeta);
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalDaysMeta);
    }
    if (data.containsKey('recommended_date')) {
      context.handle(
        _recommendedDateMeta,
        recommendedDate.isAcceptableOrUnknown(
          data['recommended_date']!,
          _recommendedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedDateMeta);
    }
    if (data.containsKey('override_date')) {
      context.handle(
        _overrideDateMeta,
        overrideDate.isAcceptableOrUnknown(
          data['override_date']!,
          _overrideDateMeta,
        ),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  RecallSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecallSchedule(
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      )!,
      observedLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observed_local_date'],
      )!,
      originalOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_offset_minutes'],
      )!,
      observedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}observed_utc_ms'],
      )!,
      intervalIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_index'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      recommendedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_date'],
      )!,
      overrideDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_date'],
      ),
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}paused'],
      )!,
    );
  }

  @override
  $RecallSchedulesTable createAlias(String alias) {
    return $RecallSchedulesTable(attachedDatabase, alias);
  }
}

class RecallSchedule extends DataClass implements Insertable<RecallSchedule> {
  final int sequence;
  final String sessionId;
  final String observation;
  final String observedLocalDate;
  final int originalOffsetMinutes;
  final int observedUtcMs;
  final int intervalIndex;
  final int intervalDays;
  final String recommendedDate;
  final String? overrideDate;
  final bool paused;
  const RecallSchedule({
    required this.sequence,
    required this.sessionId,
    required this.observation,
    required this.observedLocalDate,
    required this.originalOffsetMinutes,
    required this.observedUtcMs,
    required this.intervalIndex,
    required this.intervalDays,
    required this.recommendedDate,
    this.overrideDate,
    required this.paused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['session_id'] = Variable<String>(sessionId);
    map['observation'] = Variable<String>(observation);
    map['observed_local_date'] = Variable<String>(observedLocalDate);
    map['original_offset_minutes'] = Variable<int>(originalOffsetMinutes);
    map['observed_utc_ms'] = Variable<int>(observedUtcMs);
    map['interval_index'] = Variable<int>(intervalIndex);
    map['interval_days'] = Variable<int>(intervalDays);
    map['recommended_date'] = Variable<String>(recommendedDate);
    if (!nullToAbsent || overrideDate != null) {
      map['override_date'] = Variable<String>(overrideDate);
    }
    map['paused'] = Variable<bool>(paused);
    return map;
  }

  RecallSchedulesCompanion toCompanion(bool nullToAbsent) {
    return RecallSchedulesCompanion(
      sequence: Value(sequence),
      sessionId: Value(sessionId),
      observation: Value(observation),
      observedLocalDate: Value(observedLocalDate),
      originalOffsetMinutes: Value(originalOffsetMinutes),
      observedUtcMs: Value(observedUtcMs),
      intervalIndex: Value(intervalIndex),
      intervalDays: Value(intervalDays),
      recommendedDate: Value(recommendedDate),
      overrideDate: overrideDate == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideDate),
      paused: Value(paused),
    );
  }

  factory RecallSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecallSchedule(
      sequence: serializer.fromJson<int>(json['sequence']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      observation: serializer.fromJson<String>(json['observation']),
      observedLocalDate: serializer.fromJson<String>(json['observedLocalDate']),
      originalOffsetMinutes: serializer.fromJson<int>(
        json['originalOffsetMinutes'],
      ),
      observedUtcMs: serializer.fromJson<int>(json['observedUtcMs']),
      intervalIndex: serializer.fromJson<int>(json['intervalIndex']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      recommendedDate: serializer.fromJson<String>(json['recommendedDate']),
      overrideDate: serializer.fromJson<String?>(json['overrideDate']),
      paused: serializer.fromJson<bool>(json['paused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'sessionId': serializer.toJson<String>(sessionId),
      'observation': serializer.toJson<String>(observation),
      'observedLocalDate': serializer.toJson<String>(observedLocalDate),
      'originalOffsetMinutes': serializer.toJson<int>(originalOffsetMinutes),
      'observedUtcMs': serializer.toJson<int>(observedUtcMs),
      'intervalIndex': serializer.toJson<int>(intervalIndex),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'recommendedDate': serializer.toJson<String>(recommendedDate),
      'overrideDate': serializer.toJson<String?>(overrideDate),
      'paused': serializer.toJson<bool>(paused),
    };
  }

  RecallSchedule copyWith({
    int? sequence,
    String? sessionId,
    String? observation,
    String? observedLocalDate,
    int? originalOffsetMinutes,
    int? observedUtcMs,
    int? intervalIndex,
    int? intervalDays,
    String? recommendedDate,
    Value<String?> overrideDate = const Value.absent(),
    bool? paused,
  }) => RecallSchedule(
    sequence: sequence ?? this.sequence,
    sessionId: sessionId ?? this.sessionId,
    observation: observation ?? this.observation,
    observedLocalDate: observedLocalDate ?? this.observedLocalDate,
    originalOffsetMinutes: originalOffsetMinutes ?? this.originalOffsetMinutes,
    observedUtcMs: observedUtcMs ?? this.observedUtcMs,
    intervalIndex: intervalIndex ?? this.intervalIndex,
    intervalDays: intervalDays ?? this.intervalDays,
    recommendedDate: recommendedDate ?? this.recommendedDate,
    overrideDate: overrideDate.present ? overrideDate.value : this.overrideDate,
    paused: paused ?? this.paused,
  );
  RecallSchedule copyWithCompanion(RecallSchedulesCompanion data) {
    return RecallSchedule(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      observedLocalDate: data.observedLocalDate.present
          ? data.observedLocalDate.value
          : this.observedLocalDate,
      originalOffsetMinutes: data.originalOffsetMinutes.present
          ? data.originalOffsetMinutes.value
          : this.originalOffsetMinutes,
      observedUtcMs: data.observedUtcMs.present
          ? data.observedUtcMs.value
          : this.observedUtcMs,
      intervalIndex: data.intervalIndex.present
          ? data.intervalIndex.value
          : this.intervalIndex,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      recommendedDate: data.recommendedDate.present
          ? data.recommendedDate.value
          : this.recommendedDate,
      overrideDate: data.overrideDate.present
          ? data.overrideDate.value
          : this.overrideDate,
      paused: data.paused.present ? data.paused.value : this.paused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecallSchedule(')
          ..write('sequence: $sequence, ')
          ..write('sessionId: $sessionId, ')
          ..write('observation: $observation, ')
          ..write('observedLocalDate: $observedLocalDate, ')
          ..write('originalOffsetMinutes: $originalOffsetMinutes, ')
          ..write('observedUtcMs: $observedUtcMs, ')
          ..write('intervalIndex: $intervalIndex, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('recommendedDate: $recommendedDate, ')
          ..write('overrideDate: $overrideDate, ')
          ..write('paused: $paused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequence,
    sessionId,
    observation,
    observedLocalDate,
    originalOffsetMinutes,
    observedUtcMs,
    intervalIndex,
    intervalDays,
    recommendedDate,
    overrideDate,
    paused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecallSchedule &&
          other.sequence == this.sequence &&
          other.sessionId == this.sessionId &&
          other.observation == this.observation &&
          other.observedLocalDate == this.observedLocalDate &&
          other.originalOffsetMinutes == this.originalOffsetMinutes &&
          other.observedUtcMs == this.observedUtcMs &&
          other.intervalIndex == this.intervalIndex &&
          other.intervalDays == this.intervalDays &&
          other.recommendedDate == this.recommendedDate &&
          other.overrideDate == this.overrideDate &&
          other.paused == this.paused);
}

class RecallSchedulesCompanion extends UpdateCompanion<RecallSchedule> {
  final Value<int> sequence;
  final Value<String> sessionId;
  final Value<String> observation;
  final Value<String> observedLocalDate;
  final Value<int> originalOffsetMinutes;
  final Value<int> observedUtcMs;
  final Value<int> intervalIndex;
  final Value<int> intervalDays;
  final Value<String> recommendedDate;
  final Value<String?> overrideDate;
  final Value<bool> paused;
  final Value<int> rowid;
  const RecallSchedulesCompanion({
    this.sequence = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.observation = const Value.absent(),
    this.observedLocalDate = const Value.absent(),
    this.originalOffsetMinutes = const Value.absent(),
    this.observedUtcMs = const Value.absent(),
    this.intervalIndex = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.recommendedDate = const Value.absent(),
    this.overrideDate = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecallSchedulesCompanion.insert({
    required int sequence,
    required String sessionId,
    required String observation,
    required String observedLocalDate,
    required int originalOffsetMinutes,
    required int observedUtcMs,
    required int intervalIndex,
    required int intervalDays,
    required String recommendedDate,
    this.overrideDate = const Value.absent(),
    this.paused = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sequence = Value(sequence),
       sessionId = Value(sessionId),
       observation = Value(observation),
       observedLocalDate = Value(observedLocalDate),
       originalOffsetMinutes = Value(originalOffsetMinutes),
       observedUtcMs = Value(observedUtcMs),
       intervalIndex = Value(intervalIndex),
       intervalDays = Value(intervalDays),
       recommendedDate = Value(recommendedDate);
  static Insertable<RecallSchedule> custom({
    Expression<int>? sequence,
    Expression<String>? sessionId,
    Expression<String>? observation,
    Expression<String>? observedLocalDate,
    Expression<int>? originalOffsetMinutes,
    Expression<int>? observedUtcMs,
    Expression<int>? intervalIndex,
    Expression<int>? intervalDays,
    Expression<String>? recommendedDate,
    Expression<String>? overrideDate,
    Expression<bool>? paused,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (sessionId != null) 'session_id': sessionId,
      if (observation != null) 'observation': observation,
      if (observedLocalDate != null) 'observed_local_date': observedLocalDate,
      if (originalOffsetMinutes != null)
        'original_offset_minutes': originalOffsetMinutes,
      if (observedUtcMs != null) 'observed_utc_ms': observedUtcMs,
      if (intervalIndex != null) 'interval_index': intervalIndex,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (recommendedDate != null) 'recommended_date': recommendedDate,
      if (overrideDate != null) 'override_date': overrideDate,
      if (paused != null) 'paused': paused,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecallSchedulesCompanion copyWith({
    Value<int>? sequence,
    Value<String>? sessionId,
    Value<String>? observation,
    Value<String>? observedLocalDate,
    Value<int>? originalOffsetMinutes,
    Value<int>? observedUtcMs,
    Value<int>? intervalIndex,
    Value<int>? intervalDays,
    Value<String>? recommendedDate,
    Value<String?>? overrideDate,
    Value<bool>? paused,
    Value<int>? rowid,
  }) {
    return RecallSchedulesCompanion(
      sequence: sequence ?? this.sequence,
      sessionId: sessionId ?? this.sessionId,
      observation: observation ?? this.observation,
      observedLocalDate: observedLocalDate ?? this.observedLocalDate,
      originalOffsetMinutes:
          originalOffsetMinutes ?? this.originalOffsetMinutes,
      observedUtcMs: observedUtcMs ?? this.observedUtcMs,
      intervalIndex: intervalIndex ?? this.intervalIndex,
      intervalDays: intervalDays ?? this.intervalDays,
      recommendedDate: recommendedDate ?? this.recommendedDate,
      overrideDate: overrideDate ?? this.overrideDate,
      paused: paused ?? this.paused,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (observedLocalDate.present) {
      map['observed_local_date'] = Variable<String>(observedLocalDate.value);
    }
    if (originalOffsetMinutes.present) {
      map['original_offset_minutes'] = Variable<int>(
        originalOffsetMinutes.value,
      );
    }
    if (observedUtcMs.present) {
      map['observed_utc_ms'] = Variable<int>(observedUtcMs.value);
    }
    if (intervalIndex.present) {
      map['interval_index'] = Variable<int>(intervalIndex.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (recommendedDate.present) {
      map['recommended_date'] = Variable<String>(recommendedDate.value);
    }
    if (overrideDate.present) {
      map['override_date'] = Variable<String>(overrideDate.value);
    }
    if (paused.present) {
      map['paused'] = Variable<bool>(paused.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecallSchedulesCompanion(')
          ..write('sequence: $sequence, ')
          ..write('sessionId: $sessionId, ')
          ..write('observation: $observation, ')
          ..write('observedLocalDate: $observedLocalDate, ')
          ..write('originalOffsetMinutes: $originalOffsetMinutes, ')
          ..write('observedUtcMs: $observedUtcMs, ')
          ..write('intervalIndex: $intervalIndex, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('recommendedDate: $recommendedDate, ')
          ..write('overrideDate: $overrideDate, ')
          ..write('paused: $paused, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PracticeSessionsTable practiceSessions = $PracticeSessionsTable(
    this,
  );
  late final $ResponsesTable responses = $ResponsesTable(this);
  late final $TimingSegmentsTable timingSegments = $TimingSegmentsTable(this);
  late final $ReviewRecordsTable reviewRecords = $ReviewRecordsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $WritingWorkspacesTable writingWorkspaces =
      $WritingWorkspacesTable(this);
  late final $ReadingWorkspacesTable readingWorkspaces =
      $ReadingWorkspacesTable(this);
  late final $AudioRecordingsTable audioRecordings = $AudioRecordingsTable(
    this,
  );
  late final $AudioObservationsTable audioObservations =
      $AudioObservationsTable(this);
  late final $MemorySpeechesTable memorySpeeches = $MemorySpeechesTable(this);
  late final $MemoryVersionsTable memoryVersions = $MemoryVersionsTable(this);
  late final $MemoryWorkspacesTable memoryWorkspaces = $MemoryWorkspacesTable(
    this,
  );
  late final $DebateWorkspacesTable debateWorkspaces = $DebateWorkspacesTable(
    this,
  );
  late final $DebateStagesTable debateStages = $DebateStagesTable(this);
  late final $ImpromptuQueuesTable impromptuQueues = $ImpromptuQueuesTable(
    this,
  );
  late final $ImpromptuWorkspacesTable impromptuWorkspaces =
      $ImpromptuWorkspacesTable(this);
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(
    this,
  );
  late final $PracticeContextsTable practiceContexts = $PracticeContextsTable(
    this,
  );
  late final $RecallSchedulesTable recallSchedules = $RecallSchedulesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    practiceSessions,
    responses,
    timingSegments,
    reviewRecords,
    appSettings,
    writingWorkspaces,
    readingWorkspaces,
    audioRecordings,
    audioObservations,
    memorySpeeches,
    memoryVersions,
    memoryWorkspaces,
    debateWorkspaces,
    debateStages,
    impromptuQueues,
    impromptuWorkspaces,
    customExercises,
    practiceContexts,
    recallSchedules,
  ];
}

typedef $$PracticeSessionsTableCreateCompanionBuilder =
    PracticeSessionsCompanion Function({
      required String id,
      required String exerciseId,
      required int exerciseVersion,
      required String moduleId,
      required String snapshot,
      required String status,
      required String stage,
      required int createdUtcMs,
      required int updatedUtcMs,
      Value<int?> startedUtcMs,
      Value<int?> completedUtcMs,
      required String localPracticeDate,
      required int originalOffsetMinutes,
      Value<int> rowid,
    });
typedef $$PracticeSessionsTableUpdateCompanionBuilder =
    PracticeSessionsCompanion Function({
      Value<String> id,
      Value<String> exerciseId,
      Value<int> exerciseVersion,
      Value<String> moduleId,
      Value<String> snapshot,
      Value<String> status,
      Value<String> stage,
      Value<int> createdUtcMs,
      Value<int> updatedUtcMs,
      Value<int?> startedUtcMs,
      Value<int?> completedUtcMs,
      Value<String> localPracticeDate,
      Value<int> originalOffsetMinutes,
      Value<int> rowid,
    });

final class $$PracticeSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PracticeSessionsTable, PracticeSession> {
  $$PracticeSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ResponsesTable, List<Response>>
  _responsesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.responses,
    aliasName: 'practice_sessions__id__responses__session_id',
  );

  $$ResponsesTableProcessedTableManager get responsesRefs {
    final manager = $$ResponsesTableTableManager(
      $_db,
      $_db.responses,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_responsesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimingSegmentsTable, List<TimingSegment>>
  _timingSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timingSegments,
    aliasName: 'practice_sessions__id__timing_segments__session_id',
  );

  $$TimingSegmentsTableProcessedTableManager get timingSegmentsRefs {
    final manager = $$TimingSegmentsTableTableManager(
      $_db,
      $_db.timingSegments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_timingSegmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReviewRecordsTable, List<ReviewRecord>>
  _reviewRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewRecords,
    aliasName: 'practice_sessions__id__review_records__session_id',
  );

  $$ReviewRecordsTableProcessedTableManager get reviewRecordsRefs {
    final manager = $$ReviewRecordsTableTableManager(
      $_db,
      $_db.reviewRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WritingWorkspacesTable, List<WritingWorkspace>>
  _writingVersionsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.writingWorkspaces,
    aliasName: 'practice_sessions__id__writing_workspaces__session_id',
  );

  $$WritingWorkspacesTableProcessedTableManager get writingVersions {
    final manager = $$WritingWorkspacesTableTableManager(
      $_db,
      $_db.writingWorkspaces,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_writingVersionsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WritingWorkspacesTable, List<WritingWorkspace>>
  _writingRootsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.writingWorkspaces,
    aliasName: 'practice_sessions__id__writing_workspaces__root_session_id',
  );

  $$WritingWorkspacesTableProcessedTableManager get writingRoots {
    final manager = $$WritingWorkspacesTableTableManager(
      $_db,
      $_db.writingWorkspaces,
    ).filter((f) => f.rootSessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_writingRootsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WritingWorkspacesTable, List<WritingWorkspace>>
  _writingChildrenTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.writingWorkspaces,
    aliasName: 'practice_sessions__id__writing_workspaces__parent_session_id',
  );

  $$WritingWorkspacesTableProcessedTableManager get writingChildren {
    final manager =
        $$WritingWorkspacesTableTableManager(
          $_db,
          $_db.writingWorkspaces,
        ).filter(
          (f) => f.parentSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_writingChildrenTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingWorkspacesTable, List<ReadingWorkspace>>
  _readingWorkspacesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readingWorkspaces,
        aliasName: 'practice_sessions__id__reading_workspaces__session_id',
      );

  $$ReadingWorkspacesTableProcessedTableManager get readingWorkspacesRefs {
    final manager = $$ReadingWorkspacesTableTableManager(
      $_db,
      $_db.readingWorkspaces,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingWorkspacesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AudioRecordingsTable, List<AudioRecording>>
  _audioRecordingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.audioRecordings,
    aliasName: 'practice_sessions__id__audio_recordings__session_id',
  );

  $$AudioRecordingsTableProcessedTableManager get audioRecordingsRefs {
    final manager = $$AudioRecordingsTableTableManager(
      $_db,
      $_db.audioRecordings,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audioRecordingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MemoryWorkspacesTable, List<MemoryWorkspace>>
  _memoryWorkspacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryWorkspaces,
    aliasName: 'practice_sessions__id__memory_workspaces__session_id',
  );

  $$MemoryWorkspacesTableProcessedTableManager get memoryWorkspacesRefs {
    final manager = $$MemoryWorkspacesTableTableManager(
      $_db,
      $_db.memoryWorkspaces,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryWorkspacesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DebateWorkspacesTable, List<DebateWorkspace>>
  _debateWorkspacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debateWorkspaces,
    aliasName: 'practice_sessions__id__debate_workspaces__session_id',
  );

  $$DebateWorkspacesTableProcessedTableManager get debateWorkspacesRefs {
    final manager = $$DebateWorkspacesTableTableManager(
      $_db,
      $_db.debateWorkspaces,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _debateWorkspacesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DebateStagesTable, List<DebateStage>>
  _debateStagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.debateStages,
    aliasName: 'practice_sessions__id__debate_stages__session_id',
  );

  $$DebateStagesTableProcessedTableManager get debateStagesRefs {
    final manager = $$DebateStagesTableTableManager(
      $_db,
      $_db.debateStages,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_debateStagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImpromptuWorkspacesTable,
    List<ImpromptuWorkspace>
  >
  _impromptuWorkspacesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.impromptuWorkspaces,
        aliasName: 'practice_sessions__id__impromptu_workspaces__session_id',
      );

  $$ImpromptuWorkspacesTableProcessedTableManager get impromptuWorkspacesRefs {
    final manager = $$ImpromptuWorkspacesTableTableManager(
      $_db,
      $_db.impromptuWorkspaces,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _impromptuWorkspacesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ImpromptuWorkspacesTable,
    List<ImpromptuWorkspace>
  >
  _impromptuRetriesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.impromptuWorkspaces,
    aliasName: 'practice_sessions__id__impromptu_workspaces__parent_session_id',
  );

  $$ImpromptuWorkspacesTableProcessedTableManager get impromptuRetries {
    final manager =
        $$ImpromptuWorkspacesTableTableManager(
          $_db,
          $_db.impromptuWorkspaces,
        ).filter(
          (f) => f.parentSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_impromptuRetriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PracticeContextsTable, List<PracticeContext>>
  _practiceContextsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceContexts,
    aliasName: 'practice_sessions__id__practice_contexts__session_id',
  );

  $$PracticeContextsTableProcessedTableManager get practiceContextsRefs {
    final manager = $$PracticeContextsTableTableManager(
      $_db,
      $_db.practiceContexts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _practiceContextsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PracticeContextsTable, List<PracticeContext>>
  _targetedRetriesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.practiceContexts,
    aliasName: 'practice_sessions__id__practice_contexts__parent_session_id',
  );

  $$PracticeContextsTableProcessedTableManager get targetedRetries {
    final manager =
        $$PracticeContextsTableTableManager($_db, $_db.practiceContexts).filter(
          (f) => f.parentSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_targetedRetriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecallSchedulesTable, List<RecallSchedule>>
  _recallSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recallSchedules,
    aliasName: 'practice_sessions__id__recall_schedules__session_id',
  );

  $$RecallSchedulesTableProcessedTableManager get recallSchedulesRefs {
    final manager = $$RecallSchedulesTableTableManager(
      $_db,
      $_db.recallSchedules,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recallSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PracticeSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseVersion => $composableBuilder(
    column: $table.exerciseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedUtcMs => $composableBuilder(
    column: $table.startedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedUtcMs => $composableBuilder(
    column: $table.completedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPracticeDate => $composableBuilder(
    column: $table.localPracticeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalOffsetMinutes => $composableBuilder(
    column: $table.originalOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> responsesRefs(
    Expression<bool> Function($$ResponsesTableFilterComposer f) f,
  ) {
    final $$ResponsesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.responses,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResponsesTableFilterComposer(
            $db: $db,
            $table: $db.responses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timingSegmentsRefs(
    Expression<bool> Function($$TimingSegmentsTableFilterComposer f) f,
  ) {
    final $$TimingSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timingSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimingSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.timingSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reviewRecordsRefs(
    Expression<bool> Function($$ReviewRecordsTableFilterComposer f) f,
  ) {
    final $$ReviewRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRecordsTableFilterComposer(
            $db: $db,
            $table: $db.reviewRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> writingVersions(
    Expression<bool> Function($$WritingWorkspacesTableFilterComposer f) f,
  ) {
    final $$WritingWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.writingWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WritingWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.writingWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> writingRoots(
    Expression<bool> Function($$WritingWorkspacesTableFilterComposer f) f,
  ) {
    final $$WritingWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.writingWorkspaces,
      getReferencedColumn: (t) => t.rootSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WritingWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.writingWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> writingChildren(
    Expression<bool> Function($$WritingWorkspacesTableFilterComposer f) f,
  ) {
    final $$WritingWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.writingWorkspaces,
      getReferencedColumn: (t) => t.parentSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WritingWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.writingWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingWorkspacesRefs(
    Expression<bool> Function($$ReadingWorkspacesTableFilterComposer f) f,
  ) {
    final $$ReadingWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.readingWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> audioRecordingsRefs(
    Expression<bool> Function($$AudioRecordingsTableFilterComposer f) f,
  ) {
    final $$AudioRecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioRecordings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioRecordingsTableFilterComposer(
            $db: $db,
            $table: $db.audioRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> memoryWorkspacesRefs(
    Expression<bool> Function($$MemoryWorkspacesTableFilterComposer f) f,
  ) {
    final $$MemoryWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.memoryWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> debateWorkspacesRefs(
    Expression<bool> Function($$DebateWorkspacesTableFilterComposer f) f,
  ) {
    final $$DebateWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debateWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebateWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.debateWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> debateStagesRefs(
    Expression<bool> Function($$DebateStagesTableFilterComposer f) f,
  ) {
    final $$DebateStagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debateStages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebateStagesTableFilterComposer(
            $db: $db,
            $table: $db.debateStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> impromptuWorkspacesRefs(
    Expression<bool> Function($$ImpromptuWorkspacesTableFilterComposer f) f,
  ) {
    final $$ImpromptuWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.impromptuWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImpromptuWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.impromptuWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> impromptuRetries(
    Expression<bool> Function($$ImpromptuWorkspacesTableFilterComposer f) f,
  ) {
    final $$ImpromptuWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.impromptuWorkspaces,
      getReferencedColumn: (t) => t.parentSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImpromptuWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.impromptuWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> practiceContextsRefs(
    Expression<bool> Function($$PracticeContextsTableFilterComposer f) f,
  ) {
    final $$PracticeContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceContexts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeContextsTableFilterComposer(
            $db: $db,
            $table: $db.practiceContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> targetedRetries(
    Expression<bool> Function($$PracticeContextsTableFilterComposer f) f,
  ) {
    final $$PracticeContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceContexts,
      getReferencedColumn: (t) => t.parentSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeContextsTableFilterComposer(
            $db: $db,
            $table: $db.practiceContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recallSchedulesRefs(
    Expression<bool> Function($$RecallSchedulesTableFilterComposer f) f,
  ) {
    final $$RecallSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recallSchedules,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecallSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.recallSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseVersion => $composableBuilder(
    column: $table.exerciseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleId => $composableBuilder(
    column: $table.moduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedUtcMs => $composableBuilder(
    column: $table.startedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedUtcMs => $composableBuilder(
    column: $table.completedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPracticeDate => $composableBuilder(
    column: $table.localPracticeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalOffsetMinutes => $composableBuilder(
    column: $table.originalOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeSessionsTable> {
  $$PracticeSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exerciseVersion => $composableBuilder(
    column: $table.exerciseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get snapshot =>
      $composableBuilder(column: $table.snapshot, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedUtcMs => $composableBuilder(
    column: $table.startedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedUtcMs => $composableBuilder(
    column: $table.completedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPracticeDate => $composableBuilder(
    column: $table.localPracticeDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalOffsetMinutes => $composableBuilder(
    column: $table.originalOffsetMinutes,
    builder: (column) => column,
  );

  Expression<T> responsesRefs<T extends Object>(
    Expression<T> Function($$ResponsesTableAnnotationComposer a) f,
  ) {
    final $$ResponsesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.responses,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResponsesTableAnnotationComposer(
            $db: $db,
            $table: $db.responses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timingSegmentsRefs<T extends Object>(
    Expression<T> Function($$TimingSegmentsTableAnnotationComposer a) f,
  ) {
    final $$TimingSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timingSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimingSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.timingSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reviewRecordsRefs<T extends Object>(
    Expression<T> Function($$ReviewRecordsTableAnnotationComposer a) f,
  ) {
    final $$ReviewRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> writingVersions<T extends Object>(
    Expression<T> Function($$WritingWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$WritingWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.writingWorkspaces,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WritingWorkspacesTableAnnotationComposer(
                $db: $db,
                $table: $db.writingWorkspaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> writingRoots<T extends Object>(
    Expression<T> Function($$WritingWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$WritingWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.writingWorkspaces,
          getReferencedColumn: (t) => t.rootSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WritingWorkspacesTableAnnotationComposer(
                $db: $db,
                $table: $db.writingWorkspaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> writingChildren<T extends Object>(
    Expression<T> Function($$WritingWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$WritingWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.writingWorkspaces,
          getReferencedColumn: (t) => t.parentSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WritingWorkspacesTableAnnotationComposer(
                $db: $db,
                $table: $db.writingWorkspaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> readingWorkspacesRefs<T extends Object>(
    Expression<T> Function($$ReadingWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$ReadingWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readingWorkspaces,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingWorkspacesTableAnnotationComposer(
                $db: $db,
                $table: $db.readingWorkspaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> audioRecordingsRefs<T extends Object>(
    Expression<T> Function($$AudioRecordingsTableAnnotationComposer a) f,
  ) {
    final $$AudioRecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioRecordings,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioRecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> memoryWorkspacesRefs<T extends Object>(
    Expression<T> Function($$MemoryWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$MemoryWorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryWorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> debateWorkspacesRefs<T extends Object>(
    Expression<T> Function($$DebateWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$DebateWorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debateWorkspaces,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebateWorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.debateWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> debateStagesRefs<T extends Object>(
    Expression<T> Function($$DebateStagesTableAnnotationComposer a) f,
  ) {
    final $$DebateStagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.debateStages,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DebateStagesTableAnnotationComposer(
            $db: $db,
            $table: $db.debateStages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> impromptuWorkspacesRefs<T extends Object>(
    Expression<T> Function($$ImpromptuWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$ImpromptuWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.impromptuWorkspaces,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImpromptuWorkspacesTableAnnotationComposer(
                $db: $db,
                $table: $db.impromptuWorkspaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> impromptuRetries<T extends Object>(
    Expression<T> Function($$ImpromptuWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$ImpromptuWorkspacesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.impromptuWorkspaces,
          getReferencedColumn: (t) => t.parentSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ImpromptuWorkspacesTableAnnotationComposer(
                $db: $db,
                $table: $db.impromptuWorkspaces,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> practiceContextsRefs<T extends Object>(
    Expression<T> Function($$PracticeContextsTableAnnotationComposer a) f,
  ) {
    final $$PracticeContextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceContexts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeContextsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> targetedRetries<T extends Object>(
    Expression<T> Function($$PracticeContextsTableAnnotationComposer a) f,
  ) {
    final $$PracticeContextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.practiceContexts,
      getReferencedColumn: (t) => t.parentSessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeContextsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recallSchedulesRefs<T extends Object>(
    Expression<T> Function($$RecallSchedulesTableAnnotationComposer a) f,
  ) {
    final $$RecallSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recallSchedules,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecallSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.recallSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PracticeSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeSessionsTable,
          PracticeSession,
          $$PracticeSessionsTableFilterComposer,
          $$PracticeSessionsTableOrderingComposer,
          $$PracticeSessionsTableAnnotationComposer,
          $$PracticeSessionsTableCreateCompanionBuilder,
          $$PracticeSessionsTableUpdateCompanionBuilder,
          (PracticeSession, $$PracticeSessionsTableReferences),
          PracticeSession,
          PrefetchHooks Function({
            bool responsesRefs,
            bool timingSegmentsRefs,
            bool reviewRecordsRefs,
            bool writingVersions,
            bool writingRoots,
            bool writingChildren,
            bool readingWorkspacesRefs,
            bool audioRecordingsRefs,
            bool memoryWorkspacesRefs,
            bool debateWorkspacesRefs,
            bool debateStagesRefs,
            bool impromptuWorkspacesRefs,
            bool impromptuRetries,
            bool practiceContextsRefs,
            bool targetedRetries,
            bool recallSchedulesRefs,
          })
        > {
  $$PracticeSessionsTableTableManager(
    _$AppDatabase db,
    $PracticeSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> exerciseVersion = const Value.absent(),
                Value<String> moduleId = const Value.absent(),
                Value<String> snapshot = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<int> createdUtcMs = const Value.absent(),
                Value<int> updatedUtcMs = const Value.absent(),
                Value<int?> startedUtcMs = const Value.absent(),
                Value<int?> completedUtcMs = const Value.absent(),
                Value<String> localPracticeDate = const Value.absent(),
                Value<int> originalOffsetMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeSessionsCompanion(
                id: id,
                exerciseId: exerciseId,
                exerciseVersion: exerciseVersion,
                moduleId: moduleId,
                snapshot: snapshot,
                status: status,
                stage: stage,
                createdUtcMs: createdUtcMs,
                updatedUtcMs: updatedUtcMs,
                startedUtcMs: startedUtcMs,
                completedUtcMs: completedUtcMs,
                localPracticeDate: localPracticeDate,
                originalOffsetMinutes: originalOffsetMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseId,
                required int exerciseVersion,
                required String moduleId,
                required String snapshot,
                required String status,
                required String stage,
                required int createdUtcMs,
                required int updatedUtcMs,
                Value<int?> startedUtcMs = const Value.absent(),
                Value<int?> completedUtcMs = const Value.absent(),
                required String localPracticeDate,
                required int originalOffsetMinutes,
                Value<int> rowid = const Value.absent(),
              }) => PracticeSessionsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                exerciseVersion: exerciseVersion,
                moduleId: moduleId,
                snapshot: snapshot,
                status: status,
                stage: stage,
                createdUtcMs: createdUtcMs,
                updatedUtcMs: updatedUtcMs,
                startedUtcMs: startedUtcMs,
                completedUtcMs: completedUtcMs,
                localPracticeDate: localPracticeDate,
                originalOffsetMinutes: originalOffsetMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PracticeSessionsTable, PracticeSession>(table),
                  $$PracticeSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                responsesRefs = false,
                timingSegmentsRefs = false,
                reviewRecordsRefs = false,
                writingVersions = false,
                writingRoots = false,
                writingChildren = false,
                readingWorkspacesRefs = false,
                audioRecordingsRefs = false,
                memoryWorkspacesRefs = false,
                debateWorkspacesRefs = false,
                debateStagesRefs = false,
                impromptuWorkspacesRefs = false,
                impromptuRetries = false,
                practiceContextsRefs = false,
                targetedRetries = false,
                recallSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (responsesRefs) db.responses,
                    if (timingSegmentsRefs) db.timingSegments,
                    if (reviewRecordsRefs) db.reviewRecords,
                    if (writingVersions) db.writingWorkspaces,
                    if (writingRoots) db.writingWorkspaces,
                    if (writingChildren) db.writingWorkspaces,
                    if (readingWorkspacesRefs) db.readingWorkspaces,
                    if (audioRecordingsRefs) db.audioRecordings,
                    if (memoryWorkspacesRefs) db.memoryWorkspaces,
                    if (debateWorkspacesRefs) db.debateWorkspaces,
                    if (debateStagesRefs) db.debateStages,
                    if (impromptuWorkspacesRefs) db.impromptuWorkspaces,
                    if (impromptuRetries) db.impromptuWorkspaces,
                    if (practiceContextsRefs) db.practiceContexts,
                    if (targetedRetries) db.practiceContexts,
                    if (recallSchedulesRefs) db.recallSchedules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (responsesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          Response,
                          $ResponsesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._responsesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).responsesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (timingSegmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          TimingSegment,
                          $TimingSegmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._timingSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).timingSegmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (reviewRecordsRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          ReviewRecord,
                          $ReviewRecordsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._reviewRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewRecordsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (writingVersions)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          WritingWorkspace,
                          $WritingWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._writingVersionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).writingVersions,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (writingRoots)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          WritingWorkspace,
                          $WritingWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._writingRootsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).writingRoots,
                          currentColumn: 'id',
                          referencedColumn: 'root_session_id',
                          typedResults: items,
                        ),
                      if (writingChildren)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          WritingWorkspace,
                          $WritingWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._writingChildrenTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).writingChildren,
                          currentColumn: 'id',
                          referencedColumn: 'parent_session_id',
                          typedResults: items,
                        ),
                      if (readingWorkspacesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          ReadingWorkspace,
                          $ReadingWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._readingWorkspacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).readingWorkspacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (audioRecordingsRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          AudioRecording,
                          $AudioRecordingsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._audioRecordingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).audioRecordingsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (memoryWorkspacesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          MemoryWorkspace,
                          $MemoryWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._memoryWorkspacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryWorkspacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (debateWorkspacesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          DebateWorkspace,
                          $DebateWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._debateWorkspacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).debateWorkspacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (debateStagesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          DebateStage,
                          $DebateStagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._debateStagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).debateStagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (impromptuWorkspacesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          ImpromptuWorkspace,
                          $ImpromptuWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._impromptuWorkspacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).impromptuWorkspacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (impromptuRetries)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          ImpromptuWorkspace,
                          $ImpromptuWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._impromptuRetriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).impromptuRetries,
                          currentColumn: 'id',
                          referencedColumn: 'parent_session_id',
                          typedResults: items,
                        ),
                      if (practiceContextsRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          PracticeContext,
                          $PracticeContextsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._practiceContextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).practiceContextsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (targetedRetries)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          PracticeContext,
                          $PracticeContextsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._targetedRetriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).targetedRetries,
                          currentColumn: 'id',
                          referencedColumn: 'parent_session_id',
                          typedResults: items,
                        ),
                      if (recallSchedulesRefs)
                        await $_getPrefetchedDataByColumns<
                          PracticeSession,
                          $PracticeSessionsTable,
                          RecallSchedule,
                          $RecallSchedulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PracticeSessionsTableReferences
                              ._recallSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PracticeSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).recallSchedulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PracticeSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeSessionsTable,
      PracticeSession,
      $$PracticeSessionsTableFilterComposer,
      $$PracticeSessionsTableOrderingComposer,
      $$PracticeSessionsTableAnnotationComposer,
      $$PracticeSessionsTableCreateCompanionBuilder,
      $$PracticeSessionsTableUpdateCompanionBuilder,
      (PracticeSession, $$PracticeSessionsTableReferences),
      PracticeSession,
      PrefetchHooks Function({
        bool responsesRefs,
        bool timingSegmentsRefs,
        bool reviewRecordsRefs,
        bool writingVersions,
        bool writingRoots,
        bool writingChildren,
        bool readingWorkspacesRefs,
        bool audioRecordingsRefs,
        bool memoryWorkspacesRefs,
        bool debateWorkspacesRefs,
        bool debateStagesRefs,
        bool impromptuWorkspacesRefs,
        bool impromptuRetries,
        bool practiceContextsRefs,
        bool targetedRetries,
        bool recallSchedulesRefs,
      })
    >;
typedef $$ResponsesTableCreateCompanionBuilder = ResponsesCompanion Function({
  required String id,
  required String sessionId,
  Value<String> body,
  required int updatedUtcMs,
  Value<int> rowid,
});
typedef $$ResponsesTableUpdateCompanionBuilder = ResponsesCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> body,
  Value<int> updatedUtcMs,
  Value<int> rowid,
});

final class $$ResponsesTableReferences
    extends BaseReferences<_$AppDatabase, $ResponsesTable, Response> {
  $$ResponsesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('responses__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $ResponsesTable> {
  $$ResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResponsesTable> {
  $$ResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResponsesTable> {
  $$ResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResponsesTable,
          Response,
          $$ResponsesTableFilterComposer,
          $$ResponsesTableOrderingComposer,
          $$ResponsesTableAnnotationComposer,
          $$ResponsesTableCreateCompanionBuilder,
          $$ResponsesTableUpdateCompanionBuilder,
          (Response, $$ResponsesTableReferences),
          Response,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ResponsesTableTableManager(_$AppDatabase db, $ResponsesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResponsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResponsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> updatedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResponsesCompanion(
                id: id,
                sessionId: sessionId,
                body: body,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String> body = const Value.absent(),
                required int updatedUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => ResponsesCompanion.insert(
                id: id,
                sessionId: sessionId,
                body: body,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ResponsesTable, Response>(table),
                  $$ResponsesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ResponsesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ResponsesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResponsesTable,
      Response,
      $$ResponsesTableFilterComposer,
      $$ResponsesTableOrderingComposer,
      $$ResponsesTableAnnotationComposer,
      $$ResponsesTableCreateCompanionBuilder,
      $$ResponsesTableUpdateCompanionBuilder,
      (Response, $$ResponsesTableReferences),
      Response,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$TimingSegmentsTableCreateCompanionBuilder =
    TimingSegmentsCompanion Function({
      required String id,
      required String sessionId,
      required String stage,
      required int startedUtcMs,
      required int checkpointUtcMs,
      Value<int?> endedUtcMs,
      required int elapsedMs,
      Value<String?> endReason,
      Value<int> rowid,
    });
typedef $$TimingSegmentsTableUpdateCompanionBuilder =
    TimingSegmentsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> stage,
      Value<int> startedUtcMs,
      Value<int> checkpointUtcMs,
      Value<int?> endedUtcMs,
      Value<int> elapsedMs,
      Value<String?> endReason,
      Value<int> rowid,
    });

final class $$TimingSegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $TimingSegmentsTable, TimingSegment> {
  $$TimingSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('timing_segments__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimingSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TimingSegmentsTable> {
  $$TimingSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedUtcMs => $composableBuilder(
    column: $table.startedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get checkpointUtcMs => $composableBuilder(
    column: $table.checkpointUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedUtcMs => $composableBuilder(
    column: $table.endedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimingSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimingSegmentsTable> {
  $$TimingSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedUtcMs => $composableBuilder(
    column: $table.startedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get checkpointUtcMs => $composableBuilder(
    column: $table.checkpointUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedUtcMs => $composableBuilder(
    column: $table.endedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimingSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimingSegmentsTable> {
  $$TimingSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<int> get startedUtcMs => $composableBuilder(
    column: $table.startedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get checkpointUtcMs => $composableBuilder(
    column: $table.checkpointUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedUtcMs => $composableBuilder(
    column: $table.endedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => column);

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimingSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimingSegmentsTable,
          TimingSegment,
          $$TimingSegmentsTableFilterComposer,
          $$TimingSegmentsTableOrderingComposer,
          $$TimingSegmentsTableAnnotationComposer,
          $$TimingSegmentsTableCreateCompanionBuilder,
          $$TimingSegmentsTableUpdateCompanionBuilder,
          (TimingSegment, $$TimingSegmentsTableReferences),
          TimingSegment,
          PrefetchHooks Function({bool sessionId})
        > {
  $$TimingSegmentsTableTableManager(
    _$AppDatabase db,
    $TimingSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimingSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimingSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimingSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<int> startedUtcMs = const Value.absent(),
                Value<int> checkpointUtcMs = const Value.absent(),
                Value<int?> endedUtcMs = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimingSegmentsCompanion(
                id: id,
                sessionId: sessionId,
                stage: stage,
                startedUtcMs: startedUtcMs,
                checkpointUtcMs: checkpointUtcMs,
                endedUtcMs: endedUtcMs,
                elapsedMs: elapsedMs,
                endReason: endReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String stage,
                required int startedUtcMs,
                required int checkpointUtcMs,
                Value<int?> endedUtcMs = const Value.absent(),
                required int elapsedMs,
                Value<String?> endReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimingSegmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                stage: stage,
                startedUtcMs: startedUtcMs,
                checkpointUtcMs: checkpointUtcMs,
                endedUtcMs: endedUtcMs,
                elapsedMs: elapsedMs,
                endReason: endReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimingSegmentsTable, TimingSegment>(table),
                  $$TimingSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$TimingSegmentsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$TimingSegmentsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimingSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimingSegmentsTable,
      TimingSegment,
      $$TimingSegmentsTableFilterComposer,
      $$TimingSegmentsTableOrderingComposer,
      $$TimingSegmentsTableAnnotationComposer,
      $$TimingSegmentsTableCreateCompanionBuilder,
      $$TimingSegmentsTableUpdateCompanionBuilder,
      (TimingSegment, $$TimingSegmentsTableReferences),
      TimingSegment,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ReviewRecordsTableCreateCompanionBuilder =
    ReviewRecordsCompanion Function({
      required String id,
      required String sessionId,
      required String status,
      required String notes,
      required int updatedUtcMs,
      Value<int> rowid,
    });
typedef $$ReviewRecordsTableUpdateCompanionBuilder =
    ReviewRecordsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> status,
      Value<String> notes,
      Value<int> updatedUtcMs,
      Value<int> rowid,
    });

final class $$ReviewRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewRecordsTable, ReviewRecord> {
  $$ReviewRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('review_records__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewRecordsTable> {
  $$ReviewRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewRecordsTable,
          ReviewRecord,
          $$ReviewRecordsTableFilterComposer,
          $$ReviewRecordsTableOrderingComposer,
          $$ReviewRecordsTableAnnotationComposer,
          $$ReviewRecordsTableCreateCompanionBuilder,
          $$ReviewRecordsTableUpdateCompanionBuilder,
          (ReviewRecord, $$ReviewRecordsTableReferences),
          ReviewRecord,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ReviewRecordsTableTableManager(_$AppDatabase db, $ReviewRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> updatedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewRecordsCompanion(
                id: id,
                sessionId: sessionId,
                status: status,
                notes: notes,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String status,
                required String notes,
                required int updatedUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => ReviewRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                status: status,
                notes: notes,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewRecordsTable, ReviewRecord>(table),
                  $$ReviewRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ReviewRecordsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ReviewRecordsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewRecordsTable,
      ReviewRecord,
      $$ReviewRecordsTableFilterComposer,
      $$ReviewRecordsTableOrderingComposer,
      $$ReviewRecordsTableAnnotationComposer,
      $$ReviewRecordsTableCreateCompanionBuilder,
      $$ReviewRecordsTableUpdateCompanionBuilder,
      (ReviewRecord, $$ReviewRecordsTableReferences),
      ReviewRecord,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$WritingWorkspacesTableCreateCompanionBuilder =
    WritingWorkspacesCompanion Function({
      required String sessionId,
      required String rootSessionId,
      Value<String?> parentSessionId,
      required int versionNumber,
      Value<String> outline,
      required String audience,
      required String purpose,
      Value<String> viewStep,
      Value<String> assessments,
      required String reviewRubric,
      Value<String> legacyReviewNotes,
      Value<String> nextAction,
      required int updatedUtcMs,
      Value<int> rowid,
    });
typedef $$WritingWorkspacesTableUpdateCompanionBuilder =
    WritingWorkspacesCompanion Function({
      Value<String> sessionId,
      Value<String> rootSessionId,
      Value<String?> parentSessionId,
      Value<int> versionNumber,
      Value<String> outline,
      Value<String> audience,
      Value<String> purpose,
      Value<String> viewStep,
      Value<String> assessments,
      Value<String> reviewRubric,
      Value<String> legacyReviewNotes,
      Value<String> nextAction,
      Value<int> updatedUtcMs,
      Value<int> rowid,
    });

final class $$WritingWorkspacesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WritingWorkspacesTable,
          WritingWorkspace
        > {
  $$WritingWorkspacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('writing_workspaces__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PracticeSessionsTable _rootSessionIdTable(_$AppDatabase db) =>
      db.practiceSessions.createAlias(
        'writing_workspaces__root_session_id__practice_sessions__id',
      );

  $$PracticeSessionsTableProcessedTableManager get rootSessionId {
    final $_column = $_itemColumn<String>('root_session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rootSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PracticeSessionsTable _parentSessionIdTable(_$AppDatabase db) =>
      db.practiceSessions.createAlias(
        'writing_workspaces__parent_session_id__practice_sessions__id',
      );

  $$PracticeSessionsTableProcessedTableManager? get parentSessionId {
    final $_column = $_itemColumn<String>('parent_session_id');
    if ($_column == null) return null;
    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WritingWorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WritingWorkspacesTable> {
  $$WritingWorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outline => $composableBuilder(
    column: $table.outline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewStep => $composableBuilder(
    column: $table.viewStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewRubric => $composableBuilder(
    column: $table.reviewRubric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyReviewNotes => $composableBuilder(
    column: $table.legacyReviewNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableFilterComposer get rootSessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableFilterComposer get parentSessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WritingWorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WritingWorkspacesTable> {
  $$WritingWorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outline => $composableBuilder(
    column: $table.outline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewStep => $composableBuilder(
    column: $table.viewStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewRubric => $composableBuilder(
    column: $table.reviewRubric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyReviewNotes => $composableBuilder(
    column: $table.legacyReviewNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableOrderingComposer get rootSessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableOrderingComposer get parentSessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WritingWorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WritingWorkspacesTable> {
  $$WritingWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outline =>
      $composableBuilder(column: $table.outline, builder: (column) => column);

  GeneratedColumn<String> get audience =>
      $composableBuilder(column: $table.audience, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get viewStep =>
      $composableBuilder(column: $table.viewStep, builder: (column) => column);

  GeneratedColumn<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewRubric => $composableBuilder(
    column: $table.reviewRubric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legacyReviewNotes => $composableBuilder(
    column: $table.legacyReviewNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableAnnotationComposer get rootSessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableAnnotationComposer get parentSessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WritingWorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WritingWorkspacesTable,
          WritingWorkspace,
          $$WritingWorkspacesTableFilterComposer,
          $$WritingWorkspacesTableOrderingComposer,
          $$WritingWorkspacesTableAnnotationComposer,
          $$WritingWorkspacesTableCreateCompanionBuilder,
          $$WritingWorkspacesTableUpdateCompanionBuilder,
          (WritingWorkspace, $$WritingWorkspacesTableReferences),
          WritingWorkspace,
          PrefetchHooks Function({
            bool sessionId,
            bool rootSessionId,
            bool parentSessionId,
          })
        > {
  $$WritingWorkspacesTableTableManager(
    _$AppDatabase db,
    $WritingWorkspacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WritingWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WritingWorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WritingWorkspacesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> rootSessionId = const Value.absent(),
                Value<String?> parentSessionId = const Value.absent(),
                Value<int> versionNumber = const Value.absent(),
                Value<String> outline = const Value.absent(),
                Value<String> audience = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> viewStep = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                Value<String> reviewRubric = const Value.absent(),
                Value<String> legacyReviewNotes = const Value.absent(),
                Value<String> nextAction = const Value.absent(),
                Value<int> updatedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WritingWorkspacesCompanion(
                sessionId: sessionId,
                rootSessionId: rootSessionId,
                parentSessionId: parentSessionId,
                versionNumber: versionNumber,
                outline: outline,
                audience: audience,
                purpose: purpose,
                viewStep: viewStep,
                assessments: assessments,
                reviewRubric: reviewRubric,
                legacyReviewNotes: legacyReviewNotes,
                nextAction: nextAction,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String rootSessionId,
                Value<String?> parentSessionId = const Value.absent(),
                required int versionNumber,
                Value<String> outline = const Value.absent(),
                required String audience,
                required String purpose,
                Value<String> viewStep = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                required String reviewRubric,
                Value<String> legacyReviewNotes = const Value.absent(),
                Value<String> nextAction = const Value.absent(),
                required int updatedUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => WritingWorkspacesCompanion.insert(
                sessionId: sessionId,
                rootSessionId: rootSessionId,
                parentSessionId: parentSessionId,
                versionNumber: versionNumber,
                outline: outline,
                audience: audience,
                purpose: purpose,
                viewStep: viewStep,
                assessments: assessments,
                reviewRubric: reviewRubric,
                legacyReviewNotes: legacyReviewNotes,
                nextAction: nextAction,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WritingWorkspacesTable, WritingWorkspace>(table),
                  $$WritingWorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                rootSessionId = false,
                parentSessionId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$WritingWorkspacesTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$WritingWorkspacesTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (rootSessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rootSessionId,
                            referencedTable: $$WritingWorkspacesTableReferences
                                ._rootSessionIdTable(db),
                            referencedColumn: $$WritingWorkspacesTableReferences
                                ._rootSessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (parentSessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentSessionId,
                            referencedTable: $$WritingWorkspacesTableReferences
                                ._parentSessionIdTable(db),
                            referencedColumn: $$WritingWorkspacesTableReferences
                                ._parentSessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WritingWorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WritingWorkspacesTable,
      WritingWorkspace,
      $$WritingWorkspacesTableFilterComposer,
      $$WritingWorkspacesTableOrderingComposer,
      $$WritingWorkspacesTableAnnotationComposer,
      $$WritingWorkspacesTableCreateCompanionBuilder,
      $$WritingWorkspacesTableUpdateCompanionBuilder,
      (WritingWorkspace, $$WritingWorkspacesTableReferences),
      WritingWorkspace,
      PrefetchHooks Function({
        bool sessionId,
        bool rootSessionId,
        bool parentSessionId,
      })
    >;
typedef $$ReadingWorkspacesTableCreateCompanionBuilder =
    ReadingWorkspacesCompanion Function({
      required String sessionId,
      Value<String?> keyResults,
      Value<String> revisionAnswers,
      Value<String> ratings,
      Value<String> viewStep,
      Value<bool> hidePassage,
      required int updatedUtcMs,
      Value<int> rowid,
    });
typedef $$ReadingWorkspacesTableUpdateCompanionBuilder =
    ReadingWorkspacesCompanion Function({
      Value<String> sessionId,
      Value<String?> keyResults,
      Value<String> revisionAnswers,
      Value<String> ratings,
      Value<String> viewStep,
      Value<bool> hidePassage,
      Value<int> updatedUtcMs,
      Value<int> rowid,
    });

final class $$ReadingWorkspacesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReadingWorkspacesTable,
          ReadingWorkspace
        > {
  $$ReadingWorkspacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('reading_workspaces__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingWorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingWorkspacesTable> {
  $$ReadingWorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get keyResults => $composableBuilder(
    column: $table.keyResults,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revisionAnswers => $composableBuilder(
    column: $table.revisionAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratings => $composableBuilder(
    column: $table.ratings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewStep => $composableBuilder(
    column: $table.viewStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidePassage => $composableBuilder(
    column: $table.hidePassage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingWorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingWorkspacesTable> {
  $$ReadingWorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get keyResults => $composableBuilder(
    column: $table.keyResults,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revisionAnswers => $composableBuilder(
    column: $table.revisionAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratings => $composableBuilder(
    column: $table.ratings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewStep => $composableBuilder(
    column: $table.viewStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidePassage => $composableBuilder(
    column: $table.hidePassage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingWorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingWorkspacesTable> {
  $$ReadingWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get keyResults => $composableBuilder(
    column: $table.keyResults,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revisionAnswers => $composableBuilder(
    column: $table.revisionAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ratings =>
      $composableBuilder(column: $table.ratings, builder: (column) => column);

  GeneratedColumn<String> get viewStep =>
      $composableBuilder(column: $table.viewStep, builder: (column) => column);

  GeneratedColumn<bool> get hidePassage => $composableBuilder(
    column: $table.hidePassage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingWorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingWorkspacesTable,
          ReadingWorkspace,
          $$ReadingWorkspacesTableFilterComposer,
          $$ReadingWorkspacesTableOrderingComposer,
          $$ReadingWorkspacesTableAnnotationComposer,
          $$ReadingWorkspacesTableCreateCompanionBuilder,
          $$ReadingWorkspacesTableUpdateCompanionBuilder,
          (ReadingWorkspace, $$ReadingWorkspacesTableReferences),
          ReadingWorkspace,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ReadingWorkspacesTableTableManager(
    _$AppDatabase db,
    $ReadingWorkspacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingWorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingWorkspacesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String?> keyResults = const Value.absent(),
                Value<String> revisionAnswers = const Value.absent(),
                Value<String> ratings = const Value.absent(),
                Value<String> viewStep = const Value.absent(),
                Value<bool> hidePassage = const Value.absent(),
                Value<int> updatedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingWorkspacesCompanion(
                sessionId: sessionId,
                keyResults: keyResults,
                revisionAnswers: revisionAnswers,
                ratings: ratings,
                viewStep: viewStep,
                hidePassage: hidePassage,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                Value<String?> keyResults = const Value.absent(),
                Value<String> revisionAnswers = const Value.absent(),
                Value<String> ratings = const Value.absent(),
                Value<String> viewStep = const Value.absent(),
                Value<bool> hidePassage = const Value.absent(),
                required int updatedUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => ReadingWorkspacesCompanion.insert(
                sessionId: sessionId,
                keyResults: keyResults,
                revisionAnswers: revisionAnswers,
                ratings: ratings,
                viewStep: viewStep,
                hidePassage: hidePassage,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingWorkspacesTable, ReadingWorkspace>(table),
                  $$ReadingWorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$ReadingWorkspacesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$ReadingWorkspacesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingWorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingWorkspacesTable,
      ReadingWorkspace,
      $$ReadingWorkspacesTableFilterComposer,
      $$ReadingWorkspacesTableOrderingComposer,
      $$ReadingWorkspacesTableAnnotationComposer,
      $$ReadingWorkspacesTableCreateCompanionBuilder,
      $$ReadingWorkspacesTableUpdateCompanionBuilder,
      (ReadingWorkspace, $$ReadingWorkspacesTableReferences),
      ReadingWorkspace,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AudioRecordingsTableCreateCompanionBuilder =
    AudioRecordingsCompanion Function({
      required String id,
      required String sessionId,
      Value<String> contextKey,
      required String relativePath,
      required String state,
      Value<bool> microphoneCheck,
      Value<bool> interrupted,
      required String inputId,
      required String inputName,
      Value<int> durationMs,
      Value<int> sampleRate,
      Value<int> channels,
      Value<int> byteCount,
      Value<double?> peakDb,
      Value<double?> rmsDb,
      Value<String> statusNote,
      required int createdUtcMs,
      Value<int?> finalizedUtcMs,
      Value<int> rowid,
    });
typedef $$AudioRecordingsTableUpdateCompanionBuilder =
    AudioRecordingsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> contextKey,
      Value<String> relativePath,
      Value<String> state,
      Value<bool> microphoneCheck,
      Value<bool> interrupted,
      Value<String> inputId,
      Value<String> inputName,
      Value<int> durationMs,
      Value<int> sampleRate,
      Value<int> channels,
      Value<int> byteCount,
      Value<double?> peakDb,
      Value<double?> rmsDb,
      Value<String> statusNote,
      Value<int> createdUtcMs,
      Value<int?> finalizedUtcMs,
      Value<int> rowid,
    });

final class $$AudioRecordingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AudioRecordingsTable, AudioRecording> {
  $$AudioRecordingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('audio_recordings__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AudioObservationsTable, List<AudioObservation>>
  _audioObservationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.audioObservations,
        aliasName: 'audio_recordings__id__audio_observations__recording_id',
      );

  $$AudioObservationsTableProcessedTableManager get audioObservationsRefs {
    final manager = $$AudioObservationsTableTableManager(
      $_db,
      $_db.audioObservations,
    ).filter((f) => f.recordingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _audioObservationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AudioRecordingsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioRecordingsTable> {
  $$AudioRecordingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get microphoneCheck => $composableBuilder(
    column: $table.microphoneCheck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get interrupted => $composableBuilder(
    column: $table.interrupted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputId => $composableBuilder(
    column: $table.inputId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inputName => $composableBuilder(
    column: $table.inputName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get channels => $composableBuilder(
    column: $table.channels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteCount => $composableBuilder(
    column: $table.byteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakDb => $composableBuilder(
    column: $table.peakDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rmsDb => $composableBuilder(
    column: $table.rmsDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalizedUtcMs => $composableBuilder(
    column: $table.finalizedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> audioObservationsRefs(
    Expression<bool> Function($$AudioObservationsTableFilterComposer f) f,
  ) {
    final $$AudioObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audioObservations,
      getReferencedColumn: (t) => t.recordingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioObservationsTableFilterComposer(
            $db: $db,
            $table: $db.audioObservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AudioRecordingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioRecordingsTable> {
  $$AudioRecordingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get microphoneCheck => $composableBuilder(
    column: $table.microphoneCheck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get interrupted => $composableBuilder(
    column: $table.interrupted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputId => $composableBuilder(
    column: $table.inputId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inputName => $composableBuilder(
    column: $table.inputName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get channels => $composableBuilder(
    column: $table.channels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteCount => $composableBuilder(
    column: $table.byteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakDb => $composableBuilder(
    column: $table.peakDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rmsDb => $composableBuilder(
    column: $table.rmsDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalizedUtcMs => $composableBuilder(
    column: $table.finalizedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioRecordingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioRecordingsTable> {
  $$AudioRecordingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get microphoneCheck => $composableBuilder(
    column: $table.microphoneCheck,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get interrupted => $composableBuilder(
    column: $table.interrupted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get inputId =>
      $composableBuilder(column: $table.inputId, builder: (column) => column);

  GeneratedColumn<String> get inputName =>
      $composableBuilder(column: $table.inputName, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get channels =>
      $composableBuilder(column: $table.channels, builder: (column) => column);

  GeneratedColumn<int> get byteCount =>
      $composableBuilder(column: $table.byteCount, builder: (column) => column);

  GeneratedColumn<double> get peakDb =>
      $composableBuilder(column: $table.peakDb, builder: (column) => column);

  GeneratedColumn<double> get rmsDb =>
      $composableBuilder(column: $table.rmsDb, builder: (column) => column);

  GeneratedColumn<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalizedUtcMs => $composableBuilder(
    column: $table.finalizedUtcMs,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> audioObservationsRefs<T extends Object>(
    Expression<T> Function($$AudioObservationsTableAnnotationComposer a) f,
  ) {
    final $$AudioObservationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.audioObservations,
          getReferencedColumn: (t) => t.recordingId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AudioObservationsTableAnnotationComposer(
                $db: $db,
                $table: $db.audioObservations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AudioRecordingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioRecordingsTable,
          AudioRecording,
          $$AudioRecordingsTableFilterComposer,
          $$AudioRecordingsTableOrderingComposer,
          $$AudioRecordingsTableAnnotationComposer,
          $$AudioRecordingsTableCreateCompanionBuilder,
          $$AudioRecordingsTableUpdateCompanionBuilder,
          (AudioRecording, $$AudioRecordingsTableReferences),
          AudioRecording,
          PrefetchHooks Function({bool sessionId, bool audioObservationsRefs})
        > {
  $$AudioRecordingsTableTableManager(
    _$AppDatabase db,
    $AudioRecordingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioRecordingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioRecordingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioRecordingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> contextKey = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<bool> microphoneCheck = const Value.absent(),
                Value<bool> interrupted = const Value.absent(),
                Value<String> inputId = const Value.absent(),
                Value<String> inputName = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> sampleRate = const Value.absent(),
                Value<int> channels = const Value.absent(),
                Value<int> byteCount = const Value.absent(),
                Value<double?> peakDb = const Value.absent(),
                Value<double?> rmsDb = const Value.absent(),
                Value<String> statusNote = const Value.absent(),
                Value<int> createdUtcMs = const Value.absent(),
                Value<int?> finalizedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioRecordingsCompanion(
                id: id,
                sessionId: sessionId,
                contextKey: contextKey,
                relativePath: relativePath,
                state: state,
                microphoneCheck: microphoneCheck,
                interrupted: interrupted,
                inputId: inputId,
                inputName: inputName,
                durationMs: durationMs,
                sampleRate: sampleRate,
                channels: channels,
                byteCount: byteCount,
                peakDb: peakDb,
                rmsDb: rmsDb,
                statusNote: statusNote,
                createdUtcMs: createdUtcMs,
                finalizedUtcMs: finalizedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String> contextKey = const Value.absent(),
                required String relativePath,
                required String state,
                Value<bool> microphoneCheck = const Value.absent(),
                Value<bool> interrupted = const Value.absent(),
                required String inputId,
                required String inputName,
                Value<int> durationMs = const Value.absent(),
                Value<int> sampleRate = const Value.absent(),
                Value<int> channels = const Value.absent(),
                Value<int> byteCount = const Value.absent(),
                Value<double?> peakDb = const Value.absent(),
                Value<double?> rmsDb = const Value.absent(),
                Value<String> statusNote = const Value.absent(),
                required int createdUtcMs,
                Value<int?> finalizedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioRecordingsCompanion.insert(
                id: id,
                sessionId: sessionId,
                contextKey: contextKey,
                relativePath: relativePath,
                state: state,
                microphoneCheck: microphoneCheck,
                interrupted: interrupted,
                inputId: inputId,
                inputName: inputName,
                durationMs: durationMs,
                sampleRate: sampleRate,
                channels: channels,
                byteCount: byteCount,
                peakDb: peakDb,
                rmsDb: rmsDb,
                statusNote: statusNote,
                createdUtcMs: createdUtcMs,
                finalizedUtcMs: finalizedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioRecordingsTable, AudioRecording>(table),
                  $$AudioRecordingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, audioObservationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (audioObservationsRefs) db.audioObservations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$AudioRecordingsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$AudioRecordingsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (audioObservationsRefs)
                        await $_getPrefetchedDataByColumns<
                          AudioRecording,
                          $AudioRecordingsTable,
                          AudioObservation,
                          $AudioObservationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AudioRecordingsTableReferences
                              ._audioObservationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AudioRecordingsTableReferences(
                                db,
                                table,
                                p0,
                              ).audioObservationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'recording_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AudioRecordingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioRecordingsTable,
      AudioRecording,
      $$AudioRecordingsTableFilterComposer,
      $$AudioRecordingsTableOrderingComposer,
      $$AudioRecordingsTableAnnotationComposer,
      $$AudioRecordingsTableCreateCompanionBuilder,
      $$AudioRecordingsTableUpdateCompanionBuilder,
      (AudioRecording, $$AudioRecordingsTableReferences),
      AudioRecording,
      PrefetchHooks Function({bool sessionId, bool audioObservationsRefs})
    >;
typedef $$AudioObservationsTableCreateCompanionBuilder =
    AudioObservationsCompanion Function({
      required String id,
      required String recordingId,
      required int positionMs,
      required String note,
      required int createdUtcMs,
      Value<int> rowid,
    });
typedef $$AudioObservationsTableUpdateCompanionBuilder =
    AudioObservationsCompanion Function({
      Value<String> id,
      Value<String> recordingId,
      Value<int> positionMs,
      Value<String> note,
      Value<int> createdUtcMs,
      Value<int> rowid,
    });

final class $$AudioObservationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AudioObservationsTable,
          AudioObservation
        > {
  $$AudioObservationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AudioRecordingsTable _recordingIdTable(_$AppDatabase db) => db
      .audioRecordings
      .createAlias('audio_observations__recording_id__audio_recordings__id');

  $$AudioRecordingsTableProcessedTableManager get recordingId {
    final $_column = $_itemColumn<String>('recording_id')!;

    final manager = $$AudioRecordingsTableTableManager(
      $_db,
      $_db.audioRecordings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AudioObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $AudioObservationsTable> {
  $$AudioObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$AudioRecordingsTableFilterComposer get recordingId {
    final $$AudioRecordingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.audioRecordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioRecordingsTableFilterComposer(
            $db: $db,
            $table: $db.audioRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AudioObservationsTable> {
  $$AudioObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$AudioRecordingsTableOrderingComposer get recordingId {
    final $$AudioRecordingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.audioRecordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioRecordingsTableOrderingComposer(
            $db: $db,
            $table: $db.audioRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AudioObservationsTable> {
  $$AudioObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => column,
  );

  $$AudioRecordingsTableAnnotationComposer get recordingId {
    final $$AudioRecordingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordingId,
      referencedTable: $db.audioRecordings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AudioRecordingsTableAnnotationComposer(
            $db: $db,
            $table: $db.audioRecordings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AudioObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AudioObservationsTable,
          AudioObservation,
          $$AudioObservationsTableFilterComposer,
          $$AudioObservationsTableOrderingComposer,
          $$AudioObservationsTableAnnotationComposer,
          $$AudioObservationsTableCreateCompanionBuilder,
          $$AudioObservationsTableUpdateCompanionBuilder,
          (AudioObservation, $$AudioObservationsTableReferences),
          AudioObservation,
          PrefetchHooks Function({bool recordingId})
        > {
  $$AudioObservationsTableTableManager(
    _$AppDatabase db,
    $AudioObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AudioObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AudioObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AudioObservationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recordingId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> createdUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AudioObservationsCompanion(
                id: id,
                recordingId: recordingId,
                positionMs: positionMs,
                note: note,
                createdUtcMs: createdUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recordingId,
                required int positionMs,
                required String note,
                required int createdUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => AudioObservationsCompanion.insert(
                id: id,
                recordingId: recordingId,
                positionMs: positionMs,
                note: note,
                createdUtcMs: createdUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AudioObservationsTable, AudioObservation>(table),
                  $$AudioObservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordingId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.recordingId,
                        referencedTable: $$AudioObservationsTableReferences
                            ._recordingIdTable(db),
                        referencedColumn: $$AudioObservationsTableReferences
                            ._recordingIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AudioObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AudioObservationsTable,
      AudioObservation,
      $$AudioObservationsTableFilterComposer,
      $$AudioObservationsTableOrderingComposer,
      $$AudioObservationsTableAnnotationComposer,
      $$AudioObservationsTableCreateCompanionBuilder,
      $$AudioObservationsTableUpdateCompanionBuilder,
      (AudioObservation, $$AudioObservationsTableReferences),
      AudioObservation,
      PrefetchHooks Function({bool recordingId})
    >;
typedef $$MemorySpeechesTableCreateCompanionBuilder =
    MemorySpeechesCompanion Function({
      required String id,
      required String draft,
      required int updatedUtcMs,
      Value<int> rowid,
    });
typedef $$MemorySpeechesTableUpdateCompanionBuilder =
    MemorySpeechesCompanion Function({
      Value<String> id,
      Value<String> draft,
      Value<int> updatedUtcMs,
      Value<int> rowid,
    });

final class $$MemorySpeechesTableReferences
    extends BaseReferences<_$AppDatabase, $MemorySpeechesTable, MemorySpeech> {
  $$MemorySpeechesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MemoryVersionsTable, List<MemoryVersion>>
  _memoryVersionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryVersions,
    aliasName: 'memory_speeches__id__memory_versions__speech_id',
  );

  $$MemoryVersionsTableProcessedTableManager get memoryVersionsRefs {
    final manager = $$MemoryVersionsTableTableManager(
      $_db,
      $_db.memoryVersions,
    ).filter((f) => f.speechId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoryVersionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemorySpeechesTableFilterComposer
    extends Composer<_$AppDatabase, $MemorySpeechesTable> {
  $$MemorySpeechesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draft => $composableBuilder(
    column: $table.draft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> memoryVersionsRefs(
    Expression<bool> Function($$MemoryVersionsTableFilterComposer f) f,
  ) {
    final $$MemoryVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryVersions,
      getReferencedColumn: (t) => t.speechId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVersionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemorySpeechesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemorySpeechesTable> {
  $$MemorySpeechesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draft => $composableBuilder(
    column: $table.draft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemorySpeechesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemorySpeechesTable> {
  $$MemorySpeechesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get draft =>
      $composableBuilder(column: $table.draft, builder: (column) => column);

  GeneratedColumn<int> get updatedUtcMs => $composableBuilder(
    column: $table.updatedUtcMs,
    builder: (column) => column,
  );

  Expression<T> memoryVersionsRefs<T extends Object>(
    Expression<T> Function($$MemoryVersionsTableAnnotationComposer a) f,
  ) {
    final $$MemoryVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryVersions,
      getReferencedColumn: (t) => t.speechId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemorySpeechesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemorySpeechesTable,
          MemorySpeech,
          $$MemorySpeechesTableFilterComposer,
          $$MemorySpeechesTableOrderingComposer,
          $$MemorySpeechesTableAnnotationComposer,
          $$MemorySpeechesTableCreateCompanionBuilder,
          $$MemorySpeechesTableUpdateCompanionBuilder,
          (MemorySpeech, $$MemorySpeechesTableReferences),
          MemorySpeech,
          PrefetchHooks Function({bool memoryVersionsRefs})
        > {
  $$MemorySpeechesTableTableManager(
    _$AppDatabase db,
    $MemorySpeechesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemorySpeechesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemorySpeechesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemorySpeechesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> draft = const Value.absent(),
                Value<int> updatedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemorySpeechesCompanion(
                id: id,
                draft: draft,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String draft,
                required int updatedUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => MemorySpeechesCompanion.insert(
                id: id,
                draft: draft,
                updatedUtcMs: updatedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemorySpeechesTable, MemorySpeech>(table),
                  $$MemorySpeechesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoryVersionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (memoryVersionsRefs) db.memoryVersions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (memoryVersionsRefs)
                    await $_getPrefetchedDataByColumns<
                      MemorySpeech,
                      $MemorySpeechesTable,
                      MemoryVersion,
                      $MemoryVersionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$MemorySpeechesTableReferences
                          ._memoryVersionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MemorySpeechesTableReferences(
                            db,
                            table,
                            p0,
                          ).memoryVersionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'speech_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MemorySpeechesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemorySpeechesTable,
      MemorySpeech,
      $$MemorySpeechesTableFilterComposer,
      $$MemorySpeechesTableOrderingComposer,
      $$MemorySpeechesTableAnnotationComposer,
      $$MemorySpeechesTableCreateCompanionBuilder,
      $$MemorySpeechesTableUpdateCompanionBuilder,
      (MemorySpeech, $$MemorySpeechesTableReferences),
      MemorySpeech,
      PrefetchHooks Function({bool memoryVersionsRefs})
    >;
typedef $$MemoryVersionsTableCreateCompanionBuilder =
    MemoryVersionsCompanion Function({
      required String id,
      required String speechId,
      required int versionNumber,
      required String content,
      required int createdUtcMs,
      Value<int> rowid,
    });
typedef $$MemoryVersionsTableUpdateCompanionBuilder =
    MemoryVersionsCompanion Function({
      Value<String> id,
      Value<String> speechId,
      Value<int> versionNumber,
      Value<String> content,
      Value<int> createdUtcMs,
      Value<int> rowid,
    });

final class $$MemoryVersionsTableReferences
    extends BaseReferences<_$AppDatabase, $MemoryVersionsTable, MemoryVersion> {
  $$MemoryVersionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MemorySpeechesTable _speechIdTable(_$AppDatabase db) => db
      .memorySpeeches
      .createAlias('memory_versions__speech_id__memory_speeches__id');

  $$MemorySpeechesTableProcessedTableManager get speechId {
    final $_column = $_itemColumn<String>('speech_id')!;

    final manager = $$MemorySpeechesTableTableManager(
      $_db,
      $_db.memorySpeeches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speechIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MemoryWorkspacesTable, List<MemoryWorkspace>>
  _memoryWorkspacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoryWorkspaces,
    aliasName: 'memory_versions__id__memory_workspaces__version_id',
  );

  $$MemoryWorkspacesTableProcessedTableManager get memoryWorkspacesRefs {
    final manager = $$MemoryWorkspacesTableTableManager(
      $_db,
      $_db.memoryWorkspaces,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _memoryWorkspacesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemoryVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryVersionsTable> {
  $$MemoryVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$MemorySpeechesTableFilterComposer get speechId {
    final $$MemorySpeechesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speechId,
      referencedTable: $db.memorySpeeches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemorySpeechesTableFilterComposer(
            $db: $db,
            $table: $db.memorySpeeches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> memoryWorkspacesRefs(
    Expression<bool> Function($$MemoryWorkspacesTableFilterComposer f) f,
  ) {
    final $$MemoryWorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryWorkspaces,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryWorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.memoryWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryVersionsTable> {
  $$MemoryVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemorySpeechesTableOrderingComposer get speechId {
    final $$MemorySpeechesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speechId,
      referencedTable: $db.memorySpeeches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemorySpeechesTableOrderingComposer(
            $db: $db,
            $table: $db.memorySpeeches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryVersionsTable> {
  $$MemoryVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get versionNumber => $composableBuilder(
    column: $table.versionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => column,
  );

  $$MemorySpeechesTableAnnotationComposer get speechId {
    final $$MemorySpeechesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speechId,
      referencedTable: $db.memorySpeeches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemorySpeechesTableAnnotationComposer(
            $db: $db,
            $table: $db.memorySpeeches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> memoryWorkspacesRefs<T extends Object>(
    Expression<T> Function($$MemoryWorkspacesTableAnnotationComposer a) f,
  ) {
    final $$MemoryWorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoryWorkspaces,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryWorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryWorkspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemoryVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryVersionsTable,
          MemoryVersion,
          $$MemoryVersionsTableFilterComposer,
          $$MemoryVersionsTableOrderingComposer,
          $$MemoryVersionsTableAnnotationComposer,
          $$MemoryVersionsTableCreateCompanionBuilder,
          $$MemoryVersionsTableUpdateCompanionBuilder,
          (MemoryVersion, $$MemoryVersionsTableReferences),
          MemoryVersion,
          PrefetchHooks Function({bool speechId, bool memoryWorkspacesRefs})
        > {
  $$MemoryVersionsTableTableManager(
    _$AppDatabase db,
    $MemoryVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> speechId = const Value.absent(),
                Value<int> versionNumber = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> createdUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryVersionsCompanion(
                id: id,
                speechId: speechId,
                versionNumber: versionNumber,
                content: content,
                createdUtcMs: createdUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String speechId,
                required int versionNumber,
                required String content,
                required int createdUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => MemoryVersionsCompanion.insert(
                id: id,
                speechId: speechId,
                versionNumber: versionNumber,
                content: content,
                createdUtcMs: createdUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryVersionsTable, MemoryVersion>(table),
                  $$MemoryVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({speechId = false, memoryWorkspacesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (memoryWorkspacesRefs) db.memoryWorkspaces,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (speechId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.speechId,
                            referencedTable: $$MemoryVersionsTableReferences
                                ._speechIdTable(db),
                            referencedColumn: $$MemoryVersionsTableReferences
                                ._speechIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (memoryWorkspacesRefs)
                        await $_getPrefetchedDataByColumns<
                          MemoryVersion,
                          $MemoryVersionsTable,
                          MemoryWorkspace,
                          $MemoryWorkspacesTable
                        >(
                          currentTable: table,
                          referencedTable: $$MemoryVersionsTableReferences
                              ._memoryWorkspacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MemoryVersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).memoryWorkspacesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'version_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MemoryVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryVersionsTable,
      MemoryVersion,
      $$MemoryVersionsTableFilterComposer,
      $$MemoryVersionsTableOrderingComposer,
      $$MemoryVersionsTableAnnotationComposer,
      $$MemoryVersionsTableCreateCompanionBuilder,
      $$MemoryVersionsTableUpdateCompanionBuilder,
      (MemoryVersion, $$MemoryVersionsTableReferences),
      MemoryVersion,
      PrefetchHooks Function({bool speechId, bool memoryWorkspacesRefs})
    >;
typedef $$MemoryWorkspacesTableCreateCompanionBuilder =
    MemoryWorkspacesCompanion Function({
      required String sessionId,
      required String versionId,
      required String sectionId,
      required String mode,
      required String recallKind,
      required String cueStage,
      required String assistance,
      Value<String> assessments,
      Value<String> reviewNote,
      Value<bool> laterReview,
      Value<int> rowid,
    });
typedef $$MemoryWorkspacesTableUpdateCompanionBuilder =
    MemoryWorkspacesCompanion Function({
      Value<String> sessionId,
      Value<String> versionId,
      Value<String> sectionId,
      Value<String> mode,
      Value<String> recallKind,
      Value<String> cueStage,
      Value<String> assistance,
      Value<String> assessments,
      Value<String> reviewNote,
      Value<bool> laterReview,
      Value<int> rowid,
    });

final class $$MemoryWorkspacesTableReferences
    extends
        BaseReferences<_$AppDatabase, $MemoryWorkspacesTable, MemoryWorkspace> {
  $$MemoryWorkspacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('memory_workspaces__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MemoryVersionsTable _versionIdTable(_$AppDatabase db) => db
      .memoryVersions
      .createAlias('memory_workspaces__version_id__memory_versions__id');

  $$MemoryVersionsTableProcessedTableManager get versionId {
    final $_column = $_itemColumn<String>('version_id')!;

    final manager = $$MemoryVersionsTableTableManager(
      $_db,
      $_db.memoryVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoryWorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryWorkspacesTable> {
  $$MemoryWorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recallKind => $composableBuilder(
    column: $table.recallKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cueStage => $composableBuilder(
    column: $table.cueStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assistance => $composableBuilder(
    column: $table.assistance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewNote => $composableBuilder(
    column: $table.reviewNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get laterReview => $composableBuilder(
    column: $table.laterReview,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryVersionsTableFilterComposer get versionId {
    final $$MemoryVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.memoryVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVersionsTableFilterComposer(
            $db: $db,
            $table: $db.memoryVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryWorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryWorkspacesTable> {
  $$MemoryWorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sectionId => $composableBuilder(
    column: $table.sectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recallKind => $composableBuilder(
    column: $table.recallKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cueStage => $composableBuilder(
    column: $table.cueStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assistance => $composableBuilder(
    column: $table.assistance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewNote => $composableBuilder(
    column: $table.reviewNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get laterReview => $composableBuilder(
    column: $table.laterReview,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryVersionsTableOrderingComposer get versionId {
    final $$MemoryVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.memoryVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.memoryVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryWorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryWorkspacesTable> {
  $$MemoryWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get recallKind => $composableBuilder(
    column: $table.recallKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cueStage =>
      $composableBuilder(column: $table.cueStage, builder: (column) => column);

  GeneratedColumn<String> get assistance => $composableBuilder(
    column: $table.assistance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewNote => $composableBuilder(
    column: $table.reviewNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get laterReview => $composableBuilder(
    column: $table.laterReview,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MemoryVersionsTableAnnotationComposer get versionId {
    final $$MemoryVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.memoryVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoryVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.memoryVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoryWorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryWorkspacesTable,
          MemoryWorkspace,
          $$MemoryWorkspacesTableFilterComposer,
          $$MemoryWorkspacesTableOrderingComposer,
          $$MemoryWorkspacesTableAnnotationComposer,
          $$MemoryWorkspacesTableCreateCompanionBuilder,
          $$MemoryWorkspacesTableUpdateCompanionBuilder,
          (MemoryWorkspace, $$MemoryWorkspacesTableReferences),
          MemoryWorkspace,
          PrefetchHooks Function({bool sessionId, bool versionId})
        > {
  $$MemoryWorkspacesTableTableManager(
    _$AppDatabase db,
    $MemoryWorkspacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryWorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryWorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> recallKind = const Value.absent(),
                Value<String> cueStage = const Value.absent(),
                Value<String> assistance = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                Value<String> reviewNote = const Value.absent(),
                Value<bool> laterReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryWorkspacesCompanion(
                sessionId: sessionId,
                versionId: versionId,
                sectionId: sectionId,
                mode: mode,
                recallKind: recallKind,
                cueStage: cueStage,
                assistance: assistance,
                assessments: assessments,
                reviewNote: reviewNote,
                laterReview: laterReview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String versionId,
                required String sectionId,
                required String mode,
                required String recallKind,
                required String cueStage,
                required String assistance,
                Value<String> assessments = const Value.absent(),
                Value<String> reviewNote = const Value.absent(),
                Value<bool> laterReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryWorkspacesCompanion.insert(
                sessionId: sessionId,
                versionId: versionId,
                sectionId: sectionId,
                mode: mode,
                recallKind: recallKind,
                cueStage: cueStage,
                assistance: assistance,
                assessments: assessments,
                reviewNote: reviewNote,
                laterReview: laterReview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryWorkspacesTable, MemoryWorkspace>(table),
                  $$MemoryWorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, versionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$MemoryWorkspacesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$MemoryWorkspacesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (versionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.versionId,
                        referencedTable: $$MemoryWorkspacesTableReferences
                            ._versionIdTable(db),
                        referencedColumn: $$MemoryWorkspacesTableReferences
                            ._versionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MemoryWorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryWorkspacesTable,
      MemoryWorkspace,
      $$MemoryWorkspacesTableFilterComposer,
      $$MemoryWorkspacesTableOrderingComposer,
      $$MemoryWorkspacesTableAnnotationComposer,
      $$MemoryWorkspacesTableCreateCompanionBuilder,
      $$MemoryWorkspacesTableUpdateCompanionBuilder,
      (MemoryWorkspace, $$MemoryWorkspacesTableReferences),
      MemoryWorkspace,
      PrefetchHooks Function({bool sessionId, bool versionId})
    >;
typedef $$DebateWorkspacesTableCreateCompanionBuilder =
    DebateWorkspacesCompanion Function({
      required String sessionId,
      required String position,
      required String responseKind,
      required String preset,
      Value<int> currentStage,
      Value<String> assessments,
      Value<String> reviewNote,
      Value<int> rowid,
    });
typedef $$DebateWorkspacesTableUpdateCompanionBuilder =
    DebateWorkspacesCompanion Function({
      Value<String> sessionId,
      Value<String> position,
      Value<String> responseKind,
      Value<String> preset,
      Value<int> currentStage,
      Value<String> assessments,
      Value<String> reviewNote,
      Value<int> rowid,
    });

final class $$DebateWorkspacesTableReferences
    extends
        BaseReferences<_$AppDatabase, $DebateWorkspacesTable, DebateWorkspace> {
  $$DebateWorkspacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('debate_workspaces__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DebateWorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $DebateWorkspacesTable> {
  $$DebateWorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseKind => $composableBuilder(
    column: $table.responseKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preset => $composableBuilder(
    column: $table.preset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewNote => $composableBuilder(
    column: $table.reviewNote,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebateWorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $DebateWorkspacesTable> {
  $$DebateWorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseKind => $composableBuilder(
    column: $table.responseKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preset => $composableBuilder(
    column: $table.preset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewNote => $composableBuilder(
    column: $table.reviewNote,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebateWorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebateWorkspacesTable> {
  $$DebateWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get responseKind => $composableBuilder(
    column: $table.responseKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preset =>
      $composableBuilder(column: $table.preset, builder: (column) => column);

  GeneratedColumn<int> get currentStage => $composableBuilder(
    column: $table.currentStage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewNote => $composableBuilder(
    column: $table.reviewNote,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebateWorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebateWorkspacesTable,
          DebateWorkspace,
          $$DebateWorkspacesTableFilterComposer,
          $$DebateWorkspacesTableOrderingComposer,
          $$DebateWorkspacesTableAnnotationComposer,
          $$DebateWorkspacesTableCreateCompanionBuilder,
          $$DebateWorkspacesTableUpdateCompanionBuilder,
          (DebateWorkspace, $$DebateWorkspacesTableReferences),
          DebateWorkspace,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DebateWorkspacesTableTableManager(
    _$AppDatabase db,
    $DebateWorkspacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebateWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebateWorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebateWorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> position = const Value.absent(),
                Value<String> responseKind = const Value.absent(),
                Value<String> preset = const Value.absent(),
                Value<int> currentStage = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                Value<String> reviewNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebateWorkspacesCompanion(
                sessionId: sessionId,
                position: position,
                responseKind: responseKind,
                preset: preset,
                currentStage: currentStage,
                assessments: assessments,
                reviewNote: reviewNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String position,
                required String responseKind,
                required String preset,
                Value<int> currentStage = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                Value<String> reviewNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebateWorkspacesCompanion.insert(
                sessionId: sessionId,
                position: position,
                responseKind: responseKind,
                preset: preset,
                currentStage: currentStage,
                assessments: assessments,
                reviewNote: reviewNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebateWorkspacesTable, DebateWorkspace>(table),
                  $$DebateWorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$DebateWorkspacesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$DebateWorkspacesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DebateWorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebateWorkspacesTable,
      DebateWorkspace,
      $$DebateWorkspacesTableFilterComposer,
      $$DebateWorkspacesTableOrderingComposer,
      $$DebateWorkspacesTableAnnotationComposer,
      $$DebateWorkspacesTableCreateCompanionBuilder,
      $$DebateWorkspacesTableUpdateCompanionBuilder,
      (DebateWorkspace, $$DebateWorkspacesTableReferences),
      DebateWorkspace,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DebateStagesTableCreateCompanionBuilder =
    DebateStagesCompanion Function({
      required String sessionId,
      required String stageKey,
      required String status,
      Value<String> fields,
      Value<int> elapsedMs,
      Value<int?> finishedUtcMs,
      Value<int> rowid,
    });
typedef $$DebateStagesTableUpdateCompanionBuilder =
    DebateStagesCompanion Function({
      Value<String> sessionId,
      Value<String> stageKey,
      Value<String> status,
      Value<String> fields,
      Value<int> elapsedMs,
      Value<int?> finishedUtcMs,
      Value<int> rowid,
    });

final class $$DebateStagesTableReferences
    extends BaseReferences<_$AppDatabase, $DebateStagesTable, DebateStage> {
  $$DebateStagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('debate_stages__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DebateStagesTableFilterComposer
    extends Composer<_$AppDatabase, $DebateStagesTable> {
  $$DebateStagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stageKey => $composableBuilder(
    column: $table.stageKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedUtcMs => $composableBuilder(
    column: $table.finishedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebateStagesTableOrderingComposer
    extends Composer<_$AppDatabase, $DebateStagesTable> {
  $$DebateStagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stageKey => $composableBuilder(
    column: $table.stageKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedUtcMs => $composableBuilder(
    column: $table.finishedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebateStagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DebateStagesTable> {
  $$DebateStagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stageKey =>
      $composableBuilder(column: $table.stageKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get finishedUtcMs => $composableBuilder(
    column: $table.finishedUtcMs,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DebateStagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DebateStagesTable,
          DebateStage,
          $$DebateStagesTableFilterComposer,
          $$DebateStagesTableOrderingComposer,
          $$DebateStagesTableAnnotationComposer,
          $$DebateStagesTableCreateCompanionBuilder,
          $$DebateStagesTableUpdateCompanionBuilder,
          (DebateStage, $$DebateStagesTableReferences),
          DebateStage,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DebateStagesTableTableManager(_$AppDatabase db, $DebateStagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DebateStagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DebateStagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DebateStagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> stageKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int?> finishedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebateStagesCompanion(
                sessionId: sessionId,
                stageKey: stageKey,
                status: status,
                fields: fields,
                elapsedMs: elapsedMs,
                finishedUtcMs: finishedUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String stageKey,
                required String status,
                Value<String> fields = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int?> finishedUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DebateStagesCompanion.insert(
                sessionId: sessionId,
                stageKey: stageKey,
                status: status,
                fields: fields,
                elapsedMs: elapsedMs,
                finishedUtcMs: finishedUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DebateStagesTable, DebateStage>(table),
                  $$DebateStagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$DebateStagesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$DebateStagesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DebateStagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DebateStagesTable,
      DebateStage,
      $$DebateStagesTableFilterComposer,
      $$DebateStagesTableOrderingComposer,
      $$DebateStagesTableAnnotationComposer,
      $$DebateStagesTableCreateCompanionBuilder,
      $$DebateStagesTableUpdateCompanionBuilder,
      (DebateStage, $$DebateStagesTableReferences),
      DebateStage,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ImpromptuQueuesTableCreateCompanionBuilder =
    ImpromptuQueuesCompanion Function({
      required String poolKey,
      required String remaining,
      required String lastQuestion,
      Value<int> rowid,
    });
typedef $$ImpromptuQueuesTableUpdateCompanionBuilder =
    ImpromptuQueuesCompanion Function({
      Value<String> poolKey,
      Value<String> remaining,
      Value<String> lastQuestion,
      Value<int> rowid,
    });

class $$ImpromptuQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $ImpromptuQueuesTable> {
  $$ImpromptuQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get poolKey => $composableBuilder(
    column: $table.poolKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastQuestion => $composableBuilder(
    column: $table.lastQuestion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImpromptuQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImpromptuQueuesTable> {
  $$ImpromptuQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get poolKey => $composableBuilder(
    column: $table.poolKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remaining => $composableBuilder(
    column: $table.remaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastQuestion => $composableBuilder(
    column: $table.lastQuestion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImpromptuQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImpromptuQueuesTable> {
  $$ImpromptuQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get poolKey =>
      $composableBuilder(column: $table.poolKey, builder: (column) => column);

  GeneratedColumn<String> get remaining =>
      $composableBuilder(column: $table.remaining, builder: (column) => column);

  GeneratedColumn<String> get lastQuestion => $composableBuilder(
    column: $table.lastQuestion,
    builder: (column) => column,
  );
}

class $$ImpromptuQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImpromptuQueuesTable,
          ImpromptuQueue,
          $$ImpromptuQueuesTableFilterComposer,
          $$ImpromptuQueuesTableOrderingComposer,
          $$ImpromptuQueuesTableAnnotationComposer,
          $$ImpromptuQueuesTableCreateCompanionBuilder,
          $$ImpromptuQueuesTableUpdateCompanionBuilder,
          (
            ImpromptuQueue,
            BaseReferences<
              _$AppDatabase,
              $ImpromptuQueuesTable,
              ImpromptuQueue
            >,
          ),
          ImpromptuQueue,
          PrefetchHooks Function()
        > {
  $$ImpromptuQueuesTableTableManager(
    _$AppDatabase db,
    $ImpromptuQueuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImpromptuQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImpromptuQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImpromptuQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> poolKey = const Value.absent(),
                Value<String> remaining = const Value.absent(),
                Value<String> lastQuestion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImpromptuQueuesCompanion(
                poolKey: poolKey,
                remaining: remaining,
                lastQuestion: lastQuestion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String poolKey,
                required String remaining,
                required String lastQuestion,
                Value<int> rowid = const Value.absent(),
              }) => ImpromptuQueuesCompanion.insert(
                poolKey: poolKey,
                remaining: remaining,
                lastQuestion: lastQuestion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImpromptuQueuesTable, ImpromptuQueue>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImpromptuQueuesTable,
                    ImpromptuQueue
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImpromptuQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImpromptuQueuesTable,
      ImpromptuQueue,
      $$ImpromptuQueuesTableFilterComposer,
      $$ImpromptuQueuesTableOrderingComposer,
      $$ImpromptuQueuesTableAnnotationComposer,
      $$ImpromptuQueuesTableCreateCompanionBuilder,
      $$ImpromptuQueuesTableUpdateCompanionBuilder,
      (
        ImpromptuQueue,
        BaseReferences<_$AppDatabase, $ImpromptuQueuesTable, ImpromptuQueue>,
      ),
      ImpromptuQueue,
      PrefetchHooks Function()
    >;
typedef $$ImpromptuWorkspacesTableCreateCompanionBuilder =
    ImpromptuWorkspacesCompanion Function({
      required String sessionId,
      required String requestKey,
      Value<String?> parentSessionId,
      Value<String> improvement,
      required String responseKind,
      required String preset,
      Value<String> viewStep,
      Value<String> preparation,
      Value<bool> scaffoldEnabled,
      Value<String> scaffold,
      Value<String> assessments,
      Value<String> reflection,
      Value<int?> confidence,
      Value<int> rowid,
    });
typedef $$ImpromptuWorkspacesTableUpdateCompanionBuilder =
    ImpromptuWorkspacesCompanion Function({
      Value<String> sessionId,
      Value<String> requestKey,
      Value<String?> parentSessionId,
      Value<String> improvement,
      Value<String> responseKind,
      Value<String> preset,
      Value<String> viewStep,
      Value<String> preparation,
      Value<bool> scaffoldEnabled,
      Value<String> scaffold,
      Value<String> assessments,
      Value<String> reflection,
      Value<int?> confidence,
      Value<int> rowid,
    });

final class $$ImpromptuWorkspacesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ImpromptuWorkspacesTable,
          ImpromptuWorkspace
        > {
  $$ImpromptuWorkspacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('impromptu_workspaces__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PracticeSessionsTable _parentSessionIdTable(_$AppDatabase db) =>
      db.practiceSessions.createAlias(
        'impromptu_workspaces__parent_session_id__practice_sessions__id',
      );

  $$PracticeSessionsTableProcessedTableManager? get parentSessionId {
    final $_column = $_itemColumn<String>('parent_session_id');
    if ($_column == null) return null;
    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImpromptuWorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $ImpromptuWorkspacesTable> {
  $$ImpromptuWorkspacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get improvement => $composableBuilder(
    column: $table.improvement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseKind => $composableBuilder(
    column: $table.responseKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preset => $composableBuilder(
    column: $table.preset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get viewStep => $composableBuilder(
    column: $table.viewStep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scaffoldEnabled => $composableBuilder(
    column: $table.scaffoldEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scaffold => $composableBuilder(
    column: $table.scaffold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableFilterComposer get parentSessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImpromptuWorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImpromptuWorkspacesTable> {
  $$ImpromptuWorkspacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get improvement => $composableBuilder(
    column: $table.improvement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseKind => $composableBuilder(
    column: $table.responseKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preset => $composableBuilder(
    column: $table.preset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get viewStep => $composableBuilder(
    column: $table.viewStep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scaffoldEnabled => $composableBuilder(
    column: $table.scaffoldEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scaffold => $composableBuilder(
    column: $table.scaffold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableOrderingComposer get parentSessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImpromptuWorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImpromptuWorkspacesTable> {
  $$ImpromptuWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get improvement => $composableBuilder(
    column: $table.improvement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseKind => $composableBuilder(
    column: $table.responseKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preset =>
      $composableBuilder(column: $table.preset, builder: (column) => column);

  GeneratedColumn<String> get viewStep =>
      $composableBuilder(column: $table.viewStep, builder: (column) => column);

  GeneratedColumn<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get scaffoldEnabled => $composableBuilder(
    column: $table.scaffoldEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scaffold =>
      $composableBuilder(column: $table.scaffold, builder: (column) => column);

  GeneratedColumn<String> get assessments => $composableBuilder(
    column: $table.assessments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableAnnotationComposer get parentSessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImpromptuWorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImpromptuWorkspacesTable,
          ImpromptuWorkspace,
          $$ImpromptuWorkspacesTableFilterComposer,
          $$ImpromptuWorkspacesTableOrderingComposer,
          $$ImpromptuWorkspacesTableAnnotationComposer,
          $$ImpromptuWorkspacesTableCreateCompanionBuilder,
          $$ImpromptuWorkspacesTableUpdateCompanionBuilder,
          (ImpromptuWorkspace, $$ImpromptuWorkspacesTableReferences),
          ImpromptuWorkspace,
          PrefetchHooks Function({bool sessionId, bool parentSessionId})
        > {
  $$ImpromptuWorkspacesTableTableManager(
    _$AppDatabase db,
    $ImpromptuWorkspacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImpromptuWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImpromptuWorkspacesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ImpromptuWorkspacesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> requestKey = const Value.absent(),
                Value<String?> parentSessionId = const Value.absent(),
                Value<String> improvement = const Value.absent(),
                Value<String> responseKind = const Value.absent(),
                Value<String> preset = const Value.absent(),
                Value<String> viewStep = const Value.absent(),
                Value<String> preparation = const Value.absent(),
                Value<bool> scaffoldEnabled = const Value.absent(),
                Value<String> scaffold = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                Value<String> reflection = const Value.absent(),
                Value<int?> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImpromptuWorkspacesCompanion(
                sessionId: sessionId,
                requestKey: requestKey,
                parentSessionId: parentSessionId,
                improvement: improvement,
                responseKind: responseKind,
                preset: preset,
                viewStep: viewStep,
                preparation: preparation,
                scaffoldEnabled: scaffoldEnabled,
                scaffold: scaffold,
                assessments: assessments,
                reflection: reflection,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String requestKey,
                Value<String?> parentSessionId = const Value.absent(),
                Value<String> improvement = const Value.absent(),
                required String responseKind,
                required String preset,
                Value<String> viewStep = const Value.absent(),
                Value<String> preparation = const Value.absent(),
                Value<bool> scaffoldEnabled = const Value.absent(),
                Value<String> scaffold = const Value.absent(),
                Value<String> assessments = const Value.absent(),
                Value<String> reflection = const Value.absent(),
                Value<int?> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImpromptuWorkspacesCompanion.insert(
                sessionId: sessionId,
                requestKey: requestKey,
                parentSessionId: parentSessionId,
                improvement: improvement,
                responseKind: responseKind,
                preset: preset,
                viewStep: viewStep,
                preparation: preparation,
                scaffoldEnabled: scaffoldEnabled,
                scaffold: scaffold,
                assessments: assessments,
                reflection: reflection,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImpromptuWorkspacesTable, ImpromptuWorkspace>(
                    table,
                  ),
                  $$ImpromptuWorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, parentSessionId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable:
                                $$ImpromptuWorkspacesTableReferences
                                    ._sessionIdTable(db),
                            referencedColumn:
                                $$ImpromptuWorkspacesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (parentSessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentSessionId,
                            referencedTable:
                                $$ImpromptuWorkspacesTableReferences
                                    ._parentSessionIdTable(db),
                            referencedColumn:
                                $$ImpromptuWorkspacesTableReferences
                                    ._parentSessionIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ImpromptuWorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImpromptuWorkspacesTable,
      ImpromptuWorkspace,
      $$ImpromptuWorkspacesTableFilterComposer,
      $$ImpromptuWorkspacesTableOrderingComposer,
      $$ImpromptuWorkspacesTableAnnotationComposer,
      $$ImpromptuWorkspacesTableCreateCompanionBuilder,
      $$ImpromptuWorkspacesTableUpdateCompanionBuilder,
      (ImpromptuWorkspace, $$ImpromptuWorkspacesTableReferences),
      ImpromptuWorkspace,
      PrefetchHooks Function({bool sessionId, bool parentSessionId})
    >;
typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      required String id,
      required int version,
      required String snapshot,
      required int createdUtcMs,
      Value<int> rowid,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> snapshot,
      Value<int> createdUtcMs,
      Value<int> rowid,
    });

class $$CustomExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshot => $composableBuilder(
    column: $table.snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get snapshot =>
      $composableBuilder(column: $table.snapshot, builder: (column) => column);

  GeneratedColumn<int> get createdUtcMs => $composableBuilder(
    column: $table.createdUtcMs,
    builder: (column) => column,
  );
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomExercisesTable,
          CustomExercise,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (
            CustomExercise,
            BaseReferences<
              _$AppDatabase,
              $CustomExercisesTable,
              CustomExercise
            >,
          ),
          CustomExercise,
          PrefetchHooks Function()
        > {
  $$CustomExercisesTableTableManager(
    _$AppDatabase db,
    $CustomExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> snapshot = const Value.absent(),
                Value<int> createdUtcMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                version: version,
                snapshot: snapshot,
                createdUtcMs: createdUtcMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int version,
                required String snapshot,
                required int createdUtcMs,
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion.insert(
                id: id,
                version: version,
                snapshot: snapshot,
                createdUtcMs: createdUtcMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomExercisesTable, CustomExercise>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomExercisesTable,
                    CustomExercise
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomExercisesTable,
      CustomExercise,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (
        CustomExercise,
        BaseReferences<_$AppDatabase, $CustomExercisesTable, CustomExercise>,
      ),
      CustomExercise,
      PrefetchHooks Function()
    >;
typedef $$PracticeContextsTableCreateCompanionBuilder =
    PracticeContextsCompanion Function({
      required String sessionId,
      required String requestKey,
      Value<String?> parentSessionId,
      required String label,
      required String conditions,
      required String target,
      Value<int> rowid,
    });
typedef $$PracticeContextsTableUpdateCompanionBuilder =
    PracticeContextsCompanion Function({
      Value<String> sessionId,
      Value<String> requestKey,
      Value<String?> parentSessionId,
      Value<String> label,
      Value<String> conditions,
      Value<String> target,
      Value<int> rowid,
    });

final class $$PracticeContextsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PracticeContextsTable, PracticeContext> {
  $$PracticeContextsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('practice_contexts__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PracticeSessionsTable _parentSessionIdTable(_$AppDatabase db) =>
      db.practiceSessions.createAlias(
        'practice_contexts__parent_session_id__practice_sessions__id',
      );

  $$PracticeSessionsTableProcessedTableManager? get parentSessionId {
    final $_column = $_itemColumn<String>('parent_session_id');
    if ($_column == null) return null;
    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PracticeContextsTableFilterComposer
    extends Composer<_$AppDatabase, $PracticeContextsTable> {
  $$PracticeContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableFilterComposer get parentSessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $PracticeContextsTable> {
  $$PracticeContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableOrderingComposer get parentSessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PracticeContextsTable> {
  $$PracticeContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get conditions => $composableBuilder(
    column: $table.conditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PracticeSessionsTableAnnotationComposer get parentSessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PracticeContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PracticeContextsTable,
          PracticeContext,
          $$PracticeContextsTableFilterComposer,
          $$PracticeContextsTableOrderingComposer,
          $$PracticeContextsTableAnnotationComposer,
          $$PracticeContextsTableCreateCompanionBuilder,
          $$PracticeContextsTableUpdateCompanionBuilder,
          (PracticeContext, $$PracticeContextsTableReferences),
          PracticeContext,
          PrefetchHooks Function({bool sessionId, bool parentSessionId})
        > {
  $$PracticeContextsTableTableManager(
    _$AppDatabase db,
    $PracticeContextsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeContextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeContextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> requestKey = const Value.absent(),
                Value<String?> parentSessionId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> conditions = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PracticeContextsCompanion(
                sessionId: sessionId,
                requestKey: requestKey,
                parentSessionId: parentSessionId,
                label: label,
                conditions: conditions,
                target: target,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String requestKey,
                Value<String?> parentSessionId = const Value.absent(),
                required String label,
                required String conditions,
                required String target,
                Value<int> rowid = const Value.absent(),
              }) => PracticeContextsCompanion.insert(
                sessionId: sessionId,
                requestKey: requestKey,
                parentSessionId: parentSessionId,
                label: label,
                conditions: conditions,
                target: target,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PracticeContextsTable, PracticeContext>(table),
                  $$PracticeContextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionId = false, parentSessionId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$PracticeContextsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$PracticeContextsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (parentSessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentSessionId,
                            referencedTable: $$PracticeContextsTableReferences
                                ._parentSessionIdTable(db),
                            referencedColumn: $$PracticeContextsTableReferences
                                ._parentSessionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PracticeContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PracticeContextsTable,
      PracticeContext,
      $$PracticeContextsTableFilterComposer,
      $$PracticeContextsTableOrderingComposer,
      $$PracticeContextsTableAnnotationComposer,
      $$PracticeContextsTableCreateCompanionBuilder,
      $$PracticeContextsTableUpdateCompanionBuilder,
      (PracticeContext, $$PracticeContextsTableReferences),
      PracticeContext,
      PrefetchHooks Function({bool sessionId, bool parentSessionId})
    >;
typedef $$RecallSchedulesTableCreateCompanionBuilder =
    RecallSchedulesCompanion Function({
      required int sequence,
      required String sessionId,
      required String observation,
      required String observedLocalDate,
      required int originalOffsetMinutes,
      required int observedUtcMs,
      required int intervalIndex,
      required int intervalDays,
      required String recommendedDate,
      Value<String?> overrideDate,
      Value<bool> paused,
      Value<int> rowid,
    });
typedef $$RecallSchedulesTableUpdateCompanionBuilder =
    RecallSchedulesCompanion Function({
      Value<int> sequence,
      Value<String> sessionId,
      Value<String> observation,
      Value<String> observedLocalDate,
      Value<int> originalOffsetMinutes,
      Value<int> observedUtcMs,
      Value<int> intervalIndex,
      Value<int> intervalDays,
      Value<String> recommendedDate,
      Value<String?> overrideDate,
      Value<bool> paused,
      Value<int> rowid,
    });

final class $$RecallSchedulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $RecallSchedulesTable, RecallSchedule> {
  $$RecallSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PracticeSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .practiceSessions
      .createAlias('recall_schedules__session_id__practice_sessions__id');

  $$PracticeSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$PracticeSessionsTableTableManager(
      $_db,
      $_db.practiceSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecallSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecallSchedulesTable> {
  $$RecallSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observedLocalDate => $composableBuilder(
    column: $table.observedLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalOffsetMinutes => $composableBuilder(
    column: $table.originalOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get observedUtcMs => $composableBuilder(
    column: $table.observedUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalIndex => $composableBuilder(
    column: $table.intervalIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedDate => $composableBuilder(
    column: $table.recommendedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideDate => $composableBuilder(
    column: $table.overrideDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  $$PracticeSessionsTableFilterComposer get sessionId {
    final $$PracticeSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableFilterComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecallSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecallSchedulesTable> {
  $$RecallSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observedLocalDate => $composableBuilder(
    column: $table.observedLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalOffsetMinutes => $composableBuilder(
    column: $table.originalOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get observedUtcMs => $composableBuilder(
    column: $table.observedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalIndex => $composableBuilder(
    column: $table.intervalIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedDate => $composableBuilder(
    column: $table.recommendedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideDate => $composableBuilder(
    column: $table.overrideDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  $$PracticeSessionsTableOrderingComposer get sessionId {
    final $$PracticeSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecallSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecallSchedulesTable> {
  $$RecallSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observedLocalDate => $composableBuilder(
    column: $table.observedLocalDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalOffsetMinutes => $composableBuilder(
    column: $table.originalOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get observedUtcMs => $composableBuilder(
    column: $table.observedUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalIndex => $composableBuilder(
    column: $table.intervalIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendedDate => $composableBuilder(
    column: $table.recommendedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideDate => $composableBuilder(
    column: $table.overrideDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  $$PracticeSessionsTableAnnotationComposer get sessionId {
    final $$PracticeSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.practiceSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PracticeSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.practiceSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecallSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecallSchedulesTable,
          RecallSchedule,
          $$RecallSchedulesTableFilterComposer,
          $$RecallSchedulesTableOrderingComposer,
          $$RecallSchedulesTableAnnotationComposer,
          $$RecallSchedulesTableCreateCompanionBuilder,
          $$RecallSchedulesTableUpdateCompanionBuilder,
          (RecallSchedule, $$RecallSchedulesTableReferences),
          RecallSchedule,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RecallSchedulesTableTableManager(
    _$AppDatabase db,
    $RecallSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecallSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecallSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecallSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> observation = const Value.absent(),
                Value<String> observedLocalDate = const Value.absent(),
                Value<int> originalOffsetMinutes = const Value.absent(),
                Value<int> observedUtcMs = const Value.absent(),
                Value<int> intervalIndex = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<String> recommendedDate = const Value.absent(),
                Value<String?> overrideDate = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecallSchedulesCompanion(
                sequence: sequence,
                sessionId: sessionId,
                observation: observation,
                observedLocalDate: observedLocalDate,
                originalOffsetMinutes: originalOffsetMinutes,
                observedUtcMs: observedUtcMs,
                intervalIndex: intervalIndex,
                intervalDays: intervalDays,
                recommendedDate: recommendedDate,
                overrideDate: overrideDate,
                paused: paused,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int sequence,
                required String sessionId,
                required String observation,
                required String observedLocalDate,
                required int originalOffsetMinutes,
                required int observedUtcMs,
                required int intervalIndex,
                required int intervalDays,
                required String recommendedDate,
                Value<String?> overrideDate = const Value.absent(),
                Value<bool> paused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecallSchedulesCompanion.insert(
                sequence: sequence,
                sessionId: sessionId,
                observation: observation,
                observedLocalDate: observedLocalDate,
                originalOffsetMinutes: originalOffsetMinutes,
                observedUtcMs: observedUtcMs,
                intervalIndex: intervalIndex,
                intervalDays: intervalDays,
                recommendedDate: recommendedDate,
                overrideDate: overrideDate,
                paused: paused,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecallSchedulesTable, RecallSchedule>(table),
                  $$RecallSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$RecallSchedulesTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$RecallSchedulesTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecallSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecallSchedulesTable,
      RecallSchedule,
      $$RecallSchedulesTableFilterComposer,
      $$RecallSchedulesTableOrderingComposer,
      $$RecallSchedulesTableAnnotationComposer,
      $$RecallSchedulesTableCreateCompanionBuilder,
      $$RecallSchedulesTableUpdateCompanionBuilder,
      (RecallSchedule, $$RecallSchedulesTableReferences),
      RecallSchedule,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PracticeSessionsTableTableManager get practiceSessions =>
      $$PracticeSessionsTableTableManager(_db, _db.practiceSessions);
  $$ResponsesTableTableManager get responses =>
      $$ResponsesTableTableManager(_db, _db.responses);
  $$TimingSegmentsTableTableManager get timingSegments =>
      $$TimingSegmentsTableTableManager(_db, _db.timingSegments);
  $$ReviewRecordsTableTableManager get reviewRecords =>
      $$ReviewRecordsTableTableManager(_db, _db.reviewRecords);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$WritingWorkspacesTableTableManager get writingWorkspaces =>
      $$WritingWorkspacesTableTableManager(_db, _db.writingWorkspaces);
  $$ReadingWorkspacesTableTableManager get readingWorkspaces =>
      $$ReadingWorkspacesTableTableManager(_db, _db.readingWorkspaces);
  $$AudioRecordingsTableTableManager get audioRecordings =>
      $$AudioRecordingsTableTableManager(_db, _db.audioRecordings);
  $$AudioObservationsTableTableManager get audioObservations =>
      $$AudioObservationsTableTableManager(_db, _db.audioObservations);
  $$MemorySpeechesTableTableManager get memorySpeeches =>
      $$MemorySpeechesTableTableManager(_db, _db.memorySpeeches);
  $$MemoryVersionsTableTableManager get memoryVersions =>
      $$MemoryVersionsTableTableManager(_db, _db.memoryVersions);
  $$MemoryWorkspacesTableTableManager get memoryWorkspaces =>
      $$MemoryWorkspacesTableTableManager(_db, _db.memoryWorkspaces);
  $$DebateWorkspacesTableTableManager get debateWorkspaces =>
      $$DebateWorkspacesTableTableManager(_db, _db.debateWorkspaces);
  $$DebateStagesTableTableManager get debateStages =>
      $$DebateStagesTableTableManager(_db, _db.debateStages);
  $$ImpromptuQueuesTableTableManager get impromptuQueues =>
      $$ImpromptuQueuesTableTableManager(_db, _db.impromptuQueues);
  $$ImpromptuWorkspacesTableTableManager get impromptuWorkspaces =>
      $$ImpromptuWorkspacesTableTableManager(_db, _db.impromptuWorkspaces);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
  $$PracticeContextsTableTableManager get practiceContexts =>
      $$PracticeContextsTableTableManager(_db, _db.practiceContexts);
  $$RecallSchedulesTableTableManager get recallSchedules =>
      $$RecallSchedulesTableTableManager(_db, _db.recallSchedules);
}
