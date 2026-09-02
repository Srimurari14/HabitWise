import 'dart:convert';

enum AgeBand {
  under18('Under 18'),
  age18To24('18–24'),
  age25To34('25–34'),
  age35To44('35–44'),
  age45To54('45–54'),
  age55Plus('55+'),
  preferNotToSay('Prefer not to say');

  const AgeBand(this.label);
  final String label;
}

enum HealthContext {
  adhd('ADHD or attention support'),
  anxiety('Anxiety or high stress'),
  depression('Depression or low mood'),
  bipolarMood('Bipolar or another mood condition'),
  menstrualCycle('Cycle-related appetite changes'),
  diabetesGlucose('Diabetes or glucose-management needs'),
  sleepCondition('A sleep condition'),
  eatingConcern('Current or past eating concerns'),
  sensoryNeeds('Sensory or food-texture needs'),
  gastrointestinal('Digestive or gastrointestinal needs'),
  chronicPainFatigue('Chronic pain or fatigue'),
  other('Another health context');

  const HealthContext(this.label);
  final String label;
}

enum MedicationEffect {
  appetiteLowerEarlier('Appetite is lower earlier'),
  hungerAsWearsOff('Hunger increases as it wears off'),
  appetiteHigher('Appetite is often higher'),
  nauseaOrFoodAversion('Nausea or food aversion'),
  energyOrAlertnessShift('Energy or alertness changes'),
  noPatternNoticed('No pattern noticed');

  const MedicationEffect(this.label);
  final String label;
}

enum DayWindow {
  morning('Morning'),
  midday('Midday'),
  afternoon('Afternoon'),
  evening('Evening'),
  overnight('Overnight'),
  varies('It varies');

  const DayWindow(this.label);
  final String label;
}

class MedicationContext {
  const MedicationContext({
    required this.id,
    required this.label,
    required this.effects,
    required this.usualWindow,
    required this.wearOffWindow,
  });

  factory MedicationContext.fromJson(Map<String, Object?> json) {
    final rawEffects = json['effects'] as List<Object?>? ?? const [];
    return MedicationContext(
      id: json['id']! as String,
      label: json['label']! as String,
      effects: rawEffects
          .whereType<String>()
          .map(MedicationEffect.values.byName)
          .toSet(),
      usualWindow: DayWindow.values.byName(
        json['usualWindow'] as String? ?? DayWindow.varies.name,
      ),
      wearOffWindow: DayWindow.values.byName(
        json['wearOffWindow'] as String? ?? DayWindow.varies.name,
      ),
    );
  }

  final String id;
  final String label;
  final Set<MedicationEffect> effects;
  final DayWindow usualWindow;
  final DayWindow wearOffWindow;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'effects': effects.map((effect) => effect.name).toList(),
    'usualWindow': usualWindow.name,
    'wearOffWindow': wearOffWindow.name,
  };
}

class HealthProfile {
  const HealthProfile({
    required this.ageBand,
    required this.contexts,
    required this.medications,
    required this.edSafetyMode,
    required this.glucoseSafetyEnabled,
    required this.onboardingComplete,
    required this.themeMode,
    required this.remindersEnabled,
    required this.checkInEnabled,
  });

  factory HealthProfile.empty() => const HealthProfile(
    ageBand: AgeBand.preferNotToSay,
    contexts: <HealthContext>{},
    medications: <MedicationContext>[],
    edSafetyMode: false,
    glucoseSafetyEnabled: false,
    onboardingComplete: false,
    themeMode: 'system',
    remindersEnabled: false,
    checkInEnabled: false,
  );

  factory HealthProfile.fromJson(Map<String, Object?> json) {
    final contexts = json['contexts'] as List<Object?>? ?? const [];
    final medications = json['medications'] as List<Object?>? ?? const [];
    return HealthProfile(
      ageBand: AgeBand.values.byName(
        json['ageBand'] as String? ?? AgeBand.preferNotToSay.name,
      ),
      contexts: contexts
          .whereType<String>()
          .map(HealthContext.values.byName)
          .toSet(),
      medications: medications
          .whereType<Map<Object?, Object?>>()
          .map(
            (item) => MedicationContext.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
      edSafetyMode: json['edSafetyMode'] as bool? ?? false,
      glucoseSafetyEnabled: json['glucoseSafetyEnabled'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      checkInEnabled: json['checkInEnabled'] as bool? ?? false,
    );
  }

  factory HealthProfile.decode(String value) {
    return HealthProfile.fromJson(
      (jsonDecode(value) as Map<Object?, Object?>).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
  }

  final AgeBand ageBand;
  final Set<HealthContext> contexts;
  final List<MedicationContext> medications;
  final bool edSafetyMode;
  final bool glucoseSafetyEnabled;
  final bool onboardingComplete;
  final String themeMode;
  final bool remindersEnabled;
  final bool checkInEnabled;

  bool get hasWearOffHunger => medications.any(
    (medication) =>
        medication.effects.contains(MedicationEffect.hungerAsWearsOff),
  );

  bool wearOffMatches(DateTime time) {
    final window = dayWindowFor(time);
    return medications.any(
      (medication) =>
          medication.effects.contains(MedicationEffect.hungerAsWearsOff) &&
          (medication.wearOffWindow == DayWindow.varies ||
              medication.wearOffWindow == window),
    );
  }

  HealthProfile copyWith({
    AgeBand? ageBand,
    Set<HealthContext>? contexts,
    List<MedicationContext>? medications,
    bool? edSafetyMode,
    bool? glucoseSafetyEnabled,
    bool? onboardingComplete,
    String? themeMode,
    bool? remindersEnabled,
    bool? checkInEnabled,
  }) {
    return HealthProfile(
      ageBand: ageBand ?? this.ageBand,
      contexts: contexts ?? this.contexts,
      medications: medications ?? this.medications,
      edSafetyMode: edSafetyMode ?? this.edSafetyMode,
      glucoseSafetyEnabled: glucoseSafetyEnabled ?? this.glucoseSafetyEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      checkInEnabled: checkInEnabled ?? this.checkInEnabled,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'ageBand': ageBand.name,
    'contexts': contexts.map((context) => context.name).toList(),
    'medications': medications.map((item) => item.toJson()).toList(),
    'edSafetyMode': edSafetyMode,
    'glucoseSafetyEnabled': glucoseSafetyEnabled,
    'onboardingComplete': onboardingComplete,
    'themeMode': themeMode,
    'remindersEnabled': remindersEnabled,
    'checkInEnabled': checkInEnabled,
  };

  String encode() => jsonEncode(toJson());
}

DayWindow dayWindowFor(DateTime time) {
  if (time.hour < 5) return DayWindow.overnight;
  if (time.hour < 11) return DayWindow.morning;
  if (time.hour < 14) return DayWindow.midday;
  if (time.hour < 18) return DayWindow.afternoon;
  if (time.hour < 23) return DayWindow.evening;
  return DayWindow.overnight;
}
