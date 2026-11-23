import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:studylink/features/auth/presentation/pages/home_page.dart';
import 'package:studylink/features/settings/data/settings_repository_impl.dart';
import 'package:studylink/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:studylink/features/settings/presentation/pages/settings_page.dart';

import '../helpers/fake_auth_repository.dart';

void main() {
  late SharedPreferences prefs;
  late SettingsCubit cubit;

  final darkModeSwitch = find.widgetWithText(SwitchListTile, 'Dark mode');
  final remindersSwitch = find.widgetWithText(
    SwitchListTile,
    'Session reminders',
  );

  /// Pretends the phone already has [saved] values stored, then builds the
  /// cubit with the real SharedPreferences repository, like main.dart does.
  Future<void> openStorage([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    prefs = await SharedPreferences.getInstance();
    cubit = SettingsCubit(SettingsRepositoryImpl(prefs));
    addTearDown(cubit.close);
  }

  Future<void> showSettingsPage(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<SettingsCubit>.value(
        value: cubit,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
  }

  bool switchIsOn(WidgetTester tester, Finder finder) =>
      tester.widget<SwitchListTile>(finder).value;

  testWidgets('shows the default settings when nothing is saved', (
    tester,
  ) async {
    await openStorage();
    await showSettingsPage(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(switchIsOn(tester, darkModeSwitch), isFalse);
    expect(switchIsOn(tester, remindersSwitch), isTrue);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('shows the settings already saved on the phone', (tester) async {
    await openStorage({
      'isDarkMode': true,
      'notificationsEnabled': false,
      'language': 'Kinyarwanda',
    });
    await showSettingsPage(tester);

    expect(switchIsOn(tester, darkModeSwitch), isTrue);
    expect(switchIsOn(tester, remindersSwitch), isFalse);
    expect(find.text('Kinyarwanda'), findsOneWidget);
  });

  testWidgets('tapping Dark mode turns it on and saves it', (tester) async {
    await openStorage();
    await showSettingsPage(tester);

    await tester.tap(darkModeSwitch);
    await tester.pumpAndSettle();

    expect(switchIsOn(tester, darkModeSwitch), isTrue);
    expect(prefs.getBool('isDarkMode'), isTrue);
  });

  testWidgets('tapping Session reminders turns them off and saves it', (
    tester,
  ) async {
    await openStorage();
    await showSettingsPage(tester);

    await tester.tap(remindersSwitch);
    await tester.pumpAndSettle();

    expect(switchIsOn(tester, remindersSwitch), isFalse);
    expect(prefs.getBool('notificationsEnabled'), isFalse);
  });

  testWidgets('choosing a language shows it and saves it', (tester) async {
    await openStorage();
    await showSettingsPage(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    // The open menu shows every language; pick French from it.
    await tester.tap(find.text('French').last);
    await tester.pumpAndSettle();

    expect(find.text('French'), findsOneWidget);
    expect(find.text('English'), findsNothing);
    expect(prefs.getString('language'), 'French');
  });

  testWidgets('changes are still there after the app restarts', (tester) async {
    await openStorage();
    await showSettingsPage(tester);
    await tester.tap(darkModeSwitch);
    await tester.tap(remindersSwitch);
    await tester.pumpAndSettle();

    // A new cubit reading the same storage is what happens on relaunch.
    final relaunched = SettingsCubit(SettingsRepositoryImpl(prefs));
    addTearDown(relaunched.close);
    await tester.pumpWidget(
      BlocProvider<SettingsCubit>.value(
        value: relaunched,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );

    expect(switchIsOn(tester, darkModeSwitch), isTrue);
    expect(switchIsOn(tester, remindersSwitch), isFalse);
  });

  testWidgets('the settings button on Home opens the settings screen', (
    tester,
  ) async {
    await openStorage();
    final authRepository = FakeAuthRepository();
    final authBloc = AuthBloc(authRepository: authRepository);
    addTearDown(() async {
      await authBloc.close();
      await authRepository.dispose();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: cubit),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(darkModeSwitch, findsOneWidget);
  });
}
