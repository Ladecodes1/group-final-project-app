import '../../domain/entities/booking.dart';

enum BookingsStatus { initial, loading, loaded, error }

class BookingsState {
  const BookingsState({
    this.status = BookingsStatus.initial,
    this.bookings = const [],
    this.errorMessage,
  });

  final BookingsStatus status;
  final List<Booking> bookings;
  final String? errorMessage;
}
