import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/app/state/study_link_controller.dart';

void main() {
  test('booking stores selected tutor and creates an upcoming session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);

    final result = await controller.confirmBooking();

    expect(result, isTrue);
    expect(container.read(studyLinkProvider).sessions.first.isUpcoming, isTrue);
    expect(container.read(studyLinkProvider).sessions.first.tutorName, 'Kevin Habimana');
  });

  test('unavailable time preserves the selected tutor and booking choices', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);
    controller.setSelectedSlotAvailability(false);

    final result = await controller.confirmBooking();

    expect(result, isFalse);
    expect(container.read(studyLinkProvider).selectedTutor.name, 'Kevin Habimana');
    expect(container.read(studyLinkProvider).selectedTime, '16:00');
    expect(container.read(studyLinkProvider).lastBookingFailed, isTrue);
  });

  test('feedback tags can be toggled on and off', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyLinkProvider.notifier);

    controller.toggleFeedbackTag('Patient');
    expect(container.read(studyLinkProvider).feedbackTags, contains('Patient'));
    controller.toggleFeedbackTag('Patient');
    expect(container.read(studyLinkProvider).feedbackTags, isNot(contains('Patient')));
  });
}
