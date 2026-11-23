import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylink/app/app.dart';

void main() {
  testWidgets('sign-in screen renders the StudyLink prototype heading', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: StudyLinkApp()));
    await tester.pumpAndSettle();

    expect(find.text('StudyLink'), findsOneWidget);
    expect(find.text('Stuck on a topic? A classmate has been there.'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('sign-in layout remains scrollable on a compact landscape display', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: StudyLinkApp()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(568, 320);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
