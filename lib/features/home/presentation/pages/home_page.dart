import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_card.dart';
import '../widgets/subject_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    // The next upcoming session, so a new booking or a cancellation shows here.
    final next = state.sessions.where((s) => s.isUpcoming).firstOrNull;
    // The signed-in user comes from the shared AuthBloc (Firebase Auth).
    final email =
        context.select((AuthBloc bloc) => bloc.state.user?.email) ?? '';
    final displayName = _nameFromEmail(email);
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Muraho,',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              displayName,
                              style: AppTextStyles.pageTitle.copyWith(
                                fontSize: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Log out',
                        // The router sends the user back to Sign In once AuthBloc
                        // reports that nobody is signed in.
                        onPressed: () => context.read<AuthBloc>().add(
                          const AuthSignOutRequested(),
                        ),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.push('/search'),
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'What are you stuck on?',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flexible so the title shrinks instead of overflowing
                      // on small phones or with large system text.
                      const Flexible(
                        child: Text(
                          'Your next session',
                          style: AppTextStyles.section,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/sessions'),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppCard(
                    color: AppColors.green,
                    padding: const EdgeInsets.all(17),
                    onTap: () => next == null
                        ? context.push('/search')
                        : context.push('/session-details', extra: next),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (next?.subject ?? 'No upcoming session')
                                        .toUpperCase(),
                                    style: AppTextStyles.eyebrow.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: .72,
                                      ),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    next == null
                                        ? 'Find a peer to help you'
                                        : 'with ${next.tutorName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.beigeAvatar,
                              child: Text(
                                next?.initials ?? '?',
                                style: const TextStyle(
                                  color: Color(0xFF765A22),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            if (next != null)
                              _HeroMeta(
                                icon: Icons.calendar_today_outlined,
                                label:
                                    '${next.day} ${next.date} · ${next.time}',
                              ),
                            if (next != null)
                              _HeroMeta(
                                icon: Icons.location_on_outlined,
                                label: next.location,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Browse by subject', style: AppTextStyles.section),
                  const SizedBox(height: 11),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - 10) / 2;
                      final subjects = const [
                        (
                          'Data Structures',
                          '6 tutors free this week',
                          'Data Structures & Algorithms',
                        ),
                        (
                          'Discrete Maths',
                          '4 tutors free this week',
                          'Discrete Maths',
                        ),
                        (
                          'Intro to Python',
                          '9 tutors free this week',
                          'Intro to Python',
                        ),
                        ('Statistics', '3 tutors free this week', 'Statistics'),
                      ];
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: subjects
                            .map(
                              (subject) => SizedBox(
                                width: width,
                                child: SubjectCard(
                                  title: subject.$1,
                                  subtitle: subject.$2,
                                  onTap: () {
                                    context
                                        .read<StudyLinkCubit>()
                                        .selectSubject(subject.$3);
                                    context.push('/tutors');
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF684D1B),
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your requests are private. Only the tutor you book sees what you need help with.',
                            style: TextStyle(
                              color: Color(0xFF684D1B),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Turns "aline.uwase@alustudent.com" into "Aline" for the greeting.
String _nameFromEmail(String email) {
  final local = email.split('@').first.split(RegExp(r'[._-]')).first;
  if (local.isEmpty) return 'Student';
  return local[0].toUpperCase() + local.substring(1);
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: Colors.white.withValues(alpha: .9)),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .95),
          fontSize: 12,
        ),
      ),
    ],
  );
}
