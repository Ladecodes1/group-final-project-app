import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studylink/core/error/app_exception.dart';
import 'package:studylink/features/availability/domain/entities/availability_slot.dart';
import 'package:studylink/features/availability/domain/repositories/availability_repository.dart';
import 'package:studylink/features/availability/presentation/cubit/slots_cubit.dart';
import 'package:studylink/features/availability/presentation/cubit/slots_state.dart';
import 'package:studylink/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:studylink/features/booking/data/models/booking_model.dart';
import 'package:studylink/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:studylink/features/booking/domain/entities/booking.dart';
import 'package:studylink/features/booking/domain/repositories/booking_repository.dart';
import 'package:studylink/features/booking/presentation/cubit/bookings_cubit.dart';
import 'package:studylink/features/booking/presentation/cubit/bookings_state.dart';
import 'package:studylink/features/tutor_profiles/domain/entities/tutor_profile.dart';
import 'package:studylink/features/tutor_profiles/domain/repositories/tutor_profile_repository.dart';
import 'package:studylink/features/tutor_profiles/presentation/cubit/tutors_cubit.dart';
import 'package:studylink/features/tutor_profiles/presentation/cubit/tutors_state.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

class MockTutorRepository extends Mock implements TutorProfileRepository {}

class MockSlotRepository extends Mock implements AvailabilityRepository {}

class MockBookingDataSource extends Mock implements BookingRemoteDataSource {}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

final booking = Booking(
  id: 'b1',
  studentId: 's1',
  tutorId: 't1',
  slotId: 'slot1',
  subjectId: 'dsa',
  status: BookingStatus.confirmed,
  topicNote: 'Recursion',
  createdAt: DateTime(2026, 11, 20),
);

