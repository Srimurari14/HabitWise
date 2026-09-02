import 'dart:convert';

enum CravingType {
  sweet('Something sweet', 'Sweet'),
  salty('Something salty', 'Salty'),
  crunchy('Something crunchy', 'Crunchy'),
  creamy('Something creamy', 'Creamy'),
  warm('Something warm', 'Warm'),
  cold('Something cold', 'Cold'),
  specific('A specific food', 'Specific'),
  anything('Anything', 'Anything');

  const CravingType(this.label, this.shortLabel);
  final String label;
  final String shortLabel;
}

enum TriggerCategory {
  physiological('Body need', 'Your body may need fuel, rest, or regulation.'),
  emotional('Emotional', 'An emotion may be asking for care or relief.'),
  environmental('Environment', 'Something around you may be cueing the urge.'),
  habitual('Habit loop', 'A familiar moment may be running on autopilot.'),
  sensory(
    'Sensory',
    'A texture, temperature, or stimulation need may be present.',
  );

  const TriggerCategory(this.label, this.description);
  final String label;
  final String description;
}

enum CravingOutcome {
  resistedCraving('I moved past the craving'),
  helped('The plan helped and I stayed with my goal'),
  partlyHelped('The urge fell, but I still need another strategy'),
  choseSomethingElse('I chose a different supportive option'),
  ateCravedFood('I deliberately chose the food after the plan'),
  needMoreSupport('The craving is still strong; I need more support'),
  followedSafetyPlan('I followed the nourishment or safety plan');

  const CravingOutcome(this.label);
  final String label;
}

enum SafetyExit { none, urgentGlucose, genuineHunger, eatingConcernSupport }

class SubtriggerDefinition {
  const SubtriggerDefinition({
    required this.id,
    required this.label,
    required this.category,
    required this.description,
    required this.interventionIds,
  });

  factory SubtriggerDefinition.fromJson(Map<String, Object?> json) {
    return SubtriggerDefinition(
      id: json['id']! as String,
      label: json['label']! as String,
      category: TriggerCategory.values.byName(json['category']! as String),
      description: json['description']! as String,
      interventionIds: (json['interventionIds']! as List<Object?>)
          .whereType<String>()
          .toList(),
    );
  }

  final String id;
  final String label;
  final TriggerCategory category;
  final String description;
  final List<String> interventionIds;
}

class InterventionDefinition {
  const InterventionDefinition({
    required this.id,
    required this.title,
    required this.minutes,
    required this.whyLine,
    required this.steps,
    required this.swaps,
    required this.tags,
    required this.nonLearnable,
    required this.timerAllowed,
  });

  factory InterventionDefinition.fromJson(Map<String, Object?> json) {
    List<String> list(String key) =>
        (json[key]! as List<Object?>).whereType<String>().toList();

    return InterventionDefinition(
      id: json['id']! as String,
      title: json['title']! as String,
      minutes: json['minutes']! as int,
      whyLine: json['whyLine']! as String,
      steps: list('steps'),
      swaps: list('swaps'),
      tags: list('tags').toSet(),
      nonLearnable: json['nonLearnable'] as bool? ?? false,
      timerAllowed: json['timerAllowed'] as bool? ?? true,
    );
  }

  final String id;
  final String title;
  final int minutes;
  final String whyLine;
  final List<String> steps;
  final List<String> swaps;
  final Set<String> tags;
  final bool nonLearnable;
  final bool timerAllowed;

  InterventionDefinition copyWith({bool? nonLearnable, bool? timerAllowed}) =>
      InterventionDefinition(
        id: id,
        title: title,
        minutes: minutes,
        whyLine: whyLine,
        steps: steps,
        swaps: swaps,
        tags: tags,
        nonLearnable: nonLearnable ?? this.nonLearnable,
        timerAllowed: timerAllowed ?? this.timerAllowed,
      );
}

class CravingConfig {
  const CravingConfig({
    required this.version,
    required this.subtriggers,
    required this.interventions,
    required this.typePriors,
  });

