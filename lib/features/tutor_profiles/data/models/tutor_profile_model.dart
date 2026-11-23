import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/tutor_profile.dart';

/// Converts between a Firestore document and a [TutorProfile].
/// Field names match the `tutorProfiles` table in the ERD.
class TutorProfileModel extends TutorProfile {
  const TutorProfileModel({
    required super.uid,
    required super.bio,
    required super.yearOfStudy,
    required super.subjectIds,
    required super.isActive,
  });

  factory TutorProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw const AppException('This tutor profile does not exist.');
    }
    return TutorProfileModel(
      uid: doc.id,
      bio: data['bio'] as String? ?? '',
      yearOfStudy: (data['yearOfStudy'] as num?)?.toInt() ?? 1,
      subjectIds: List<String>.from(data['subjectIds'] as List? ?? const []),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// The map written to Firestore. The uid is the document id.
  static Map<String, dynamic> toDocument({
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
    bool isActive = true,
  }) {
    return {
      'bio': bio,
      'yearOfStudy': yearOfStudy,
      'subjectIds': subjectIds,
      'isActive': isActive,
    };
  }
}
