import '../../../../core/error/app_exception.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

/// Implements [UserRepository]: checks the profile details, then calls
/// Firestore and reports problems in plain language.
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  static const int _minNameLength = 2;
  static const int _maxNameLength = 50;
  static const int _maxUniversityLength = 80;

  @override
  Future<void> createUserIfAbsent({
    required String uid,
    required String displayName,
    required String email,
    String university = '',
  }) {
    final profile = _clean(displayName, university);
    return guardFirebase(
      () => _remote.createUserIfAbsent(
        uid: uid,
        displayName: profile.name,
        email: email,
        university: profile.university,
      ),
    );
  }

  @override
  Future<UserProfile> getUser(String uid) {
    return guardFirebase(() => _remote.getUser(uid));
  }

  @override
  Stream<UserProfile> watchUser(String uid) {
    return _remote.watchUser(uid).handleError(rethrowFriendly);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String university,
  }) {
    final profile = _clean(displayName, university);
    return guardFirebase(
      () => _remote.updateProfile(
        uid: uid,
        displayName: profile.name,
        university: profile.university,
      ),
    );
  }

  @override
  Future<void> deleteUser(String uid) {
    return guardFirebase(() => _remote.deleteUser(uid));
  }

  /// Checks the name and university and returns the trimmed values.
  ({String name, String university}) _clean(String name, String university) {
    final cleanName = name.trim();
    final cleanUniversity = university.trim();
    if (cleanName.length < _minNameLength) {
      throw const AppException('Please enter your name.');
    }
    if (cleanName.length > _maxNameLength) {
      throw const AppException('Your name must be under 50 characters.');
    }
    if (cleanUniversity.length > _maxUniversityLength) {
      throw const AppException('University name must be under 80 characters.');
    }
    return (name: cleanName, university: cleanUniversity);
  }
}
