import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/availability_slot.dart';

class AvailabilitySlotModel extends AvailabilitySlot {
  const AvailabilitySlotModel({
    required super.id,
    required super.tutorId,
    required super.subjectId,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.isBooked,
  });

  factory AvailabilitySlotModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    if (data == null) {
      throw const AppException('This time slot no longer exists.');
    }

    return AvailabilitySlotModel(
      id: doc.id,
      tutorId: data['tutorId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isBooked: data['isBooked'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> newDocument({
    required String tutorId,
    required String subjectId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return {
      'tutorId': tutorId,
      'subjectId': subjectId,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isBooked': false,
    };
  }
}
