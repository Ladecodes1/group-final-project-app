import 'package:flutter/material.dart';

@immutable
class Tutor {
  const Tutor({
    required this.name,
    required this.initials,
    required this.year,
    required this.programme,
    required this.rating,
    required this.sessions,
    required this.nextSlot,
    required this.subjects,
    required this.about,
    required this.avatarColor,
    this.fullyBooked = false,
    this.isNew = false,
    this.testimonial = 'He did not make me feel slow for asking basic questions. The topic finally clicked.',
  });

  final String name;
  final String initials;
  final String year;
  final String programme;
  final double rating;
  final int sessions;
  final String nextSlot;
  final List<String> subjects;
  final String about;
  final Color avatarColor;
  final bool fullyBooked;
  final bool isNew;
  final String testimonial;
}

@immutable
class StudySession {
  const StudySession({
    required this.subject,
    required this.tutorName,
    required this.initials,
    required this.day,
    required this.date,
    required this.time,
    required this.location,
    required this.mode,
    this.isUpcoming = false,
    this.isRated = false,
    this.rating = 0,
  });

  final String subject;
  final String tutorName;
  final String initials;
  final String day;
  final String date;
  final String time;
  final String location;
  final String mode;
  final bool isUpcoming;
  final bool isRated;
  final int rating;

  StudySession copyWith({bool? isUpcoming, bool? isRated, int? rating}) => StudySession(
        subject: subject,
        tutorName: tutorName,
        initials: initials,
        day: day,
        date: date,
        time: time,
        location: location,
        mode: mode,
        isUpcoming: isUpcoming ?? this.isUpcoming,
        isRated: isRated ?? this.isRated,
        rating: rating ?? this.rating,
      );
}

const sampleKevin = Tutor(
    name: 'Kevin Habimana', initials: 'KH', year: 'Year 3',
    programme: 'Software Engineering', rating: 4.9, sessions: 14,
    nextSlot: 'Today · 18:00',
    subjects: ['Data Structures & Algorithms', 'Intro to Python', 'Discrete Maths'],
    about: 'I struggled with recursion and linked lists in my first year, so I explain them step by step with drawings before we write any code. Bring the exact exercise you are stuck on.',
    avatarColor: Color(0xFFF4DFB1),
    testimonial: 'He did not make me feel slow for asking basic questions. Trees finally clicked.',
  );

const sampleTutors = <Tutor>[
  sampleKevin,
  Tutor(
    name: 'Grace Uwase', initials: 'GU', year: 'Year 2',
    programme: 'Software Engineering', rating: 4.7, sessions: 9,
    nextSlot: 'Tomorrow · 10:00',
    subjects: ['Data Structures & Algorithms', 'Statistics', 'Data Analysis with Python', 'Discrete Maths'],
    about: 'I use practical examples and clear steps to make difficult topics easier to understand. We work through the problem together.',
    avatarColor: Color(0xFFD5E8E0),
  ),
  Tutor(
    name: 'Samuel Ndayisaba', initials: 'SN', year: 'Year 4',
    programme: 'Software Engineering', rating: 0, sessions: 0,
    nextSlot: 'Fri 25 Sep · 13:00',
    subjects: ['Data Structures & Algorithms', 'Web Development'],
    about: 'I enjoy breaking down challenging engineering concepts into smaller, manageable steps.',
    avatarColor: Color(0xFFE7DFF3), isNew: true,
  ),
  Tutor(
    name: 'Nadia Kamikazi', initials: 'NK', year: 'Year 3',
    programme: 'Software Engineering', rating: 0, sessions: 0,
    nextSlot: 'Fully booked this week',
    subjects: ['Data Structures & Algorithms'],
    about: 'I help students practise algorithms with clear examples.',
    avatarColor: Color(0xFFE6E1D7), fullyBooked: true,
  ),
];

const sampleSubjects = <String>[
  'Discrete Maths', 'Intro to Python', 'Statistics', 'Web Development',
  'Linux & Shell', 'Financial Accounting', 'Leadership Core',
];
