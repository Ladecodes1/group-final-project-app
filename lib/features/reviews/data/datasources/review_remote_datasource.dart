import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/app_exception.dart';
import '../../../booking/domain/entities/booking.dart';
import '../models/review_model.dart';

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

      final tutorId = data['tutorId'] as String?;

      if (tutorId == null || tutorId.isEmpty) {
        throw const AppException('The booking has no tutor assigned.');
      }

      tx.set(
        reviewRef,
        ReviewModel.newDocument(
          bookingId: bookingId,
          studentId: studentId,
          tutorId: tutorId,
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
