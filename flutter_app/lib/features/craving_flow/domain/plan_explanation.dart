import '../../profile/domain/health_profile.dart';
import 'craving_models.dart';
import 'medical_rules.dart';

class DriverExplanation {
  const DriverExplanation({
    required this.title,
    required this.summary,
    required this.signals,
    required this.mechanism,
    required this.otherPossibilities,
  });

  final String title;
  final String summary;
  final List<String> signals;
  final String mechanism;
  final List<String> otherPossibilities;
}

class PlanSupportContent {
  const PlanSupportContent({
    required this.firmLead,
    required this.stepReasons,
    required this.backupWhy,
    required this.safetyReminder,
  });

  final String firmLead;
  final List<String> stepReasons;
  final String backupWhy;
  final String safetyReminder;
}

abstract final class PlanExplanationEngine {
  static DriverExplanation buildDriver({
    required CravingType type,
    required TriggerCategory category,
    required SubtriggerDefinition subtrigger,
    required List<RankedCategory> rankedCategories,
    required HealthProfile profile,
    DateTime? now,
  }) {
    final ranked = rankedCategories
        .where((item) => item.category == category)
        .firstOrNull;
    final signals = <String>[
      'You described the urge as ${type.label.toLowerCase()}.',
      'You selected ${category.label.toLowerCase()} as the closest category.',
      'You chose "${subtrigger.label}" as the detail that fits best.',
    ];
    if (ranked != null &&
        ranked.sources.contains(EvidenceSource.learnedHistory)) {
      signals.add('Your recent check-ins also raised this category.');
    }
    final instant = now ?? DateTime.now();
    if (subtrigger.id == 'medication_rebound' &&
        profile.wearOffMatches(instant)) {
      signals.add(
        'This check-in falls inside the medication wear-off window you reported.',
      );
    }
    if (subtrigger.id == 'sensory_specific' &&
        profile.contexts.contains(HealthContext.sensoryNeeds)) {
      signals.add(
        'Your profile says sensory or texture needs can matter for you.',
      );
    }

    final alternatives = rankedCategories
        .where((item) => item.category != category)
        .take(2)
        .map((item) => '${item.category.label}: ${item.category.description}')
        .toList();

    return DriverExplanation(
      title: subtrigger.label,
      summary:
          'Your answers suggest ${subtrigger.label.toLowerCase()} is the strongest working explanation for this check-in. This is a useful hypothesis, not a diagnosis or a confirmed cause.',
      signals: signals,
      mechanism: _mechanisms[subtrigger.id] ?? subtrigger.description,
      otherPossibilities: alternatives,
    );
  }

  static PlanSupportContent supportFor({
    required TriggerCategory category,
    required InterventionDefinition plan,
  }) {
    final reasonPool = _stepReasons[category]!;
    return PlanSupportContent(
      firmLead: switch (category) {
        TriggerCategory.physiological =>
          'Do not automatically follow the specific urge. Complete this body check first, then respond to genuine hunger if it is present.',
        TriggerCategory.emotional =>
          'This feeling is real, but the craving does not control your next action. Complete the plan before making any food decision.',
        TriggerCategory.environmental =>
          'The cue has your attention, but it has not made the decision. Break contact with it and complete the plan.',
        TriggerCategory.habitual =>
          'This is a learned sequence, not an instruction. Change the next link and let the urge pass without reinforcing it.',
        TriggerCategory.sensory =>
          'Your brain may want stimulation, but the craved food is not the only route. Give the system a different strong signal first.',
      },
      stepReasons: List<String>.generate(
        plan.steps.length,
        (index) => reasonPool[index % reasonPool.length],
      ),
      backupWhy: switch (category) {
        TriggerCategory.physiological =>
          'The backup changes from a quick body check to a more direct reassessment of hunger, energy, hydration, and medical warning signs.',
        TriggerCategory.emotional =>
          'The backup changes regulation channels so you are not repeating a strategy that did not fit the moment.',
        TriggerCategory.environmental =>
          'The backup adds more distance and a competing activity, weakening the immediate cue-response sequence.',
        TriggerCategory.habitual =>
          'The backup replaces the familiar transition with a different predictable action instead of relying on willpower alone.',
        TriggerCategory.sensory =>
          'The backup uses a different type of safe stimulation so the exact food is not treated as the only answer.',
      },
      safetyReminder:
          'If you notice genuine physical hunger, glucose warning signs, illness, or another medical need, stop resisting the urge and follow the appropriate nourishment or care plan.',
    );
  }

