import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/booking.dart';

/// Converts between a Firestore document and a [Booking].
/// Field names match the `bookings` table in the ERD.
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.studentId,
    required super.tutorId,
    required super.slotId,
    required super.subjectId,
    required super.status,
    required super.topicNote,
    required super.createdAt,
  });

  /// Builds a model from a Firestore document.
  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw const AppException('This booking no longer exists.');
    }
    final created = data['createdAt'];
    return BookingModel(
      id: doc.id,
      studentId: data['studentId'] as String? ?? '',
      tutorId: data['tutorId'] as String? ?? '',
      slotId: data['slotId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      topicNote: data['topicNote'] as String? ?? '',
      // createdAt is null for a moment while the server timestamp is pending.
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  /// The map written to Firestore when a booking is created.
  /// The id is the document id, so it is not stored as a field.
  static Map<String, dynamic> newDocument({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  }) {
    return {
      'studentId': studentId,
      'tutorId': tutorId,
      'slotId': slotId,
      'subjectId': subjectId,
      'status': BookingStatus.confirmed.name,
      'topicNote': topicNote,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static BookingStatus _statusFromString(String? value) {
    return BookingStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => BookingStatus.confirmed,
    );
  }
}
