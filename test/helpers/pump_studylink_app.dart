import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studylink/app/app.dart';

import 'fake_auth_repository.dart';

/// Runs the whole StudyLink app (router, AuthBloc, settings and booking state)
/// with a fake login, on a phone-sized screen.
///
/// [signedIn] decides whether the app opens on Home or on Sign In.
Future<FakeAuthRepository> pumpStudyLinkApp(
  WidgetTester tester, {
  bool signedIn = false,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final repository = FakeAuthRepository();
  addTearDown(repository.dispose);

  await tester.pumpWidget(
    StudyLinkApp(prefs: prefs, authRepository: repository),
  );
  // Firebase would report the saved login state when the app starts.
  repository.emitUser(signedIn ? testUser : null);
  await tester.pumpAndSettle();
  return repository;
}

/// Taps a widget after scrolling it into view.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
