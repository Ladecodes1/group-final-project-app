import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_card.dart';

class MySessionsPage extends StatelessWidget {
  const MySessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<StudyLinkCubit>().state.sessions;
    final upcoming = sessions.where((session) => session.isUpcoming).toList();
    final past = sessions.where((session) => !session.isUpcoming).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
              children: [
                Text('My sessions', style: AppTextStyles.pageTitle),
                const SizedBox(height: 22),
                const Text('UPCOMING', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                if (upcoming.isEmpty)
                  AppCard(
                    child: Text(
                      'No upcoming sessions yet.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...upcoming.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _UpcomingCard(
                        session: session,
                        onTap: () =>
                            context.push('/session-details', extra: session),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                const Text('PAST', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                if (past.isEmpty)
                  const AppCard(
                    child: Text(
                      'Completed sessions will appear here.',
                      style: AppTextStyles.body,
                    ),
                  )
                else
                  ...past.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PastCard(
                        session: session,
                        onRate: () {
                          context.read<StudyLinkCubit>().prepareRating(session);
                          context.push('/rate-session', extra: session);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.session, required this.onTap});
  final StudySession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 54,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.day,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                session.date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.subject,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${session.tutorName} · ${session.time}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 3),
              Text(session.location, style: AppTextStyles.caption),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.green,
          size: 22,
        ),
      ],
    ),
  );
}

class _PastCard extends StatelessWidget {
  const _PastCard({required this.session, required this.onRate});
  final StudySession session;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(13),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    session.day,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    session.date,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.subject,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.tutorName} · ${session.mode} · ${session.time}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (session.isRated)
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.star,
                    size: 16,
                  ),
                  Text(
                    ' ${session.rating}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (!session.isRated) ...[
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: FilledButton.tonalIcon(
              onPressed: onRate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: const Color(0xFF684D1B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.star_border_rounded, size: 17),
              label: const Text(
                'Rate this session',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
