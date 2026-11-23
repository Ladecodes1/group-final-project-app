import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/pump_studylink_app.dart';

void main() {
  final emailField = find.byType(TextFormField).at(0);
  final passwordField = find.byType(TextFormField).at(1);
  final confirmField = find.byType(TextFormField).at(2);
  final createButton = find.text('Create account');

  /// Opens the app signed out and goes to the sign-up screen.
  Future<FakeAuthRepository> openSignUp(WidgetTester tester) async {
    final repository = await pumpStudyLinkApp(tester);
    await tapVisible(tester, find.text('Create an account'));
    return repository;
  }

  testWidgets('blank form shows an error for every field', (tester) async {
    final repository = await openSignUp(tester);

    await tapVisible(tester, createButton);

    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('different passwords are caught before sign-up', (tester) async {
    final repository = await openSignUp(tester);

    await tester.enterText(emailField, 'new@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.enterText(confirmField, 'secret2');
    await tapVisible(tester, createButton);

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('valid details create the account and open Home', (tester) async {
    final repository = await openSignUp(tester);

    await tester.enterText(emailField, 'new@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.enterText(confirmField, 'secret1');
    await tapVisible(tester, createButton);

    expect(repository.signUpCalls, 1);
    expect(repository.verificationCalls, 1);
    expect(find.text('Your next session'), findsOneWidget);
  });

  testWidgets('a taken email shows the error once', (tester) async {
    final repository = await openSignUp(tester);
    repository.failure = const AuthFailure(
      'An account with this email already exists.',
    );

    await tester.enterText(emailField, 'taken@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.enterText(confirmField, 'secret1');
    await tapVisible(tester, createButton);

    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
  });

  testWidgets('"Already have an account? Sign in" goes back to sign-in', (
    tester,
  ) async {
    await openSignUp(tester);

    await tapVisible(tester, find.text('Already have an account? Sign in'));

    expect(
      find.text('Stuck on a topic? A classmate has been there.'),
      findsOneWidget,
    );
  });
}
