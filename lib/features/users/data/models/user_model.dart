import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/app_user.dart';

/// Converts between a Firestore document and an [AppUser].
/// Field names match the `users` table in the ERD.
class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.university,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw const AppException('This profile does not exist.');
    }
    final created = data['createdAt'];
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      university: data['university'] as String? ?? '',
      // createdAt is null for a moment while the server timestamp is pending.
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  /// The map written to Firestore on first sign-in. The uid is the
  /// document id, so it is not stored as a field.
  static Map<String, dynamic> newDocument({
    required String displayName,
    required String email,
    required String university,
  }) {
    return {
      'displayName': displayName,
      'email': email,
      'university': university,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
