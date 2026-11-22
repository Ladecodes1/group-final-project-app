import '../entities/subject.dart';

/// Subjects are added by the team in the Firebase console, so the app
/// only reads them.
abstract class SubjectRepository {
  /// READ: live list of all subjects, sorted by name.
  Stream<List<Subject>> watchSubjects();

  /// READ: one subject by id.
  Future<Subject> getSubject(String subjectId);
}
