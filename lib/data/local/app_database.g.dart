// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final String payload;
  final DateTime updatedAt;
  const UserProfile({
    required this.id,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfile copyWith({int? id, String? payload, DateTime? updatedAt}) =>
      UserProfile(
        id: id ?? this.id,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
    required DateTime updatedAt,
  }) : payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CravingLogsTable extends CravingLogs
    with TableInfo<$CravingLogsTable, CravingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CravingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cravingTypeMeta = const VerificationMeta(
    'cravingType',
  );
  @override
  late final GeneratedColumn<String> cravingType = GeneratedColumn<String>(
    'craving_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtriggerIdMeta = const VerificationMeta(
    'subtriggerId',
  );
  @override
  late final GeneratedColumn<String> subtriggerId = GeneratedColumn<String>(
    'subtrigger_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intensityBeforeMeta = const VerificationMeta(
    'intensityBefore',
  );
  @override
  late final GeneratedColumn<int> intensityBefore = GeneratedColumn<int>(
    'intensity_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityAfterMeta = const VerificationMeta(
    'intensityAfter',
  );
  @override
  late final GeneratedColumn<int> intensityAfter = GeneratedColumn<int>(
    'intensity_after',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hungryMeta = const VerificationMeta('hungry');
  @override
  late final GeneratedColumn<bool> hungry = GeneratedColumn<bool>(
    'hungry',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hungry" IN (0, 1))',
    ),
  );
  static const VerificationMeta _safetyExitMeta = const VerificationMeta(
    'safetyExit',
  );
  @override
  late final GeneratedColumn<String> safetyExit = GeneratedColumn<String>(
    'safety_exit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planTitleMeta = const VerificationMeta(
    'planTitle',
  );
  @override
  late final GeneratedColumn<String> planTitle = GeneratedColumn<String>(
    'plan_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nonLearnableMeta = const VerificationMeta(
    'nonLearnable',
  );
  @override
  late final GeneratedColumn<bool> nonLearnable = GeneratedColumn<bool>(
    'non_learnable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("non_learnable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _planCompletedMeta = const VerificationMeta(
    'planCompleted',
  );
  @override
  late final GeneratedColumn<bool> planCompleted = GeneratedColumn<bool>(
    'plan_completed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("plan_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _helpfulStepIndexMeta = const VerificationMeta(
    'helpfulStepIndex',
  );
  @override
  late final GeneratedColumn<int> helpfulStepIndex = GeneratedColumn<int>(
    'helpful_step_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cravingReturnedMeta = const VerificationMeta(
    'cravingReturned',
  );
  @override
  late final GeneratedColumn<bool> cravingReturned = GeneratedColumn<bool>(
    'craving_returned',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("craving_returned" IN (0, 1))',
    ),
  );
  static const VerificationMeta _contextJsonMeta = const VerificationMeta(
    'contextJson',
  );
  @override
  late final GeneratedColumn<String> contextJson = GeneratedColumn<String>(
    'context_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    completedAt,
    cravingType,
    category,
    subtriggerId,
    intensityBefore,
    intensityAfter,
    hungry,
    safetyExit,
    planId,
    planTitle,
    nonLearnable,
    outcome,
    planCompleted,
    helpfulStepIndex,
    cravingReturned,
    contextJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'craving_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CravingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('craving_type')) {
      context.handle(
        _cravingTypeMeta,
        cravingType.isAcceptableOrUnknown(
          data['craving_type']!,
          _cravingTypeMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('subtrigger_id')) {
      context.handle(
        _subtriggerIdMeta,
        subtriggerId.isAcceptableOrUnknown(
          data['subtrigger_id']!,
          _subtriggerIdMeta,
        ),
      );
    }
    if (data.containsKey('intensity_before')) {
      context.handle(
        _intensityBeforeMeta,
        intensityBefore.isAcceptableOrUnknown(
          data['intensity_before']!,
          _intensityBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intensityBeforeMeta);
    }
    if (data.containsKey('intensity_after')) {
      context.handle(
        _intensityAfterMeta,
        intensityAfter.isAcceptableOrUnknown(
          data['intensity_after']!,
          _intensityAfterMeta,
        ),
      );
    }
    if (data.containsKey('hungry')) {
      context.handle(
        _hungryMeta,
        hungry.isAcceptableOrUnknown(data['hungry']!, _hungryMeta),
      );
    }
    if (data.containsKey('safety_exit')) {
      context.handle(
        _safetyExitMeta,
        safetyExit.isAcceptableOrUnknown(data['safety_exit']!, _safetyExitMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyExitMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('plan_title')) {
      context.handle(
        _planTitleMeta,
        planTitle.isAcceptableOrUnknown(data['plan_title']!, _planTitleMeta),
      );
    }
    if (data.containsKey('non_learnable')) {
      context.handle(
        _nonLearnableMeta,
        nonLearnable.isAcceptableOrUnknown(
          data['non_learnable']!,
          _nonLearnableMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('plan_completed')) {
      context.handle(
        _planCompletedMeta,
        planCompleted.isAcceptableOrUnknown(
          data['plan_completed']!,
          _planCompletedMeta,
        ),
      );
    }
    if (data.containsKey('helpful_step_index')) {
      context.handle(
        _helpfulStepIndexMeta,
        helpfulStepIndex.isAcceptableOrUnknown(
          data['helpful_step_index']!,
          _helpfulStepIndexMeta,
        ),
      );
    }
    if (data.containsKey('craving_returned')) {
      context.handle(
        _cravingReturnedMeta,
        cravingReturned.isAcceptableOrUnknown(
          data['craving_returned']!,
          _cravingReturnedMeta,
        ),
      );
    }
    if (data.containsKey('context_json')) {
      context.handle(
        _contextJsonMeta,
        contextJson.isAcceptableOrUnknown(
          data['context_json']!,
          _contextJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CravingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CravingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      cravingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}craving_type'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subtriggerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtrigger_id'],
      ),
      intensityBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity_before'],
      )!,
      intensityAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity_after'],
      ),
      hungry: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hungry'],
      ),
      safetyExit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_exit'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
      planTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_title'],
      ),
      nonLearnable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}non_learnable'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      planCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}plan_completed'],
      ),
      helpfulStepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}helpful_step_index'],
      ),
      cravingReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}craving_returned'],
      ),
      contextJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_json'],
      )!,
    );
  }

  @override
  $CravingLogsTable createAlias(String alias) {
    return $CravingLogsTable(attachedDatabase, alias);
  }
}

