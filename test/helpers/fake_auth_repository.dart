import 'dart:async';

import 'package:studylink/features/auth/domain/auth_failure.dart';
import 'package:studylink/features/auth/domain/entities/app_user.dart';
import 'package:studylink/features/auth/domain/repositories/auth_repository.dart';

/// A user the fake repository signs in as.
const testUser = AppUser(
  uid: 'user-123',
  email: 'student@alustudent.com',
  emailVerified: false,
);

/// An in-memory [AuthRepository] so tests never talk to Firebase.
///
/// Set [failure] to make every call throw it, and read the `...Calls`
/// counters to check what the bloc asked the repository to do.
class FakeAuthRepository implements AuthRepository {
  final _users = StreamController<AppUser?>.broadcast();

  /// When not null, every action throws this instead of succeeding.
  AuthFailure? failure;

  int signUpCalls = 0;
  int signInCalls = 0;
  int googleCalls = 0;
  int signOutCalls = 0;
  int resetCalls = 0;
  int verificationCalls = 0;
  String? lastEmail;

  /// Pretends Firebase reported a sign-in or sign-out.
  void emitUser(AppUser? user) => _users.add(user);

  Future<void> dispose() => _users.close();

  @override
  Stream<AppUser?> get authStateChanges => _users.stream;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    lastEmail = email;
    if (failure != null) throw failure!;
    emitUser(testUser);
    return testUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    lastEmail = email;
    if (failure != null) throw failure!;
    emitUser(testUser);
    return testUser;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    googleCalls++;
    if (failure != null) throw failure!;
    emitUser(testUser);
    return testUser;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    emitUser(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetCalls++;
    lastEmail = email;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> sendEmailVerification() async {
    verificationCalls++;
  }
}
