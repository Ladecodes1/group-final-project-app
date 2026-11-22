import '../../../../core/error/app_exception.dart';
import '../../../../core/error/firebase_error_mapper.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/repositories/availability_repository.dart';
import '../datasources/availability_remote_datasource.dart';

/// Implements [AvailabilityRepository]: checks the rules for slot times,
/// then calls Firestore and reports problems in plain language.
class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._remote);

  final AvailabilityRemoteDataSource _remote;

  @override
  Future<String> createSlot({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    _validateTimes(startTime, endTime);
    return guardFirebase(
      () => _remote.createSlot(
        tutorId: tutorId,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }

  @override
  Stream<List<AvailabilitySlot>> watchOpenSlots(String tutorId) {
    return _remote.watchOpenSlots(tutorId).handleError(rethrowFriendly);
  }

  @override
  Stream<List<AvailabilitySlot>> watchTutorSlots(String tutorId) {
    return _remote.watchTutorSlots(tutorId).handleError(rethrowFriendly);
  }

  @override
  Future<void> updateSlotTimes({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    _validateTimes(startTime, endTime);
    return guardFirebase(
      () => _remote.updateSlotTimes(
        slotId: slotId,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }

  @override
  Future<void> deleteSlot(String slotId) {
    return guardFirebase(() => _remote.deleteSlot(slotId));
  }

  /// A slot must end after it starts, and must start in the future.
  void _validateTimes(DateTime startTime, DateTime endTime) {
    if (!endTime.isAfter(startTime)) {
      throw const AppException('The end time must be after the start time.');
    }
    if (!startTime.isAfter(DateTime.now())) {
      throw const AppException('Please pick a time in the future.');
    }
  }
}
