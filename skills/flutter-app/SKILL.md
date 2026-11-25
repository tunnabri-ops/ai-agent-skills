---
name: flutter-app
description: Use when building a production Flutter app in Dart with clean architecture, Riverpod or Bloc state management, Dio networking, local storage, navigation, widget and integration tests, and Android and iOS builds ready for store submission.
---

# Flutter App

Build a production Flutter app that is fast, testable, and ready for the
stores. Keep the UI thin, keep business rules in the domain layer, and keep
every network call behind a repository interface. A feature is not done
until it works offline where it should, has a loading and an error state,
has a widget test, and passes `flutter analyze` with no issues.

## When to Use This Skill

- The user asks for a Flutter app, a Dart mobile app, or an Android/iOS app.
- An existing Flutter app needs state management, networking, or storage.
- A prototype must become a production app ready for the Play Store or App Store.
- The user asks for Riverpod, Bloc, Dio, clean architecture, or Flutter testing.

## Stack Decisions

- Language: Dart 3, Flutter 3.24 or newer, with null safety and sound typing everywhere.
- Architecture: clean architecture with three layers: presentation, domain, data.
- State management: Riverpod for most apps, Bloc when the team wants strict event/state flows. Pick one; do not mix both.
- Networking: Dio with interceptors for auth, logging, and retries.
- Local storage: flutter_secure_storage for tokens, SharedPreferences for settings, Hive or Drift for offline data.
- Navigation: go_router with typed routes and deep links.
- Code generation: freezed for state and models, json_serializable for JSON, riverpod_generator where Riverpod is used.
- Tooling: `flutter analyze`, `dart format`, and `flutter test` on every change.

## Project Layout

```text
lib/main.dart                   # entry point only: providers, router, theme
lib/core/config/env.dart        # environment and base URLs
lib/core/network/dio_client.dart
lib/core/network/api_exception.dart
lib/core/router/app_router.dart
lib/core/theme/app_theme.dart
lib/core/widgets/loading_view.dart, error_view.dart
lib/features/auth/presentation/auth_page.dart, auth_controller.dart
lib/features/auth/domain/auth_repository.dart, user.dart
lib/features/auth/data/auth_repository_impl.dart, auth_remote_data_source.dart
lib/features/home/presentation/, domain/, data/   # same three-layer split
assets/images/  assets/fonts/
test/features/auth/auth_page_test.dart
integration_test/app_test.dart
```

Rules: presentation holds widgets and controllers only. Domain holds
entities, repository interfaces, and use cases, with no Flutter or Dio
imports. Data holds repository implementations, data sources, and DTOs.
A feature folder is self-contained; moving it must not break another feature.

## Setup Commands

```bash
flutter --version
flutter create --org com.example --project-name shop_app shop_app
cd shop_app
flutter pub add flutter_riverpod dio go_router freezed_annotation
flutter pub add --dev flutter_test build_runner freezed json_serializable
flutter pub add flutter_secure_storage shared_preferences hive_flutter
cp .env.example .env
flutter pub get
flutter analyze
flutter run
```

Environment rules: base URL, API keys, and feature flags come from
environment config, never hard-coded in Dart. Keep a `.env.example` with
placeholder values and keep `.env` out of version control. Fail at startup
with a clear message when a required value is missing.

## State Management

Riverpod pattern: one provider per feature, one immutable freezed state class per screen, with states `Initial`, `Loading`, `Loaded(items)`, and `Error(message)`. State holds `isLoading`, `data`, and `error`, never three separate booleans that can disagree. Bloc pattern, when Bloc is chosen instead: one event per user action (`LoadItems`, `RefreshItems`, `SearchItems(query)`), one state per screen state (`Initial`, `Loading`, `Loaded`, `Error`), and no business logic inside the widget.

Rules: widgets read state and dispatch actions; they never call Dio or a
database directly. Side effects such as navigation and snackbars happen in
a listener, not in the build method. Controllers are disposed with the
screen, and streams are cancelled when the provider is disposed.

## Networking with Dio

Configure one Dio client for the whole app: base URL, 15-second connect timeout, 30-second receive timeout, JSON content type, an auth interceptor that adds the bearer token and refreshes it once on a 401, and a log interceptor with `responseBody: false`.

Error handling: map Dio errors to typed exceptions in one place.
`401` means refresh the token once, then retry; a second `401` means sign
out. `404` means the item does not exist. `422` means a validation error
with one message per field. `500` and timeouts mean show a retry screen,
never a blank page. Never show a raw exception message to the user; map it
to a plain-language message and log the technical detail.

Offline rules: cache the last successful list response in Hive or Drift,
show it with a "Last updated" label when offline, and queue mutations to
retry when connectivity returns. Check connectivity with
`connectivity_plus` before assuming a failure is a server error.

