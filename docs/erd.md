# StudyLink entity relationship overview

- A **User** authenticates through Firebase Authentication and owns one `users/{uid}` profile.
- A user may be a **Tutor**. A tutor profile is stored at `tutors/{uid}`.
- A **Subject** is stored at `subjects/{subjectId}`; a tutor references subjects by ID or approved subject name.
- A tutor owns **Availability Slots** in `tutors/{uid}/availability/{slotId}`.
- A **Session** belongs to one student, one tutor, one subject and one availability slot.
- A **Rating** references one completed session and is submitted by that session's student.

A booking transaction checks and reserves one slot while creating one session. Cancellation updates that session and releases only its linked slot. A rating is unique per session.