  static const _stepReasons = <TriggerCategory, List<String>>{
    TriggerCategory.physiological: <String>[
      'Creating distance prevents a specific cue from being mistaken for an automatic body instruction.',
      'Checking broad hunger and energy signals separates a physical need from wanting one particular food.',
      'A brief low-demand reset gives fatigue, thirst, and medication-transition signals room to become clearer.',
      'Re-rating tests whether the specific urge changed before you decide what your body actually needs.',
    ],
    TriggerCategory.emotional: <String>[
      'Naming the emotion turns a vague impulse into information you can respond to directly.',
      'A short grounding action can lower activation enough to restore choice.',
      'A competing source of comfort or connection addresses the need without reinforcing the food loop.',
      'Re-rating shows whether the emotional wave shifted, even if it did not disappear completely.',
    ],
    TriggerCategory.environmental: <String>[
      'Naming the cue makes the automatic sequence visible.',
      'Moving away or hiding the cue reduces repeated prompts while the urge is strongest.',
      'A concrete competing action gives attention somewhere else to go.',
      'Re-rating checks whether distance weakened the cue before you return to the situation.',
    ],
    TriggerCategory.habitual: <String>[
      'Identifying the cue and expected reward exposes the learned sequence.',
      'Changing one link makes the routine less automatic without requiring a perfect day.',
      'A predictable replacement still gives the moment a clear next action.',
      'Repeating the new link once is how the alternative begins becoming easier to access.',
    ],
    TriggerCategory.sensory: <String>[
      'Naming the exact sensation prevents a broad craving from feeling mysterious or uncontrollable.',
      'A non-food sensory signal gives your attention system another source of intensity or regulation.',
      'Brief movement, sound, touch, or temperature competes with the food image without a complicated routine.',
      'Re-rating reveals whether the need was stimulation, hunger, or a mixture of both.',
    ],
  };

  static const _mechanisms = <String, String>{
    'under_fueled':
        'Eating less than your body needed earlier can make later urges feel urgent. Because you did not report clear hunger at the safety check, this plan starts with a brief reassessment rather than assuming either hunger or habit.',
    'medication_rebound':
        'You reported that appetite can rise during your medication transition. Returning appetite may overlap with fatigue, lower inhibition, or reward-seeking, but the app cannot determine that medication caused this individual craving.',
    'long_gap':
        'A long gap since eating can increase broad interest in food and make a specific cue harder to ignore. The useful question is whether several foods sound acceptable, not only the craved item.',
    'sleep_debt':
        'Short or disrupted sleep can leave energy and self-regulation feeling reduced. Familiar high-reward options may then become more attention-grabbing.',
    'thirst_dry_mouth':
        'Dry mouth and thirst can overlap with eating cues. Fluid can address thirst, but it should never be used to suppress genuine hunger.',
    'fatigue':
        'Low energy can increase the appeal of the fastest familiar reward. Rest, reduced demand, and an honest hunger reassessment help separate those needs.',
    'cycle_shift':
        'You identified a possible cycle-related appetite shift. Appetite and food preference can change, but one check-in cannot establish that the cycle caused this craving.',
    'stress_pressure':
        'Stress can make a fast, familiar reward feel unusually important. The urge may be offering quick relief rather than solving the source of pressure.',
    'anxiety_activation':
        'When attention is locked onto threat or tension, a predictable sensory reward can feel grounding. Direct grounding offers another route back to the present.',
    'low_mood':
        'When reward and motivation feel low, the brain may focus on an easy source of pleasure. A very small activation step can provide another source of momentum.',
    'lonely_disconnected':
        'A food routine can temporarily fill space created by loneliness or disconnection. Even a low-pressure signal of human connection may address more of the underlying need.',
    'overwhelmed':
        'Too many competing demands can make a concrete food action feel like an escape. Reducing one demand lowers the load instead of asking for more willpower.',
    'celebration_reward':
        'Finishing or succeeding can trigger a learned expectation of food. The goal is to keep the sense of reward while choosing a reward that matches what you actually want.',
    'food_visible':
        'Seeing or smelling food repeatedly can capture attention before a deliberate decision forms. Removing the cue interrupts those repeated prompts.',
    'someone_eating':
        'Seeing another person eat can make the same action feel immediately relevant. That social cue can be strong even when physical hunger is low.',
    'screen_content':
        'Food images and screen routines can prime expectation and link eating with passive attention. Breaking the first part of that pairing makes it easier to choose deliberately.',
    'easy_access':
        'Convenience strongly shapes automatic behavior when energy or attention is limited. Making a non-craving option equally easy changes the environment rather than depending only on self-control.',
    'time_of_day':
        'Repeated eating at the same time can create an expectation before physical need is clear. A replacement ritual gives that time cue somewhere else to lead.',
    'after_task':
        'A completed task often needs a transition marker, decompression, or reward. The craving may be the familiar way your routine supplies that ending.',
    'screen_pairing':
        'When eating and screens occur together repeatedly, starting one can cue the other. Separating them briefly weakens the automatic opening of the routine.',
    'procrastination':
        'An unclear or uncomfortable task can make a food action appealing because it is concrete and immediately rewarding. Making the task tiny reduces the need to escape it.',
    'automatic_route':
        'Places and routes can become powerful cues through repetition. Changing the route or the next action interrupts the sequence before it gathers momentum.',
    'sensory_specific':
        'The urge may be focused on crunch, temperature, creaminess, spice, or another specific sensation. Naming that property makes it possible to test a different source of stimulation first.',
    'oral_stimulation':
        'Chewing, sipping, temperature, and strong flavor can supply oral stimulation apart from hunger. A safe non-food mouth activity can help test which need is present.',
    'temperature_texture':
        'Texture and temperature can feel regulating or alerting. A different safe sensory input may meet enough of that need for the food-specific urge to fall.',
    'understimulated':
        'Boredom or low stimulation can make an intense, immediate food reward especially noticeable. Brief novelty, movement, sound, or touch provides a competing signal.',
  };
}
