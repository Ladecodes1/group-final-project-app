import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_study_link_backend.dart';
import '../helpers/pump_studylink_app.dart';

void main() {
  /// From Home: search, pick DSA, pick Grace and open her time slots.
  Future<void> openGraceTimes(WidgetTester tester) async {
    await tapVisible(tester, find.text('What are you stuck on?'));
    expect(find.text('Find help'), findsOneWidget);

    await tapVisible(tester, find.text('Data Structures & Algorithms').first);
    expect(find.text('Grace Uwase'), findsOneWidget);

    await tapVisible(tester, find.text('Grace Uwase'));
    await tapVisible(tester, find.text('See open times'));
  }

  testWidgets('Home lists the subjects stored in Firestore', (tester) async {
    await pumpStudyLinkApp(tester, signedIn: true);

    expect(find.text('Data Structures & Algorithms'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('No upcoming session'.toUpperCase()), findsOneWidget);
  });

  testWidgets('a student can book a session and see it in My Sessions', (
    tester,
  ) async {
    final backend = FakeStudyLinkBackend();
    await pumpStudyLinkApp(tester, signedIn: true, backend: backend);

    await openGraceTimes(tester);
    expect(find.text('Thu 24'.split(' ').first), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('16:00'), findsOneWidget);

    await tapVisible(tester, find.text('16:00'));
    await tapVisible(tester, find.text('Confirm booking'));

    expect(find.text("You're booked"), findsOneWidget);
    expect(backend.sessions.single.id, 'booking-slot-b');
    expect(backend.slots.firstWhere((s) => s.id == 'slot-b').isBooked, isTrue);

    await tapVisible(tester, find.text('View my sessions'));
    expect(find.text('My sessions'), findsOneWidget);
    expect(find.textContaining('Grace'), findsWidgets);
  });

  testWidgets(
    'a slot that was just taken shows a message and keeps the choice',
    (tester) async {
      final backend = FakeStudyLinkBackend()
        ..failNextBookingWith =
            'That time was just taken. Please pick another slot.';
      await pumpStudyLinkApp(tester, signedIn: true, backend: backend);

      await openGraceTimes(tester);
      await tapVisible(tester, find.text('Confirm booking'));

      expect(
        find.text('That time was just taken. Please pick another slot.'),
        findsOneWidget,
      );
      expect(find.text("You're booked"), findsNothing);
      expect(find.text('Confirm booking'), findsOneWidget);
    },
  );

  testWidgets('a subject without tutors shows the empty state', (tester) async {
    await pumpStudyLinkApp(tester, signedIn: true);

    await tapVisible(tester, find.text('What are you stuck on?'));
    await tapVisible(tester, find.text('Statistics').first);

    expect(find.text('No tutors found'), findsOneWidget);
    await tapVisible(tester, find.text('Back to search'));
    expect(find.text('Find help'), findsOneWidget);
  });

  testWidgets('a tutor without open times says so', (tester) async {
    await pumpStudyLinkApp(
      tester,
      signedIn: true,
      backend: FakeStudyLinkBackend(slots: []),
    );

    await openGraceTimes(tester);

    expect(find.textContaining('has no open times right now'), findsOneWidget);
  });

  testWidgets('a student can cancel a session and then remove it', (
    tester,
  ) async {
    final backend = FakeStudyLinkBackend();
    await pumpStudyLinkApp(tester, signedIn: true, backend: backend);
    await openGraceTimes(tester);
    await tapVisible(tester, find.text('Confirm booking'));
    await tapVisible(tester, find.text('View my sessions'));

    // Open the upcoming session and cancel it.
    await tapVisible(tester, find.text('Data Structures & Algorithms').first);
    await tapVisible(tester, find.text('Cancel session'));
    await tapVisible(tester, find.text('Yes, cancel session'));

    expect(backend.sessions.single.isCancelled, isTrue);
    expect(find.text('Session cancelled.'), findsOneWidget);
    expect(find.textContaining('Cancelled'), findsOneWidget);

    await tapVisible(tester, find.text('Remove'));
    expect(backend.sessions, isEmpty);
    expect(find.text('Session removed.'), findsOneWidget);
  });

  testWidgets('a student can rate a past session', (tester) async {
    final backend = FakeStudyLinkBackend(sessions: [pastSession]);
    await pumpStudyLinkApp(tester, signedIn: true, backend: backend);

    await tester.tap(find.text('Sessions'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Rate this session'));

    expect(find.text('How was your session with Grace?'), findsOneWidget);
    await tapVisible(tester, find.byIcon(Icons.star_border_rounded).last);
    await tapVisible(tester, find.text('Submit rating'));

    expect(backend.ratings['booking-past']!.$1, 5);
    expect(find.text('Thanks for rating your session.'), findsOneWidget);
    expect(find.text('Rate this session'), findsNothing);
  });
}
