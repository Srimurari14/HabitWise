import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../../craving_flow/domain/craving_models.dart';
import '../../craving_flow/domain/medical_rules.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all';
  String _range = 'all';

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
          final filtered = _applyFilter(_applyRange(items));
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
                // Filters only appear once there is something to filter.
                if (items.isNotEmpty) ...<Widget>[
                  DropdownMenu<String>(
                    initialSelection: _filter,
                    label: const Text('Show'),
                    expandedInsets: EdgeInsets.zero,
                    onSelected: (value) =>
                        setState(() => _filter = value ?? 'all'),
                    dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: 'all', label: 'All check-ins'),
                      DropdownMenuEntry(value: 'hunger', label: 'Hunger'),
                      DropdownMenuEntry(value: 'body', label: 'Body need'),
                      DropdownMenuEntry(value: 'emotion', label: 'Emotional'),
                      DropdownMenuEntry(value: 'habit', label: 'Habit loop'),
                      DropdownMenuEntry(
                        value: 'environment',
                        label: 'Environment',
                      ),
                      DropdownMenuEntry(value: 'sensory', label: 'Sensory'),
                      DropdownMenuEntry(
                        value: 'games',
                        label: 'Signal Shift only',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownMenu<String>(
                    initialSelection: _range,
                    label: const Text('When'),
                    expandedInsets: EdgeInsets.zero,
                    onSelected: (value) =>
                        setState(() => _range = value ?? 'all'),
                    dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                      DropdownMenuEntry(value: 'all', label: 'All time'),
                      DropdownMenuEntry(value: '7', label: 'Last 7 days'),
                      DropdownMenuEntry(value: '30', label: 'Last 30 days'),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                if (filtered.isEmpty)
                  EmptyState(
                    icon: Icons.history_rounded,
                    title: items.isEmpty
                        ? 'No check-ins yet'
                        : 'Nothing matches this filter',
                    message: items.isEmpty
                        ? 'Your check-ins will appear here. Start one from the Home tab whenever you want.'
                        : 'Try a different filter or time range.',
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
                        ref,
                        filtered[index],
                        config?.subtriggers
                            .where(
                              (item) => item.id == filtered[index].subtriggerId,
                            )
                            .firstOrNull
                            ?.label,
                        config?.interventions[filtered[index].planId]?.steps,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                if (games.isNotEmpty) ...<Widget>[
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

  List<CravingLog> _applyRange(List<CravingLog> items) {
    final days = int.tryParse(_range);
    if (days == null) return items;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return items.where((item) => item.completedAt.isAfter(cutoff)).toList();
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
      'environment' =>
        items
            .where(
              (item) => item.category == TriggerCategory.environmental.name,
            )
            .toList(),
      'sensory' =>
        items
            .where((item) => item.category == TriggerCategory.sensory.name)
            .toList(),
      'games' => const <CravingLog>[],
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

  /// The second plan the app chose for this detail and showed collapsed on the
  /// plan screen. People open this sheet after a plan did not hold, so the plan
  /// they were not given is the one useful thing to put in front of them.
  static InterventionDefinition? _otherPlanFor(WidgetRef ref, CravingLog log) {
    if (log.safetyExit != 'none' || log.subtriggerId == null) return null;
    // If they said no step helped, the second plan for this detail is usually
    // the same advice reworded, so putting it here reads as not listening.
    if ((log.helpfulStepIndex ?? 0) < 0) return null;
    final config = ref.read(cravingConfigProvider).value;
    final profile = ref.read(profileProvider).value;
    if (config == null || profile == null) return null;
    SubtriggerDefinition? subtrigger;
    for (final item in config.subtriggers) {
      if (item.id == log.subtriggerId) subtrigger = item;
    }
    if (subtrigger == null) return null;
    final chosen = const MedicalRulesEngine().choosePlans(
      subtrigger: subtrigger,
      config: config,
      profile: profile,
    );
    final other = chosen.primary.id == log.planId
        ? chosen.backup
        : chosen.primary;
    return other?.id == log.planId ? null : other;
  }

  static Future<void> _showDetails(
    BuildContext context,
    WidgetRef ref,
    CravingLog log,
    String? subtriggerLabel,
    List<String>? planSteps,
  ) {
    final type = log.cravingType == null
        ? null
        : CravingType.values.byName(log.cravingType!);
    final category = log.category == null
        ? null
        : TriggerCategory.values.byName(log.category!);
    final tags = (jsonDecode(log.contextJson) as List<Object?>)
        .whereType<String>();
    final otherPlan = _otherPlanFor(ref, log);
    final repeat =
        log.safetyExit == 'none' &&
            log.cravingType != null &&
            log.category != null &&
            log.subtriggerId != null
        ? CravingRepeat(
            type: CravingType.values.byName(log.cravingType!),
            category: TriggerCategory.values.byName(log.category!),
            subtriggerId: log.subtriggerId!,
          )
        : null;
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
                  label: 'Urge',
                  value:
                      '${log.intensityBefore} before, ${log.intensityAfter} after',
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
                      : (planSteps != null &&
                            log.helpfulStepIndex! < planSteps.length)
                      ? planSteps[log.helpfulStepIndex!]
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
              if (otherPlan != null) ...<Widget>[
                const SizedBox(height: 18),
                HabitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Also offered for this detail',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        otherPlan.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(otherPlan.whyLine),
                      const SizedBox(height: 12),
                      for (
                        var index = 0;
                        index < otherPlan.steps.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('${index + 1}. ${otherPlan.steps[index]}'),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.pop(context);
                    router.push('/craving', extra: repeat);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    repeat == null
                        ? 'Start a check-in'
                        : 'Same trigger, new check-in',
                  ),
                ),
              ),
              if (repeat != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'It asks the safety question again, then goes straight to '
                  'the plan.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete this check-in?'),
                        content: const Text(
                          'It is removed from your history and from the '
                          'patterns the app notices. Coins you already earned '
                          'stay. This cannot be undone.',
                        ),
                        actions: <Widget>[
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Keep it'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !context.mounted) return;
                    await ref.read(repositoryProvider).deleteLog(log.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete this check-in'),
                ),
              ),
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

  /// What actually happened, which is what people scan a list for.
  static String? _result(CravingLog log) {
    final before = log.intensityBefore;
    final after = log.intensityAfter;
    if (after != null && log.safetyExit == 'none') {
      final movement = after < before
          ? 'Urge $before to $after'
          : after > before
          ? 'Urge rose $before to $after'
          : 'Urge stayed at $before';
      return movement;
    }
    if (log.hungry == true) return 'Ate instead';
    if (log.safetyExit != 'none') return 'Safety plan';
    return null;
  }

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
        category?.label ?? subtriggerLabel,
      ].whereType<String>().join(' • '),
      badge: _result(log),
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
