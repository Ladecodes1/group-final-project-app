import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Muraho,', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
              Text(state.userName, style: AppTextStyles.pageTitle.copyWith(fontSize: 26)),
            ])),
            const CircleAvatar(radius: 21, backgroundColor: AppColors.beigeAvatar, child: Text('AU', style: TextStyle(color: Color(0xFF765A22), fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 22),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => context.go('/search'),
            child: Container(
              height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [const Icon(Icons.search_rounded, color: AppColors.textSecondary), const SizedBox(width: 12), Text('What are you stuck on?', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))]),
            ),
          ),
          const SizedBox(height: 22),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Your next session', style: AppTextStyles.section),
            TextButton(onPressed: () => context.go('/sessions'), child: const Text('See all', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700))),
          ]),
          AppCard(
            color: AppColors.green,
            padding: const EdgeInsets.all(17),
            onTap: () => context.push('/session-details'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DATA STRUCTURES & ALGORITHMS', style: AppTextStyles.eyebrow.copyWith(color: Colors.white.withValues(alpha: .72), fontSize: 10)),
                  const SizedBox(height: 5),
                  const Text('with Kevin Habimana', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                ])),
                const CircleAvatar(radius: 22, backgroundColor: AppColors.beigeAvatar, child: Text('KH', style: TextStyle(color: Color(0xFF765A22), fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 16, runSpacing: 8, children: [
                _HeroMeta(icon: Icons.calendar_today_outlined, label: 'Thu 24 Sep · 16:00'),
                _HeroMeta(icon: Icons.location_on_outlined, label: 'Library, pod 2'),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Browse by subject', style: AppTextStyles.section),
          const SizedBox(height: 11),
          LayoutBuilder(builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            final subjects = const [
              ('Data Structures', '6 tutors free this week', 'Data Structures & Algorithms'),
              ('Discrete Maths', '4 tutors free this week', 'Discrete Maths'),
              ('Intro to Python', '9 tutors free this week', 'Intro to Python'),
              ('Statistics', '3 tutors free this week', 'Statistics'),
            ];
            return Wrap(spacing: 10, runSpacing: 10, children: subjects.map((subject) => SizedBox(width: width, child: SubjectCard(
              title: subject.$1,
              subtitle: subject.$2,
              onTap: () {
                ref.read(studyLinkProvider.notifier).selectSubject(subject.$3);
                context.push('/tutors');
              },
            ))).toList());
          }),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.lock_outline_rounded, color: Color(0xFF684D1B), size: 19),
              SizedBox(width: 10),
              Expanded(child: Text('Your requests are private. Only the tutor you book sees what you need help with.', style: TextStyle(color: Color(0xFF684D1B), fontSize: 13, height: 1.4))),
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
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 15, color: Colors.white.withValues(alpha: .9)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .95), fontSize: 12)),
  ]);
}
