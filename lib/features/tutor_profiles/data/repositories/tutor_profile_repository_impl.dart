import '../../../../core/error/app_exception.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../../domain/entities/tutor_profile.dart';
import '../../domain/repositories/tutor_profile_repository.dart';
import '../datasources/tutor_profile_remote_datasource.dart';

/// Implements [TutorProfileRepository]: checks the profile details,
/// then calls Firestore and reports problems in plain language.
class TutorProfileRepositoryImpl implements TutorProfileRepository {
  TutorProfileRepositoryImpl(this._remote);

  final TutorProfileRemoteDataSource _remote;

  static const int _maxBioLength = 300;

  @override
  Future<void> createProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  }) {
    final cleanBio = _validate(bio, yearOfStudy, subjectIds);
    return guardFirebase(
      () => _remote.createProfile(
        uid: uid,
        bio: cleanBio,
        yearOfStudy: yearOfStudy,
        subjectIds: subjectIds,
      ),
    );
  }

  @override
  Future<TutorProfile> getProfile(String uid) {
    return guardFirebase(() => _remote.getProfile(uid));
  }

  @override
  Stream<List<TutorProfile>> watchTutorsBySubject(String subjectId) {
    return _remote.watchTutorsBySubject(subjectId).handleError(rethrowFriendly);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  }) {
    final cleanBio = _validate(bio, yearOfStudy, subjectIds);
    return guardFirebase(
      () => _remote.updateProfile(
        uid: uid,
        bio: cleanBio,
        yearOfStudy: yearOfStudy,
        subjectIds: subjectIds,
      ),
    );
  }

  @override
  Future<void> setActive(String uid, {required bool isActive}) {
    return guardFirebase(() => _remote.setActive(uid, isActive: isActive));
  }

  @override
  Future<void> deleteProfile(String uid) {
    return guardFirebase(() => _remote.deleteProfile(uid));
  }

  /// Checks the profile details and returns the trimmed bio.
  String _validate(String bio, int yearOfStudy, List<String> subjectIds) {
    final cleanBio = bio.trim();
    if (cleanBio.isEmpty) {
      throw const AppException('Please write a short bio.');
    }
    if (cleanBio.length > _maxBioLength) {
      throw const AppException('Keep your bio under 300 characters.');
    }
    if (yearOfStudy < 1 || yearOfStudy > 6) {
      throw const AppException('Year of study must be between 1 and 6.');
    }
    if (subjectIds.isEmpty) {
      throw const AppException('Choose at least one subject you can tutor.');
    }
    return cleanBio;
  }
}
