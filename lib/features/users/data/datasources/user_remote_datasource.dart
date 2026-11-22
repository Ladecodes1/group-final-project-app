import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/user_model.dart';

/// Talks to Cloud Firestore. Nothing outside the data layer uses this.
abstract class UserRemoteDataSource {
  Future<void> createUserIfAbsent({
    required String uid,
    required String displayName,
    required String email,
    required String university,
  });
  Future<UserModel> getUser(String uid);
  Stream<UserModel> watchUser(String uid);
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String university,
  });
  Future<void> deleteUser(String uid);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<void> createUserIfAbsent({
    required String uid,
    required String displayName,
    required String email,
    required String university,
  }) async {
    final ref = _users.doc(uid);
    await _firestore.runTransaction((tx) async {
      // Only write if the profile is missing, so a second Google sign-in
      // does not overwrite what the user already saved.
      if ((await tx.get(ref)).exists) return;
      tx.set(
        ref,
        UserModel.newDocument(
          displayName: displayName,
          email: email,
          university: university,
        ),
      );
    });
  }

  @override
  Future<UserModel> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Stream<UserModel> watchUser(String uid) {
    return _users.doc(uid).snapshots().map(UserModel.fromFirestore);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String university,
  }) {
    return _users.doc(uid).update({
      'displayName': displayName,
      'university': university,
    });
  }

  @override
  Future<void> deleteUser(String uid) {
    return _users.doc(uid).delete();
  }
}
