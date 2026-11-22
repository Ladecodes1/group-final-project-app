# StudyLink Firestore schema

The UI repository integrates with the following agreed draft schema. The backend team should confirm the names and field types before deploying production data.

## Collections

### `users/{uid}`

Fields:
- `uid`: Firebase Authentication UID
- `displayName`: student's full name
- `email`: account email
- `programme`: study programme
- `year`: integer study year
- `isTutor`: whether the student has opted in as a tutor
- `createdAt`, `updatedAt`: Firestore timestamps

Student profile documents are private. Tutor profile fields are exposed through the `tutors` collection.

### `subjects/{subjectId}`

Fields:
- `name`, `programme`, `description`
- `tutorCount`: optional denormalised tutor count
- `isActive`: controls whether the subject appears in search

### `tutors/{uid}`

Fields:
- `bio`
- `subjects`: array of subject document IDs or subject names
- `ratingAggregate`: numeric average rating
- `sessionCount`
- `isAvailable`
- `modes`: supported meeting modes such as `On campus` and `Online`
- optional `avatarColor`, `nextSlot`, and `testimonial`

The tutor's public name, programme and year are read from `users/{uid}` only when `isTutor == true`.

### `tutors/{uid}/availability/{slotId}`

Fields:
- `startAt`: Firestore timestamp
- `durationMinutes`: normally 45
- `mode`: `On campus` or `Online`
- `status`: `available` or `booked`
- optional `bookedBy`, `bookedAt`

### `sessions/{sessionId}`

Fields:
- `studentId`, `tutorId`, `tutorName`, `tutorInitials`
- `subjectId`, `subjectName`
- `slotId`, `startAt`, `durationMinutes`, `mode`, `location`, `note`
- `status`: `confirmed`, `completed`, or `cancelled`
- optional `rating`, `ratedAt`, `cancellationReason`, `cancelledAt`
- `participantIds`, `createdAt`, `updatedAt`

A booking is written in a Firestore transaction that checks the slot is still available, marks it booked and creates the session document.

### `ratings/{sessionId}`

One rating document per session:
- `sessionId`, `studentId`, `tutorId`
- `score` (1–5), `tags`, `comment`, `createdAt`

A rating is submitted transactionally against a completed session and cannot be duplicated by the same student.

## Indexes and security

The availability query needs the composite index included in `firebase/firestore.indexes.json`. Firestore security rules are in `firebase/firestore.rules`; review them with the backend team before production deployment. Client-side slot checks are not a substitute for the transaction and server-side rules.
