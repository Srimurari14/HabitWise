import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../data/local/app_database.dart';
import '../../../providers.dart';
import '../../gamification/domain/avatar_models.dart';
import '../../profile/domain/health_profile.dart';
import '../application/craving_controller.dart';
import '../domain/craving_models.dart';
import '../domain/medical_rules.dart';
import '../domain/plan_explanation.dart';

class CravingFlowScreen extends ConsumerStatefulWidget {
  const CravingFlowScreen({super.key, this.repeat});

  /// Set when the check-in was started from an earlier one, so the craving,
  /// the category and the detail are already known.
  final CravingRepeat? repeat;

  @override
  ConsumerState<CravingFlowScreen> createState() => _CravingFlowScreenState();
}

class _CravingFlowScreenState extends ConsumerState<CravingFlowScreen> {
  @override
  void initState() {
    super.initState();
    final repeat = widget.repeat;
    if (repeat != null) {
      ref.read(cravingFlowControllerProvider.notifier).prefill(repeat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cravingFlowControllerProvider);
    final controller = ref.read(cravingFlowControllerProvider.notifier);
    final config = ref.watch(cravingConfigProvider);
    final profile = ref.watch(profileProvider).value ?? HealthProfile.empty();
    final showBack =
        state.step != CravingFlowStep.safety &&
        state.step != CravingFlowStep.complete;
    return Scaffold(
      appBar: AppBar(
        leading: showBack
            ? IconButton(
                tooltip: 'Previous question',
                onPressed: controller.goBack,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : IconButton(
                tooltip: 'Close check-in',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
              ),
        title: const Text('Craving check-in'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _progress(state.step),
            minHeight: 4,
          ),
        ),
      ),
      body: config.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ConfigError(error: error),
        data: (value) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(state.step),
            child: switch (state.step) {
              CravingFlowStep.safety => _SafetyStep(
                profile: profile,
                onContinue: controller.answerSafety,
              ),
              CravingFlowStep.type => _TypeStep(
                onSelected: controller.selectType,
              ),
              CravingFlowStep.category => _CategoryStep(
                ranked: state.rankedCategories,
                onSelected: controller.selectCategory,
              ),
              CravingFlowStep.subtrigger => _SubtriggerStep(
                config: value,
                category: state.session.category!,
                profile: profile,
                onSelected: controller.selectSubtrigger,
              ),
              CravingFlowStep.intensity => _IntensityStep(
                initialValue: state.session.intensityBefore,
                onContinue: controller.setIntensity,
              ),
              CravingFlowStep.plan => _PlanStep(
                plan: state.session.plan!,
                backupPlan: state.backupPlan,
                explanation: state.driverExplanation,
                category: state.session.category,
                safetyDecision: state.safetyDecision,
                edSafetyMode: profile.edSafetyMode,
                gameRecommendation: state.gameRecommendation,
                session: state.session,
                onContinue: controller.beginFollowUp,
              ),
              CravingFlowStep.followUp => _FollowUpStep(
                state: state,
                eatPlan: value.interventions['permission-to-eat'],
                onChanged: controller.updateFollowUp,
                onSave: controller.save,
              ),
              CravingFlowStep.complete => _CompleteStep(
                session: state.session,
                onDone: () => context.go('/home'),
              ),
            },
          ),
        ),
      ),
    );
  }

  static double _progress(CravingFlowStep step) {
    return switch (step) {
      CravingFlowStep.safety => 0.08,
      CravingFlowStep.type => 0.2,
      CravingFlowStep.category => 0.35,
      CravingFlowStep.subtrigger => 0.5,
      CravingFlowStep.intensity => 0.62,
      CravingFlowStep.plan => 0.76,
      CravingFlowStep.followUp => 0.9,
      CravingFlowStep.complete => 1,
    };
  }
}

class _SafetyStep extends StatefulWidget {
  const _SafetyStep({required this.profile, required this.onContinue});

  final HealthProfile profile;
  final Future<void> Function(SafetyAnswers) onContinue;

  @override
  State<_SafetyStep> createState() => _SafetyStepState();
}

