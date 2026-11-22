# StudyLink Android screenshots

The screenshots in this folder are captured from the running Flutter application on an Android Pixel 7 emulator by the separate `.github/workflows/studylink_android_evidence.yml` workflow.

The automated journey captures:

1. `01-sign-in.png`
2. `02-sign-up.png`
3. `03-home.png`
4. `04-subject-search.png`
5. `05-tutor-results.png`
6. `06-tutor-profile.png`
7. `07-availability.png`
8. `08-booking-confirmation.png`
9. `09-my-sessions.png`
10. `10-session-details.png`
11. `11-rate-session.png`

## Evidence scope

These are genuine emulator captures of the current app screens. The automated journey uses the app's local sample records and a fake authentication repository so it can run without the team's Firebase project. It demonstrates the UI and navigation journey only; it does **not** verify live Firebase authentication, live Firestore data, or production bookings.

The screenshots are not a Figma pixel-match certificate. Complete the manual comparison in [the Figma review checklist](../FIGMA_REVIEW_CHECKLIST.md) against the approved frames and physical devices before claiming exact design parity.

Re-run the evidence workflow whenever the UI or integration flow changes. The same run creates `docs/demo/studylink-demo.mp4`.
