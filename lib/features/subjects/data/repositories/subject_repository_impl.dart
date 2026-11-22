import '../../../../core/error/firebase_error_mapper.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_remote_datasource.dart';

/// Implements [SubjectRepository] with friendly error messages.
class SubjectRepositoryImpl implements SubjectRepository {
  SubjectRepositoryImpl(this._remote);

  final SubjectRemoteDataSource _remote;

  @override
  Stream<List<Subject>> watchSubjects() {
    return _remote.watchSubjects().handleError(rethrowFriendly);
  }

  @override
  Future<Subject> getSubject(String subjectId) {
    return guardFirebase(() => _remote.getSubject(subjectId));
  }
}
