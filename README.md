# StudyLink

StudyLink is a Flutter app that helps ALU students find a fellow student who can
tutor them in a course subject, see when that tutor is free, and book a session.

## The problem

Students who are stuck on course material have no organised way to find which
classmates or senior students can help with a subject, see when they are free,
or book a time. Help depends on group chats and personal contacts, so many
students never get it and good student tutors stay invisible.

## The solution

A peer-tutoring app with two roles:

- **Learner:** signs up, searches by subject, browses tutors (bio, year, rating),
  books an open time slot with a note about the topic, manages upcoming and past
  sessions, cancels if needed, and rates a session after it is completed.
- **Tutor:** a student who opts in, creates a tutor profile (bio, year of study,
  subjects), posts availability slots and marks sessions completed.

Bookings run in Firestore transactions so two students cannot take the same
slot, cancelling frees the slot again, and each completed booking can be
reviewed once.

## Features

| Feature                                                                       | Status                     |
| ----------------------------------------------------------------------------- | -------------------------- |
| Email sign up / log in, email verification, password reset                    | Done                       |
| Google sign-in (Android)                                                      | Done                       |
| Settings saved on the device (dark mode, session reminders, language)         | Done                       |
| Firestore security rules                                                      | Done                       |
| Users, tutor profiles, subjects, availability, bookings, reviews (data layer) | On `feature/database-crud` |
| Tutor search, booking and session screens                                     | In progress                |

## Tech stack

- Flutter (Dart SDK `^3.13.2`, tested with Flutter 3.47.2), Material 3
- Firebase Auth and Cloud Firestore
- State management: **BLoC / Cubit** (`flutter_bloc`) across the whole app
- `shared_preferences` for saved settings
- `equatable` for value equality

## Architecture

Each feature is split into three layers. The UI never talks to Firebase or
storage directly; screens only show state and call BLoC/Cubit methods.

```
lib/
  main.dart                 app start: Firebase, saved settings, providers
  features/
    auth/
      domain/               AppUser, AuthRepository contract, validators
      data/                 Firebase Auth implementation
      presentation/         AuthBloc, login, sign-up and home pages
    settings/
      domain/               AppSettings, SettingsRepository contract
      data/                 SharedPreferences implementation
      presentation/         SettingsCubit, settings page
test/                       unit tests
firestore.rules             Firestore security rules
```

- **presentation:** pages, widgets and the BLoC/Cubit that holds their state.
- **domain:** plain Dart entities, repository contracts and rules (no Flutter or
  Firebase imports).
- **data:** the code that actually reads and writes Firebase or the device.

### Saved settings

Settings are loaded from `SharedPreferences` in `main()` before the first
screen is drawn, so they are already applied when the app reopens.

| Key                    | Type   | Default   | Effect                                                             |
| ---------------------- | ------ | --------- | ------------------------------------------------------------------ |
| `isDarkMode`           | bool   | `false`   | Switches the app between light and dark theme                      |
| `notificationsEnabled` | bool   | `true`    | Session reminders on/off (saved; reminders not built yet)          |
| `language`             | String | `English` | English, French or Kinyarwanda (saved; translations not built yet) |

Open them from the gear icon on the home screen.
