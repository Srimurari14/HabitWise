# HabitWise complete AI-development handoff

This archive is intended for a human developer who will also use AI coding assistants. It contains the current Flutter application, the earlier Electron/Node prototype, the runnable Android build, original specification prompts, screenshots, safety documentation, and durable project-memory files.

## Start here

1. Read `AGENTS.md` at the root of this archive.
2. Read `project_memory/PROJECT_MEMORY.md` and `project_memory/CURRENT_STATE.md`.
3. Treat `flutter_app/` as the production application and the source of truth.
4. Treat `legacy_node_prototype/` as historical reference only unless the owner explicitly asks to revive it.
5. Review `original_prompts/PROMPT_INDEX.md` before making product-level changes.

If beginning a new AI-assistant conversation, paste the contents of `project_memory/AI_CONTINUATION_PROMPT.md` and attach this archive.

## Run the Android build

The simplest option is the ready-built debug APK:

- `release/HabitWise-1.2.0-Android.apk`
- Windows emulator helper: `release/run_habitwise_emulator.ps1`
- Windows physical-device helper: `release/install_habitwise_android.ps1`

With Android Studio's Pixel emulator configured, open PowerShell in `release/` and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\run_habitwise_emulator.ps1 -AvdName Pixel_10_Pro_XL
```

This is a debug-signed testing build, not a Play Store production release.

## Develop the Flutter app

Requirements:

- Flutter 3.44.x / Dart 3.12.x or a compatible newer toolchain
- Java 17
- Android SDK for Android work
- Xcode/macOS for iOS builds

From `flutter_app/`:

```powershell
flutter pub get
dart run build_runner build
flutter analyze
flutter test
flutter run
```

On the original Windows machine, Flutter was installed at `C:\flutter_3_44\bin\flutter.bat`. That absolute path is only historical context; other machines should configure Flutter normally.

## Important boundary

HabitWise contains psychiatric and physical-health context, but it is not a diagnostic tool, medical treatment, emergency service, medication adviser, glucose-treatment calculator, or substitute for clinical review. Safety-routing invariants in `AGENTS.md` must be preserved.

## Archive design

Dependency caches and generated build directories were deliberately excluded because they add several gigabytes, are machine-specific, and can be regenerated. Lockfiles, generated Drift source, native platform scaffolds, the verified APK, and all authored source/configuration are included.
