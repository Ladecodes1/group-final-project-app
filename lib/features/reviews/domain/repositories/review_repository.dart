import '../entities/review.dart';

/// What the app can do with session ratings.
///
/// A booking can have at most one review, so the review document uses
/// the booking id as its document id.
abstract class ReviewRepository {
  /// CREATE: rates a completed session. Throws [AppException] if the
  /// session is not completed, is not the student's, or is already rated.
  Future<void> createReview({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  });

  /// READ: the review for a booking, or null if it has not been rated.
  Future<Review?> getReviewForBooking(String bookingId);

  /// UPDATE: changes the rating and comment of an existing review.
  Future<void> updateReview({
    required String bookingId,
    required int rating,
    required String comment,
  });

  /// DELETE: removes a review.
  Future<void> deleteReview(String bookingId);
}
