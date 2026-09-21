import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/widgets/habit_widgets.dart';
import '../../../notification_provider.dart';
import '../../../providers.dart';
import '../domain/health_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Could not load profile: $error')),
        data: (profile) => PageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Make it yours',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Optional details tune the experience. They are never used to diagnose you.',
              ),
              const SizedBox(height: 24),
              const SectionHeader('Personalization'),
              const SizedBox(height: 12),
              HabitCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.cake_outlined),
                      title: const Text('Age range'),
                      subtitle: Text(profile.ageBand.label),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _editAge(context, ref, profile),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.health_and_safety_outlined),
                      title: const Text('Health contexts'),
                      subtitle: Text(
                        profile.contexts.isEmpty
                            ? 'None selected'
                            : '${profile.contexts.length} selected',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _editContexts(context, ref, profile),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.medication_outlined),
                      title: const Text('Medication patterns'),
                      subtitle: Text(
                        profile.medications.isEmpty
                            ? 'None added'
                            : profile.hasWearOffHunger
                            ? 'Wear-off hunger noted'
                            : '${profile.medications.length} pattern added',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _editMedication(context, ref, profile),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionHeader('Safety'),
              const SizedBox(height: 12),
              HabitCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.restaurant_menu_rounded),
                      title: const Text('Eating-concern safety mode'),
                      subtitle: Text(
                        profile.edSafetyMode
                            ? 'On. Delay and resistance tools stay removed.'
                            : 'Removes delay, portion, resistance, and win/loss framing.',
                      ),
                      value: profile.edSafetyMode,
                      onChanged: profile.edSafetyMode
                          ? null
                          : (value) =>
                                _enableEdMode(context, ref, profile, value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.bloodtype_outlined),
                      title: const Text('Glucose safety check'),
                      subtitle: const Text(
                        'Routes warning signs to your existing care plan.',
                      ),
                      value: profile.glucoseSafetyEnabled,
                      onChanged: (value) => ref
                          .read(repositoryProvider)
                          .saveProfile(
                            profile.copyWith(glucoseSafetyEnabled: value),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionHeader('Gentle reminders'),
              const SizedBox(height: 12),
              HabitCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.notifications_none_rounded),
                      title: const Text('Pattern-time check-in'),
                      subtitle: const Text(
                        'Uses the most common hour in your local history, or 4 PM until enough history exists.',
                      ),
                      value: profile.remindersEnabled,
                      onChanged: (value) =>
                          _setPatternReminder(context, ref, profile, value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.nights_stay_outlined),
                      title: const Text('Evening reflection'),
                      subtitle: const Text(
                        'A private, no-streak reminder at 8 PM local time.',
                      ),
                      value: profile.checkInEnabled,
                      onChanged: (value) =>
                          _setReflectionReminder(context, ref, profile, value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionHeader('Appearance'),
              const SizedBox(height: 12),
              HabitCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Theme'),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const <ButtonSegment<String>>[
                        ButtonSegment(value: 'system', label: Text('System')),
                        ButtonSegment(value: 'light', label: Text('Light')),
                        ButtonSegment(value: 'dark', label: Text('Dark')),
                      ],
                      selected: <String>{profile.themeMode},
                      showSelectedIcon: false,
                      onSelectionChanged: (values) => ref
                          .read(repositoryProvider)
                          .saveProfile(
                            profile.copyWith(themeMode: values.first),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionHeader('Your data'),
              const SizedBox(height: 12),
              HabitCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.lock_outline_rounded),
                      title: const Text('Privacy and safety'),
                      subtitle: const Text(
                        'How local storage and medical guardrails work',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/privacy'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.ios_share_rounded),
                      title: const Text('Export my data'),
                      subtitle: const Text('Create a human-readable JSON file'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _export(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      textColor: Theme.of(context).colorScheme.error,
                      iconColor: Theme.of(context).colorScheme.error,
                      leading: const Icon(Icons.delete_outline_rounded),
                      title: const Text('Delete all local data'),
                      subtitle: const Text(
                        'Removes profile, history, insights, and reflections',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _deleteAll(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'HabitWise 1.0.0 • Offline-first',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _editAge(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
  ) async {
    final value = await showModalBottomSheet<AgeBand>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          children: <Widget>[
            Text('Age range', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            for (final band in AgeBand.values)
              ListTile(
                leading: Icon(
                  band == profile.ageBand
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(band.label),
                onTap: () => Navigator.pop(context, band),
              ),
          ],
        ),
      ),
    );
    if (value != null) {
      await ref
          .read(repositoryProvider)
          .saveProfile(profile.copyWith(ageBand: value));
    }
  }

  static Future<void> _editContexts(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
  ) async {
    final selected = {...profile.contexts};
    final value = await showModalBottomSheet<Set<HealthContext>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Health contexts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Select only what you want the app to account for.'),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HealthContext.values.map((item) {
                        return FilterChip(
                          label: Text(item.label),
                          selected: selected.contains(item),
                          onSelected: (isSelected) => setModalState(() {
                            isSelected
                                ? selected.add(item)
                                : selected.remove(item);
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text('Save contexts'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (value == null) return;
    final edMode =
        profile.edSafetyMode || value.contains(HealthContext.eatingConcern);
    await ref
        .read(repositoryProvider)
        .saveProfile(
          profile.copyWith(
            contexts: value,
            edSafetyMode: edMode,
            glucoseSafetyEnabled:
                profile.glucoseSafetyEnabled ||
                value.contains(HealthContext.diabetesGlucose),
          ),
        );
  }

  static Future<void> _editMedication(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
  ) async {
    var enabled = profile.medications.isNotEmpty;
    final effects = profile.medications.isEmpty
        ? <MedicationEffect>{}
        : {...profile.medications.first.effects};
    var window = profile.medications.isEmpty
        ? DayWindow.afternoon
        : profile.medications.first.wearOffWindow;
    final result = await showModalBottomSheet<List<MedicationContext>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Medication patterns',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Record what you notice. HabitWise does not infer effects from a medication name.',
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Account for a medication pattern'),
                  value: enabled,
                  onChanged: (value) => setModalState(() => enabled = value),
                ),
                if (enabled) ...<Widget>[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MedicationEffect.values.map((effect) {
                      return FilterChip(
                        label: Text(effect.label),
                        selected: effects.contains(effect),
                        onSelected: (selected) => setModalState(() {
                          selected
                              ? effects.add(effect)
                              : effects.remove(effect);
                        }),
                      );
                    }).toList(),
                  ),
                  if (effects.contains(
                    MedicationEffect.hungerAsWearsOff,
                  )) ...<Widget>[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DayWindow>(
                      initialValue: window,
                      decoration: const InputDecoration(
                        labelText: 'Usual hunger-return window',
                      ),
                      items: DayWindow.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setModalState(() => window = value);
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    final medications = enabled
                        ? <MedicationContext>[
                            MedicationContext(
                              id:
                                  profile.medications.firstOrNull?.id ??
                                  const Uuid().v4(),
                              label: 'Medication affecting appetite or energy',
                              effects: effects.isEmpty
                                  ? const <MedicationEffect>{
                                      MedicationEffect.noPatternNoticed,
                                    }
                                  : effects,
                              usualWindow: DayWindow.varies,
                              wearOffWindow: window,
                            ),
                          ]
                        : <MedicationContext>[];
                    Navigator.pop(context, medications);
                  },
                  child: const Text('Save medication pattern'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For new, severe, or disruptive effects, contact your prescriber. Do not change medication based on this app.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null) {
      await ref
          .read(repositoryProvider)
          .saveProfile(profile.copyWith(medications: result));
    }
  }

  static Future<void> _enableEdMode(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
    bool value,
  ) async {
    if (!value) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable safety mode?'),
        content: const Text(
          'HabitWise will permanently remove delay, resistance, portion-control, and win/loss framing from this local profile. Routine profile editing cannot turn it off.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(repositoryProvider)
          .saveProfile(profile.copyWith(edSafetyMode: true));
    }
  }

  static Future<void> _export(BuildContext context, WidgetRef ref) async {
    final data = await ref.read(repositoryProvider).exportAll();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await SharePlus.instance.share(
      ShareParams(
        title: 'HabitWise data export',
        subject: 'HabitWise private data export',
        files: <XFile>[
          XFile.fromData(
            Uint8List.fromList(utf8.encode(json)),
            mimeType: 'application/json',
          ),
        ],
        fileNameOverrides: const <String>['habitwise-export.json'],
      ),
    );
  }

  static Future<void> _setPatternReminder(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
    bool enabled,
  ) async {
    final notifications = ref.read(notificationServiceProvider);
    if (enabled) {
      final allowed = await notifications.requestPermission();
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission was not granted.'),
            ),
          );
        }
        return;
      }
      await notifications.schedulePatternReminder(
        await ref.read(repositoryProvider).getLogs(),
      );
    } else {
      await notifications.cancelPatternReminder();
    }
    await ref
        .read(repositoryProvider)
        .saveProfile(profile.copyWith(remindersEnabled: enabled));
  }

  static Future<void> _setReflectionReminder(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
    bool enabled,
  ) async {
    final notifications = ref.read(notificationServiceProvider);
    if (enabled) {
      final allowed = await notifications.requestPermission();
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission was not granted.'),
            ),
          );
        }
        return;
      }
      await notifications.scheduleReflectionReminder();
    } else {
      await notifications.cancelReflectionReminder();
    }
    await ref
        .read(repositoryProvider)
        .saveProfile(profile.copyWith(checkInEnabled: enabled));
  }

  static Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all local data?'),
        content: const Text(
          'This removes your profile, craving history, learned patterns, reflections, avatar, coins, outfits, and game sessions from this device.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!(first ?? false) || !context.mounted) return;
    final finalConfirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('This cannot be undone'),
        content: const Text(
          'Export first if you want a copy. Delete everything now?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep my data'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (!(finalConfirmation ?? false)) return;
    await ref.read(repositoryProvider).deleteAllData();
    ref
      ..invalidate(gamificationReadyProvider)
      ..invalidate(avatarProvider)
      ..invalidate(ownedCosmeticsProvider)
      ..invalidate(coinLedgerProvider)
      ..invalidate(streakProvider)
      ..invalidate(gameSessionsProvider);
    if (context.mounted) context.go('/onboarding');
  }
}
