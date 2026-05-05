# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project goal

Fit-Log is a daily fashion (OOTD) camera app whose distinguishing feature is **shooting today's outfit in the same pose as a previously saved photo**. Two camera modes serve that goal:

- **Split mode** — viewport is split 50/50; one side shows a reference photo, the other shows the live camera preview, with a swappable side and a divider as an alignment guide.
- **Overlay mode** — the reference photo is composited over the live preview at user-controlled opacity (slider, capped at 50%).

A separate **layout/grid composer** (2x2, 3x3, 3x2, 4x2) lets the user combine multiple OOTD photos into a single saved image.

This project goal is the only thing the user intends to keep across the upcoming rewrite (see next section).

## Stack & key design rule

The app stays on **Flutter**, but the UI is being rebuilt against a new design system. **Do not use Material or Cupertino widgets for visual elements** — that includes `AppBar`, `Scaffold`'s default decorations, `ElevatedButton` / `TextButton` / `IconButton`'s built-in look, `Slider`, `FloatingActionButton`, the default `showDialog` / `showModalBottomSheet` shells, and `SnackBar`. Build screens with primitive widgets (`Container`, `Stack`, `Row`/`Column`, `SizedBox`, `Padding`, `Align`, `GestureDetector`, `CustomPaint`, `ShaderMask`, `BackdropFilter`) and reach for components in `lib/design/components/` (to be created — see Phase 1 in README) rather than Material equivalents. `MaterialApp` / `CupertinoApp` themselves are fine as routing/localization shells; the rule applies to the *rendered* visual surface only.

The existing code in `lib/` was built on Material (e.g. `AppBar`, `FloatingActionButton`, `Slider`, `ElevatedButton` inside `main.dart`'s theme). Treat that styling as **legacy that will be replaced** — the camera/storage/i18n logic is intended to be kept, but anything visual is up for rewrite once the design system arrives in `docs/` and is translated into `lib/design/`.

## Commands

```bash
flutter pub get                              # install deps
flutter run                                  # run on connected device/simulator
flutter analyze                              # lint (uses analysis_options.yaml -> flutter_lints)
flutter test                                 # run all tests
flutter test test/widget_test.dart           # run a single test file
```

There is currently only one test file (`test/widget_test.dart`, the default Flutter scaffold) — the project has effectively no test coverage.

## Current architecture worth knowing

Most of the code is straightforward Flutter; only call out things that would surprise someone reading a single file:

- **No state management library.** All screens are `StatefulWidget`s and services are plain singletons (`StorageService`, `CameraService`, `LocaleService`, `TutorialService`). Don't go looking for Provider/Riverpod/Bloc — there isn't any.
- **Photo persistence is two-tier.** `StorageService` saves each capture to the app documents directory under `ootd_photos/` *and* writes it to the device's photo gallery via `image_gallery_saver`. A single `photos_metadata.json` file in the app documents root is the index — `loadPhotos()` parses it, filters by `file.exists`, and sorts newest-first. There is no database.
- **Localization is hand-rolled.** `lib/l10n/app_localizations.dart` is a single Dart file containing a nested `Map<locale, Map<key, String>>` for en/ko/ja/zh. The standard Flutter ARB workflow is **not** in use, so adding a string means editing that map directly in all four languages, not generating from `.arb` files.
- **Camera mode + reference photo state lives in `CameraScreen`.** `_currentMode`, `_referencePhoto`, `_overlayOpacity`, `_isLeftReference` are screen-local. The "use as reference" flow comes back via `Navigator.push` from `PhotoViewerScreen` with a callback.
- **Tutorial overlay is a one-shot per-screen flag.** `TutorialService` reads/writes `shared_preferences` keys (`tutorial_home_seen`, `tutorial_camera_seen`); each screen checks its flag in `initState` and renders `TutorialOverlay` over the scaffold via a `Stack` if unseen.
- **Orientation is locked to portrait** in `main.dart` via `SystemChrome.setPreferredOrientations`. Any new camera/layout work should assume portrait-only.

## Platform configuration that matters

When changing camera/storage behavior, both platform manifests must stay in sync:

- iOS: `ios/Runner/Info.plist` — `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription`.
- Android: `android/app/src/main/AndroidManifest.xml` — `CAMERA`, `READ_MEDIA_IMAGES`, plus `WRITE_EXTERNAL_STORAGE` capped at SDK 32. `minSdkVersion` is 26 (Android 8.0).

Permission requests are funneled through `lib/utils/permissions.dart` (`PermissionUtils.requestCameraPermission` / `requestStoragePermission`); call those rather than touching `permission_handler` directly.
