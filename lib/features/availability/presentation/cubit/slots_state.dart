import '../../domain/entities/availability_slot.dart';

enum SlotsStatus { initial, loading, loaded, error }

class SlotsState {
  const SlotsState({
    this.status = SlotsStatus.initial,
    this.slots = const [],
    this.errorMessage,
  });

  final SlotsStatus status;
  final List<AvailabilitySlot> slots;
  final String? errorMessage;
}
