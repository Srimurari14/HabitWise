import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/features/craving_flow/domain/config_loader.dart';
import 'package:habitwise/features/craving_flow/domain/craving_models.dart';
import 'package:habitwise/features/craving_flow/domain/medical_rules.dart';
import 'package:habitwise/features/profile/domain/health_profile.dart';

/// Eating-concern safety mode must never surface delay, resistance,
/// restriction or portion-control plans. The mode cannot be switched off once
/// a person enables it, so it can only be checked here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const rules = MedicalRulesEngine();
  const banned = <String>{'delay', 'restriction', 'portion-control', 'resist'};

  test('eating-concern mode never shows a delay or resistance plan', () async {
    final config = await ConfigLoader(rootBundle).load();
    final profile = HealthProfile.empty().copyWith(edSafetyMode: true);

    for (final subtrigger in config.subtriggers) {
      final chosen = rules.choosePlans(
        subtrigger: subtrigger,
        config: config,
        profile: profile,
      );
      final shown = <InterventionDefinition>[
        chosen.primary,
        if (chosen.backup != null) chosen.backup!,
      ];
      for (final plan in shown) {
        expect(
          plan.tags.intersection(banned),
          isEmpty,
          reason: '${subtrigger.id} offered ${plan.id} in eating-concern mode',
        );
        expect(
          plan.timerAllowed,
          isFalse,
          reason: '${subtrigger.id} offered a timer in eating-concern mode',
        );
      }
    }
  });

  test(
    'ordinary profiles still get a plan and a backup for every path',
    () async {
      final config = await ConfigLoader(rootBundle).load();
      final profile = HealthProfile.empty();

      for (final subtrigger in config.subtriggers) {
        final chosen = rules.choosePlans(
          subtrigger: subtrigger,
          config: config,
          profile: profile,
        );
        expect(
          chosen.backup,
          isNotNull,
          reason: '${subtrigger.id} has no backup',
        );
        expect(
          chosen.backup!.id,
          isNot(chosen.primary.id),
          reason: '${subtrigger.id} repeats the same plan as its backup',
        );
        expect(chosen.primary.id, isNot('intentional-enjoyment'));
      }
    },
  );
}
