import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/app_settings.dart';
import '../../domain/settings_repository.dart';

/// Holds the current settings and saves every change.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repository) : super(_repository.load());

  final SettingsRepository _repository;

  Future<void> setDarkMode(bool value) =>
      _update(state.copyWith(isDarkMode: value));

  Future<void> setNotifications(bool value) =>
      _update(state.copyWith(notificationsEnabled: value));

  Future<void> setLanguage(String value) =>
      _update(state.copyWith(language: value));

  Future<void> _update(AppSettings settings) async {
    emit(settings);
    await _repository.save(settings);
  }
}
