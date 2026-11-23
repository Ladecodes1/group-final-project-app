import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studylink/app/app.dart';

import '../test/studylink_test_fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('student can sign in and open subject search', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = FakeAuthRepository();

    await tester.pumpWidget(StudyLinkApp(prefs: prefs, authRepository: auth));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@alustudent.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Your next session'), findsOneWidget);
    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();
    expect(find.text('Find help'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await auth.close();
  });
}
