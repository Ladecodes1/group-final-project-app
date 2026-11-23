import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/subject_model.dart';

/// Talks to Cloud Firestore. Nothing outside the data layer uses this.
abstract class SubjectRemoteDataSource {
  Stream<List<SubjectModel>> watchSubjects();
  Future<SubjectModel> getSubject(String subjectId);
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  SubjectRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _subjects =>
      _firestore.collection(FirestoreCollections.subjects);

  @override
  Stream<List<SubjectModel>> watchSubjects() {
    return _subjects
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(SubjectModel.fromFirestore).toList());
  }

  @override
  Future<SubjectModel> getSubject(String subjectId) async {
    final doc = await _subjects.doc(subjectId).get();
    return SubjectModel.fromFirestore(doc);
  }
}
