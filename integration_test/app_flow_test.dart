import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:studylink/app/app.dart';
import 'package:studylink/features/auth/data/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthProfile> signIn(
          {required String email, required String password}) async =>
      AuthProfile(
          uid: 'student-1',
          name: 'Integration Student',
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
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'StudyLink main journey renders screens and captures Android evidence',
      (tester) async {
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository())
      ],
      child: const StudyLinkApp(),
    ));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await capture('01-sign-in');

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    await capture('02-sign-up');

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).at(0), 'demo@studylink.local');
    await tester.enterText(find.byType(TextFormField).at(1), 'DemoPass123');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Your next session'), findsOneWidget);
    await capture('03-home');

    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();
    expect(find.text('Find help'), findsOneWidget);
    await capture('04-subject-search');

    await tester.tap(find.text('Data Structures & Algorithms').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('peer tutors'), findsOneWidget);
    await capture('05-tutor-results');

    await tester.tap(find.text('Kevin Habimana').first);
    await tester.pumpAndSettle();
    expect(find.text('CAN HELP WITH'), findsOneWidget);
    await capture('06-tutor-profile');

    await tester.tap(find.text('See open times'));
    await tester.pumpAndSettle();
    expect(find.text('Open slots'), findsOneWidget);
    await capture('07-availability');

    await tester.tap(find.text('Confirm booking'));
    await tester.pumpAndSettle();
    expect(find.text("You're booked"), findsOneWidget);
    await capture('08-booking-confirmation');

    await tester.tap(find.text('View my sessions'));
    await tester.pumpAndSettle();
    expect(find.text('My sessions'), findsOneWidget);
    await capture('09-my-sessions');

    await tester.tap(find.text('Data Structures & Algorithms').first);
    await tester.pumpAndSettle();
    expect(find.text('Data Structures & Algorithms'), findsWidgets);
    await capture('10-session-details');

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();
    final rateButton = find.text('Rate this session');
    await tester.ensureVisible(rateButton);
    await tester.tap(rateButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('How was your session with'), findsOneWidget);
    await capture('11-rate-session');
  });
}
