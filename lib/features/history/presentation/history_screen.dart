import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../../craving_flow/domain/craving_models.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(logsProvider);
    final games =
        ref.watch(gameSessionsProvider).value ?? const <GameSession>[];
    final config = ref.watch(cravingConfigProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load history: $error')),
        data: (items) {
          final filtered = _applyFilter(items);
          return PageFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your check-ins',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                const Text('A neutral record of what you noticed and tried.'),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'hunger', label: Text('Hunger')),
                      ButtonSegment(value: 'body', label: Text('Body')),
                      ButtonSegment(value: 'emotion', label: Text('Emotion')),
                      ButtonSegment(value: 'habit', label: Text('Habit')),
                    ],
                    selected: <String>{_filter},
                    showSelectedIcon: false,
                    onSelectionChanged: (values) =>
                        setState(() => _filter = values.first),
                  ),
                ),
                const SizedBox(height: 20),
                if (filtered.isEmpty)
                  const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'No check-ins here yet',
                    message:
                        'Try another filter, or use the Home tab when you want to log a craving.',
                  )
                else
                  for (
                    var index = 0;
                    index < filtered.length;
                    index++
                  ) ...<Widget>[
                    if (index == 0 ||
                        !_sameDay(
                          filtered[index - 1].completedAt,
                          filtered[index].completedAt,
                        )) ...<Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 10),
                        child: Text(
                          _dateHeading(filtered[index].completedAt),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                    _HistoryCard(
                      log: filtered[index],
                      subtriggerLabel: config?.subtriggers
                          .where(
                            (item) => item.id == filtered[index].subtriggerId,
                          )
                          .firstOrNull
                          ?.label,
                      onTap: () => _showDetails(
                        context,
                        filtered[index],
                        config?.subtriggers
                            .where(
                              (item) => item.id == filtered[index].subtriggerId,
                            )
                            .firstOrNull
                            ?.label,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                if (_filter == 'all' && games.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 24),
                  const SectionHeader('Signal Shift sessions'),
                  const SizedBox(height: 6),
                  const Text(
                    'Game outcomes are shown separately from craving-plan outcomes.',
                  ),
                  const SizedBox(height: 12),
                  for (final game in games.take(12)) ...<Widget>[
                    _GameHistoryCard(game: game),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<CravingLog> _applyFilter(List<CravingLog> items) {
    return switch (_filter) {
      'hunger' => items.where((item) => item.hungry == true).toList(),
      'body' =>
        items
            .where(
              (item) => item.category == TriggerCategory.physiological.name,
            )
            .toList(),
      'emotion' =>
        items
            .where((item) => item.category == TriggerCategory.emotional.name)
            .toList(),
      'habit' =>
        items
            .where((item) => item.category == TriggerCategory.habitual.name)
            .toList(),
      _ => items,
    };
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateHeading(DateTime date) {
    final now = DateTime.now();
    if (_sameDay(date, now)) return 'Today';
    if (_sameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('EEEE, MMMM d').format(date);
  }

  static Future<void> _showDetails(
    BuildContext context,
    CravingLog log,
    String? subtriggerLabel,
  ) {
    final type = log.cravingType == null
        ? null
        : CravingType.values.byName(log.cravingType!);
    final category = log.category == null
        ? null
        : TriggerCategory.values.byName(log.category!);
    final tags = (jsonDecode(log.contextJson) as List<Object?>)
        .whereType<String>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Check-in details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(DateFormat('EEEE, MMM d • h:mm a').format(log.completedAt)),
              const SizedBox(height: 20),
              _DetailRow(
                label: 'Craving',
                value: type?.label ?? 'Safety check-in',
              ),
              _DetailRow(
                label: 'Closest need',
                value: category?.label ?? 'Direct care',
              ),
              if (subtriggerLabel != null)
                _DetailRow(label: 'Detail', value: subtriggerLabel),
              _DetailRow(
                label: 'Plan',
                value: log.planTitle ?? 'No plan recorded',
              ),
              if (log.intensityAfter != null)
                _DetailRow(
                  label: 'Urge reference',
                  value:
                      '${log.intensityBefore} before • ${log.intensityAfter} after',
                ),
              if (log.outcome != null)
                _DetailRow(
                  label: 'Outcome',
                  value: CravingOutcome.values.byName(log.outcome!).label,
                ),
              if (log.planCompleted != null)
                _DetailRow(
                  label: 'Primary plan completed',
                  value: log.planCompleted! ? 'Yes' : 'Not fully',
                ),
              if (log.helpfulStepIndex != null)
                _DetailRow(
                  label: 'Most helpful action',
                  value: log.helpfulStepIndex! < 0
                      ? 'No single step'
                      : 'Step ${log.helpfulStepIndex! + 1}',
                ),
              if (log.cravingReturned != null)
                _DetailRow(
                  label: 'Craving returned',
                  value: log.cravingReturned! ? 'Yes' : 'No',
                ),
              if (tags.isNotEmpty)
                _DetailRow(
                  label: 'Context',
                  value: tags.map((tag) => tag.replaceAll('_', ' ')).join(', '),
                ),
              if (log.nonLearnable) ...<Widget>[
                const SizedBox(height: 8),
                HabitCard(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'This safety or permission plan did not train recommendations.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GameHistoryCard extends StatelessWidget {
  const _GameHistoryCard({required this.game});
  final GameSession game;

  @override
  Widget build(BuildContext context) {
    final change = game.intensityBefore != null && game.intensityAfter != null
        ? game.intensityBefore! - game.intensityAfter!
        : null;
    return ChoiceTile(
      title: game.source == 'recommended'
          ? 'Recommended Signal Shift'
          : 'Signal Shift practice',
      subtitle: <String>[
        DateFormat('MMM d • h:mm a').format(game.completedAt),
        'score ${game.score}',
        '+${game.coinsAwarded} coins',
        if (change != null)
          change > 0
              ? 'urge fell by $change'
              : change == 0
              ? 'urge unchanged'
              : 'urge rose by ${-change}',
      ].join(' • '),
      icon: game.completed
          ? Icons.sports_esports_rounded
          : Icons.stop_circle_outlined,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Signal Shift details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                _DetailRow(label: 'Score', value: '${game.score}'),
                _DetailRow(
                  label: 'Time played',
                  value:
                      '${game.durationSeconds ~/ 60}m ${game.durationSeconds % 60}s',
                ),
                _DetailRow(
                  label: 'Mode',
                  value: game.mode.replaceAll(
                    'reducedMotion',
                    'reduced motion',
                  ),
                ),
                if (game.intensityBefore != null && game.intensityAfter != null)
                  _DetailRow(
                    label: 'Urge reference',
                    value:
                        '${game.intensityBefore} before • ${game.intensityAfter} after',
                  ),
                if (game.helpfulness != null)
                  _DetailRow(
                    label: 'Attention shift',
                    value: game.helpfulness!.replaceAll(
                      'notHelpful',
                      'not helpful',
                    ),
                  ),
                const Text(
                  'This record describes what happened; it does not prove the game caused a change.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.log,
    required this.subtriggerLabel,
    required this.onTap,
  });

  final CravingLog log;
  final String? subtriggerLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = log.cravingType == null
        ? null
        : CravingType.values.byName(log.cravingType!);
    final category = log.category == null
        ? null
        : TriggerCategory.values.byName(log.category!);
    return ChoiceTile(
      title:
          type?.label ??
          (log.hungry == true ? 'Hunger check-in' : 'Safety check-in'),
      subtitle: <String?>[
        DateFormat.jm().format(log.completedAt),
        category?.label,
        subtriggerLabel,
        log.planTitle,
      ].whereType<String>().join(' • '),
      icon: log.hungry == true ? Icons.restaurant_rounded : Icons.route_rounded,
      onTap: onTap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 3),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
