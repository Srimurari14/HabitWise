import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/data/local/app_database.dart';
import 'package:habitwise/data/repositories/habit_repository.dart';
import 'package:habitwise/features/craving_flow/domain/craving_models.dart';
import 'package:habitwise/features/profile/domain/health_profile.dart';

void main() {
  late AppDatabase database;
  late HabitRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = HabitRepository(database);
  });

  tearDown(() => database.close());

  test(
    'saves a session and updates learnable weights transactionally',
    () async {
      const plan = InterventionDefinition(
        id: 'test-plan',
        title: 'Test plan',
        minutes: 2,
        whyLine: 'Test',
        steps: <String>['One'],
        swaps: <String>[],
        tags: <String>{},
        nonLearnable: false,
        timerAllowed: true,
      );
      await repository.commitSession(
        CravingSession(
          id: 'session-1',
          startedAt: DateTime(2026, 7, 18, 12),
          type: CravingType.sweet,
          category: TriggerCategory.emotional,
          subtriggerId: 'stress_pressure',
          plan: plan,
          outcome: CravingOutcome.helped,
          intensityAfter: 3,
          planCompleted: true,
          helpfulStepIndex: 0,
          cravingReturned: false,
        ),
      );
      final logs = await repository.getLogs();
      expect(logs, hasLength(1));
      expect(logs.single.planCompleted, isTrue);
      expect(logs.single.helpfulStepIndex, 0);
      expect(logs.single.cravingReturned, isFalse);
      expect(
        await database.select(database.learnedPriors).get(),
        hasLength(TriggerCategory.values.length),
      );
      final stats = await database.select(database.interventionStats).get();
      expect(stats.single.uses, 1);
      expect(stats.single.helpful, 1);
    },
  );

  test(
    'permission plans cannot train even if passed with a malformed flag',
    () async {
      const plan = InterventionDefinition(
        id: 'permission-to-eat',
        title: 'Permission',
        minutes: 0,
        whyLine: 'Eat',
        steps: <String>['Eat'],
        swaps: <String>[],
        tags: <String>{},
        nonLearnable: false,
        timerAllowed: false,
      );
      await repository.commitSession(
        CravingSession(
          id: 'session-2',
          startedAt: DateTime(2026, 7, 18, 12),
          type: CravingType.salty,
          category: TriggerCategory.physiological,
          plan: plan,
          outcome: CravingOutcome.ateCravedFood,
          hungry: true,
          safetyExit: SafetyExit.genuineHunger,
        ),
      );
      expect(await database.select(database.learnedPriors).get(), isEmpty);
      final log = (await repository.getLogs()).single;
      expect(log.nonLearnable, isTrue);
    },
  );

  test(
    'eating-concern safety mode persists through routine profile editing',
    () async {
      await repository.saveProfile(
        HealthProfile.empty().copyWith(edSafetyMode: true),
      );
      await repository.saveProfile(
        HealthProfile.empty().copyWith(edSafetyMode: false),
      );
      expect((await repository.getProfile()).edSafetyMode, isTrue);
    },
  );
}
