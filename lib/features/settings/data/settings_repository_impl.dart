import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Saves and loads settings using SharedPreferences.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _darkModeKey = 'isDarkMode';
  static const _notificationsKey = 'notificationsEnabled';
  static const _languageKey = 'language';

  @override
  AppSettings load() {
    return AppSettings(
      isDarkMode: _prefs.getBool(_darkModeKey) ?? false,
      notificationsEnabled: _prefs.getBool(_notificationsKey) ?? true,
      language: _prefs.getString(_languageKey) ?? 'English',
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _prefs.setBool(_darkModeKey, settings.isDarkMode);
    await _prefs.setBool(_notificationsKey, settings.notificationsEnabled);
    await _prefs.setString(_languageKey, settings.language);
  }
}
