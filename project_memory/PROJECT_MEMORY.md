# HabitWise project memory

Last assembled: 2026-08-18 (America/New_York)

## Executive summary

HabitWise is a private, offline-first Flutter phone application that helps users understand and respond to food cravings. It combines a fast structured check-in, transparent rule-based trigger hypotheses, practical resistance-first plans for ordinary cravings, medical/psychiatric safety routing, local history and cautious insights, and an earned-only avatar/game system.

The current production code is in `flutter_app/`. The adjacent Electron project is a historical prototype from when the concept targeted a simulated watch interface. The product was deliberately moved to a phone format so plans, explanations, History, and Insights could contain more useful information.

## Product evolution

1. **Legacy prototype:** Electron/Node application rendered inside a watch-like frame. It established the trigger taxonomy, learning loop, statistics engine, neutral insights philosophy, and permission branches for hunger.
2. **Flutter phone rebuild:** The owner approved the concept but requested a real mobile application. The Flutter app added phone-native navigation, encrypted local storage, structured health context, medication-wear-off appetite support, expanded plans, History, Insights, Profile, notifications, export, and deletion.
3. **Plan-tone revision:** The owner felt ordinary plans were too permissive about the craved food. The resulting direction is resistance-first and direct: do not routinely tell users to eat the food they are trying to avoid; explain why the craving may be occurring and provide a realistic, low-friction way to move through it. Intentional consumption is not presented as the default plan.
4. **Safety nuance retained:** Firmness applies to ordinary cue-driven cravings, not genuine hunger or medical/psychiatric safety routes. The app must not coach overriding hunger, glucose warning states, medication-wear-off hunger, eating-concern safety needs, or other body needs.
5. **Gamification:** HabitWise 1.2 added an original customizable avatar, earned coins, non-punitive momentum, cosmetics, outfits, milestones, and the three-lane Signal Shift game. The game is conditionally recommended only when a brief attention shift plausibly fits the selected trigger.

The complete source prompts are preserved under `original_prompts/`.

## Current user experience

The bottom navigation has five tabs:

1. **Home** — entry point for a craving check-in, current summary, gentle reflection, and local-privacy explanation.
2. **History** — neutral craving records plus a separate Signal Shift session section.
3. **Avatar** — layered character, coin/momentum/weekly status, Signal Shift practice, locker, earned-item shop, saved outfits, and game comfort settings.
4. **Insights** — sample-size-gated descriptive patterns, charts, plan metrics, medication/context observations, and Signal Shift before/after patterns.
5. **Profile** — optional health/medication contexts, reminders, theme, privacy, JSON export, and two-step local deletion.

The craving flow is:

1. Targeted safety questions.
2. Craving surface type.
3. Closest trigger category.
4. Specific subtrigger.
5. Before-intensity rating.
6. Expanded plan with a transparent working hypothesis, evidence signals, plain-language mechanism, direct immediate plan, checkable steps, rationale, timer when safe, backup plan, and optional Signal Shift card when eligible.
7. After-intensity/outcome/follow-up.
8. Transactional local save and adaptive update when learnable.

## Clinical and behavioral boundaries

HabitWise is not a diagnostic tool. Profile data is optional context and cannot overrule a current safety answer. Rule priority is:

1. Current safety state.
2. Current hunger answer.
3. Current selected trigger/subtrigger.
4. Learned local history.
5. Optional user-reported health and medication context.
6. Base priors and final intervention filter.

Medication wear-off support is based only on a user explicitly reporting hunger/appetite returning and specifying a usual window. The app may recommend planning accessible nourishment and contacting a prescriber about disruptive effects, but never changing treatment.

Eating-concern safety mode is persistent. It removes delay/resistance/portion framing and disables timers. Its protected plans do not train recommendations or earn craving-resistance coins.

Ordinary craving language should be clear and committed without shame. The app can say the user does not have to obey an urge and should finish the process first. It should not call a user weak, bad, a failure, or dishonest. It should never make nourishment itself a loss.

## Trigger and plan model

Flutter uses eight craving types and five trigger categories:

- physiological/body need
- emotional
- environmental
- habitual/habit loop
- sensory

There are 26 JSON-defined subtriggers under `flutter_app/assets/config/tree_v1.json`, with interventions in `interventions_v1.json`. `MedicalRulesEngine` handles safety prechecks, ranking, and terminal filtering. `PlanExplanationEngine` creates the working-hypothesis copy, supporting signals, mechanisms, alternative possibilities, firm lead, step rationale, backup explanation, and safety reminder.

