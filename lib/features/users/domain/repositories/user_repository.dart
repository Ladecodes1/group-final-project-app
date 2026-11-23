import '../entities/user_profile.dart';

/// What the app can do with user profiles. The sign-in code calls
/// [createUserIfAbsent] right after a successful registration or Google
/// sign-in, so every signed-in person has a profile document.
abstract class UserRepository {
  /// CREATE: makes the profile on first sign-in and does nothing if it
  /// already exists, so signing in again never overwrites the data.
  Future<void> createUserIfAbsent({
    required String uid,
    required String displayName,
    required String email,
    String university = '',
  });

  /// READ: one profile by uid.
  Future<UserProfile> getUser(String uid);

  /// READ: live profile, so the screen updates after an edit.
  Stream<UserProfile> watchUser(String uid);

  /// UPDATE: changes the name and university.
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String university,
  });

  /// DELETE: removes the profile document (not the sign-in account).
  Future<void> deleteUser(String uid);
}

