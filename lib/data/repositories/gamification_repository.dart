import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/gamification/domain/avatar_models.dart';
import '../local/app_database.dart';

class GamificationRepository {
  GamificationRepository(this.database);

  final AppDatabase database;
  static const _uuid = Uuid();

  Stream<AvatarProfileData> watchAvatar() {
    return (database.select(
      database.avatarProfiles,
    )..where((table) => table.id.equals(1))).watchSingleOrNull().map(
      (row) => row == null
          ? const AvatarProfileData()
          : AvatarProfileData.decode(row.payload),
    );
  }

  Future<AvatarProfileData> getAvatar() async {
    final row = await (database.select(
      database.avatarProfiles,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    return row == null
        ? const AvatarProfileData()
        : AvatarProfileData.decode(row.payload);
  }

  Future<void> initialize(CosmeticCatalog catalog) async {
    await database.transaction(() async {
      final profile = await (database.select(
        database.avatarProfiles,
      )..where((table) => table.id.equals(1))).getSingleOrNull();
      if (profile == null) {
        const initial = AvatarProfileData();
        await database
            .into(database.avatarProfiles)
            .insert(
              AvatarProfilesCompanion.insert(
                id: const Value(1),
                payload: initial.encode(),
                updatedAt: DateTime.now(),
              ),
            );
      }
      for (final item in catalog.items.where((item) => item.starter)) {
        await database
            .into(database.ownedCosmetics)
            .insert(
              OwnedCosmeticsCompanion.insert(
                itemId: item.id,
                acquiredAt: DateTime.now(),
                source: 'starter',
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await database
          .into(database.streakStates)
          .insert(
            StreakStatesCompanion.insert(id: const Value(1)),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  Future<void> saveAvatar(AvatarProfileData avatar) async {
    await database
        .into(database.avatarProfiles)
        .insertOnConflictUpdate(
          AvatarProfilesCompanion.insert(
            id: const Value(1),
            payload: avatar.encode(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> updatePreferences(GamePreferences preferences) async {
    final avatar = await getAvatar();
    await saveAvatar(avatar.copyWith(preferences: preferences));
  }

  Stream<List<OwnedCosmetic>> watchOwned() {
    return database.select(database.ownedCosmetics).watch();
  }

  Stream<List<OutfitPreset>> watchOutfits() {
    return (database.select(database.outfitPresets)
          ..orderBy(<OrderingTerm Function(OutfitPresets)>[
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<CoinLedgerData>> watchLedger() {
    return (database.select(database.coinLedger)
          ..orderBy(<OrderingTerm Function(CoinLedger)>[
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<StreakState?> watchStreak() {
    return (database.select(
      database.streakStates,
    )..where((table) => table.id.equals(1))).watchSingleOrNull();
  }

  Stream<List<GameSession>> watchGameSessions() {
    return (database.select(database.gameSessions)
          ..orderBy(<OrderingTerm Function(GameSessions)>[
            (table) => OrderingTerm.desc(table.completedAt),
          ]))
        .watch();
  }

  Future<int> balance() async {
    final expression = database.coinLedger.amount.sum();
    final row = await (database.selectOnly(
      database.coinLedger,
    )..addColumns(<Expression<Object>>[expression])).getSingle();
    return row.read(expression) ?? 0;
  }

  Future<bool> purchase(CosmeticItem item) async {
    if (item.starter || item.milestone != null) return false;
    return database.transaction(() async {
      final owned = await (database.select(
        database.ownedCosmetics,
      )..where((table) => table.itemId.equals(item.id))).getSingleOrNull();
      if (owned != null) return true;
      final currentBalance = await balance();
      if (currentBalance < item.price) return false;
      final eventId = 'purchase:${item.id}';
      await database
          .into(database.coinLedger)
          .insert(
            CoinLedgerCompanion.insert(
              eventId: eventId,
              createdAt: DateTime.now(),
              amount: -item.price,
              reason: 'Unlocked ${item.name}',
              sourceType: 'purchase',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await database
          .into(database.ownedCosmetics)
          .insert(
            OwnedCosmeticsCompanion.insert(
              itemId: item.id,
              acquiredAt: DateTime.now(),
              source: 'store',
            ),
            mode: InsertMode.insertOrIgnore,
          );
      return true;
    });
  }

  Future<bool> equip(CosmeticItem item) async {
    final owned = await (database.select(
      database.ownedCosmetics,
    )..where((table) => table.itemId.equals(item.id))).getSingleOrNull();
    if (owned == null) return false;
    final avatar = await getAvatar();
    final equipped = Map<String, String>.of(avatar.equipped)
      ..[item.slot.name] = item.id;
    await saveAvatar(avatar.copyWith(equipped: equipped));
    return true;
  }

  Future<void> saveOutfit(String name) async {
    final avatar = await getAvatar();
    await database
        .into(database.outfitPresets)
        .insert(
          OutfitPresetsCompanion.insert(
            id: _uuid.v4(),
            name: name.trim().isEmpty ? 'Saved look' : name.trim(),
            payload: jsonEncode(avatar.equipped),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> wearOutfit(OutfitPreset preset) async {
    final avatar = await getAvatar();
    final decoded = (jsonDecode(preset.payload) as Map<Object?, Object?>).map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
    final owned = (await database.select(database.ownedCosmetics).get())
        .map((row) => row.itemId)
        .toSet();
    decoded.removeWhere((key, value) => !owned.contains(value));
    await saveAvatar(avatar.copyWith(equipped: decoded));
  }

  Future<void> deleteOutfit(String id) async {
    await (database.delete(
      database.outfitPresets,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<SignalShiftResult> recordGame({
    required SignalShiftLaunch launch,
    required DateTime startedAt,
    required int durationSeconds,
    required int score,
    required bool completed,
    int? intensityAfter,
    GameHelpfulness? helpfulness,
  }) async {
    final id = _uuid.v4();
    return database.transaction(() async {
      final now = DateTime.now();
      var reward = 0;
      if (completed) {
        final requested = launch.source == GameSource.recommended
            ? (3 + score ~/ 180).clamp(3, 10)
            : (score ~/ 250).clamp(0, 3);
        final startOfDay = DateTime(now.year, now.month, now.day);
        final tomorrow = startOfDay.add(const Duration(days: 1));
        final dailyRows =
            await (database.select(database.coinLedger)..where(
                  (table) =>
                      table.sourceType.equals('game') &
                      table.createdAt.isBiggerOrEqualValue(startOfDay) &
                      table.createdAt.isSmallerThanValue(tomorrow),
                ))
                .get();
        final awardedToday = dailyRows.fold<int>(
          0,
          (total, row) => total + row.amount,
        );
        reward = requested.clamp(0, (30 - awardedToday).clamp(0, 30));
      }
      await database
          .into(database.gameSessions)
          .insert(
            GameSessionsCompanion.insert(
              id: id,
              startedAt: startedAt,
              completedAt: now,
              cravingSessionId: Value(launch.cravingSessionId),
              source: launch.source.name,
              category: Value(launch.category),
              subtriggerId: Value(launch.subtriggerId),
              intensityBefore: Value(launch.intensityBefore),
              intensityAfter: Value(intensityAfter),
              durationSeconds: durationSeconds,
              mode: launch.mode.name,
              score: score,
              coinsAwarded: Value(reward),
              completed: Value(completed),
              helpfulness: Value(helpfulness?.name),
            ),
          );
      if (reward > 0) {
        await database
            .into(database.coinLedger)
            .insert(
              CoinLedgerCompanion.insert(
                eventId: 'game:$id',
                createdAt: now,
                amount: reward,
                reason: 'Signal Shift session',
                relatedSessionId: Value(id),
                sourceType: 'game',
              ),
            );
      }
      return SignalShiftResult(
        sessionId: id,
        score: score,
        coinsEarned: reward,
        completed: completed,
        intensityAfter: intensityAfter,
        helpfulness: helpfulness,
      );
    });
  }

  Future<void> updateGameFollowUp({
    required String id,
    required int intensityAfter,
    required GameHelpfulness helpfulness,
    bool? cravingReturned,
  }) async {
    await (database.update(
      database.gameSessions,
    )..where((table) => table.id.equals(id))).write(
      GameSessionsCompanion(
        intensityAfter: Value(intensityAfter),
        helpfulness: Value(helpfulness.name),
        cravingReturned: Value(cravingReturned),
      ),
    );
  }
}
