import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/repositories/availability_repository.dart';
import 'slots_state.dart';

class SlotsCubit extends Cubit<SlotsState> {
  SlotsCubit(this._repository) : super(const SlotsState());

  final AvailabilityRepository _repository;
  StreamSubscription<List<AvailabilitySlot>>? _subscription;

  void watchTutorSlots(String tutorId) {
    _watch(_repository.watchTutorSlots(tutorId));
  }

  void watchOpenSlots(String tutorId) {
    _watch(_repository.watchOpenSlots(tutorId));
  }

  void _watch(Stream<List<AvailabilitySlot>> stream) {
    _subscription?.cancel();

    emit(const SlotsState(status: SlotsStatus.loading));

    _subscription = stream.listen(
      (slots) {
        emit(SlotsState(status: SlotsStatus.loaded, slots: slots));
      },
      onError: (Object error) {
        emit(
          SlotsState(
            status: SlotsStatus.error,
            errorMessage: error is AppException
                ? error.message
                : 'Unable to load availability slots. Please try again.',
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
