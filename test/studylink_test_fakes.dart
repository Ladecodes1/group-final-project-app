export 'helpers/fake_study_link_backend.dart';

import 'dart:async';

import 'package:studylink/features/auth/domain/auth_failure.dart';
import 'package:studylink/features/auth/domain/entities/app_user.dart';
import 'package:studylink/features/auth/domain/repositories/auth_repository.dart';

/// An in-memory [AuthRepository] for app-level and integration tests.
///
/// It starts signed out (or signed in as [initialUser]) and signs in any
/// email/password, so the full app can run without Firebase.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _user = initialUser;

  final _changes = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  /// When not null, sign-in and sign-up throw this instead of succeeding.
  AuthFailure? failure;

  AppUser? get currentUser => _user;

  void _set(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  Future<void> close() => _changes.close();

  /// Emits the current user first, like Firebase does when the app starts.
  @override
  Stream<AppUser?> get authStateChanges async* {
    yield _user;
    yield* _changes.stream;
  }

  AppUser _userFor(String email) => AppUser(
    uid: 'uid-${email.trim()}',
    email: email.trim(),
    emailVerified: true,
  );

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (failure != null) throw failure!;
    final user = _userFor(email);
    _set(user);
    return user;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    if (failure != null) throw failure!;
    final user = _userFor(email);
    _set(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    if (failure != null) throw failure!;
    final user = _userFor('google.student@alustudent.com');
    _set(user);
    return user;
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}
}
