import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/availability/data/datasources/availability_remote_datasource.dart';
import '../features/availability/data/repositories/availability_repository_impl.dart';
import '../features/booking/data/datasources/booking_remote_datasource.dart';
import '../features/booking/data/repositories/booking_repository_impl.dart';
import '../features/reviews/data/datasources/review_remote_datasource.dart';
import '../features/reviews/data/repositories/review_repository_impl.dart';
import '../features/settings/data/settings_repository_impl.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import '../features/subjects/data/datasources/subject_remote_datasource.dart';
import '../features/subjects/data/repositories/subject_repository_impl.dart';
import '../features/tutor_profiles/data/datasources/tutor_profile_remote_datasource.dart';
import '../features/tutor_profiles/data/repositories/tutor_profile_repository_impl.dart';
import '../features/users/data/datasources/user_remote_datasource.dart';
import '../features/users/data/repositories/user_repository_impl.dart';
import 'router/app_router.dart';
import 'state/firestore_study_link_backend.dart';
import 'state/study_link_backend.dart';
import 'state/study_link_cubit.dart';

/// Composition root: Firebase Auth, saved settings and the Firestore-backed
/// booking flow. Tests pass fakes for [authRepository] and [backend].
class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({
    required this.prefs,
    this.authRepository,
    this.backend,
    super.key,
  });

  final SharedPreferences prefs;
  final AuthRepository? authRepository;
  final StudyLinkBackend? backend;

  /// The real backend: the team's Firestore repositories.
  static StudyLinkBackend firestoreBackend() {
    final db = FirebaseFirestore.instance;
    return FirestoreStudyLinkBackend(
      users: UserRepositoryImpl(UserRemoteDataSourceImpl(db)),
      subjects: SubjectRepositoryImpl(SubjectRemoteDataSourceImpl(db)),
      tutors: TutorProfileRepositoryImpl(TutorProfileRemoteDataSourceImpl(db)),
      slots: AvailabilityRepositoryImpl(AvailabilityRemoteDataSourceImpl(db)),
      bookings: BookingRepositoryImpl(BookingRemoteDataSourceImpl(db)),
      reviews: ReviewRepositoryImpl(ReviewRemoteDataSourceImpl(db)),
    );
  }

  @override
  Widget build(BuildContext context) => RepositoryProvider<AuthRepository>(
    create: (_) => authRepository ?? AuthRepositoryImpl(),
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: context.read<AuthRepository>()),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(SettingsRepositoryImpl(prefs)),
        ),
        BlocProvider(
          create: (_) => StudyLinkCubit(backend ?? firestoreBackend()),
        ),
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
  final _messenger = GlobalKey<ScaffoldMessengerState>();

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

  /// Starts the booking data when someone signs in and clears it on sign-out.
  void _onAuthChanged(BuildContext context, AuthState auth) {
    final cubit = context.read<StudyLinkCubit>();
    final user = auth.user;
    if (auth.status == AuthStatus.authenticated && user != null) {
      cubit.start(
        userId: user.uid,
        email: user.email,
        displayName: displayNameFromEmail(user.email),
      );
    } else if (auth.status == AuthStatus.unauthenticated) {
      cubit.stop();
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.user?.uid != current.user?.uid,
        listener: _onAuthChanged,
      ),
      // Errors and confirmations from the booking flow appear in a snack bar.
      BlocListener<StudyLinkCubit, StudyLinkState>(
        listenWhen: (previous, current) => current.message != null,
        listener: (context, state) => _messenger.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.message!))),
      ),
    ],
    child: BlocBuilder<SettingsCubit, AppSettings>(
      buildWhen: (previous, current) =>
          previous.isDarkMode != current.isDarkMode,
      builder: (context, settings) => MaterialApp.router(
        title: 'StudyLink',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: _messenger,
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
    ),
  );
}

/// "aline.uwase@alustudent.com" -> "Aline Uwase".
String displayNameFromEmail(String email) {
  final parts = email
      .split('@')
      .first
      .split(RegExp(r'[._-]'))
      .where((part) => part.isNotEmpty);
  if (parts.isEmpty) return 'Student';
  return parts
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
