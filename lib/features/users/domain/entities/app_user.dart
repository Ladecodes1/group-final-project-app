import 'package:equatable/equatable.dart';

/// A person who uses the app (pure Dart, no Firebase).
/// Named AppUser so it is not confused with Firebase's own User class.
class AppUser extends Equatable {
  const AppUser({
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
  List<Object?> get props => [uid, displayName, email, university, createdAt];
}
