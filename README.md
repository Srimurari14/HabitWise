# HabitWise mobile

HabitWise is a private, offline-first Flutter app for understanding and responding to food cravings without shame, calorie tracking, weight goals, or willpower scoring. It supports iOS and Android from one codebase.

The original Electron/Node project remains untouched in the adjacent `craving-coach` directory. This directory is the new phone-first product.

## What is implemented

- Six-step optional onboarding with privacy, health-context, medication-pattern, and safety settings.
- Eight craving types, five root trigger families, and 26 JSON-defined subtriggers.
- Resistance-first intervention plans with transparent driver hypotheses, supporting signals, plain-language mechanisms, checkable 5–10 minute actions, step-by-step rationale, and a second strategy when the first does not work.
- Hunger-first routing: physical hunger immediately produces a permission-to-eat plan.
- User-reported medication effects, including appetite returning as an ADHD medication wears off.
- Psychiatric and physical context filters for ADHD/attention, anxiety, mood, cycle-related appetite, sleep, glucose needs, eating concerns, sensory needs, digestive needs, pain, and fatigue.
- Glucose warning-state exit to an existing care plan; the app never diagnoses or calculates treatment.
- Persistent eating-concern safety mode that removes delay, resistance, portion-control, and win/loss framing.
- Transactional craving logging that records before/after intensity, plan completion, the most helpful action, recurrence, context, and the user's final decision. Safety, nourishment, and permission plans are never learnable—even if malformed data marks them otherwise.
- History with filters and expanded plan-result details.
- Insights with minimum sample sizes, visible denominators, completion and redirection rates, descriptive associations, and no causal claims.
- Pure Dart descriptive statistics, correlations, Welch t-test, Mann–Whitney U, chi-square, OLS, and logistic regression.
- Opt-in local reminders using device time and local history; no server is involved.
- Light/dark/system themes, large tap targets, semantic labels, DM Sans, and Playfair Display.
- Human-readable JSON export and two-step local-data deletion.
- A fifth Avatar tab with an original layered character, earned-only cosmetics, a locker, saved outfits, momentum milestones, and comfort controls. No real-money currency, ads, loot boxes, or paid unlocks are present.
- Signal Shift, a three-lane attention-shift game with standard, calm, reduced-motion, swipe, jump, and one-handed controls. Mistakes reset a combo but never eliminate the player.
- Conservative game recommendations that are based on the current trigger rather than a diagnosis, never auto-launch, and are suppressed for hunger, physical-need, eating-concern, glucose-safety, sleep-risk, and late mood-activation contexts.
- Separate local game history and cautious game insights that require at least three relevant before/after check-ins and never claim causation.

## Architecture

```text
lib/
  core/                   theme, reusable UI, notifications, statistics
  data/
    local/                Drift schema, SQLCipher opening, secure key
    repositories/         transactions, learning guardrails, export/delete
  features/
    onboarding/
    home/
    craving_flow/         JSON config, medical rules, controller, phone UI
    gamification/         avatar model, cosmetics, recommendation rules, game
    history/
    insights/
    profile/
assets/
  config/                 versioned tree and intervention definitions
  fonts/                  bundled brand fonts; no runtime font fetch
```

Riverpod owns app and feature state, `go_router` owns navigation, Drift owns persistence, and `fl_chart` renders the compact insights chart.

## Toolchain

- Flutter 3.44.0
- Dart 3.12.0
- Java 17 and an Android SDK for Android builds
- Xcode on macOS for iOS builds

From this directory:

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test --exclude-tags golden
flutter run
```

The Windows environment used to create this handoff has Flutter at `C:\flutter_3_44\bin\flutter.bat`. Add it to `PATH` or substitute that full path in the commands.

Golden tests are tagged because font rasterization can vary by host OS. Regenerate and verify the baseline on the release host:

```powershell
flutter test test/golden_test.dart --update-goldens
flutter test test/golden_test.dart
```

## Privacy implementation

The database uses Drift on SQLCipher. `pubspec.yaml` selects the SQLCipher native asset through the `sqlite3` hook. A random 256-bit key is created on first launch and saved with `flutter_secure_storage`; it is not stored in the database or source. SQLCipher memory security and SQLite secure deletion are enabled. “Delete all” clears every app table and vacuums the encrypted database.

There is no account, advertising SDK, analytics SDK, telemetry client, in-app purchase, or paid currency. Notification schedules, avatar ownership, rewards, game sessions, and insight calculations remain local. An export leaves the device only through the operating-system share destination explicitly chosen by the user.

## Medical and psychiatric boundaries

Health details are optional context, not diagnoses. The rule order is:

1. Targeted safety checks.
2. Current hunger and current user answer.
3. Learned local history.
4. User-reported health or medication context.
5. Base craving-type priors.
6. Final intervention safety filter.

Medication timing is never inferred from a drug name. A medication wear-off branch activates only when the user reports appetite returning and identifies their usual time window. The app can suggest making food easier to access and can suggest contacting a prescriber about disruptive effects; it cannot recommend changing a medication, dose, or schedule.

HabitWise is not emergency care, a diagnostic tool, a glucose-treatment calculator, or a replacement for a clinician or dietitian.

## Release notes

Android and iOS scaffolds are included. Production signing credentials, store-team identifiers, final privacy-policy hosting, support URLs, screenshots, and app icons must be supplied by the publisher before store submission. Release steps are in [`docs/release_checklist.md`](docs/release_checklist.md).