Protected plan IDs are hard-coded in the repository as a defense against malformed configuration:

- `permission-to-eat`
- `steady-snack`
- `wear-off-meal`
- `cycle-support`
- `permission-and-support`
- `glucose-safety-exit`

## Signal Shift recommendation logic

Signal Shift is a short competing-attention option, not a universal response. The current rule engine may recommend it for suitable cue, habit, sensory, understimulation, task-avoidance, stress, or low-activation contexts.

It does not recommend the game when:

- recommendations are disabled;
- a safety exit is active;
- the user reports hunger;
- the selected category is physiological;
- the trigger is not on the suitable list;
- eating-concern safety mode is active;
- glucose safety is active;
- a late-evening/overnight context combines with bipolar/mood or sleep-condition context.

Anxiety, stress, chronic pain/fatigue, and user preferences can select calm or reduced-motion mode. ADHD is not a sufficient reason by itself. The recommendation explains why it appeared, remains optional, never auto-launches, and includes a stop-if-distressed safety note.

## Game behavior

Signal Shift is one original three-lane runner-style game:

- swipe or large buttons move left/right;
- swipe up or Jump clears obstacles;
- Focus Sparks increase score and combo;
- obstacles reset combo and subtract a small score amount but never end the game;
- standard, calm, and reduced-motion modes are available;
- practice offers 3, 5, or 7 minutes;
- recommended sessions use a contextual 3- or 5-minute duration;
- exiting early is allowed and records no game reward;
- recommended sessions collect an after-intensity and helpfulness check-in;
- practice and recommended sessions are stored separately.

## Avatar and economy

The avatar is a layered `CustomPainter` character. Cosmetics are data-driven through `assets/config/cosmetics_v1.json`. Slots include base color, eyes, expression, top, bottom, shoes, scarf, glasses, hat, back item, trail, celebration, and background.

Current reward implementation:

- complete an ordinary craving plan: 6 coins;
- complete the follow-up: 2 coins;
- move through or redirect an ordinary craving: 8 coins;
- milestone bonuses: 15 coins at 3 and 7 momentum days; 30 at 14 and 30 days;
- Signal Shift recommended session: 3–10 coins based on score;
- practice session: 0–3 coins based on score;
- all game rewards combined: maximum 30 coins per local day.

Safety/protected plans do not receive craving-resistance rewards. Ledger event IDs, milestone IDs, ownership primary keys, and transactional purchase checks provide idempotency. Purchases fail without sufficient coins and never create a negative balance. There is no real-money path.

Momentum uses local calendar days and includes a one-day grace mechanism. A check-in on the same day does not repeatedly extend the streak. Weekly activity displays distinct active check-in days since Monday. Momentum is intended as supportive continuity, not a punishment score.

## Persistence model

The Drift/SQLCipher database schema is version 3. Tables:

- `UserProfiles`
- `CravingLogs`
- `LearnedPriors`
- `InterventionStats`
- `ReflectionEntries`
- `AppSettings`
- `AvatarProfiles`
- `OwnedCosmetics`
- `OutfitPresets`
- `CoinLedger`
- `StreakStates`
- `MilestoneUnlocks`
- `GameSessions`

Version 2 added plan completion, helpful-step, and recurrence fields. Version 3 additively created avatar/game tables. Export and deletion cover all current tables. SQLCipher uses a random key stored with `flutter_secure_storage`; cipher memory security and secure deletion pragmas are enabled.

## Flutter architecture and key files

- `flutter_app/lib/app.dart` — router, startup gate, five shell branches, Signal Shift route.
- `flutter_app/lib/providers.dart` — database, repository, config, avatar/economy, logs, games, and derived providers.
- `flutter_app/lib/data/local/app_database.dart` — Drift schema and migrations.
- `flutter_app/lib/data/repositories/habit_repository.dart` — profile, craving transaction, adaptive learning, rewards, momentum, export, deletion.
- `flutter_app/lib/data/repositories/gamification_repository.dart` — starter initialization, avatar persistence, purchases, outfits, ledger, game recording and caps.
- `flutter_app/lib/features/craving_flow/` — models, config loader, medical rules, explanation engine, controller, complete phone UI.
- `flutter_app/lib/features/gamification/domain/game_recommendation_engine.dart` — conservative recommendation rules.
- `flutter_app/lib/features/gamification/presentation/avatar_character.dart` — layered avatar painter.
- `flutter_app/lib/features/gamification/presentation/avatar_screen.dart` — avatar tab/shop/locker/settings.
- `flutter_app/lib/features/gamification/presentation/signal_shift_game_screen.dart` — game intro, loop, controls, results, persistence.
- `flutter_app/lib/features/history/` — craving and game records.
- `flutter_app/lib/features/insights/` — cautious insight engine and UI.
- `flutter_app/lib/features/profile/` — health context, privacy, export/delete.
- `flutter_app/assets/config/` — versioned craving/intervention/cosmetic configuration.
- `flutter_app/docs/medical_safety_design.md` — detailed safety architecture.
- `flutter_app/docs/release_checklist.md` — production release requirements.

