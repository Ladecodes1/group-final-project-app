# StudyLink — UI and Navigation Implementation Report

**Role:** Member 3 — UI and Navigation  
**Application:** StudyLink peer tutoring booking app  
**Framework:** Flutter / Dart  
**State management:** Riverpod  
**Navigation:** GoRouter  
**Backend integration:** Firebase Authentication and Cloud Firestore

## 1. Project overview

StudyLink supports ALU students who need help with course topics by enabling them to discover peer tutors, select available time slots, book a 45-minute session and provide feedback after a completed session. The Member 3 implementation focuses on the mobile user interface, reusable widgets, navigation, selected-record state and loading, empty and error states.

## 2. Implemented functionality

The user journey begins with Sign In or Sign Up. Authentication is implemented using Firebase Email/Password when the team's Firebase project is configured. A student can search the active subject catalogue, view matching tutors, open a tutor profile and inspect open availability. The booking operation reserves the selected slot and creates a session document through a Firestore transaction.

The My Sessions page separates upcoming from past sessions. Each session opens its own details route using a session ID. Cancellation updates only the selected confirmed session and releases its linked slot. Rating is submitted against the selected completed session and is limited to one rating per session.

The interface retains the approved StudyLink design direction: warm neutral surfaces, deep green primary actions, mint selection states, beige avatars and gold rating accents. Shared components reduce repeated button, card, avatar, loading, empty-state and navigation styling.

## 3. Architecture and navigation

Riverpod manages shared application state. GoRouter handles screen navigation and short fade/slide transitions. Firebase services are kept behind repositories so page widgets do not write directly to Firestore. The active UI does not use BLoC or Cubit for shared application state.

The main route sequence is Sign In / Sign Up, Home, Search Subjects, Tutor Results, Tutor Profile, Available Time Slots, Booking Confirmation, My Sessions, Session Details and Rate Session.

## 4. Error handling

The interface provides a no-tutors empty state, no-open-slots message, loading indicators and readable messages for authentication and data errors. Booking failures preserve the current tutor and booking selection. If a slot is unavailable at confirmation time, the Firestore transaction aborts and the student is asked to choose another slot.

## 5. Automated verification already recorded

The existing Flutter CI run **44976016590** completed successfully on commit `8c11c2b86a44ba873648b5c02e2673fb928f22fb`. It passed Dart formatting verification, `flutter analyze`, `flutter test --coverage` (9 tests), `flutter build apk --debug` and debug APK artifact upload.

Run: https://github.com/BYUSAA/Group-Final-Project-App/actions/runs/44976016590

The automated unit/widget tests cover the booking controller, unavailable-slot state preservation, session-specific cancellation and rating, sign-in navigation and compact screen layout. The integration-test journey is separate from `flutter test` and needs to run on an Android emulator or device.

## 6. Firebase activation status

The Flutter integration code is present in `lib/core/config/firebase_config.dart`, the authentication repository and the Firestore repository. Firebase initialization uses the required `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_MESSAGING_SENDER_ID` and `FIREBASE_PROJECT_ID` build-time values.

The branch does not contain a configured team Firebase project, those project values, seeded live Firestore records or a verified backend deployment. Therefore the app can be built and previewed with sample data, but live authentication, tutor search, availability, booking, sessions and ratings have not been verified against the team's backend. The backend owner must confirm the final schema and review the security rules before deployment.

See [Firebase setup](../firebase/README.md) and [Firestore schema](firestore_schema.md).

## 7. Screenshots, demonstration and Figma status

A dedicated Android emulator evidence workflow has been added. It runs an integration-test journey with fake authentication and local sample data, captures the primary screens and records an emulator demonstration video. The resulting media is committed only after the workflow completes successfully. This evidence demonstrates the implemented UI and navigation only; it is not proof of a live Firebase flow.

**Figma review is not certified.** The approved Figma prototype and original reference frames could not be loaded in the current review environment. The manual comparison checklist remains open. Pixel-by-pixel verification across the approved frames and target devices must be completed by a reviewer with access to the Figma source.

## 8. Remaining work

- Configure the team's Firebase project and pass the required client values into the app build.
- Enable Email/Password authentication, create Firestore, seed agreed data and have the backend owner validate/deploy reviewed rules and indexes.
- Run a separate live-backend end-to-end test after Firebase is available.
- Review emulator screenshots against the approved Figma frames; complete physical-device checks for compact, large and landscape screens.
- Configure signing credentials before producing a release-signed APK.

## 9. References

1. Flutter documentation. https://docs.flutter.dev/
2. Flutter integration testing. https://docs.flutter.dev/testing/integration-tests
3. Riverpod documentation. https://riverpod.dev/
4. GoRouter documentation. https://pub.dev/packages/go_router
5. Firebase Authentication for Flutter. https://firebase.google.com/docs/auth/flutter/start
6. Cloud Firestore for Flutter. https://firebase.google.com/docs/firestore/quickstart
7. W3C, Web Content Accessibility Guidelines (WCAG) 2.2. https://www.w3.org/TR/WCAG22/
8. StudyLink approved Figma prototype, supplied for the project.
