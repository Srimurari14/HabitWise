import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_key.dart';

part 'app_database.g.dart';

class UserProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class CravingLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get cravingType => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get subtriggerId => text().nullable()();
  IntColumn get intensityBefore => integer()();
  IntColumn get intensityAfter => integer().nullable()();
  BoolColumn get hungry => boolean().nullable()();
  TextColumn get safetyExit => text()();
  TextColumn get planId => text().nullable()();
  TextColumn get planTitle => text().nullable()();
  BoolColumn get nonLearnable => boolean().withDefault(const Constant(false))();
  TextColumn get outcome => text().nullable()();
  BoolColumn get planCompleted => boolean().nullable()();
  IntColumn get helpfulStepIndex => integer().nullable()();
  BoolColumn get cravingReturned => boolean().nullable()();
  TextColumn get contextJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class LearnedPriors extends Table {
  TextColumn get key => text()();
  TextColumn get cravingType => text()();
  TextColumn get category => text()();
  RealColumn get score => real()();
  IntColumn get sampleSize => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

class InterventionStats extends Table {
  TextColumn get interventionId => text()();
  IntColumn get uses => integer().withDefault(const Constant(0))();
  IntColumn get helpful => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{interventionId};
}

class ReflectionEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get promptId => text()();
  TextColumn get answer => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

class AvatarProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get payload => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class OwnedCosmetics extends Table {
  TextColumn get itemId => text()();
  DateTimeColumn get acquiredAt => dateTime()();
  TextColumn get source => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{itemId};
}

class OutfitPresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class CoinLedger extends Table {
  TextColumn get eventId => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  TextColumn get relatedSessionId => text().nullable()();
  TextColumn get sourceType => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{eventId};
}

class StreakStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDay => dateTime().nullable()();
  BoolColumn get graceAvailable =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class MilestoneUnlocks extends Table {
  TextColumn get milestoneId => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{milestoneId};
}

class GameSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get cravingSessionId => text().nullable()();
  TextColumn get source => text()();
  TextColumn get category => text().nullable()();
  TextColumn get subtriggerId => text().nullable()();
  IntColumn get intensityBefore => integer().nullable()();
  IntColumn get intensityAfter => integer().nullable()();
  IntColumn get durationSeconds => integer()();
  TextColumn get mode => text()();
  IntColumn get score => integer()();
  IntColumn get coinsAwarded => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get helpfulness => text().nullable()();
  BoolColumn get cravingReturned => boolean().nullable()();

  /// Which game was played. Everything recorded before a second game existed
  /// was Signal Shift, so this defaults rather than being nullable.
  TextColumn get game => text().withDefault(const Constant('signal_shift'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    UserProfiles,
    CravingLogs,
    LearnedPriors,
    InterventionStats,
    ReflectionEntries,
    AppSettings,
    AvatarProfiles,
    OwnedCosmetics,
    OutfitPresets,
    CoinLedger,
    StreakStates,
    MilestoneUnlocks,
    GameSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.connection);

  AppDatabase.open(DatabaseKey key)
    : super(
        driftDatabase(
          name: key.databaseName,
          native: DriftNativeOptions(
            shareAcrossIsolates: true,
            setup: (database) {
              database
                ..execute('PRAGMA key = "x\'${key.hex}\'"')
                ..execute('PRAGMA cipher_memory_security = ON')
                ..execute('PRAGMA secure_delete = ON')
                ..execute('PRAGMA foreign_keys = ON');
            },
          ),
        ),
      );

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Future migrations are additive and version-gated here. Never drop a
      // user table without an explicit export path.
      if (from > to) {
        throw StateError('Database downgrades are not supported.');
      }
      if (from < 2) {
        await migrator.addColumn(cravingLogs, cravingLogs.planCompleted);
        await migrator.addColumn(cravingLogs, cravingLogs.helpfulStepIndex);
        await migrator.addColumn(cravingLogs, cravingLogs.cravingReturned);
      }
      if (from < 3) {
        await migrator.createTable(avatarProfiles);
        await migrator.createTable(ownedCosmetics);
        await migrator.createTable(outfitPresets);
        await migrator.createTable(coinLedger);
        await migrator.createTable(streakStates);
        await migrator.createTable(milestoneUnlocks);
        await migrator.createTable(gameSessions);
      }
      // Only for databases that already had the table. Coming from below 3 the
      // table is created above with this column already in it.
      if (from >= 3 && from < 4) {
        await migrator.addColumn(gameSessions, gameSessions.game);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA secure_delete = ON');
    },
  );

  Future<String?> cipherVersion() async {
    final rows = await customSelect('PRAGMA cipher_version').get();
    if (rows.isEmpty) return null;
    return rows.first.data.values.firstOrNull?.toString();
  }
}
