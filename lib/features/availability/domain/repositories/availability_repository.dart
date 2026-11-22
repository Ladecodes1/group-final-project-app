import '../entities/availability_slot.dart';

/// What the app can do with tutor time slots.
abstract class AvailabilityRepository {
  /// CREATE: a tutor adds a slot. Returns the new slot id.
  /// Throws [AppException] if the times are not valid.
  Future<String> createSlot({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// READ: live list of a tutor's future slots that are still free.
  /// Students use this when they pick a time.
  Stream<List<AvailabilitySlot>> watchOpenSlots(String tutorId);

  /// READ: live list of all of a tutor's slots, booked or not.
  /// The tutor uses this to manage their own schedule.
  Stream<List<AvailabilitySlot>> watchTutorSlots(String tutorId);

  /// UPDATE: changes the times of a slot that has not been booked yet.
  Future<void> updateSlotTimes({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// DELETE: removes a slot. Booked slots cannot be deleted.
  Future<void> deleteSlot(String slotId);
}
