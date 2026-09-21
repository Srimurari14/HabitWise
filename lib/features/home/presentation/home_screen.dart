import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../../profile/domain/health_profile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(logsProvider).value ?? const <CravingLog>[];
    final profile = ref.watch(profileProvider).value ?? HealthProfile.empty();
    final now = DateTime.now();
    final todayCount = logs
        .where(
          (log) =>
              log.completedAt.year == now.year &&
              log.completedAt.month == now.month &&
              log.completedAt.day == now.day,
        )
        .length;
    return Scaffold(
      body: PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            Text(
              _greeting(now),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'What do you need?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'A private check-in for hunger, emotion, habit, environment, and sensory needs.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _CravingCallToAction(onTap: () => context.push('/craving')),
            if (profile.wearOffMatches(now)) ...<Widget>[
              const SizedBox(height: 16),
              HabitCard(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.schedule_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Your reported wear-off window',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'You noted that hunger often rises around now. An easy meal or snack can be a planned support—not something to resist.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            const SectionHeader('Today'),
            const SizedBox(height: 12),
            HabitCard(
              child: Row(
                children: <Widget>[
                  _Metric(value: '$todayCount', label: 'check-ins'),
                  Container(
                    height: 52,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: Text(
                      logs.isEmpty
                          ? 'Your patterns will appear after a few private check-ins.'
                          : 'Last check-in ${_relative(logs.first.completedAt, now)}',
                    ),
                  ),
                ],
              ),
            ),
            if (logs.length >= 3) ...<Widget>[
              const SizedBox(height: 16),
              _ReflectionCard(onTap: () => _showReflection(context, ref)),
            ],
            const SizedBox(height: 16),
            HabitCard(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your check-ins stay on this device in an encrypted local database.',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Privacy details',
                    onPressed: () => context.push('/privacy'),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                DateFormat('EEEE, MMMM d').format(now),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _greeting(DateTime now) {
    if (now.hour < 12) return 'GOOD MORNING';
    if (now.hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  static String _relative(DateTime then, DateTime now) {
    final difference = now.difference(then);
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    return DateFormat.MMMd().format(then);
  }

  static Future<void> _showReflection(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final answer = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'A gentle reflection',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Have your recent check-ins helped you notice what you needed?',
            ),
            const SizedBox(height: 16),
            for (final value in const <String>[
              'Yes',
              'Sometimes',
              'Not really',
            ]) ...<Widget>[
              OutlinedButton(
                onPressed: () => Navigator.pop(context, value),
                child: Text(value),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
    if (answer == null) return;
    await ref
        .read(repositoryProvider)
        .addReflection(promptId: 'noticed_need_v1', answer: answer);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved on this device.')),
      );
    }
  }
}

class _CravingCallToAction extends StatelessWidget {
  const _CravingCallToAction({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Log a craving',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[HabitColors.forest, Color(0xFF0A5B4D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: HabitColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 34,
                  color: HabitColors.forest,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Log a craving',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find a plan in about a minute',
                      style: TextStyle(color: Color(0xFFD5F5E9)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: Theme.of(context).textTheme.headlineLarge),
        Text(label),
      ],
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceTile(
      title: 'A gentle reflection',
      subtitle: 'One tap, no scoring',
      icon: Icons.chat_bubble_outline_rounded,
      onTap: onTap,
    );
  }
}
