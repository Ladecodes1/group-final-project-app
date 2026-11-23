import '../entities/availability_slot.dart';

abstract class AvailabilityRepository {
  Future<String> createSlot({
    required String tutorId,
    required String subjectId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  });

  Stream<List<AvailabilitySlot>> watchOpenSlots(String tutorId);
  Stream<List<AvailabilitySlot>> watchTutorSlots(String tutorId);

  Future<void> updateSlotTimes({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<void> deleteSlot(String slotId);
}
