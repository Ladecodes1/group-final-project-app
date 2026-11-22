# Development setup

## Requirements

- Flutter stable with Dart 3.6 or later
- Android Studio and Android SDK for Android builds
- A Firebase project for live authentication and database operations

## Install and run

```bash
flutter pub get
flutter run
```

If the Android host project is absent, generate it with:

```bash
flutter create --platforms=android --org com.studylink --project-name studylink .
```

## Firebase options

Pass the public client options to Flutter using `--dart-define`:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=YOUR_API_KEY \
  --dart-define=FIREBASE_APP_ID=YOUR_APP_ID \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID \
  --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT_ID \
  --dart-define=FIREBASE_STORAGE_BUCKET=YOUR_STORAGE_BUCKET
```

The values must come from the team's Firebase project. Do not commit secrets or real service-account credentials.

## Quality checks

```bash
dart format .
flutter analyze
flutter test --coverage
flutter build apk --debug
```

The GitHub Actions workflow runs these checks and uploads the debug APK as a workflow artifact.
