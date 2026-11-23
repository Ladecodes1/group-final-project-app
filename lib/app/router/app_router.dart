import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/study_link_models.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/records/presentation/pages/availability_page.dart';
import '../../features/records/presentation/pages/booking_confirmation_page.dart';
import '../../features/records/presentation/pages/my_sessions_page.dart';
import '../../features/records/presentation/pages/rate_session_page.dart';
import '../../features/records/presentation/pages/search_subject_page.dart';
import '../../features/records/presentation/pages/session_details_page.dart';
import '../../features/records/presentation/pages/tutor_profile_page.dart';
import '../../features/records/presentation/pages/tutor_results_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Owns both router and its auth refresh notifier to avoid a stream leak.
class StudyLinkRouter {
  StudyLinkRouter(AuthBloc authBloc) {
    _refresh = _AuthRouterRefresh(authBloc.stream);
    router = GoRouter(
      initialLocation: '/boot',
      refreshListenable: _refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isAuthRoute = location == '/sign-in' || location == '/sign-up';
        final status = authBloc.state.status;

        if (status == AuthStatus.unknown) {
          return location == '/boot' ? null : '/boot';
        }
        if (status == AuthStatus.unauthenticated) {
          return isAuthRoute ? null : '/sign-in';
        }
        if (location == '/boot' || isAuthRoute) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/boot',
          pageBuilder: (context, state) => _screen(
            state,
            const Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
        ),
        GoRoute(
          path: '/sign-in',
          pageBuilder: (context, state) => _screen(state, const LoginPage()),
        ),
        GoRoute(
          path: '/sign-up',
          pageBuilder: (context, state) => _screen(state, const SignUpPage()),
        ),
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _screen(state, const HomePage()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) =>
              _screen(state, const SearchSubjectPage()),
        ),
        GoRoute(
          path: '/tutors',
          pageBuilder: (context, state) =>
              _screen(state, const TutorResultsPage()),
        ),
        GoRoute(
          path: '/tutor-profile',
          pageBuilder: (context, state) =>
              _screen(state, const TutorProfilePage()),
        ),
        GoRoute(
          path: '/availability',
          pageBuilder: (context, state) =>
              _screen(state, const AvailabilityPage()),
        ),
        GoRoute(
          path: '/booking-confirmed',
          pageBuilder: (context, state) =>
              _screen(state, const BookingConfirmationPage()),
        ),
        GoRoute(
          path: '/sessions',
          pageBuilder: (context, state) =>
              _screen(state, const MySessionsPage()),
        ),
        GoRoute(
          path: '/session-details',
          pageBuilder: (context, state) => _screen(
            state,
            SessionDetailsPage(session: state.extra as StudySession?),
          ),
        ),
        GoRoute(
          path: '/rate-session',
          pageBuilder: (context, state) => _screen(
            state,
            RateSessionPage(session: state.extra as StudySession?),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _screen(state, const SettingsPage()),
        ),
      ],
    );
  }

  late final _AuthRouterRefresh _refresh;
  late final GoRouter router;

  void dispose() {
    router.dispose();
    _refresh.dispose();
  }
}

CustomTransitionPage<void> _screen(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 210),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.035, 0),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: .985, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