class CravingLog extends DataClass implements Insertable<CravingLog> {
  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final String? cravingType;
  final String? category;
  final String? subtriggerId;
  final int intensityBefore;
  final int? intensityAfter;
  final bool? hungry;
  final String safetyExit;
  final String? planId;
  final String? planTitle;
  final bool nonLearnable;
  final String? outcome;
  final bool? planCompleted;
  final int? helpfulStepIndex;
  final bool? cravingReturned;
  final String contextJson;
  const CravingLog({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    this.cravingType,
    this.category,
    this.subtriggerId,
    required this.intensityBefore,
    this.intensityAfter,
    this.hungry,
    required this.safetyExit,
    this.planId,
    this.planTitle,
    required this.nonLearnable,
    this.outcome,
    this.planCompleted,
    this.helpfulStepIndex,
    this.cravingReturned,
    required this.contextJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || cravingType != null) {
      map['craving_type'] = Variable<String>(cravingType);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || subtriggerId != null) {
      map['subtrigger_id'] = Variable<String>(subtriggerId);
    }
    map['intensity_before'] = Variable<int>(intensityBefore);
    if (!nullToAbsent || intensityAfter != null) {
      map['intensity_after'] = Variable<int>(intensityAfter);
    }
    if (!nullToAbsent || hungry != null) {
      map['hungry'] = Variable<bool>(hungry);
    }
    map['safety_exit'] = Variable<String>(safetyExit);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    if (!nullToAbsent || planTitle != null) {
      map['plan_title'] = Variable<String>(planTitle);
    }
    map['non_learnable'] = Variable<bool>(nonLearnable);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || planCompleted != null) {
      map['plan_completed'] = Variable<bool>(planCompleted);
    }
    if (!nullToAbsent || helpfulStepIndex != null) {
      map['helpful_step_index'] = Variable<int>(helpfulStepIndex);
    }
    if (!nullToAbsent || cravingReturned != null) {
      map['craving_returned'] = Variable<bool>(cravingReturned);
    }
    map['context_json'] = Variable<String>(contextJson);
    return map;
  }

  CravingLogsCompanion toCompanion(bool nullToAbsent) {
    return CravingLogsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      cravingType: cravingType == null && nullToAbsent
          ? const Value.absent()
          : Value(cravingType),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      subtriggerId: subtriggerId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtriggerId),
      intensityBefore: Value(intensityBefore),
      intensityAfter: intensityAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(intensityAfter),
      hungry: hungry == null && nullToAbsent
          ? const Value.absent()
          : Value(hungry),
      safetyExit: Value(safetyExit),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      planTitle: planTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(planTitle),
      nonLearnable: Value(nonLearnable),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      planCompleted: planCompleted == null && nullToAbsent
          ? const Value.absent()
          : Value(planCompleted),
      helpfulStepIndex: helpfulStepIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(helpfulStepIndex),
      cravingReturned: cravingReturned == null && nullToAbsent
          ? const Value.absent()
          : Value(cravingReturned),
      contextJson: Value(contextJson),
    );
  }

  factory CravingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CravingLog(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      cravingType: serializer.fromJson<String?>(json['cravingType']),
      category: serializer.fromJson<String?>(json['category']),
      subtriggerId: serializer.fromJson<String?>(json['subtriggerId']),
      intensityBefore: serializer.fromJson<int>(json['intensityBefore']),
      intensityAfter: serializer.fromJson<int?>(json['intensityAfter']),
      hungry: serializer.fromJson<bool?>(json['hungry']),
      safetyExit: serializer.fromJson<String>(json['safetyExit']),
      planId: serializer.fromJson<String?>(json['planId']),
      planTitle: serializer.fromJson<String?>(json['planTitle']),
      nonLearnable: serializer.fromJson<bool>(json['nonLearnable']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      planCompleted: serializer.fromJson<bool?>(json['planCompleted']),
      helpfulStepIndex: serializer.fromJson<int?>(json['helpfulStepIndex']),
      cravingReturned: serializer.fromJson<bool?>(json['cravingReturned']),
      contextJson: serializer.fromJson<String>(json['contextJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'cravingType': serializer.toJson<String?>(cravingType),
      'category': serializer.toJson<String?>(category),
      'subtriggerId': serializer.toJson<String?>(subtriggerId),
      'intensityBefore': serializer.toJson<int>(intensityBefore),
      'intensityAfter': serializer.toJson<int?>(intensityAfter),
      'hungry': serializer.toJson<bool?>(hungry),
      'safetyExit': serializer.toJson<String>(safetyExit),
      'planId': serializer.toJson<String?>(planId),
      'planTitle': serializer.toJson<String?>(planTitle),
      'nonLearnable': serializer.toJson<bool>(nonLearnable),
      'outcome': serializer.toJson<String?>(outcome),
      'planCompleted': serializer.toJson<bool?>(planCompleted),
      'helpfulStepIndex': serializer.toJson<int?>(helpfulStepIndex),
      'cravingReturned': serializer.toJson<bool?>(cravingReturned),
      'contextJson': serializer.toJson<String>(contextJson),
    };
  }

  CravingLog copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? completedAt,
    Value<String?> cravingType = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> subtriggerId = const Value.absent(),
    int? intensityBefore,
    Value<int?> intensityAfter = const Value.absent(),
    Value<bool?> hungry = const Value.absent(),
    String? safetyExit,
    Value<String?> planId = const Value.absent(),
    Value<String?> planTitle = const Value.absent(),
    bool? nonLearnable,
    Value<String?> outcome = const Value.absent(),
    Value<bool?> planCompleted = const Value.absent(),
    Value<int?> helpfulStepIndex = const Value.absent(),
    Value<bool?> cravingReturned = const Value.absent(),
    String? contextJson,
  }) => CravingLog(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cravingType: cravingType.present ? cravingType.value : this.cravingType,
    category: category.present ? category.value : this.category,
    subtriggerId: subtriggerId.present ? subtriggerId.value : this.subtriggerId,
    intensityBefore: intensityBefore ?? this.intensityBefore,
    intensityAfter: intensityAfter.present
        ? intensityAfter.value
        : this.intensityAfter,
    hungry: hungry.present ? hungry.value : this.hungry,
    safetyExit: safetyExit ?? this.safetyExit,
    planId: planId.present ? planId.value : this.planId,
    planTitle: planTitle.present ? planTitle.value : this.planTitle,
    nonLearnable: nonLearnable ?? this.nonLearnable,
    outcome: outcome.present ? outcome.value : this.outcome,
    planCompleted: planCompleted.present
        ? planCompleted.value
        : this.planCompleted,
    helpfulStepIndex: helpfulStepIndex.present
        ? helpfulStepIndex.value
        : this.helpfulStepIndex,
    cravingReturned: cravingReturned.present
        ? cravingReturned.value
        : this.cravingReturned,
    contextJson: contextJson ?? this.contextJson,
  );
  CravingLog copyWithCompanion(CravingLogsCompanion data) {
    return CravingLog(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cravingType: data.cravingType.present
          ? data.cravingType.value
          : this.cravingType,
      category: data.category.present ? data.category.value : this.category,
      subtriggerId: data.subtriggerId.present
          ? data.subtriggerId.value
          : this.subtriggerId,
      intensityBefore: data.intensityBefore.present
          ? data.intensityBefore.value
          : this.intensityBefore,
      intensityAfter: data.intensityAfter.present
          ? data.intensityAfter.value
          : this.intensityAfter,
      hungry: data.hungry.present ? data.hungry.value : this.hungry,
      safetyExit: data.safetyExit.present
          ? data.safetyExit.value
          : this.safetyExit,
      planId: data.planId.present ? data.planId.value : this.planId,
      planTitle: data.planTitle.present ? data.planTitle.value : this.planTitle,
      nonLearnable: data.nonLearnable.present
          ? data.nonLearnable.value
          : this.nonLearnable,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      planCompleted: data.planCompleted.present
          ? data.planCompleted.value
          : this.planCompleted,
      helpfulStepIndex: data.helpfulStepIndex.present
          ? data.helpfulStepIndex.value
          : this.helpfulStepIndex,
      cravingReturned: data.cravingReturned.present
          ? data.cravingReturned.value
          : this.cravingReturned,
      contextJson: data.contextJson.present
          ? data.contextJson.value
          : this.contextJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CravingLog(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cravingType: $cravingType, ')
          ..write('category: $category, ')
          ..write('subtriggerId: $subtriggerId, ')
          ..write('intensityBefore: $intensityBefore, ')
          ..write('intensityAfter: $intensityAfter, ')
          ..write('hungry: $hungry, ')
          ..write('safetyExit: $safetyExit, ')
          ..write('planId: $planId, ')
          ..write('planTitle: $planTitle, ')
          ..write('nonLearnable: $nonLearnable, ')
          ..write('outcome: $outcome, ')
          ..write('planCompleted: $planCompleted, ')
          ..write('helpfulStepIndex: $helpfulStepIndex, ')
          ..write('cravingReturned: $cravingReturned, ')
          ..write('contextJson: $contextJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    completedAt,
    cravingType,
    category,
    subtriggerId,
    intensityBefore,
    intensityAfter,
    hungry,
    safetyExit,
    planId,
    planTitle,
    nonLearnable,
    outcome,
    planCompleted,
    helpfulStepIndex,
    cravingReturned,
    contextJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CravingLog &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.cravingType == this.cravingType &&
          other.category == this.category &&
          other.subtriggerId == this.subtriggerId &&
          other.intensityBefore == this.intensityBefore &&
          other.intensityAfter == this.intensityAfter &&
          other.hungry == this.hungry &&
          other.safetyExit == this.safetyExit &&
          other.planId == this.planId &&
          other.planTitle == this.planTitle &&
          other.nonLearnable == this.nonLearnable &&
          other.outcome == this.outcome &&
          other.planCompleted == this.planCompleted &&
          other.helpfulStepIndex == this.helpfulStepIndex &&
          other.cravingReturned == this.cravingReturned &&
          other.contextJson == this.contextJson);
}

class CravingLogsCompanion extends UpdateCompanion<CravingLog> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<String?> cravingType;
  final Value<String?> category;
  final Value<String?> subtriggerId;
  final Value<int> intensityBefore;
  final Value<int?> intensityAfter;
  final Value<bool?> hungry;
  final Value<String> safetyExit;
  final Value<String?> planId;
  final Value<String?> planTitle;
  final Value<bool> nonLearnable;
  final Value<String?> outcome;
  final Value<bool?> planCompleted;
  final Value<int?> helpfulStepIndex;
  final Value<bool?> cravingReturned;
  final Value<String> contextJson;
  final Value<int> rowid;
  const CravingLogsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cravingType = const Value.absent(),
    this.category = const Value.absent(),
    this.subtriggerId = const Value.absent(),
    this.intensityBefore = const Value.absent(),
    this.intensityAfter = const Value.absent(),
    this.hungry = const Value.absent(),
    this.safetyExit = const Value.absent(),
    this.planId = const Value.absent(),
    this.planTitle = const Value.absent(),
    this.nonLearnable = const Value.absent(),
    this.outcome = const Value.absent(),
    this.planCompleted = const Value.absent(),
    this.helpfulStepIndex = const Value.absent(),
    this.cravingReturned = const Value.absent(),
    this.contextJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CravingLogsCompanion.insert({
    required String id,
    required DateTime startedAt,
    required DateTime completedAt,
    this.cravingType = const Value.absent(),
    this.category = const Value.absent(),
    this.subtriggerId = const Value.absent(),
    required int intensityBefore,
    this.intensityAfter = const Value.absent(),
    this.hungry = const Value.absent(),
    required String safetyExit,
    this.planId = const Value.absent(),
    this.planTitle = const Value.absent(),
    this.nonLearnable = const Value.absent(),
    this.outcome = const Value.absent(),
    this.planCompleted = const Value.absent(),
    this.helpfulStepIndex = const Value.absent(),
    this.cravingReturned = const Value.absent(),
    this.contextJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       completedAt = Value(completedAt),
       intensityBefore = Value(intensityBefore),
       safetyExit = Value(safetyExit);
  static Insertable<CravingLog> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? cravingType,
    Expression<String>? category,
    Expression<String>? subtriggerId,
    Expression<int>? intensityBefore,
    Expression<int>? intensityAfter,
    Expression<bool>? hungry,
    Expression<String>? safetyExit,
    Expression<String>? planId,
    Expression<String>? planTitle,
    Expression<bool>? nonLearnable,
    Expression<String>? outcome,
    Expression<bool>? planCompleted,
    Expression<int>? helpfulStepIndex,
    Expression<bool>? cravingReturned,
    Expression<String>? contextJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (cravingType != null) 'craving_type': cravingType,
      if (category != null) 'category': category,
      if (subtriggerId != null) 'subtrigger_id': subtriggerId,
      if (intensityBefore != null) 'intensity_before': intensityBefore,
      if (intensityAfter != null) 'intensity_after': intensityAfter,
      if (hungry != null) 'hungry': hungry,
      if (safetyExit != null) 'safety_exit': safetyExit,
      if (planId != null) 'plan_id': planId,
      if (planTitle != null) 'plan_title': planTitle,
      if (nonLearnable != null) 'non_learnable': nonLearnable,
      if (outcome != null) 'outcome': outcome,
      if (planCompleted != null) 'plan_completed': planCompleted,
      if (helpfulStepIndex != null) 'helpful_step_index': helpfulStepIndex,
      if (cravingReturned != null) 'craving_returned': cravingReturned,
      if (contextJson != null) 'context_json': contextJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CravingLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<String?>? cravingType,
    Value<String?>? category,
    Value<String?>? subtriggerId,
    Value<int>? intensityBefore,
    Value<int?>? intensityAfter,
    Value<bool?>? hungry,
    Value<String>? safetyExit,
    Value<String?>? planId,
    Value<String?>? planTitle,
    Value<bool>? nonLearnable,
    Value<String?>? outcome,
    Value<bool?>? planCompleted,
    Value<int?>? helpfulStepIndex,
    Value<bool?>? cravingReturned,
    Value<String>? contextJson,
    Value<int>? rowid,
  }) {
    return CravingLogsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cravingType: cravingType ?? this.cravingType,
      category: category ?? this.category,
      subtriggerId: subtriggerId ?? this.subtriggerId,
      intensityBefore: intensityBefore ?? this.intensityBefore,
      intensityAfter: intensityAfter ?? this.intensityAfter,
      hungry: hungry ?? this.hungry,
      safetyExit: safetyExit ?? this.safetyExit,
      planId: planId ?? this.planId,
      planTitle: planTitle ?? this.planTitle,
      nonLearnable: nonLearnable ?? this.nonLearnable,
      outcome: outcome ?? this.outcome,
      planCompleted: planCompleted ?? this.planCompleted,
      helpfulStepIndex: helpfulStepIndex ?? this.helpfulStepIndex,
      cravingReturned: cravingReturned ?? this.cravingReturned,
      contextJson: contextJson ?? this.contextJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (cravingType.present) {
      map['craving_type'] = Variable<String>(cravingType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subtriggerId.present) {
      map['subtrigger_id'] = Variable<String>(subtriggerId.value);
    }
    if (intensityBefore.present) {
      map['intensity_before'] = Variable<int>(intensityBefore.value);
    }
    if (intensityAfter.present) {
      map['intensity_after'] = Variable<int>(intensityAfter.value);
    }
    if (hungry.present) {
      map['hungry'] = Variable<bool>(hungry.value);
    }
    if (safetyExit.present) {
      map['safety_exit'] = Variable<String>(safetyExit.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (planTitle.present) {
      map['plan_title'] = Variable<String>(planTitle.value);
    }
    if (nonLearnable.present) {
      map['non_learnable'] = Variable<bool>(nonLearnable.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (planCompleted.present) {
      map['plan_completed'] = Variable<bool>(planCompleted.value);
    }
    if (helpfulStepIndex.present) {
      map['helpful_step_index'] = Variable<int>(helpfulStepIndex.value);
    }
    if (cravingReturned.present) {
      map['craving_returned'] = Variable<bool>(cravingReturned.value);
    }
    if (contextJson.present) {
      map['context_json'] = Variable<String>(contextJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CravingLogsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cravingType: $cravingType, ')
          ..write('category: $category, ')
          ..write('subtriggerId: $subtriggerId, ')
          ..write('intensityBefore: $intensityBefore, ')
          ..write('intensityAfter: $intensityAfter, ')
          ..write('hungry: $hungry, ')
          ..write('safetyExit: $safetyExit, ')
          ..write('planId: $planId, ')
          ..write('planTitle: $planTitle, ')
          ..write('nonLearnable: $nonLearnable, ')
          ..write('outcome: $outcome, ')
          ..write('planCompleted: $planCompleted, ')
          ..write('helpfulStepIndex: $helpfulStepIndex, ')
          ..write('cravingReturned: $cravingReturned, ')
          ..write('contextJson: $contextJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearnedPriorsTable extends LearnedPriors
    with TableInfo<$LearnedPriorsTable, LearnedPrior> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnedPriorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cravingTypeMeta = const VerificationMeta(
    'cravingType',
  );
  @override
  late final GeneratedColumn<String> cravingType = GeneratedColumn<String>(
    'craving_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sampleSizeMeta = const VerificationMeta(
    'sampleSize',
  );
  @override
  late final GeneratedColumn<int> sampleSize = GeneratedColumn<int>(
    'sample_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    cravingType,
    category,
    score,
    sampleSize,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learned_priors';
  @override
  VerificationContext validateIntegrity(
    Insertable<LearnedPrior> instance, {
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
    if (data.containsKey('craving_type')) {
      context.handle(
        _cravingTypeMeta,
        cravingType.isAcceptableOrUnknown(
          data['craving_type']!,
          _cravingTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cravingTypeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('sample_size')) {
      context.handle(
        _sampleSizeMeta,
        sampleSize.isAcceptableOrUnknown(data['sample_size']!, _sampleSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sampleSizeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LearnedPrior map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnedPrior(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      cravingType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}craving_type'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      sampleSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_size'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LearnedPriorsTable createAlias(String alias) {
    return $LearnedPriorsTable(attachedDatabase, alias);
  }
}

class LearnedPrior extends DataClass implements Insertable<LearnedPrior> {
  final String key;
  final String cravingType;
  final String category;
  final double score;
  final int sampleSize;
  final DateTime updatedAt;
  const LearnedPrior({
    required this.key,
    required this.cravingType,
    required this.category,
    required this.score,
    required this.sampleSize,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['craving_type'] = Variable<String>(cravingType);
    map['category'] = Variable<String>(category);
    map['score'] = Variable<double>(score);
    map['sample_size'] = Variable<int>(sampleSize);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LearnedPriorsCompanion toCompanion(bool nullToAbsent) {
    return LearnedPriorsCompanion(
      key: Value(key),
      cravingType: Value(cravingType),
      category: Value(category),
      score: Value(score),
      sampleSize: Value(sampleSize),
      updatedAt: Value(updatedAt),
    );
  }

  factory LearnedPrior.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedPrior(
      key: serializer.fromJson<String>(json['key']),
      cravingType: serializer.fromJson<String>(json['cravingType']),
      category: serializer.fromJson<String>(json['category']),
      score: serializer.fromJson<double>(json['score']),
      sampleSize: serializer.fromJson<int>(json['sampleSize']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'cravingType': serializer.toJson<String>(cravingType),
      'category': serializer.toJson<String>(category),
      'score': serializer.toJson<double>(score),
      'sampleSize': serializer.toJson<int>(sampleSize),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LearnedPrior copyWith({
    String? key,
    String? cravingType,
    String? category,
    double? score,
    int? sampleSize,
    DateTime? updatedAt,
  }) => LearnedPrior(
    key: key ?? this.key,
    cravingType: cravingType ?? this.cravingType,
    category: category ?? this.category,
    score: score ?? this.score,
    sampleSize: sampleSize ?? this.sampleSize,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LearnedPrior copyWithCompanion(LearnedPriorsCompanion data) {
    return LearnedPrior(
      key: data.key.present ? data.key.value : this.key,
      cravingType: data.cravingType.present
          ? data.cravingType.value
          : this.cravingType,
      category: data.category.present ? data.category.value : this.category,
      score: data.score.present ? data.score.value : this.score,
      sampleSize: data.sampleSize.present
          ? data.sampleSize.value
          : this.sampleSize,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedPrior(')
          ..write('key: $key, ')
          ..write('cravingType: $cravingType, ')
          ..write('category: $category, ')
          ..write('score: $score, ')
          ..write('sampleSize: $sampleSize, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, cravingType, category, score, sampleSize, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedPrior &&
          other.key == this.key &&
          other.cravingType == this.cravingType &&
          other.category == this.category &&
          other.score == this.score &&
          other.sampleSize == this.sampleSize &&
          other.updatedAt == this.updatedAt);
}

class LearnedPriorsCompanion extends UpdateCompanion<LearnedPrior> {
  final Value<String> key;
  final Value<String> cravingType;
  final Value<String> category;
  final Value<double> score;
  final Value<int> sampleSize;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LearnedPriorsCompanion({
    this.key = const Value.absent(),
    this.cravingType = const Value.absent(),
    this.category = const Value.absent(),
    this.score = const Value.absent(),
    this.sampleSize = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearnedPriorsCompanion.insert({
    required String key,
    required String cravingType,
    required String category,
    required double score,
    required int sampleSize,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       cravingType = Value(cravingType),
       category = Value(category),
       score = Value(score),
       sampleSize = Value(sampleSize),
       updatedAt = Value(updatedAt);
  static Insertable<LearnedPrior> custom({
    Expression<String>? key,
    Expression<String>? cravingType,
    Expression<String>? category,
    Expression<double>? score,
    Expression<int>? sampleSize,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (cravingType != null) 'craving_type': cravingType,
      if (category != null) 'category': category,
      if (score != null) 'score': score,
      if (sampleSize != null) 'sample_size': sampleSize,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearnedPriorsCompanion copyWith({
    Value<String>? key,
    Value<String>? cravingType,
    Value<String>? category,
    Value<double>? score,
    Value<int>? sampleSize,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LearnedPriorsCompanion(
      key: key ?? this.key,
      cravingType: cravingType ?? this.cravingType,
      category: category ?? this.category,
      score: score ?? this.score,
      sampleSize: sampleSize ?? this.sampleSize,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (cravingType.present) {
      map['craving_type'] = Variable<String>(cravingType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (sampleSize.present) {
      map['sample_size'] = Variable<int>(sampleSize.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnedPriorsCompanion(')
          ..write('key: $key, ')
          ..write('cravingType: $cravingType, ')
          ..write('category: $category, ')
          ..write('score: $score, ')
          ..write('sampleSize: $sampleSize, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterventionStatsTable extends InterventionStats
    with TableInfo<$InterventionStatsTable, InterventionStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterventionStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _interventionIdMeta = const VerificationMeta(
    'interventionId',
  );
  @override
  late final GeneratedColumn<String> interventionId = GeneratedColumn<String>(
    'intervention_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usesMeta = const VerificationMeta('uses');
  @override
  late final GeneratedColumn<int> uses = GeneratedColumn<int>(
    'uses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _helpfulMeta = const VerificationMeta(
    'helpful',
  );
  @override
  late final GeneratedColumn<int> helpful = GeneratedColumn<int>(
    'helpful',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    interventionId,
    uses,
    helpful,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intervention_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterventionStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('intervention_id')) {
      context.handle(
        _interventionIdMeta,
        interventionId.isAcceptableOrUnknown(
          data['intervention_id']!,
          _interventionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interventionIdMeta);
    }
    if (data.containsKey('uses')) {
      context.handle(
        _usesMeta,
        uses.isAcceptableOrUnknown(data['uses']!, _usesMeta),
      );
    }
    if (data.containsKey('helpful')) {
      context.handle(
        _helpfulMeta,
        helpful.isAcceptableOrUnknown(data['helpful']!, _helpfulMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {interventionId};
  @override
  InterventionStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterventionStat(
      interventionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intervention_id'],
      )!,
      uses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uses'],
      )!,
      helpful: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}helpful'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $InterventionStatsTable createAlias(String alias) {
    return $InterventionStatsTable(attachedDatabase, alias);
  }
}

class InterventionStat extends DataClass
    implements Insertable<InterventionStat> {
  final String interventionId;
  final int uses;
  final int helpful;
  final DateTime lastUsedAt;
  const InterventionStat({
    required this.interventionId,
    required this.uses,
    required this.helpful,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['intervention_id'] = Variable<String>(interventionId);
    map['uses'] = Variable<int>(uses);
    map['helpful'] = Variable<int>(helpful);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  InterventionStatsCompanion toCompanion(bool nullToAbsent) {
    return InterventionStatsCompanion(
      interventionId: Value(interventionId),
      uses: Value(uses),
      helpful: Value(helpful),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory InterventionStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterventionStat(
      interventionId: serializer.fromJson<String>(json['interventionId']),
      uses: serializer.fromJson<int>(json['uses']),
      helpful: serializer.fromJson<int>(json['helpful']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'interventionId': serializer.toJson<String>(interventionId),
      'uses': serializer.toJson<int>(uses),
      'helpful': serializer.toJson<int>(helpful),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  InterventionStat copyWith({
    String? interventionId,
    int? uses,
    int? helpful,
    DateTime? lastUsedAt,
  }) => InterventionStat(
    interventionId: interventionId ?? this.interventionId,
    uses: uses ?? this.uses,
    helpful: helpful ?? this.helpful,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  InterventionStat copyWithCompanion(InterventionStatsCompanion data) {
    return InterventionStat(
      interventionId: data.interventionId.present
          ? data.interventionId.value
          : this.interventionId,
      uses: data.uses.present ? data.uses.value : this.uses,
      helpful: data.helpful.present ? data.helpful.value : this.helpful,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterventionStat(')
          ..write('interventionId: $interventionId, ')
          ..write('uses: $uses, ')
          ..write('helpful: $helpful, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(interventionId, uses, helpful, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterventionStat &&
          other.interventionId == this.interventionId &&
          other.uses == this.uses &&
          other.helpful == this.helpful &&
          other.lastUsedAt == this.lastUsedAt);
}

class InterventionStatsCompanion extends UpdateCompanion<InterventionStat> {
  final Value<String> interventionId;
  final Value<int> uses;
  final Value<int> helpful;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const InterventionStatsCompanion({
    this.interventionId = const Value.absent(),
    this.uses = const Value.absent(),
    this.helpful = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterventionStatsCompanion.insert({
    required String interventionId,
    this.uses = const Value.absent(),
    this.helpful = const Value.absent(),
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : interventionId = Value(interventionId),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<InterventionStat> custom({
    Expression<String>? interventionId,
    Expression<int>? uses,
    Expression<int>? helpful,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (interventionId != null) 'intervention_id': interventionId,
      if (uses != null) 'uses': uses,
      if (helpful != null) 'helpful': helpful,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterventionStatsCompanion copyWith({
    Value<String>? interventionId,
    Value<int>? uses,
    Value<int>? helpful,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return InterventionStatsCompanion(
      interventionId: interventionId ?? this.interventionId,
      uses: uses ?? this.uses,
      helpful: helpful ?? this.helpful,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (interventionId.present) {
      map['intervention_id'] = Variable<String>(interventionId.value);
    }
    if (uses.present) {
      map['uses'] = Variable<int>(uses.value);
    }
    if (helpful.present) {
      map['helpful'] = Variable<int>(helpful.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterventionStatsCompanion(')
          ..write('interventionId: $interventionId, ')
          ..write('uses: $uses, ')
          ..write('helpful: $helpful, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionEntriesTable extends ReflectionEntries
    with TableInfo<$ReflectionEntriesTable, ReflectionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptIdMeta = const VerificationMeta(
    'promptId',
  );
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, promptId, answer];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflection_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReflectionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(
        _promptIdMeta,
        promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReflectionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      promptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_id'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
    );
  }

  @override
  $ReflectionEntriesTable createAlias(String alias) {
    return $ReflectionEntriesTable(attachedDatabase, alias);
  }
}

class ReflectionEntry extends DataClass implements Insertable<ReflectionEntry> {
  final String id;
  final DateTime createdAt;
  final String promptId;
  final String answer;
  const ReflectionEntry({
    required this.id,
    required this.createdAt,
    required this.promptId,
    required this.answer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['prompt_id'] = Variable<String>(promptId);
    map['answer'] = Variable<String>(answer);
    return map;
  }

  ReflectionEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReflectionEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      promptId: Value(promptId),
      answer: Value(answer),
    );
  }

  factory ReflectionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionEntry(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      promptId: serializer.fromJson<String>(json['promptId']),
      answer: serializer.fromJson<String>(json['answer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'promptId': serializer.toJson<String>(promptId),
      'answer': serializer.toJson<String>(answer),
    };
  }

  ReflectionEntry copyWith({
    String? id,
    DateTime? createdAt,
    String? promptId,
    String? answer,
  }) => ReflectionEntry(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    promptId: promptId ?? this.promptId,
    answer: answer ?? this.answer,
  );
  ReflectionEntry copyWithCompanion(ReflectionEntriesCompanion data) {
    return ReflectionEntry(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      answer: data.answer.present ? data.answer.value : this.answer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionEntry(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('promptId: $promptId, ')
          ..write('answer: $answer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, promptId, answer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionEntry &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.promptId == this.promptId &&
          other.answer == this.answer);
}

class ReflectionEntriesCompanion extends UpdateCompanion<ReflectionEntry> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> promptId;
  final Value<String> answer;
  final Value<int> rowid;
  const ReflectionEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.promptId = const Value.absent(),
    this.answer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionEntriesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String promptId,
    required String answer,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       promptId = Value(promptId),
       answer = Value(answer);
  static Insertable<ReflectionEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? promptId,
    Expression<String>? answer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (promptId != null) 'prompt_id': promptId,
      if (answer != null) 'answer': answer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? promptId,
    Value<String>? answer,
    Value<int>? rowid,
  }) {
    return ReflectionEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      promptId: promptId ?? this.promptId,
      answer: answer ?? this.answer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('promptId: $promptId, ')
          ..write('answer: $answer, ')
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

class $AvatarProfilesTable extends AvatarProfiles
    with TableInfo<$AvatarProfilesTable, AvatarProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AvatarProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'avatar_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AvatarProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AvatarProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvatarProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AvatarProfilesTable createAlias(String alias) {
    return $AvatarProfilesTable(attachedDatabase, alias);
  }
}

class AvatarProfile extends DataClass implements Insertable<AvatarProfile> {
  final int id;
  final String payload;
  final DateTime updatedAt;
  const AvatarProfile({
    required this.id,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AvatarProfilesCompanion toCompanion(bool nullToAbsent) {
    return AvatarProfilesCompanion(
      id: Value(id),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory AvatarProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvatarProfile(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AvatarProfile copyWith({int? id, String? payload, DateTime? updatedAt}) =>
      AvatarProfile(
        id: id ?? this.id,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AvatarProfile copyWithCompanion(AvatarProfilesCompanion data) {
    return AvatarProfile(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AvatarProfile(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvatarProfile &&
          other.id == this.id &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class AvatarProfilesCompanion extends UpdateCompanion<AvatarProfile> {
  final Value<int> id;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  const AvatarProfilesCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AvatarProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
    required DateTime updatedAt,
  }) : payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<AvatarProfile> custom({
    Expression<int>? id,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AvatarProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
  }) {
    return AvatarProfilesCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvatarProfilesCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OwnedCosmeticsTable extends OwnedCosmetics
    with TableInfo<$OwnedCosmeticsTable, OwnedCosmetic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnedCosmeticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, acquiredAt, source];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owned_cosmetics';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnedCosmetic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_acquiredAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  OwnedCosmetic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnedCosmetic(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $OwnedCosmeticsTable createAlias(String alias) {
    return $OwnedCosmeticsTable(attachedDatabase, alias);
  }
}

class OwnedCosmetic extends DataClass implements Insertable<OwnedCosmetic> {
  final String itemId;
  final DateTime acquiredAt;
  final String source;
  const OwnedCosmetic({
    required this.itemId,
    required this.acquiredAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['acquired_at'] = Variable<DateTime>(acquiredAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  OwnedCosmeticsCompanion toCompanion(bool nullToAbsent) {
    return OwnedCosmeticsCompanion(
      itemId: Value(itemId),
      acquiredAt: Value(acquiredAt),
      source: Value(source),
    );
  }

  factory OwnedCosmetic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnedCosmetic(
      itemId: serializer.fromJson<String>(json['itemId']),
      acquiredAt: serializer.fromJson<DateTime>(json['acquiredAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'acquiredAt': serializer.toJson<DateTime>(acquiredAt),
      'source': serializer.toJson<String>(source),
    };
  }

  OwnedCosmetic copyWith({
    String? itemId,
    DateTime? acquiredAt,
    String? source,
  }) => OwnedCosmetic(
    itemId: itemId ?? this.itemId,
    acquiredAt: acquiredAt ?? this.acquiredAt,
    source: source ?? this.source,
  );
  OwnedCosmetic copyWithCompanion(OwnedCosmeticsCompanion data) {
    return OwnedCosmetic(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnedCosmetic(')
          ..write('itemId: $itemId, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, acquiredAt, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnedCosmetic &&
          other.itemId == this.itemId &&
          other.acquiredAt == this.acquiredAt &&
          other.source == this.source);
}

class OwnedCosmeticsCompanion extends UpdateCompanion<OwnedCosmetic> {
  final Value<String> itemId;
  final Value<DateTime> acquiredAt;
  final Value<String> source;
  final Value<int> rowid;
  const OwnedCosmeticsCompanion({
    this.itemId = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnedCosmeticsCompanion.insert({
    required String itemId,
    required DateTime acquiredAt,
    required String source,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       acquiredAt = Value(acquiredAt),
       source = Value(source);
  static Insertable<OwnedCosmetic> custom({
    Expression<String>? itemId,
    Expression<DateTime>? acquiredAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnedCosmeticsCompanion copyWith({
    Value<String>? itemId,
    Value<DateTime>? acquiredAt,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return OwnedCosmeticsCompanion(
      itemId: itemId ?? this.itemId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnedCosmeticsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitPresetsTable extends OutfitPresets
    with TableInfo<$OutfitPresetsTable, OutfitPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutfitPreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutfitPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitPreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutfitPresetsTable createAlias(String alias) {
    return $OutfitPresetsTable(attachedDatabase, alias);
  }
}

class OutfitPreset extends DataClass implements Insertable<OutfitPreset> {
  final String id;
  final String name;
  final String payload;
  final DateTime createdAt;
  const OutfitPreset({
    required this.id,
    required this.name,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutfitPresetsCompanion toCompanion(bool nullToAbsent) {
    return OutfitPresetsCompanion(
      id: Value(id),
      name: Value(name),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory OutfitPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitPreset(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutfitPreset copyWith({
    String? id,
    String? name,
    String? payload,
    DateTime? createdAt,
  }) => OutfitPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  OutfitPreset copyWithCompanion(OutfitPresetsCompanion data) {
    return OutfitPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutfitPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class OutfitPresetsCompanion extends UpdateCompanion<OutfitPreset> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OutfitPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitPresetsCompanion.insert({
    required String id,
    required String name,
    required String payload,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutfitPreset> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitPresetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OutfitPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoinLedgerTable extends CoinLedger
    with TableInfo<$CoinLedgerTable, CoinLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoinLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedSessionIdMeta = const VerificationMeta(
    'relatedSessionId',
  );
  @override
  late final GeneratedColumn<String> relatedSessionId = GeneratedColumn<String>(
    'related_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    createdAt,
    amount,
    reason,
    relatedSessionId,
    sourceType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coin_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoinLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('related_session_id')) {
      context.handle(
        _relatedSessionIdMeta,
        relatedSessionId.isAcceptableOrUnknown(
          data['related_session_id']!,
          _relatedSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  CoinLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoinLedgerData(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      relatedSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_session_id'],
      ),
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
    );
  }

  @override
  $CoinLedgerTable createAlias(String alias) {
    return $CoinLedgerTable(attachedDatabase, alias);
  }
}

class CoinLedgerData extends DataClass implements Insertable<CoinLedgerData> {
  final String eventId;
  final DateTime createdAt;
  final int amount;
  final String reason;
  final String? relatedSessionId;
  final String sourceType;
  const CoinLedgerData({
    required this.eventId,
    required this.createdAt,
    required this.amount,
    required this.reason,
    this.relatedSessionId,
    required this.sourceType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || relatedSessionId != null) {
      map['related_session_id'] = Variable<String>(relatedSessionId);
    }
    map['source_type'] = Variable<String>(sourceType);
    return map;
  }

  CoinLedgerCompanion toCompanion(bool nullToAbsent) {
    return CoinLedgerCompanion(
      eventId: Value(eventId),
      createdAt: Value(createdAt),
      amount: Value(amount),
      reason: Value(reason),
      relatedSessionId: relatedSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedSessionId),
      sourceType: Value(sourceType),
    );
  }

  factory CoinLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoinLedgerData(
      eventId: serializer.fromJson<String>(json['eventId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      relatedSessionId: serializer.fromJson<String?>(json['relatedSessionId']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'relatedSessionId': serializer.toJson<String?>(relatedSessionId),
      'sourceType': serializer.toJson<String>(sourceType),
    };
  }

  CoinLedgerData copyWith({
    String? eventId,
    DateTime? createdAt,
    int? amount,
    String? reason,
    Value<String?> relatedSessionId = const Value.absent(),
    String? sourceType,
  }) => CoinLedgerData(
    eventId: eventId ?? this.eventId,
    createdAt: createdAt ?? this.createdAt,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    relatedSessionId: relatedSessionId.present
        ? relatedSessionId.value
        : this.relatedSessionId,
    sourceType: sourceType ?? this.sourceType,
  );
  CoinLedgerData copyWithCompanion(CoinLedgerCompanion data) {
    return CoinLedgerData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      relatedSessionId: data.relatedSessionId.present
          ? data.relatedSessionId.value
          : this.relatedSessionId,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoinLedgerData(')
          ..write('eventId: $eventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('relatedSessionId: $relatedSessionId, ')
          ..write('sourceType: $sourceType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    createdAt,
    amount,
    reason,
    relatedSessionId,
    sourceType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoinLedgerData &&
          other.eventId == this.eventId &&
          other.createdAt == this.createdAt &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.relatedSessionId == this.relatedSessionId &&
          other.sourceType == this.sourceType);
}

class CoinLedgerCompanion extends UpdateCompanion<CoinLedgerData> {
  final Value<String> eventId;
  final Value<DateTime> createdAt;
  final Value<int> amount;
  final Value<String> reason;
  final Value<String?> relatedSessionId;
  final Value<String> sourceType;
  final Value<int> rowid;
  const CoinLedgerCompanion({
    this.eventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.relatedSessionId = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoinLedgerCompanion.insert({
    required String eventId,
    required DateTime createdAt,
    required int amount,
    required String reason,
    this.relatedSessionId = const Value.absent(),
    required String sourceType,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       createdAt = Value(createdAt),
       amount = Value(amount),
       reason = Value(reason),
       sourceType = Value(sourceType);
  static Insertable<CoinLedgerData> custom({
    Expression<String>? eventId,
    Expression<DateTime>? createdAt,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? relatedSessionId,
    Expression<String>? sourceType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (createdAt != null) 'created_at': createdAt,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (relatedSessionId != null) 'related_session_id': relatedSessionId,
      if (sourceType != null) 'source_type': sourceType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoinLedgerCompanion copyWith({
    Value<String>? eventId,
    Value<DateTime>? createdAt,
    Value<int>? amount,
    Value<String>? reason,
    Value<String?>? relatedSessionId,
    Value<String>? sourceType,
    Value<int>? rowid,
  }) {
    return CoinLedgerCompanion(
      eventId: eventId ?? this.eventId,
      createdAt: createdAt ?? this.createdAt,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      relatedSessionId: relatedSessionId ?? this.relatedSessionId,
      sourceType: sourceType ?? this.sourceType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (relatedSessionId.present) {
      map['related_session_id'] = Variable<String>(relatedSessionId.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoinLedgerCompanion(')
          ..write('eventId: $eventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('relatedSessionId: $relatedSessionId, ')
          ..write('sourceType: $sourceType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreakStatesTable extends StreakStates
    with TableInfo<$StreakStatesTable, StreakState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestStreakMeta = const VerificationMeta(
    'bestStreak',
  );
  @override
  late final GeneratedColumn<int> bestStreak = GeneratedColumn<int>(
    'best_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDayMeta = const VerificationMeta(
    'lastActiveDay',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDay =
      GeneratedColumn<DateTime>(
        'last_active_day',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _graceAvailableMeta = const VerificationMeta(
    'graceAvailable',
  );
  @override
  late final GeneratedColumn<bool> graceAvailable = GeneratedColumn<bool>(
    'grace_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("grace_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStreak,
    bestStreak,
    lastActiveDay,
    graceAvailable,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('best_streak')) {
      context.handle(
        _bestStreakMeta,
        bestStreak.isAcceptableOrUnknown(data['best_streak']!, _bestStreakMeta),
      );
    }
    if (data.containsKey('last_active_day')) {
      context.handle(
        _lastActiveDayMeta,
        lastActiveDay.isAcceptableOrUnknown(
          data['last_active_day']!,
          _lastActiveDayMeta,
        ),
      );
    }
    if (data.containsKey('grace_available')) {
      context.handle(
        _graceAvailableMeta,
        graceAvailable.isAcceptableOrUnknown(
          data['grace_available']!,
          _graceAvailableMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      bestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_streak'],
      )!,
      lastActiveDay: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_day'],
      ),
      graceAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}grace_available'],
      )!,
    );
  }

  @override
  $StreakStatesTable createAlias(String alias) {
    return $StreakStatesTable(attachedDatabase, alias);
  }
}

class StreakState extends DataClass implements Insertable<StreakState> {
  final int id;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastActiveDay;
  final bool graceAvailable;
  const StreakState({
    required this.id,
    required this.currentStreak,
    required this.bestStreak,
    this.lastActiveDay,
    required this.graceAvailable,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak'] = Variable<int>(currentStreak);
    map['best_streak'] = Variable<int>(bestStreak);
    if (!nullToAbsent || lastActiveDay != null) {
      map['last_active_day'] = Variable<DateTime>(lastActiveDay);
    }
    map['grace_available'] = Variable<bool>(graceAvailable);
    return map;
  }

  StreakStatesCompanion toCompanion(bool nullToAbsent) {
    return StreakStatesCompanion(
      id: Value(id),
      currentStreak: Value(currentStreak),
      bestStreak: Value(bestStreak),
      lastActiveDay: lastActiveDay == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDay),
      graceAvailable: Value(graceAvailable),
    );
  }

  factory StreakState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakState(
      id: serializer.fromJson<int>(json['id']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      bestStreak: serializer.fromJson<int>(json['bestStreak']),
      lastActiveDay: serializer.fromJson<DateTime?>(json['lastActiveDay']),
      graceAvailable: serializer.fromJson<bool>(json['graceAvailable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'bestStreak': serializer.toJson<int>(bestStreak),
      'lastActiveDay': serializer.toJson<DateTime?>(lastActiveDay),
      'graceAvailable': serializer.toJson<bool>(graceAvailable),
    };
  }

  StreakState copyWith({
    int? id,
    int? currentStreak,
    int? bestStreak,
    Value<DateTime?> lastActiveDay = const Value.absent(),
    bool? graceAvailable,
  }) => StreakState(
    id: id ?? this.id,
    currentStreak: currentStreak ?? this.currentStreak,
    bestStreak: bestStreak ?? this.bestStreak,
    lastActiveDay: lastActiveDay.present
        ? lastActiveDay.value
        : this.lastActiveDay,
    graceAvailable: graceAvailable ?? this.graceAvailable,
  );
  StreakState copyWithCompanion(StreakStatesCompanion data) {
    return StreakState(
      id: data.id.present ? data.id.value : this.id,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      bestStreak: data.bestStreak.present
          ? data.bestStreak.value
          : this.bestStreak,
      lastActiveDay: data.lastActiveDay.present
          ? data.lastActiveDay.value
          : this.lastActiveDay,
      graceAvailable: data.graceAvailable.present
          ? data.graceAvailable.value
          : this.graceAvailable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakState(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastActiveDay: $lastActiveDay, ')
          ..write('graceAvailable: $graceAvailable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, currentStreak, bestStreak, lastActiveDay, graceAvailable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakState &&
          other.id == this.id &&
          other.currentStreak == this.currentStreak &&
          other.bestStreak == this.bestStreak &&
          other.lastActiveDay == this.lastActiveDay &&
          other.graceAvailable == this.graceAvailable);
}

class StreakStatesCompanion extends UpdateCompanion<StreakState> {
  final Value<int> id;
  final Value<int> currentStreak;
  final Value<int> bestStreak;
  final Value<DateTime?> lastActiveDay;
  final Value<bool> graceAvailable;
  const StreakStatesCompanion({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastActiveDay = const Value.absent(),
    this.graceAvailable = const Value.absent(),
  });
  StreakStatesCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.bestStreak = const Value.absent(),
    this.lastActiveDay = const Value.absent(),
    this.graceAvailable = const Value.absent(),
  });
  static Insertable<StreakState> custom({
    Expression<int>? id,
    Expression<int>? currentStreak,
    Expression<int>? bestStreak,
    Expression<DateTime>? lastActiveDay,
    Expression<bool>? graceAvailable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (bestStreak != null) 'best_streak': bestStreak,
      if (lastActiveDay != null) 'last_active_day': lastActiveDay,
      if (graceAvailable != null) 'grace_available': graceAvailable,
    });
  }

  StreakStatesCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStreak,
    Value<int>? bestStreak,
    Value<DateTime?>? lastActiveDay,
    Value<bool>? graceAvailable,
  }) {
    return StreakStatesCompanion(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      graceAvailable: graceAvailable ?? this.graceAvailable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (bestStreak.present) {
      map['best_streak'] = Variable<int>(bestStreak.value);
    }
    if (lastActiveDay.present) {
      map['last_active_day'] = Variable<DateTime>(lastActiveDay.value);
    }
    if (graceAvailable.present) {
      map['grace_available'] = Variable<bool>(graceAvailable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakStatesCompanion(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('bestStreak: $bestStreak, ')
          ..write('lastActiveDay: $lastActiveDay, ')
          ..write('graceAvailable: $graceAvailable')
          ..write(')'))
        .toString();
  }
}

class $MilestoneUnlocksTable extends MilestoneUnlocks
    with TableInfo<$MilestoneUnlocksTable, MilestoneUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestoneUnlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _milestoneIdMeta = const VerificationMeta(
    'milestoneId',
  );
  @override
  late final GeneratedColumn<String> milestoneId = GeneratedColumn<String>(
    'milestone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [milestoneId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestone_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MilestoneUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('milestone_id')) {
      context.handle(
        _milestoneIdMeta,
        milestoneId.isAcceptableOrUnknown(
          data['milestone_id']!,
          _milestoneIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_milestoneIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {milestoneId};
  @override
  MilestoneUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilestoneUnlock(
      milestoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestone_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $MilestoneUnlocksTable createAlias(String alias) {
    return $MilestoneUnlocksTable(attachedDatabase, alias);
  }
}

class MilestoneUnlock extends DataClass implements Insertable<MilestoneUnlock> {
  final String milestoneId;
  final DateTime unlockedAt;
  const MilestoneUnlock({required this.milestoneId, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['milestone_id'] = Variable<String>(milestoneId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  MilestoneUnlocksCompanion toCompanion(bool nullToAbsent) {
    return MilestoneUnlocksCompanion(
      milestoneId: Value(milestoneId),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory MilestoneUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilestoneUnlock(
      milestoneId: serializer.fromJson<String>(json['milestoneId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'milestoneId': serializer.toJson<String>(milestoneId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  MilestoneUnlock copyWith({String? milestoneId, DateTime? unlockedAt}) =>
      MilestoneUnlock(
        milestoneId: milestoneId ?? this.milestoneId,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  MilestoneUnlock copyWithCompanion(MilestoneUnlocksCompanion data) {
    return MilestoneUnlock(
      milestoneId: data.milestoneId.present
          ? data.milestoneId.value
          : this.milestoneId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneUnlock(')
          ..write('milestoneId: $milestoneId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(milestoneId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilestoneUnlock &&
          other.milestoneId == this.milestoneId &&
          other.unlockedAt == this.unlockedAt);
}

class MilestoneUnlocksCompanion extends UpdateCompanion<MilestoneUnlock> {
  final Value<String> milestoneId;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const MilestoneUnlocksCompanion({
    this.milestoneId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestoneUnlocksCompanion.insert({
    required String milestoneId,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : milestoneId = Value(milestoneId),
       unlockedAt = Value(unlockedAt);
  static Insertable<MilestoneUnlock> custom({
    Expression<String>? milestoneId,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (milestoneId != null) 'milestone_id': milestoneId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestoneUnlocksCompanion copyWith({
    Value<String>? milestoneId,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return MilestoneUnlocksCompanion(
      milestoneId: milestoneId ?? this.milestoneId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (milestoneId.present) {
      map['milestone_id'] = Variable<String>(milestoneId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneUnlocksCompanion(')
          ..write('milestoneId: $milestoneId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cravingSessionIdMeta = const VerificationMeta(
    'cravingSessionId',
  );
  @override
  late final GeneratedColumn<String> cravingSessionId = GeneratedColumn<String>(
    'craving_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtriggerIdMeta = const VerificationMeta(
    'subtriggerId',
  );
  @override
  late final GeneratedColumn<String> subtriggerId = GeneratedColumn<String>(
    'subtrigger_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intensityBeforeMeta = const VerificationMeta(
    'intensityBefore',
  );
  @override
  late final GeneratedColumn<int> intensityBefore = GeneratedColumn<int>(
    'intensity_before',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intensityAfterMeta = const VerificationMeta(
    'intensityAfter',
  );
  @override
  late final GeneratedColumn<int> intensityAfter = GeneratedColumn<int>(
    'intensity_after',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coinsAwardedMeta = const VerificationMeta(
    'coinsAwarded',
  );
  @override
  late final GeneratedColumn<int> coinsAwarded = GeneratedColumn<int>(
    'coins_awarded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _helpfulnessMeta = const VerificationMeta(
    'helpfulness',
  );
  @override
  late final GeneratedColumn<String> helpfulness = GeneratedColumn<String>(
    'helpfulness',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cravingReturnedMeta = const VerificationMeta(
    'cravingReturned',
  );
  @override
  late final GeneratedColumn<bool> cravingReturned = GeneratedColumn<bool>(
    'craving_returned',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("craving_returned" IN (0, 1))',
    ),
  );
  static const VerificationMeta _gameMeta = const VerificationMeta('game');
  @override
  late final GeneratedColumn<String> game = GeneratedColumn<String>(
    'game',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('signal_shift'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    completedAt,
    cravingSessionId,
    source,
    category,
    subtriggerId,
    intensityBefore,
    intensityAfter,
    durationSeconds,
    mode,
    score,
    coinsAwarded,
    completed,
    helpfulness,
    cravingReturned,
    game,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('craving_session_id')) {
      context.handle(
        _cravingSessionIdMeta,
        cravingSessionId.isAcceptableOrUnknown(
          data['craving_session_id']!,
          _cravingSessionIdMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('subtrigger_id')) {
      context.handle(
        _subtriggerIdMeta,
        subtriggerId.isAcceptableOrUnknown(
          data['subtrigger_id']!,
          _subtriggerIdMeta,
        ),
      );
    }
    if (data.containsKey('intensity_before')) {
      context.handle(
        _intensityBeforeMeta,
        intensityBefore.isAcceptableOrUnknown(
          data['intensity_before']!,
          _intensityBeforeMeta,
        ),
      );
    }
    if (data.containsKey('intensity_after')) {
      context.handle(
        _intensityAfterMeta,
        intensityAfter.isAcceptableOrUnknown(
          data['intensity_after']!,
          _intensityAfterMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('coins_awarded')) {
      context.handle(
        _coinsAwardedMeta,
        coinsAwarded.isAcceptableOrUnknown(
          data['coins_awarded']!,
          _coinsAwardedMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('helpfulness')) {
      context.handle(
        _helpfulnessMeta,
        helpfulness.isAcceptableOrUnknown(
          data['helpfulness']!,
          _helpfulnessMeta,
        ),
      );
    }
    if (data.containsKey('craving_returned')) {
      context.handle(
        _cravingReturnedMeta,
        cravingReturned.isAcceptableOrUnknown(
          data['craving_returned']!,
          _cravingReturnedMeta,
        ),
      );
    }
    if (data.containsKey('game')) {
      context.handle(
        _gameMeta,
        game.isAcceptableOrUnknown(data['game']!, _gameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      cravingSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}craving_session_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subtriggerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtrigger_id'],
      ),
      intensityBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity_before'],
      ),
      intensityAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity_after'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      coinsAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coins_awarded'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      helpfulness: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}helpfulness'],
      ),
      cravingReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}craving_returned'],
      ),
      game: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game'],
      )!,
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSession extends DataClass implements Insertable<GameSession> {
  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final String? cravingSessionId;
  final String source;
  final String? category;
  final String? subtriggerId;
  final int? intensityBefore;
  final int? intensityAfter;
  final int durationSeconds;
  final String mode;
  final int score;
  final int coinsAwarded;
  final bool completed;
  final String? helpfulness;
  final bool? cravingReturned;

  /// Which game was played. Everything recorded before a second game existed
  /// was Signal Shift, so this defaults rather than being nullable.
  final String game;
  const GameSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    this.cravingSessionId,
    required this.source,
    this.category,
    this.subtriggerId,
    this.intensityBefore,
    this.intensityAfter,
    required this.durationSeconds,
    required this.mode,
    required this.score,
    required this.coinsAwarded,
    required this.completed,
    this.helpfulness,
    this.cravingReturned,
    required this.game,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || cravingSessionId != null) {
      map['craving_session_id'] = Variable<String>(cravingSessionId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || subtriggerId != null) {
      map['subtrigger_id'] = Variable<String>(subtriggerId);
    }
    if (!nullToAbsent || intensityBefore != null) {
      map['intensity_before'] = Variable<int>(intensityBefore);
    }
    if (!nullToAbsent || intensityAfter != null) {
      map['intensity_after'] = Variable<int>(intensityAfter);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['mode'] = Variable<String>(mode);
    map['score'] = Variable<int>(score);
    map['coins_awarded'] = Variable<int>(coinsAwarded);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || helpfulness != null) {
      map['helpfulness'] = Variable<String>(helpfulness);
    }
    if (!nullToAbsent || cravingReturned != null) {
      map['craving_returned'] = Variable<bool>(cravingReturned);
    }
    map['game'] = Variable<String>(game);
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      cravingSessionId: cravingSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(cravingSessionId),
      source: Value(source),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      subtriggerId: subtriggerId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtriggerId),
      intensityBefore: intensityBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(intensityBefore),
      intensityAfter: intensityAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(intensityAfter),
      durationSeconds: Value(durationSeconds),
      mode: Value(mode),
      score: Value(score),
      coinsAwarded: Value(coinsAwarded),
      completed: Value(completed),
      helpfulness: helpfulness == null && nullToAbsent
          ? const Value.absent()
          : Value(helpfulness),
      cravingReturned: cravingReturned == null && nullToAbsent
          ? const Value.absent()
          : Value(cravingReturned),
      game: Value(game),
    );
  }

  factory GameSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      cravingSessionId: serializer.fromJson<String?>(json['cravingSessionId']),
      source: serializer.fromJson<String>(json['source']),
      category: serializer.fromJson<String?>(json['category']),
      subtriggerId: serializer.fromJson<String?>(json['subtriggerId']),
      intensityBefore: serializer.fromJson<int?>(json['intensityBefore']),
      intensityAfter: serializer.fromJson<int?>(json['intensityAfter']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      mode: serializer.fromJson<String>(json['mode']),
      score: serializer.fromJson<int>(json['score']),
      coinsAwarded: serializer.fromJson<int>(json['coinsAwarded']),
      completed: serializer.fromJson<bool>(json['completed']),
      helpfulness: serializer.fromJson<String?>(json['helpfulness']),
      cravingReturned: serializer.fromJson<bool?>(json['cravingReturned']),
      game: serializer.fromJson<String>(json['game']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'cravingSessionId': serializer.toJson<String?>(cravingSessionId),
      'source': serializer.toJson<String>(source),
      'category': serializer.toJson<String?>(category),
      'subtriggerId': serializer.toJson<String?>(subtriggerId),
      'intensityBefore': serializer.toJson<int?>(intensityBefore),
      'intensityAfter': serializer.toJson<int?>(intensityAfter),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'mode': serializer.toJson<String>(mode),
      'score': serializer.toJson<int>(score),
      'coinsAwarded': serializer.toJson<int>(coinsAwarded),
      'completed': serializer.toJson<bool>(completed),
      'helpfulness': serializer.toJson<String?>(helpfulness),
      'cravingReturned': serializer.toJson<bool?>(cravingReturned),
      'game': serializer.toJson<String>(game),
    };
  }

  GameSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? completedAt,
    Value<String?> cravingSessionId = const Value.absent(),
    String? source,
    Value<String?> category = const Value.absent(),
    Value<String?> subtriggerId = const Value.absent(),
    Value<int?> intensityBefore = const Value.absent(),
    Value<int?> intensityAfter = const Value.absent(),
    int? durationSeconds,
    String? mode,
    int? score,
    int? coinsAwarded,
    bool? completed,
    Value<String?> helpfulness = const Value.absent(),
    Value<bool?> cravingReturned = const Value.absent(),
    String? game,
  }) => GameSession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    cravingSessionId: cravingSessionId.present
        ? cravingSessionId.value
        : this.cravingSessionId,
    source: source ?? this.source,
    category: category.present ? category.value : this.category,
    subtriggerId: subtriggerId.present ? subtriggerId.value : this.subtriggerId,
    intensityBefore: intensityBefore.present
        ? intensityBefore.value
        : this.intensityBefore,
    intensityAfter: intensityAfter.present
        ? intensityAfter.value
        : this.intensityAfter,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    mode: mode ?? this.mode,
    score: score ?? this.score,
    coinsAwarded: coinsAwarded ?? this.coinsAwarded,
    completed: completed ?? this.completed,
    helpfulness: helpfulness.present ? helpfulness.value : this.helpfulness,
    cravingReturned: cravingReturned.present
        ? cravingReturned.value
        : this.cravingReturned,
    game: game ?? this.game,
  );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      cravingSessionId: data.cravingSessionId.present
          ? data.cravingSessionId.value
          : this.cravingSessionId,
      source: data.source.present ? data.source.value : this.source,
      category: data.category.present ? data.category.value : this.category,
      subtriggerId: data.subtriggerId.present
          ? data.subtriggerId.value
          : this.subtriggerId,
      intensityBefore: data.intensityBefore.present
          ? data.intensityBefore.value
          : this.intensityBefore,
      intensityAfter: data.intensityAfter.present
          ? data.intensityAfter.value
          : this.intensityAfter,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      mode: data.mode.present ? data.mode.value : this.mode,
      score: data.score.present ? data.score.value : this.score,
      coinsAwarded: data.coinsAwarded.present
          ? data.coinsAwarded.value
          : this.coinsAwarded,
      completed: data.completed.present ? data.completed.value : this.completed,
      helpfulness: data.helpfulness.present
          ? data.helpfulness.value
          : this.helpfulness,
      cravingReturned: data.cravingReturned.present
          ? data.cravingReturned.value
          : this.cravingReturned,
      game: data.game.present ? data.game.value : this.game,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cravingSessionId: $cravingSessionId, ')
          ..write('source: $source, ')
          ..write('category: $category, ')
          ..write('subtriggerId: $subtriggerId, ')
          ..write('intensityBefore: $intensityBefore, ')
          ..write('intensityAfter: $intensityAfter, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('mode: $mode, ')
          ..write('score: $score, ')
          ..write('coinsAwarded: $coinsAwarded, ')
          ..write('completed: $completed, ')
          ..write('helpfulness: $helpfulness, ')
          ..write('cravingReturned: $cravingReturned, ')
          ..write('game: $game')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    completedAt,
    cravingSessionId,
    source,
    category,
    subtriggerId,
    intensityBefore,
    intensityAfter,
    durationSeconds,
    mode,
    score,
    coinsAwarded,
    completed,
    helpfulness,
    cravingReturned,
    game,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.cravingSessionId == this.cravingSessionId &&
          other.source == this.source &&
          other.category == this.category &&
          other.subtriggerId == this.subtriggerId &&
          other.intensityBefore == this.intensityBefore &&
          other.intensityAfter == this.intensityAfter &&
          other.durationSeconds == this.durationSeconds &&
          other.mode == this.mode &&
          other.score == this.score &&
          other.coinsAwarded == this.coinsAwarded &&
          other.completed == this.completed &&
          other.helpfulness == this.helpfulness &&
          other.cravingReturned == this.cravingReturned &&
          other.game == this.game);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<String?> cravingSessionId;
  final Value<String> source;
  final Value<String?> category;
  final Value<String?> subtriggerId;
  final Value<int?> intensityBefore;
  final Value<int?> intensityAfter;
  final Value<int> durationSeconds;
  final Value<String> mode;
  final Value<int> score;
  final Value<int> coinsAwarded;
  final Value<bool> completed;
  final Value<String?> helpfulness;
  final Value<bool?> cravingReturned;
  final Value<String> game;
  final Value<int> rowid;
  const GameSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.cravingSessionId = const Value.absent(),
    this.source = const Value.absent(),
    this.category = const Value.absent(),
    this.subtriggerId = const Value.absent(),
    this.intensityBefore = const Value.absent(),
    this.intensityAfter = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.mode = const Value.absent(),
    this.score = const Value.absent(),
    this.coinsAwarded = const Value.absent(),
    this.completed = const Value.absent(),
    this.helpfulness = const Value.absent(),
    this.cravingReturned = const Value.absent(),
    this.game = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    required String id,
    required DateTime startedAt,
    required DateTime completedAt,
    this.cravingSessionId = const Value.absent(),
    required String source,
    this.category = const Value.absent(),
    this.subtriggerId = const Value.absent(),
    this.intensityBefore = const Value.absent(),
    this.intensityAfter = const Value.absent(),
    required int durationSeconds,
    required String mode,
    required int score,
    this.coinsAwarded = const Value.absent(),
    this.completed = const Value.absent(),
    this.helpfulness = const Value.absent(),
    this.cravingReturned = const Value.absent(),
    this.game = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       completedAt = Value(completedAt),
       source = Value(source),
       durationSeconds = Value(durationSeconds),
       mode = Value(mode),
       score = Value(score);
  static Insertable<GameSession> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? cravingSessionId,
    Expression<String>? source,
    Expression<String>? category,
    Expression<String>? subtriggerId,
    Expression<int>? intensityBefore,
    Expression<int>? intensityAfter,
    Expression<int>? durationSeconds,
    Expression<String>? mode,
    Expression<int>? score,
    Expression<int>? coinsAwarded,
    Expression<bool>? completed,
    Expression<String>? helpfulness,
    Expression<bool>? cravingReturned,
    Expression<String>? game,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (cravingSessionId != null) 'craving_session_id': cravingSessionId,
      if (source != null) 'source': source,
      if (category != null) 'category': category,
      if (subtriggerId != null) 'subtrigger_id': subtriggerId,
      if (intensityBefore != null) 'intensity_before': intensityBefore,
      if (intensityAfter != null) 'intensity_after': intensityAfter,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (mode != null) 'mode': mode,
      if (score != null) 'score': score,
      if (coinsAwarded != null) 'coins_awarded': coinsAwarded,
      if (completed != null) 'completed': completed,
      if (helpfulness != null) 'helpfulness': helpfulness,
      if (cravingReturned != null) 'craving_returned': cravingReturned,
      if (game != null) 'game': game,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<String?>? cravingSessionId,
    Value<String>? source,
    Value<String?>? category,
    Value<String?>? subtriggerId,
    Value<int?>? intensityBefore,
    Value<int?>? intensityAfter,
    Value<int>? durationSeconds,
    Value<String>? mode,
    Value<int>? score,
    Value<int>? coinsAwarded,
    Value<bool>? completed,
    Value<String?>? helpfulness,
    Value<bool?>? cravingReturned,
    Value<String>? game,
    Value<int>? rowid,
  }) {
    return GameSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cravingSessionId: cravingSessionId ?? this.cravingSessionId,
      source: source ?? this.source,
      category: category ?? this.category,
      subtriggerId: subtriggerId ?? this.subtriggerId,
      intensityBefore: intensityBefore ?? this.intensityBefore,
      intensityAfter: intensityAfter ?? this.intensityAfter,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      mode: mode ?? this.mode,
      score: score ?? this.score,
      coinsAwarded: coinsAwarded ?? this.coinsAwarded,
      completed: completed ?? this.completed,
      helpfulness: helpfulness ?? this.helpfulness,
      cravingReturned: cravingReturned ?? this.cravingReturned,
      game: game ?? this.game,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (cravingSessionId.present) {
      map['craving_session_id'] = Variable<String>(cravingSessionId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subtriggerId.present) {
      map['subtrigger_id'] = Variable<String>(subtriggerId.value);
    }
    if (intensityBefore.present) {
      map['intensity_before'] = Variable<int>(intensityBefore.value);
    }
    if (intensityAfter.present) {
      map['intensity_after'] = Variable<int>(intensityAfter.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (coinsAwarded.present) {
      map['coins_awarded'] = Variable<int>(coinsAwarded.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (helpfulness.present) {
      map['helpfulness'] = Variable<String>(helpfulness.value);
    }
    if (cravingReturned.present) {
      map['craving_returned'] = Variable<bool>(cravingReturned.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(game.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('cravingSessionId: $cravingSessionId, ')
          ..write('source: $source, ')
          ..write('category: $category, ')
          ..write('subtriggerId: $subtriggerId, ')
          ..write('intensityBefore: $intensityBefore, ')
          ..write('intensityAfter: $intensityAfter, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('mode: $mode, ')
          ..write('score: $score, ')
          ..write('coinsAwarded: $coinsAwarded, ')
          ..write('completed: $completed, ')
          ..write('helpfulness: $helpfulness, ')
          ..write('cravingReturned: $cravingReturned, ')
          ..write('game: $game, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $CravingLogsTable cravingLogs = $CravingLogsTable(this);
  late final $LearnedPriorsTable learnedPriors = $LearnedPriorsTable(this);
  late final $InterventionStatsTable interventionStats =
      $InterventionStatsTable(this);
  late final $ReflectionEntriesTable reflectionEntries =
      $ReflectionEntriesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $AvatarProfilesTable avatarProfiles = $AvatarProfilesTable(this);
  late final $OwnedCosmeticsTable ownedCosmetics = $OwnedCosmeticsTable(this);
  late final $OutfitPresetsTable outfitPresets = $OutfitPresetsTable(this);
  late final $CoinLedgerTable coinLedger = $CoinLedgerTable(this);
  late final $StreakStatesTable streakStates = $StreakStatesTable(this);
  late final $MilestoneUnlocksTable milestoneUnlocks = $MilestoneUnlocksTable(
    this,
  );
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    cravingLogs,
    learnedPriors,
    interventionStats,
    reflectionEntries,
    appSettings,
    avatarProfiles,
    ownedCosmetics,
    outfitPresets,
    coinLedger,
    streakStates,
    milestoneUnlocks,
    gameSessions,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required String payload,
      required DateTime updatedAt,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String> payload,
      Value<DateTime> updatedAt,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                payload: payload,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
                required DateTime updatedAt,
              }) => UserProfilesCompanion.insert(
                id: id,
                payload: payload,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfilesTable, UserProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfilesTable,
                    UserProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$CravingLogsTableCreateCompanionBuilder =
    CravingLogsCompanion Function({
      required String id,
      required DateTime startedAt,
      required DateTime completedAt,
      Value<String?> cravingType,
      Value<String?> category,
      Value<String?> subtriggerId,
      required int intensityBefore,
      Value<int?> intensityAfter,
      Value<bool?> hungry,
      required String safetyExit,
      Value<String?> planId,
      Value<String?> planTitle,
      Value<bool> nonLearnable,
      Value<String?> outcome,
      Value<bool?> planCompleted,
      Value<int?> helpfulStepIndex,
      Value<bool?> cravingReturned,
      Value<String> contextJson,
      Value<int> rowid,
    });
typedef $$CravingLogsTableUpdateCompanionBuilder =
    CravingLogsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime> completedAt,
      Value<String?> cravingType,
      Value<String?> category,
      Value<String?> subtriggerId,
      Value<int> intensityBefore,
      Value<int?> intensityAfter,
      Value<bool?> hungry,
      Value<String> safetyExit,
      Value<String?> planId,
      Value<String?> planTitle,
      Value<bool> nonLearnable,
      Value<String?> outcome,
      Value<bool?> planCompleted,
      Value<int?> helpfulStepIndex,
      Value<bool?> cravingReturned,
      Value<String> contextJson,
      Value<int> rowid,
    });

class $$CravingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CravingLogsTable> {
  $$CravingLogsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cravingType => $composableBuilder(
    column: $table.cravingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtriggerId => $composableBuilder(
    column: $table.subtriggerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensityBefore => $composableBuilder(
    column: $table.intensityBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensityAfter => $composableBuilder(
    column: $table.intensityAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hungry => $composableBuilder(
    column: $table.hungry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyExit => $composableBuilder(
    column: $table.safetyExit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planTitle => $composableBuilder(
    column: $table.planTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nonLearnable => $composableBuilder(
    column: $table.nonLearnable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get planCompleted => $composableBuilder(
    column: $table.planCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get helpfulStepIndex => $composableBuilder(
    column: $table.helpfulStepIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cravingReturned => $composableBuilder(
    column: $table.cravingReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CravingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CravingLogsTable> {
  $$CravingLogsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cravingType => $composableBuilder(
    column: $table.cravingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtriggerId => $composableBuilder(
    column: $table.subtriggerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensityBefore => $composableBuilder(
    column: $table.intensityBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensityAfter => $composableBuilder(
    column: $table.intensityAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hungry => $composableBuilder(
    column: $table.hungry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyExit => $composableBuilder(
    column: $table.safetyExit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planTitle => $composableBuilder(
    column: $table.planTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nonLearnable => $composableBuilder(
    column: $table.nonLearnable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get planCompleted => $composableBuilder(
    column: $table.planCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get helpfulStepIndex => $composableBuilder(
    column: $table.helpfulStepIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cravingReturned => $composableBuilder(
    column: $table.cravingReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CravingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CravingLogsTable> {
  $$CravingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cravingType => $composableBuilder(
    column: $table.cravingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subtriggerId => $composableBuilder(
    column: $table.subtriggerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensityBefore => $composableBuilder(
    column: $table.intensityBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensityAfter => $composableBuilder(
    column: $table.intensityAfter,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hungry =>
      $composableBuilder(column: $table.hungry, builder: (column) => column);

  GeneratedColumn<String> get safetyExit => $composableBuilder(
    column: $table.safetyExit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get planTitle =>
      $composableBuilder(column: $table.planTitle, builder: (column) => column);

  GeneratedColumn<bool> get nonLearnable => $composableBuilder(
    column: $table.nonLearnable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<bool> get planCompleted => $composableBuilder(
    column: $table.planCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get helpfulStepIndex => $composableBuilder(
    column: $table.helpfulStepIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cravingReturned => $composableBuilder(
    column: $table.cravingReturned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => column,
  );
}

class $$CravingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CravingLogsTable,
          CravingLog,
          $$CravingLogsTableFilterComposer,
          $$CravingLogsTableOrderingComposer,
          $$CravingLogsTableAnnotationComposer,
          $$CravingLogsTableCreateCompanionBuilder,
          $$CravingLogsTableUpdateCompanionBuilder,
          (
            CravingLog,
            BaseReferences<_$AppDatabase, $CravingLogsTable, CravingLog>,
          ),
          CravingLog,
          PrefetchHooks Function()
        > {
  $$CravingLogsTableTableManager(_$AppDatabase db, $CravingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CravingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CravingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CravingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> cravingType = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subtriggerId = const Value.absent(),
                Value<int> intensityBefore = const Value.absent(),
                Value<int?> intensityAfter = const Value.absent(),
                Value<bool?> hungry = const Value.absent(),
                Value<String> safetyExit = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<String?> planTitle = const Value.absent(),
                Value<bool> nonLearnable = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<bool?> planCompleted = const Value.absent(),
                Value<int?> helpfulStepIndex = const Value.absent(),
                Value<bool?> cravingReturned = const Value.absent(),
                Value<String> contextJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CravingLogsCompanion(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                cravingType: cravingType,
                category: category,
                subtriggerId: subtriggerId,
                intensityBefore: intensityBefore,
                intensityAfter: intensityAfter,
                hungry: hungry,
                safetyExit: safetyExit,
                planId: planId,
                planTitle: planTitle,
                nonLearnable: nonLearnable,
                outcome: outcome,
                planCompleted: planCompleted,
                helpfulStepIndex: helpfulStepIndex,
                cravingReturned: cravingReturned,
                contextJson: contextJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                required DateTime completedAt,
                Value<String?> cravingType = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subtriggerId = const Value.absent(),
                required int intensityBefore,
                Value<int?> intensityAfter = const Value.absent(),
                Value<bool?> hungry = const Value.absent(),
                required String safetyExit,
                Value<String?> planId = const Value.absent(),
                Value<String?> planTitle = const Value.absent(),
                Value<bool> nonLearnable = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<bool?> planCompleted = const Value.absent(),
                Value<int?> helpfulStepIndex = const Value.absent(),
                Value<bool?> cravingReturned = const Value.absent(),
                Value<String> contextJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CravingLogsCompanion.insert(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                cravingType: cravingType,
                category: category,
                subtriggerId: subtriggerId,
                intensityBefore: intensityBefore,
                intensityAfter: intensityAfter,
                hungry: hungry,
                safetyExit: safetyExit,
                planId: planId,
                planTitle: planTitle,
                nonLearnable: nonLearnable,
                outcome: outcome,
                planCompleted: planCompleted,
                helpfulStepIndex: helpfulStepIndex,
                cravingReturned: cravingReturned,
                contextJson: contextJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CravingLogsTable, CravingLog>(table),
                  BaseReferences<_$AppDatabase, $CravingLogsTable, CravingLog>(
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

typedef $$CravingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CravingLogsTable,
      CravingLog,
      $$CravingLogsTableFilterComposer,
      $$CravingLogsTableOrderingComposer,
      $$CravingLogsTableAnnotationComposer,
      $$CravingLogsTableCreateCompanionBuilder,
      $$CravingLogsTableUpdateCompanionBuilder,
      (
        CravingLog,
        BaseReferences<_$AppDatabase, $CravingLogsTable, CravingLog>,
      ),
      CravingLog,
      PrefetchHooks Function()
    >;
typedef $$LearnedPriorsTableCreateCompanionBuilder =
    LearnedPriorsCompanion Function({
      required String key,
      required String cravingType,
      required String category,
      required double score,
      required int sampleSize,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LearnedPriorsTableUpdateCompanionBuilder =
    LearnedPriorsCompanion Function({
      Value<String> key,
      Value<String> cravingType,
      Value<String> category,
      Value<double> score,
      Value<int> sampleSize,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LearnedPriorsTableFilterComposer
    extends Composer<_$AppDatabase, $LearnedPriorsTable> {
  $$LearnedPriorsTableFilterComposer({
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

  ColumnFilters<String> get cravingType => $composableBuilder(
    column: $table.cravingType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleSize => $composableBuilder(
    column: $table.sampleSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LearnedPriorsTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnedPriorsTable> {
  $$LearnedPriorsTableOrderingComposer({
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

  ColumnOrderings<String> get cravingType => $composableBuilder(
    column: $table.cravingType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleSize => $composableBuilder(
    column: $table.sampleSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LearnedPriorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnedPriorsTable> {
  $$LearnedPriorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get cravingType => $composableBuilder(
    column: $table.cravingType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get sampleSize => $composableBuilder(
    column: $table.sampleSize,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LearnedPriorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LearnedPriorsTable,
          LearnedPrior,
          $$LearnedPriorsTableFilterComposer,
          $$LearnedPriorsTableOrderingComposer,
          $$LearnedPriorsTableAnnotationComposer,
          $$LearnedPriorsTableCreateCompanionBuilder,
          $$LearnedPriorsTableUpdateCompanionBuilder,
          (
            LearnedPrior,
            BaseReferences<_$AppDatabase, $LearnedPriorsTable, LearnedPrior>,
          ),
          LearnedPrior,
          PrefetchHooks Function()
        > {
  $$LearnedPriorsTableTableManager(_$AppDatabase db, $LearnedPriorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnedPriorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnedPriorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnedPriorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> cravingType = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<int> sampleSize = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LearnedPriorsCompanion(
                key: key,
                cravingType: cravingType,
                category: category,
                score: score,
                sampleSize: sampleSize,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String cravingType,
                required String category,
                required double score,
                required int sampleSize,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LearnedPriorsCompanion.insert(
                key: key,
                cravingType: cravingType,
                category: category,
                score: score,
                sampleSize: sampleSize,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LearnedPriorsTable, LearnedPrior>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LearnedPriorsTable,
                    LearnedPrior
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LearnedPriorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LearnedPriorsTable,
      LearnedPrior,
      $$LearnedPriorsTableFilterComposer,
      $$LearnedPriorsTableOrderingComposer,
      $$LearnedPriorsTableAnnotationComposer,
      $$LearnedPriorsTableCreateCompanionBuilder,
      $$LearnedPriorsTableUpdateCompanionBuilder,
      (
        LearnedPrior,
        BaseReferences<_$AppDatabase, $LearnedPriorsTable, LearnedPrior>,
      ),
      LearnedPrior,
      PrefetchHooks Function()
    >;
typedef $$InterventionStatsTableCreateCompanionBuilder =
    InterventionStatsCompanion Function({
      required String interventionId,
      Value<int> uses,
      Value<int> helpful,
      required DateTime lastUsedAt,
      Value<int> rowid,
    });
typedef $$InterventionStatsTableUpdateCompanionBuilder =
    InterventionStatsCompanion Function({
      Value<String> interventionId,
      Value<int> uses,
      Value<int> helpful,
      Value<DateTime> lastUsedAt,
      Value<int> rowid,
    });

class $$InterventionStatsTableFilterComposer
    extends Composer<_$AppDatabase, $InterventionStatsTable> {
  $$InterventionStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get interventionId => $composableBuilder(
    column: $table.interventionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uses => $composableBuilder(
    column: $table.uses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get helpful => $composableBuilder(
    column: $table.helpful,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterventionStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $InterventionStatsTable> {
  $$InterventionStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get interventionId => $composableBuilder(
    column: $table.interventionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uses => $composableBuilder(
    column: $table.uses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get helpful => $composableBuilder(
    column: $table.helpful,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterventionStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterventionStatsTable> {
  $$InterventionStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get interventionId => $composableBuilder(
    column: $table.interventionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uses =>
      $composableBuilder(column: $table.uses, builder: (column) => column);

  GeneratedColumn<int> get helpful =>
      $composableBuilder(column: $table.helpful, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$InterventionStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InterventionStatsTable,
          InterventionStat,
          $$InterventionStatsTableFilterComposer,
          $$InterventionStatsTableOrderingComposer,
          $$InterventionStatsTableAnnotationComposer,
          $$InterventionStatsTableCreateCompanionBuilder,
          $$InterventionStatsTableUpdateCompanionBuilder,
          (
            InterventionStat,
            BaseReferences<
              _$AppDatabase,
              $InterventionStatsTable,
              InterventionStat
            >,
          ),
          InterventionStat,
          PrefetchHooks Function()
        > {
  $$InterventionStatsTableTableManager(
    _$AppDatabase db,
    $InterventionStatsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterventionStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterventionStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterventionStatsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> interventionId = const Value.absent(),
                Value<int> uses = const Value.absent(),
                Value<int> helpful = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterventionStatsCompanion(
                interventionId: interventionId,
                uses: uses,
                helpful: helpful,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String interventionId,
                Value<int> uses = const Value.absent(),
                Value<int> helpful = const Value.absent(),
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => InterventionStatsCompanion.insert(
                interventionId: interventionId,
                uses: uses,
                helpful: helpful,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InterventionStatsTable, InterventionStat>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InterventionStatsTable,
                    InterventionStat
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterventionStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InterventionStatsTable,
      InterventionStat,
      $$InterventionStatsTableFilterComposer,
      $$InterventionStatsTableOrderingComposer,
      $$InterventionStatsTableAnnotationComposer,
      $$InterventionStatsTableCreateCompanionBuilder,
      $$InterventionStatsTableUpdateCompanionBuilder,
      (
        InterventionStat,
        BaseReferences<
          _$AppDatabase,
          $InterventionStatsTable,
          InterventionStat
        >,
      ),
      InterventionStat,
      PrefetchHooks Function()
    >;
typedef $$ReflectionEntriesTableCreateCompanionBuilder =
    ReflectionEntriesCompanion Function({
      required String id,
      required DateTime createdAt,
      required String promptId,
      required String answer,
      Value<int> rowid,
    });
typedef $$ReflectionEntriesTableUpdateCompanionBuilder =
    ReflectionEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> promptId,
      Value<String> answer,
      Value<int> rowid,
    });

class $$ReflectionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionEntriesTable> {
  $$ReflectionEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReflectionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionEntriesTable> {
  $$ReflectionEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReflectionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionEntriesTable> {
  $$ReflectionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);
}

class $$ReflectionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReflectionEntriesTable,
          ReflectionEntry,
          $$ReflectionEntriesTableFilterComposer,
          $$ReflectionEntriesTableOrderingComposer,
          $$ReflectionEntriesTableAnnotationComposer,
          $$ReflectionEntriesTableCreateCompanionBuilder,
          $$ReflectionEntriesTableUpdateCompanionBuilder,
          (
            ReflectionEntry,
            BaseReferences<
              _$AppDatabase,
              $ReflectionEntriesTable,
              ReflectionEntry
            >,
          ),
          ReflectionEntry,
          PrefetchHooks Function()
        > {
  $$ReflectionEntriesTableTableManager(
    _$AppDatabase db,
    $ReflectionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> promptId = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionEntriesCompanion(
                id: id,
                createdAt: createdAt,
                promptId: promptId,
                answer: answer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String promptId,
                required String answer,
                Value<int> rowid = const Value.absent(),
              }) => ReflectionEntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                promptId: promptId,
                answer: answer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReflectionEntriesTable, ReflectionEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReflectionEntriesTable,
                    ReflectionEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReflectionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReflectionEntriesTable,
      ReflectionEntry,
      $$ReflectionEntriesTableFilterComposer,
      $$ReflectionEntriesTableOrderingComposer,
      $$ReflectionEntriesTableAnnotationComposer,
      $$ReflectionEntriesTableCreateCompanionBuilder,
      $$ReflectionEntriesTableUpdateCompanionBuilder,
      (
        ReflectionEntry,
        BaseReferences<_$AppDatabase, $ReflectionEntriesTable, ReflectionEntry>,
      ),
      ReflectionEntry,
      PrefetchHooks Function()
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
          updateCompanionCallback:
              ({
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
typedef $$AvatarProfilesTableCreateCompanionBuilder =
    AvatarProfilesCompanion Function({
      Value<int> id,
      required String payload,
      required DateTime updatedAt,
    });
typedef $$AvatarProfilesTableUpdateCompanionBuilder =
    AvatarProfilesCompanion Function({
      Value<int> id,
      Value<String> payload,
      Value<DateTime> updatedAt,
    });

class $$AvatarProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $AvatarProfilesTable> {
  $$AvatarProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AvatarProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $AvatarProfilesTable> {
  $$AvatarProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AvatarProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AvatarProfilesTable> {
  $$AvatarProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AvatarProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AvatarProfilesTable,
          AvatarProfile,
          $$AvatarProfilesTableFilterComposer,
          $$AvatarProfilesTableOrderingComposer,
          $$AvatarProfilesTableAnnotationComposer,
          $$AvatarProfilesTableCreateCompanionBuilder,
          $$AvatarProfilesTableUpdateCompanionBuilder,
          (
            AvatarProfile,
            BaseReferences<_$AppDatabase, $AvatarProfilesTable, AvatarProfile>,
          ),
          AvatarProfile,
          PrefetchHooks Function()
        > {
  $$AvatarProfilesTableTableManager(
    _$AppDatabase db,
    $AvatarProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AvatarProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AvatarProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AvatarProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AvatarProfilesCompanion(
                id: id,
                payload: payload,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
                required DateTime updatedAt,
              }) => AvatarProfilesCompanion.insert(
                id: id,
                payload: payload,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AvatarProfilesTable, AvatarProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AvatarProfilesTable,
                    AvatarProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AvatarProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AvatarProfilesTable,
      AvatarProfile,
      $$AvatarProfilesTableFilterComposer,
      $$AvatarProfilesTableOrderingComposer,
      $$AvatarProfilesTableAnnotationComposer,
      $$AvatarProfilesTableCreateCompanionBuilder,
      $$AvatarProfilesTableUpdateCompanionBuilder,
      (
        AvatarProfile,
        BaseReferences<_$AppDatabase, $AvatarProfilesTable, AvatarProfile>,
      ),
      AvatarProfile,
      PrefetchHooks Function()
    >;
typedef $$OwnedCosmeticsTableCreateCompanionBuilder =
    OwnedCosmeticsCompanion Function({
      required String itemId,
      required DateTime acquiredAt,
      required String source,
      Value<int> rowid,
    });
typedef $$OwnedCosmeticsTableUpdateCompanionBuilder =
    OwnedCosmeticsCompanion Function({
      Value<String> itemId,
      Value<DateTime> acquiredAt,
      Value<String> source,
      Value<int> rowid,
    });

class $$OwnedCosmeticsTableFilterComposer
    extends Composer<_$AppDatabase, $OwnedCosmeticsTable> {
  $$OwnedCosmeticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OwnedCosmeticsTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnedCosmeticsTable> {
  $$OwnedCosmeticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnedCosmeticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnedCosmeticsTable> {
  $$OwnedCosmeticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$OwnedCosmeticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnedCosmeticsTable,
          OwnedCosmetic,
          $$OwnedCosmeticsTableFilterComposer,
          $$OwnedCosmeticsTableOrderingComposer,
          $$OwnedCosmeticsTableAnnotationComposer,
          $$OwnedCosmeticsTableCreateCompanionBuilder,
          $$OwnedCosmeticsTableUpdateCompanionBuilder,
          (
            OwnedCosmetic,
            BaseReferences<_$AppDatabase, $OwnedCosmeticsTable, OwnedCosmetic>,
          ),
          OwnedCosmetic,
          PrefetchHooks Function()
        > {
  $$OwnedCosmeticsTableTableManager(
    _$AppDatabase db,
    $OwnedCosmeticsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnedCosmeticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnedCosmeticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnedCosmeticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<DateTime> acquiredAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnedCosmeticsCompanion(
                itemId: itemId,
                acquiredAt: acquiredAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required DateTime acquiredAt,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => OwnedCosmeticsCompanion.insert(
                itemId: itemId,
                acquiredAt: acquiredAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OwnedCosmeticsTable, OwnedCosmetic>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OwnedCosmeticsTable,
                    OwnedCosmetic
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnedCosmeticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnedCosmeticsTable,
      OwnedCosmetic,
      $$OwnedCosmeticsTableFilterComposer,
      $$OwnedCosmeticsTableOrderingComposer,
      $$OwnedCosmeticsTableAnnotationComposer,
      $$OwnedCosmeticsTableCreateCompanionBuilder,
      $$OwnedCosmeticsTableUpdateCompanionBuilder,
      (
        OwnedCosmetic,
        BaseReferences<_$AppDatabase, $OwnedCosmeticsTable, OwnedCosmetic>,
      ),
      OwnedCosmetic,
      PrefetchHooks Function()
    >;
typedef $$OutfitPresetsTableCreateCompanionBuilder =
    OutfitPresetsCompanion Function({
      required String id,
      required String name,
      required String payload,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OutfitPresetsTableUpdateCompanionBuilder =
    OutfitPresetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$OutfitPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitPresetsTable> {
  $$OutfitPresetsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutfitPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitPresetsTable> {
  $$OutfitPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutfitPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitPresetsTable> {
  $$OutfitPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutfitPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitPresetsTable,
          OutfitPreset,
          $$OutfitPresetsTableFilterComposer,
          $$OutfitPresetsTableOrderingComposer,
          $$OutfitPresetsTableAnnotationComposer,
          $$OutfitPresetsTableCreateCompanionBuilder,
          $$OutfitPresetsTableUpdateCompanionBuilder,
          (
            OutfitPreset,
            BaseReferences<_$AppDatabase, $OutfitPresetsTable, OutfitPreset>,
          ),
          OutfitPreset,
          PrefetchHooks Function()
        > {
  $$OutfitPresetsTableTableManager(_$AppDatabase db, $OutfitPresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitPresetsCompanion(
                id: id,
                name: name,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String payload,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutfitPresetsCompanion.insert(
                id: id,
                name: name,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutfitPresetsTable, OutfitPreset>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OutfitPresetsTable,
                    OutfitPreset
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutfitPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitPresetsTable,
      OutfitPreset,
      $$OutfitPresetsTableFilterComposer,
      $$OutfitPresetsTableOrderingComposer,
      $$OutfitPresetsTableAnnotationComposer,
      $$OutfitPresetsTableCreateCompanionBuilder,
      $$OutfitPresetsTableUpdateCompanionBuilder,
      (
        OutfitPreset,
        BaseReferences<_$AppDatabase, $OutfitPresetsTable, OutfitPreset>,
      ),
      OutfitPreset,
      PrefetchHooks Function()
    >;
typedef $$CoinLedgerTableCreateCompanionBuilder =
    CoinLedgerCompanion Function({
      required String eventId,
      required DateTime createdAt,
      required int amount,
      required String reason,
      Value<String?> relatedSessionId,
      required String sourceType,
      Value<int> rowid,
    });
typedef $$CoinLedgerTableUpdateCompanionBuilder =
    CoinLedgerCompanion Function({
      Value<String> eventId,
      Value<DateTime> createdAt,
      Value<int> amount,
      Value<String> reason,
      Value<String?> relatedSessionId,
      Value<String> sourceType,
      Value<int> rowid,
    });

class $$CoinLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $CoinLedgerTable> {
  $$CoinLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedSessionId => $composableBuilder(
    column: $table.relatedSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoinLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $CoinLedgerTable> {
  $$CoinLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedSessionId => $composableBuilder(
    column: $table.relatedSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoinLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoinLedgerTable> {
  $$CoinLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get relatedSessionId => $composableBuilder(
    column: $table.relatedSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );
}

class $$CoinLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoinLedgerTable,
          CoinLedgerData,
          $$CoinLedgerTableFilterComposer,
          $$CoinLedgerTableOrderingComposer,
          $$CoinLedgerTableAnnotationComposer,
          $$CoinLedgerTableCreateCompanionBuilder,
          $$CoinLedgerTableUpdateCompanionBuilder,
          (
            CoinLedgerData,
            BaseReferences<_$AppDatabase, $CoinLedgerTable, CoinLedgerData>,
          ),
          CoinLedgerData,
          PrefetchHooks Function()
        > {
  $$CoinLedgerTableTableManager(_$AppDatabase db, $CoinLedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoinLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoinLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoinLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> relatedSessionId = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoinLedgerCompanion(
                eventId: eventId,
                createdAt: createdAt,
                amount: amount,
                reason: reason,
                relatedSessionId: relatedSessionId,
                sourceType: sourceType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required DateTime createdAt,
                required int amount,
                required String reason,
                Value<String?> relatedSessionId = const Value.absent(),
                required String sourceType,
                Value<int> rowid = const Value.absent(),
              }) => CoinLedgerCompanion.insert(
                eventId: eventId,
                createdAt: createdAt,
                amount: amount,
                reason: reason,
                relatedSessionId: relatedSessionId,
                sourceType: sourceType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoinLedgerTable, CoinLedgerData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CoinLedgerTable,
                    CoinLedgerData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoinLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoinLedgerTable,
      CoinLedgerData,
      $$CoinLedgerTableFilterComposer,
      $$CoinLedgerTableOrderingComposer,
      $$CoinLedgerTableAnnotationComposer,
      $$CoinLedgerTableCreateCompanionBuilder,
      $$CoinLedgerTableUpdateCompanionBuilder,
      (
        CoinLedgerData,
        BaseReferences<_$AppDatabase, $CoinLedgerTable, CoinLedgerData>,
      ),
      CoinLedgerData,
      PrefetchHooks Function()
    >;
typedef $$StreakStatesTableCreateCompanionBuilder =
    StreakStatesCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<DateTime?> lastActiveDay,
      Value<bool> graceAvailable,
    });
typedef $$StreakStatesTableUpdateCompanionBuilder =
    StreakStatesCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> bestStreak,
      Value<DateTime?> lastActiveDay,
      Value<bool> graceAvailable,
    });

class $$StreakStatesTableFilterComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get graceAvailable => $composableBuilder(
    column: $table.graceAvailable,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get graceAvailable => $composableBuilder(
    column: $table.graceAvailable,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakStatesTable> {
  $$StreakStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestStreak => $composableBuilder(
    column: $table.bestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDay => $composableBuilder(
    column: $table.lastActiveDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get graceAvailable => $composableBuilder(
    column: $table.graceAvailable,
    builder: (column) => column,
  );
}

class $$StreakStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakStatesTable,
          StreakState,
          $$StreakStatesTableFilterComposer,
          $$StreakStatesTableOrderingComposer,
          $$StreakStatesTableAnnotationComposer,
          $$StreakStatesTableCreateCompanionBuilder,
          $$StreakStatesTableUpdateCompanionBuilder,
          (
            StreakState,
            BaseReferences<_$AppDatabase, $StreakStatesTable, StreakState>,
          ),
          StreakState,
          PrefetchHooks Function()
        > {
  $$StreakStatesTableTableManager(_$AppDatabase db, $StreakStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<DateTime?> lastActiveDay = const Value.absent(),
                Value<bool> graceAvailable = const Value.absent(),
              }) => StreakStatesCompanion(
                id: id,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lastActiveDay: lastActiveDay,
                graceAvailable: graceAvailable,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> bestStreak = const Value.absent(),
                Value<DateTime?> lastActiveDay = const Value.absent(),
                Value<bool> graceAvailable = const Value.absent(),
              }) => StreakStatesCompanion.insert(
                id: id,
                currentStreak: currentStreak,
                bestStreak: bestStreak,
                lastActiveDay: lastActiveDay,
                graceAvailable: graceAvailable,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreakStatesTable, StreakState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StreakStatesTable,
                    StreakState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakStatesTable,
      StreakState,
      $$StreakStatesTableFilterComposer,
      $$StreakStatesTableOrderingComposer,
      $$StreakStatesTableAnnotationComposer,
      $$StreakStatesTableCreateCompanionBuilder,
      $$StreakStatesTableUpdateCompanionBuilder,
      (
        StreakState,
        BaseReferences<_$AppDatabase, $StreakStatesTable, StreakState>,
      ),
      StreakState,
      PrefetchHooks Function()
    >;
typedef $$MilestoneUnlocksTableCreateCompanionBuilder =
    MilestoneUnlocksCompanion Function({
      required String milestoneId,
      required DateTime unlockedAt,
      Value<int> rowid,
    });
typedef $$MilestoneUnlocksTableUpdateCompanionBuilder =
    MilestoneUnlocksCompanion Function({
      Value<String> milestoneId,
      Value<DateTime> unlockedAt,
      Value<int> rowid,
    });

class $$MilestoneUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $MilestoneUnlocksTable> {
  $$MilestoneUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get milestoneId => $composableBuilder(
    column: $table.milestoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MilestoneUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestoneUnlocksTable> {
  $$MilestoneUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get milestoneId => $composableBuilder(
    column: $table.milestoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MilestoneUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestoneUnlocksTable> {
  $$MilestoneUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get milestoneId => $composableBuilder(
    column: $table.milestoneId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$MilestoneUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestoneUnlocksTable,
          MilestoneUnlock,
          $$MilestoneUnlocksTableFilterComposer,
          $$MilestoneUnlocksTableOrderingComposer,
          $$MilestoneUnlocksTableAnnotationComposer,
          $$MilestoneUnlocksTableCreateCompanionBuilder,
          $$MilestoneUnlocksTableUpdateCompanionBuilder,
          (
            MilestoneUnlock,
            BaseReferences<
              _$AppDatabase,
              $MilestoneUnlocksTable,
              MilestoneUnlock
            >,
          ),
          MilestoneUnlock,
          PrefetchHooks Function()
        > {
  $$MilestoneUnlocksTableTableManager(
    _$AppDatabase db,
    $MilestoneUnlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestoneUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestoneUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestoneUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> milestoneId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestoneUnlocksCompanion(
                milestoneId: milestoneId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String milestoneId,
                required DateTime unlockedAt,
                Value<int> rowid = const Value.absent(),
              }) => MilestoneUnlocksCompanion.insert(
                milestoneId: milestoneId,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilestoneUnlocksTable, MilestoneUnlock>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MilestoneUnlocksTable,
                    MilestoneUnlock
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MilestoneUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestoneUnlocksTable,
      MilestoneUnlock,
      $$MilestoneUnlocksTableFilterComposer,
      $$MilestoneUnlocksTableOrderingComposer,
      $$MilestoneUnlocksTableAnnotationComposer,
      $$MilestoneUnlocksTableCreateCompanionBuilder,
      $$MilestoneUnlocksTableUpdateCompanionBuilder,
      (
        MilestoneUnlock,
        BaseReferences<_$AppDatabase, $MilestoneUnlocksTable, MilestoneUnlock>,
      ),
      MilestoneUnlock,
      PrefetchHooks Function()
    >;
typedef $$GameSessionsTableCreateCompanionBuilder =
    GameSessionsCompanion Function({
      required String id,
      required DateTime startedAt,
      required DateTime completedAt,
      Value<String?> cravingSessionId,
      required String source,
      Value<String?> category,
      Value<String?> subtriggerId,
      Value<int?> intensityBefore,
      Value<int?> intensityAfter,
      required int durationSeconds,
      required String mode,
      required int score,
      Value<int> coinsAwarded,
      Value<bool> completed,
      Value<String?> helpfulness,
      Value<bool?> cravingReturned,
      Value<String> game,
      Value<int> rowid,
    });
typedef $$GameSessionsTableUpdateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime> completedAt,
      Value<String?> cravingSessionId,
      Value<String> source,
      Value<String?> category,
      Value<String?> subtriggerId,
      Value<int?> intensityBefore,
      Value<int?> intensityAfter,
      Value<int> durationSeconds,
      Value<String> mode,
      Value<int> score,
      Value<int> coinsAwarded,
      Value<bool> completed,
      Value<String?> helpfulness,
      Value<bool?> cravingReturned,
      Value<String> game,
      Value<int> rowid,
    });

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cravingSessionId => $composableBuilder(
    column: $table.cravingSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtriggerId => $composableBuilder(
    column: $table.subtriggerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensityBefore => $composableBuilder(
    column: $table.intensityBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensityAfter => $composableBuilder(
    column: $table.intensityAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get helpfulness => $composableBuilder(
    column: $table.helpfulness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cravingReturned => $composableBuilder(
    column: $table.cravingReturned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cravingSessionId => $composableBuilder(
    column: $table.cravingSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtriggerId => $composableBuilder(
    column: $table.subtriggerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensityBefore => $composableBuilder(
    column: $table.intensityBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensityAfter => $composableBuilder(
    column: $table.intensityAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get helpfulness => $composableBuilder(
    column: $table.helpfulness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cravingReturned => $composableBuilder(
    column: $table.cravingReturned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cravingSessionId => $composableBuilder(
    column: $table.cravingSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subtriggerId => $composableBuilder(
    column: $table.subtriggerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensityBefore => $composableBuilder(
    column: $table.intensityBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensityAfter => $composableBuilder(
    column: $table.intensityAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get coinsAwarded => $composableBuilder(
    column: $table.coinsAwarded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get helpfulness => $composableBuilder(
    column: $table.helpfulness,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cravingReturned => $composableBuilder(
    column: $table.cravingReturned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);
}

class $$GameSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsTable,
          GameSession,
          $$GameSessionsTableFilterComposer,
          $$GameSessionsTableOrderingComposer,
          $$GameSessionsTableAnnotationComposer,
          $$GameSessionsTableCreateCompanionBuilder,
          $$GameSessionsTableUpdateCompanionBuilder,
          (
            GameSession,
            BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
          ),
          GameSession,
          PrefetchHooks Function()
        > {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> cravingSessionId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> subtriggerId = const Value.absent(),
                Value<int?> intensityBefore = const Value.absent(),
                Value<int?> intensityAfter = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> coinsAwarded = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> helpfulness = const Value.absent(),
                Value<bool?> cravingReturned = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                cravingSessionId: cravingSessionId,
                source: source,
                category: category,
                subtriggerId: subtriggerId,
                intensityBefore: intensityBefore,
                intensityAfter: intensityAfter,
                durationSeconds: durationSeconds,
                mode: mode,
                score: score,
                coinsAwarded: coinsAwarded,
                completed: completed,
                helpfulness: helpfulness,
                cravingReturned: cravingReturned,
                game: game,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                required DateTime completedAt,
                Value<String?> cravingSessionId = const Value.absent(),
                required String source,
                Value<String?> category = const Value.absent(),
                Value<String?> subtriggerId = const Value.absent(),
                Value<int?> intensityBefore = const Value.absent(),
                Value<int?> intensityAfter = const Value.absent(),
                required int durationSeconds,
                required String mode,
                required int score,
                Value<int> coinsAwarded = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> helpfulness = const Value.absent(),
                Value<bool?> cravingReturned = const Value.absent(),
                Value<String> game = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                completedAt: completedAt,
                cravingSessionId: cravingSessionId,
                source: source,
                category: category,
                subtriggerId: subtriggerId,
                intensityBefore: intensityBefore,
                intensityAfter: intensityAfter,
                durationSeconds: durationSeconds,
                mode: mode,
                score: score,
                coinsAwarded: coinsAwarded,
                completed: completed,
                helpfulness: helpfulness,
                cravingReturned: cravingReturned,
                game: game,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSessionsTable, GameSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameSessionsTable,
                    GameSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsTable,
      GameSession,
      $$GameSessionsTableFilterComposer,
      $$GameSessionsTableOrderingComposer,
      $$GameSessionsTableAnnotationComposer,
      $$GameSessionsTableCreateCompanionBuilder,
      $$GameSessionsTableUpdateCompanionBuilder,
      (
        GameSession,
        BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
      ),
      GameSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$CravingLogsTableTableManager get cravingLogs =>
      $$CravingLogsTableTableManager(_db, _db.cravingLogs);
  $$LearnedPriorsTableTableManager get learnedPriors =>
      $$LearnedPriorsTableTableManager(_db, _db.learnedPriors);
  $$InterventionStatsTableTableManager get interventionStats =>
      $$InterventionStatsTableTableManager(_db, _db.interventionStats);
  $$ReflectionEntriesTableTableManager get reflectionEntries =>
      $$ReflectionEntriesTableTableManager(_db, _db.reflectionEntries);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$AvatarProfilesTableTableManager get avatarProfiles =>
      $$AvatarProfilesTableTableManager(_db, _db.avatarProfiles);
  $$OwnedCosmeticsTableTableManager get ownedCosmetics =>
      $$OwnedCosmeticsTableTableManager(_db, _db.ownedCosmetics);
  $$OutfitPresetsTableTableManager get outfitPresets =>
      $$OutfitPresetsTableTableManager(_db, _db.outfitPresets);
  $$CoinLedgerTableTableManager get coinLedger =>
      $$CoinLedgerTableTableManager(_db, _db.coinLedger);
  $$StreakStatesTableTableManager get streakStates =>
      $$StreakStatesTableTableManager(_db, _db.streakStates);
  $$MilestoneUnlocksTableTableManager get milestoneUnlocks =>
      $$MilestoneUnlocksTableTableManager(_db, _db.milestoneUnlocks);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
}
