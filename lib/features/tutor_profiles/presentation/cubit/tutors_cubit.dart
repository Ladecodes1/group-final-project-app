import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/tutor_profile.dart';
import '../../domain/repositories/tutor_profile_repository.dart';
import 'tutors_state.dart';

class TutorsCubit extends Cubit<TutorsState> {
  TutorsCubit(this._repository) : super(const TutorsState());

  final TutorProfileRepository _repository;
  StreamSubscription<List<TutorProfile>>? _subscription;

  void watchTutorsBySubject(String subjectId) {
    _subscription?.cancel();

    emit(const TutorsState(status: TutorsStatus.loading));

    _subscription = _repository.watchTutorsBySubject(subjectId).listen(
      (tutors) {
        emit(TutorsState(
          status: TutorsStatus.loaded,
          tutors: tutors,
        ));
      },
      onError: (Object error) {
        emit(TutorsState(
          status: TutorsStatus.error,
          errorMessage: error is AppException
              ? error.message
              : 'Unable to load tutors. Please try again.',
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
