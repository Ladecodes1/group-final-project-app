import '../entities/booking.dart';

/// What the app can do with bookings. BLoCs depend on this class only,
/// never on Firestore.
abstract class BookingRepository {
  /// CREATE: books a slot and marks it as taken. Returns the new booking id.
  /// Throws [AppException] if the slot was just taken by someone else.
  Future<String> createBooking({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  });

  /// READ: live list of a student's bookings, newest first.
  Stream<List<Booking>> watchStudentBookings(String studentId);

  /// READ: live list of the bookings a tutor has received.
  Stream<List<Booking>> watchTutorBookings(String tutorId);

  /// READ: one booking by id.
  Future<Booking> getBooking(String bookingId);

  /// UPDATE: changes the note the student wrote for the session.
  Future<void> updateTopicNote(String bookingId, String topicNote);

  /// UPDATE: marks the session as completed.
  Future<void> completeBooking(String bookingId);

  /// UPDATE: cancels the booking and frees the slot again.
  Future<void> cancelBooking(String bookingId);

  /// DELETE: removes a booking. Only cancelled bookings can be deleted.
  Future<void> deleteBooking(String bookingId);
}