class _SafetyStepState extends State<_SafetyStep> {
  bool? _hungry;
  bool? _glucoseWarning;
  bool? _personalPlan;
  bool? _restriction;
  bool _submitting = false;

  bool get _singleQuestion =>
      !widget.profile.glucoseSafetyEnabled && !widget.profile.edSafetyMode;

  bool get _complete =>
      _hungry != null &&
      (!widget.profile.glucoseSafetyEnabled || _glucoseWarning != null) &&
      (!widget.profile.edSafetyMode || _restriction != null) &&
      (_glucoseWarning != true || _personalPlan != null);

  void _answerHunger(bool value) {
    if (_submitting) return;
    setState(() => _hungry = value);
    if (_singleQuestion) unawaited(_submit());
  }

  Future<void> _submit() async {
    if (_submitting || !_complete) return;
    setState(() => _submitting = true);
    await widget.onContinue(
      SafetyAnswers(
        physicalHunger: _hungry!,
        glucoseWarningSigns: _glucoseWarning ?? false,
        hasPersonalGlucosePlan: _personalPlan ?? false,
        restrictionOrCompensation: _restriction ?? false,
      ),
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Body first', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          const Text('First, let’s check what your body needs.'),
          const SizedBox(height: 24),
          _YesNoQuestion(
            title:
                'Are you hungry, or unsure enough that food sounds good right now?',
            supportingText:
                'Hunger can feel like emptiness, low energy, being irritable or shaky, wanting food in general, or just knowing it has been a while.',
            value: _hungry,
            yesLabel: 'Yes / not sure',
            noLabel: 'No',
            onChanged: _answerHunger,
          ),
          if (widget.profile.glucoseSafetyEnabled) ...<Widget>[
            const SizedBox(height: 16),
            _YesNoQuestion(
              title:
                  'Any warning signs you associate with a glucose problem right now?',
              supportingText:
                  'For example: concerning shakiness, sweating, confusion, weakness, or a reading outside the range in your care plan.',
              value: _glucoseWarning,
              yesLabel: 'Yes',
              noLabel: 'No',
              onChanged: (value) => setState(() => _glucoseWarning = value),
            ),
            if (_glucoseWarning == true) ...<Widget>[
              const SizedBox(height: 16),
              _YesNoQuestion(
                title:
                    'Do you have a personal glucose plan from your care team?',
                supportingText:
                    'HabitWise will direct you to that plan; it will not create or calculate one.',
                value: _personalPlan,
                yesLabel: 'Yes',
                noLabel: 'No / not sure',
                onChanged: (value) => setState(() => _personalPlan = value),
              ),
            ],
          ],
          if (widget.profile.edSafetyMode) ...<Widget>[
            const SizedBox(height: 16),
            _YesNoQuestion(
              title:
                  'Is restriction, compensation, or fear of allowing food part of this moment?',
              supportingText:
                  'A yes routes away from timers and resistance tools and toward nourishment and support.',
              value: _restriction,
              yesLabel: 'Yes / maybe',
              noLabel: 'No',
              onChanged: (value) => setState(() => _restriction = value),
            ),
          ],
          const SizedBox(height: 24),
          if (!_singleQuestion)
            FilledButton(
              onPressed: !_complete || _submitting ? null : _submit,
              child: _submitting
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Continue'),
            )
          else if (_submitting)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

class _CoinReward extends StatelessWidget {
  const _CoinReward({
    required this.earned,
    required this.balance,
    required this.reducedMotion,
  });

  final int earned;
  final int balance;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.hexagon_outlined, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: reducedMotion ? earned : 0, end: earned),
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Text(
              '+$value coins',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      children: <Widget>[
        if (reducedMotion)
          chip
        else
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: chip,
          ),
        const SizedBox(height: 8),
        Text(
          '$balance coins in total. Coins are earned, never bought.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _YesNoQuestion extends StatelessWidget {
  const _YesNoQuestion({
    required this.title,
    required this.supportingText,
    required this.value,
    required this.yesLabel,
    required this.noLabel,
    required this.onChanged,
  });

  final String title;
  final String supportingText;
  final bool? value;
  final String yesLabel;
  final String noLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(supportingText),
          const SizedBox(height: 14),
          SegmentedButton<bool>(
            segments: <ButtonSegment<bool>>[
              ButtonSegment(value: true, label: Text(yesLabel)),
              ButtonSegment(value: false, label: Text(noLabel)),
            ],
            selected: value == null ? const <bool>{} : <bool>{value!},
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onChanged(selection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _TypeStep extends StatelessWidget {
  const _TypeStep({required this.onSelected});
  final Future<void> Function(CravingType) onSelected;

  @override
  Widget build(BuildContext context) {
    const icons = <CravingType, IconData>{
      CravingType.sweet: Icons.cake_outlined,
      CravingType.salty: Icons.ramen_dining_outlined,
      CravingType.crunchy: Icons.grain_rounded,
      CravingType.creamy: Icons.icecream_outlined,
      CravingType.warm: Icons.soup_kitchen_outlined,
      CravingType.cold: Icons.ac_unit_rounded,
      CravingType.specific: Icons.restaurant_rounded,
      CravingType.anything: Icons.question_mark_rounded,
    };
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What sounds good?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text('Pick the closest one.'),
          const SizedBox(height: 20),
          for (final type in CravingType.values) ...<Widget>[
            ChoiceTile(
              title: type.label,
              icon: icons[type],
              trailing: const SizedBox.shrink(),
              onTap: () => onSelected(type),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({required this.ranked, required this.onSelected});

  final List<RankedCategory> ranked;
  final ValueChanged<TriggerCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What is closest right now?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text('The first one is a guess. Pick whatever fits.'),
          const SizedBox(height: 20),
          for (var index = 0; index < ranked.length; index++) ...<Widget>[
            ChoiceTile(
              title: ranked[index].category.label,
              subtitle: ranked[index].category.description,
              badge: index == 0
                  ? 'Suggested from ${ranked[index].reason}'
                  : null,
              icon: _categoryIcon(ranked[index].category),
              trailing: const SizedBox.shrink(),
              onTap: () => onSelected(ranked[index].category),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  static IconData _categoryIcon(TriggerCategory category) => switch (category) {
    TriggerCategory.physiological => Icons.monitor_heart_outlined,
    TriggerCategory.emotional => Icons.favorite_outline_rounded,
    TriggerCategory.environmental => Icons.place_outlined,
    TriggerCategory.habitual => Icons.repeat_rounded,
    TriggerCategory.sensory => Icons.touch_app_outlined,
  };
}

class _SubtriggerStep extends StatelessWidget {
  const _SubtriggerStep({
    required this.config,
    required this.category,
    required this.profile,
    required this.onSelected,
  });

  final CravingConfig config;
  final TriggerCategory category;
  final HealthProfile profile;
  final Future<void> Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final items = const MedicalRulesEngine().reorderSubtriggers(
      candidates: config.forCategory(category),
      profile: profile,
    );
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Which detail fits?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You chose ${category.label.toLowerCase()}. Pick the closest explanation, even if it is imperfect.',
          ),
          const SizedBox(height: 20),
          for (var index = 0; index < items.length; index++) ...<Widget>[
            ChoiceTile(
              title: items[index].label,
              subtitle: items[index].description,
              badge:
                  const MedicalRulesEngine().subtriggerPriority(
                        item: items[index],
                        profile: profile,
                      ) >
                      0
                  ? 'From your profile'
                  : null,
              trailing: const SizedBox.shrink(),
              onTap: () => onSelected(items[index].id),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _IntensityStep extends StatefulWidget {
  const _IntensityStep({required this.initialValue, required this.onContinue});
  final int initialValue;
  final ValueChanged<int> onContinue;

  @override
  State<_IntensityStep> createState() => _IntensityStepState();
}

class _IntensityStepState extends State<_IntensityStep> {
  late double _value = widget.initialValue.toDouble();

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How loud is the urge?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'This is only a before-and-after reference. There is no target score.',
          ),
          const SizedBox(height: 28),
          HabitCard(
            child: Column(
              children: <Widget>[
                Text(
                  _value.round().toString(),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Slider(
                  value: _value,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _value.round().toString(),
                  onChanged: (value) => setState(() => _value = value),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('Quiet'), Text('Very loud')],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => widget.onContinue(_value.round()),
            child: const Text('Show my plan'),
          ),
        ],
      ),
    );
  }
}

class _PlanStep extends StatefulWidget {
  const _PlanStep({
    required this.plan,
    required this.backupPlan,
    required this.explanation,
    required this.category,
    required this.safetyDecision,
    required this.edSafetyMode,
    required this.gameRecommendation,
    required this.session,
    required this.onContinue,
  });

  final InterventionDefinition plan;
  final InterventionDefinition? backupPlan;
  final DriverExplanation? explanation;
  final TriggerCategory? category;
  final SafetyDecision safetyDecision;
  final bool edSafetyMode;
  final GameRecommendation? gameRecommendation;
  final CravingSession session;
  final VoidCallback onContinue;

  @override
  State<_PlanStep> createState() => _PlanStepState();
}

class _PlanStepState extends State<_PlanStep> {
  Timer? _timer;
  late var _remaining = Duration(minutes: widget.plan.minutes);
  var _running = false;
  var _started = false;
  var _timeUp = false;
  final _completedSteps = <int>{};
  SignalShiftResult? _gameResult;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() {
      // Starting again after the countdown finished begins a fresh run.
      if (_remaining == Duration.zero) {
        _remaining = Duration(minutes: widget.plan.minutes);
        _timeUp = false;
      }
      _running = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _running = false;
          _timeUp = true;
        });
        unawaited(HapticFeedback.vibrate());
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _startPlan(bool canTime) {
    if (_started) return;
    setState(() => _started = true);
    if (canTime) _toggleTimer();
  }

  void _toggleStep(int index, bool? complete) {
    // The steps are in order, so ticking one marks everything before it, and
    // unticking one clears everything after it.
    setState(() {
      if (complete ?? false) {
        for (var step = 0; step <= index; step++) {
          _completedSteps.add(step);
        }
      } else {
        _completedSteps.removeWhere((step) => step >= index);
      }
    });
  }

  Future<void> _playGame() async {
    final recommendation = widget.gameRecommendation;
    if (recommendation == null) return;
    final result = await context.push<SignalShiftResult>(
      '/signal-shift',
      extra: SignalShiftLaunch(
        source: GameSource.recommended,
        durationMinutes: recommendation.durationMinutes,
        mode: recommendation.mode,
        cravingSessionId: widget.session.id,
        category: widget.session.category?.name,
        subtriggerId: widget.session.subtriggerId,
        intensityBefore: widget.session.intensityBefore,
        reason: recommendation.reason,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _gameResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final canTime =
        plan.timerAllowed && !widget.edSafetyMode && plan.minutes > 0;
    final ordinaryPlan = !widget.safetyDecision.shouldExit;
    final category = widget.category;
    final support = ordinaryPlan && category != null
        ? PlanExplanationEngine.supportFor(category: category, plan: plan)
        : null;
    final progress = plan.steps.isEmpty
        ? 0.0
        : _completedSteps.length / plan.steps.length;
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.safetyDecision.shouldExit) ...<Widget>[
            Text(
              widget.safetyDecision.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            HabitCard(
              // Only a possible medical emergency uses the alarm colour. A
              // hunger or eating-concern exit is permission, not a warning.
              color: widget.safetyDecision.exit == SafetyExit.urgentGlucose
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
              child: Text(widget.safetyDecision.message),
            ),
            const SizedBox(height: 20),
          ] else ...<Widget>[
            Text(
              'Most likely craving driver',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            HabitCard(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.psychology_alt_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.explanation?.title ?? category?.label ?? '',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.explanation?.summary ??
                        'This is the best working explanation from your answers, not a confirmed cause.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A working guess, not a diagnosis.',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Why HabitWise thinks this'),
              subtitle: const Text('The signals used, shown openly'),
              children: <Widget>[
                for (final signal
                    in widget.explanation?.signals ?? const <String>[])
                  _ExplanationBullet(text: signal),
              ],
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.lightbulb_outline_rounded),
              title: const Text('What may be happening'),
              subtitle: const Text('A plain-language explanation'),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.explanation?.mechanism ?? ''),
                ),
                if (widget.explanation?.otherPossibilities.isNotEmpty ??
                    false) ...<Widget>[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Other contributors worth watching',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final possibility
                      in widget.explanation!.otherPossibilities)
                    _ExplanationBullet(text: possibility),
                ],
                const SizedBox(height: 12),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Your immediate plan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            HabitCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hold the line',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(support!.firmLead),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(plan.title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(plan.whyLine),
          const SizedBox(height: 18),
          if (ordinaryPlan && !_started) ...<Widget>[
            FilledButton.icon(
              onPressed: () => _startPlan(canTime),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start the plan'),
            ),
            if (plan.minutes > 0) ...<Widget>[
              const SizedBox(height: 8),
              Text('Usually about ${plan.minutes} minutes.'),
            ],
            const SizedBox(height: 18),
          ],
          if (ordinaryPlan && _started) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${_completedSteps.length} of ${plan.steps.length} steps complete',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Text('${(progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              value: progress,
            ),
            const SizedBox(height: 12),
          ],
          for (var index = 0; index < plan.steps.length; index++)
            ordinaryPlan
                ? CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _completedSteps.contains(index),
                    onChanged: _started
                        ? (value) => _toggleStep(index, value)
                        : null,
                    title: Text(plan.steps[index]),
                    secondary: CircleAvatar(
                      radius: 14,
                      child: Text('${index + 1}'),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NumberedStep(
                      number: index + 1,
                      text: plan.steps[index],
                    ),
                  ),
          if (ordinaryPlan && widget.gameRecommendation != null) ...<Widget>[
            const SizedBox(height: 16),
            HabitCard(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/signal_shift_hero.png',
                      height: 145,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.sports_esports_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Optional: play Signal Shift',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(
                        label: Text(
                          '${widget.gameRecommendation!.durationMinutes} min',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.gameRecommendation!.reason),
                  const SizedBox(height: 10),
                  Text(
                    widget.gameRecommendation!.safetyNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  if (_gameResult == null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: _playGame,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play the recommended shift'),
                      ),
                    )
                  else ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Saved: score ${_gameResult!.score}, ${_gameResult!.coinsEarned} coins. '
                      'Coins are capped at 30 a day.',
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _gameResult == null
                        ? 'Prefer not to play? Skip it and continue the plan below.'
                        : 'Continue with the rest of your plan below.',
                  ),
                ],
              ),
            ),
          ],
          if (ordinaryPlan) ...<Widget>[
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              leading: const Icon(Icons.school_outlined),
              title: const Text('Why these steps should help'),
              children: <Widget>[
                for (var index = 0; index < plan.steps.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Step ${index + 1}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(support!.stepReasons[index]),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (plan.swaps.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              // On a safety exit the concrete list is the useful part, so it
              // opens by default instead of hiding behind a tap.
              initiallyExpanded: widget.safetyDecision.shouldExit,
              title: const Text('Easy ways to carry out the plan'),
              subtitle: const Text('Pick whichever is easiest'),
              children: plan.swaps
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.add_circle_outline_rounded),
                      title: Text(item),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (plan.tags.contains('medication-context')) ...<Widget>[
            const SizedBox(height: 8),
            const HabitCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.medical_information_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If appetite changes are disruptive, new, or concerning, contact your prescriber. HabitWise does not advise medication changes.',
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (canTime) ...<Widget>[
            const SizedBox(height: 18),
            HabitCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_started ? 'Plan timer' : 'Timer ready'),
                        Text(
                          '${_remaining.inMinutes.toString().padLeft(2, '0')}:${(_remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: _running
                        ? 'Pause timer'
                        : _timeUp
                        ? 'Start again'
                        : 'Start timer',
                    onPressed: _started ? _toggleTimer : null,
                    icon: Icon(
                      _running
                          ? Icons.pause_rounded
                          : _timeUp
                          ? Icons.replay_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                ],
              ),
            ),
            if (_timeUp) ...<Widget>[
              const SizedBox(height: 8),
              const Text('Time is up. Re-rate the urge when you are ready.'),
            ],
          ],
          if (ordinaryPlan && widget.backupPlan != null) ...<Widget>[
            const SizedBox(height: 26),
            Text(
              'If the craving is still strong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            HabitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Backup: ${widget.backupPlan!.title}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(support!.backupWhy),
                  const SizedBox(height: 12),
                  for (
                    var index = 0;
                    index < widget.backupPlan!.steps.length;
                    index++
                  )
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NumberedStep(
                        number: index + 1,
                        text: widget.backupPlan!.steps[index],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            HabitCard(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.health_and_safety_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text(support.safetyReminder)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'After the plan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const HabitCard(
              child: Text(
                'You will re-rate the urge, record whether you completed the plan, choose the step that helped most, note whether the craving returned, and record what you ultimately did.',
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.onContinue,
            child: Text(
              widget.safetyDecision.shouldExit
                  ? 'Save check-in'
                  : 'Re-rate my craving',
            ),
          ),
          if (widget.safetyDecision.shouldExit) ...<Widget>[
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Saved as a note. It never changes what the app suggests to you.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (ordinaryPlan) ...<Widget>[
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'You do not have to obey this urge. Finish the process first.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExplanationBullet extends StatelessWidget {
  const _ExplanationBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 6),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 14,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _FollowUpStep extends StatefulWidget {
  const _FollowUpStep({
    required this.state,
    required this.eatPlan,
    required this.onChanged,
    required this.onSave,
  });

  final CravingFlowState state;

  /// Shown only if someone corrects the hunger answer at the end of a flow
  /// that did not work. It is the same permission plan the safety step uses.
  final InterventionDefinition? eatPlan;
  final void Function({
    int? intensityAfter,
    CravingOutcome? outcome,
    bool? planCompleted,
    int? helpfulStepIndex,
    bool? cravingReturned,
    Set<String>? contextTags,
    bool? hungry,
  })
  onChanged;
  final Future<void> Function() onSave;

  @override
  State<_FollowUpStep> createState() => _FollowUpStepState();
}

class _FollowUpStepState extends State<_FollowUpStep> {
  late double _intensity =
      (widget.state.session.intensityAfter ??
              widget.state.session.intensityBefore)
          .toDouble();
  // The slider has to start somewhere, so an untouched one would otherwise be
  // saved as "the urge did not move", which is a real answer nobody gave.
  late bool _rated = widget.state.session.intensityAfter != null;
  // Null until the end of a flow that did not work, where the hunger question
  // is worth asking a second time.
  bool? _reHungry;
  late CravingOutcome? _outcome = widget.state.session.outcome;
  late bool? _planCompleted = widget.state.session.planCompleted;
  late int? _helpfulStepIndex = widget.state.session.helpfulStepIndex;
  late bool? _cravingReturned = widget.state.session.cravingReturned;
  final _tags = <String>{};

  Future<void> _playGame() async {
    final recommendation = widget.state.gameRecommendation;
    if (recommendation == null) return;
    await context.push<SignalShiftResult>(
      '/signal-shift',
      extra: SignalShiftLaunch(
        source: GameSource.recommended,
        durationMinutes: recommendation.durationMinutes,
        mode: recommendation.mode,
        cravingSessionId: widget.state.session.id,
        category: widget.state.session.category?.name,
        subtriggerId: widget.state.session.subtriggerId,
        intensityBefore: widget.state.session.intensityBefore,
        reason: recommendation.reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const availableTags = <String, String>{
      'tired': 'Tired',
      'stressed': 'Stressed',
      'screen': 'Using a screen',
      'alone': 'Alone',
      'social': 'With people',
      'after_task': 'After a task',
      'medication_transition': 'Medication transition',
    };
    final safetyExit = widget.state.session.safetyExit != SafetyExit.none;
    final askedForMore =
        _outcome == CravingOutcome.partlyHelped ||
        _outcome == CravingOutcome.needMoreSupport;
    final backup = widget.state.backupPlan;
    final game = widget.state.gameRecommendation;
    // Still rough: either they said so, or the number they set is mid or above.
    final stillStrong =
        !safetyExit && (askedForMore || (_rated && _intensity.round() >= 5));
    // They said none of the steps helped. The backup for most details is the
    // same plan in different words, so offering it here reads as not listening.
    final nothingHelped = _helpfulStepIndex != null && _helpfulStepIndex! < 0;
    final offerMore =
        stillStrong && (nothingHelped || backup != null || game != null);
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'What happened next?',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text('This helps you notice patterns. Every outcome is valid.'),
          if (!safetyExit) ...<Widget>[
            const SizedBox(height: 22),
            Text(
              _rated ? 'Urge now: ${_intensity.round()}' : 'Urge now',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (!_rated)
              const Text('Move the slider, even if nothing changed.'),
            Slider(
              value: _intensity,
              min: 1,
              max: 10,
              divisions: 9,
              label: _intensity.round().toString(),
              onChanged: (value) => setState(() {
                _intensity = value;
                _rated = true;
              }),
            ),
            const SizedBox(height: 18),
            Text(
              'Did you complete the primary plan?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment(value: true, label: Text('Yes')),
                ButtonSegment(value: false, label: Text('Not fully')),
              ],
              selected: _planCompleted == null
                  ? const <bool>{}
                  : <bool>{_planCompleted!},
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              onSelectionChanged: (selection) => setState(() {
                _planCompleted = selection.first;
                _helpfulStepIndex = null;
              }),
            ),
            if (_planCompleted != null) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                'Which step helped most?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (
                    var index = 0;
                    index < (widget.state.session.plan?.steps.length ?? 0);
                    index++
                  )
                    ChoiceChip(
                      label: Text('Step ${index + 1}'),
                      selected: _helpfulStepIndex == index,
                      onSelected: (_) =>
                          setState(() => _helpfulStepIndex = index),
                    ),
                  ChoiceChip(
                    label: const Text('No single step'),
                    selected: _helpfulStepIndex == -1,
                    onSelected: (_) => setState(() => _helpfulStepIndex = -1),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'Has the craving returned since you started?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const <ButtonSegment<bool>>[
                ButtonSegment(value: true, label: Text('Yes')),
                ButtonSegment(value: false, label: Text('No')),
              ],
              selected: _cravingReturned == null
                  ? const <bool>{}
                  : <bool>{_cravingReturned!},
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _cravingReturned = selection.first),
            ),
            const SizedBox(height: 18),
            Text(
              'What did you ultimately do?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final outcome in CravingOutcome.values) ...<Widget>[
              if (outcome != CravingOutcome.followedSafetyPlan)
                ChoiceTile(
                  title: outcome.label,
                  selected: _outcome == outcome,
                  trailing: _outcome == outcome
                      ? const Icon(Icons.check_circle_rounded)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => setState(() => _outcome = outcome),
                ),
              if (outcome != CravingOutcome.followedSafetyPlan)
                const SizedBox(height: 9),
            ],
            if (offerMore) ...<Widget>[
              const SizedBox(height: 6),
              HabitCard(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Try one more thing',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nothingHelped
                          ? 'That plan did not fit. Nothing here is owed, and '
                                'the check-in saves whatever you do next.'
                          : 'The urge is still up. Nothing here is required, '
                                'and the check-in saves whenever you want it '
                                'to.',
                    ),
                    // The game is never offered to someone who has just said
                    // they may be hungry. Food comes first, same as the safety
                    // step at the start of the flow.
                    if (game != null && _reHungry != true) ...<Widget>[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _playGame,
                          icon: const Icon(Icons.sports_esports_rounded),
                          label: Text(
                            'Play Signal Shift for '
                            '${game.durationMinutes} minutes',
                          ),
                        ),
                      ),
                    ],
                    if (backup != null &&
                        !nothingHelped &&
                        _reHungry != true) ...<Widget>[
                      const SizedBox(height: 14),
                      Text(
                        'Or the other plan: ${backup.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(backup.whyLine),
                      const SizedBox(height: 12),
                      for (var index = 0; index < backup.steps.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NumberedStep(
                            number: index + 1,
                            text: backup.steps[index],
                          ),
                        ),
                    ],
                    if (_reHungry != true &&
                        (game != null || (backup != null && !nothingHelped)))
                      const Text('Re-rate the urge above after you try it.'),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Text(
                      'One more question',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Are you sure you are not hungry? An urge that will not '
                      'move is often plain hunger wearing a costume.',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        ChoiceChip(
                          label: const Text('I am sure'),
                          selected: _reHungry == false,
                          onSelected: (_) {
                            setState(() => _reHungry = false);
                            widget.onChanged(hungry: false);
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Actually, I might be'),
                          selected: _reHungry == true,
                          onSelected: (_) {
                            setState(() => _reHungry = true);
                            widget.onChanged(hungry: true);
                          },
                        ),
                      ],
                    ),
                    if (_reHungry == true &&
                        widget.eatPlan != null) ...<Widget>[
                      const SizedBox(height: 14),
                      Text(
                        widget.eatPlan!.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(widget.eatPlan!.whyLine),
                      const SizedBox(height: 12),
                      for (
                        var index = 0;
                        index < widget.eatPlan!.steps.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NumberedStep(
                            number: index + 1,
                            text: widget.eatPlan!.steps[index],
                          ),
                        ),
                      const Text(
                        'No timer and no coins for this one. Eating is the '
                        'plan, not a failure of the other ones.',
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'Optional context',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTags.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _tags.contains(entry.key),
                  onSelected: (selected) => setState(() {
                    selected ? _tags.add(entry.key) : _tags.remove(entry.key);
                  }),
                );
              }).toList(),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 22),
            const HabitCard(
              child: Text(
                'Safety and nourishment plans are saved only as context. They never train trigger or intervention rankings.',
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed:
                widget.state.saving ||
                    (!safetyExit &&
                        (!_rated ||
                            _outcome == null ||
                            _planCompleted == null ||
                            _helpfulStepIndex == null ||
                            _cravingReturned == null))
                ? null
                : () async {
                    widget.onChanged(
                      intensityAfter: _intensity.round(),
                      outcome: _outcome,
                      planCompleted: _planCompleted,
                      helpfulStepIndex: _helpfulStepIndex,
                      cravingReturned: _cravingReturned,
                      contextTags: _tags,
                    );
                    await widget.onSave();
                  },
            child: widget.state.saving
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Text(offerMore ? 'Save and stop here' : 'Save check-in'),
          ),
        ],
      ),
    );
  }
}

class _CompleteStep extends ConsumerWidget {
  const _CompleteStep({required this.session, required this.onDone});

  final CravingSession session;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safety and nourishment check-ins never earn coins, so they show nothing
    // here rather than a zero.
    final ledger = session.safetyExit == SafetyExit.none
        ? (ref.watch(coinLedgerProvider).value ?? const <CoinLedgerData>[])
        : const <CoinLedgerData>[];
    final earned = ledger
        .where((row) => row.relatedSessionId == session.id)
        .fold<int>(0, (total, row) => total + row.amount);
    final balance = ref.watch(coinBalanceProvider);
    final reducedMotion =
        MediaQuery.disableAnimationsOf(context) ||
        (ref.watch(avatarProvider).value?.preferences.reducedMotion ?? false);
    return PageFrame(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 42,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(
              Icons.check_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Check-in saved',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          Text(
            session.safetyExit == SafetyExit.genuineHunger
                ? 'You responded to hunger with permission and care.'
                : session.safetyExit != SafetyExit.none
                ? 'The safety route took priority, as it should.'
                : 'You gathered information, not a grade. That is what makes patterns clearer.',
            textAlign: TextAlign.center,
          ),
          if (earned > 0) ...<Widget>[
            const SizedBox(height: 22),
            _CoinReward(
              earned: earned,
              balance: balance,
              reducedMotion: reducedMotion,
            ),
          ],
          const SizedBox(height: 26),
          FilledButton(onPressed: onDone, child: const Text('Back to home')),
        ],
      ),
    );
  }
}

class _ConfigError extends StatelessWidget {
  const _ConfigError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'The support guide could not load',
        message:
            'Close and reopen the app. Your existing check-ins are safe. Details: $error',
      ),
    );
  }
}
