import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/study_link_models.dart';
import '../data/study_link_repository.dart';
import '../../features/auth/data/auth_repository.dart';

class StudyLinkState {
  const StudyLinkState({
    this.userName = 'Aline',
    this.userId = '',
    this.searchQuery = 'Data',
    this.selectedSubject = 'Data Structures & Algorithms',
    this.selectedSubjectId = 'sample-dsa',
    this.selectedTutor = sampleKevin,
    this.selectedDay = 'Thu 24',
    this.selectedDate,
    this.selectedTime = '16:00',
    this.selectedSlotId = 'sample-slot-kevin',
    this.meetingMode = 'On campus',
    this.privateNote = '',
    this.sessions = StudyLinkRepository.sampleSessions,
    this.selectedSessionId = 'sample-session-kevin',
    this.subjects = sampleSubjectRecords,
    this.tutors = sampleTutors,
    this.availableSlots = const [],
    this.rating = 4,
    this.unstuckAnswer = 'Yes',
    this.feedbackTags = const {'Clear explanations'},
    this.extraFeedback = '',
    this.cancelReason = 'The time no longer works',
    this.lastBookingFailed = false,
    this.selectedSlotAvailable = true,
    this.isLoadingSubjects = false,
    this.isLoadingTutors = false,
    this.isLoadingSlots = false,
    this.isLoadingSessions = false,
    this.errorMessage,
  });

  final String userName;
  final String userId;
  final String searchQuery;
  final String selectedSubject;
  final String selectedSubjectId;
  final Tutor selectedTutor;
  final String selectedDay;
  final DateTime? selectedDate;
  final String selectedTime;
  final String selectedSlotId;
  final String meetingMode;
  final String privateNote;
  final List<StudySession> sessions;
  final String selectedSessionId;
  final List<StudySubject> subjects;
  final List<Tutor> tutors;
  final List<AvailabilitySlot> availableSlots;
  final int rating;
  final String unstuckAnswer;
  final Set<String> feedbackTags;
  final String extraFeedback;
  final String cancelReason;
  final bool lastBookingFailed;
  final bool selectedSlotAvailable;
  final bool isLoadingSubjects;
  final bool isLoadingTutors;
  final bool isLoadingSlots;
  final bool isLoadingSessions;
  final String? errorMessage;

  StudySession? get selectedSession {
    for (final session in sessions) {
      if (session.id == selectedSessionId) return session;
    }
    return null;
  }

