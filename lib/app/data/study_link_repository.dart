import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/models/study_link_models.dart';

class SlotUnavailableException implements Exception {
  const SlotUnavailableException();
  @override
  String toString() => 'That time is no longer available. Choose another slot.';
}

class StudyLinkRepository {
  bool get isConfigured => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db {
    if (!isConfigured) {
      throw StateError(
          'Firebase is not configured. Add the StudyLink Firebase dart-define values.');
    }
    return FirebaseFirestore.instance;
  }

  User get _currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in again before continuing.');
    }
    return user;
  }

  Future<List<StudySubject>> searchSubjects(String query) async {
    if (!isConfigured) {
      final q = query.trim().toLowerCase();
      return sampleSubjectRecords
          .where((subject) => subject.name.toLowerCase().contains(q))
          .toList();
    }

    final snapshot = await _db
        .collection('subjects')
        .where('isActive', isEqualTo: true)
        .get();
    final q = query.trim().toLowerCase();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return StudySubject(
            id: doc.id,
            name: (data['name'] ?? '').toString(),
            programme: (data['programme'] ?? 'All programmes').toString(),
            description: (data['description'] ?? '').toString(),
            tutorCount: (data['tutorCount'] as num?)?.toInt() ?? 0,
            isActive: data['isActive'] != false,
          );
        })
        .where((subject) =>
            subject.name.isNotEmpty && subject.name.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<Tutor>> getTutorsForSubject({
    required String subjectId,
    required String subjectName,
  }) async {
    if (!isConfigured) {
      final subject = subjectName.toLowerCase();
      return sampleTutors
          .where((tutor) => tutor.subjects.any(
                (name) =>
                    name.toLowerCase().contains(subject) ||
                    subject.contains(name.toLowerCase()),
              ))
          .toList();
    }

    final snapshot = await _db.collection('tutors').get();
    final tutors = <Tutor>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final subjectValues = (data['subjects'] as List<dynamic>? ?? const [])
          .map((value) => value.toString().toLowerCase())
          .toList();
      if (subjectId.isNotEmpty &&
          subjectId != subjectName &&
          !subjectValues.contains(subjectId.toLowerCase()) &&
          !subjectValues.contains(subjectName.toLowerCase())) {
        continue;
      }
      if (subjectId.isEmpty &&
          !subjectValues.contains(subjectName.toLowerCase())) {
        continue;
      }

      final userDoc = await _db.collection('users').doc(doc.id).get();
      final user = userDoc.data() ?? const <String, dynamic>{};
      final subjects = (data['subjects'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList();
      final name = (user['displayName'] ??
              data['name'] ??
              data['displayName'] ??
              'StudyLink tutor')
          .toString();
      final ratingValue = data['ratingAggregate'];
      final rating = ratingValue is Map
          ? ((ratingValue['average'] as num?)?.toDouble() ?? 0)
          : (ratingValue as num?)?.toDouble() ?? 0;
      tutors.add(Tutor(
        id: doc.id,
        name: name,
        initials: _initials(name),
        year: 'Year ${(user['year'] as num?)?.toInt() ?? 1}',
        programme: (user['programme'] ?? 'ALU student').toString(),
        rating: rating,
        sessions: (data['sessionCount'] as num?)?.toInt() ?? 0,
        nextSlot: (data['nextSlot'] ?? 'Check available times').toString(),
        subjects: subjects,
        about: (data['bio'] ?? '').toString(),
        avatarColor: _colorFromHex(data['avatarColor']),
        fullyBooked: data['isAvailable'] == false,
        isNew: (data['sessionCount'] as num?)?.toInt() == 0,
        testimonial:
            (data['testimonial'] ?? 'Be the first student to leave feedback.')
                .toString(),
        modes:
            (data['modes'] as List<dynamic>? ?? const ['On campus', 'Online'])
                .map((value) => value.toString())
                .toList(),
      ));
    }
    return tutors;
  }

  Future<Tutor> getTutorProfile(String tutorId) async {
    if (!isConfigured) {
      return sampleTutors.firstWhere((tutor) => tutor.id == tutorId,
          orElse: () => sampleKevin);
    }
    final tutorDoc = await _db.collection('tutors').doc(tutorId).get();
    if (!tutorDoc.exists) {
      throw StateError('This tutor profile is no longer available.');
    }
    final data = tutorDoc.data() ?? const <String, dynamic>{};
    final userDoc = await _db.collection('users').doc(tutorId).get();
    final user = userDoc.data() ?? const <String, dynamic>{};
    final name =
        (user['displayName'] ?? data['name'] ?? 'StudyLink tutor').toString();
    final ratingValue = data['ratingAggregate'];
    final rating = ratingValue is Map
        ? ((ratingValue['average'] as num?)?.toDouble() ?? 0)
        : (ratingValue as num?)?.toDouble() ?? 0;
    return Tutor(
      id: tutorId,
      name: name,
      initials: _initials(name),
      year: 'Year ${(user['year'] as num?)?.toInt() ?? 1}',
      programme: (user['programme'] ?? 'ALU student').toString(),
      rating: rating,
      sessions: (data['sessionCount'] as num?)?.toInt() ?? 0,
      nextSlot: (data['nextSlot'] ?? 'Check available times').toString(),
      subjects: (data['subjects'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      about: (data['bio'] ?? '').toString(),
      avatarColor: _colorFromHex(data['avatarColor']),
      fullyBooked: data['isAvailable'] == false,
      isNew: (data['sessionCount'] as num?)?.toInt() == 0,
      modes: (data['modes'] as List<dynamic>? ?? const ['On campus', 'Online'])
          .map((value) => value.toString())
          .toList(),
    );
  }

  Future<List<AvailabilitySlot>> getOpenSlots({
    required String tutorId,
    required DateTime day,
  }) async {
    if (!isConfigured) {
      final base = DateTime(day.year, day.month, day.day);
      return ['10:00', '14:00', '16:00', '19:00'].asMap().entries.map((entry) {
        final parts = entry.value.split(':');
        return AvailabilitySlot(
          id: 'sample-${day.year}${day.month}${day.day}-${entry.key}',
          tutorId: tutorId,
          startAt: DateTime(base.year, base.month, base.day,
              int.parse(parts[0]), int.parse(parts[1])),
          mode: entry.key.isEven ? 'On campus' : 'Online',
        );
      }).toList();
    }

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _db
        .collection('tutors')
        .doc(tutorId)
        .collection('availability')
        .where('status', isEqualTo: 'available')
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('startAt')
        .get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          final timestamp = data['startAt'];
          if (timestamp is! Timestamp) return null;
          return AvailabilitySlot(
            id: doc.id,
            tutorId: tutorId,
            startAt: timestamp.toDate(),
            durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 45,
            mode: (data['mode'] ?? 'On campus').toString(),
          );
        })
        .whereType<AvailabilitySlot>()
        .toList();
  }

  Future<StudySession> createBooking({
    required String tutorId,
    required String tutorName,
    required String tutorInitials,
    required String subjectId,
    required String subjectName,
    required AvailabilitySlot slot,
    required String note,
  }) async {
    if (!isConfigured) {
      return _sampleSession(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        tutorId: tutorId,
        tutorName: tutorName,
        tutorInitials: tutorInitials,
        subjectId: subjectId,
        subjectName: subjectName,
        slot: slot,
        note: note,
        studentId: 'local-demo',
      );
    }

    final user = _currentUser;
    final slotRef = _db
        .collection('tutors')
        .doc(tutorId)
        .collection('availability')
        .doc(slot.id);
    final sessionRef = _db.collection('sessions').doc();

    await _db.runTransaction((transaction) async {
      final slotSnapshot = await transaction.get(slotRef);
      final slotData = slotSnapshot.data();
      if (!slotSnapshot.exists ||
          slotData == null ||
          slotData['status'] != 'available') {
        throw const SlotUnavailableException();
      }
      transaction.update(slotRef, {
        'status': 'booked',
        'bookedBy': user.uid,
        'bookedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(sessionRef, {
        'studentId': user.uid,
        'tutorId': tutorId,
        'tutorName': tutorName,
        'tutorInitials': tutorInitials,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'slotId': slot.id,
        'startAt': slotData['startAt'],
        'durationMinutes': (slotData['durationMinutes'] as num?)?.toInt() ??
            slot.durationMinutes,
        'mode': (slotData['mode'] ?? slot.mode).toString(),
        'location': slot.mode == 'Online' ? 'Online' : 'Library, study pod 2',
        'note': note,
        'status': 'confirmed',
        'rating': null,
        'participantIds': [user.uid, tutorId],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return _sampleSession(
      id: sessionRef.id,
      tutorId: tutorId,
      tutorName: tutorName,
      tutorInitials: tutorInitials,
      subjectId: subjectId,
      subjectName: subjectName,
      slot: slot,
      note: note,
      studentId: user.uid,
    );
  }

  Future<List<StudySession>> getMySessions() async {
    if (!isConfigured) return sampleSessions;
    final user = _currentUser;
    final snapshot = await _db
        .collection('sessions')
        .where('studentId', isEqualTo: user.uid)
        .get();
    final sessions = snapshot.docs
        .map((doc) => _sessionFromMap(doc.id, doc.data()))
        .toList();
    sessions.sort((a, b) =>
        (a.startAt ?? DateTime(2100)).compareTo(b.startAt ?? DateTime(2100)));
    return sessions;
  }

  Future<StudySession> getSession(String sessionId) async {
    if (!isConfigured) {
      return sampleSessions.firstWhere((session) => session.id == sessionId);
    }
    final doc = await _db.collection('sessions').doc(sessionId).get();
    if (!doc.exists) throw StateError('This session could not be found.');
    return _sessionFromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  Future<void> cancelSession(
      {required String sessionId, required String reason}) async {
    if (!isConfigured) return;
    final user = _currentUser;
    final sessionRef = _db.collection('sessions').doc(sessionId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw StateError('This session no longer exists.');
      }
      if (data['studentId'] != user.uid) {
        throw StateError('You cannot cancel another student\'s session.');
      }
      if (data['status'] != 'confirmed') {
        throw StateError('Only a confirmed session can be cancelled.');
      }
      final slotId = (data['slotId'] ?? '').toString();
      final tutorId = (data['tutorId'] ?? '').toString();
      final slotRef = _db
          .collection('tutors')
          .doc(tutorId)
          .collection('availability')
          .doc(slotId);
      transaction.update(sessionRef, {
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(slotRef, {
        'status': 'available',
        'bookedBy': FieldValue.delete(),
        'bookedAt': FieldValue.delete(),
      });
    });
  }

  Future<void> submitRating({
    required String sessionId,
    required int rating,
    required List<String> tags,
    required String comment,
  }) async {
    if (!isConfigured) return;
    final user = _currentUser;
    final sessionRef = _db.collection('sessions').doc(sessionId);
    final ratingRef = _db.collection('ratings').doc(sessionId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        throw StateError('This session could not be found.');
      }
      if (data['studentId'] != user.uid) {
        throw StateError('You cannot rate another student\'s session.');
      }
      if (data['status'] != 'completed') {
        throw StateError('You can rate a session after it has been completed.');
      }
      if (data['rating'] != null) {
        throw StateError('You have already rated this session.');
      }
      final tutorId = (data['tutorId'] ?? '').toString();
      transaction.set(ratingRef, {
        'sessionId': sessionId,
        'studentId': user.uid,
        'tutorId': tutorId,
        'score': rating,
        'tags': tags,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(sessionRef, {
        'rating': rating,
        'ratedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  StudySession _sessionFromMap(String id, Map<String, dynamic> data) {
    final rawStart = data['startAt'];
    final startAt = rawStart is Timestamp
        ? rawStart.toDate()
        : rawStart is DateTime
            ? rawStart
            : DateTime.now();
    final status = (data['status'] ?? 'confirmed').toString();
    final mode = (data['mode'] ?? 'On campus').toString();
    final initials = (data['tutorInitials'] ??
            _initials((data['tutorName'] ?? 'Tutor').toString()))
        .toString();
    return StudySession(
      id: id,
      studentId: (data['studentId'] ?? '').toString(),
      tutorId: (data['tutorId'] ?? '').toString(),
      subjectId: (data['subjectId'] ?? '').toString(),
      slotId: (data['slotId'] ?? '').toString(),
      note: (data['note'] ?? '').toString(),
      status: status,
      startAt: startAt,
      subject: (data['subjectName'] ?? 'Study session').toString(),
      tutorName: (data['tutorName'] ?? 'Peer tutor').toString(),
      initials: initials,
      day: _weekday(startAt).toUpperCase(),
      date: startAt.day.toString(),
      time:
          '${startAt.hour.toString().padLeft(2, '0')}:${startAt.minute.toString().padLeft(2, '0')}',
      location: (data['location'] ??
              (mode == 'Online' ? 'Online' : 'Library, study pod 2'))
          .toString(),
      mode: mode,
      isUpcoming: status == 'confirmed' && startAt.isAfter(DateTime.now()),
      isRated: data['rating'] != null,
      rating: (data['rating'] as num?)?.toInt() ?? 0,
    );
  }

  StudySession _sampleSession({
    required String id,
    required String tutorId,
    required String tutorName,
    required String tutorInitials,
    required String subjectId,
    required String subjectName,
    required AvailabilitySlot slot,
    required String note,
    required String studentId,
  }) {
    final start = slot.startAt;
    return StudySession(
      id: id,
      studentId: studentId,
      tutorId: tutorId,
      subjectId: subjectId,
      slotId: slot.id,
      note: note,
      startAt: start,
      subject: subjectName,
      tutorName: tutorName,
      initials: tutorInitials,
      day: _weekday(start).toUpperCase(),
      date: start.day.toString(),
      time: slot.time,
      location: slot.mode == 'Online' ? 'Online' : 'Library, study pod 2',
      mode: slot.mode,
      isUpcoming: true,
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ST';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _weekday(DateTime date) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

  Color _colorFromHex(dynamic value) {
    final raw = value?.toString().replaceFirst('#', '');
    if (raw == null || raw.isEmpty) return const Color(0xFFD5E8E0);
    final normalized = raw.length == 6 ? 'FF$raw' : raw;
    final parsed = int.tryParse(normalized, radix: 16);
    return parsed == null ? const Color(0xFFD5E8E0) : Color(parsed);
  }

  static const sampleSessions = <StudySession>[
    StudySession(
      id: 'sample-session-kevin',
      subject: 'Data Structures & Algorithms',
      tutorName: 'Kevin Habimana',
      initials: 'KH',
      day: 'THU',
      date: '24',
      time: '16:00',
      location: 'Library, study pod 2',
      mode: 'On campus',
      isUpcoming: true,
      tutorId: 'sample-kevin',
      slotId: 'sample-slot-kevin',
      status: 'confirmed',
      note: 'I do not understand recursion in merge sort.',
    ),
    StudySession(
      id: 'sample-session-grace',
      subject: 'Statistics',
      tutorName: 'Grace Uwase',
      initials: 'GU',
      day: 'MON',
      date: '21',
      time: '18:00',
      location: 'Online',
      mode: 'Online',
      isUpcoming: false,
      isRated: false,
      tutorId: 'sample-grace',
      status: 'completed',
    ),
    StudySession(
      id: 'sample-session-python',
      subject: 'Intro to Python',
      tutorName: 'Kevin Habimana',
      initials: 'KH',
      day: 'WED',
      date: '16',
      time: '15:00',
      location: 'Campus',
      mode: 'On campus',
      isUpcoming: false,
      isRated: true,
      rating: 5,
      tutorId: 'sample-kevin',
      status: 'completed',
    ),
  ];
}
