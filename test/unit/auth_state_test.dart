import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_state.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  group('AuthState', () {
    test('starts as unknown, not loading, with no messages', () {
      const state = AuthState();
      expect(state.status, AuthStatus.unknown);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.infoMessage, isNull);
    });

    test('copyWith keeps the user and status it is not given', () {
      const state = AuthState(status: AuthStatus.authenticated, user: testUser);
      final copy = state.copyWith(isLoading: true);
      expect(copy.status, AuthStatus.authenticated);
      expect(copy.user, testUser);
      expect(copy.isLoading, isTrue);
    });

    test('copyWith clears old messages unless they are passed again', () {
      const state = AuthState(errorMessage: 'Old error', infoMessage: 'Old');
      final copy = state.copyWith();
      expect(copy.errorMessage, isNull);
      expect(copy.infoMessage, isNull);
    });

    test('two states with the same values are equal', () {
      expect(
        const AuthState(status: AuthStatus.unauthenticated),
        const AuthState(status: AuthStatus.unauthenticated),
      );
    });
  });

  test('AuthFailure shows its message when printed', () {
    const failure = AuthFailure('Incorrect email or password.');
    expect(failure.toString(), 'Incorrect email or password.');
  });
}
