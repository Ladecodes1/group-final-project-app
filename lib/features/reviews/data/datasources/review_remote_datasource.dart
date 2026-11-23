import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/app_exception.dart';
import '../../../booking/domain/entities/booking.dart';
import '../models/review_model.dart';

/// Talks to Cloud Firestore. Nothing outside the data layer uses this.
abstract class ReviewRemoteDataSource {
  Future<void> createReview({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  });

  Future<ReviewModel?> getReviewForBooking(String bookingId);

  Future<void> updateReview({
    required String bookingId,
    required int rating,
    required String comment,
  });

  Future<void> deleteReview(String bookingId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(FirestoreCollections.reviews);

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection(FirestoreCollections.bookings);

  @override
  Future<void> createReview({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  }) async {
    final bookingRef = _bookings.doc(bookingId);
    // The booking id is also the review id, so a booking can only be
    // rated once.
    final reviewRef = _reviews.doc(bookingId);

    await _firestore.runTransaction((tx) async {
      final booking = await tx.get(bookingRef);
      final data = booking.data();

      if (data == null) {
        throw const AppException('This booking no longer exists.');
      }

      if (data['studentId'] != studentId) {
        throw const AppException('You can only rate your own sessions.');
      }

      if (data['status'] != BookingStatus.completed.name) {
        throw const AppException(
          'You can rate a session after it is completed.',
        );
      }

      if ((await tx.get(reviewRef)).exists) {
        throw const AppException('You already rated this session.');
      }

      tx.set(
        reviewRef,
        ReviewModel.newDocument(
          bookingId: bookingId,
          studentId: studentId,
          rating: rating,
          comment: comment,
        ),
      );
    });
  }

  @override
  Future<ReviewModel?> getReviewForBooking(String bookingId) async {
    final doc = await _reviews.doc(bookingId).get();
    return doc.exists ? ReviewModel.fromFirestore(doc) : null;
  }

  @override
  Future<void> updateReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) {
    return _reviews.doc(bookingId).update({
      'rating': rating,
      'comment': comment,
    });
  }

  @override
  Future<void> deleteReview(String bookingId) {
    return _reviews.doc(bookingId).delete();
  }
}