  StudyLinkState copyWith({
    String? userName,
    String? userId,
    String? searchQuery,
    String? selectedSubject,
    String? selectedSubjectId,
    Tutor? selectedTutor,
    String? selectedDay,
    DateTime? selectedDate,
    String? selectedTime,
    String? selectedSlotId,
    String? meetingMode,
    String? privateNote,
    List<StudySession>? sessions,
    String? selectedSessionId,
    List<StudySubject>? subjects,
    List<Tutor>? tutors,
    List<AvailabilitySlot>? availableSlots,
    int? rating,
    String? unstuckAnswer,
    Set<String>? feedbackTags,
    String? extraFeedback,
    String? cancelReason,
    bool? lastBookingFailed,
    bool? selectedSlotAvailable,
    bool? isLoadingSubjects,
    bool? isLoadingTutors,
    bool? isLoadingSlots,
    bool? isLoadingSessions,
    String? errorMessage,
    bool clearError = false,
  }) =>
      StudyLinkState(
        userName: userName ?? this.userName,
        userId: userId ?? this.userId,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedSubject: selectedSubject ?? this.selectedSubject,
        selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
        selectedTutor: selectedTutor ?? this.selectedTutor,
        selectedDay: selectedDay ?? this.selectedDay,
        selectedDate: selectedDate ?? this.selectedDate,
        selectedTime: selectedTime ?? this.selectedTime,
        selectedSlotId: selectedSlotId ?? this.selectedSlotId,
        meetingMode: meetingMode ?? this.meetingMode,
        privateNote: privateNote ?? this.privateNote,
        sessions: sessions ?? this.sessions,
        selectedSessionId: selectedSessionId ?? this.selectedSessionId,
        subjects: subjects ?? this.subjects,
        tutors: tutors ?? this.tutors,
        availableSlots: availableSlots ?? this.availableSlots,
        rating: rating ?? this.rating,
        unstuckAnswer: unstuckAnswer ?? this.unstuckAnswer,
        feedbackTags: feedbackTags ?? this.feedbackTags,
        extraFeedback: extraFeedback ?? this.extraFeedback,
        cancelReason: cancelReason ?? this.cancelReason,
        lastBookingFailed: lastBookingFailed ?? this.lastBookingFailed,
        selectedSlotAvailable:
            selectedSlotAvailable ?? this.selectedSlotAvailable,
        isLoadingSubjects: isLoadingSubjects ?? this.isLoadingSubjects,
        isLoadingTutors: isLoadingTutors ?? this.isLoadingTutors,
        isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
        isLoadingSessions: isLoadingSessions ?? this.isLoadingSessions,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class StudyLinkController extends Notifier<StudyLinkState> {
  StudyLinkRepository get _repository => ref.read(studyLinkRepositoryProvider);

  @override
  StudyLinkState build() =>
      StudyLinkState(selectedDate: DateTime.now().add(const Duration(days: 1)));

  void setCurrentUser(AuthProfile profile) {
    final liveFirebase = _repository.isConfigured;
    state = state.copyWith(
      userName: profile.name,
      userId: profile.uid,
      sessions: liveFirebase ? const [] : state.sessions,
      subjects: liveFirebase ? const [] : state.subjects,
      tutors: liveFirebase ? const [] : state.tutors,
      clearError: true,
    );
  }

  void setSearchQuery(String value) =>
      state = state.copyWith(searchQuery: value);

  void selectSubject(String value, {String? id}) {
    final match = state.subjects.where((subject) => subject.name == value);
    state = state.copyWith(
      selectedSubject: value,
      selectedSubjectId: id ?? (match.isEmpty ? '' : match.first.id),
      searchQuery: value,
      clearError: true,
    );
  }

  Future<void> loadSubjects({String query = ''}) async {
    state = state.copyWith(isLoadingSubjects: true, clearError: true);
    try {
      final subjects = await _repository.searchSubjects(query);
      state = state.copyWith(subjects: subjects, isLoadingSubjects: false);
    } catch (error) {
      state = state.copyWith(
        subjects: const [],
        isLoadingSubjects: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> loadTutors() async {
    state = state.copyWith(isLoadingTutors: true, clearError: true);
    try {
      final tutors = await _repository.getTutorsForSubject(
        subjectId: state.selectedSubjectId,
        subjectName: state.selectedSubject,
      );
      state = state.copyWith(tutors: tutors, isLoadingTutors: false);
    } catch (error) {
      state = state.copyWith(
        tutors: const [],
        isLoadingTutors: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void selectTutor(Tutor tutor) {
    state = state.copyWith(
        selectedTutor: tutor, availableSlots: const [], clearError: true);
  }

  Future<void> loadAvailability(DateTime day) async {
    final previousTime = state.selectedTime;
    final preferredMode = state.meetingMode;
    state = state.copyWith(
      selectedDate: day,
      selectedDay: '${_weekday(day)} ${day.day}',
      isLoadingSlots: true,
      availableSlots: const [],
      selectedSlotId: '',
      clearError: true,
    );
    try {
      final slots = await _repository.getOpenSlots(
          tutorId: state.selectedTutor.id, day: day);
      state = state.copyWith(availableSlots: slots, isLoadingSlots: false);
      if (slots.isNotEmpty) {
        final preferred = slots.where(
          (slot) => slot.time == previousTime && slot.mode == preferredMode,
        );
        final sameMode = slots.where((slot) => slot.mode == preferredMode);
        final slot = preferred.isNotEmpty
            ? preferred.first
            : sameMode.isNotEmpty
                ? sameMode.first
                : slots.first;
        selectTime(slot.time);
      }
    } catch (error) {
      state = state.copyWith(
        availableSlots: const [],
        selectedSlotId: '',
        isLoadingSlots: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void selectDay(String value) {
    final parts = value.split(' ');
    final dayNumber = parts.length > 1 ? int.tryParse(parts.last) : null;
    final now = DateTime.now();
    var day = state.selectedDate ?? now.add(const Duration(days: 1));
    if (dayNumber != null) {
      day = DateTime(day.year, day.month, dayNumber);
      if (!day.isAfter(now)) day = DateTime(day.year, day.month + 1, dayNumber);
    }
    state = state.copyWith(selectedDay: value, selectedDate: day);
  }

  Future<void> selectDate(DateTime value) async {
    state = state.copyWith(
        selectedDate: value, selectedDay: '${_weekday(value)} ${value.day}');
    await loadAvailability(value);
  }

  void selectTime(String value) {
    final matches = state.availableSlots.where((slot) => slot.time == value);
    state = state.copyWith(
      selectedTime: value,
      selectedSlotId: matches.isEmpty ? '' : matches.first.id,
      meetingMode: matches.isEmpty ? state.meetingMode : matches.first.mode,
      selectedSlotAvailable: true,
      clearError: true,
    );
  }

  void selectMeetingMode(String value) {
    final matchingSlots =
        state.availableSlots.where((slot) => slot.mode == value).toList();
    if (matchingSlots.isEmpty) {
      state = state.copyWith(meetingMode: value, selectedSlotId: '');
      return;
    }
    state = state.copyWith(
      meetingMode: value,
      selectedSlotId: matchingSlots.first.id,
      selectedTime: matchingSlots.first.time,
    );
  }

  void setPrivateNote(String value) =>
      state = state.copyWith(privateNote: value);
  void setRating(int value) =>
      state = state.copyWith(rating: value.clamp(1, 5).toInt());
  void setUnstuckAnswer(String value) =>
      state = state.copyWith(unstuckAnswer: value);
  void setExtraFeedback(String value) =>
      state = state.copyWith(extraFeedback: value);
  void setCancelReason(String value) =>
      state = state.copyWith(cancelReason: value);
  void setSelectedSlotAvailability(bool value) =>
      state = state.copyWith(selectedSlotAvailable: value);

  void selectSession(StudySession session) {
    state = state.copyWith(
        selectedSessionId: session.id,
        rating: session.rating == 0 ? 4 : session.rating,
        extraFeedback: '',
        clearError: true);
  }

  void toggleFeedbackTag(String value) {
    final tags = {...state.feedbackTags};
    if (!tags.add(value)) tags.remove(value);
    state = state.copyWith(feedbackTags: tags);
  }

  Future<bool> confirmBooking() async {
    state = state.copyWith(lastBookingFailed: false, clearError: true);
    if (!state.selectedSlotAvailable) {
      state = state.copyWith(lastBookingFailed: true);
      return false;
    }
    final day =
        state.selectedDate ?? DateTime.now().add(const Duration(days: 1));
    final slotMatches = state.availableSlots.where((slot) =>
        slot.id == state.selectedSlotId || slot.time == state.selectedTime);
    final slot = slotMatches.isNotEmpty
        ? slotMatches.first
        : AvailabilitySlot(
            id: state.selectedSlotId.isEmpty
                ? 'local-slot-${day.millisecondsSinceEpoch}'
                : state.selectedSlotId,
            tutorId: state.selectedTutor.id,
            startAt: DateTime(
                day.year,
                day.month,
                day.day,
                int.parse(state.selectedTime.split(':')[0]),
                int.parse(state.selectedTime.split(':')[1])),
            mode: state.meetingMode,
          );
    try {
      final session = await _repository.createBooking(
        tutorId: state.selectedTutor.id,
        tutorName: state.selectedTutor.name,
        tutorInitials: state.selectedTutor.initials,
        subjectId: state.selectedSubjectId,
        subjectName: state.selectedSubject,
        slot: slot,
        note: state.privateNote,
      );
      final updated = [session, ...state.sessions];
      state = state.copyWith(
        sessions: updated,
        selectedSessionId: session.id,
        selectedSlotId: slot.id,
        lastBookingFailed: false,
      );
      return true;
    } on SlotUnavailableException catch (error) {
      state = state.copyWith(
          lastBookingFailed: true, errorMessage: error.toString());
      return false;
    } catch (error) {
      state = state.copyWith(
          lastBookingFailed: true, errorMessage: _friendlyError(error));
      rethrow;
    }
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoadingSessions: true, clearError: true);
    try {
      final sessions = await _repository.getMySessions();
      state = state.copyWith(sessions: sessions, isLoadingSessions: false);
    } catch (error) {
      state = state.copyWith(
        sessions: const [],
        isLoadingSessions: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> loadSessionById(String sessionId) async {
    final existing = state.sessions.where((session) => session.id == sessionId);
    if (existing.isNotEmpty) {
      selectSession(existing.first);
      return;
    }
    final session = await _repository.getSession(sessionId);
    state = state.copyWith(
      sessions: [...state.sessions, session],
      selectedSessionId: sessionId,
      clearError: true,
    );
  }

  Future<void> loadTutorProfile(String tutorId) async {
    final tutor = await _repository.getTutorProfile(tutorId);
    state = state.copyWith(selectedTutor: tutor, clearError: true);
  }

  Future<void> cancelSession(String sessionId) async {
    final selected = state.sessions.where((session) => session.id == sessionId);
    if (selected.isEmpty) throw StateError('This session could not be found.');
    await _repository.cancelSession(
        sessionId: sessionId, reason: state.cancelReason);
    final updated = state.sessions
        .map((session) => session.id == sessionId
            ? session.copyWith(isUpcoming: false, status: 'cancelled')
            : session)
        .toList();
    state = state.copyWith(sessions: updated, clearError: true);
  }

  Future<void> submitRating(String sessionId) async {
    final selected = state.sessions.where((session) => session.id == sessionId);
    if (selected.isEmpty) throw StateError('This session could not be found.');
    final session = selected.first;
    if (session.status != 'completed') {
      throw StateError('You can rate a session after it has been completed.');
    }
    if (session.isRated) {
      throw StateError('This session has already been rated.');
    }
    final tags = [...state.feedbackTags, 'Helped: ${state.unstuckAnswer}'];
    await _repository.submitRating(
      sessionId: sessionId,
      rating: state.rating,
      tags: tags,
      comment: state.extraFeedback.trim(),
    );
    final updated = state.sessions
        .map((item) => item.id == sessionId
            ? item.copyWith(isRated: true, rating: state.rating)
            : item)
        .toList();
    state = state.copyWith(sessions: updated, clearError: true);
  }

  String _friendlyError(Object error) {
    final message = error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
    if (message.contains('permission-denied')) {
      return 'You do not have permission to perform this action.';
    }
    if (message.contains('network')) {
      return 'A network error occurred. Check your connection and try again.';
    }
    return message;
  }

  String _weekday(DateTime value) => const [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][value.weekday - 1];
}

final studyLinkRepositoryProvider =
    Provider<StudyLinkRepository>((ref) => StudyLinkRepository());

final studyLinkProvider = NotifierProvider<StudyLinkController, StudyLinkState>(
  StudyLinkController.new,
);
