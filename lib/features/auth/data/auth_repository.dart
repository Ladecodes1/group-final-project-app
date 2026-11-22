import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthProfile {
  const AuthProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.programme,
    required this.year,
    required this.isTutor,
  });

  final String uid;
  final String name;
  final String email;
  final String programme;
  final int year;
  final bool isTutor;
}

abstract interface class AuthRepository {
  Future<AuthProfile> signIn({required String email, required String password});
  Future<AuthProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String programme,
    required int year,
    required bool isTutor,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth get _auth {
    if (Firebase.apps.isEmpty) {
      throw StateError(
          'Firebase is not configured. Add the StudyLink Firebase dart-define values before signing in.');
    }
    return FirebaseAuth.instance;
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Future<AuthProfile> signIn(
      {required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Authentication did not return a user.');
    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data() ?? <String, dynamic>{};
    return AuthProfile(
      uid: user.uid,
      name: (data['displayName'] ?? user.displayName ?? user.email ?? 'Student')
          .toString(),
      email: user.email ?? email.trim(),
      programme: (data['programme'] ?? '').toString(),
      year: (data['year'] as num?)?.toInt() ?? 1,
      isTutor: data['isTutor'] == true,
    );
  }

  @override
  Future<AuthProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String programme,
    required int year,
    required bool isTutor,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Account creation did not return a user.');
    }
    await user.updateDisplayName(name.trim());
    final profile = <String, dynamic>{
      'uid': user.uid,
      'displayName': name.trim(),
      'email': email.trim(),
      'programme': programme,
      'year': year,
      'isTutor': isTutor,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(user.uid).set(profile);
    if (isTutor) {
      await _db.collection('tutors').doc(user.uid).set({
        'bio': '',
        'subjects': <String>[],
        'ratingAggregate': 0,
        'sessionCount': 0,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return AuthProfile(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      programme: programme,
      year: year,
      isTutor: isTutor,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() => _auth.signOut();
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => FirebaseAuthRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  if (Firebase.apps.isEmpty) return Stream<User?>.value(null);
  return FirebaseAuth.instance.authStateChanges();
});
