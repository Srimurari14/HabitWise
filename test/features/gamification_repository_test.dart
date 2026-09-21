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

  test('game reward is capped at thirty coins per day', () async {
    for (var index = 0; index < 6; index++) {
      await repository.recordGame(
        launch: const SignalShiftLaunch(
          source: GameSource.recommended,
          durationMinutes: 3,
          mode: GameMode.standard,
          cravingSessionId: 'craving',
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
    final gameRewards = await (database.select(
      database.coinLedger,
    )..where((table) => table.sourceType.equals('game'))).get();
    expect(gameRewards.fold<int>(0, (total, row) => total + row.amount), 30);
  });
}
