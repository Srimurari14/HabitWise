import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/craving_flow/domain/craving_models.dart';
import '../../features/profile/domain/health_profile.dart';
import '../local/app_database.dart';

class HabitRepository {
  HabitRepository(this.database);

  final AppDatabase database;
  static const _uuid = Uuid();
  static const _protectedPlanIds = <String>{
    'permission-to-eat',
    'steady-snack',
    'wear-off-meal',
    'cycle-support',
    'permission-and-support',
    'glucose-safety-exit',
  };

  Stream<HealthProfile> watchProfile() {
    return (database.select(
      database.userProfiles,
    )..where((table) => table.id.equals(1))).watchSingleOrNull().map(
      (row) => row == null
          ? HealthProfile.empty()
          : HealthProfile.decode(row.payload),
    );
  }

  Future<HealthProfile> getProfile() async {
    final row = await (database.select(
      database.userProfiles,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    return row == null
        ? HealthProfile.empty()
        : HealthProfile.decode(row.payload);
  }

  Future<void> saveProfile(HealthProfile profile) async {
    final previous = await getProfile();
    final safeProfile = previous.edSafetyMode && !profile.edSafetyMode
        ? profile.copyWith(edSafetyMode: true)
        : profile;
    await database
        .into(database.userProfiles)
        .insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: const Value(1),
            payload: safeProfile.encode(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Stream<List<CravingLog>> watchLogs() {
    return (database.select(database.cravingLogs)
          ..orderBy(<OrderingTerm Function(CravingLogs)>[
            (table) => OrderingTerm.desc(table.completedAt),
          ]))
        .watch();
  }

  Future<List<CravingLog>> getLogs() {
    return (database.select(database.cravingLogs)
          ..orderBy(<OrderingTerm Function(CravingLogs)>[
            (table) => OrderingTerm.desc(table.completedAt),
          ]))
        .get();
  }

  Future<Map<TriggerCategory, double>> learnedScores(CravingType type) async {
    final rows = await (database.select(
      database.learnedPriors,
    )..where((table) => table.cravingType.equals(type.name))).get();
    return <TriggerCategory, double>{
      for (final row in rows)
        TriggerCategory.values.byName(row.category): row.score,
    };
  }

  Future<void> commitSession(CravingSession session) async {
    final plan = session.plan;
    final planIsProtected =
        plan == null ||
        plan.nonLearnable ||
        _protectedPlanIds.contains(plan.id) ||
        session.safetyExit != SafetyExit.none;
    await database.transaction(() async {
      await database
          .into(database.cravingLogs)
          .insert(
            CravingLogsCompanion.insert(
              id: session.id,
              startedAt: session.startedAt,
              completedAt: DateTime.now(),
              cravingType: Value(session.type?.name),
              category: Value(session.category?.name),
              subtriggerId: Value(session.subtriggerId),
              intensityBefore: session.intensityBefore,
              intensityAfter: Value(session.intensityAfter),
              hungry: Value(session.hungry),
              safetyExit: session.safetyExit.name,
              planId: Value(plan?.id),
              planTitle: Value(plan?.title),
              nonLearnable: Value(planIsProtected),
              outcome: Value(session.outcome?.name),
              planCompleted: Value(session.planCompleted),
              helpfulStepIndex: Value(session.helpfulStepIndex),
              cravingReturned: Value(session.cravingReturned),
              contextJson: Value(jsonEncode(session.contextTags.toList())),
            ),
          );

      if (!planIsProtected &&
          session.type != null &&
          session.category != null &&
          session.outcome != null) {
        await _updateLearnedPriors(session);
        await _updateInterventionStats(session);
      }
      await _updateMomentum(session);
      if (!planIsProtected) {
        await _awardSessionCoins(session);
      }
    });
  }

  Future<void> _awardSessionCoins(CravingSession session) async {
    if (session.planCompleted == true) {
      await _insertCoinEvent(
        eventId: 'craving:${session.id}:plan',
        amount: 6,
        reason: 'Completed a craving plan',
        sessionId: session.id,
      );
    }
    await _insertCoinEvent(
      eventId: 'craving:${session.id}:reflection',
      amount: 2,
      reason: 'Finished the follow-up',
      sessionId: session.id,
    );
    final redirected = <CravingOutcome>{
      CravingOutcome.resistedCraving,
      CravingOutcome.helped,
      CravingOutcome.choseSomethingElse,
    }.contains(session.outcome);
    if (redirected) {
      await _insertCoinEvent(
        eventId: 'craving:${session.id}:redirect',
        amount: 8,
        reason: 'Moved through or redirected a craving',
        sessionId: session.id,
      );
    }
  }

  Future<void> _insertCoinEvent({
    required String eventId,
    required int amount,
    required String reason,
    required String sessionId,
  }) async {
    await database
        .into(database.coinLedger)
        .insert(
          CoinLedgerCompanion.insert(
            eventId: eventId,
            createdAt: DateTime.now(),
            amount: amount,
            reason: reason,
            relatedSessionId: Value(sessionId),
            sourceType: 'craving',
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _updateMomentum(CravingSession session) async {
    final completedAt = DateTime.now();
    final today = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    final existing = await (database.select(
      database.streakStates,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (existing?.lastActiveDay != null) {
      final last = existing!.lastActiveDay!;
      final normalizedLast = DateTime(last.year, last.month, last.day);
      final difference = today.difference(normalizedLast).inDays;
      if (difference <= 0) return;
      final usedGrace = difference == 2 && existing.graceAvailable;
      final continuing = difference == 1 || usedGrace;
      final current = continuing ? existing.currentStreak + 1 : 1;
      await database
          .into(database.streakStates)
          .insertOnConflictUpdate(
            StreakStatesCompanion.insert(
              id: const Value(1),
              currentStreak: Value(current),
              bestStreak: Value(
                current > existing.bestStreak ? current : existing.bestStreak,
              ),
              lastActiveDay: Value(today),
              graceAvailable: Value(usedGrace ? false : true),
            ),
          );
      await _unlockMilestones(current);
      return;
    }
    await database
        .into(database.streakStates)
        .insertOnConflictUpdate(
          StreakStatesCompanion.insert(
            id: const Value(1),
            currentStreak: const Value(1),
            bestStreak: const Value(1),
            lastActiveDay: Value(today),
          ),
        );
    await _unlockMilestones(1);
  }

  Future<void> _unlockMilestones(int streak) async {
    for (final target in <int>[3, 7, 14, 30]) {
      if (streak < target) continue;
      final milestoneId = 'streak_$target';
      final inserted = await database
          .into(database.milestoneUnlocks)
          .insert(
            MilestoneUnlocksCompanion.insert(
              milestoneId: milestoneId,
              unlockedAt: DateTime.now(),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (inserted == 0) continue;
      await database
          .into(database.coinLedger)
          .insert(
            CoinLedgerCompanion.insert(
              eventId: 'milestone:$milestoneId',
              createdAt: DateTime.now(),
              amount: target >= 14 ? 30 : 15,
              reason: '$target-day momentum milestone',
              sourceType: 'milestone',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final cosmeticId = switch (target) {
        7 => 'back_wings',
        14 => 'celebration_confetti',
        _ => null,
      };
      if (cosmeticId != null) {
        await database
            .into(database.ownedCosmetics)
            .insert(
              OwnedCosmeticsCompanion.insert(
                itemId: cosmeticId,
                acquiredAt: DateTime.now(),
                source: milestoneId,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    }
  }

  Future<void> _updateLearnedPriors(CravingSession session) async {
    const alpha = 0.15;
    final type = session.type!;
    final selected = session.category!;
    for (final category in TriggerCategory.values) {
      final key = '${type.name}:${category.name}';
      final existing = await (database.select(
        database.learnedPriors,
      )..where((table) => table.key.equals(key))).getSingleOrNull();
      final oldScore = existing?.score ?? 0.2;
      final observation = category == selected ? 1.0 : 0.0;
      final newScore = oldScore * (1 - alpha) + observation * alpha;
      await database
          .into(database.learnedPriors)
          .insertOnConflictUpdate(
            LearnedPriorsCompanion.insert(
              key: key,
              cravingType: type.name,
              category: category.name,
              score: newScore,
              sampleSize: (existing?.sampleSize ?? 0) + 1,
              updatedAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> _updateInterventionStats(CravingSession session) async {
    final plan = session.plan!;
    final existing =
        await (database.select(database.interventionStats)
              ..where((table) => table.interventionId.equals(plan.id)))
            .getSingleOrNull();
    final helped =
        session.outcome == CravingOutcome.helped ||
        session.outcome == CravingOutcome.partlyHelped;
    await database
        .into(database.interventionStats)
        .insertOnConflictUpdate(
          InterventionStatsCompanion.insert(
            interventionId: plan.id,
            uses: Value((existing?.uses ?? 0) + 1),
            helpful: Value((existing?.helpful ?? 0) + (helped ? 1 : 0)),
            lastUsedAt: DateTime.now(),
          ),
        );
  }

  Future<void> addReflection({
    required String promptId,
    required String answer,
  }) async {
    await database
        .into(database.reflectionEntries)
        .insert(
          ReflectionEntriesCompanion.insert(
            id: _uuid.v4(),
            createdAt: DateTime.now(),
            promptId: promptId,
            answer: answer,
          ),
        );
  }

  Future<Map<String, Object?>> exportAll() async {
    final profile = await getProfile();
    final logs = await getLogs();
    final priors = await database.select(database.learnedPriors).get();
    final stats = await database.select(database.interventionStats).get();
    final reflections = await database.select(database.reflectionEntries).get();
    final avatar = await database.select(database.avatarProfiles).get();
    final cosmetics = await database.select(database.ownedCosmetics).get();
    final outfits = await database.select(database.outfitPresets).get();
    final ledger = await database.select(database.coinLedger).get();
    final streaks = await database.select(database.streakStates).get();
    final milestones = await database.select(database.milestoneUnlocks).get();
    final games = await database.select(database.gameSessions).get();
    return <String, Object?>{
      'schemaVersion': database.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': profile.toJson(),
      'cravingLogs': logs.map((row) => row.toJson()).toList(),
      'learnedPriors': priors.map((row) => row.toJson()).toList(),
      'interventionStats': stats.map((row) => row.toJson()).toList(),
      'reflections': reflections.map((row) => row.toJson()).toList(),
      'avatar': avatar.map((row) => row.toJson()).toList(),
      'ownedCosmetics': cosmetics.map((row) => row.toJson()).toList(),
      'outfitPresets': outfits.map((row) => row.toJson()).toList(),
      'coinLedger': ledger.map((row) => row.toJson()).toList(),
      'streaks': streaks.map((row) => row.toJson()).toList(),
      'milestones': milestones.map((row) => row.toJson()).toList(),
      'gameSessions': games.map((row) => row.toJson()).toList(),
    };
  }

  /// Removes a single check-in. Coins already earned stay in the ledger: they
  /// were earned by what the person did, not by the record of it.
  Future<void> deleteLog(String id) async {
    await (database.delete(
      database.cravingLogs,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> deleteAllData() async {
    await database.transaction(() async {
      await database.delete(database.gameSessions).go();
      await database.delete(database.milestoneUnlocks).go();
      await database.delete(database.streakStates).go();
      await database.delete(database.coinLedger).go();
      await database.delete(database.outfitPresets).go();
      await database.delete(database.ownedCosmetics).go();
      await database.delete(database.avatarProfiles).go();
      await database.delete(database.reflectionEntries).go();
      await database.delete(database.interventionStats).go();
      await database.delete(database.learnedPriors).go();
      await database.delete(database.cravingLogs).go();
      await database.delete(database.appSettings).go();
      await database.delete(database.userProfiles).go();
    });
    await database.customStatement('VACUUM');
  }
}
