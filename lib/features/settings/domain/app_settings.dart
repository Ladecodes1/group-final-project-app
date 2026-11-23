import 'package:equatable/equatable.dart';

/// The preferences the user can change and that are saved on the phone.
class AppSettings extends Equatable {
  const AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.language = 'English',
  });

  final bool isDarkMode;

  // shortcut: stored and restored only, no reminder system yet; wire to notifications when sessions get reminders.
  final bool notificationsEnabled;

  // shortcut: stored and restored only, UI text is not translated; add flutter_localizations + ARB files to apply it.
  final String language;

  AppSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? language,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, notificationsEnabled, language];
}
