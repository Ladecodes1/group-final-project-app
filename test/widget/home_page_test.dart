import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/entities/app_user.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_state.dart';
import 'package:studylink/features/auth/presentation/pages/home_page.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthBloc bloc;

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

  Future<void> signInAs(WidgetTester tester, AppUser user) async {
    repository.emitUser(user);
    await tester.pumpAndSettle();
  }

  testWidgets('shows who is signed in and that email is not verified', (
    tester,
  ) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const HomePage());
    await signInAs(tester, testUser);

    expect(find.textContaining('student@alustudent.com'), findsOneWidget);
    expect(find.textContaining('Email not verified yet'), findsOneWidget);
  });

  testWidgets('shows when the email is verified', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const HomePage());
    await signInAs(
      tester,
      const AppUser(
        uid: 'user-123',
        email: 'student@alustudent.com',
        emailVerified: true,
      ),
    );

    expect(find.textContaining('Email verified'), findsOneWidget);
  });

  testWidgets('the log out button signs the user out', (tester) async {
    createBloc();
    await pumpWithBloc(tester, bloc, const HomePage());
    await signInAs(tester, testUser);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(bloc.state.status, AuthStatus.unauthenticated);
  });
}
