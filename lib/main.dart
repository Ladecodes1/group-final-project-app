import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/settings/data/settings_repository_impl.dart';
import 'features/settings/domain/app_settings.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Loaded before runApp so saved settings apply on the very first frame.
  final prefs = await SharedPreferences.getInstance();
  runApp(StudyLinkApp(prefs: prefs));
}

class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (_) => SettingsCubit(SettingsRepositoryImpl(prefs)),
          ),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          buildWhen: (previous, current) =>
              previous.isDarkMode != current.isDarkMode,
          builder: (context, settings) => MaterialApp(
            title: 'StudyLink',
            theme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) {
                switch (state.status) {
                  case AuthStatus.unknown:
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  case AuthStatus.authenticated:
                    return const HomePage();
                  case AuthStatus.unauthenticated:
                    return const LoginPage();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
