import '../../../../core/error/firebase_error_mapper.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

/// Implements [BookingRepository] and turns Firebase errors into
/// messages the user can understand.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  Future<String> createBooking({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  }) {
    return guardFirebase(
      () => _remote.createBooking(
        studentId: studentId,
        tutorId: tutorId,
        slotId: slotId,
        subjectId: subjectId,
        topicNote: topicNote,
      ),
    );
  }

  @override
  Stream<List<Booking>> watchStudentBookings(String studentId) {
    return _remote.watchStudentBookings(studentId).handleError(rethrowFriendly);
  }

  @override
  Stream<List<Booking>> watchTutorBookings(String tutorId) {
    return _remote.watchTutorBookings(tutorId).handleError(rethrowFriendly);
  }

  @override
  Future<Booking> getBooking(String bookingId) {
    return guardFirebase(() => _remote.getBooking(bookingId));
  }

  @override
  Future<void> updateTopicNote(String bookingId, String topicNote) {
    return guardFirebase(() => _remote.updateTopicNote(bookingId, topicNote));
  }

  @override
  Future<void> completeBooking(String bookingId) {
    return guardFirebase(() => _remote.completeBooking(bookingId));
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return guardFirebase(() => _remote.cancelBooking(bookingId));
  }

  @override
  Future<void> deleteBooking(String bookingId) {
    return guardFirebase(() => _remote.deleteBooking(bookingId));
  }
}
