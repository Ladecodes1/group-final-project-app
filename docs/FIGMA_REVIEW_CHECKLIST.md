# StudyLink Figma comparison checklist

**Review status: not certified.** The approved prototype is the source of truth. The Figma prototype URL could not be opened in the review environment, and no separate approved reference-frame image files were available in the repository or current task attachments. The Android screenshots are evidence of the app as implemented; they are not proof of pixel-perfect parity.

The repository UI uses the existing warm-neutral, deep-green, mint, beige and gold design direction. Complete this checklist against the approved Figma frames before marking the design as an exact match.

For each screen compare:

- Frame size, safe areas and scroll behavior
- Page background, card fills, border colours and corner radii
- Font family, font sizes, weights, line spacing and text wrapping
- Button labels, heights, widths, disabled states and selected states
- Icons, avatar sizes, spacing and alignment
- Bottom navigation position and selected tab
- Loading, empty and error states where specified
- Back navigation and route transitions

## Screen-by-screen checks

- [ ] Sign In
- [ ] Sign Up
- [ ] Home
- [ ] Search Subjects
- [ ] Tutor Results
- [ ] Tutor Profile
- [ ] Available Time Slots
- [ ] Booking Confirmation
- [ ] My Sessions
- [ ] Session Details
- [ ] Rate Session

## Device checks

- [ ] Compact phone at or below 5.5 inches
- [ ] Large phone at or above 6.7 inches
- [ ] Portrait and landscape orientation
- [ ] No horizontal overflow or clipped controls
- [ ] Text contrast of at least 4.5:1 for normal-size text
- [ ] Interactive controls have comfortable touch targets
- [ ] Back stack returns to the expected previous screen

Do not add new visual elements solely to make a screen look more decorative. Keep differences from Figma limited to the real data and dynamic state required by the application.
