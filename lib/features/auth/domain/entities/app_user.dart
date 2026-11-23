import 'package:equatable/equatable.dart';

/// A signed-in user, kept independent of Firebase types.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });

  final String uid;
  final String email;
  final bool emailVerified;

  @override
  List<Object?> get props => [uid, email, emailVerified];
}
