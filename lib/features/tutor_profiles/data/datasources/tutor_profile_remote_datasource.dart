import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/app_exception.dart';
import '../models/tutor_profile_model.dart';

/// Talks to Cloud Firestore. Nothing outside the data layer uses this.
abstract class TutorProfileRemoteDataSource {
  Future<void> createProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  });
  Future<TutorProfileModel> getProfile(String uid);
  Stream<List<TutorProfileModel>> watchTutorsBySubject(String subjectId);
  Future<void> updateProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  });
  Future<void> setActive(String uid, {required bool isActive});
  Future<void> deleteProfile(String uid);
}

class TutorProfileRemoteDataSourceImpl implements TutorProfileRemoteDataSource {
  TutorProfileRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection(FirestoreCollections.tutorProfiles);

  @override
  Future<void> createProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  }) async {
    final ref = _profiles.doc(uid);
    await _firestore.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) {
        throw const AppException('You already have a tutor profile.');
      }
      tx.set(
        ref,
        TutorProfileModel.toDocument(
          bio: bio,
          yearOfStudy: yearOfStudy,
          subjectIds: subjectIds,
        ),
      );
    });
  }

  @override
  Future<TutorProfileModel> getProfile(String uid) async {
    final doc = await _profiles.doc(uid).get();
    return TutorProfileModel.fromFirestore(doc);
  }

  /// Needs a composite index:
  /// tutorProfiles -> isActive (asc), subjectIds (array contains).
  @override
  Stream<List<TutorProfileModel>> watchTutorsBySubject(String subjectId) {
    return _profiles
        .where('isActive', isEqualTo: true)
        .where('subjectIds', arrayContains: subjectId)
        .snapshots()
        .map((s) => s.docs.map(TutorProfileModel.fromFirestore).toList());
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String bio,
    required int yearOfStudy,
    required List<String> subjectIds,
  }) {
    return _profiles.doc(uid).update({
      'bio': bio,
      'yearOfStudy': yearOfStudy,
      'subjectIds': subjectIds,
    });
  }

  @override
  Future<void> setActive(String uid, {required bool isActive}) {
    return _profiles.doc(uid).update({'isActive': isActive});
  }

  @override
  Future<void> deleteProfile(String uid) {
    return _profiles.doc(uid).delete();
  }
}
