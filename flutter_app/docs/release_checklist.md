# Release checklist

## Code and data

- Run `dart run build_runner build` and commit `app_database.g.dart`.
- Run `dart format --output=none --set-exit-if-changed lib test`.
- Run `flutter analyze`.
- Run `flutter test --exclude-tags golden`.
- Regenerate and visually inspect the golden test on the release host.
- Test a schema upgrade from every previously published database version.
- Verify `PRAGMA cipher_version` is non-empty on physical Android and iOS devices.
- Verify a copied database cannot be opened as plain SQLite.
- Verify export, secure deletion, and reinstall behavior on both platforms.

## Safety regression

- Genuine hunger exits before predictions and shows no delay timer.
- Glucose warning state outranks all craving branches.
- Current user answers outrank medication and learned priors.
- Medication wear-off routing activates only from a user-reported effect and time window.
- Eating-concern mode cannot be switched off through routine profile editing.
- Eating-concern mode exposes no delay, resistance, portion, win/loss, or streak copy.
- Every protected nourishment/safety plan remains non-learnable after malformed-input tests.
- No plan suggests a medication, dose, timing, glucose treatment, calorie target, or weight goal.

## Android

- Replace debug signing with a protected upload/release keystore.
- Confirm final application ID and Play App Signing setup.
- Build and test an Android App Bundle: `flutter build appbundle --release`.
- Verify notification permission behavior on Android 13+ and rescheduling after restart.
- Supply adaptive launcher and notification icons.
- Complete Data safety answers from `store/google_play.md`.

## iOS

- Set the final bundle identifier, Apple team, signing certificate, and provisioning profile.
- Build/archive on current macOS/Xcode: `flutter build ipa --release`.
- Verify notification permission, local schedule, export share sheet, Dynamic Type, and VoiceOver.
- Supply App Store icon and phone screenshots.
- Complete App Privacy answers from `store/app_store.md`.

## Publication

- Host the final privacy policy and support page on stable HTTPS URLs.
- Replace all `[PUBLISHER ...]` placeholders in store drafts.
- Have clinical/safety, privacy, accessibility, and store-compliance reviewers sign off.
- Run closed testing before production rollout.
- Stage rollout and monitor user-submitted safety/support reports without adding behavioral telemetry.
