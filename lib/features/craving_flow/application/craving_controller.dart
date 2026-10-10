import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../providers.dart';
import '../../gamification/domain/avatar_models.dart';
import '../../gamification/domain/game_recommendation_engine.dart';
import '../domain/craving_models.dart';
import '../domain/medical_rules.dart';
import '../domain/plan_explanation.dart';

enum CravingFlowStep {
  safety,
  type,
  category,
  subtrigger,
  intensity,
  plan,
  followUp,
  complete,
}

class CravingFlowState {
  const CravingFlowState({
    required this.step,
    required this.session,
    this.rankedCategories = const <RankedCategory>[],
    this.safetyDecision = const SafetyDecision.continueFlow(),
    this.driverExplanation,
    this.backupPlan,
    this.gameRecommendation,
    this.saving = false,
  });

  final CravingFlowStep step;
  final CravingSession session;
  final List<RankedCategory> rankedCategories;
  final SafetyDecision safetyDecision;
  final DriverExplanation? driverExplanation;
  final InterventionDefinition? backupPlan;
  final GameRecommendation? gameRecommendation;
  final bool saving;

  CravingFlowState copyWith({
    CravingFlowStep? step,
    CravingSession? session,
    List<RankedCategory>? rankedCategories,
    SafetyDecision? safetyDecision,
    DriverExplanation? driverExplanation,
    InterventionDefinition? backupPlan,
    GameRecommendation? gameRecommendation,
    bool clearGameRecommendation = false,
    bool? saving,
  }) => CravingFlowState(
    step: step ?? this.step,
    session: session ?? this.session,
    rankedCategories: rankedCategories ?? this.rankedCategories,
    safetyDecision: safetyDecision ?? this.safetyDecision,
    driverExplanation: driverExplanation ?? this.driverExplanation,
    backupPlan: backupPlan ?? this.backupPlan,
    gameRecommendation: clearGameRecommendation
        ? null
        : gameRecommendation ?? this.gameRecommendation,
    saving: saving ?? this.saving,
  );
}

final cravingFlowControllerProvider =
    NotifierProvider.autoDispose<CravingFlowController, CravingFlowState>(
      CravingFlowController.new,
    );

class CravingFlowController extends Notifier<CravingFlowState> {
  static const _uuid = Uuid();
  static const _rules = MedicalRulesEngine();
  static const _gameRules = GameRecommendationEngine();

  CravingRepeat? _repeat;

  @override
  CravingFlowState build() {
    return CravingFlowState(
      step: CravingFlowStep.safety,
      session: CravingSession(id: _uuid.v4(), startedAt: DateTime.now()),
    );
  }

  /// Carries the craving, the category and the detail over from an earlier
  /// check-in. The safety question is still asked, because hunger and glucose
  /// are about this moment, not the last one.
  void prefill(CravingRepeat repeat) => _repeat = repeat;

  Future<void> _applyRepeat(CravingRepeat repeat) async {
    final config = await ref.read(cravingConfigProvider.future);
    final exists = config.subtriggers.any(
      (item) => item.id == repeat.subtriggerId,
    );
    if (!exists) return;
    await selectType(repeat.type);
    selectCategory(repeat.category);
    await selectSubtrigger(repeat.subtriggerId);
  }

  Future<void> answerSafety(SafetyAnswers answers) async {
    final profile =
        ref.read(profileProvider).value ??
        await ref.read(repositoryProvider).getProfile();
    final decision = _rules.runSafetyPrecheck(
      profile: profile,
      answers: answers,
    );
    if (!decision.shouldExit) {
      state = state.copyWith(
        step: CravingFlowStep.type,
        session: state.session.copyWith(hungry: answers.physicalHunger),
      );
      final repeat = _repeat;
      if (repeat != null) {
        _repeat = null;
        await _applyRepeat(repeat);
      }
      return;
    }
    final config = await ref.read(cravingConfigProvider.future);
    final plan = config.interventions[decision.planId];
    state = state.copyWith(
      step: CravingFlowStep.plan,
      safetyDecision: decision,
      session: state.session.copyWith(
        hungry: answers.physicalHunger,
        safetyExit: decision.exit,
        plan: plan,
      ),
      clearGameRecommendation: true,
    );
  }

  Future<void> selectType(CravingType type) async {
    final repository = ref.read(repositoryProvider);
    final profile =
        ref.read(profileProvider).value ?? await repository.getProfile();
    final config = await ref.read(cravingConfigProvider.future);
    final learned = await repository.learnedScores(type);
    final ranked = _rules.rankCategories(
      type: type,
      config: config,
      profile: profile,
      learnedScores: learned,
    );
    state = state.copyWith(
      step: CravingFlowStep.category,
      session: state.session.copyWith(type: type),
      rankedCategories: ranked,
    );
  }

