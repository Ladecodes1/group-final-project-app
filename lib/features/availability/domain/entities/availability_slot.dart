import 'package:equatable/equatable.dart';

class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.id,
    required this.tutorId,
    required this.subjectId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  final String id;
  final String tutorId;
  final String subjectId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  @override
  List<Object?> get props => [
        id,
        tutorId,
        subjectId,
        date,
        startTime,
        endTime,
        isBooked,
      ];
}
