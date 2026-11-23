import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studylink/app/state/firestore_study_link_backend.dart';
import 'package:studylink/core/error/app_exception.dart';
import 'package:studylink/features/availability/domain/entities/availability_slot.dart';
import 'package:studylink/features/availability/domain/repositories/availability_repository.dart';
import 'package:studylink/features/booking/domain/entities/booking.dart';
import 'package:studylink/features/booking/domain/repositories/booking_repository.dart';
import 'package:studylink/features/reviews/domain/entities/review.dart';
import 'package:studylink/features/reviews/domain/repositories/review_repository.dart';
import 'package:studylink/features/subjects/domain/entities/subject.dart';
import 'package:studylink/features/subjects/domain/repositories/subject_repository.dart';
import 'package:studylink/features/tutor_profiles/domain/entities/tutor_profile.dart';
import 'package:studylink/features/tutor_profiles/domain/repositories/tutor_profile_repository.dart';
import 'package:studylink/features/users/domain/entities/user_profile.dart';
import 'package:studylink/features/users/domain/repositories/user_repository.dart';

class MockUsers extends Mock implements UserRepository {}

class MockSubjects extends Mock implements SubjectRepository {}

class MockTutors extends Mock implements TutorProfileRepository {}

class MockSlots extends Mock implements AvailabilityRepository {}

class MockBookings extends Mock implements BookingRepository {}

class MockReviews extends Mock implements ReviewRepository {}

