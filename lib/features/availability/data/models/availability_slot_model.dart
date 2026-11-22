import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/availability_slot.dart';

/// Converts between a Firestore document and an [AvailabilitySlot].
/// Field names match the `availabilitySlots` table in the ERD.
class AvailabilitySlotModel extends AvailabilitySlot {
  const AvailabilitySlotModel({
    required super.id,
    required super.tutorId,
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
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isBooked: data['isBooked'] as bool? ?? false,
    );
  }

  /// The map written to Firestore when a slot is created.
  static Map<String, dynamic> newDocument({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return {
      'tutorId': tutorId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isBooked': false,
    };
  }
}
