import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/habit_widgets.dart';
import '../../../providers.dart';
import '../../gamification/presentation/avatar_character.dart';
import '../../profile/domain/health_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _page = 0;
  var _skin = 'skin_honey';
  var _ageBand = AgeBand.preferNotToSay;
  final _contexts = <HealthContext>{};
  final _medicationEffects = <MedicationEffect>{};
  var _medicationPattern = false;
  var _wearOffWindow = DayWindow.afternoon;
  var _edSafetyMode = false;
  var _glucoseSafety = false;
  var _saving = false;

  static const _pages = 7;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < _pages - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    setState(() => _saving = true);
    final medications = _medicationPattern
        ? <MedicationContext>[
            MedicationContext(
              id: const Uuid().v4(),
              label: 'Medication affecting appetite or energy',
              effects: _medicationEffects.isEmpty
                  ? const <MedicationEffect>{MedicationEffect.noPatternNoticed}
                  : _medicationEffects,
              usualWindow: DayWindow.varies,
              wearOffWindow: _wearOffWindow,
            ),
          ]
        : <MedicationContext>[];
    final profile = HealthProfile(
      ageBand: _ageBand,
      contexts: _contexts,
      medications: medications,
      edSafetyMode: _edSafetyMode,
      glucoseSafetyEnabled:
          _glucoseSafety || _contexts.contains(HealthContext.diabetesGlucose),
      onboardingComplete: true,
      themeMode: 'system',
      remindersEnabled: false,
      checkInEnabled: false,
    );
    await ref.read(repositoryProvider).saveProfile(profile);
    final gamification = ref.read(gamificationRepositoryProvider);
    final avatar = await gamification.getAvatar();
    await gamification.saveAvatar(
      avatar.copyWith(
        equipped: <String, String>{...avatar.equipped, 'baseColor': _skin},
      ),
    );
    if (mounted) context.go('/home');
  }

  Future<void> _back() async {
    if (_page == 0) return;
    await _controller.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _page == 0
            ? null
            : IconButton(
                tooltip: 'Back',
                onPressed: _back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
        title: const Text('HabitWise'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_page + 1} / $_pages')),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(value: (_page + 1) / _pages),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() => _page = value),
              children: <Widget>[
                _WelcomePage(),
                _PrinciplesPage(),
                _ContextPage(
                  ageBand: _ageBand,
                  contexts: _contexts,
                  onAgeChanged: (value) => setState(() => _ageBand = value),
                  onContextChanged: (value, selected) => setState(() {
                    selected ? _contexts.add(value) : _contexts.remove(value);
                    if (value == HealthContext.eatingConcern && selected) {
                      _edSafetyMode = true;
                    }
                    if (value == HealthContext.diabetesGlucose && selected) {
                      _glucoseSafety = true;
                    }
                  }),
                ),
                _MedicationPage(
                  enabled: _medicationPattern,
                  effects: _medicationEffects,
                  wearOffWindow: _wearOffWindow,
                  onEnabled: (value) =>
                      setState(() => _medicationPattern = value),
                  onEffectChanged: (effect, selected) => setState(() {
                    selected
                        ? _medicationEffects.add(effect)
                        : _medicationEffects.remove(effect);
                  }),
                  onWindowChanged: (value) =>
                      setState(() => _wearOffWindow = value),
                ),
                _SafetyPage(
                  edMode: _edSafetyMode,
                  glucoseSafety: _glucoseSafety,
                  onEdModeChanged: (value) =>
                      setState(() => _edSafetyMode = value),
                  onGlucoseChanged: (value) =>
                      setState(() => _glucoseSafety = value),
                ),
                _CharacterPage(
                  skin: _skin,
                  onSkinChanged: (value) => setState(() => _skin = value),
                ),
                const _ReadyPage(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: FilledButton(
              onPressed: _saving ? null : _next,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _page == _pages - 1
                          ? 'Start using HabitWise'
                          : 'Continue',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 30),
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: HabitColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 40,
              color: HabitColors.forest,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Understand the urge.\nChoose what helps.',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 18),
          Text(
            'HabitWise is a private, judgment-free craving coach. It helps you notice hunger, emotion, habit, environment and sensory needs, then offers a practical plan.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          const HabitCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.favorite_outline_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Eating the food is always an allowed outcome. HabitWise does not count calories, prescribe weight change, or score willpower.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrinciplesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String, String)>[
      (
        Icons.lock_outline_rounded,
        'Local and private',
        'Your entries stay in an encrypted database on this device.',
      ),
      (
        Icons.restaurant_rounded,
        'Hunger comes first',
        'If you are hungry, the plan is to eat, not to wait it out.',
      ),
      (
        Icons.psychology_alt_outlined,
        'Context, not diagnosis',
        'Optional health details adjust support without diagnosing or replacing care.',
      ),
      (
        Icons.insights_outlined,
        'Learns carefully',
        'Your current answer outranks old patterns, and safety plans never train the algorithm.',
      ),
    ];
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Built around your needs',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          const Text('Here is what will stay true throughout the app.'),
          const SizedBox(height: 22),
          for (final item in items) ...<Widget>[
            HabitCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(item.$1, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.$2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(item.$3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ContextPage extends StatelessWidget {
  const _ContextPage({
    required this.ageBand,
    required this.contexts,
    required this.onAgeChanged,
    required this.onContextChanged,
  });

  final AgeBand ageBand;
  final Set<HealthContext> contexts;
  final ValueChanged<AgeBand> onAgeChanged;
  final void Function(HealthContext, bool) onContextChanged;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Personalize gently',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Everything here is optional. These details only tune questions and filter unsuitable plans.',
          ),
          const SizedBox(height: 22),
          DropdownButtonFormField<AgeBand>(
            initialValue: ageBand,
            decoration: const InputDecoration(labelText: 'Age range'),
            items: AgeBand.values
                .map(
                  (value) =>
                      DropdownMenuItem(value: value, child: Text(value.label)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onAgeChanged(value);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Health contexts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Select any that you want HabitWise to account for.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HealthContext.values.map((value) {
              final selected = contexts.contains(value);
              return FilterChip(
                label: Text(value.label),
                selected: selected,
                onSelected: (newValue) => onContextChanged(value, newValue),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MedicationPage extends StatelessWidget {
  const _MedicationPage({
    required this.enabled,
    required this.effects,
    required this.wearOffWindow,
    required this.onEnabled,
    required this.onEffectChanged,
    required this.onWindowChanged,
  });

  final bool enabled;
  final Set<MedicationEffect> effects;
  final DayWindow wearOffWindow;
  final ValueChanged<bool> onEnabled;
  final void Function(MedicationEffect, bool) onEffectChanged;
  final ValueChanged<DayWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Medication patterns',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell HabitWise only what you have noticed. The app never recommends changing a medication, dose, or schedule.',
          ),
          const SizedBox(height: 20),
          HabitCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('A medication affects my appetite or energy'),
              subtitle: const Text(
                'Includes ADHD medications and other prescriptions',
              ),
              value: enabled,
              onChanged: onEnabled,
            ),
          ),
          if (enabled) ...<Widget>[
            const SizedBox(height: 22),
            Text(
              'What have you noticed?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MedicationEffect.values.map((effect) {
                return FilterChip(
                  label: Text(effect.label),
                  selected: effects.contains(effect),
                  onSelected: (selected) => onEffectChanged(effect, selected),
                );
              }).toList(),
            ),
            if (effects.contains(
              MedicationEffect.hungerAsWearsOff,
            )) ...<Widget>[
              const SizedBox(height: 20),
              DropdownButtonFormField<DayWindow>(
                initialValue: wearOffWindow,
                decoration: const InputDecoration(
                  labelText: 'When does hunger usually return?',
                ),
                items: DayWindow.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onWindowChanged(value);
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'This window comes from you, not from a medication-name lookup. You can change it later.',
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SafetyPage extends StatelessWidget {
  const _SafetyPage({
    required this.edMode,
    required this.glucoseSafety,
    required this.onEdModeChanged,
    required this.onGlucoseChanged,
  });

  final bool edMode;
  final bool glucoseSafety;
  final ValueChanged<bool> onEdModeChanged;
  final ValueChanged<bool> onGlucoseChanged;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Safety settings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'These settings change the flow before any prediction or habit tool runs.',
          ),
          const SizedBox(height: 22),
          HabitCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Eating-concern safety mode'),
              subtitle: const Text(
                'Removes delay, resistance, portion, and win/loss framing. Once enabled, turning it off requires a supported reset outside routine profile editing.',
              ),
              value: edMode,
              onChanged: onEdModeChanged,
            ),
          ),
          const SizedBox(height: 12),
          HabitCard(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Glucose safety check'),
              subtitle: const Text(
                'Adds a warning-sign question and exits to your existing care plan when needed. HabitWise does not diagnose or calculate treatment.',
              ),
              value: glucoseSafety,
              onChanged: onGlucoseChanged,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'HabitWise is a self-reflection and behavior-support tool, not emergency care or a medical device. For immediate danger, contact local emergency services.',
          ),
        ],
      ),
    );
  }
}

class _CharacterPage extends StatelessWidget {
  const _CharacterPage({required this.skin, required this.onSkinChanged});

  final String skin;
  final ValueChanged<String> onSkinChanged;

  static const _skins = <(String, String, Color)>[
    ('skin_porcelain', 'Porcelain', Color(0xFFF3D3BC)),
    ('skin_sand', 'Sand', Color(0xFFE3B591)),
    ('skin_honey', 'Honey', Color(0xFFC98D62)),
    ('skin_bronze', 'Bronze', Color(0xFFA9683F)),
    ('skin_espresso', 'Espresso', Color(0xFF6E3F26)),
  ];

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Make your character',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'This is you in the app. You can change it any time, and earn '
            'clothes for it as you use HabitWise.',
          ),
          const SizedBox(height: 18),
          Center(
            child: AvatarCharacter(
              equipped: <String, String>{
                'baseColor': skin,
                'eyes': 'eyes_kind',
                'expression': 'expression_ready',
              },
              size: 200,
            ),
          ),
          const SizedBox(height: 22),
          Text('Skin tone', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (final option in _skins)
                Semantics(
                  button: true,
                  selected: skin == option.$1,
                  label: option.$2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => onSkinChanged(option.$1),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: option.$3,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: skin == option.$1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: skin == option.$1 ? 3 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage();

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'You are ready',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 14),
          const Text(
            'A check-in usually takes about a minute. As your history grows, HabitWise can show patterns, but your answer in the moment always comes first.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const HabitCard(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.restaurant_menu_rounded),
                  title: Text('Hungry? Eat.'),
                  subtitle: Text('No timer, no compensation, no score.'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.route_rounded),
                  title: Text('Not sure? Explore.'),
                  subtitle: Text(
                    'Body, emotion, environment, habit, or sensory need.',
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.lock_rounded),
                  title: Text('Private by default'),
                  subtitle: Text(
                    'Export or delete your data whenever you choose.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
