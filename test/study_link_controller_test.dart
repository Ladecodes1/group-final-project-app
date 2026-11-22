import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/app/state/study_link_controller.dart';

void main() {
  test('booking creates an upcoming session with the selected tutor', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);

    final result = await controller.confirmBooking();

    final state = container.read(studyLinkProvider);
    expect(result, isTrue);
    expect(state.sessions.first.isUpcoming, isTrue);
    expect(state.sessions.first.tutorName, 'Kevin Habimana');
    expect(state.sessions.first.id, isNotEmpty);
  });

  test('unavailable time preserves tutor and booking choices', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);
    controller.setSelectedSlotAvailability(false);

    final result = await controller.confirmBooking();
    final state = container.read(studyLinkProvider);

    expect(result, isFalse);
    expect(state.selectedTutor.name, 'Kevin Habimana');
    expect(state.selectedTime, '16:00');
    expect(state.lastBookingFailed, isTrue);
  });

  test('cancelling one session does not cancel other sessions', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);

    await controller.cancelSession('sample-session-kevin');
    final sessions = container.read(studyLinkProvider).sessions;
    final cancelled =
        sessions.firstWhere((session) => session.id == 'sample-session-kevin');
    final completed =
        sessions.firstWhere((session) => session.id == 'sample-session-python');

    expect(cancelled.status, 'cancelled');
    expect(cancelled.isUpcoming, isFalse);
    expect(completed.status, 'completed');
    expect(completed.isRated, isTrue);
  });

  test('rating updates only the session being rated', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);
    controller.setRating(5);

    await controller.submitRating('sample-session-grace');
    final sessions = container.read(studyLinkProvider).sessions;
    final rated =
        sessions.firstWhere((session) => session.id == 'sample-session-grace');
    final other =
        sessions.firstWhere((session) => session.id == 'sample-session-python');

    expect(rated.isRated, isTrue);
    expect(rated.rating, 5);
    expect(other.rating, 5);
    expect(other.isRated, isTrue);
  });

  test('feedback tags can be toggled on and off', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);

    controller.toggleFeedbackTag('Patient');
    expect(container.read(studyLinkProvider).feedbackTags, contains('Patient'));
    controller.toggleFeedbackTag('Patient');
    expect(container.read(studyLinkProvider).feedbackTags,
        isNot(contains('Patient')));
  });
}
