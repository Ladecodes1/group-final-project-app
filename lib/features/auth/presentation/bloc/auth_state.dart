import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

/// Whether we know who the user is yet.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isLoading;

  /// Shown to the user as an error (for example a wrong password).
  final String? errorMessage;

  /// Shown to the user as good news (for example "reset email sent").
  final String? infoMessage;

  /// Messages are cleared on every copy unless given again.
  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, user, isLoading, errorMessage, infoMessage];
}
