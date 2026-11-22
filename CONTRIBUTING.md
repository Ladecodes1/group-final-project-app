# Contributing to StudyLink

## Branches and commits

- Use `feature/<name>`, `fix/<name>`, or member branches such as `byusa-work`.
- Use commit prefixes: `feat:`, `fix:`, `docs:`, `test:`, and `refactor:`.
- Pull requests should describe changes, test steps, affected screens, and include updated UI screenshots where available.

## Architecture conventions

- Use Riverpod for shared application state.
- Use GoRouter for navigation.
- Keep Firebase operations inside repository/data services; do not write Firestore calls directly inside page widgets.
- Do not add BLoC, Cubit, GetIt or a second state-management system to the active app without an explicit team-wide architecture decision.
- Keep screen IDs and selected-record IDs in the route when opening details or rating screens.

## Before submitting a change

Run:

```bash
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build apk --debug
```

Do not claim a check passed unless its command or CI job completed successfully.

## Credentials and data

Never commit Firebase service-account files, signing keys, private credentials, user passwords or production data. Use the Firebase build-time options documented in the root README.
