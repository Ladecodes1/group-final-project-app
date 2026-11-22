import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class MySessionsPage extends ConsumerStatefulWidget {
  const MySessionsPage({super.key});

  @override
  ConsumerState<MySessionsPage> createState() => _MySessionsPageState();
}

class _MySessionsPageState extends ConsumerState<MySessionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref
          .read(studyLinkProvider.notifier)
          .loadSessions()
          .catchError((_) {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyLinkProvider);
    final sessions = state.sessions;
    final upcoming = sessions
        .where((session) => session.isUpcoming && session.status == 'confirmed')
        .toList();
    final past = sessions.where((session) => !session.isUpcoming).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 25),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('My sessions',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 26)),
              const SizedBox(height: 22),
              if (state.isLoadingSessions)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: LoadingIndicator()),
              if (!state.isLoadingSessions) ...[
                const Text('UPCOMING', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                if (upcoming.isEmpty)
                  AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Text('No upcoming sessions yet.',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textSecondary)))
                else
                  ...upcoming.map((session) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _UpcomingCard(
                            session: session,
                            onTap: () {
                              ref
                                  .read(studyLinkProvider.notifier)
                                  .selectSession(session);
                              context.push(
                                  '/session-details?sessionId=${Uri.encodeQueryComponent(session.id)}');
                            }),
                      )),
                const SizedBox(height: 10),
                const Text('PAST', style: AppTextStyles.eyebrow),
                const SizedBox(height: 10),
                if (past.isEmpty)
                  const AppCard(
                      padding: EdgeInsets.all(16),
                      child: Text('Completed sessions will appear here.',
                          style: AppTextStyles.body))
                else
                  ...past.map((session) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PastCard(
                          session: session,
                          onRate: () {
                            ref
                                .read(studyLinkProvider.notifier)
                                .selectSession(session);
                            context.push(
                                '/rate-session?sessionId=${Uri.encodeQueryComponent(session.id)}');
                          },
                        ),
                      )),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage!,
                    style:
                        const TextStyle(color: AppColors.danger, fontSize: 12)),
              ],
            ])),
      ))),
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
        child: Row(children: [
          _DateTile(session: session, upcoming: true),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(session.subject,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text('${session.tutorName} · ${session.time}',
                    style: AppTextStyles.caption),
                const SizedBox(height: 3),
                Text(session.location, style: AppTextStyles.caption),
              ])),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.green, size: 22),
        ]),
      );
}

class _PastCard extends StatelessWidget {
  const _PastCard({required this.session, required this.onRate});
  final StudySession session;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) => AppCard(
      padding: const EdgeInsets.all(13),
      child: Column(children: [
        Row(children: [
          _DateTile(session: session, upcoming: false),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(session.subject,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text('${session.tutorName} · ${session.mode} · ${session.time}',
                    style: AppTextStyles.caption),
                if (session.status == 'cancelled')
                  const Text('Cancelled',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
              ])),
          if (session.isRated)
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.star, size: 16),
              Text(' ${session.rating}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text))
            ]),
        ]),
        if (session.status == 'completed' && !session.isRated) ...[
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
                        borderRadius: BorderRadius.circular(10))),
                icon: const Icon(Icons.star_border_rounded, size: 17),
                label: const Text('Rate this session',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              )),
        ],
      ]));
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.session, required this.upcoming});
  final StudySession session;
  final bool upcoming;

  @override
  Widget build(BuildContext context) => Container(
        width: 54,
        height: 58,
        decoration: BoxDecoration(
            color: upcoming ? AppColors.green : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(session.day,
              style: TextStyle(
                  color: upcoming ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
          Text(session.date,
              style: TextStyle(
                  color: upcoming ? Colors.white : AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ]),
      );
}
