import 'package:equatable/equatable.dart';

/// A time window when a tutor can give a session (pure Dart, no Firebase).
class AvailabilitySlot extends Equatable {
  const AvailabilitySlot({
    required this.id,
    required this.tutorId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  final String id;
  final String tutorId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;

  @override
  List<Object?> get props => [id, tutorId, startTime, endTime, isBooked];
}
