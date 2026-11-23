import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studylink/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:studylink/features/auth/domain/auth_failure.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockUser firebaseUser;
  late MockUserCredential credential;
  late AuthRepositoryImpl repository;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    firebaseUser = MockUser();
    credential = MockUserCredential();
    repository = AuthRepositoryImpl(firebaseAuth: firebaseAuth);

    when(() => firebaseUser.uid).thenReturn('user-123');
    when(() => firebaseUser.email).thenReturn('student@alustudent.com');
    when(() => firebaseUser.emailVerified).thenReturn(true);
    when(() => credential.user).thenReturn(firebaseUser);
  });

  /// Makes Firebase sign-in fail with the given error code.
  void signInFailsWith(String code) {
    when(
      () => firebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: code));
  }

  /// Signs in and returns the message of the [AuthFailure] it throws.
  Future<String> signInErrorMessage() async {
    try {
      await repository.signIn(email: 'a@b.co', password: 'secret1');
    } on AuthFailure catch (failure) {
      return failure.message;
    }
    fail('Expected signIn to throw an AuthFailure');
  }

  group('authStateChanges', () {
    test('turns a Firebase user into an AppUser', () async {
      when(() => firebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(firebaseUser));

      final user = await repository.authStateChanges.first;

      expect(user?.uid, 'user-123');
      expect(user?.email, 'student@alustudent.com');
      expect(user?.emailVerified, isTrue);
    });

    test('reports null when nobody is signed in', () async {
      when(() => firebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      expect(await repository.authStateChanges.first, isNull);
    });

    test('uses an empty email when Firebase has none', () async {
      when(() => firebaseUser.email).thenReturn(null);
      when(() => firebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(firebaseUser));

      final user = await repository.authStateChanges.first;

      expect(user?.email, '');
    });
  });

  group('signIn', () {
    test('trims the email and returns the signed-in user', () async {
      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);

      final user = await repository.signIn(
        email: '  student@alustudent.com ',
        password: 'secret1',
      );

      expect(user.uid, 'user-123');
      verify(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'student@alustudent.com',
          password: 'secret1',
        ),
      ).called(1);
    });

    test('hides whether the email or the password was wrong', () async {
      for (final code in [
        'user-not-found',
        'wrong-password',
        'invalid-credential',
      ]) {
        signInFailsWith(code);
        expect(await signInErrorMessage(), 'Incorrect email or password.');
      }
    });

    test('turns each Firebase error into a clear message', () async {
      const expected = {
        'invalid-email': 'That email address is not valid.',
        'too-many-requests': 'Too many attempts. Please try again later.',
        'network-request-failed': 'No internet connection. Check your network.',
        'some-new-code': 'Something went wrong. Please try again.',
      };
      for (final entry in expected.entries) {
        signInFailsWith(entry.key);
        expect(await signInErrorMessage(), entry.value);
      }
    });
  });

  group('signUp', () {
    test('creates the account and returns the new user', () async {
      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => credential);

      final user = await repository.signUp(
        email: 'student@alustudent.com',
        password: 'secret1',
      );

      expect(user.email, 'student@alustudent.com');
    });

    test('explains when the email is taken or the password weak', () async {
      const expected = {
        'email-already-in-use': 'An account with this email already exists.',
        'weak-password': 'Password is too weak. Use at least 6 characters.',
      };
      for (final entry in expected.entries) {
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: entry.key));

        await expectLater(
          repository.signUp(email: 'a@b.co', password: 'secret1'),
          throwsA(
            isA<AuthFailure>().having((f) => f.message, 'message', entry.value),
          ),
        );
      }
    });
  });

  group('password reset and verification', () {
    test('sends the reset email to the trimmed address', () async {
      when(
        () => firebaseAuth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      await repository.sendPasswordReset(' student@alustudent.com ');

      verify(
        () => firebaseAuth.sendPasswordResetEmail(
          email: 'student@alustudent.com',
        ),
      ).called(1);
    });

    test('reports a clear message when the reset email fails', () async {
      when(
        () => firebaseAuth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(FirebaseAuthException(code: 'invalid-email'));

      await expectLater(
        repository.sendPasswordReset('bad'),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('sends a verification email to the current user', () async {
      when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
      when(() => firebaseUser.sendEmailVerification()).thenAnswer((_) async {});

      await repository.sendEmailVerification();

      verify(() => firebaseUser.sendEmailVerification()).called(1);
    });

    test('reports a clear message when verification fails', () async {
      when(() => firebaseAuth.currentUser).thenReturn(firebaseUser);
      when(() => firebaseUser.sendEmailVerification())
          .thenThrow(FirebaseAuthException(code: 'too-many-requests'));

      await expectLater(
        repository.sendEmailVerification(),
        throwsA(isA<AuthFailure>()),
      );
    });
  });

  test('signOut signs out of Firebase', () async {
    when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

    await repository.signOut();

    verify(() => firebaseAuth.signOut()).called(1);
  });
}
