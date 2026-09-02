import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local/app_database.dart';
import 'data/repositories/gamification_repository.dart';
import 'data/repositories/habit_repository.dart';
import 'features/craving_flow/domain/config_loader.dart';
import 'features/craving_flow/domain/craving_models.dart';
import 'features/gamification/domain/avatar_models.dart';
import 'features/profile/domain/health_profile.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('databaseProvider must be overridden at startup.'),
);

final repositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(ref.watch(databaseProvider)),
);

final gamificationRepositoryProvider = Provider<GamificationRepository>(
  (ref) => GamificationRepository(ref.watch(databaseProvider)),
);

final cosmeticCatalogProvider = FutureProvider<CosmeticCatalog>((ref) async {
  final source = await rootBundle.loadString('assets/config/cosmetics_v1.json');
  return CosmeticCatalog.decode(source);
});

final gamificationReadyProvider = FutureProvider<void>((ref) async {
  final catalog = await ref.watch(cosmeticCatalogProvider.future);
  await ref.watch(gamificationRepositoryProvider).initialize(catalog);
});

final avatarProvider = StreamProvider<AvatarProfileData>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchAvatar(),
);

final ownedCosmeticsProvider = StreamProvider<List<OwnedCosmetic>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchOwned(),
);

final outfitPresetsProvider = StreamProvider<List<OutfitPreset>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchOutfits(),
);

final coinLedgerProvider = StreamProvider<List<CoinLedgerData>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchLedger(),
);

final coinBalanceProvider = Provider<int>((ref) {
  final rows = ref.watch(coinLedgerProvider).value ?? const <CoinLedgerData>[];
  return rows.fold<int>(0, (total, row) => total + row.amount);
});

final streakProvider = StreamProvider<StreakState?>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchStreak(),
);

final gameSessionsProvider = StreamProvider<List<GameSession>>(
  (ref) => ref.watch(gamificationRepositoryProvider).watchGameSessions(),
);

final cravingConfigProvider = FutureProvider<CravingConfig>(
  (ref) => ConfigLoader(rootBundle).load(),
);

final profileProvider = StreamProvider<HealthProfile>(
  (ref) => ref.watch(repositoryProvider).watchProfile(),
);

final logsProvider = StreamProvider<List<CravingLog>>(
  (ref) => ref.watch(repositoryProvider).watchLogs(),
);

final weeklyActivityProvider = Provider<int>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));
  final logs = ref.watch(logsProvider).value ?? const <CravingLog>[];
  return logs
      .where((log) => !log.completedAt.isBefore(weekStart))
      .map(
        (log) => DateTime(
          log.completedAt.year,
          log.completedAt.month,
          log.completedAt.day,
        ),
      )
      .toSet()
      .length;
});
