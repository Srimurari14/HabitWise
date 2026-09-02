# Current state and artifact record

Handoff assembled: 2026-08-18

## Active application

- Product: HabitWise Flutter mobile app
- Source folder: `flutter_app/`
- Package version: `1.2.0+3`
- Android package ID used by the debug build: `com.habitwise.habitwise`
- Database schema version: 3
- Minimum documented Android version: Android 7.0 / API 24
- Primary verified emulator: `Pixel_10_Pro_XL`

## Verification result

- `flutter analyze`: no issues
- `flutter test`: 25 tests passed
- Android debug build: successful
- APK installation/update through ADB: successful
- Launch and runtime visual inspection: successful
- Version 2 to version 3 additive database migration: successful with prior profile preserved
- Fatal Flutter/database errors during checked run: none observed

## Release artifacts

Standalone APK:

- File: `release/HabitWise-1.2.0-Android.apk`
- Size at build: 179,786,443 bytes
- SHA-256: `BA852B5AB1E527ED8F9498D08E7CADAA8EFEE36F2ED7DC1845F3B40A41A9EC71`

Original runnable package from the build session:

- File: `release/HabitWise-1.2.0-Emulator-Package.zip`
- Size at build: 91,230,723 bytes
- SHA-256: `223D5B2DC70271D5D4A59BE91E9320AF31B550161379B0EF00A01B96472EDD5B`

The outer AI handoff ZIP has its own checksum beside it in the original workspace.

## Toolchain used

- Flutter 3.44.0 at `C:\flutter_3_44`
- Dart 3.12.0
- Java 17
- Android SDK under the original user's local Android SDK location
- PowerShell on Windows

Absolute paths are not portable. Reconfigure the toolchain normally on another machine.

## Distribution status

The APK is debug-signed for testing/personal sideloading. It is not approved or configured for public Play Store or App Store distribution. Review `flutter_app/docs/release_checklist.md` before any external release.

## Repository status

The source workspace had empty `.git` and `.agents` directories. No commit history or prior agent-memory files could be recovered. This handoff's `AGENTS.md`, `PROJECT_MEMORY.md`, and original prompt archive are the authoritative continuation memory.
