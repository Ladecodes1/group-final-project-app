import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studylink/core/error/app_exception.dart';
import 'package:studylink/core/error/firebase_error_mapper.dart';
import 'package:studylink/features/availability/data/models/availability_slot_model.dart';
import 'package:studylink/features/booking/data/models/booking_model.dart';
import 'package:studylink/features/booking/domain/entities/booking.dart';
import 'package:studylink/features/reviews/data/models/review_model.dart';
import 'package:studylink/features/subjects/data/models/subject_model.dart';
import 'package:studylink/features/tutor_profiles/data/models/tutor_profile_model.dart';
import 'package:studylink/features/users/data/models/user_model.dart';

// Mocking a Firestore document is the usual way to test model conversion.
// ignore: subtype_of_sealed_class
class MockDoc extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

/// A Firestore document with [id] and [data] (null = the document is missing).
MockDoc doc(String id, Map<String, dynamic>? data) {
  final d = MockDoc();
  when(() => d.id).thenReturn(id);
  when(() => d.data()).thenReturn(data);
  return d;
}

void main() {
  final when_ = DateTime(2026, 11, 26, 16);
  final ts = Timestamp.fromDate(when_);

  group('BookingModel', () {
    test('reads every field from the document', () {
      final b = BookingModel.fromFirestore(
        doc('b1', {
          'studentId': 's1',
          'tutorId': 't1',
          'slotId': 'slot1',
          'subjectId': 'dsa',
          'status': 'completed',
          'topicNote': 'Recursion',
          'createdAt': ts,
        }),
      );
      expect(b.id, 'b1');
      expect(b.studentId, 's1');
      expect(b.tutorId, 't1');
      expect(b.slotId, 'slot1');
      expect(b.subjectId, 'dsa');
      expect(b.status, BookingStatus.completed);
      expect(b.topicNote, 'Recursion');
      expect(b.createdAt, when_);
    });

    test(
      'an unknown status is treated as confirmed, and cancelled is detected',
      () {
        expect(
          BookingModel.fromFirestore(doc('b', {'status': 'weird'})).status,
          BookingStatus.confirmed,
        );
        expect(
          BookingModel.fromFirestore(doc('b', {'status': 'cancelled'}))
              .isCancelled,
          isTrue,
        );
      },
    );

    test('a missing document gives a clear error', () {
      expect(
        () => BookingModel.fromFirestore(doc('b', null)),
        throwsA(isA<AppException>()),
      );
    });

    test('a new booking starts confirmed with a server timestamp', () {
      final map = BookingModel.newDocument(
        studentId: 's1',
        tutorId: 't1',
        slotId: 'slot1',
        subjectId: 'dsa',
        topicNote: 'n',
      );
      expect(map['status'], 'confirmed');
      expect(map['studentId'], 's1');
      expect(map['createdAt'], isA<FieldValue>());
    });
  });

  group('AvailabilitySlotModel', () {
    test('reads the times and booked flag', () {
      final s = AvailabilitySlotModel.fromFirestore(
        doc('slot1', {
          'tutorId': 't1',
          'subjectId': 'dsa',
          'date': ts,
          'startTime': ts,
          'endTime': Timestamp.fromDate(when_.add(const Duration(minutes: 45))),
          'isBooked': true,
        }),
      );
      expect(s.id, 'slot1');
      expect(s.subjectId, 'dsa');
      expect(s.startTime, when_);
      expect(s.endTime.difference(s.startTime).inMinutes, 45);
      expect(s.isBooked, isTrue);
    });

    test('a new slot is stored as not booked, with timestamps', () {
      final map = AvailabilitySlotModel.newDocument(
        tutorId: 't1',
        subjectId: 'dsa',
        date: when_,
        startTime: when_,
        endTime: when_,
      );
      expect(map['isBooked'], isFalse);
      expect(map['startTime'], isA<Timestamp>());
      expect(map['subjectId'], 'dsa');
    });

    test('a missing slot gives a clear error', () {
      expect(
        () => AvailabilitySlotModel.fromFirestore(doc('x', null)),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('ReviewModel', () {
    test('reads the review, including the student and tutor', () {
      final r = ReviewModel.fromFirestore(
        doc('b1', {
          'bookingId': 'b1',
          'studentId': 's1',
          'tutorId': 't1',
          'rating': 5,
          'comment': 'Clear',
          'createdAt': ts,
        }),
      );
      expect(r.bookingId, 'b1');
      expect(r.studentId, 's1');
      expect(r.tutorId, 't1');
      expect(r.rating, 5);
      expect(r.comment, 'Clear');
    });

    test('a review stores who wrote it (needed by the security rules)', () {
      final map = ReviewModel.newDocument(
        bookingId: 'b1',
        studentId: 's1',
        tutorId: 't1',
        rating: 4,
        comment: 'ok',
      );
      expect(map['studentId'], 's1');
      expect(map['tutorId'], 't1');
      expect(map['rating'], 4);
    });
  });

  group('SubjectModel, TutorProfileModel and UserModel', () {
    test('subject fields', () {
      final s = SubjectModel.fromFirestore(
        doc('dsa', {'name': 'DSA', 'courseCode': 'SE 201'}),
      );
      expect((s.id, s.name, s.courseCode), ('dsa', 'DSA', 'SE 201'));
      expect(
        () => SubjectModel.fromFirestore(doc('x', null)),
        throwsA(isA<AppException>()),
      );
    });

    test('tutor profile fields and defaults', () {
      final t = TutorProfileModel.fromFirestore(
        doc('t1', {
          'bio': 'Hi',
          'yearOfStudy': 3,
          'subjectIds': ['dsa', 'stats'],
          'isActive': false,
        }),
      );
      expect(t.uid, 't1');
      expect(t.yearOfStudy, 3);
      expect(t.subjectIds, ['dsa', 'stats']);
      expect(t.isActive, isFalse);

      final empty = TutorProfileModel.fromFirestore(doc('t2', {}));
      expect(empty.yearOfStudy, 1);
      expect(empty.subjectIds, isEmpty);
      expect(empty.isActive, isTrue);

      final map = TutorProfileModel.toDocument(
        bio: 'Hi',
        yearOfStudy: 2,
        subjectIds: ['dsa'],
      );
      expect(map['isActive'], isTrue);
      expect(map['subjectIds'], ['dsa']);
    });

    test('user fields', () {
      final u = UserModel.fromFirestore(
        doc('u1', {
          'displayName': 'Aline',
          'email': 'aline@alustudent.com',
          'university': 'ALU',
          'createdAt': ts,
        }),
      );
      expect((u.uid, u.displayName, u.university), ('u1', 'Aline', 'ALU'));
      expect(
        () => UserModel.fromFirestore(doc('x', null)),
        throwsA(isA<AppException>()),
      );

      final map = UserModel.newDocument(
        displayName: 'Aline',
        email: 'a@b.co',
        university: 'ALU',
      );
      expect(map['email'], 'a@b.co');
      expect(map['createdAt'], isA<FieldValue>());
    });
  });

  group('Firebase error messages', () {
    FirebaseException err(String code) =>
        FirebaseException(plugin: 'cloud_firestore', code: code);

    test('each error code becomes a clear message', () {
      expect(
        friendlyFirebaseMessage(err('permission-denied')),
        "You don't have permission to do that.",
      );
      expect(
        friendlyFirebaseMessage(err('unavailable')),
        'No connection. Check your internet and try again.',
      );
      expect(
        friendlyFirebaseMessage(err('not-found')),
        'We could not find that item.',
      );
      expect(
        friendlyFirebaseMessage(err('other')),
        'Something went wrong. Please try again.',
      );
    });

    test(
      'guardFirebase returns the result or a friendly AppException',
      () async {
        expect(await guardFirebase(() async => 42), 42);
        await expectLater(
          guardFirebase<void>(() async => throw err('permission-denied')),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              "You don't have permission to do that.",
            ),
          ),
        );
      },
    );

    test('stream errors are made friendly too', () {
      expect(
        () => rethrowFriendly(err('unavailable')),
        throwsA(isA<AppException>()),
      );
      expect(
        () => rethrowFriendly(StateError('x')),
        throwsA(isA<StateError>()),
      );
    });
  });
}
