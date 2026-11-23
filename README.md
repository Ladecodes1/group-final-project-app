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
