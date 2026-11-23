import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/state/study_link_controller.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_card.dart';

const _matchingSubjects = <(String, String, String)>[
  ('Data Structures & Algorithms', 'Software Engineering · 6 tutors', 'Data Structures & Algorithms'),
  ('Databases & SQL', 'Software Engineering · 3 tutors', 'Databases & SQL'),
  ('Data Analysis with Python', 'Global Challenges · 2 tutors', 'Data Analysis with Python'),
];

class SearchSubjectPage extends ConsumerWidget {
  const SearchSubjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyLinkProvider);
    final q = state.searchQuery.trim().toLowerCase();
    final matches = q.isEmpty ? _matchingSubjects : _matchingSubjects.where((s) => s.$1.toLowerCase().contains(q) || s.$2.toLowerCase().contains(q)).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 25, 20, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Find help', style: AppTextStyles.pageTitle.copyWith(fontSize: 27)),
          const SizedBox(height: 22),
          const Text('Subject or course', style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.searchQuery,
            onChanged: ref.read(studyLinkProvider.notifier).setSearchQuery,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref.read(studyLinkProvider.notifier).selectSubject(value.trim());
                context.push('/tutors');
              }
            },
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary), hintText: 'Search a subject or course'),
          ),
          const SizedBox(height: 23),
          const Text('MATCHING SUBJECTS', style: AppTextStyles.eyebrow),
          const SizedBox(height: 10),
          if (matches.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('No matching subjects. Try another search.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)))
          else
            ...matches.map((subject) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                onTap: () {
                  ref.read(studyLinkProvider.notifier).selectSubject(subject.$3);
                  context.push('/tutors');
                },
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subject.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text(subject.$2, style: AppTextStyles.caption),
                  ])),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.green, size: 22),
                ]),
              ),
            )),
          const SizedBox(height: 12),
          const Text('ALL SUBJECTS', style: AppTextStyles.eyebrow),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 9, children: sampleSubjects.map((subject) => ActionChip(
            label: Text(subject, style: const TextStyle(color: AppColors.green, fontSize: 12, fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.mint,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            onPressed: () {
              ref.read(studyLinkProvider.notifier).selectSubject(subject);
              context.push('/tutors');
            },
          )).toList()),
        ])),
      ))),
    );
  }
}
