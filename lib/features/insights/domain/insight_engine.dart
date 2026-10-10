import 'dart:convert';

import '../../../core/utils/stats.dart';
import '../../../core/utils/stored_enum.dart';
import '../../../data/local/app_database.dart';
import '../../craving_flow/domain/craving_models.dart';
import '../../profile/domain/health_profile.dart';

class InsightCardData {
  const InsightCardData({
    required this.title,
    required this.body,
    required this.numerator,
    required this.denominator,
    required this.kind,
  });

  final String title;
  final String body;
  final int numerator;
  final int denominator;
  final String kind;
}

/// How one plan has gone for this person, counted from their own check-ins.
/// Everything here is a count of what they recorded, never a claim that the
/// plan caused the change.
class PlanPerformance {
  const PlanPerformance({
    required this.planId,
    required this.title,
    required this.uses,
    required this.urgeFell,
    required this.averageChange,
    required this.topStep,
    required this.topStepCount,
  });

  final String planId;
  final String title;
  final int uses;
  final int urgeFell;
  final double? averageChange;
  final String? topStep;
  final int topStepCount;
}

class InsightSnapshot {
  const InsightSnapshot({
    required this.total,
    required this.last30Days,
    required this.ordinaryCount,
    required this.safetyCount,
    required this.categoryCounts,
    required this.timeCounts,
    required this.hungerCount,
    required this.averageUrgeChange,
    required this.cards,
    required this.topSubtrigger,
    required this.helpfulPlanRate,
    required this.helpfulSample,
    required this.partlyHelpedCount,
    required this.planCompletionRate,
    required this.completionSample,
    required this.resistanceRate,
    required this.decisionSample,
    required this.urgeChangeSample,
    required this.planPerformance,
  });

  final int total;
  final int last30Days;

  /// Craving check-ins. Patterns, charts and rates are all built from these.
  final int ordinaryCount;

  /// Hunger, glucose and eating-concern check-ins, which train nothing.
  final int safetyCount;
  final Map<TriggerCategory, int> categoryCounts;
  final Map<DayWindow, int> timeCounts;
  final int hungerCount;
  final double? averageUrgeChange;
  final List<InsightCardData> cards;
  final String? topSubtrigger;
  final double? helpfulPlanRate;
  final int helpfulSample;
  final int partlyHelpedCount;
  final double? planCompletionRate;
  final int completionSample;
  final double? resistanceRate;
  final int decisionSample;
  final int urgeChangeSample;
  final List<PlanPerformance> planPerformance;
}

abstract final class InsightEngine {
  static const minimumPatternSize = 3;
  static const strongerPatternSize = 7;

