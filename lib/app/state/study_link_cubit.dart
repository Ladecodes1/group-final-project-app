import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/app_exception.dart';
import '../../core/models/study_link_models.dart';
import '../../features/availability/domain/entities/availability_slot.dart';
import '../../features/subjects/domain/entities/subject.dart';
import 'firestore_study_link_backend.dart';
import 'study_link_backend.dart';

/// Shown before the student has picked a tutor.
const noTutorSelected = Tutor(
  id: '',
  name: 'Peer tutor',
  initials: '?',
  year: '',
  programme: '',
  rating: 0,
  sessions: 0,
  nextSlot: '',
  subjects: [],
  about: '',
  avatarColor: Color(0xFFF1DDB3),
);

/// Everything the booking screens show. Subjects, tutors, slots and sessions
/// come from Firestore through [StudyLinkBackend]; the rest is what the
/// student has picked on screen.
@immutable
class StudyLinkState {
  const StudyLinkState({
    this.userId = '',
    this.subjects = const [],
    this.searchQuery = '',
    this.selectedSubject = '',
    this.selectedSubjectId = '',
    this.tutors = const [],
    this.tutorsLoading = false,
    this.selectedTutor = noTutorSelected,
    this.slots = const [],
    this.slotsLoading = false,
    this.selectedDay = '',
    this.selectedTime = '',
    this.meetingMode = 'On campus',
    this.privateNote = '',
    this.tutorFilter = 'Free this week',
    this.sessions = const [],
    this.lastBooked,
    this.rating = 4,
    this.unstuckAnswer = 'Yes',
    this.feedbackTags = const {'Clear explanations'},
    this.extraFeedback = '',
    this.cancelReason = 'The time no longer works',
    this.lastBookingFailed = false,
    this.isSaving = false,
    this.message,
  });

  final String userId;
  final List<Subject> subjects;
  final String searchQuery;
  final String selectedSubject;
  final String selectedSubjectId;
  final List<Tutor> tutors;
  final bool tutorsLoading;
  final Tutor selectedTutor;
  final List<AvailabilitySlot> slots;
  final bool slotsLoading;
  final String selectedDay;
  final String selectedTime;
  final String meetingMode;
  final String privateNote;
  final String tutorFilter;
  final List<StudySession> sessions;

  /// The booking just made, shown on the confirmation screen.
  final StudySession? lastBooked;
  final int rating;
  final String unstuckAnswer;
  final Set<String> feedbackTags;
  final String extraFeedback;
  final String cancelReason;
  final bool lastBookingFailed;

  /// True while a booking, cancellation or rating is being saved.
  final bool isSaving;

  /// A message for the user (an error or a confirmation), shown once in a
  /// snack bar and then cleared.
  final String? message;

  /// Days that have open slots, e.g. ["Thu 24", "Fri 25"], in date order.
  List<String> get days {
    final labels = <String>[];
    for (final slot in slots) {
      final label = slotDayLabel(slot.startTime);
      if (!labels.contains(label)) labels.add(label);
    }
    return labels;
  }

  /// Open times on the selected day, e.g. ["10:00", "16:00"].
  List<String> get timesForSelectedDay => [
    for (final slot in slots)
      if (slotDayLabel(slot.startTime) == selectedDay)
        slotTimeLabel(slot.startTime),
  ];

  /// The slot matching the selected day and time, if any.
  AvailabilitySlot? get selectedSlot {
    for (final slot in slots) {
      if (slotDayLabel(slot.startTime) == selectedDay &&
          slotTimeLabel(slot.startTime) == selectedTime) {
        return slot;
      }
    }
    return null;
  }

