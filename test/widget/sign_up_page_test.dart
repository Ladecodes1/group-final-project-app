import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:studylink/features/auth/presentation/pages/sign_up_page.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthBloc bloc;

  final emailField = find.widgetWithText(TextFormField, 'Email');
  final passwordField = find.widgetWithText(TextFormField, 'Password');
  final confirmField = find.widgetWithText(TextFormField, 'Confirm password');
  final signUpButton = find.widgetWithText(FilledButton, 'Sign up');

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

  testWidgets('blank form shows an error for every field', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const SignUpPage());

    await tester.tap(signUpButton);
    await tester.pump();

    expect(find.text('Please enter your email.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('different passwords are caught before sign-up', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const SignUpPage());

    await tester.enterText(emailField, 'new@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.enterText(confirmField, 'secret2');
    await tester.tap(signUpButton);
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(repository.signUpCalls, 0);
  });

  testWidgets('valid details create the account', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const SignUpPage());

    await tester.enterText(emailField, 'new@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.enterText(confirmField, 'secret1');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(repository.signUpCalls, 1);
    expect(repository.verificationCalls, 1);
  });

  testWidgets('a taken email shows the error once', (tester) async {
    createBloc();
    repository.failure = const AuthFailure(
      'An account with this email already exists.',
    );
    await pumpWithBloc(tester, bloc, const SignUpPage());

    await tester.enterText(emailField, 'taken@alustudent.com');
    await tester.enterText(passwordField, 'secret1');
    await tester.enterText(confirmField, 'secret1');
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
  });
}
