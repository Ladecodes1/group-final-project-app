import '../../domain/entities/tutor_profile.dart';

enum TutorsStatus { initial, loading, loaded, error }

class TutorsState {
  const TutorsState({
    this.status = TutorsStatus.initial,
    this.tutors = const [],
    this.errorMessage,
  });

  final TutorsStatus status;
  final List<TutorProfile> tutors;
  final String? errorMessage;
}
