import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_event.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_state.dart';

import '../helpers/fake_auth_repository.dart';

/// Lets the bloc finish handling queued events and stream updates.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakeAuthRepository repository;
  late AuthBloc bloc;

  setUp(() {
    repository = FakeAuthRepository();
    bloc = AuthBloc(authRepository: repository);
  });

  tearDown(() async {
    await bloc.close();
    await repository.dispose();
  });

  test('starts with an unknown status while Firebase is checked', () {
    expect(bloc.state.status, AuthStatus.unknown);
  });

  group('when Firebase reports the user', () {
    test('a signed-in user makes the app authenticated', () async {
      repository.emitUser(testUser);
      await settle();
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.user, testUser);
    });

    test('no user makes the app unauthenticated', () async {
      repository.emitUser(null);
      await settle();
      expect(bloc.state.status, AuthStatus.unauthenticated);
      expect(bloc.state.user, isNull);
    });
  });

  group('sign in with email and password', () {
    test('signs the user in and stops loading', () async {
      repository.emitUser(null);
      await settle();

      bloc.add(
        const AuthSignInRequested(
          email: 'student@alustudent.com',
          password: 'secret1',
        ),
      );
      await settle();

      expect(repository.signInCalls, 1);
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.errorMessage, isNull);
    });

    test('shows the error and lets the user try again on failure', () async {
      repository
        ..emitUser(null)
        ..failure = const AuthFailure('Incorrect email or password.');
      await settle();

      bloc.add(
        const AuthSignInRequested(
          email: 'student@alustudent.com',
          password: 'wrong1',
        ),
      );
      await settle();

      expect(bloc.state.status, AuthStatus.unauthenticated);
      expect(bloc.state.errorMessage, 'Incorrect email or password.');
      // Regression check: the button must not stay stuck on a spinner.
      expect(bloc.state.isLoading, isFalse);
    });

    test('shows the loading spinner while the request runs', () async {
      repository.emitUser(null);
      await settle();
      final states = <AuthState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(
        const AuthSignInRequested(
          email: 'student@alustudent.com',
          password: 'secret1',
        ),
      );
      await settle();
      await subscription.cancel();

      expect(states.first.isLoading, isTrue);
      expect(states.last.isLoading, isFalse);
    });
  });

  group('sign up', () {
    test('creates the account and sends a verification email', () async {
      bloc.add(
        const AuthSignUpRequested(
          email: 'new@alustudent.com',
          password: 'secret1',
        ),
      );
      await settle();

      expect(repository.signUpCalls, 1);
      expect(repository.verificationCalls, 1);
      expect(bloc.state.isLoading, isFalse);
      expect(
        bloc.state.infoMessage,
        'Account created. Check your email to verify it.',
      );
    });

    test('shows the error and sends no email when it fails', () async {
      repository.failure = const AuthFailure(
        'An account with this email already exists.',
      );

      bloc.add(
        const AuthSignUpRequested(
          email: 'taken@alustudent.com',
          password: 'secret1',
        ),
      );
      await settle();

      expect(repository.verificationCalls, 0);
      expect(bloc.state.isLoading, isFalse);
      expect(
        bloc.state.errorMessage,
        'An account with this email already exists.',
      );
    });
  });

  group('Google sign-in', () {
    test('signs the user in', () async {
      bloc.add(const AuthGoogleSignInRequested());
      await settle();

      expect(repository.googleCalls, 1);
      expect(bloc.state.status, AuthStatus.authenticated);
      expect(bloc.state.isLoading, isFalse);
    });

    test('shows a message when the user cancels', () async {
      repository.failure = const AuthFailure('Google sign-in was cancelled.');

      bloc.add(const AuthGoogleSignInRequested());
      await settle();

      expect(bloc.state.errorMessage, 'Google sign-in was cancelled.');
      expect(bloc.state.isLoading, isFalse);
    });
  });

  group('password reset', () {
    test('sends the email and confirms it to the user', () async {
      bloc.add(const AuthPasswordResetRequested('student@alustudent.com'));
      await settle();

      expect(repository.resetCalls, 1);
      expect(repository.lastEmail, 'student@alustudent.com');
      expect(
        bloc.state.infoMessage,
        'Password reset email sent. Check your inbox.',
      );
      expect(bloc.state.isLoading, isFalse);
    });

    test('shows the error when sending fails', () async {
      repository.failure = const AuthFailure(
        'No internet connection. Check your network.',
      );

      bloc.add(const AuthPasswordResetRequested('student@alustudent.com'));
      await settle();

      expect(
        bloc.state.errorMessage,
        'No internet connection. Check your network.',
      );
      expect(bloc.state.isLoading, isFalse);
    });
  });

  test('sign out returns the app to unauthenticated', () async {
    repository.emitUser(testUser);
    await settle();

    bloc.add(const AuthSignOutRequested());
    await settle();

    expect(repository.signOutCalls, 1);
    expect(bloc.state.status, AuthStatus.unauthenticated);
    expect(bloc.state.user, isNull);
  });
}
