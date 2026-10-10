import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/data/local/app_database.dart';
import 'package:habitwise/data/repositories/gamification_repository.dart';
import 'package:habitwise/features/gamification/domain/avatar_models.dart';

void main() {
  late AppDatabase database;
  late GamificationRepository repository;
  late CosmeticCatalog catalog;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = GamificationRepository(database);
    catalog = const CosmeticCatalog(<CosmeticItem>[
      CosmeticItem(
        id: 'base_plum',
        name: 'Plum',
        slot: CosmeticSlot.baseColor,
        rarity: CosmeticRarity.starter,
        price: 0,
        style: 'plum',
        starter: true,
      ),
      CosmeticItem(
        id: 'scarf_test',
        name: 'Test scarf',
        slot: CosmeticSlot.scarf,
        rarity: CosmeticRarity.common,
        price: 50,
        style: 'test',
      ),
    ]);
    await repository.initialize(catalog);
  });

  tearDown(() => database.close());

  test('starter ownership persists and purchase cannot go negative', () async {
    expect(
      (await database.select(database.ownedCosmetics).get()).map(
        (row) => row.itemId,
      ),
      contains('base_plum'),
    );
    expect(await repository.purchase(catalog.items.last), isFalse);
    expect(await repository.balance(), 0);
    expect(await database.select(database.coinLedger).get(), isEmpty);
  });

  test(
    'purchase is atomic and idempotent, then item can be equipped',
    () async {
      await database
          .into(database.coinLedger)
          .insert(
            CoinLedgerCompanion.insert(
              eventId: 'seed',
              createdAt: DateTime.now(),
              amount: 100,
              reason: 'test',
              sourceType: 'test',
            ),
          );
      final item = catalog.items.last;
      expect(await repository.purchase(item), isTrue);
      expect(await repository.purchase(item), isTrue);
      expect(await repository.balance(), 50);
      expect(await repository.equip(item), isTrue);
      expect((await repository.getAvatar()).equipped['scarf'], item.id);
    },
  );

  Future<SignalShiftResult> playFullSession({
    required String cravingSessionId,
    GameKind kind = GameKind.signalShift,
  }) {
    return repository.recordGame(
      launch: SignalShiftLaunch(
        kind: kind,
        source: GameSource.recommended,
        durationMinutes: 3,
        mode: GameMode.standard,
        cravingSessionId: cravingSessionId,
        category: 'sensory',
        subtriggerId: 'understimulated',
        intensityBefore: 7,
      ),
      startedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      durationSeconds: 180,
      score: 2000,
      completed: true,
      intensityAfter: 4,
      helpfulness: GameHelpfulness.helpful,
    );
  }

  Future<int> gameCoins() async {
    final rewards = await (database.select(
      database.coinLedger,
    )..where((table) => table.sourceType.equals('game'))).get();
    return rewards.fold<int>(0, (total, row) => total + row.amount);
  }

  test('replaying the same game in one check-in pays only once', () async {
    final first = await playFullSession(cravingSessionId: 'craving');
    final second = await playFullSession(cravingSessionId: 'craving');
    expect(first.coinsEarned, 12);
    expect(second.coinsEarned, 0);
    expect(second.block, GameRewardBlock.alreadyPlayed);
    // The run is still recorded. It just does not pay.
    expect(second.score, 2000);
    expect(await gameCoins(), 12);
  });

  test('switching to the other game in one check-in pays again', () async {
    await playFullSession(cravingSessionId: 'craving');
    final other = await playFullSession(
      cravingSessionId: 'craving',
      kind: GameKind.focusStack,
    );
    expect(other.coinsEarned, 12);
    expect(other.block, GameRewardBlock.none);
    expect(await gameCoins(), 24);
  });

  test('game reward is capped per day across check-ins', () async {
    // Three check-ins, both games in each, is 72 at full score. The daily
    // ceiling is what stops it there.
    for (final craving in <String>['one', 'two', 'three']) {
      await playFullSession(cravingSessionId: craving);
      await playFullSession(
        cravingSessionId: craving,
        kind: GameKind.focusStack,
      );
    }
    expect(await gameCoins(), dailyGameCoinCap);
  });

  test('stopping before halfway pays nothing and says so', () async {
    final result = await repository.recordGame(
      launch: const SignalShiftLaunch(
        source: GameSource.recommended,
        durationMinutes: 3,
        mode: GameMode.standard,
        cravingSessionId: 'craving',
      ),
      startedAt: DateTime.now().subtract(const Duration(seconds: 20)),
      durationSeconds: 20,
      score: 40,
      completed: false,
    );
    expect(result.coinsEarned, 0);
    expect(result.block, GameRewardBlock.stoppedEarly);
    expect(result.noCoinsReason, contains('halfway'));
  });
}
