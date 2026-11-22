import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_card.dart';
import '../widgets/subject_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyLinkProvider);
    final upcomingSessions = state.sessions
        .where((session) => session.isUpcoming && session.status == 'confirmed')
        .toList();
    final nextSession =
        upcomingSessions.isEmpty ? null : upcomingSessions.first;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Muraho,',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textSecondary)),
                      Text(state.userName,
                          style:
                              AppTextStyles.pageTitle.copyWith(fontSize: 26)),
                    ])),
                const CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.beigeAvatar,
                    child: Text('AU',
                        style: TextStyle(
                            color: Color(0xFF765A22),
                            fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 22),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go('/search'),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                      'What are you stuck on?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ))
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              Row(children: [
                const Expanded(
                    child: Text(
                  'Your next session',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.section,
                )),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(56, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => context.go('/sessions'),
                  child: const Text('See all',
                      style: TextStyle(
                          color: AppColors.green, fontWeight: FontWeight.w700)),
                ),
              ]),
              if (nextSession == null)
                AppCard(
                  padding: const EdgeInsets.all(17),
                  child: Row(children: [
                    const Icon(Icons.event_available_outlined,
                        color: AppColors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            'You have no upcoming sessions. Find a peer tutor when you need help.',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary))),
                  ]),
                )
              else
                AppCard(
                  color: AppColors.green,
                  padding: const EdgeInsets.all(17),
                  onTap: () {
                    ref
                        .read(studyLinkProvider.notifier)
                        .selectSession(nextSession);
                    context.push(
                        '/session-details?sessionId=${Uri.encodeQueryComponent(nextSession.id)}');
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(nextSession.subject.toUpperCase(),
                                    style: AppTextStyles.eyebrow.copyWith(
                                        color:
                                            Colors.white.withValues(alpha: .72),
                                        fontSize: 10)),
                                const SizedBox(height: 5),
                                Text('with ${nextSession.tutorName}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                              ])),
                          CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.beigeAvatar,
                              child: Text(nextSession.initials,
                                  style: const TextStyle(
                                      color: Color(0xFF765A22),
                                      fontWeight: FontWeight.w700))),
                        ]),
                        const SizedBox(height: 12),
                        Wrap(spacing: 16, runSpacing: 8, children: [
                          _HeroMeta(
                              icon: Icons.calendar_today_outlined,
                              label:
                                  '${nextSession.day} ${nextSession.date} · ${nextSession.time}'),
                          _HeroMeta(
                              icon: Icons.location_on_outlined,
                              label: nextSession.location),
                        ]),
                      ]),
                ),
              const SizedBox(height: 24),
              const Text('Browse by subject', style: AppTextStyles.section),
              const SizedBox(height: 11),
              LayoutBuilder(builder: (context, constraints) {
                final width = (constraints.maxWidth - 10) / 2;
                final subjects = state.subjects.take(4).toList();
                return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: subjects
                        .map((subject) => SizedBox(
                            width: width,
                            child: SubjectCard(
                              title: subject.name,
                              subtitle:
                                  '${subject.tutorCount} tutors available',
                              onTap: () {
                                ref
                                    .read(studyLinkProvider.notifier)
                                    .selectSubject(subject.name,
                                        id: subject.id);
                                context.push('/tutors');
                              },
                            )))
                        .toList());
              }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(14)),
                child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          color: Color(0xFF684D1B), size: 19),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text(
                              'Your requests are private. Only the tutor you book sees what you need help with.',
                              style: TextStyle(
                                  color: Color(0xFF684D1B),
                                  fontSize: 13,
                                  height: 1.4))),
                    ]),
              ),
            ])),
      ))),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: .9)),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: .95), fontSize: 12)),
      ]);
}
