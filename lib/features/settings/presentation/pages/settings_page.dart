import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/app_settings.dart';
import '../cubit/settings_cubit.dart';

/// Lets the user change preferences that are saved on the device.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _languages = ['English', 'French', 'Kinyarwanda'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                value: settings.isDarkMode,
                onChanged: cubit.setDarkMode,
              ),
              SwitchListTile(
                title: const Text('Session reminders'),
                value: settings.notificationsEnabled,
                onChanged: cubit.setNotifications,
              ),
              ListTile(
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  items: [
                    for (final language in _languages)
                      DropdownMenuItem(value: language, child: Text(language)),
                  ],
                  onChanged: (value) {
                    if (value != null) cubit.setLanguage(value);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
