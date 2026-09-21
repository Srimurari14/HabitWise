import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/data/local/app_database.dart';
import 'package:habitwise/features/craving_flow/application/craving_controller.dart';
import 'package:habitwise/features/craving_flow/domain/craving_models.dart';
import 'package:habitwise/features/craving_flow/domain/medical_rules.dart';
import 'package:habitwise/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'hunger-first controller path saves a protected check-in end to end',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      final controller = container.read(cravingFlowControllerProvider.notifier);

      await controller.answerSafety(const SafetyAnswers(physicalHunger: true));
      expect(
        container.read(cravingFlowControllerProvider).step,
        CravingFlowStep.plan,
      );
      expect(
        container.read(cravingFlowControllerProvider).session.plan?.id,
        'permission-to-eat',
      );
      controller.beginFollowUp();
      await controller.save();

      final state = container.read(cravingFlowControllerProvider);
      expect(state.step, CravingFlowStep.complete);
      expect(state.session.safetyExit, SafetyExit.genuineHunger);
      final logs = await database.select(database.cravingLogs).get();
      expect(logs, hasLength(1));
      expect(logs.single.nonLearnable, isTrue);

      container.dispose();
      await database.close();
    },
  );

  test('ordinary flow builds a transparent primary and backup plan', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    final controller = container.read(cravingFlowControllerProvider.notifier);

    await controller.answerSafety(const SafetyAnswers(physicalHunger: false));
    await controller.selectType(CravingType.sweet);
    controller.selectCategory(TriggerCategory.environmental);
    await controller.selectSubtrigger('food_visible');

    final state = container.read(cravingFlowControllerProvider);
    expect(state.session.plan?.id, 'change-the-cue');
    expect(state.backupPlan?.id, 'choice-reset');
    expect(state.driverExplanation?.title, 'Food is visible or nearby');
    expect(state.driverExplanation?.signals, isNotEmpty);
    expect(state.session.plan?.id, isNot('intentional-enjoyment'));

    container.dispose();
    await database.close();
  });
}
