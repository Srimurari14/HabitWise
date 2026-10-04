# HabitWise

HabitWise is a private, offline-first Flutter app for responding to food cravings without shame, calorie tracking, weight goals, or willpower scores. One codebase, Android and iOS. Nothing leaves the phone.

The Flutter app is the whole repository. Earlier versions kept it in a `flutter_app/` subfolder next to prompts, notes and an older Electron prototype; those are gone and the app now sits at the top level.

## What a check-in does

1. **Safety first.** One tap for hunger. Glucose and eating-concern questions appear only if the profile asks for them. A yes to hunger goes straight to food: no timer, no coins, no craving logic.
2. **Craving type.** Eight of them. The type only reorders the next list; it never changes the plan.
3. **Closest need.** Five families: body, emotion, environment, habit, sensory.
4. **Detail.** 26 of them in `assets/config/tree_v1.json`, each pointing at a plan and a backup.
5. **Urge rating,** 1 to 10.
6. **Plan.** Title, one-line reason, four steps, an optional timer, and a second plan underneath. Signal Shift may be offered here.
7. **Follow-up.** Urge now, plan finished, which step helped, did it come back, what you did, optional context chips. If the urge is still up, the screen offers the second plan and the game, and asks once more whether you are sure you are not hungry. The exit is always visible and nothing is ever required.

Safety, hunger and permission check-ins are saved as notes. They never train what the app suggests and they earn no coins.

## What is in the app

- Seven-page optional setup: welcome, how it works, health context, medication patterns, safety settings, your character, and a ready page.
- 27 plans in `assets/config/interventions_v1.json`, written in plain English, with every medical caveat kept intact.
- Hunger-first routing, a glucose warning exit to the person's own care plan, and a permanent eating-concern mode that removes every delay, resistance and portion-control plan.
- Health-context filters for attention, anxiety, mood, cycle, sleep, glucose, eating concerns, sensory needs, digestion, pain and fatigue, plus user-reported medication wear-off.
- History with filters by type and date range, an outcome badge per row, a detail sheet, delete, and a one-tap repeat that carries the previous answers over.
- Insights that show the sample behind every number, a section listing which plans actually moved the person's urge, and no causal claims anywhere.
- Pure Dart statistics: descriptives, correlations, Welch t-test, Mann-Whitney U, chi-square, OLS, logistic regression.
- An Avatar tab with a code-drawn human figure, 21 earned-only cosmetics, five skin tones, padlocks and prices that say how far off you are, and a preview before you buy.
- Signal Shift, a three-lane attention game: swipe, tap, arrow keys or lane buttons, combo scoring, standard, calm, reduced-motion and one-handed modes. A hit costs points and never ends the run.
- Game recommendations driven by the current trigger, never auto-launched, and suppressed for hunger, body-need, eating-concern, glucose, sleep-risk and late mood contexts.
- Opt-in local reminders, light and dark themes, large tap targets, semantic labels.
- JSON export and a two-step local wipe.

No account, no analytics, no advertising, no in-app purchase, no paid currency.

## Known gaps

Honest list, so nobody rediscovers these the hard way:

- The 26 detail paths share only 17 distinct plans, so different answers can produce the same screen, and most backups paraphrase their main plan.
- `intentional-enjoyment` ("Choosing it on purpose") is written, excluded by the plan picker, and three tests assert it never appears.
- In eating-concern mode 21 of the 27 plans are filtered out, so nearly every path lands on the same nourishment fallback.
- Turning on glucose safety disables Signal Shift permanently, including when there are no warning signs.
- Tests cover the safety rules, the plan choice for all 26 paths, the repositories and the setup screens. The craving screens themselves are still only covered by one golden test.

## Layout

```text
lib/
  core/                   theme, shared widgets, notifications, statistics
  data/
    local/                Drift schema, SQLCipher opening, secure key
    repositories/         transactions, learning guardrails, export and delete
  features/
    onboarding/
    home/
    craving_flow/         config loading, medical rules, controller, screens
    gamification/         avatar, cosmetics, recommendation rules, the game
    history/
    insights/
    profile/
assets/
  config/                 versioned trigger tree, plans, cosmetics
  fonts/                  bundled fonts, nothing fetched at runtime
docs/                     medical safety design, release checklist
store/                    listing copy and privacy policy
```

Riverpod holds state, `go_router` handles navigation, Drift on SQLCipher handles persistence, `fl_chart` draws the insights chart.

## Running it

Requires Flutter 3.44 or newer on the Dart 3.12 SDK line. Development is on Flutter 3.47.2 and Dart 3.13.2; continuous integration pins 3.44.0, which lints more strictly than a newer local toolchain, so a clean `flutter analyze` locally does not guarantee a green check.

```bash
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter run
```

`dart run build_runner build` generates the Drift database code and has to run after a fresh clone or any schema change.

Android needs Java 17 and the Android SDK. iOS needs Xcode on macOS. Android Studio is not required: VS Code with the Flutter extension works, and so does the command line.

## Tests and CI

`flutter test` runs everything including the golden test. Golden images are rasterized by the host, so a failure of a few hundred pixels after a UI change usually means the baseline is stale rather than broken:

```bash
flutter test --update-goldens test/golden_test.dart
flutter test
```

`.github/workflows/flutter.yml` runs on every push and pull request: `flutter pub get`, code generation, `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test --exclude-tags golden`, and a debug APK build. Formatting is a hard failure, so run `dart format lib test` before pushing.

## Privacy implementation

Drift on SQLCipher. `pubspec.yaml` selects the SQLCipher native asset through the `sqlite3` hook. A random 256-bit key is created on first launch and stored with `flutter_secure_storage`, never in the database or the source. SQLCipher memory security and SQLite secure deletion are on. "Delete all" clears every table and vacuums the encrypted database. An export leaves the device only through a share destination the person picks.

## Medical boundaries

Health details are optional context, never diagnoses. The rule order is:

1. Targeted safety checks.
2. Current hunger and the answer given right now.
3. Learned local history.
4. User-reported health or medication context.
5. Craving-type priors.
6. A final safety filter over the chosen plans.

Medication timing is never inferred from a drug name. The wear-off branch activates only when someone reports appetite returning and names their usual window. The app can suggest making food easier to reach and can suggest contacting a prescriber about disruptive effects. It cannot suggest changing a medication, a dose or a schedule.

HabitWise is not emergency care, a diagnostic tool, a glucose-treatment calculator, or a substitute for a clinician or dietitian.

## Release

Android and iOS scaffolds are included. Signing credentials, store identifiers, privacy-policy hosting, support URLs, screenshots and icons are still to be supplied. Steps are in [`docs/release_checklist.md`](docs/release_checklist.md).