  static InsightSnapshot build({
    required List<CravingLog> logs,
    required HealthProfile profile,
    required CravingConfig config,
    DateTime? now,
  }) {
    final instant = now ?? DateTime.now();
    final ordinary = logs
        .where((log) => log.safetyExit == SafetyExit.none.name)
        .toList();
    final categoryCounts = <TriggerCategory, int>{
      for (final category in TriggerCategory.values) category: 0,
    };
    final timeCounts = <DayWindow, int>{
      for (final window in DayWindow.values.where(
        (value) => value != DayWindow.varies,
      ))
        window: 0,
    };
    final subtriggerCounts = <String, int>{};
    for (final log in ordinary) {
      final category = storedEnum(TriggerCategory.values, log.category);
      if (category != null) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
      final window = dayWindowFor(log.completedAt);
      timeCounts[window] = (timeCounts[window] ?? 0) + 1;
      if (log.subtriggerId != null) {
        subtriggerCounts[log.subtriggerId!] =
            (subtriggerCounts[log.subtriggerId!] ?? 0) + 1;
      }
    }

    final changes = ordinary
        .where((log) => log.intensityAfter != null)
        .map((log) => (log.intensityAfter! - log.intensityBefore).toDouble())
        .toList();
    final learnableOutcomes = ordinary
        .where((log) => !log.nonLearnable && log.outcome != null)
        .toList();
    // "The urge fell, but I still need another strategy" is the answer people
    // give when a plan half worked. Counting it as helpful inflates the one
    // number that says whether the plans are any good, so it is counted apart.
    final helped = learnableOutcomes
        .where(
          (log) =>
              log.outcome == CravingOutcome.helped.name ||
              log.outcome == CravingOutcome.resistedCraving.name,
        )
        .length;
    final partlyHelped = learnableOutcomes
        .where((log) => log.outcome == CravingOutcome.partlyHelped.name)
        .length;
    final completionLogs = ordinary
        .where((log) => !log.nonLearnable && log.planCompleted != null)
        .toList();
    final completedPlans = completionLogs
        .where((log) => log.planCompleted == true)
        .length;
    final decisionLogs = ordinary
        .where((log) => !log.nonLearnable && log.outcome != null)
        .toList();
    final resisted = decisionLogs
        .where(
          (log) =>
              log.outcome == CravingOutcome.resistedCraving.name ||
              log.outcome == CravingOutcome.helped.name ||
              log.outcome == CravingOutcome.choseSomethingElse.name,
        )
        .length;
    final topId = subtriggerCounts.entries.isEmpty
        ? null
        : (subtriggerCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;
    final topLabel = topId == null
        ? null
        : config.subtriggers
              .where((item) => item.id == topId)
              .firstOrNull
              ?.label;

    final planLogs = <String, List<CravingLog>>{};
    for (final log in ordinary) {
      if (log.planId == null || log.nonLearnable) continue;
      planLogs.putIfAbsent(log.planId!, () => <CravingLog>[]).add(log);
    }
    final planPerformance = <PlanPerformance>[];
    planLogs.forEach((planId, entries) {
      final rated = entries.where((log) => log.intensityAfter != null).toList();
      final stepCounts = <int, int>{};
      for (final log in entries) {
        final index = log.helpfulStepIndex;
        if (index == null || index < 0) continue;
        stepCounts[index] = (stepCounts[index] ?? 0) + 1;
      }
      var topIndex = -1;
      var topCount = 0;
      stepCounts.forEach((index, count) {
        if (count > topCount) {
          topIndex = index;
          topCount = count;
        }
      });
      final steps = config.interventions[planId]?.steps ?? const <String>[];
      planPerformance.add(
        PlanPerformance(
          planId: planId,
          title: config.interventions[planId]?.title ?? planId,
          uses: entries.length,
          urgeFell: rated
              .where((log) => log.intensityAfter! < log.intensityBefore)
              .length,
          averageChange: rated.isEmpty
              ? null
              : Stats.mean(
                  rated.map((log) => log.intensityAfter! - log.intensityBefore),
                ),
          topStep: topIndex >= 0 && topIndex < steps.length
              ? steps[topIndex]
              : null,
          topStepCount: topCount,
        ),
      );
    });
    planPerformance.sort((a, b) {
      final byUses = b.uses.compareTo(a.uses);
      if (byUses != 0) return byUses;
      return (a.averageChange ?? 0).compareTo(b.averageChange ?? 0);
    });

    final cards = <InsightCardData>[];
    if (ordinary.length >= minimumPatternSize && topId != null) {
      final count = subtriggerCounts[topId]!;
      cards.add(
        InsightCardData(
          title: 'A detail that repeats',
          body: count >= strongerPatternSize
              ? '$topLabel has appeared often enough to be a pattern worth planning around.'
              : '$topLabel is appearing more than other details so far. More check-ins may change this.',
          numerator: count,
          denominator: ordinary.length,
          kind: 'trigger',
        ),
      );
    }

    if (profile.hasWearOffHunger) {
      final windowLogs = ordinary.where((log) {
        final window = dayWindowFor(log.completedAt);
        return profile.medications.any(
          (medication) =>
              medication.effects.contains(MedicationEffect.hungerAsWearsOff) &&
              (medication.wearOffWindow == DayWindow.varies ||
                  medication.wearOffWindow == window),
        );
      }).toList();
      final bodyOrRebound = windowLogs
          .where(
            (log) =>
                log.category == TriggerCategory.physiological.name ||
                log.subtriggerId == 'medication_rebound' ||
                _contextTags(log).contains('medication_transition'),
          )
          .length;
      if (windowLogs.length >= minimumPatternSize) {
        cards.add(
          InsightCardData(
            title: 'Your reported medication transition',
            body:
                '$bodyOrRebound of ${windowLogs.length} check-ins in your usual wear-off window involved a body need or medication-transition cue. This is an association in your entries, not proof that medication caused any one craving.',
            numerator: bodyOrRebound,
            denominator: windowLogs.length,
            kind: 'medication',
          ),
        );
      }
    }

    final tiredLogs = ordinary
        .where((log) => _contextTags(log).contains('tired'))
        .toList();
    if (tiredLogs.length >= minimumPatternSize) {
      final averageTired = Stats.mean(
        tiredLogs.map((log) => log.intensityBefore),
      );
      final otherLogs = ordinary
          .where((log) => !_contextTags(log).contains('tired'))
          .toList();
      final comparison = otherLogs.isEmpty
          ? null
          : Stats.mean(otherLogs.map((log) => log.intensityBefore));
      cards.add(
        InsightCardData(
          title: 'Tired moments',
          body: comparison == null
              ? 'Tired was present in ${tiredLogs.length} check-ins. The average starting urge was ${averageTired.toStringAsFixed(1)}.'
              : 'Starting urges averaged ${averageTired.toStringAsFixed(1)} when tired and ${comparison.toStringAsFixed(1)} in other recorded contexts. This is descriptive, not causal.',
          numerator: tiredLogs.length,
          denominator: ordinary.length,
          kind: 'context',
        ),
      );
    }

    return InsightSnapshot(
      total: logs.length,
      last30Days: logs
          .where((log) => instant.difference(log.completedAt).inDays < 30)
          .length,
      ordinaryCount: ordinary.length,
      safetyCount: logs.length - ordinary.length,
      categoryCounts: categoryCounts,
      timeCounts: timeCounts,
      hungerCount: logs.where((log) => log.hungry == true).length,
      averageUrgeChange: changes.isEmpty ? null : Stats.mean(changes),
      urgeChangeSample: changes.length,
      cards: cards,
      topSubtrigger: topLabel,
      helpfulPlanRate: learnableOutcomes.isEmpty
          ? null
          : helped / learnableOutcomes.length,
      helpfulSample: learnableOutcomes.length,
      partlyHelpedCount: partlyHelped,
      planCompletionRate: completionLogs.isEmpty
          ? null
          : completedPlans / completionLogs.length,
      completionSample: completionLogs.length,
      resistanceRate: decisionLogs.isEmpty
          ? null
          : resisted / decisionLogs.length,
      decisionSample: decisionLogs.length,
      planPerformance: planPerformance,
    );
  }

  static Set<String> _contextTags(CravingLog log) {
    return (jsonDecode(log.contextJson) as List<Object?>)
        .whereType<String>()
        .toSet();
  }
}
