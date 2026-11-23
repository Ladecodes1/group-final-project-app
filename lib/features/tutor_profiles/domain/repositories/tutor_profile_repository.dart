import '../entities/tutor_profile.dart';

/// What the app can do with tutor profiles.
abstract class TutorProfileRepository {
  /// CREATE: a user becomes a tutor. Throws [AppException] if they
  /// already have a profile or the details are not valid.
  Future<void> createProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  });

  /// READ: one tutor profile by the tutor's uid.
  Future<TutorProfile> getProfile(String uid);

  /// READ: live list of active tutors who teach a subject.
  Stream<List<TutorProfile>> watchTutorsBySubject(String subjectId);

  /// UPDATE: edits the bio, year and subjects.
  Future<void> updateProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  });

  /// UPDATE: turns the profile on or off in search results.
  Future<void> setActive(String uid, {required bool isActive});

  /// DELETE: removes the tutor profile (the user account stays).
  Future<void> deleteProfile(String uid);
}
