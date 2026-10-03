import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../../craving_flow/domain/craving_models.dart';
import '../../profile/domain/health_profile.dart';
import '../domain/insight_engine.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider).value ?? const <CravingLog>[];
    final games =
        ref.watch(gameSessionsProvider).value ?? const <GameSession>[];
    final profile = ref.watch(profileProvider).value ?? HealthProfile.empty();
    final config = ref.watch(cravingConfigProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: config.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load insights: $error')),
        data: (value) {
          if (logs.isEmpty) {
            return PageFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  EmptyState(
                    icon: Icons.insights_rounded,
                    title: 'Nothing to show yet',
                    message:
                        'This page fills in from your own check-ins. After a '
                        'few of them it shows which details repeat, what time '
                        'of day they happen, and which plans moved your urge.',
                  ),
                ],
              ),
            );
          }
          final snapshot = InsightEngine.build(
            logs: logs,
            profile: profile,
            config: value,
          );
          final gameChecks = games
              .where(
                (game) =>
                    game.completed &&
                    game.source == 'recommended' &&
                    game.intensityBefore != null &&
                    game.intensityAfter != null,
              )
              .toList();
          return PageFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Patterns, carefully',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'HabitWise waits for repeated observations, shows sample sizes, and avoids causal claims.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        value: '${snapshot.last30Days}',
                        label: 'check-ins, last 30 days',
                        note: 'cravings, hunger and safety together',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: '${snapshot.hungerCount}',
                        label: 'ended in food, by plan',
                        note: 'of ${snapshot.total} check-ins, all time',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        value: _urgeValue(snapshot.averageUrgeChange),
                        label: _urgeLabel(snapshot.averageUrgeChange),
                        note: snapshot.urgeChangeSample == 0
                            ? 'nothing rated yet'
                            : 'across ${snapshot.urgeChangeSample} rated '
                                  'cravings',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: snapshot.helpfulPlanRate == null
                            ? '—'
                            : '${(snapshot.helpfulPlanRate! * 100).round()}%',
                        label: 'plans that worked',
                        note: snapshot.helpfulSample == 0
                            ? 'no plans rated yet'
                            : 'of ${snapshot.helpfulSample} rated, plus '
                                  '${snapshot.partlyHelpedCount} that half '
                                  'worked',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        value: snapshot.planCompletionRate == null
                            ? '—'
                            : '${(snapshot.planCompletionRate! * 100).round()}%',
                        label: 'plans finished',
                        note: snapshot.completionSample == 0
                            ? 'none answered yet'
                            : 'of ${snapshot.completionSample} answered',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: snapshot.resistanceRate == null
                            ? '—'
                            : '${(snapshot.resistanceRate! * 100).round()}%',
                        label: 'moved past or redirected',
                        note: snapshot.decisionSample == 0
                            ? 'nothing recorded yet'
                            : 'of ${snapshot.decisionSample} cravings',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const SectionHeader('Closest needs'),
                const SizedBox(height: 12),
                HabitCard(
                  child: SizedBox(
                    height: 230,
                    child: _CategoryChart(counts: snapshot.categoryCounts),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Safety and permission-only check-ins are excluded from learned trigger patterns.',
                ),
                const SizedBox(height: 28),
                const SectionHeader('What may be worth noticing'),
                const SizedBox(height: 12),
                if (snapshot.ordinaryCount < InsightEngine.minimumPatternSize)
                  EmptyState(
                    icon: Icons.auto_graph_rounded,
                    title: 'Still gathering your baseline',
                    message: _baselineMessage(
                      InsightEngine.minimumPatternSize - snapshot.ordinaryCount,
                    ),
                  )
                else if (snapshot.cards.isEmpty)
                  const EmptyState(
                    icon: Icons.blur_on_rounded,
                    title: 'No stable pattern yet',
                    message:
                        'Your entries are varied. That is useful information too; HabitWise will keep watching without forcing a story.',
                  )
                else
                  for (final card in snapshot.cards) ...<Widget>[
                    _InsightCard(data: card),
                    const SizedBox(height: 12),
                  ],
                if (gameChecks.length >= 3) ...<Widget>[
                  const SizedBox(height: 16),
                  _GameInsightCard(games: gameChecks),
                ],
                const SizedBox(height: 28),
                const SectionHeader('What has worked for you'),
                const SizedBox(height: 12),
                if (snapshot.planPerformance.isEmpty)
                  const EmptyState(
                    icon: Icons.checklist_rounded,
                    title: 'No plans rated yet',
                    message:
                        'Once you have finished a few check-ins this lists the '
                        'plans you were given, how often the urge fell '
                        'afterwards, and the step you marked as the one that '
                        'helped.',
                  )
                else
                  for (final plan in snapshot.planPerformance.take(4)) ...[
                    _PlanPerformanceCard(plan: plan),
                    const SizedBox(height: 10),
                  ],
                if (snapshot.planPerformance.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  const Text(
                    'These are counts from your own check-ins. A plan can be '
                    'ahead simply because it is the one you were given most.',
                  ),
                ],
                const SizedBox(height: 28),
                const SectionHeader('Time of day'),
                const SizedBox(height: 12),
                HabitCard(
                  child: Column(
                    children: snapshot.timeCounts.entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 88,
                                  child: Text(entry.key.label),
                                ),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(20),
                                    // These counts only cover craving
                                    // check-ins, so the bars have to be drawn
                                    // against the same set.
                                    value: snapshot.ordinaryCount == 0
                                        ? 0
                                        : entry.value / snapshot.ordinaryCount,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 24,
                                  child: Text('${entry.value}'),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Insights support reflection only. They do not diagnose conditions, predict emergencies, or replace advice from a clinician.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GameInsightCard extends StatelessWidget {
  const _GameInsightCard({required this.games});
  final List<GameSession> games;

  @override
  Widget build(BuildContext context) {
    final lower = games
        .where((game) => game.intensityAfter! < game.intensityBefore!)
        .length;
    final helpful = games
        .where(
          (game) =>
              game.helpfulness == 'helpful' || game.helpfulness == 'somewhat',
        )
        .length;
    final enoughForPattern = games.length >= 7;
    return HabitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.sports_esports_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Signal Shift pattern',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            enoughForPattern
                ? 'Across ${games.length} recommended sessions, the urge was lower afterward in $lower and the attention shift felt at least somewhat helpful in $helpful.'
                : 'Early signal only: the urge was lower afterward in $lower of ${games.length} sessions. More check-ins are needed before treating this as a repeatable pattern.',
          ),
          const SizedBox(height: 8),
          const Text(
            'This is a within-session observation, not proof that the game caused the change.',
          ),
        ],
      ),
    );
  }
}

