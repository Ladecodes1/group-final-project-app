import '../../../../core/error/app_exception.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

/// Implements [ReviewRepository]: checks the rating, then calls Firestore
/// and reports problems in plain language.
class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._remote);

  final ReviewRemoteDataSource _remote;

  static const int _maxCommentLength = 300;

  @override
  Future<void> createReview({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  }) {
    final cleanComment = _validate(rating, comment);
    return guardFirebase(
      () => _remote.createReview(
        bookingId: bookingId,
        studentId: studentId,
        rating: rating,
        comment: cleanComment,
      ),
    );
  }

  @override
  Future<Review?> getReviewForBooking(String bookingId) {
    return guardFirebase(() => _remote.getReviewForBooking(bookingId));
  }

  @override
  Future<void> updateReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) {
    final cleanComment = _validate(rating, comment);
    return guardFirebase(
      () => _remote.updateReview(
        bookingId: bookingId,
        rating: rating,
        comment: cleanComment,
      ),
    );
  }

  @override
  Future<void> deleteReview(String bookingId) {
    return guardFirebase(() => _remote.deleteReview(bookingId));
  }

  /// Checks the rating and comment, and returns the trimmed comment.
  String _validate(int rating, String comment) {
    if (rating < 1 || rating > 5) {
      throw const AppException('Please choose a rating from 1 to 5.');
    }
    final cleanComment = comment.trim();
    if (cleanComment.length > _maxCommentLength) {
      throw const AppException('Keep your comment under 300 characters.');
    }
    return cleanComment;
  }
}
