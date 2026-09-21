# Instructions for AI coding assistants

These instructions apply to the entire repository. The human owner's newest explicit request takes precedence, but do not silently weaken the safety invariants below.

## Source of truth

- This repository root is the Flutter app, currently HabitWise `1.2.0+3`.
- Historical material (original prompts, project memory notes, screenshots, the legacy Node prototype) is kept outside this repository. It records past intent and must not be mistaken for executable source or current requirements.

## Product intent

HabitWise helps a user interrupt ordinary hedonic or cue-driven food cravings with a direct, realistic plan. For ordinary cravings, plans should confidently encourage completing the coping process and choosing a non-craved alternative rather than casually suggesting the craved food.

That firmness must never override genuine hunger or health safety. Physical hunger, possible glucose warning states, medication-wear-off hunger, eating-concern safety, cycle-related appetite, and other body needs are care routes, not failures. Do not turn nourishment into a coin/streak optimization problem.

## Non-negotiable safety invariants

- Ask about current physical hunger before predictive craving logic.
- Genuine hunger exits to a nourishment/permission plan with no delay or resistance timer.
- A possible glucose warning state outranks all craving branches and directs the user to their established care plan or urgent help. Never calculate glucose treatment.
- Eating-concern safety mode removes restriction, compensation, delay, portion-control, and win/loss framing. Routine profile edits cannot silently disable this mode.
- Protected nourishment and safety plans must remain non-learnable and must not award craving-resistance coins.
- Medication context is user-reported. Never infer medication duration from a drug name or suggest changing medication, dose, or timing.
- Psychiatric contexts are optional modifiers, never diagnoses. ADHD alone must not automatically trigger a game recommendation.
- Do not claim a plan, game, trigger, medication, or diagnosis caused an outcome. Insights are descriptive and show sample sizes.
- Never add calorie goals, weight-loss scores, compensatory exercise, food morality, or body-transformation rewards.
- The game must never replace eating, sleep, emergency action, or clinician-directed care.

Protected plan IDs are enforced in `lib/data/repositories/habit_repository.dart` and documented in `docs/medical_safety_design.md`.

## Gamification invariants

- Coins are earned only. No real-money purchase, advertising, paid currency, loot box, chance-based reward, or manipulative scarcity.
- Purchases are atomic and idempotent; balances cannot become negative.
- Reward events use unique ledger IDs. Preserve duplicate-award protections.
- Safety/nourishment flows preserve momentum but do not award resistance coins.
- Signal Shift is optional and never auto-launches.
- A missed game object resets a combo but never eliminates the player.
- Recommended game sessions and voluntary practice sessions remain distinguishable in storage and History.
- Daily game rewards are capped at 30 coins. Do not remove caps without explicit owner approval and abuse analysis.
- Maintain calm, reduced-motion, and one-handed options.

## Data and privacy invariants

- The application is offline-first and has no account, analytics SDK, ads SDK, or telemetry client.
- Persistence uses Drift with SQLCipher and a key stored via secure storage.
- Schema changes must be additive and version-gated. Never drop or rewrite user tables without an explicit migration and export path.
- Update `exportAll()` and `deleteAllData()` whenever a persistent table is added.
- Do not commit secrets, signing keys, secure-storage contents, user databases, or personal exports.

## Architecture and implementation conventions

- Riverpod owns state and repositories.
- `go_router` owns navigation.
- Drift owns persistence; `app_database.g.dart` is generated and included.
- Versioned behavioral and cosmetic configuration lives under `assets/config/`.
- The layered avatar is drawn with Flutter `CustomPainter`; the Signal Shift hero raster is an original generated asset under `assets/images/`.
- Keep the craving flow answerable with short taps and avoid typing during acute craving steps.
- Preserve source-tagged, hedged explanations such as “working hypothesis,” “may,” and “in your entries.”
- Use `dart run build_runner build` after changing Drift tables.
- Prefer pure, separately tested rules for safety, recommendations, statistics, and reward calculations.

## Required verification for meaningful changes

From the repository root:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

For database changes, test upgrades from schema version 2 and 3. For UI/game changes, install the exact built APK on an Android emulator and inspect Home, Avatar, Signal Shift intro, live gameplay, Plan integration, History, and Insights. For store release, follow `docs/release_checklist.md`.

## Do not assume

- Do not assume the debug APK is store-ready.
- Do not assume clinical validation has occurred.
- Do not assume iOS has been built; only scaffolding is present.
- Do not assume the generated game artwork is a final brand identity.
- Do not assume the owner wants the legacy Node app changed when asking about HabitWise.