/// A fall in the urge is good news, so it is shown as a drop rather than as a
/// negative number with no unit.
/// Patterns are built from craving check-ins only, so the countdown has to
/// count those and not every check-in.
String _baselineMessage(int remaining) {
  final checkIns = remaining == 1 ? 'craving check-in' : 'craving check-ins';
  return '$remaining more $checkIns will unlock the first pattern. Hunger and '
      'safety check-ins are not counted here, because they never train what '
      'the app suggests.';
}

String _urgeValue(double? change) {
  if (change == null) return '—';
  final rounded = double.parse(change.abs().toStringAsFixed(1));
  if (rounded == 0) return '0';
  return rounded.toStringAsFixed(1);
}

String _urgeLabel(double? change) {
  if (change == null) return 'average urge change';
  if (change < -0.05) return 'average urge drop';
  if (change > 0.05) return 'average urge rise';
  return 'average urge change';
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label, this.note});
  final String value;
  final String label;

  /// The sample behind the number. The page promises sample sizes, so a
  /// percentage without one does not belong here.
  final String? note;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label),
          if (note != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              note!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanPerformanceCard extends StatelessWidget {
  const _PlanPerformanceCard({required this.plan});
  final PlanPerformance plan;

  @override
  Widget build(BuildContext context) {
    final change = plan.averageChange;
    final rated = plan.urgeFell;
    return HabitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(plan.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            plan.uses == 1
                ? 'Used once.'
                : 'Used ${plan.uses} times. The urge fell afterwards '
                      '$rated of those.',
          ),
          if (change != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              change < -0.05
                  ? 'Average drop of ${change.abs().toStringAsFixed(1)} points.'
                  : change > 0.05
                  ? 'Average rise of ${change.toStringAsFixed(1)} points.'
                  : 'The urge averaged no change.',
            ),
          ],
          if (plan.topStep != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Step you picked as the most helpful, '
              '${plan.topStepCount == 1 ? 'once' : '${plan.topStepCount} times'}:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(plan.topStep!),
          ],
        ],
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.counts});
  final Map<TriggerCategory, int> counts;

  @override
  Widget build(BuildContext context) {
    final maximum = counts.values.fold<int>(
      1,
      (current, value) => value > current ? value : current,
    );
    return BarChart(
      BarChartData(
        maxY: (maximum + 1).toDouble(),
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= TriggerCategory.values.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(switch (TriggerCategory.values[index]) {
                    TriggerCategory.physiological => 'Body',
                    TriggerCategory.emotional => 'Emotion',
                    TriggerCategory.environmental => 'Place',
                    TriggerCategory.habitual => 'Habit',
                    TriggerCategory.sensory => 'Sense',
                  }, style: Theme.of(context).textTheme.labelSmall),
                );
              },
            ),
          ),
        ),
        barGroups: List<BarChartGroupData>.generate(
          TriggerCategory.values.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: <BarChartRodData>[
              BarChartRodData(
                toY: (counts[TriggerCategory.values[index]] ?? 0).toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});
  final InsightCardData data;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                _icon(data.kind),
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.body),
          const SizedBox(height: 6),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('See the numbers'),
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${data.numerator} of ${data.denominator} relevant check-ins',
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _icon(String kind) => switch (kind) {
    'medication' => Icons.schedule_rounded,
    'context' => Icons.bedtime_outlined,
    _ => Icons.pattern_rounded,
  };
}
