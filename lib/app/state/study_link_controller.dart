import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/study_link_models.dart';

/// Immutable presentation state for the StudyLink UI flow.
///
/// The initial records are demo fixtures, not persisted users or bookings.
/// Inject the team's Firestore repositories when feature/database-crud lands.
class StudyLinkState {
  const StudyLinkState({
    this.searchQuery = 'Data',
    this.selectedSubject = 'Data Structures & Algorithms',
    this.selectedTutor = sampleKevin,
    this.selectedDay = 'Thu 24',
    this.selectedTime = '16:00',
    this.meetingMode = 'On campus',
    this.privateNote = '',
    this.tutorFilter = 'Free this week',
    this.sessions = const [
      StudySession(
        id: 'demo-session-kevin',
        subject: 'Data Structures & Algorithms',
        tutorName: 'Kevin Habimana',
        initials: 'KH',
        day: 'THU',
        date: '24',
        time: '16:00',
        location: 'Library, study pod 2',
        mode: 'Campus',
        tutorId: 'demo-kevin',
        isUpcoming: true,
        privateNote: 'I do not understand recursion in merge sort.',
      ),
      StudySession(
        id: 'demo-session-grace',
        subject: 'Statistics',
        tutorName: 'Grace Uwase',
        initials: 'GU',
        day: 'MON',
        date: '21',
        time: '18:00',
        location: 'Online',
        mode: 'Online',
        tutorId: 'demo-grace',
      ),
      StudySession(
        id: 'demo-session-python',
        subject: 'Intro to Python',
        tutorName: 'Kevin Habimana',
        initials: 'KH',
        day: 'WED',
        date: '16',
        time: '15:00',
        location: 'Campus',
        mode: 'Campus',
        tutorId: 'demo-kevin',
        isRated: true,
        rating: 5,
      ),
    ],
    rating = 4,
    unstuckAnswer = 'Yes',
    feedbackTags = const {'Clear explanations'},
    extraFeedback = '',
    cancelReason = 'The time no longer works',
    lastBookingFailed = false,
    selectedSlotAvailable = true,
  });

  final String searchQuery;
  final String selectedSubject;
  final Tutor selectedTutor;
  final String selectedDay;
  final String selectedTime;
  final String meetingMode;
  final String privateNote;
  final String tutorFilter;
  final List<StudySession> sessions;
  final int rating;
  final String unstuckAnswer;
  final Set<String> feedbackTags;
  final String extraFeedback;
  final String cancelReason;
  final bool lastBookingFailed;
  final bool selectedSlotAvailable;

  StudyLinkState copyWith({
    String? searchQuery,
    String? selectedSubject,
    Tutor? selectedTutor,
    String? selectedDay,
    String? selectedTime,
    String? meetingMode,
    String? privateNote,
    String? tutorFilter,
    List<StudySession>? sessions,
    int? rating,
    String? unstuckAnswer,
    Set<String>? feedbackTags,
    String? extraFeedback,
    String? cancelReason,
    bool? lastBookingFailed,
    bool? selectedSlotAvailable,
  }) => StudyLinkState(
        searchQuery: searchQuery ?? this.searchQuery,
        selectedSubject: selectedSubject ?? this.selectedSubject,
        selectedTutor: selectedTutor ?? this.selectedTutor,
        selectedDay: selectedDay ?? this.selectedDay,
        selectedTime: selectedTime ?? this.selectedTime,
        meetingMode: meetingMode ?? this.meetingMode,
        privateNote: privateNote ?? this.privateNote,
        tutorFilter: tutorFilter ?? this.tutorFilter,
        sessions: sessions ?? this.sessions,
        rating: rating ?? this.rating,
        unstuckAnswer: unstuckAnswer ?? this.unstuckAnswer,
        feedbackTags: feedbackTags ?? this.feedbackTags,
        extraFeedback: extraFeedback ?? this.extraFeedback,
        cancelReason: cancelReason ?? this.cancelReason,
        lastBookingFailed: lastBookingFailed ?? this.lastBookingFailed,
        selectedSlotAvailable:
            selectedSlotAvailable ?? this.selectedSlotAvailable,
      );
}

