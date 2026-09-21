import 'package:flutter_test/flutter_test.dart';
import 'package:habitwise/features/craving_flow/domain/craving_models.dart';
import 'package:habitwise/features/gamification/domain/avatar_models.dart';
import 'package:habitwise/features/gamification/domain/game_recommendation_engine.dart';
import 'package:habitwise/features/profile/domain/health_profile.dart';

void main() {
  const engine = GameRecommendationEngine();

  CravingSession session({
    String trigger = 'understimulated',
    TriggerCategory category = TriggerCategory.sensory,
    bool hungry = false,
  }) => CravingSession(
    id: 'session',
    startedAt: DateTime(2026, 7, 27, 14),
    type: CravingType.sweet,
    category: category,
    subtriggerId: trigger,
    hungry: hungry,
  );

  test('recommends a short attention shift for a suitable cue', () {
    final result = engine.recommend(
      session: session(),
      profile: HealthProfile.empty(),
      preferences: const GamePreferences(),
      now: DateTime(2026, 7, 27, 14),
    );
    expect(result, isNotNull);
    expect(result!.reason, contains('understimulation'));
    expect(result.durationMinutes, 3);
  });

  test(
    'never recommends over hunger, physical need, ED, or glucose safety',
    () {
      expect(
        engine.recommend(
          session: session(hungry: true),
          profile: HealthProfile.empty(),
          preferences: const GamePreferences(),
        ),
        isNull,
      );
      expect(
        engine.recommend(
          session: session(category: TriggerCategory.physiological),
          profile: HealthProfile.empty(),
          preferences: const GamePreferences(),
        ),
        isNull,
      );
      expect(
        engine.recommend(
          session: session(),
          profile: HealthProfile.empty().copyWith(edSafetyMode: true),
          preferences: const GamePreferences(),
        ),
        isNull,
      );
      expect(
        engine.recommend(
          session: session(),
          profile: HealthProfile.empty().copyWith(glucoseSafetyEnabled: true),
          preferences: const GamePreferences(),
        ),
        isNull,
      );
    },
  );

  test('uses calm mode for anxiety and avoids late bipolar activation', () {
    final anxiety = HealthProfile.empty().copyWith(
      contexts: <HealthContext>{HealthContext.anxiety},
    );
    expect(
      engine
          .recommend(
            session: session(trigger: 'anxiety_activation'),
            profile: anxiety,
            preferences: const GamePreferences(),
            now: DateTime(2026, 7, 27, 14),
          )!
          .mode,
      GameMode.calm,
    );
    final bipolar = HealthProfile.empty().copyWith(
      contexts: <HealthContext>{HealthContext.bipolarMood},
    );
    expect(
      engine.recommend(
        session: session(),
        profile: bipolar,
        preferences: const GamePreferences(),
        now: DateTime(2026, 7, 27, 22),
      ),
      isNull,
    );
  });

  test('ADHD context alone does not force a recommendation', () {
    final profile = HealthProfile.empty().copyWith(
      contexts: <HealthContext>{HealthContext.adhd},
    );
    expect(
      engine.recommend(
        session: session(trigger: 'lonely_disconnected'),
        profile: profile,
        preferences: const GamePreferences(),
      ),
      isNull,
    );
  });
}
