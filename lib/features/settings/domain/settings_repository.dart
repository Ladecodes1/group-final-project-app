import 'app_settings.dart';

/// What the app can do with saved settings.
abstract class SettingsRepository {
  AppSettings load();

  Future<void> save(AppSettings settings);
}
