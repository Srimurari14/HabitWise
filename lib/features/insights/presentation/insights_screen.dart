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
                        label: 'last 30 days',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: '${snapshot.hungerCount}',
                        label: 'hunger-first plans',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        value: snapshot.averageUrgeChange == null
                            ? '—'
                            : snapshot.averageUrgeChange!.toStringAsFixed(1),
                        label: 'average urge change',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: snapshot.helpfulPlanRate == null
                            ? '—'
                            : '${(snapshot.helpfulPlanRate! * 100).round()}%',
                        label: 'plans felt helpful',
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
                        label: 'primary plans completed',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: snapshot.resistanceRate == null
                            ? '—'
                            : '${(snapshot.resistanceRate! * 100).round()}%',
                        label: 'moved past or redirected',
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
                if (snapshot.total < InsightEngine.minimumPatternSize)
                  EmptyState(
                    icon: Icons.auto_graph_rounded,
                    title: 'Still gathering your baseline',
                    message:
                        '${InsightEngine.minimumPatternSize - snapshot.total} more check-in(s) will unlock the first descriptive pattern. Nothing is inferred yet.',
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
                                    value: snapshot.total == 0
                                        ? 0
                                        : entry.value / snapshot.total,
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label),
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
