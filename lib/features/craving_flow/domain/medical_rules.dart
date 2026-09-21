import 'dart:math' as math;

import '../../profile/domain/health_profile.dart';
import 'craving_models.dart';

enum EvidenceSource {
  userAnswer,
  safetyRule,
  learnedHistory,
  profileContext,
  basePrior,
}

class SafetyAnswers {
  const SafetyAnswers({
    required this.physicalHunger,
    this.glucoseWarningSigns = false,
    this.hasPersonalGlucosePlan = false,
    this.restrictionOrCompensation = false,
  });

  final bool physicalHunger;
  final bool glucoseWarningSigns;
  final bool hasPersonalGlucosePlan;
  final bool restrictionOrCompensation;
}

class SafetyDecision {
  const SafetyDecision({
    required this.exit,
    required this.title,
    required this.message,
    required this.planId,
  });

  const SafetyDecision.continueFlow()
    : exit = SafetyExit.none,
      title = '',
      message = '',
      planId = null;

  final SafetyExit exit;
  final String title;
  final String message;
  final String? planId;

  bool get shouldExit => exit != SafetyExit.none;
}

class RankedCategory {
  const RankedCategory({
    required this.category,
    required this.score,
    required this.sources,
    required this.reason,
  });

  final TriggerCategory category;
  final double score;
  final Set<EvidenceSource> sources;
  final String reason;
}

class MedicalRulesEngine {
  const MedicalRulesEngine();

  SafetyDecision runSafetyPrecheck({
    required HealthProfile profile,
    required SafetyAnswers answers,
  }) {
    if (profile.glucoseSafetyEnabled && answers.glucoseWarningSigns) {
      return SafetyDecision(
        exit: SafetyExit.urgentGlucose,
        title: 'Use your glucose safety plan now',
        message: answers.hasPersonalGlucosePlan
            ? 'Pause HabitWise and follow the plan provided by your care team. '
                  'If symptoms are severe or not improving, seek urgent medical help.'
            : 'Pause HabitWise. Check your glucose if you can and get help from '
                  'someone nearby or urgent medical services if symptoms are severe. '
                  'HabitWise cannot create a glucose treatment plan.',
        planId: 'glucose-safety-exit',
      );
    }
    if (profile.edSafetyMode && answers.restrictionOrCompensation) {
      return const SafetyDecision(
        exit: SafetyExit.eatingConcernSupport,
        title: 'Food and support come first',
        message:
            'This moment may be connected to restriction or compensation. '
            'Skip delay tools. Choose nourishment and reach out to a trusted person '
            'or your care team if support would help.',
        planId: 'permission-and-support',
      );
    }
    if (answers.physicalHunger) {
      return const SafetyDecision(
        exit: SafetyExit.genuineHunger,
        title: 'Hunger is a reason to eat',
        message:
            'Choose a satisfying meal or snack you can access. You do not need '
            'to earn food or wait out hunger. You can include the food you want.',
        planId: 'permission-to-eat',
      );
    }
    return const SafetyDecision.continueFlow();
  }

  List<RankedCategory> rankCategories({
    required CravingType type,
    required CravingConfig config,
    required HealthProfile profile,
    required Map<TriggerCategory, double> learnedScores,
    TriggerCategory? userAnswer,
    DateTime? now,
  }) {
    final instant = now ?? DateTime.now();
    final base = config.typePriors[type]!;
    final output = <RankedCategory>[];
    for (final category in TriggerCategory.values) {
      var score = base[category] ?? 0;
      final sources = <EvidenceSource>{EvidenceSource.basePrior};
      final reasons = <String>[];

      final learned = learnedScores[category];
      if (learned != null) {
        score = score * 0.65 + learned * 0.35;
        sources.add(EvidenceSource.learnedHistory);
        reasons.add('your recent check-ins');
      }

      if (category == TriggerCategory.physiological &&
          profile.wearOffMatches(instant)) {
        score += 0.22;
        sources.add(EvidenceSource.profileContext);
        reasons.add('your reported medication wear-off window');
      }
      if (category == TriggerCategory.emotional &&
          profile.contexts.intersection(const <HealthContext>{
            HealthContext.anxiety,
            HealthContext.depression,
            HealthContext.bipolarMood,
          }).isNotEmpty) {
        score += 0.06;
        sources.add(EvidenceSource.profileContext);
        reasons.add('an optional mood or stress context');
      }
      if (category == TriggerCategory.sensory &&
          profile.contexts.contains(HealthContext.sensoryNeeds)) {
        score += 0.1;
        sources.add(EvidenceSource.profileContext);
        reasons.add('your sensory preferences');
      }
      if (userAnswer == category) {
        score += 2;
        sources.add(EvidenceSource.userAnswer);
        reasons.insert(0, 'what you selected just now');
      }
      output.add(
        RankedCategory(
          category: category,
          score: math.max(0, score),
          sources: sources,
          reason: reasons.isEmpty
              ? 'a starting pattern for this kind of craving'
              : reasons.join(' and '),
        ),
      );
    }
    output.sort((a, b) => b.score.compareTo(a.score));
    return output;
  }

  List<InterventionDefinition> filterPlans({
    required Iterable<InterventionDefinition> candidates,
    required HealthProfile profile,
  }) {
    final unique = <String, InterventionDefinition>{};
    for (final candidate in candidates) {
      if (profile.edSafetyMode &&
          candidate.tags.intersection(const <String>{
            'delay',
            'restriction',
            'portion-control',
            'resist',
          }).isNotEmpty) {
        continue;
      }
      if (profile.contexts.contains(HealthContext.gastrointestinal) &&
          candidate.tags.contains('high-volume-food')) {
        continue;
      }
      unique[candidate.id] = profile.edSafetyMode
          ? candidate.copyWith(timerAllowed: false)
          : candidate;
    }
    return unique.values.toList();
  }

  List<SubtriggerDefinition> reorderSubtriggers({
    required Iterable<SubtriggerDefinition> candidates,
    required HealthProfile profile,
    DateTime? now,
  }) {
    final ordered = candidates.toList();
    final instant = now ?? DateTime.now();
    ordered.sort((a, b) {
      int priority(SubtriggerDefinition item) {
        if (item.id == 'medication_rebound' &&
            profile.wearOffMatches(instant)) {
          return 3;
        }
        if (item.id == 'sensory_specific' &&
            profile.contexts.contains(HealthContext.sensoryNeeds)) {
          return 2;
        }
        if (item.id == 'under_fueled' && profile.hasWearOffHunger) return 1;
        return 0;
      }

      return priority(b).compareTo(priority(a));
    });
    return ordered;
  }
}
