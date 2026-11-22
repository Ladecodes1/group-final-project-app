import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/app_exception.dart';
import '../models/availability_slot_model.dart';

/// Talks to Cloud Firestore. Nothing outside the data layer uses this.
abstract class AvailabilityRemoteDataSource {
  Future<String> createSlot({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
  });
  Stream<List<AvailabilitySlotModel>> watchOpenSlots(String tutorId);
  Stream<List<AvailabilitySlotModel>> watchTutorSlots(String tutorId);
  Future<void> updateSlotTimes({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<void> deleteSlot(String slotId);
}

class AvailabilityRemoteDataSourceImpl implements AvailabilityRemoteDataSource {
  /// The Firestore instance is passed in so tests can use a fake one.
  AvailabilityRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _slots =>
      _firestore.collection(FirestoreCollections.availabilitySlots);

  @override
  Future<String> createSlot({
    required String tutorId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final ref = await _slots.add(
      AvailabilitySlotModel.newDocument(
        tutorId: tutorId,
        startTime: startTime,
        endTime: endTime,
      ),
    );
    return ref.id;
  }

  /// Needs a composite index:
  /// availabilitySlots -> tutorId (asc), isBooked (asc), startTime (asc).
  @override
  Stream<List<AvailabilitySlotModel>> watchOpenSlots(String tutorId) {
    return _slots
        .where('tutorId', isEqualTo: tutorId)
        .where('isBooked', isEqualTo: false)
        .where('startTime', isGreaterThan: Timestamp.now())
        .orderBy('startTime')
        .snapshots()
        .map((s) => s.docs.map(AvailabilitySlotModel.fromFirestore).toList());
  }

  /// Needs a composite index:
  /// availabilitySlots -> tutorId (asc), startTime (asc).
  @override
  Stream<List<AvailabilitySlotModel>> watchTutorSlots(String tutorId) {
    return _slots
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('startTime')
        .snapshots()
        .map((s) => s.docs.map(AvailabilitySlotModel.fromFirestore).toList());
  }

  @override
  Future<void> updateSlotTimes({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final ref = _slots.doc(slotId);
    // A transaction stops a slot being edited at the moment it gets booked.
    await _firestore.runTransaction((tx) async {
      final slot = await tx.get(ref);
      if (slot.data()?['isBooked'] == true) {
        throw const AppException(
          'This slot is already booked, so its time cannot be changed.',
        );
      }
      tx.update(ref, {
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
      });
    });
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    final ref = _slots.doc(slotId);
    await _firestore.runTransaction((tx) async {
      final slot = await tx.get(ref);
      if (slot.data()?['isBooked'] == true) {
        throw const AppException(
          'This slot is already booked and cannot be removed.',
        );
      }
      tx.delete(ref);
    });
  }
}
