import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:studylink/features/auth/presentation/pages/login_page.dart';
import 'package:studylink/features/auth/presentation/pages/sign_up_page.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthBloc bloc;

  final emailField = find.widgetWithText(TextFormField, 'Email');
  final passwordField = find.widgetWithText(TextFormField, 'Password');
  final loginButton = find.widgetWithText(FilledButton, 'Log in');

  /// Creates the fake repository and bloc inside the test itself, so the
  /// bloc runs on the widget tester's clock and its updates reach the UI.
  void createBloc() {
    repository = FakeAuthRepository();
    bloc = AuthBloc(authRepository: repository);
    addTearDown(() async {
      await bloc.close();
      await repository.dispose();
    });
  }

  testWidgets('shows the email, password and both sign-in buttons', (
    tester,
  ) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const LoginPage());

    expect(find.text('Welcome to StudyLink'), findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('blank form shows validation errors and does not log in', (
    tester,
  ) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const LoginPage());

    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('invalid email and short password show clear errors', (
    tester,
  ) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const LoginPage());

    await tester.enterText(emailField, 'not-an-email');
    await tester.enterText(passwordField, '123');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
    expect(repository.signInCalls, 0);
  });

  testWidgets('valid details are sent to the bloc', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const LoginPage());

    await tester.enterText(emailField, 'student@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(repository.signInCalls, 1);
    expect(repository.lastEmail, 'student@alustudent.com');
  });

  testWidgets('a failed login shows the error in a snack bar', (tester) async {
    createBloc();
    repository.failure = const AuthFailure('Incorrect email or password.');
    await pumpWithBloc(tester, bloc, const LoginPage());

    await tester.enterText(emailField, 'student@alustudent.com');
    await tester.enterText(passwordField, 'wrong12');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    // The button is usable again so the user can retry.
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNotNull);
  });

  testWidgets('Continue with Google starts Google sign-in', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const LoginPage());

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(repository.googleCalls, 1);
  });

  group('Forgot password', () {
    testWidgets('asks for an email first when the field is empty', (
      tester,
    ) async {
      createBloc();
      await pumpWithBloc(tester, bloc, const LoginPage());

      await tester.tap(find.text('Forgot password?'));
      await tester.pump();

      expect(find.text('Enter your email above first.'), findsOneWidget);
      expect(repository.resetCalls, 0);
    });

    testWidgets('sends a reset email and confirms it', (tester) async {
      createBloc();
      await pumpWithBloc(tester, bloc, const LoginPage());

      await tester.enterText(emailField, 'student@alustudent.com');
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(repository.resetCalls, 1);
      expect(
        find.text('Password reset email sent. Check your inbox.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Sign up link opens the create-account screen', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const LoginPage());

    await tester.tap(find.text('No account? Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpPage), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
