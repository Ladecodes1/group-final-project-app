import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.bookingId,
    required this.studentId,
    required this.tutorId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String studentId;
  final String tutorId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        bookingId,
        studentId,
        tutorId,
        rating,
        comment,
        createdAt,
      ];
}