void main() {
  late MockUsers users;
  late MockSubjects subjects;
  late MockTutors tutors;
  late MockSlots slots;
  late MockBookings bookings;
  late MockReviews reviews;
  late FirestoreStudyLinkBackend backend;

  const dsa = Subject(
    id: 'dsa',
    name: 'Data Structures & Algorithms',
    courseCode: 'SE 201',
  );
  final grace = UserProfile(
    uid: 'tutor-grace',
    displayName: 'Grace Uwase',
    email: 'grace@alustudent.com',
    university: 'ALU',
    createdAt: DateTime(2026),
  );
  const graceProfile = TutorProfile(
    uid: 'tutor-grace',
    bio: 'I passed DSA last year.',
    yearOfStudy: 3,
    subjectIds: ['dsa'],
    isActive: true,
  );
  final slot = AvailabilitySlot(
    id: 'slot-a',
    tutorId: 'tutor-grace',
    subjectId: 'dsa',
    date: DateTime(2099, 12, 24),
    startTime: DateTime(2099, 12, 24, 16),
    endTime: DateTime(2099, 12, 24, 16, 45),
    isBooked: true,
  );
  Booking booking({
    BookingStatus status = BookingStatus.confirmed,
    String slotId = 'slot-a',
  }) => Booking(
    id: 'booking-1',
    studentId: 'student-1',
    tutorId: 'tutor-grace',
    slotId: slotId,
    subjectId: 'dsa',
    status: status,
    topicNote: 'Recursion',
    createdAt: DateTime(2026, 11, 20, 9),
  );

  setUp(() {
    users = MockUsers();
    subjects = MockSubjects();
    tutors = MockTutors();
    slots = MockSlots();
    bookings = MockBookings();
    reviews = MockReviews();
    backend = FirestoreStudyLinkBackend(
      users: users,
      subjects: subjects,
      tutors: tutors,
      slots: slots,
      bookings: bookings,
      reviews: reviews,
    );
    when(() => users.getUser('tutor-grace')).thenAnswer((_) async => grace);
    when(() => subjects.getSubject('dsa')).thenAnswer((_) async => dsa);
    when(() => slots.getSlot('slot-a')).thenAnswer((_) async => slot);
  });

  test('saving the profile creates the users document once', () async {
    when(
      () => users.createUserIfAbsent(
        uid: any(named: 'uid'),
        displayName: any(named: 'displayName'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async {});

    await backend.saveUserProfile(
      uid: 'student-1',
      email: 'a@alustudent.com',
      displayName: 'A',
    );

    verify(
      () => users.createUserIfAbsent(
        uid: 'student-1',
        displayName: 'A',
        email: 'a@alustudent.com',
      ),
    ).called(1);
  });

  test('subjects come straight from Firestore', () async {
    when(() => subjects.watchSubjects()).thenAnswer((_) => Stream.value([dsa]));
    expect(
      (await backend.watchSubjects().first).single.name,
      'Data Structures & Algorithms',
    );
  });

  test(
    'tutors get their name from users and subject names from subjects',
    () async {
      when(() => tutors.watchTutorsBySubject('dsa'))
          .thenAnswer((_) => Stream.value([graceProfile]));

      final tutor = (await backend.watchTutors('dsa').first).single;

      expect(tutor.id, 'tutor-grace');
      expect(tutor.name, 'Grace Uwase');
      expect(tutor.initials, 'GU');
      expect(tutor.year, 'Year 3');
      expect(tutor.subjects, ['Data Structures & Algorithms']);
      expect(tutor.about, 'I passed DSA last year.');
      expect(tutor.isNew, isTrue);
    },
  );

  test('a tutor whose user document cannot be read is still shown', () async {
    when(() => users.getUser('tutor-grace'))
        .thenThrow(const AppException('not found'));
    when(() => tutors.watchTutorsBySubject('dsa'))
        .thenAnswer((_) => Stream.value([graceProfile]));

    final tutor = (await backend.watchTutors('dsa').first).single;
    expect(tutor.name, 'Peer tutor');
  });

  test('open slots come straight from Firestore', () async {
    when(() => slots.watchOpenSlots('tutor-grace'))
        .thenAnswer((_) => Stream.value([slot]));
    expect(
      (await backend.watchOpenSlots('tutor-grace').first).single.id,
      'slot-a',
    );
  });

  group('sessions', () {
    test(
      'a confirmed booking becomes an upcoming session with its slot time',
      () async {
        when(() => bookings.watchStudentBookings('student-1'))
            .thenAnswer((_) => Stream.value([booking()]));

        final session = (await backend.watchSessions('student-1').first).single;

        expect(session.id, 'booking-1');
        expect(session.subject, 'Data Structures & Algorithms');
        expect(session.tutorName, 'Grace Uwase');
        expect(session.day, 'THU');
        expect(session.date, '24');
        expect(session.time, '16:00');
        expect(session.isUpcoming, isTrue);
        expect(session.isCancelled, isFalse);
        expect(session.privateNote, 'Recursion');
      },
    );

    test('a cancelled booking is marked cancelled and not upcoming', () async {
      when(() => bookings.watchStudentBookings('student-1')).thenAnswer(
        (_) => Stream.value([booking(status: BookingStatus.cancelled)]),
      );

      final session = (await backend.watchSessions('student-1').first).single;
      expect(session.isCancelled, isTrue);
      expect(session.isUpcoming, isFalse);
    });

    test('a completed and reviewed booking shows its rating', () async {
      when(() => bookings.watchStudentBookings('student-1')).thenAnswer(
        (_) => Stream.value([booking(status: BookingStatus.completed)]),
      );
      when(() => reviews.getReviewForBooking('booking-1')).thenAnswer(
        (_) async => Review(
          id: 'booking-1',
          bookingId: 'booking-1',
          studentId: 'student-1',
          tutorId: 'tutor-grace',
          rating: 5,
          comment: 'Great',
          createdAt: DateTime(2026),
        ),
      );

      final session = (await backend.watchSessions('student-1').first).single;
      expect(session.isRated, isTrue);
      expect(session.rating, 5);
      expect(session.isUpcoming, isFalse);
    });

    test(
      'a booking whose slot was removed falls back to its created date',
      () async {
        when(() => slots.getSlot('gone'))
            .thenThrow(const AppException('That time slot no longer exists.'));
        when(() => bookings.watchStudentBookings('student-1'))
            .thenAnswer((_) => Stream.value([booking(slotId: 'gone')]));

        final session = (await backend.watchSessions('student-1').first).single;
        expect(session.date, '20');
        expect(session.time, '09:00');
      },
    );
  });

  group('actions', () {
    test('booking passes every field to the repository', () async {
      when(
        () => bookings.createBooking(
          studentId: any(named: 'studentId'),
          tutorId: any(named: 'tutorId'),
          slotId: any(named: 'slotId'),
          subjectId: any(named: 'subjectId'),
          topicNote: any(named: 'topicNote'),
        ),
      ).thenAnswer((_) async => 'booking-1');

      await backend.book(
        studentId: 's',
        tutorId: 't',
        slotId: 'slot-a',
        subjectId: 'dsa',
        topicNote: 'n',
      );

      verify(
        () => bookings.createBooking(
          studentId: 's',
          tutorId: 't',
          slotId: 'slot-a',
          subjectId: 'dsa',
          topicNote: 'n',
        ),
      ).called(1);
    });

    test('cancel and remove call the booking repository', () async {
      when(() => bookings.cancelBooking('booking-1')).thenAnswer((_) async {});
      when(() => bookings.deleteBooking('booking-1')).thenAnswer((_) async {});

      await backend.cancel('booking-1');
      await backend.remove('booking-1');

      verify(() => bookings.cancelBooking('booking-1')).called(1);
      verify(() => bookings.deleteBooking('booking-1')).called(1);
    });

    test(
      'rating a confirmed booking completes it before saving the review',
      () async {
        when(() => bookings.getBooking('booking-1'))
            .thenAnswer((_) async => booking());
        when(() => bookings.completeBooking('booking-1'))
            .thenAnswer((_) async {});
        when(
          () => reviews.createReview(
            bookingId: any(named: 'bookingId'),
            studentId: any(named: 'studentId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
          ),
        ).thenAnswer((_) async {});

        await backend.rate(
          bookingId: 'booking-1',
          studentId: 'student-1',
          rating: 4,
          comment: 'Clear',
        );

        verifyInOrder([
          () => bookings.completeBooking('booking-1'),
          () => reviews.createReview(
            bookingId: 'booking-1',
            studentId: 'student-1',
            rating: 4,
            comment: 'Clear',
          ),
        ]);
      },
    );

    test(
      'rating an already completed booking does not complete it again',
      () async {
        when(() => bookings.getBooking('booking-1'))
            .thenAnswer((_) async => booking(status: BookingStatus.completed));
        when(
          () => reviews.createReview(
            bookingId: any(named: 'bookingId'),
            studentId: any(named: 'studentId'),
            rating: any(named: 'rating'),
            comment: any(named: 'comment'),
          ),
        ).thenAnswer((_) async {});

        await backend.rate(
          bookingId: 'booking-1',
          studentId: 'student-1',
          rating: 4,
          comment: 'Clear',
        );

        verifyNever(() => bookings.completeBooking(any()));
      },
    );
  });

  group('labels', () {
    test('initials use the first two names', () {
      expect(initialsOf('Grace Uwase'), 'GU');
      expect(initialsOf('kevin'), 'K');
      expect(initialsOf('  '), '?');
    });

    test('slot labels and month name', () {
      final d = DateTime(2026, 11, 26, 9, 5);
      expect(slotDayLabel(d), 'Thu 26');
      expect(slotTimeLabel(d), '09:05');
      expect(monthLabel(d), 'November 2026');
    });
  });
}
