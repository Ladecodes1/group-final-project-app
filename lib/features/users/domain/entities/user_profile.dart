import 'package:equatable/equatable.dart';

/// A person's profile in the StudyLink app.
class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.university,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String university;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        university,
        createdAt,
      ];
}