  factory CravingConfig.fromJson({
    required String treeJson,
    required String interventionsJson,
  }) {
    final tree = (jsonDecode(treeJson) as Map<Object?, Object?>).map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final plans = (jsonDecode(interventionsJson) as Map<Object?, Object?>).map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final subtriggers = (tree['subtriggers']! as List<Object?>)
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => SubtriggerDefinition.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
    final interventions = <String, InterventionDefinition>{};
    for (final item
        in (plans['interventions']! as List<Object?>)
            .whereType<Map<Object?, Object?>>()) {
      final plan = InterventionDefinition.fromJson(
        item.map((key, value) => MapEntry(key.toString(), value)),
      );
      interventions[plan.id] = plan;
    }
    final priors = <CravingType, Map<TriggerCategory, double>>{};
    final rawPriors = tree['typePriors']! as Map<Object?, Object?>;
    for (final entry in rawPriors.entries) {
      priors[CravingType.values.byName(
        entry.key.toString(),
      )] = (entry.value! as Map<Object?, Object?>).map(
        (key, value) => MapEntry(
          TriggerCategory.values.byName(key.toString()),
          (value! as num).toDouble(),
        ),
      );
    }
    final config = CravingConfig(
      version: tree['version']! as int,
      subtriggers: subtriggers,
      interventions: interventions,
      typePriors: priors,
    );
    config.validate();
    return config;
  }

  final int version;
  final List<SubtriggerDefinition> subtriggers;
  final Map<String, InterventionDefinition> interventions;
  final Map<CravingType, Map<TriggerCategory, double>> typePriors;

  List<SubtriggerDefinition> forCategory(TriggerCategory category) {
    return subtriggers.where((item) => item.category == category).toList();
  }

  void validate() {
    if (version < 1 || subtriggers.isEmpty || interventions.isEmpty) {
      throw const FormatException('Craving configuration is incomplete.');
    }
    final ids = <String>{};
    for (final subtrigger in subtriggers) {
      if (!ids.add(subtrigger.id)) {
        throw FormatException('Duplicate subtrigger: ${subtrigger.id}');
      }
      for (final interventionId in subtrigger.interventionIds) {
        if (!interventions.containsKey(interventionId)) {
          throw FormatException(
            'Missing intervention $interventionId for ${subtrigger.id}',
          );
        }
      }
    }
    for (final type in CravingType.values) {
      final scores = typePriors[type];
      if (scores == null || scores.length != TriggerCategory.values.length) {
        throw FormatException('Missing complete priors for ${type.name}');
      }
    }
  }
}

class CravingSession {
  const CravingSession({
    required this.id,
    required this.startedAt,
    this.type,
    this.category,
    this.subtriggerId,
    this.intensityBefore = 5,
    this.intensityAfter,
    this.hungry,
    this.safetyExit = SafetyExit.none,
    this.plan,
    this.outcome,
    this.planCompleted,
    this.helpfulStepIndex,
    this.cravingReturned,
    this.contextTags = const <String>{},
  });

  final String id;
  final DateTime startedAt;
  final CravingType? type;
  final TriggerCategory? category;
  final String? subtriggerId;
  final int intensityBefore;
  final int? intensityAfter;
  final bool? hungry;
  final SafetyExit safetyExit;
  final InterventionDefinition? plan;
  final CravingOutcome? outcome;
  final bool? planCompleted;
  final int? helpfulStepIndex;
  final bool? cravingReturned;
  final Set<String> contextTags;

  CravingSession copyWith({
    CravingType? type,
    TriggerCategory? category,
    String? subtriggerId,
    int? intensityBefore,
    int? intensityAfter,
    bool? hungry,
    SafetyExit? safetyExit,
    InterventionDefinition? plan,
    CravingOutcome? outcome,
    bool? planCompleted,
    int? helpfulStepIndex,
    bool? cravingReturned,
    Set<String>? contextTags,
  }) => CravingSession(
    id: id,
    startedAt: startedAt,
    type: type ?? this.type,
    category: category ?? this.category,
    subtriggerId: subtriggerId ?? this.subtriggerId,
    intensityBefore: intensityBefore ?? this.intensityBefore,
    intensityAfter: intensityAfter ?? this.intensityAfter,
    hungry: hungry ?? this.hungry,
    safetyExit: safetyExit ?? this.safetyExit,
    plan: plan ?? this.plan,
    outcome: outcome ?? this.outcome,
    planCompleted: planCompleted ?? this.planCompleted,
    helpfulStepIndex: helpfulStepIndex ?? this.helpfulStepIndex,
    cravingReturned: cravingReturned ?? this.cravingReturned,
    contextTags: contextTags ?? this.contextTags,
  );
}