class StudyLinkCubit extends Cubit<StudyLinkState> {
  StudyLinkCubit() : super(const StudyLinkState());

  void setSearchQuery(String value) =>
      emit(state.copyWith(searchQuery: value));

  void selectSubject(String value) => emit(
        state.copyWith(selectedSubject: value, searchQuery: value),
      );

  void selectTutor(Tutor tutor) =>
      emit(state.copyWith(selectedTutor: tutor));

  void selectDay(String value) => emit(state.copyWith(selectedDay: value));
  void selectTime(String value) => emit(state.copyWith(selectedTime: value));
  void selectMeetingMode(String value) =>
      emit(state.copyWith(meetingMode: value));
  void setPrivateNote(String value) =>
      emit(state.copyWith(privateNote: value));
  void setTutorFilter(String value) =>
      emit(state.copyWith(tutorFilter: value));
  void setRating(int value) =>
      emit(state.copyWith(rating: value.clamp(1, 5).toInt()));

  void prepareRating(StudySession session) {
    emit(
      state.copyWith(
        rating: session.rating > 0 ? session.rating : 4,
        unstuckAnswer: 'Yes',
        feedbackTags: const {'Clear explanations'},
        extraFeedback: '',
      ),
    );
  }
  void setUnstuckAnswer(String value) =>
      emit(state.copyWith(unstuckAnswer: value));
  void setExtraFeedback(String value) =>
      emit(state.copyWith(extraFeedback: value));
  void setCancelReason(String value) =>
      emit(state.copyWith(cancelReason: value));
  void setSelectedSlotAvailability(bool value) =>
      emit(state.copyWith(selectedSlotAvailable: value));

  void toggleFeedbackTag(String value) {
    final tags = {...state.feedbackTags};
    if (!tags.add(value)) tags.remove(value);
    emit(state.copyWith(feedbackTags: tags));
  }

  /// Demo-only booking. Replace this method with the Firestore booking
  /// repository call when the team's CRUD branch is integrated.
  Future<bool> confirmBooking() async {
    emit(state.copyWith(lastBookingFailed: false));
    if (!state.selectedSlotAvailable) {
      emit(state.copyWith(lastBookingFailed: true));
      return false;
    }
    final parts = state.selectedDay.split(' ');
    final session = StudySession(
      id: 'demo-booking-${DateTime.now().microsecondsSinceEpoch}',
      subject: state.selectedSubject,
      tutorName: state.selectedTutor.name,
      initials: state.selectedTutor.initials,
      tutorId: state.selectedTutor.id,
      day: parts.first.toUpperCase(),
      date: parts.length > 1 ? parts.last : '',
      time: state.selectedTime,
      location: state.meetingMode == 'Online'
          ? 'Online'
          : 'Library, study pod 2',
      mode: state.meetingMode == 'Online' ? 'Online' : 'Campus',
      isUpcoming: true,
      privateNote: state.privateNote,
    );
    emit(state.copyWith(sessions: [session, ...state.sessions]));
    return true;
  }

  /// Updates only the session the learner selected, never every upcoming item.
  void cancelSession(String sessionId) {
    final updated = state.sessions
        .map((session) => session.id == sessionId
            ? session.copyWith(isUpcoming: false)
            : session)
        .toList();
    emit(state.copyWith(sessions: updated));
  }

  /// The selected session ID is explicit so the wrong tutor/session is never
  /// rated by accident (the issue raised in PR #4).
  void submitRating(String sessionId) {
    final updated = state.sessions
        .map((session) => session.id == sessionId
            ? session.copyWith(isRated: true, rating: state.rating)
            : session)
        .toList();
    emit(state.copyWith(sessions: updated));
  }
}
