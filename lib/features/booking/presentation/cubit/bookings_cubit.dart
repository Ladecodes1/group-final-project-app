import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._repository) : super(const BookingsState());

  final BookingRepository _repository;
  StreamSubscription<List<Booking>>? _subscription;

  void watchStudentBookings(String studentId) {
    _watch(_repository.watchStudentBookings(studentId));
  }

  void watchTutorBookings(String tutorId) {
    _watch(_repository.watchTutorBookings(tutorId));
  }

  void _watch(Stream<List<Booking>> stream) {
    _subscription?.cancel();

    emit(const BookingsState(status: BookingsStatus.loading));

    _subscription = stream.listen(
      (bookings) {
        emit(BookingsState(
          status: BookingsStatus.loaded,
          bookings: bookings,
        ));
      },
      onError: (Object error) {
        emit(BookingsState(
          status: BookingsStatus.error,
          errorMessage: error is AppException
              ? error.message
              : 'Unable to load bookings. Please try again.',
        ));
      },
    );
  }

  Future<String?> createBooking({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  }) async {
    try {
      return await _repository.createBooking(
        studentId: studentId,
        tutorId: tutorId,
        slotId: slotId,
        subjectId: subjectId,
        topicNote: topicNote,
      );
    } catch (error) {
      _emitActionError(error);
      return null;
    }
  }

  Future<void> updateTopicNote({
    required String bookingId,
    required String topicNote,
  }) async {
    await _performAction(
      () => _repository.updateTopicNote(bookingId, topicNote),
    );
  }

  Future<void> completeBooking(String bookingId) async {
    await _performAction(() => _repository.completeBooking(bookingId));
  }

  Future<void> cancelBooking(String bookingId) async {
    await _performAction(() => _repository.cancelBooking(bookingId));
  }

  Future<void> deleteBooking(String bookingId) async {
    await _performAction(() => _repository.deleteBooking(bookingId));
  }

  Future<void> _performAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _emitActionError(error);
    }
  }

  void _emitActionError(Object error) {
    emit(BookingsState(
      status: BookingsStatus.error,
      bookings: state.bookings,
      errorMessage: error is AppException
          ? error.message
          : 'The booking action failed. Please try again.',
    ));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
