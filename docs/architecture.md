# StudyLink architecture

StudyLink uses Riverpod for application state and GoRouter for navigation. The active application does not use BLoC, Cubit, GetIt or `setState()` for shared application state.

## Application layers

- **App:** root widget, theme, route configuration and route transitions.
- **Core:** Firebase configuration and shared data models.
- **Feature UI:** authentication, home, tutors, booking and sessions.
- **Data services:** Firebase Authentication and Cloud Firestore repositories.
- **Shared widgets:** buttons, cards, fields, bottom navigation, avatars, dialogs, empty states and loading indicators.

## Main booking flow

1. Student signs in using Firebase Authentication.
2. The profile is loaded from `users/{uid}`.
3. Subject search reads active entries from `subjects`.
4. Tutor results read tutor profiles matching the selected subject.
5. Availability reads open slots from `tutors/{tutorId}/availability`.
6. Booking runs a Firestore transaction: it verifies that the selected slot is still open, reserves it and creates one session document.
7. My Sessions queries the authenticated student's sessions.
8. Cancellation updates only the selected session and reopens its exact availability slot.
9. Rating writes one rating for the selected completed session and updates that session's rating field.

Riverpod notifiers hold the current selection and presentation state. Firebase repositories own remote data operations. UI pages do not write directly to Firestore.

## Firebase configuration

Firebase options are passed as build-time Dart defines, documented in the root README. The app can still compile when these values are absent, but authentication and live data actions display a configuration error instead of pretending that a remote operation succeeded.