## Local Storage

- Tokens and secrets: `flutter_secure_storage` only, never SharedPreferences.
- Settings and flags: SharedPreferences, with defaults defined in one file.
- Offline data: Hive for simple key-value caches, Drift for relational data.
- Images: `cached_network_image` with a placeholder and an error widget.
- Clear all user data on sign-out: tokens, caches, and the local database.
- Never store a password, a full card number, or a refresh token in plain text.

## Navigation

Use go_router with typed routes and a redirect guard for auth: logged-out users are redirected to `/login`, logged-in users are redirected from `/login` to `/home`, and `/item/:id` opens the item page. Rules: deep links open the right screen even from a cold start. The back
button returns to the previous screen, never to the login screen after a
successful sign-in. Route parameters are parsed and validated in one place;
a bad ID shows a not-found screen, not a crash.

## UI and Theming

Build with Material 3, one theme file, and named spacing and text styles.
Every screen handles four states: loading, loaded, empty, and error.
Every button shows a disabled state while its action is running. Text
scales with the system font size; do not fix text at a size that clips at
large accessibility settings. Touch targets are at least 48 by 48 points.
Images always have a placeholder and an error fallback. Forms validate on
submit and show one error per field, next to that field.

## Testing

Run unit tests for use cases and repositories, widget tests for screens,
and integration tests for the main user journey.

```bash
flutter test
flutter test --coverage
flutter test integration_test/app_test.dart
```

Widget test pattern: pump the screen with a test provider, enter text, tap the button, and expect the new state. Mock the repository, never the network. A widget test must not call a real API. Example: a login test enters `a@example.com` and `wrong`, taps the login button, calls `pumpAndSettle`, and expects `Invalid email or password` to appear once. Integration test pattern: launch the app, sign in with a test account,
open the home screen, open an item, and sign out. Run it on a real device
or emulator before every store submission.

Test checklist: every use case has a unit test, including the error cases.
Every screen has a widget test for loading, loaded, empty, and error.
Auth rejects a bad token and signs the user out. Offline mode shows cached
data with a clear label. `flutter analyze` reports no issues and
`dart format --set-exit-if-changed .` passes.

## Building for Android and iOS

```bash
flutter build apk --release
flutter build appbundle --release
flutter build ipa --release
flutter build ios --release --no-codesign
```

Android rules: set `applicationId`, `versionCode`, and `versionName` in
`android/app/build.gradle.kts`; sign the release with a keystore kept out
of the repo; use an App Bundle (`.aab`) for the Play Store, not an APK.
iOS rules: set the bundle ID, version, and build number in Xcode; sign
with a distribution certificate and provisioning profile; test the exact
release build on a real device, not only the simulator. Bump the version
and build number on every submission. Keep the app size small: remove
unused assets, compress images, and check the size report after each build.

## Play Store Checklist

Use the `app-store-compliance` skill for the full store review checklist
before submitting; the items below are the Flutter-specific checks that
go with it.

- [ ] Release build installs and launches on a clean device, with no crash in the first 60 seconds.
- [ ] No placeholder text, dead button, or empty screen in the release build.
- [ ] Every purchase uses Google Play Billing or StoreKit; no external payment link for digital goods.
- [ ] Privacy policy URL loads, and the Data safety form matches the data the app actually collects.
- [ ] Permissions are requested in context, with a plain-language reason, and the app works when a non-essential one is denied.
- [ ] Screenshots are taken from the submitted build and show the real UI.
- [ ] A demo account is provided in App Store Connect and in Play Console app access, with real content.
- [ ] Version and build numbers are bumped, and release notes describe what changed.

## Pre-Ship Checklist

- [ ] `flutter analyze`, `dart format`, and `flutter test` all pass.
- [ ] Widget tests cover loading, loaded, empty, and error for every screen.
- [ ] Integration test passes on a real Android device and a real iPhone.
- [ ] Release `.aab` and `.ipa` build from a clean checkout.
- [ ] No API key, token, or password is committed; `.env` is in `.gitignore`.
- [ ] Offline mode shows cached data and retries queued actions on reconnect.
- [ ] The `app-store-compliance` skill checklist has been run for each target store.

## Pitfalls

- Mixing Riverpod and Bloc in one app creates two sources of truth for state.
- Calling Dio directly from a widget makes the screen untestable and unmockable.
- Storing a token in SharedPreferences exposes it to any app that reads the file.
- Forgetting the empty state leaves a blank screen that looks like a crash.
- Testing only on a simulator hides real-device issues with permissions and cameras.
- Shipping a debug build to a store fails review and leaks debug logging.
- Hard-coding a base URL forces a rebuild for every environment change.
