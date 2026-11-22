import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class SearchSubjectPage extends ConsumerStatefulWidget {
  const SearchSubjectPage({super.key});

  @override
  ConsumerState<SearchSubjectPage> createState() => _SearchSubjectPageState();
}

class _SearchSubjectPageState extends ConsumerState<SearchSubjectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyLinkProvider.notifier).loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyLinkProvider);
    final query = state.searchQuery.trim().toLowerCase();
    final matches = state.subjects
        .where((subject) =>
            subject.name.toLowerCase().contains(query) ||
            subject.programme.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Find help',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 27)),
              const SizedBox(height: 22),
              const Text('Subject or course',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('subject-search'),
                initialValue: state.searchQuery,
                onChanged: ref.read(studyLinkProvider.notifier).setSearchQuery,
                onFieldSubmitted: (value) async {
                  await ref
                      .read(studyLinkProvider.notifier)
                      .loadSubjects(query: value);
                  if (!context.mounted) return;
                  final results = ref.read(studyLinkProvider).subjects;
                  if (results.isNotEmpty) {
                    final selected = results.firstWhere(
                      (subject) => subject.name
                          .toLowerCase()
                          .contains(value.toLowerCase()),
                      orElse: () => results.first,
                    );
                    ref
                        .read(studyLinkProvider.notifier)
                        .selectSubject(selected.name, id: selected.id);
                    context.push('/tutors');
                  }
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textSecondary),
                  hintText: 'Search a subject or course',
                ),
              ),
              const SizedBox(height: 23),
              const Text('MATCHING SUBJECTS', style: AppTextStyles.eyebrow),
              const SizedBox(height: 10),
              if (state.isLoadingSubjects)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: LoadingIndicator())
              else if (matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text('No matching subjects. Try another search.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary)),
                )
              else
                ...matches.map((subject) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 14),
                        onTap: () {
                          ref
                              .read(studyLinkProvider.notifier)
                              .selectSubject(subject.name, id: subject.id);
                          context.push('/tutors');
                        },
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(subject.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.text)),
                                const SizedBox(height: 4),
                                Text(
                                    '${subject.programme} · ${subject.tutorCount} tutors',
                                    style: AppTextStyles.caption),
                              ])),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.green, size: 22),
                        ]),
                      ),
                    )),
              const SizedBox(height: 12),
              const Text('ALL SUBJECTS', style: AppTextStyles.eyebrow),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 8,
                  runSpacing: 9,
                  children: state.subjects
                      .map((subject) => ActionChip(
                            label: Text(subject.name,
                                style: const TextStyle(
                                    color: AppColors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: AppColors.mint,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22)),
                            onPressed: () {
                              ref
                                  .read(studyLinkProvider.notifier)
                                  .selectSubject(subject.name, id: subject.id);
                              context.push('/tutors');
                            },
                          ))
                      .toList()),
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
