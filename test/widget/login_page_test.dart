import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';

import '../helpers/pump_studylink_app.dart';

void main() {
  final emailField = find.byType(TextFormField).at(0);
  final passwordField = find.byType(TextFormField).at(1);
  final signInButton = find.text('Sign in');

  testWidgets('shows the email, password and both sign-in options', (
    tester,
  ) async {
    await pumpStudyLinkApp(tester);

    expect(
      find.text('Stuck on a topic? A classmate has been there.'),
      findsOneWidget,
    );
    expect(find.text('ALU email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(signInButton, findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
  });

  testWidgets('blank form shows validation errors and does not sign in', (
    tester,
  ) async {
    final repository = await pumpStudyLinkApp(tester);

    await tapVisible(tester, signInButton);

    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('invalid email and short password show clear errors', (
    tester,
  ) async {
    final repository = await pumpStudyLinkApp(tester);

    await tester.enterText(emailField, 'not-an-email');
    await tester.enterText(passwordField, '123');
    await tapVisible(tester, signInButton);

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 6 characters.'),
      findsOneWidget,
    );
    expect(repository.signInCalls, 0);
  });

  testWidgets('valid details sign the student in and open Home', (
    tester,
  ) async {
    final repository = await pumpStudyLinkApp(tester);

    await tester.enterText(emailField, 'student@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tapVisible(tester, signInButton);

    expect(repository.signInCalls, 1);
    expect(repository.lastEmail, 'student@alustudent.com');
    expect(find.text('Your next session'), findsOneWidget);
  });

  testWidgets('a failed sign-in shows the error and lets the user try again', (
    tester,
  ) async {
    final repository = await pumpStudyLinkApp(tester);
    repository.failure = const AuthFailure('Incorrect email or password.');

    await tester.enterText(emailField, 'student@alustudent.com');
    await tester.enterText(passwordField, 'wrong12');
    await tapVisible(tester, signInButton);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    // Regression check: the button is not stuck on "Signing in…".
    expect(signInButton, findsOneWidget);
    expect(find.text('Signing in…'), findsNothing);
  });

  testWidgets('Continue with Google starts Google sign-in', (tester) async {
    final repository = await pumpStudyLinkApp(tester);

    await tapVisible(tester, find.text('Continue with Google'));

    expect(repository.googleCalls, 1);
    expect(find.text('Your next session'), findsOneWidget);
  });

  group('Forgot password', () {
    testWidgets('asks for an email first when the field is empty', (
      tester,
    ) async {
      final repository = await pumpStudyLinkApp(tester);

      await tapVisible(tester, find.text('Forgot password?'));

      expect(find.text('Enter your email address first.'), findsOneWidget);
      expect(repository.resetCalls, 0);
    });

    testWidgets('sends a reset email and confirms it', (tester) async {
      final repository = await pumpStudyLinkApp(tester);

      await tester.enterText(emailField, 'student@alustudent.com');
      await tapVisible(tester, find.text('Forgot password?'));

      expect(repository.resetCalls, 1);
      expect(
        find.text('Password reset email sent. Check your inbox.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Create an account opens the sign-up screen', (tester) async {
    await pumpStudyLinkApp(tester);

    await tapVisible(tester, find.text('Create an account'));

    expect(find.text('Create your account'), findsOneWidget);
  });
}
