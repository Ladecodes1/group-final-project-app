import '../../core/models/study_link_models.dart';
import '../../core/theme/app_colors.dart';
import '../../features/availability/domain/entities/availability_slot.dart';
import '../../features/availability/domain/repositories/availability_repository.dart';
import '../../features/booking/domain/entities/booking.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../../features/subjects/domain/entities/subject.dart';
import '../../features/subjects/domain/repositories/subject_repository.dart';
import '../../features/tutor_profiles/domain/entities/tutor_profile.dart';
import '../../features/tutor_profiles/domain/repositories/tutor_profile_repository.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import 'study_link_backend.dart';

/// [StudyLinkBackend] built on the team's Firestore repositories.
///
/// It joins documents that the screens show together: a tutor's name comes
/// from `users`, a booking's time from `availabilitySlots`, and subject names
/// from `subjects`.
class FirestoreStudyLinkBackend implements StudyLinkBackend {
  FirestoreStudyLinkBackend({
    required this._users,
    required this._subjects,
    required this._tutors,
    required this._slots,
    required this._bookings,
    required this._reviews,
  });

  final UserRepository _users;
  final SubjectRepository _subjects;
  final TutorProfileRepository _tutors;
  final AvailabilityRepository _slots;
  final BookingRepository _bookings;
  final ReviewRepository _reviews;

  /// Names already looked up, so each document is read only once.
  final Map<String, String> _nameCache = {};
  final Map<String, String> _subjectCache = {};

  static const _avatarColors = [
    AppColors.beigeAvatar,
    AppColors.lavenderAvatar,
    AppColors.mintDark,
    AppColors.mutedAvatar,
  ];

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) => _users.createUserIfAbsent(
    uid: uid,
    displayName: displayName,
    email: email,
  );

  @override
  Stream<List<Subject>> watchSubjects() =>
      _subjects.watchSubjects().map((list) {
        for (final subject in list) {
          _subjectCache[subject.id] = subject.name;
        }
        return list;
      });

  @override
  Stream<List<Tutor>> watchTutors(String subjectId) => _tutors
      .watchTutorsBySubject(subjectId)
      .asyncMap((profiles) => Future.wait(profiles.map(_toTutor)));

  @override
  Stream<List<AvailabilitySlot>> watchOpenSlots(String tutorId) =>
      _slots.watchOpenSlots(tutorId);

  @override
  Stream<List<StudySession>> watchSessions(String studentId) => _bookings
      .watchStudentBookings(studentId)
      .asyncMap((bookings) => Future.wait(bookings.map(_toSession)));

  @override
  Future<void> book({
    required String studentId,
    required String tutorId,
    required String slotId,
    required String subjectId,
    required String topicNote,
  }) => _bookings.createBooking(
    studentId: studentId,
    tutorId: tutorId,
    slotId: slotId,
    subjectId: subjectId,
    topicNote: topicNote,
  );

  @override
  Future<void> cancel(String bookingId) => _bookings.cancelBooking(bookingId);

  @override
  Future<void> remove(String bookingId) => _bookings.deleteBooking(bookingId);

  @override
  Future<void> rate({
    required String bookingId,
    required String studentId,
    required int rating,
    required String comment,
  }) async {
    // A review can only be added to a completed booking, so a session that
    // has taken place is marked completed first.
    final booking = await _bookings.getBooking(bookingId);
    if (booking.status == BookingStatus.confirmed) {
      await _bookings.completeBooking(bookingId);
    }
    await _reviews.createReview(
      bookingId: bookingId,
      studentId: studentId,
      rating: rating,
      comment: comment,
    );
  }

  // ---------- turning documents into what the screens show ----------

  Future<String> _nameOf(String uid) async {
    final cached = _nameCache[uid];
    if (cached != null) return cached;
    try {
      final name = (await _users.getUser(uid)).displayName;
      return _nameCache[uid] = name.isEmpty ? 'Peer tutor' : name;
    } catch (_) {
      return 'Peer tutor';
    }
  }

  Future<String> _subjectName(String subjectId) async {
    final cached = _subjectCache[subjectId];
    if (cached != null) return cached;
    try {
      return _subjectCache[subjectId] = (await _subjects.getSubject(subjectId))
          .name;
    } catch (_) {
      return 'Study session';
    }
  }

  Future<Tutor> _toTutor(TutorProfile profile) async {
    final name = await _nameOf(profile.uid);
    final subjectNames = await Future.wait(
      profile.subjectIds.map(_subjectName),
    );
    return Tutor(
      id: profile.uid,
      name: name,
      initials: initialsOf(name),
      year: 'Year ${profile.yearOfStudy}',
      programme: 'Peer tutor',
      rating: 0,
      sessions: 0,
      nextSlot: 'Check open times',
      subjects: subjectNames,
      about: profile.bio.isEmpty ? 'No bio yet.' : profile.bio,
      avatarColor:
          _avatarColors[profile.uid.hashCode.abs() % _avatarColors.length],
      isNew: true,
      testimonial: 'No reviews yet.',
    );
  }

  Future<StudySession> _toSession(Booking booking) async {
    final tutorName = await _nameOf(booking.tutorId);
    final subject = await _subjectName(booking.subjectId);
    AvailabilitySlot? slot;
    try {
      slot = await _slots.getSlot(booking.slotId);
    } catch (_) {
      slot = null; // The slot was removed; show the booking date instead.
    }
    final start = slot?.startTime ?? booking.createdAt;
    final end = slot?.endTime ?? start.add(const Duration(minutes: 45));
    final review = booking.status == BookingStatus.completed
        ? await _reviews.getReviewForBooking(booking.id).catchError((_) => null)
        : null;
    final hasEnded = end.isBefore(DateTime.now());
    return StudySession(
      id: booking.id,
      subject: subject,
      tutorName: tutorName,
      initials: initialsOf(tutorName),
      tutorId: booking.tutorId,
      day: _weekday(start).toUpperCase(),
      date: '${start.day}',
      time: _hhmm(start),
      location: 'Arranged with your tutor',
      mode: 'Campus',
      isUpcoming: booking.status == BookingStatus.confirmed && !hasEnded,
      isCancelled: booking.isCancelled,
      isRated: review != null,
      rating: review?.rating ?? 0,
      privateNote: booking.topicNote,
    );
  }
}

/// "Grace Uwase" -> "GU".
String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

String _weekday(DateTime d) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Labels used by the Time Slots screen, e.g. "Thu 24" and "16:00".
String slotDayLabel(DateTime d) => '${_weekday(d)} ${d.day}';
String slotTimeLabel(DateTime d) => _hhmm(d);

/// Month shown above the day chips, e.g. "November 2026".
String monthLabel(DateTime d) =>
    '${const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][d.month - 1]} ${d.year}';
