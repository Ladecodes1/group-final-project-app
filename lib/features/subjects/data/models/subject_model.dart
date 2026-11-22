import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/subject.dart';

/// Converts a Firestore document to a [Subject].
/// Field names match the `subjects` table in the ERD.
class SubjectModel extends Subject {
  const SubjectModel({
    required super.id,
    required super.name,
    required super.courseCode,
  });

  factory SubjectModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw const AppException('This subject no longer exists.');
    }
    return SubjectModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      courseCode: data['courseCode'] as String? ?? '',
    );
  }
}
