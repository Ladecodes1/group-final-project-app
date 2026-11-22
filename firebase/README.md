# StudyLink Firebase setup

The app contains Firebase Authentication and Cloud Firestore integration code, but this repository does not belong to a configured Firebase project. The project is intentionally not activated with fabricated values.

## What the Flutter code expects

`lib/core/config/firebase_config.dart` builds a `FirebaseOptions` object from Dart compile-time defines. These four values are required before Firebase initializes:

| Dart define | Firebase Console value |
| --- | --- |
| `FIREBASE_API_KEY` | API key for the registered StudyLink app |
| `FIREBASE_APP_ID` | App ID for the registered StudyLink app |
| `FIREBASE_MESSAGING_SENDER_ID` | Project sender ID |
| `FIREBASE_PROJECT_ID` | Firebase project ID |

The following values are optional for the current Android Authentication and Firestore flow:

- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_IOS_BUNDLE_ID`

This branch uses explicit `FirebaseOptions` initialization through Dart defines; it does not currently load a generated `firebase_options.dart` file. Do not add service-account JSON or private keys to the Flutter client.

## Firebase Console work required

1. Create or select the team's Firebase project.
2. Register the Android application using the `applicationId` in `android/app/build.gradle.kts`.
3. Enable **Email/Password** in Firebase Authentication.
4. Create the Cloud Firestore database.
5. Seed the required collections and documents using [the Firestore schema](../docs/firestore_schema.md): `subjects`, `users`, `tutors`, `tutors/{uid}/availability`, `sessions` and `ratings`.
6. Have the backend owner review the Firestore rules against the final data model, then deploy the reviewed rules and indexes.
7. Supply the app's client values through the build environment when running the application.

Example Android run command:

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=YOUR_API_KEY \
  --dart-define=FIREBASE_APP_ID=YOUR_APP_ID \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID \
  --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT_ID \
  --dart-define=FIREBASE_STORAGE_BUCKET=YOUR_STORAGE_BUCKET
```

Deploy only after the backend owner has reviewed the rules:

```bash
firebase deploy --project YOUR_PROJECT_ID --only firestore:rules,firestore:indexes
```

The Firebase CLI must be installed and authenticated, and the project must exist. Storage rules currently deny all access because the app's current flow does not require Firebase Storage.

## How to tell whether Firebase is active

- `FirebaseConfig.isConfigured` returns true only when all four required Dart defines are non-empty.
- `FirebaseConfig.initialize()` then initializes the Firebase app.
- Without those values, the app remains buildable for previews and tests. Search/tutor/session preview records are local sample data; live sign-in and remote data operations are unavailable.
- A successful Android build or the emulator screenshots does not prove that Firebase is connected.

## CI and secrets

Never add service-account keys, passwords or real user credentials to source control. If the team chooses to build with Firebase values in CI, add the approved client values as repository or environment secrets and pass them to Flutter with `--dart-define`. The current CI intentionally builds and tests without them.

See [Development setup](../docs/setup.md) for Flutter commands.