## Legacy Node prototype

The historical app is under `legacy_node_prototype/`. Its `CLAUDE.md` is an unusually detailed memory file covering the original taxonomy, analytics, insights philosophy, learning loop, demo seeding, design system, and watch-focused concept. The legacy analytics implementation may be useful if richer statistical analysis is later ported into Flutter.

Do not copy legacy assumptions blindly. The active Flutter app uses a revised category model, stronger phone-oriented plans, encrypted persistence, structured medical safety, and gamification.

## Current visual identity

- Phone-first light/dark Flutter interface.
- DM Sans body type and Playfair Display editorial headings.
- Calm cream, deep green, mint, plum/lavender, coral, and cyan accents.
- Original Signal Shift hero art at `flutter_app/assets/images/signal_shift_hero.png`.
- The hero was generated with a prompt excluding food, gambling, body transformation, copyrighted characters, and brand likenesses.
- The layered live avatar is programmatic and intentionally independent from the raster hero so cosmetics can update instantly.

## Verification status at handoff

- Flutter static analysis: no issues.
- Flutter tests: 25 passed.
- Debug APK built successfully.
- Exact APK installed on a `Pixel_10_Pro_XL` Android emulator.
- Existing encrypted profile survived the schema 2-to-3 upgrade.
- Home, five-tab navigation, Avatar, Signal Shift intro, live gameplay, and runtime logs were visually checked.
- No Flutter fatal exception or database exception appeared during the verification run.
- The distribution ZIP was opened programmatically and its internal APK hash matched the standalone APK.

See `CURRENT_STATE.md` for exact artifact hashes.

## Known limitations and technical debt

- The included APK is debug-signed and large because it is a universal testing build.
- Production Android signing, final application ID review, Play App Signing, app bundle, icons, store URLs, store listing completion, accessibility review, privacy review, and clinical review remain outstanding.
- iOS scaffolding exists but no iOS archive was built or verified in this Windows environment.
- The notification plugin emitted a future Kotlin Gradle Plugin migration warning during the build; current builds succeed.
- Signal Shift is intentionally a small first game, not a fully polished game engine. It has no audio implementation despite stored sound preferences.
- Haptics/high-contrast preferences exist in the model, but the current settings UI exposes only reduced motion, calm mode, one-handed controls, and recommendation enablement. High contrast influences the track if enabled programmatically.
- Outfit deletion exists in the repository but is not surfaced prominently in the current UI.
- Weekly activity currently counts distinct check-in days, not a complex success-rate model.
- Game insights use simple minimum-sample-size descriptive counts; they are not randomized evidence and must not be framed as efficacy proof.
- No backend, synchronization, account recovery, cloud backup, or cross-device transfer exists.
- No automated end-to-end test completes a multi-minute live game; gameplay was manually emulator-verified.
- Clinical content has safety-oriented engineering rules but is not a substitute for formal clinical validation.

## Recommended next steps

1. Initialize Git and commit this handoff unchanged as the baseline.
2. Run the included verification commands on the new developer's machine.
3. Add repository tests for momentum day transitions using an injectable clock.
4. Add widget/integration tests for Avatar purchases/equipment, plan-to-game navigation, early game exit, recommended after-check-in, and History/Insights rendering.
5. Have clinical and eating-disorder-informed reviewers audit every plan and reward interaction.
6. Conduct accessibility testing for screen readers, large text, contrast, reduced motion, motor controls, and seizure/motion sensitivity.
7. Decide whether Signal Shift artwork/avatar style is a prototype or final brand direction.
8. Only after those reviews, prepare production signing and closed-store testing.

## Decision rule for future AI assistants

When a proposed feature increases “toughness,” motivation, engagement, streak pressure, or game stimulation, check it against hunger, eating-concern, glucose, sleep, anxiety, bipolar/mood activation, pain/fatigue, compulsive use, accessibility, privacy, and reward-abuse risks before implementation. Prefer explicit rule tables and tests over vague prompt-only behavior.
