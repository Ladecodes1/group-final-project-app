import 'package:equatable/equatable.dart';

/// A student's rating of a finished session (pure Dart, no Firebase).
class Review extends Equatable {
  const Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, bookingId, rating, comment, createdAt];
}
