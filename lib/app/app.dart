import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/settings/data/settings_repository_impl.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import 'router/app_router.dart';
import 'state/study_link_cubit.dart';

/// Composition root preserving the team's Firebase Auth and Settings Cubit.
class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({
    required this.prefs,
    this.authRepository,
    super.key,
  });

  final SharedPreferences prefs;
  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) => RepositoryProvider<AuthRepository>(
        create: (_) => authRepository ?? AuthRepositoryImpl(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
            BlocProvider(
              create: (_) => SettingsCubit(SettingsRepositoryImpl(prefs)),
            ),
            BlocProvider(create: (_) => StudyLinkCubit()),
          ],
          child: const _StudyLinkAppView(),
        ),
      );
}

class _StudyLinkAppView extends StatefulWidget {
  const _StudyLinkAppView();

  @override
  State<_StudyLinkAppView> createState() => _StudyLinkAppViewState();
}

class _StudyLinkAppViewState extends State<_StudyLinkAppView> {
  late final StudyLinkRouter _router;

  @override
  void initState() {
    super.initState();
    _router = StudyLinkRouter(context.read<AuthBloc>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<SettingsCubit, AppSettings>(
        buildWhen: (previous, current) =>
            previous.isDarkMode != current.isDarkMode,
        builder: (context, settings) => MaterialApp.router(
          title: 'StudyLink',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.green,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router.router,
        ),
      );
}
