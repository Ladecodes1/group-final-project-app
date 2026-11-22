import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Holds the sign-in state of the whole app.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthPasswordResetRequested>(_onPasswordReset);

    // Firebase remembers the user, so this also restores the session
    // when the app is reopened.
    _userSubscription = _authRepository.authStateChanges
        .listen((user) => add(AuthUserChanged(user)));
  }

  final AuthRepository _authRepository;
  late final StreamSubscription _userSubscription;

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      AuthState(
        status: event.user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: event.user,
      ),
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      await _authRepository.sendEmailVerification();
      emit(
        state.copyWith(
          infoMessage: 'Account created. Check your email to verify it.',
        ),
      );
    } on AuthFailure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith());
    } on AuthFailure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  Future<void> _onPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _authRepository.sendPasswordReset(event.email);
      emit(
        state.copyWith(
          infoMessage: 'Password reset email sent. Check your inbox.',
        ),
      );
    } on AuthFailure catch (failure) {
      emit(state.copyWith(errorMessage: failure.message));
    }
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
