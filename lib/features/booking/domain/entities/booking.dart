import 'package:equatable/equatable.dart';

/// Allowed values of the `status` field in a booking document.
enum BookingStatus { confirmed, completed, cancelled }

/// A session booked by a student with a tutor (pure Dart, no Firebase).
class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.slotId,
    required this.subjectId,
    required this.status,
    required this.topicNote,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String tutorId;
  final String slotId;
  final String subjectId;
  final BookingStatus status;
  final String topicNote;
  final DateTime createdAt;

  bool get isCancelled => status == BookingStatus.cancelled;

  @override
  List<Object?> get props => [
    id,
    studentId,
    tutorId,
    slotId,
    subjectId,
    status,
    topicNote,
    createdAt,
  ];
}
