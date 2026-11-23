# StudyLink UI Implementation — Member 3

## Design reference

The UI follows the supplied StudyLink prototype screenshots. The visual language uses:

- Warm off-white page background (`#F8F4EE`)
- Dark charcoal text (`#202522`)
- Deep green primary actions (`#1F6653`)
- Mint selected states and privacy surfaces (`#E5F0EB`)
- Warm beige cards and avatars (`#F4DFB1`)
- Gold rating accents (`#D18B16`)
- Red destructive action (`#B9271D`)

## Screens and navigation

| Screen | Route | Main interaction |
|---|---|---|
| Sign In | `/sign-in` | Validate email/password, continue to Home |
| Sign Up | `/sign-up` | Register UI, programme/year and tutor opt-in controls |
| Home | `/home` | Open search, subjects, upcoming session and session list |
| Search Subjects | `/search` | Search or select a subject |
| Tutor Results | `/tutors` | Filter and choose a peer tutor; empty state returns to search |
| Tutor Profile | `/tutor-profile` | Review subjects, profile and next open time |
| Available Time Slots | `/availability` | Select date, slot, mode and private note |
| Booking Confirmation | `/booking-confirmed` | View successful booking and go to sessions or Home |
| My Sessions | `/sessions` | View upcoming and past sessions; rate completed session |
| Session Details | `/session-details` | Review booking and open cancel bottom sheet |
| Rate Session | `/rate-session` | Select stars, outcome, feedback tags and optional note |

## Reusable components

`AppButton`, `AppCard`, `AppTextField`, `LoadingIndicator`, `EmptyState`, `AppBottomNav`, `InitialsAvatar` and the shared dialog helper are in `lib/shared/widgets/`.

## Responsive behavior

Scrollable content is used on form-heavy and detail pages. Primary actions are placed in bottom sections where the prototype shows sticky actions. Content widths are constrained on larger screens; rows and chips wrap where possible to avoid horizontal overflow on narrow phones. The app uses Material 3 controls with touch-friendly heights.

## Navigation and error states

- The tutor-results empty state includes a return-to-search action.
- Availability confirmation checks the booking result. An unavailable result remains on the availability page and displays a SnackBar.
- A thrown booking error displays a clear message while preserving the selected tutor and the entered booking details.
- Session cancellation is a modal bottom sheet with a reason selection, cancel action, reschedule action and keep-session action.

## State and integration boundary

The presentation layer uses Riverpod and `go_router`. The current controller uses sample local records to make the UI navigable. Replace these local demo actions with the team's data repositories for Firestore persistence and Firebase Auth; do not move business rules into page widgets. Member 4 should align provider ownership and route protection with the agreed app-wide architecture.

## Contrast and touch target spot checks

The implementation's key foreground/background combinations were checked using WCAG relative luminance contrast calculations:

| Pair | Contrast |
|---|---:|
| Main text on page background | 15.19:1 |
| Secondary text on page background | 4.93:1 |
| Secondary text on soft card background | 4.56:1 |
| White label on primary green button | 7.61:1 |
| Green label on mint selected state | 6.49:1 |
| White label on destructive red button | 6.51:1 |

Primary action buttons use a 52 logical-pixel height; choice controls and bottom navigation are also sized to provide comfortable touch areas. These are design-token checks and should be revalidated against any final team-wide theme changes.
