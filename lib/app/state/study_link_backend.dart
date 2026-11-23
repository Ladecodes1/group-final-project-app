import '../../core/models/study_link_models.dart';
import '../../features/availability/domain/entities/availability_slot.dart';
import '../../features/subjects/domain/entities/subject.dart';

/// Everything the booking screens need from the database.
///
/// StudyLinkCubit only talks to this contract, so the screens never touch
/// Firestore. The real version (FirestoreStudyLinkBackend) uses the team's
/// repositories; tests use an in-memory fake.
abstract class StudyLinkBackend {
  /// Creates the student's `users` document the first time they sign in.
  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String displayName,
  });

  /// All subjects, sorted by name.
  Stream<List<Subject>> watchSubjects();

  /// Active peer tutors who teach [subjectId], with their names.
  Stream<List<Tutor>> watchTutors(String subjectId);

  /// The tutor's open (not booked, not past) time slots.
  Stream<List<AvailabilitySlot>> watchOpenSlots(String tutorId);

  /// The student's bookings, newest first, ready to show on screen.
  Stream<List<StudySession>> watchSessions(String studentId);

  /// Books [slotId]. Throws an AppException with a clear message if the slot
  /// was just taken.
  Future<void> book({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  });

  /// Cancels a booking and frees its time slot.
  Future<void> cancel(String bookingId);

  /// Permanently removes a cancelled booking.
  Future<void> remove(String bookingId);

  /// Rates a session that has taken place.
  Future<void> rate({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  });
}
