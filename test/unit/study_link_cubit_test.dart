import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/app/state/study_link_cubit.dart';

void main() {
  late StudyLinkCubit cubit;

  setUp(() => cubit = StudyLinkCubit());
  tearDown(() => cubit.close());

  test(
    'booking stores the selected tutor and creates an upcoming session',
    () async {
      final result = await cubit.confirmBooking();

      expect(result, isTrue);
      expect(cubit.state.sessions.first.isUpcoming, isTrue);
      expect(cubit.state.sessions.first.tutorName, 'Kevin Habimana');
    },
  );

  test(
    'an unavailable time keeps the selected tutor and booking choices',
    () async {
      cubit.setSelectedSlotAvailability(false);

      final result = await cubit.confirmBooking();

      expect(result, isFalse);
      expect(cubit.state.selectedTutor.name, 'Kevin Habimana');
      expect(cubit.state.selectedTime, '16:00');
      expect(cubit.state.lastBookingFailed, isTrue);
    },
  );

  test('feedback tags can be toggled on and off', () {
    cubit.toggleFeedbackTag('Patient');
    expect(cubit.state.feedbackTags, contains('Patient'));

    cubit.toggleFeedbackTag('Patient');
    expect(cubit.state.feedbackTags, isNot(contains('Patient')));
  });

  test('cancelling a session changes only that session', () {
    final upcomingBefore = cubit.state.sessions
        .where((s) => s.isUpcoming)
        .length;
    final target = cubit.state.sessions.firstWhere((s) => s.isUpcoming);

    cubit.cancelSession(target.id);

    final cancelled = cubit.state.sessions.firstWhere((s) => s.id == target.id);
    expect(cancelled.isUpcoming, isFalse);
    expect(
      cubit.state.sessions.where((s) => s.isUpcoming).length,
      upcomingBefore - 1,
    );
  });

  test('a rating is saved on the session that was rated, not another one', () {
    final target = cubit.state.sessions.firstWhere(
      (s) => !s.isUpcoming && !s.isRated,
    );
    final others = cubit.state.sessions
        .where((s) => s.id != target.id)
        .toList();

    cubit.setRating(3);
    cubit.submitRating(target.id);

    final rated = cubit.state.sessions.firstWhere((s) => s.id == target.id);
    expect(rated.isRated, isTrue);
    expect(rated.rating, 3);
    for (final other in others) {
      final after = cubit.state.sessions.firstWhere((s) => s.id == other.id);
      expect(after.rating, other.rating);
      expect(after.isRated, other.isRated);
    }
  });

  test('the rating is kept between 1 and 5 stars', () {
    cubit.setRating(9);
    expect(cubit.state.rating, 5);
    cubit.setRating(0);
    expect(cubit.state.rating, 1);
  });

  test('the tutor filter can be changed', () {
    cubit.setTutorFilter('Online');
    expect(cubit.state.tutorFilter, 'Online');
  });
}