  StudyLinkState copyWith({
    String? userId,
    List<Subject>? subjects,
    String? searchQuery,
    String? selectedSubject,
    String? selectedSubjectId,
    List<Tutor>? tutors,
    bool? tutorsLoading,
    Tutor? selectedTutor,
    List<AvailabilitySlot>? slots,
    bool? slotsLoading,
    String? selectedDay,
    String? selectedTime,
    String? meetingMode,
    String? privateNote,
    String? tutorFilter,
    List<StudySession>? sessions,
    StudySession? lastBooked,
    int? rating,
    String? unstuckAnswer,
    Set<String>? feedbackTags,
    String? extraFeedback,
    String? cancelReason,
    bool? lastBookingFailed,
    bool? isSaving,
    String? message,
  }) => StudyLinkState(
    userId: userId ?? this.userId,
    subjects: subjects ?? this.subjects,
    searchQuery: searchQuery ?? this.searchQuery,
    selectedSubject: selectedSubject ?? this.selectedSubject,
    selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
    tutors: tutors ?? this.tutors,
    tutorsLoading: tutorsLoading ?? this.tutorsLoading,
    selectedTutor: selectedTutor ?? this.selectedTutor,
    slots: slots ?? this.slots,
    slotsLoading: slotsLoading ?? this.slotsLoading,
    selectedDay: selectedDay ?? this.selectedDay,
    selectedTime: selectedTime ?? this.selectedTime,
    meetingMode: meetingMode ?? this.meetingMode,
    privateNote: privateNote ?? this.privateNote,
    tutorFilter: tutorFilter ?? this.tutorFilter,
    sessions: sessions ?? this.sessions,
    lastBooked: lastBooked ?? this.lastBooked,
    rating: rating ?? this.rating,
    unstuckAnswer: unstuckAnswer ?? this.unstuckAnswer,
    feedbackTags: feedbackTags ?? this.feedbackTags,
    extraFeedback: extraFeedback ?? this.extraFeedback,
    cancelReason: cancelReason ?? this.cancelReason,
    lastBookingFailed: lastBookingFailed ?? this.lastBookingFailed,
    isSaving: isSaving ?? this.isSaving,
    // A message is shown once, so it is dropped unless passed again.
    message: message,
  );
}

class StudyLinkCubit extends Cubit<StudyLinkState> {
  StudyLinkCubit(this._backend) : super(const StudyLinkState());

  final StudyLinkBackend _backend;
  StreamSubscription<List<Subject>>? _subjectsSub;
  StreamSubscription<List<StudySession>>? _sessionsSub;
  StreamSubscription<List<Tutor>>? _tutorsSub;
  StreamSubscription<List<AvailabilitySlot>>? _slotsSub;

