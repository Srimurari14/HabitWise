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
      // The human character was replaced by the blob mascot, so anything
      // equipped or owned under the old ids is mapped across rather than left
      // pointing at an item that no longer exists.
      await _migrateToMascot(catalog);
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

  static const _mascotMigration = <String, String?>{
    'skin_porcelain': 'body_cloud',
    'skin_sand': 'body_sun',
    'skin_honey': 'body_violet',
    'skin_bronze': 'body_ember',
    'skin_espresso': 'body_ink',
    'expression_ready': 'face_happy',
    'expression_focus': 'face_focused',
    // Eyes and the human clothes have no blob equivalent yet. They are
    // dropped rather than silently equipped as something invisible.
    'scarf_lavender': 'scarf_red',
    'eyes_kind': null,
    'eyes_star': null,
    'top_cream': null,
    'top_coral': null,
    'bottom_night': null,
    'shoes_cloud': null,
    'shoes_spark': null,
    // Dropped when the wardrobe was rebuilt from the mascot renders. Nothing
    // in the new set is close enough to count as the same item, so these are
    // refunded rather than swapped.
    'hat_frog': null,
    'hat_wizard': null,
    'hat_astronaut': null,
    'hat_pirate': null,
    'outfit_hoodie_cream': null,
    'outfit_jacket_red': null,
    'outfit_hoodie_green': null,
    'outfit_hoodie_black': null,
    'outfit_spacesuit': null,
    'outfit_denim': null,
    'outfit_tee_bag': null,
    'shoes_sneaker_purple': null,
    'shoes_canvas_red': null,
    'shoes_runner_green': null,
    'shoes_boot_black': null,
    'shoes_runner_orange': null,
    'shoes_slipon_blue': null,
    'shoes_hightop_purple': null,
    'pet_cat': null,
    'pet_penguin': null,
    'pet_chick': null,
    'pet_sprout': null,
    'pet_robot': null,
    'pet_cloud': null,
    'pet_star': null,
    // Three slots nothing in the app ever drew, and a milestone item that was
    // never in the catalogue at all. Sold or granted, they did nothing.
    'trail_comet': null,
    'celebration_confetti': null,
    'background_dawn': null,
    'back_wings': null,
  };

  /// What the dropped items cost. The catalogue no longer lists them, so their
  /// price has to live somewhere for the refund to be honest.
  static const _refundPrices = <String, int>{
    'hat_frog': 90,
    'hat_wizard': 120,
    'hat_astronaut': 150,
    'hat_pirate': 120,
    'outfit_hoodie_cream': 75,
    'outfit_jacket_red': 90,
    'outfit_hoodie_green': 75,
    'outfit_hoodie_black': 75,
    'outfit_spacesuit': 150,
    'outfit_denim': 90,
    'outfit_tee_bag': 75,
    'shoes_sneaker_purple': 50,
    'shoes_canvas_red': 50,
    'shoes_runner_green': 50,
    'shoes_boot_black': 65,
    'shoes_runner_orange': 50,
    'shoes_slipon_blue': 50,
    'shoes_hightop_purple': 65,
    'pet_cat': 200,
    'pet_penguin': 200,
    'pet_chick': 160,
    'pet_sprout': 160,
    'pet_robot': 240,
    'pet_cloud': 200,
    'pet_star': 240,
    'trail_comet': 120,
    'background_dawn': 75,
  };

  /// Rewrites the saved profile and the owned list from the old character's
  /// item ids. Anything paid for that has no replacement is refunded, because
  /// losing a purchase to an art change is not the player's problem.
  Future<void> _migrateToMascot(CosmeticCatalog catalog) async {
    final owned = await database.select(database.ownedCosmetics).get();
    var refund = 0;
    for (final row in owned) {
      if (!_mascotMigration.containsKey(row.itemId)) continue;
      final replacement = _mascotMigration[row.itemId];
      await (database.delete(
        database.ownedCosmetics,
      )..where((table) => table.itemId.equals(row.itemId))).go();
      if (replacement != null) {
        await database
            .into(database.ownedCosmetics)
            .insert(
              OwnedCosmeticsCompanion.insert(
                itemId: replacement,
                acquiredAt: row.acquiredAt,
                source: row.source,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      } else if (row.source == 'purchase') {
        refund +=
            catalog.byId(row.itemId)?.price ?? _refundPrices[row.itemId] ?? 0;
      }
    }
    if (refund > 0) {
      await database
          .into(database.coinLedger)
          .insert(
            CoinLedgerCompanion.insert(
              eventId: 'mascot-refund',
              createdAt: DateTime.now(),
              amount: refund,
              reason: 'Refund for items the new character cannot wear',
              sourceType: 'refund',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }

    final profile = await (database.select(
      database.avatarProfiles,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (profile == null) return;
    final avatar = AvatarProfileData.decode(profile.payload);
    final equipped = <String, String>{};
    var changed = false;
    avatar.equipped.forEach((slot, itemId) {
      if (!_mascotMigration.containsKey(itemId)) {
        equipped[slot] = itemId;
        return;
      }
      changed = true;
      final replacement = _mascotMigration[itemId];
      if (replacement != null) equipped[slot] = replacement;
    });
    if (!changed) return;
    equipped.putIfAbsent('baseColor', () => 'body_violet');
    equipped.putIfAbsent('expression', () => 'face_happy');
    await database
        .into(database.avatarProfiles)
        .insertOnConflictUpdate(
          AvatarProfilesCompanion.insert(
            id: const Value(1),
            payload: AvatarProfileData(
              name: avatar.name,
              equipped: equipped,
              preferences: avatar.preferences,
            ).encode(),
            updatedAt: DateTime.now(),
          ),
        );
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

  /// Takes an accessory off. Required slots such as tops and shoes always keep
  /// an item, so those are refused.
  Future<bool> unequip(CosmeticSlot slot) async {
    if (!slot.canBeRemoved) return false;
    final avatar = await getAvatar();
    if (!avatar.equipped.containsKey(slot.name)) return false;
    final equipped = Map<String, String>.of(avatar.equipped)..remove(slot.name);
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
      // Stopping early is often the right thing: during a craving the person
      // played until they felt steady enough to stop, which is what the game
      // is for. Half the reward for half the session, rather than treating it
      // as a failed run. The halfway mark is also what stops the daily cap
      // being farmed, since a session has to be genuinely played to count.
      final half = durationSeconds * 2 >= launch.durationMinutes * 60;
      if (completed || half) {
        // Finishing always pays something: a craving session is never a test
        // a person can fail. Playing well widens the bonus on top.
        var requested = launch.source == GameSource.recommended
            ? (3 + score ~/ 180).clamp(3, 12)
            : (1 + score ~/ 250).clamp(1, 3);
        if (!completed) requested = (requested / 2).ceil();
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
              game: Value(launch.kind.key),
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
