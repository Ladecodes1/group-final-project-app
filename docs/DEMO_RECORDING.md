# StudyLink demonstration recording

The Android evidence workflow runs the app on a Pixel 7 emulator, follows the main UI journey and records the device screen. On a successful run, it commits the recording to:

- `docs/demo/studylink-demo.mp4`

It also captures the screen states listed in [the screenshots folder](screenshots/README.md). The workflow is defined in `.github/workflows/studylink_android_evidence.yml`.

## Recorded sequence

1. Sign In
2. Sign Up
3. Home
4. Search Subjects
5. Tutor Results
6. Tutor Profile
7. Available Time Slots
8. Booking Confirmation
9. My Sessions
10. Session Details
11. Rate Session

## Important limitation

The automated recording uses the local sample-preview repository and a fake authentication repository. It is suitable for demonstrating the navigation and UI screens without exposing private data. It is **not** evidence that the real Firebase project is configured or that live authentication, Firestore reads, booking transactions or ratings have been tested.

For a live-backend demonstration, first complete the steps in [Firebase setup](../firebase/README.md), seed non-sensitive demo records, and record a separate run with the team's test account. Never record passwords, private user information, API keys or real booking details.
