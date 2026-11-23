import 'package:equatable/equatable.dart';

/// A course students can get help with (pure Dart, no Firebase).
class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.name,
    required this.courseCode,
  });

  final String id;
  final String name;
  final String courseCode;

  @override
  List<Object?> get props => [id, name, courseCode];
}
