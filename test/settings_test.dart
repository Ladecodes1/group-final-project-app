import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studylink/features/settings/data/settings_repository_impl.dart';
import 'package:studylink/features/settings/domain/app_settings.dart';
import 'package:studylink/features/settings/presentation/cubit/settings_cubit.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults when nothing is saved', () async {
    final repo = SettingsRepositoryImpl(await SharedPreferences.getInstance());
    expect(repo.load(), const AppSettings());
  });

  test('changes are restored after a relaunch', () async {
    final cubit = SettingsCubit(
      SettingsRepositoryImpl(await SharedPreferences.getInstance()),
    );
    await cubit.setDarkMode(true);
    await cubit.setNotifications(false);
    await cubit.setLanguage('French');
    await cubit.close();

    // A new cubit on the same storage = the app opened again.
    final relaunched = SettingsCubit(
      SettingsRepositoryImpl(await SharedPreferences.getInstance()),
    );
    expect(
      relaunched.state,
      const AppSettings(
        isDarkMode: true,
        notificationsEnabled: false,
        language: 'French',
      ),
    );
  });

  test('reads values already on the device', () async {
    SharedPreferences.setMockInitialValues({
      'isDarkMode': true,
      'language': 'Kinyarwanda',
    });
    final repo = SettingsRepositoryImpl(await SharedPreferences.getInstance());
    expect(
      repo.load(),
      const AppSettings(isDarkMode: true, language: 'Kinyarwanda'),
    );
  });
}