void main() {
  group('BookingsCubit', () {
    late MockBookingRepository repo;
    late BookingsCubit cubit;

    setUp(() {
      repo = MockBookingRepository();
      cubit = BookingsCubit(repo);
    });
    tearDown(() => cubit.close());

    test('watching a student loads their bookings', () async {
      when(() => repo.watchStudentBookings('s1'))
          .thenAnswer((_) => Stream.value([booking]));
      cubit.watchStudentBookings('s1');
      expect(cubit.state.status, BookingsStatus.loading);
      await settle();
      expect(cubit.state.status, BookingsStatus.loaded);
      expect(cubit.state.bookings.single.id, 'b1');
    });

    test('watching a tutor loads the bookings they receive', () async {
      when(() => repo.watchTutorBookings('t1'))
          .thenAnswer((_) => Stream.value([booking]));
      cubit.watchTutorBookings('t1');
      await settle();
      expect(cubit.state.bookings, hasLength(1));
    });

    test('a stream error shows its message', () async {
      when(
        () => repo.watchStudentBookings('s1'),
      ).thenAnswer((_) => Stream.error(const AppException('No connection.')));
      cubit.watchStudentBookings('s1');
      await settle();
      expect(cubit.state.status, BookingsStatus.error);
      expect(cubit.state.errorMessage, 'No connection.');
    });

    test(
      'creating a booking returns its id, or null with a message on failure',
      () async {
        when(
          () => repo.createBooking(
            studentId: 's1',
            tutorId: 't1',
            slotId: 'slot1',
            subjectId: 'dsa',
            topicNote: 'n',
          ),
        ).thenAnswer((_) async => 'b1');
        expect(
          await cubit.createBooking(
            studentId: 's1',
            tutorId: 't1',
            slotId: 'slot1',
            subjectId: 'dsa',
            topicNote: 'n',
          ),
          'b1',
        );

        when(
          () => repo.createBooking(
            studentId: any(named: 'studentId'),
            tutorId: any(named: 'tutorId'),
            slotId: 'taken',
            subjectId: any(named: 'subjectId'),
            topicNote: any(named: 'topicNote'),
          ),
        ).thenThrow(
          const AppException(
            'That time was just taken. Please pick another slot.',
          ),
        );
        expect(
          await cubit.createBooking(
            studentId: 's1',
            tutorId: 't1',
            slotId: 'taken',
            subjectId: 'dsa',
            topicNote: 'n',
          ),
          isNull,
        );
        expect(
          cubit.state.errorMessage,
          'That time was just taken. Please pick another slot.',
        );
      },
    );

    test('update, complete, cancel and delete call the repository', () async {
      when(() => repo.updateTopicNote('b1', 'New note'))
          .thenAnswer((_) async {});
      when(() => repo.completeBooking('b1')).thenAnswer((_) async {});
      when(() => repo.cancelBooking('b1')).thenAnswer((_) async {});
      when(() => repo.deleteBooking('b1')).thenAnswer((_) async {});

      await cubit.updateTopicNote(bookingId: 'b1', topicNote: 'New note');
      await cubit.completeBooking('b1');
      await cubit.cancelBooking('b1');
      await cubit.deleteBooking('b1');

      verify(() => repo.updateTopicNote('b1', 'New note')).called(1);
      verify(() => repo.completeBooking('b1')).called(1);
      verify(() => repo.cancelBooking('b1')).called(1);
      verify(() => repo.deleteBooking('b1')).called(1);
    });

    test('a failed action keeps the bookings and shows a message', () async {
      when(() => repo.deleteBooking('b1')).thenThrow(
        const AppException('Only cancelled bookings can be deleted.'),
      );
      await cubit.deleteBooking('b1');
      expect(cubit.state.status, BookingsStatus.error);
      expect(
        cubit.state.errorMessage,
        'Only cancelled bookings can be deleted.',
      );
    });
  });

  group('TutorsCubit', () {
    test('loads the active tutors for a subject, or shows an error', () async {
      final repo = MockTutorRepository();
      final cubit = TutorsCubit(repo);
      addTearDown(cubit.close);
      when(() => repo.watchTutorsBySubject('dsa')).thenAnswer(
        (_) => Stream.value(const [
          TutorProfile(
            uid: 't1',
            bio: 'Hi',
            yearOfStudy: 3,
            subjectIds: ['dsa'],
            isActive: true,
          ),
        ]),
      );
      cubit.watchTutorsBySubject('dsa');
      await settle();
      expect(cubit.state.status, TutorsStatus.loaded);
      expect(cubit.state.tutors.single.uid, 't1');

      when(() => repo.watchTutorsBySubject('x'))
          .thenAnswer((_) => Stream.error(Exception('x')));
      cubit.watchTutorsBySubject('x');
      await settle();
      expect(cubit.state.status, TutorsStatus.error);
      expect(
        cubit.state.errorMessage,
        'Unable to load tutors. Please try again.',
      );
    });
  });

  group('SlotsCubit', () {
    test('loads open slots and all of a tutor\'s slots', () async {
      final repo = MockSlotRepository();
      final cubit = SlotsCubit(repo);
      addTearDown(cubit.close);
      final slot = AvailabilitySlot(
        id: 'slot1',
        tutorId: 't1',
        subjectId: 'dsa',
        date: DateTime(2099),
        startTime: DateTime(2099),
        endTime: DateTime(2099),
        isBooked: false,
      );
      when(() => repo.watchOpenSlots('t1'))
          .thenAnswer((_) => Stream.value([slot]));
      when(() => repo.watchTutorSlots('t1'))
          .thenAnswer((_) => Stream.value([slot, slot]));

      cubit.watchOpenSlots('t1');
      await settle();
      expect(cubit.state.status, SlotsStatus.loaded);
      expect(cubit.state.slots, hasLength(1));

      cubit.watchTutorSlots('t1');
      await settle();
      expect(cubit.state.slots, hasLength(2));
    });
  });

  group('BookingRepositoryImpl', () {
    late MockBookingDataSource remote;
    late BookingRepositoryImpl repo;

    setUp(() {
      remote = MockBookingDataSource();
      repo = BookingRepositoryImpl(remote);
    });

    test('passes calls through to Firestore', () async {
      final model = BookingModel(
        id: 'b1',
        studentId: 's1',
        tutorId: 't1',
        slotId: 'slot1',
        subjectId: 'dsa',
        status: BookingStatus.confirmed,
        topicNote: '',
        createdAt: DateTime(2026),
      );
      when(() => remote.getBooking('b1')).thenAnswer((_) async => model);
      when(() => remote.cancelBooking('b1')).thenAnswer((_) async {});
      when(() => remote.watchStudentBookings('s1'))
          .thenAnswer((_) => Stream.value([model]));

      expect((await repo.getBooking('b1')).id, 'b1');
      await repo.cancelBooking('b1');
      expect((await repo.watchStudentBookings('s1').first).single.id, 'b1');
      verify(() => remote.cancelBooking('b1')).called(1);
    });

    test(
      'turns a Firebase error into a message the user understands',
      () async {
        when(() => remote.cancelBooking('b1')).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        );
        await expectLater(
          repo.cancelBooking('b1'),
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

    test('stream errors are turned into friendly messages too', () async {
      final controller = StreamController<List<BookingModel>>();
      when(() => remote.watchStudentBookings('s1'))
          .thenAnswer((_) => controller.stream);
      final future = repo.watchStudentBookings('s1').first;
      controller.addError(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
      await expectLater(future, throwsA(isA<AppException>()));
      await controller.close();
    });
  });
}
