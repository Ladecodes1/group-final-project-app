import 'package:equatable/equatable.dart';

/// The extra information a student shares when they also want to tutor.
/// The id is the same as the user's `uid`.
class TutorProfile extends Equatable {
  const TutorProfile({
    required this.uid,
    required this.bio,
    required this.yearOfStudy,
    required this.subjectIds,
    required this.isActive,
  });

  final String uid;
  final String bio;
  final int yearOfStudy;
  final List<String> subjectIds;
  final bool isActive;

  @override
  List<Object?> get props => [uid, bio, yearOfStudy, subjectIds, isActive];
}
