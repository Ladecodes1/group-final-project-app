import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/study_link_models.dart';

class StudyLinkState {
  const StudyLinkState({
    this.userName = 'Aline',
    this.searchQuery = 'Data',
    this.selectedSubject = 'Data Structures & Algorithms',
    this.selectedTutor = sampleKevin,
    this.selectedDay = 'Thu 24',
    this.selectedTime = '16:00',
    this.meetingMode = 'On campus',
    this.privateNote = '',
    this.sessions = const [
      StudySession(
        subject: 'Data Structures & Algorithms', tutorName: 'Kevin Habimana', initials: 'KH',
        day: 'THU', date: '24', time: '16:00', location: 'Library, study pod 2',
        mode: 'Campus', isUpcoming: true,
      ),
      StudySession(
        subject: 'Statistics', tutorName: 'Grace Uwase', initials: 'GU',
        day: 'MON', date: '21', time: '18:00', location: 'Online',
        mode: 'Online', isUpcoming: false,
      ),
      StudySession(
        subject: 'Intro to Python', tutorName: 'Kevin Habimana', initials: 'KH',
        day: 'WED', date: '16', time: '15:00', location: 'Campus',
        mode: 'Campus', isUpcoming: false, isRated: true, rating: 5,
      ),
    ],
    this.rating = 4,
    this.unstuckAnswer = 'Yes',
    this.feedbackTags = const {'Clear explanations'},
    this.extraFeedback = '',
    this.cancelReason = 'The time no longer works',
    this.lastBookingFailed = false,
    this.selectedSlotAvailable = true,
  });

  final String userName;
  final String searchQuery;
  final String selectedSubject;
  final Tutor selectedTutor;
  final String selectedDay;
  final String selectedTime;
  final String meetingMode;
  final String privateNote;
  final List<StudySession> sessions;
  final int rating;
  final String unstuckAnswer;
  final Set<String> feedbackTags;
  final String extraFeedback;
  final String cancelReason;
  final bool lastBookingFailed;
  final bool selectedSlotAvailable;

  StudyLinkState copyWith({
    String? userName,
    String? searchQuery,
    String? selectedSubject,
    Tutor? selectedTutor,
    String? selectedDay,
    String? selectedTime,
    String? meetingMode,
    String? privateNote,
    List<StudySession>? sessions,
    int? rating,
    String? unstuckAnswer,
    Set<String>? feedbackTags,
    String? extraFeedback,
    String? cancelReason,
    bool? lastBookingFailed,
    bool? selectedSlotAvailable,
  }) => StudyLinkState(
    userName: userName ?? this.userName,
    searchQuery: searchQuery ?? this.searchQuery,
    selectedSubject: selectedSubject ?? this.selectedSubject,
    selectedTutor: selectedTutor ?? this.selectedTutor,
    selectedDay: selectedDay ?? this.selectedDay,
    selectedTime: selectedTime ?? this.selectedTime,
    meetingMode: meetingMode ?? this.meetingMode,
    privateNote: privateNote ?? this.privateNote,
    sessions: sessions ?? this.sessions,
    rating: rating ?? this.rating,
    unstuckAnswer: unstuckAnswer ?? this.unstuckAnswer,
    feedbackTags: feedbackTags ?? this.feedbackTags,
    extraFeedback: extraFeedback ?? this.extraFeedback,
    cancelReason: cancelReason ?? this.cancelReason,
    lastBookingFailed: lastBookingFailed ?? this.lastBookingFailed,
    selectedSlotAvailable: selectedSlotAvailable ?? this.selectedSlotAvailable,
  );
}

class StudyLinkController extends Notifier<StudyLinkState> {
  @override
  StudyLinkState build() => const StudyLinkState();

  void setSearchQuery(String value) => state = state.copyWith(searchQuery: value);
  void selectSubject(String value) => state = state.copyWith(selectedSubject: value, searchQuery: value);
  void selectTutor(Tutor tutor) => state = state.copyWith(selectedTutor: tutor);
  void selectDay(String value) => state = state.copyWith(selectedDay: value);
  void selectTime(String value) => state = state.copyWith(selectedTime: value);
  void selectMeetingMode(String value) => state = state.copyWith(meetingMode: value);
  void setPrivateNote(String value) => state = state.copyWith(privateNote: value);
  void setRating(int value) => state = state.copyWith(rating: value.clamp(1, 5).toInt());
  void setUnstuckAnswer(String value) => state = state.copyWith(unstuckAnswer: value);
  void setExtraFeedback(String value) => state = state.copyWith(extraFeedback: value);
  void setCancelReason(String value) => state = state.copyWith(cancelReason: value);
  void setSelectedSlotAvailability(bool value) => state = state.copyWith(selectedSlotAvailable: value);

  void toggleFeedbackTag(String value) {
    final tags = {...state.feedbackTags};
    if (!tags.add(value)) tags.remove(value);
    state = state.copyWith(feedbackTags: tags);
  }

  /// Local presentation state for the UI demo. Replace with the team's booking
  /// repository call when Member 2 wires Firestore CRUD into this flow.
  Future<bool> confirmBooking() async {
    state = state.copyWith(lastBookingFailed: false);
    if (!state.selectedSlotAvailable) {
      state = state.copyWith(lastBookingFailed: true);
      return false;
    }
    final newSession = StudySession(
      subject: state.selectedSubject,
      tutorName: state.selectedTutor.name,
      initials: state.selectedTutor.initials,
      day: state.selectedDay.split(' ').first.toUpperCase(),
      date: state.selectedDay.split(' ').last,
      time: state.selectedTime,
      location: state.meetingMode == 'Online' ? 'Online' : 'Library, study pod 2',
      mode: state.meetingMode == 'Online' ? 'Online' : 'Campus',
      isUpcoming: true,
    );
    final updated = [newSession, ...state.sessions.where((s) => !s.isUpcoming)];
    state = state.copyWith(sessions: updated);
    return true;
  }

  void cancelUpcomingSession() {
    final updated = state.sessions.map((s) => s.isUpcoming ? s.copyWith(isUpcoming: false) : s).toList();
    state = state.copyWith(sessions: updated);
  }

  void submitRating() {
    final updated = state.sessions.map((s) {
      if (s.subject == 'Statistics' && s.tutorName == 'Grace Uwase') {
        return s.copyWith(isRated: true, rating: state.rating);
      }
      return s;
    }).toList();
    state = state.copyWith(sessions: updated);
  }
}

final studyLinkProvider = NotifierProvider<StudyLinkController, StudyLinkState>(
  StudyLinkController.new,
);
