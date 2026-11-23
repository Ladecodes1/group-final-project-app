import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studylink/app/state/study_link_backend.dart';
import 'package:studylink/core/error/app_exception.dart';
import 'package:studylink/core/models/study_link_models.dart';
import 'package:studylink/features/availability/domain/entities/availability_slot.dart';
import 'package:studylink/features/subjects/domain/entities/subject.dart';

const dsa = Subject(
  id: 'dsa',
  name: 'Data Structures & Algorithms',
  courseCode: 'SE 201',
);
const stats = Subject(id: 'stats', name: 'Statistics', courseCode: 'MA 110');

const grace = Tutor(
  id: 'tutor-grace',
  name: 'Grace Uwase',
  initials: 'GU',
  year: 'Year 3',
  programme: 'Peer tutor',
  rating: 0,
  sessions: 0,
  nextSlot: 'Check open times',
  subjects: ['Data Structures & Algorithms'],
  about: 'I passed DSA last year.',
  avatarColor: Color(0xFFF1DDB3),
  isNew: true,
);

/// Thursday 24 Dec 2099, so the slots are always in the future.
final slotA = AvailabilitySlot(
  id: 'slot-a',
  tutorId: grace.id,
  subjectId: dsa.id,
  date: DateTime(2099, 12, 24),
  startTime: DateTime(2099, 12, 24, 10),
  endTime: DateTime(2099, 12, 24, 10, 45),
  isBooked: false,
);
final slotB = AvailabilitySlot(
  id: 'slot-b',
  tutorId: grace.id,
  subjectId: dsa.id,
  date: DateTime(2099, 12, 24),
  startTime: DateTime(2099, 12, 24, 16),
  endTime: DateTime(2099, 12, 24, 16, 45),
  isBooked: false,
);
final slotC = AvailabilitySlot(
  id: 'slot-c',
  tutorId: grace.id,
  subjectId: dsa.id,
  date: DateTime(2099, 12, 25),
  startTime: DateTime(2099, 12, 25, 14),
  endTime: DateTime(2099, 12, 25, 14, 45),
  isBooked: false,
);

/// An in-memory [StudyLinkBackend] that behaves like the Firestore one:
/// booking a slot marks it as booked, cancelling frees it, and only
/// cancelled bookings can be removed.
class FakeStudyLinkBackend implements StudyLinkBackend {
  FakeStudyLinkBackend({
    List<Subject>? subjects,
    Map<String, List<Tutor>>? tutorsBySubject,
    List<AvailabilitySlot>? slots,
    List<StudySession>? sessions,
  }) : subjects = subjects ?? [dsa, stats],
       tutorsBySubject =
           tutorsBySubject ??
           {
             dsa.id: [grace],
           },
       slots = slots ?? [slotA, slotB, slotC],
       sessions = sessions ?? [];

  final List<Subject> subjects;
  final Map<String, List<Tutor>> tutorsBySubject;
  final List<AvailabilitySlot> slots;
  final List<StudySession> sessions;

  final savedProfiles = <String>[];
  final ratings = <String, (int, String)>{};

  /// When set, the next booking fails with this message (slot just taken).
  String? failNextBookingWith;

  final _sessionsChanged = StreamController<void>.broadcast();
  final _slotsChanged = StreamController<void>.broadcast();

  Future<void> dispose() async {
    await _sessionsChanged.close();
    await _slotsChanged.close();
  }

  Stream<T> _live<T>(StreamController<void> changes, T Function() read) async* {
    yield read();
    yield* changes.stream.map((_) => read());
  }

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async => savedProfiles.add('$uid|$displayName');

  @override
  Stream<List<Subject>> watchSubjects() => Stream.value(subjects);

  @override
  Stream<List<Tutor>> watchTutors(String subjectId) =>
      Stream.value(tutorsBySubject[subjectId] ?? const []);

  @override
  Stream<List<AvailabilitySlot>> watchOpenSlots(String tutorId) => _live(
    _slotsChanged,
    () => slots.where((s) => s.tutorId == tutorId && !s.isBooked).toList(),
  );

  @override
  Stream<List<StudySession>> watchSessions(String studentId) =>
      _live(_sessionsChanged, () => List.of(sessions));

  @override
  Future<void> book({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  }) async {
    final message = failNextBookingWith;
    if (message != null) {
      failNextBookingWith = null;
      throw AppException(message);
    }
    final index = slots.indexWhere((s) => s.id == slotId);
    final slot = slots[index];
    if (slot.isBooked) {
      throw const AppException(
        'That time was just taken. Please pick another slot.',
      );
    }
    slots[index] = _withBooked(slot, true);
    final tutor = tutorsBySubject.values
        .expand((t) => t)
        .firstWhere((t) => t.id == tutorId);
    sessions.insert(
      0,
      StudySession(
        id: 'booking-$slotId',
        subject: subjects.firstWhere((s) => s.id == subjectId).name,
        tutorName: tutor.name,
        initials: tutor.initials,
        tutorId: tutorId,
        day: 'THU',
        date: '${slot.startTime.day}',
        time: '10:00',
        location: 'Arranged with your tutor',
        mode: 'Campus',
        isUpcoming: true,
        privateNote: topicNote,
      ),
    );
    _slotsChanged.add(null);
    _sessionsChanged.add(null);
  }

  @override
  Future<void> cancel(String bookingId) async {
    final i = sessions.indexWhere((s) => s.id == bookingId);
    sessions[i] = sessions[i].copyWith(isUpcoming: false, isCancelled: true);
    final slotId = bookingId.replaceFirst('booking-', '');
    final j = slots.indexWhere((s) => s.id == slotId);
    if (j >= 0) slots[j] = _withBooked(slots[j], false);
    _slotsChanged.add(null);
    _sessionsChanged.add(null);
  }

  @override
  Future<void> remove(String bookingId) async {
    final session = sessions.firstWhere((s) => s.id == bookingId);
    if (!session.isCancelled) {
      throw const AppException('Only cancelled bookings can be deleted.');
    }
    sessions.remove(session);
    _sessionsChanged.add(null);
  }

  @override
  Future<void> rate({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  }) async {
    ratings[bookingId] = (rating, comment);
    final i = sessions.indexWhere((s) => s.id == bookingId);
    sessions[i] = sessions[i].copyWith(isRated: true, rating: rating);
    _sessionsChanged.add(null);
  }

  static AvailabilitySlot _withBooked(AvailabilitySlot s, bool booked) =>
      AvailabilitySlot(
        id: s.id,
        tutorId: s.tutorId,
        subjectId: s.subjectId,
        date: s.date,
        startTime: s.startTime,
        endTime: s.endTime,
        isBooked: booked,
      );
}

/// A past session with Grace that can be rated.
const pastSession = StudySession(
  id: 'booking-past',
  subject: 'Statistics',
  tutorName: 'Grace Uwase',
  initials: 'GU',
  tutorId: 'tutor-grace',
  day: 'MON',
  date: '21',
  time: '18:00',
  location: 'Online',
  mode: 'Online',
);
