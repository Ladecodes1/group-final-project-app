import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/app/app.dart';
import 'package:studylink/features/auth/data/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthProfile> signIn(
          {required String email, required String password}) async =>
      AuthProfile(
          uid: 'student-1',
          name: 'Test Student',
          email: email,
          programme: 'Software Eng.',
          year: 2,
          isTutor: false);

  @override
  Future<AuthProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String programme,
    required int year,
    required bool isTutor,
  }) async =>
      AuthProfile(
          uid: 'student-1',
          name: name,
          email: email,
          programme: programme,
          year: year,
          isTutor: isTutor);

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('student can sign in and navigate to subject search',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository())
      ],
      child: const StudyLinkApp(),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).at(0), 'student@alustudent.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Your next session'), findsOneWidget);
    expect(find.text('Test Student'), findsOneWidget);

    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();
    expect(find.text('Find help'), findsOneWidget);
    expect(find.text('MATCHING SUBJECTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in layout stays scrollable on compact landscape',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: StudyLinkApp()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(568, 320);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
