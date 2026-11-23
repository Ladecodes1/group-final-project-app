import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/app/state/study_link_cubit.dart';

import '../helpers/fake_study_link_backend.dart';

/// Lets streams and async calls finish.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late FakeStudyLinkBackend backend;
  late StudyLinkCubit cubit;

  setUp(() {
    backend = FakeStudyLinkBackend(sessions: [pastSession]);
    cubit = StudyLinkCubit(backend);
  });

  tearDown(() async {
    await cubit.close();
    await backend.dispose();
  });

  Future<void> signIn() async {
    await cubit.start(
      userId: 'student-1',
      email: 'aline.uwase@alustudent.com',
      displayName: 'Aline Uwase',
    );
    await settle();
  }

  /// Signs in and picks DSA and Grace, so her open slots are loaded.
  Future<void> chooseGrace() async {
    await signIn();
    cubit.selectSubject('dsa');
    await settle();
    cubit.selectTutor(grace);
    await settle();
  }

  group('signing in', () {
    test('saves the student profile and loads subjects and sessions', () async {
      await signIn();

      expect(backend.savedProfiles, ['student-1|Aline Uwase']);
      expect(cubit.state.userId, 'student-1');
      expect(cubit.state.subjects.map((s) => s.name), contains('Statistics'));
      expect(cubit.state.sessions.single.id, 'booking-past');
    });

    test('signing in again as the same user does nothing new', () async {
      await signIn();
      await signIn();
      expect(backend.savedProfiles, hasLength(1));
    });

    test('signing out clears the booking data', () async {
      await signIn();
      await cubit.stop();
      expect(cubit.state.userId, isEmpty);
      expect(cubit.state.sessions, isEmpty);
    });
  });

  group('finding a tutor', () {
    test('choosing a subject by id loads its tutors', () async {
      await signIn();
      cubit.selectSubject('dsa');
      await settle();

      expect(cubit.state.selectedSubject, 'Data Structures & Algorithms');
      expect(cubit.state.selectedSubjectId, 'dsa');
      expect(cubit.state.tutors.single.name, 'Grace Uwase');
      expect(cubit.state.tutorsLoading, isFalse);
    });

    test('a typed search matches part of a subject name', () async {
      await signIn();
      cubit.selectSubject('statis');
      await settle();
      expect(cubit.state.selectedSubjectId, 'stats');
      expect(cubit.state.tutors, isEmpty); // nobody teaches Statistics yet
    });

    test('an unknown subject shows no tutors', () async {
      await signIn();
      cubit.selectSubject('Astrophysics');
      await settle();
      expect(cubit.state.selectedSubjectId, isEmpty);
      expect(cubit.state.tutors, isEmpty);
      expect(cubit.state.tutorsLoading, isFalse);
    });

    test('the tutor filter can be changed', () {
      cubit.setTutorFilter('Online');
      expect(cubit.state.tutorFilter, 'Online');
    });
  });

  group('choosing a time', () {
    test(
      'choosing a tutor loads open slots and selects the first one',
      () async {
        await chooseGrace();

        expect(cubit.state.days, ['Thu 24', 'Fri 25']);
        expect(cubit.state.selectedDay, 'Thu 24');
        expect(cubit.state.timesForSelectedDay, ['10:00', '16:00']);
        expect(cubit.state.selectedSlot?.id, 'slot-a');
      },
    );

    test('choosing another day selects its first time', () async {
      await chooseGrace();
      cubit.selectDay('Fri 25');
      expect(cubit.state.selectedTime, '14:00');
      expect(cubit.state.selectedSlot?.id, 'slot-c');
    });

    test('choosing a time selects that slot', () async {
      await chooseGrace();
      cubit.selectTime('16:00');
      expect(cubit.state.selectedSlot?.id, 'slot-b');
    });
  });

  group('booking', () {
    test('confirming saves the booking and shows it in My Sessions', () async {
      await chooseGrace();
      cubit.setPrivateNote('Recursion in merge sort');

      final ok = await cubit.confirmBooking();
      await settle();

      expect(ok, isTrue);
      expect(cubit.state.lastBooked?.tutorName, 'Grace Uwase');
      final booked = cubit.state.sessions.firstWhere(
        (s) => s.id == 'booking-slot-a',
      );
      expect(booked.isUpcoming, isTrue);
      expect(booked.privateNote, 'Recursion in merge sort');
      // The booked slot is no longer offered.
      expect(cubit.state.slots.map((s) => s.id), isNot(contains('slot-a')));
    });

    test(
      'a slot that was just taken keeps the choices and explains why',
      () async {
        await chooseGrace();
        backend.failNextBookingWith =
            'That time was just taken. Please pick another slot.';

        final ok = await cubit.confirmBooking();

        expect(ok, isFalse);
        expect(cubit.state.lastBookingFailed, isTrue);
        expect(
          cubit.state.message,
          'That time was just taken. Please pick another slot.',
        );
        expect(cubit.state.selectedTutor.name, 'Grace Uwase');
        expect(cubit.state.isSaving, isFalse);
      },
    );

    test('booking without choosing a time is refused', () async {
      await signIn();
      final ok = await cubit.confirmBooking();
      expect(ok, isFalse);
      expect(cubit.state.message, 'Please choose an open time first.');
    });
  });

  group('managing sessions', () {
    test('cancelling changes only that session and frees its slot', () async {
      await chooseGrace();
      await cubit.confirmBooking();
      await settle();

      await cubit.cancelSession('booking-slot-a');
      await settle();

      final cancelled = cubit.state.sessions.firstWhere(
        (s) => s.id == 'booking-slot-a',
      );
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.isUpcoming, isFalse);
      expect(
        cubit.state.sessions
            .firstWhere((s) => s.id == 'booking-past')
            .isCancelled,
        isFalse,
      );
      expect(cubit.state.slots.map((s) => s.id), contains('slot-a'));
    });

    test('a cancelled session can be removed', () async {
      await chooseGrace();
      await cubit.confirmBooking();
      await cubit.cancelSession('booking-slot-a');
      await cubit.removeSession('booking-slot-a');
      await settle();

      expect(
        cubit.state.sessions.map((s) => s.id),
        isNot(contains('booking-slot-a')),
      );
    });

    test('removing a session that is not cancelled shows the error', () async {
      await signIn();
      await cubit.removeSession('booking-past');
      expect(cubit.state.message, 'Only cancelled bookings can be deleted.');
      expect(cubit.state.sessions, hasLength(1));
    });

    test('a rating is saved on the rated session with the feedback', () async {
      await signIn();
      cubit.prepareRating(pastSession);
      cubit.setRating(5);
      cubit.toggleFeedbackTag('Patient');
      cubit.setExtraFeedback('Very clear');

      await cubit.submitRating('booking-past');
      await settle();

      final (stars, comment) = backend.ratings['booking-past']!;
      expect(stars, 5);
      expect(comment, contains('Patient'));
      expect(comment, contains('Very clear'));
      expect(cubit.state.sessions.single.isRated, isTrue);
      expect(cubit.state.message, 'Thanks for rating your session.');
    });
  });

  group('rating form', () {
    test('feedback tags can be toggled on and off', () {
      cubit.toggleFeedbackTag('Patient');
      expect(cubit.state.feedbackTags, contains('Patient'));
      cubit.toggleFeedbackTag('Patient');
      expect(cubit.state.feedbackTags, isNot(contains('Patient')));
    });

    test('the rating is kept between 1 and 5 stars', () {
      cubit.setRating(9);
      expect(cubit.state.rating, 5);
      cubit.setRating(0);
      expect(cubit.state.rating, 1);
    });

    test('other choices are remembered', () {
      cubit
        ..selectMeetingMode('Online')
        ..setUnstuckAnswer('Partly')
        ..setCancelReason('I figured it out')
        ..setSearchQuery('dat');
      expect(cubit.state.meetingMode, 'Online');
      expect(cubit.state.unstuckAnswer, 'Partly');
      expect(cubit.state.cancelReason, 'I figured it out');
      expect(cubit.state.searchQuery, 'dat');
    });
  });
}
