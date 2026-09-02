# Research and validation status

HabitWise contains health-context logic and safety-oriented copy, but this handoff is a software implementation record, not a completed clinical evidence dossier.

## What exists

- `flutter_app/docs/medical_safety_design.md` documents engineering safety boundaries.
- `legacy_node_prototype/docs/habitwise_medical_layer_design_proposal.md` is a detailed historical psychiatric/physical-health design proposal.
- Unit tests cover hunger-first routing, glucose priority, user-reported medication-wear-off context, eating-concern filtering/persistence, protected non-learning plans, game recommendation exclusions, anxiety calm mode, late bipolar/mood caution, and reward-economy invariants.
- User-facing insight language is intentionally descriptive and non-causal.

## What does not exist yet

- No formal systematic literature review is bundled.
- No clinician, dietitian, eating-disorder specialist, psychiatric specialist, diabetes specialist, accessibility expert, or institutional review sign-off is represented by this archive.
- No clinical trial, efficacy claim, regulatory clearance, or medical-device determination exists.
- The app must not be marketed as diagnosing, treating, preventing, or curing a condition based on this implementation alone.

## Guidance for future research work

When revising medical or psychiatric behavior, use current primary research and authoritative clinical guidance, record citations and publication dates, separate evidence from product inference, and have qualified reviewers evaluate the final user-facing behavior. Pay special attention to eating-disorder risk, stimulant medication appetite effects, glucose safety, bipolar activation/sleep, anxiety and overstimulation, pain/fatigue, compulsive gaming, youth use, and accessibility.

Do not use a general association to infer an individual user's diagnosis or cause. Preserve the app's current hierarchy in which direct hunger and safety answers outrank predictions and engagement features.
