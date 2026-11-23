import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/records/presentation/pages/search_subject_page.dart';
import '../../features/records/presentation/pages/tutor_results_page.dart';
import '../../features/records/presentation/pages/tutor_profile_page.dart';
import '../../features/records/presentation/pages/availability_page.dart';
import '../../features/records/presentation/pages/booking_confirmation_page.dart';
import '../../features/records/presentation/pages/my_sessions_page.dart';
import '../../features/records/presentation/pages/session_details_page.dart';
import '../../features/records/presentation/pages/rate_session_page.dart';

CustomTransitionPage<void> _screen(GoRouterState state, Widget child) => CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 190),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(.025, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

final appRouterProvider = Provider<GoRouter>((ref) => GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(path: '/sign-in', pageBuilder: (context, state) => _screen(state, const SignInPage())),
        GoRoute(path: '/sign-up', pageBuilder: (context, state) => _screen(state, const SignUpPage())),
        GoRoute(path: '/home', pageBuilder: (context, state) => _screen(state, const HomePage())),
        GoRoute(path: '/search', pageBuilder: (context, state) => _screen(state, const SearchSubjectPage())),
        GoRoute(path: '/tutors', pageBuilder: (context, state) => _screen(state, const TutorResultsPage())),
        GoRoute(path: '/tutor-profile', pageBuilder: (context, state) => _screen(state, const TutorProfilePage())),
        GoRoute(path: '/availability', pageBuilder: (context, state) => _screen(state, const AvailabilityPage())),
        GoRoute(path: '/booking-confirmed', pageBuilder: (context, state) => _screen(state, const BookingConfirmationPage())),
        GoRoute(path: '/sessions', pageBuilder: (context, state) => _screen(state, const MySessionsPage())),
        GoRoute(path: '/session-details', pageBuilder: (context, state) => _screen(state, const SessionDetailsPage())),
        GoRoute(path: '/rate-session', pageBuilder: (context, state) => _screen(state, const RateSessionPage())),
      ],
    ));
