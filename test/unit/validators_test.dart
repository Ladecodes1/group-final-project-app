import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/domain/validators.dart';

void main() {
  group('AuthValidators.email', () {
    test('asks for an email when the field is empty', () {
      expect(AuthValidators.email(''), 'Please enter your email.');
      expect(AuthValidators.email(null), 'Please enter your email.');
      expect(AuthValidators.email('   '), 'Please enter your email.');
    });

    test('rejects text that is not an email address', () {
      const message = 'Enter a valid email address.';
      expect(AuthValidators.email('student'), message);
      expect(AuthValidators.email('student@'), message);
      expect(AuthValidators.email('student@alu'), message);
      expect(AuthValidators.email('stu dent@alu.com'), message);
    });

    test('accepts a valid email, ignoring spaces around it', () {
      expect(AuthValidators.email('student@alustudent.com'), isNull);
      expect(AuthValidators.email('  student@alustudent.com  '), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('asks for a password when the field is empty', () {
      expect(AuthValidators.password(''), 'Please enter a password.');
      expect(AuthValidators.password(null), 'Please enter a password.');
    });

    test('rejects passwords shorter than 6 characters', () {
      expect(
        AuthValidators.password('12345'),
        'Password must be at least 6 characters.',
      );
    });

    test('accepts a password of 6 or more characters', () {
      expect(AuthValidators.password('123456'), isNull);
      expect(AuthValidators.password('a much longer password'), isNull);
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('asks the user to confirm when the field is empty', () {
      expect(
        AuthValidators.confirmPassword('', 'secret1'),
        'Please confirm your password.',
      );
      expect(
        AuthValidators.confirmPassword(null, 'secret1'),
        'Please confirm your password.',
      );
    });

    test('rejects a confirmation that does not match', () {
      expect(
        AuthValidators.confirmPassword('secret2', 'secret1'),
        'Passwords do not match.',
      );
    });

    test('accepts a matching confirmation', () {
      expect(AuthValidators.confirmPassword('secret1', 'secret1'), isNull);
    });
  });
}
