# StudyLink UI and navigation patch — Martin

This patch is designed to be applied **on top of the latest `main` branch** of
`Ladecodes1/group-final-project-app`. It was prepared against `main` commit
`ba91b6a6bd8585c4d48f8c0f2a7e3b5ff7fc37c5` (23 November 2026); pull the newest
`main` before applying in case the team has pushed newer commits. It deliberately preserves the team's
existing Firebase configuration, `AuthBloc`, authentication repository,
`SettingsCubit`, settings repository, and Firestore rules.

## Main changes

- Replaces the default Flutter counter entry point with the StudyLink app while
  retaining Firebase initialization and `SharedPreferences` startup loading.
- Integrates the UI with the existing `AuthBloc` and `SettingsCubit`.
- Uses BLoC/Cubit for the StudyLink presentation flow. Riverpod is not used in
  this patch, so there is one consistent app state-management approach.
- Adds an auth-aware `go_router` router and page transitions. Opening search,
  tutor, booking, and detail flows uses `push`; bottom navigation uses `go` to
  switch tabs.
- Keeps the existing warm off-white / deep-green / beige visual design.
- Moves the Home content to the top of the safe content area and constrains its
  width on larger devices. Subject tiles adapt to narrow widths. Search and
  detail screens scroll, and availability choices wrap to avoid fixed-width
  overflow.
- Adds subtle route transitions, Hero transitions between tutor cards and profiles, animated selection/card feedback, and touch
  targets appropriate for mobile.
- Carries the selected `StudySession` through the detail/rating route. Rating
  and cancellation methods now take a session ID and update only that record.
- Adds focused Cubit tests for booking, unavailable slots, session-specific
  rating, session-specific cancellation, and feedback tags.

## Integration boundary

The `feature/database-crud` branch exists, but was still three commits behind
`main` and had not been merged when this patch was prepared. The tutor and
session records in `study_link_cubit.dart` and
`study_link_models.dart` are clearly marked demo fixtures. They are not real
Firestore records and do not persist between app restarts. The current `main`
branch README identifies the data/CRUD work as being developed on
`feature/database-crud`. Replace the demo cubit operations with Dedine's
repository methods after that branch is merged; this patch does not pretend
that the Firestore CRUD integration is already complete.

The current `AuthBloc` accepts email and password for registration, but does
not yet accept profile attributes such as full name, programme, study year, or
tutor opt-in. The sign-up UI therefore collects only the values the existing
repository can actually save. Add the profile fields when the profile CRUD
contract is available rather than silently discarding them.

## Apply the patch

1. Check out the latest `main` branch and make a backup or a new working branch.
2. Extract this ZIP into the repository root, allowing the listed patch files
   to be added/replaced. The ZIP contains only files changed or added by this
   patch; it does not contain Firebase secrets/configuration or unrelated team
   files.
3. Run `flutter pub get` to resolve `go_router` and the Flutter SDK's
   `integration_test` package and regenerate `pubspec.lock` for the local SDK.
4. Run the checks below.

## Required local checks

```bash
dart format lib test integration_test
flutter analyze
flutter test
flutter test integration_test
flutter build apk --debug
```

A live Firebase sign-in and Google sign-in test also requires the project's
Firebase Auth providers, Android SHA-1, and OAuth configuration to be enabled.

## Existing files intentionally not included

- `lib/firebase_options.dart`, `android/app/google-services.json`, Firebase
  rules, Gradle files and other platform configuration remain owned by the
  latest `main` branch.
- The team's AuthBloc, authentication repository, SettingsCubit, and settings
  page are imported and reused rather than replaced.
- `test/widget_test.dart` is not replaced; the team removed it on `main`. New tests use distinct names.
- The existing README is not replaced. This document provides the UI handoff
  notes without overwriting Moses's project documentation.
