import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/features/craving_flow/domain/config_loader.dart';
import 'package:habitwise/features/craving_flow/domain/craving_models.dart';
import 'package:habitwise/features/craving_flow/domain/medical_rules.dart';
import 'package:habitwise/features/profile/domain/health_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const rules = MedicalRulesEngine();

  test('physical hunger short-circuits to a non-learning food plan', () {
    final decision = rules.runSafetyPrecheck(
      profile: HealthProfile.empty(),
      answers: const SafetyAnswers(physicalHunger: true),
    );
    expect(decision.exit, SafetyExit.genuineHunger);
    expect(decision.planId, 'permission-to-eat');
  });

  test('glucose warning outranks hunger when the safety check is enabled', () {
    final profile = HealthProfile.empty().copyWith(glucoseSafetyEnabled: true);
    final decision = rules.runSafetyPrecheck(
      profile: profile,
      answers: const SafetyAnswers(
        physicalHunger: true,
        glucoseWarningSigns: true,
        hasPersonalGlucosePlan: true,
      ),
    );
    expect(decision.exit, SafetyExit.urgentGlucose);
    expect(decision.planId, 'glucose-safety-exit');
  });

  test(
    'reported wear-off window increases body ranking without overriding answers',
    () async {
      final config = await ConfigLoader(rootBundle).load();
      final profile = HealthProfile.empty().copyWith(
        medications: const <MedicationContext>[
          MedicationContext(
            id: 'test',
            label: 'ADHD medication',
            effects: <MedicationEffect>{MedicationEffect.hungerAsWearsOff},
            usualWindow: DayWindow.morning,
            wearOffWindow: DayWindow.afternoon,
          ),
        ],
      );
      final ranked = rules.rankCategories(
        type: CravingType.crunchy,
        config: config,
        profile: profile,
        learnedScores: const <TriggerCategory, double>{},
        userAnswer: TriggerCategory.sensory,
        now: DateTime(2026, 7, 18, 15),
      );
      expect(ranked.first.category, TriggerCategory.sensory);
      final body = ranked.firstWhere(
        (item) => item.category == TriggerCategory.physiological,
      );
      expect(body.sources, contains(EvidenceSource.profileContext));
    },
  );

  test(
    'eating-concern mode filters resistance plans and disables safe timers',
    () async {
      final config = await ConfigLoader(rootBundle).load();
      final profile = HealthProfile.empty().copyWith(edSafetyMode: true);
      final plans = rules.filterPlans(
        candidates: <InterventionDefinition>[
          config.interventions['two-minute-downshift']!,
          config.interventions['sensory-match']!,
          const InterventionDefinition(
            id: 'safe-support',
            title: 'Safe support',
            minutes: 2,
            whyLine: 'Support',
            steps: <String>['Connect'],
            swaps: <String>[],
            tags: <String>{'support'},
            nonLearnable: true,
            timerAllowed: true,
          ),
        ],
        profile: profile,
      );
      expect(plans.any((plan) => plan.id == 'two-minute-downshift'), isFalse);
      expect(plans.any((plan) => plan.id == 'sensory-match'), isFalse);
      expect(plans.single.id, 'safe-support');
      expect(plans.single.timerAllowed, isFalse);
    },
  );
}
