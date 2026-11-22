# StudyLink UI implementation — Member 3

## Design reference

The screens continue the supplied StudyLink prototype's visual language:

- Warm off-white page background
- Dark charcoal text
- Deep green primary actions
- Mint selected states and privacy surfaces
- Warm beige cards and avatars
- Gold rating accents
- Red destructive actions

The current Figma prototype URL is in the project brief. The Figma site could not be fetched by the automated review environment, so the final implementation must still be visually compared against the approved prototype.

## Screens and routes

| Screen | Route | Main interaction |
|---|---|---|
| Sign In | `/sign-in` | Firebase email/password sign-in and reset email |
| Sign Up | `/sign-up` | Firebase account creation and profile save |
| Home | `/home` | Next session, subject shortcuts and bottom navigation |
| Search Subjects | `/search` | Query active Firestore subjects |
| Tutor Results | `/tutors` | Tutors associated with the selected subject; empty state returns to search |
| Tutor Profile | `/tutor-profile` | Selected tutor's profile and subjects |
| Available Time Slots | `/availability` | Read open slots, choose date/time/mode and write a private note |
| Booking Confirmation | `/booking-confirmed` | Display the created session |
| My Sessions | `/sessions` | Load the authenticated student's sessions |
| Session Details | `/session-details?sessionId=...` | Display the selected session by ID |
| Rate Session | `/rate-session?sessionId=...` | Submit a rating against the selected completed session |

## Reusable widgets

The shared widgets include `AppButton`, `AppCard`, `AppTextField`, `LoadingIndicator`, `EmptyState`, `AppBottomNav`, `InitialsAvatar` and the shared message dialog.

## State and navigation

Riverpod Notifiers manage search state, tutor selection, selected date and slot, meeting mode, session selection and rating input. GoRouter manages route transitions. No BLoC/Cubit implementation is used by the active app.

Routes for details and rating carry a `sessionId` query parameter. This prevents the UI from relying on one fixed shared session when a student opens a different booking.

## Data integration

Firebase Authentication creates and signs in student accounts. Firestore repositories query subjects, tutors, nested tutor availability and the authenticated student's sessions. A transaction reserves an availability slot and creates its session document. Cancellation releases only the slot associated with the selected session; rating writes one rating document for the selected completed session.

## Error handling

- No matching tutors: display an empty state with a route back to Search.
- No open time slots: explain that no times are available on the selected date.
- A slot claimed by another user: the transaction fails without clearing the selected tutor or booking details.
- Firebase/network errors: display a readable message.
- Empty sessions: display empty upcoming/past sections.
- Loading data: display a loading indicator while requests are pending.

## Responsive behavior and accessibility

Scrollable layouts and constrained content widths are retained on form-heavy and detail pages. CI includes widget tests for the sign-in view at compact portrait and landscape sizes. Final verification still needs to cover all screens on a small phone (5.5 inches or less), a large phone (6.7 inches or more), and landscape displays, with manual contrast/tap-target checks.

## Integration boundary

Firebase options must be supplied by the team using Dart defines. The final Firestore schema, indexes and rules need backend-team review before production deployment.
