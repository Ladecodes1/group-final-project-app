import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_study_link_backend.dart';
import '../helpers/pump_studylink_app.dart';

void main() {
  testWidgets('signed-out users see the sign-in screen', (tester) async {
    await pumpStudyLinkApp(tester);

    expect(find.text('StudyLink'), findsOneWidget);
    expect(
      find.text('Stuck on a topic? A classmate has been there.'),
      findsOneWidget,
    );
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('signed-in users open on Home', (tester) async {
    await pumpStudyLinkApp(tester, signedIn: true);

    expect(find.text('Your next session'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget); // from student@alustudent.com
  });

  testWidgets(
    'sign-in layout has no overflow on a small screen and in landscape',
    (tester) async {
      await pumpStudyLinkApp(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(568, 320);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Back from the Find tab returns to Home instead of closing the app',
    (tester) async {
      await pumpStudyLinkApp(tester, signedIn: true);

      await tester.tap(find.text('Find'));
      await tester.pumpAndSettle();
      expect(find.text('Find help'), findsOneWidget);

      // The same as pressing the phone's Back button.
      final handled = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(handled, isTrue);
      expect(find.text('Your next session'), findsOneWidget);
    },
  );

  testWidgets('Back from the Sessions tab returns to Home', (tester) async {
    await pumpStudyLinkApp(tester, signedIn: true);

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Your next session'), findsOneWidget);
  });

  testWidgets('the Settings button on Home opens the settings screen', (
    tester,
  ) async {
    await pumpStudyLinkApp(tester, signedIn: true);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('Log out on Home returns to the sign-in screen', (tester) async {
    final repository = await pumpStudyLinkApp(tester, signedIn: true);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();

    expect(repository.signOutCalls, 1);
    expect(
      find.text('Stuck on a topic? A classmate has been there.'),
      findsOneWidget,
    );
  });

  testWidgets('the next upcoming session is shown on Home', (tester) async {
    await pumpStudyLinkApp(
      tester,
      signedIn: true,
      backend: FakeStudyLinkBackend(
        sessions: [pastSession.copyWith(isUpcoming: true)],
      ),
    );

    expect(find.text('with Grace Uwase'), findsOneWidget);
    expect(find.text('STATISTICS'), findsOneWidget);
  });
}
