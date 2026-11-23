import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';

/// Converts between a Firestore document and a [Review].
/// Field names match the `reviews` table in the ERD.
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.studentId,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final created = data['createdAt'];

    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? doc.id,
      studentId: data['studentId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String? ?? '',
      // createdAt is null for a moment while the server timestamp is pending.
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  /// The map written to Firestore when a review is created.
  static Map<String, dynamic> newDocument({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  }) {
    return {
      'bookingId': bookingId,
      'studentId': studentId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