  void selectCategory(TriggerCategory category) {
    state = state.copyWith(
      step: CravingFlowStep.subtrigger,
      session: state.session.copyWith(category: category),
    );
  }

  Future<void> selectSubtrigger(String id) async {
    // Both of these are answered by earlier steps, so a missing one means the
    // flow was re-entered without them rather than that the person skipped a
    // question. Asking again is the only honest move.
    final type = state.session.type;
    if (type == null) {
      state = state.copyWith(step: CravingFlowStep.type);
      return;
    }
    final category = state.session.category;
    if (category == null) {
      state = state.copyWith(step: CravingFlowStep.category);
      return;
    }
    final config = await ref.read(cravingConfigProvider.future);
    final profile =
        ref.read(profileProvider).value ??
        await ref.read(repositoryProvider).getProfile();
    final subtrigger = config.subtriggers
        .where((item) => item.id == id)
        .firstOrNull;
    if (subtrigger == null) {
      // The id was taken from a list this config built, so losing it means
      // the config changed underneath an open check-in. The subtrigger list
      // comes from the category, so sending them back a step is what offers
      // a working list. Throwing here would end the check-in instead.
      state = state.copyWith(step: CravingFlowStep.category);
      return;
    }
    final chosen = _rules.choosePlans(
      subtrigger: subtrigger,
      config: config,
      profile: profile,
    );
    final primary = chosen.primary;
    final backup = chosen.backup;
    final explanation = PlanExplanationEngine.buildDriver(
      type: type,
      category: category,
      subtrigger: subtrigger,
      rankedCategories: state.rankedCategories,
      profile: profile,
    );
    final session = state.session.copyWith(subtriggerId: id, plan: primary);
    final avatar = await ref.read(gamificationRepositoryProvider).getAvatar();
    final gameRecommendation = _gameRules.recommend(
      session: session,
      profile: profile,
      preferences: avatar.preferences,
    );
    state = state.copyWith(
      step: CravingFlowStep.intensity,
      driverExplanation: explanation,
      backupPlan: backup,
      gameRecommendation: gameRecommendation,
      clearGameRecommendation: gameRecommendation == null,
      session: session,
    );
  }

  Future<void> setIntensity(int value) async {
    final session = state.session.copyWith(intensityBefore: value);
    final profile =
        ref.read(profileProvider).value ??
        await ref.read(repositoryProvider).getProfile();
    final avatar = await ref.read(gamificationRepositoryProvider).getAvatar();
    final recommendation = _gameRules.recommend(
      session: session,
      profile: profile,
      preferences: avatar.preferences,
    );
    state = state.copyWith(
      step: CravingFlowStep.plan,
      session: session,
      gameRecommendation: recommendation,
      clearGameRecommendation: recommendation == null,
    );
  }

  Future<void> beginFollowUp() async {
    if (state.session.safetyExit != SafetyExit.none) {
      // Safety and nourishment plans collect no follow-up answers, so the
      // check-in is saved straight away instead of showing an empty screen.
      state = state.copyWith(
        session: state.session.copyWith(
          intensityAfter: state.session.intensityBefore,
          outcome: CravingOutcome.followedSafetyPlan,
          planCompleted: true,
        ),
      );
      await save();
      return;
    }
    state = state.copyWith(step: CravingFlowStep.followUp);
  }

  void updateFollowUp({
    int? intensityAfter,
    CravingOutcome? outcome,
    bool? planCompleted,
    int? helpfulStepIndex,
    bool? cravingReturned,
    Set<String>? contextTags,
    bool? hungry,
  }) {
    state = state.copyWith(
      session: state.session.copyWith(
        intensityAfter: intensityAfter,
        outcome: outcome,
        planCompleted: planCompleted,
        helpfulStepIndex: helpfulStepIndex,
        cravingReturned: cravingReturned,
        contextTags: contextTags,
        hungry: hungry,
      ),
    );
  }

  Future<void> save() async {
    if (state.saving) return;
    state = state.copyWith(saving: true);
    final session = state.session.outcome == null
        ? state.session.copyWith(outcome: CravingOutcome.partlyHelped)
        : state.session;
    await ref.read(repositoryProvider).commitSession(session);
    state = state.copyWith(
      step: CravingFlowStep.complete,
      session: session,
      saving: false,
    );
  }

  void goBack() {
    final previous = switch (state.step) {
      CravingFlowStep.type => CravingFlowStep.safety,
      CravingFlowStep.category => CravingFlowStep.type,
      CravingFlowStep.subtrigger => CravingFlowStep.category,
      CravingFlowStep.intensity => CravingFlowStep.subtrigger,
      CravingFlowStep.plan =>
        state.session.safetyExit != SafetyExit.none
            ? CravingFlowStep.safety
            : CravingFlowStep.intensity,
      CravingFlowStep.followUp => CravingFlowStep.plan,
      _ => state.step,
    };
    state = state.copyWith(step: previous);
  }
}