  /// Called when a student signs in: saves their profile and starts
  /// listening to the subjects and their sessions.
  Future<void> start({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    if (state.userId == userId) return;
    await _cancelAll();
    emit(StudyLinkState(userId: userId));
    _subjectsSub = _backend.watchSubjects().listen(
      (subjects) => emit(state.copyWith(subjects: subjects)),
      onError: _showError,
    );
    _sessionsSub = _backend
        .watchSessions(userId)
        .listen(
          (sessions) => emit(state.copyWith(sessions: sessions)),
          onError: _showError,
        );
    try {
      await _backend.saveUserProfile(
        uid: userId,
        email: email,
        displayName: displayName,
      );
    } catch (error) {
      _showError(error);
    }
  }

  /// Called when the student signs out.
  Future<void> stop() async {
    await _cancelAll();
    emit(const StudyLinkState());
  }

  void setSearchQuery(String value) => emit(state.copyWith(searchQuery: value));

  /// Picks a subject by its id or name and starts loading its tutors.
  void selectSubject(String value) {
    final query = value.trim().toLowerCase();
    Subject? match;
    for (final subject in state.subjects) {
      if (subject.id == value || subject.name.toLowerCase() == query) {
        match = subject;
        break;
      }
    }
    match ??= state.subjects
        .where((s) => s.name.toLowerCase().contains(query))
        .firstOrNull;

    _tutorsSub?.cancel();
    emit(
      state.copyWith(
        selectedSubject: match?.name ?? value.trim(),
        selectedSubjectId: match?.id ?? '',
        searchQuery: match?.name ?? value.trim(),
        tutors: const [],
        tutorsLoading: match != null,
      ),
    );
    if (match == null) return;
    _tutorsSub = _backend
        .watchTutors(match.id)
        .listen(
          (tutors) =>
              emit(state.copyWith(tutors: tutors, tutorsLoading: false)),
          onError: (Object error) {
            emit(state.copyWith(tutorsLoading: false));
            _showError(error);
          },
        );
  }

  /// Picks a tutor and starts loading their open time slots.
  void selectTutor(Tutor tutor) {
    _slotsSub?.cancel();
    emit(
      state.copyWith(
        selectedTutor: tutor,
        slots: const [],
        slotsLoading: true,
        selectedDay: '',
        selectedTime: '',
      ),
    );
    _slotsSub = _backend
        .watchOpenSlots(tutor.id)
        .listen(
          (slots) {
            var next = state.copyWith(slots: slots, slotsLoading: false);
            // Keep the student's choice if it is still open, otherwise pick the
            // first open slot.
            if (next.selectedSlot == null && slots.isNotEmpty) {
              next = next.copyWith(
                selectedDay: slotDayLabel(slots.first.startTime),
                selectedTime: slotTimeLabel(slots.first.startTime),
              );
            }
            emit(next);
          },
          onError: (Object error) {
            emit(state.copyWith(slotsLoading: false));
            _showError(error);
          },
        );
  }

  void selectDay(String value) {
    final first = state.copyWith(selectedDay: value).timesForSelectedDay;
    emit(
      state.copyWith(
        selectedDay: value,
        selectedTime: first.isEmpty ? '' : first.first,
      ),
    );
  }

  void selectTime(String value) => emit(state.copyWith(selectedTime: value));
  void selectMeetingMode(String value) =>
      emit(state.copyWith(meetingMode: value));
  void setPrivateNote(String value) => emit(state.copyWith(privateNote: value));
  void setTutorFilter(String value) => emit(state.copyWith(tutorFilter: value));
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

  void toggleFeedbackTag(String value) {
    final tags = {...state.feedbackTags};
    if (!tags.add(value)) tags.remove(value);
    emit(state.copyWith(feedbackTags: tags));
  }

  /// Books the selected slot in Firestore. Returns false (and shows a
  /// message) if no slot is selected or the slot was just taken.
  Future<bool> confirmBooking() async {
    final slot = state.selectedSlot;
    if (slot == null || state.userId.isEmpty) {
      emit(
        state.copyWith(
          lastBookingFailed: true,
          message: 'Please choose an open time first.',
        ),
      );
      return false;
    }
    emit(state.copyWith(isSaving: true, lastBookingFailed: false));
    try {
      await _backend.book(
        studentId: state.userId,
        tutorId: state.selectedTutor.id,
        slotId: slot.id,
        subjectId: state.selectedSubjectId.isEmpty
            ? slot.subjectId
            : state.selectedSubjectId,
        topicNote: state.privateNote,
      );
      final tutor = state.selectedTutor;
      emit(
        state.copyWith(
          isSaving: false,
          lastBooked: StudySession(
            id: slot.id,
            subject: state.selectedSubject,
            tutorName: tutor.name,
            initials: tutor.initials,
            tutorId: tutor.id,
            day: slotDayLabel(slot.startTime).split(' ').first.toUpperCase(),
            date: '${slot.startTime.day}',
            time: slotTimeLabel(slot.startTime),
            location: state.meetingMode == 'Online'
                ? 'Online'
                : 'Arranged with your tutor',
            mode: state.meetingMode == 'Online' ? 'Online' : 'Campus',
            isUpcoming: true,
            privateNote: state.privateNote,
          ),
        ),
      );
      return true;
    } catch (error) {
      emit(state.copyWith(isSaving: false, lastBookingFailed: true));
      _showError(error);
      return false;
    }
  }

  /// Cancels only the chosen booking and frees its slot.
  Future<void> cancelSession(String sessionId) =>
      _save(() => _backend.cancel(sessionId), done: 'Session cancelled.');

  /// Removes a cancelled booking for good.
  Future<void> removeSession(String sessionId) =>
      _save(() => _backend.remove(sessionId), done: 'Session removed.');

  /// Saves a rating for the session that was rated, never another one.
  Future<void> submitRating(String sessionId) {
    final comment = [
      'Got unstuck: ${state.unstuckAnswer}',
      if (state.feedbackTags.isNotEmpty) state.feedbackTags.join(', '),
      if (state.extraFeedback.trim().isNotEmpty) state.extraFeedback.trim(),
    ].join('. ');
    return _save(
      () => _backend.rate(
        bookingId: sessionId,
        studentId: state.userId,
        rating: state.rating,
        comment: comment,
      ),
      done: 'Thanks for rating your session.',
    );
  }

  Future<void> _save(
    Future<void> Function() action, {
    required String done,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      await action();
      emit(state.copyWith(isSaving: false, message: done));
    } catch (error) {
      emit(state.copyWith(isSaving: false));
      _showError(error);
    }
  }

  void _showError(Object error) {
    emit(
      state.copyWith(
        message: error is AppException
            ? error.message
            : 'Something went wrong. Please try again.',
      ),
    );
  }

  Future<void> _cancelAll() async {
    await _subjectsSub?.cancel();
    await _sessionsSub?.cancel();
    await _tutorsSub?.cancel();
    await _slotsSub?.cancel();
    _subjectsSub = null;
    _sessionsSub = null;
    _tutorsSub = null;
    _slotsSub = null;
  }

  @override
  Future<void> close() async {
    await _cancelAll();
    return super.close();
  }
}
