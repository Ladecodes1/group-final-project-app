import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylink/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('student can move from sign in to subject search', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StudyLinkApp()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'student@alustudent.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Your next session'), findsOneWidget);
    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();
    expect(find.text('Find help'), findsOneWidget);
  });
}
