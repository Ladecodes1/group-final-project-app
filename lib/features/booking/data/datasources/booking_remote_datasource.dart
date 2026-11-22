import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/booking.dart';
import '../models/booking_model.dart';

/// Talks to Cloud Firestore. Nothing outside the data layer uses this.
abstract class BookingRemoteDataSource {
  Future<String> createBooking({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  });
  Stream<List<BookingModel>> watchStudentBookings(String studentId);
  Stream<List<BookingModel>> watchTutorBookings(String tutorId);
  Future<BookingModel> getBooking(String bookingId);
  Future<void> updateTopicNote(String bookingId, String topicNote);
  Future<void> completeBooking(String bookingId);
  Future<void> cancelBooking(String bookingId);
  Future<void> deleteBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  /// The Firestore instance is passed in so tests can use a fake one.
  BookingRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection(FirestoreCollections.bookings);

  CollectionReference<Map<String, dynamic>> get _slots =>
      _firestore.collection(FirestoreCollections.availabilitySlots);

  @override
  Future<String> createBooking({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  }) async {
    final bookingRef = _bookings.doc(); // Firestore creates the id.
    final slotRef = _slots.doc(slotId);

    // A transaction makes "check the slot, create the booking, mark the slot
    // as booked" happen together, so two students cannot take the same slot.
    await _firestore.runTransaction((tx) async {
      final slot = await tx.get(slotRef);
      if (!slot.exists) {
        throw const AppException('That time slot no longer exists.');
      }
      if (slot.data()?['isBooked'] == true) {
        throw const AppException(
          'That time was just taken. Please pick another slot.',
        );
      }
      tx.set(
        bookingRef,
        BookingModel.newDocument(
          studentId: studentId,
          tutorId: tutorId,
          slotId: slotId,
          subjectId: subjectId,
          topicNote: topicNote,
        ),
      );
      tx.update(slotRef, {'isBooked': true});
    });
    return bookingRef.id;
  }

  /// Needs a composite index: bookings -> studentId (asc), createdAt (desc).
  @override
  Stream<List<BookingModel>> watchStudentBookings(String studentId) {
    return _bookings
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Needs a composite index: bookings -> tutorId (asc), createdAt (desc).
  @override
  Stream<List<BookingModel>> watchTutorBookings(String tutorId) {
    return _bookings
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  @override
  Future<BookingModel> getBooking(String bookingId) async {
    final doc = await _bookings.doc(bookingId).get();
    return BookingModel.fromFirestore(doc);
  }

  @override
  Future<void> updateTopicNote(String bookingId, String topicNote) {
    return _bookings.doc(bookingId).update({'topicNote': topicNote});
  }

  @override
  Future<void> completeBooking(String bookingId) {
    return _bookings.doc(bookingId).update({
      'status': BookingStatus.completed.name,
    });
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = _bookings.doc(bookingId);
    await _firestore.runTransaction((tx) async {
      final booking = await tx.get(bookingRef);
      final data = booking.data();
      if (data == null) {
        throw const AppException('This booking no longer exists.');
      }
      if (data['status'] == BookingStatus.cancelled.name) return;

      tx.update(bookingRef, {'status': BookingStatus.cancelled.name});
      // Free the slot so another student can book it.
      tx.update(_slots.doc(data['slotId'] as String), {'isBooked': false});
    });
  }

  @override
  Future<void> deleteBooking(String bookingId) async {
    final ref = _bookings.doc(bookingId);
    final doc = await ref.get();
    if (doc.data()?['status'] != BookingStatus.cancelled.name) {
      throw const AppException('Only cancelled bookings can be deleted.');
    }
    await ref.delete();
  }
}
