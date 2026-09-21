import '../../craving_flow/domain/craving_models.dart';
import '../../profile/domain/health_profile.dart';
import 'avatar_models.dart';

class GameRecommendationEngine {
  const GameRecommendationEngine();

  static const _suitableTriggers = <String>{
    'understimulated',
    'sensory_specific',
    'oral_stimulation',
    'food_visible',
    'someone_eating',
    'screen_content',
    'easy_access',
    'time_of_day',
    'after_task',
    'screen_pairing',
    'procrastination',
    'automatic_route',
    'celebration_reward',
    'low_mood',
    'stress_pressure',
    'anxiety_activation',
  };

  GameRecommendation? recommend({
    required CravingSession session,
    required HealthProfile profile,
    required GamePreferences preferences,
    DateTime? now,
  }) {
    if (!preferences.recommendationsEnabled ||
        session.safetyExit != SafetyExit.none ||
        session.hungry == true ||
        session.category == TriggerCategory.physiological ||
        session.subtriggerId == null ||
        !_suitableTriggers.contains(session.subtriggerId) ||
        profile.edSafetyMode ||
        profile.glucoseSafetyEnabled) {
      return null;
    }

    final currentTime = now ?? DateTime.now();
    final window = dayWindowFor(currentTime);
    final late = window == DayWindow.evening || window == DayWindow.overnight;
    if (late &&
        (profile.contexts.contains(HealthContext.bipolarMood) ||
            profile.contexts.contains(HealthContext.sleepCondition))) {
      return null;
    }

    final calm =
        preferences.calmMode ||
        preferences.reducedMotion ||
        profile.contexts.contains(HealthContext.anxiety) ||
        profile.contexts.contains(HealthContext.chronicPainFatigue) ||
        session.subtriggerId == 'anxiety_activation' ||
        session.subtriggerId == 'stress_pressure';
    final duration = profile.contexts.contains(HealthContext.chronicPainFatigue)
        ? 3
        : session.intensityBefore >= 8
        ? 5
        : 3;
    final reason = switch (session.subtriggerId) {
      'understimulated' =>
        'You identified boredom or understimulation. A short, absorbing task may give your attention a different source of novelty while the urge changes.',
      'procrastination' =>
        'You identified task avoidance. A timed reset may interrupt the escape loop before you return to one small next action.',
      'food_visible' || 'someone_eating' || 'screen_content' =>
        'A cue around you appears to be holding your attention. A brief competing visual task may help that cue lose intensity.',
      'screen_pairing' || 'time_of_day' || 'after_task' || 'automatic_route' =>
        'This looks like a learned moment or sequence. A short alternative routine may help loosen the automatic link.',
      'sensory_specific' || 'oral_stimulation' =>
        'You identified a stimulation need. This game offers movement, color, and rapid feedback as one non-food option.',
      'anxiety_activation' || 'stress_pressure' =>
        'Your system may be looking for relief. Calm mode keeps the pace predictable and gives your attention one manageable target.',
      'low_mood' =>
        'A small, time-limited activity may offer activation and immediate feedback without asking much of you.',
      _ =>
        'A brief attention shift may help create space between the cue and your next decision.',
    };
    return GameRecommendation(
      reason: reason,
      durationMinutes: duration,
      mode: preferences.reducedMotion
          ? GameMode.reducedMotion
          : calm
          ? GameMode.calm
          : GameMode.standard,
      safetyNote:
          'This is an optional attention tool, not a test of willpower. Stop if it raises distress, dizziness, agitation, pain, or fatigue.',
    );
  }
}
