import '../entities/app_user.dart';

/// What the app can do with authentication.
abstract class AuthRepository {
  /// Emits the current user, or null when signed out.
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signUp({required String email, required String password});

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  Future<void> sendEmailVerification();
}
