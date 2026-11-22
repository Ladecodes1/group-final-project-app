import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/tutor_result_card.dart';

final tutorFilterProvider = StateProvider<String>((ref) => 'Free this week');

class TutorResultsPage extends ConsumerStatefulWidget {
  const TutorResultsPage({super.key});

  @override
  ConsumerState<TutorResultsPage> createState() => _TutorResultsPageState();
}

class _TutorResultsPageState extends ConsumerState<TutorResultsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyLinkProvider.notifier).loadTutors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyLinkProvider);
    final filter = ref.watch(tutorFilterProvider);
    final results = state.tutors;
    final visible = switch (filter) {
      'Free this week' => results,
      'In person' =>
        results.where((tutor) => tutor.modes.contains('On campus')).toList(),
      'Online' =>
        results.where((tutor) => tutor.modes.contains('Online')).toList(),
      _ => results,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            child: Row(children: [
              IconButton(
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 36, height: 44),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19)),
              const SizedBox(width: 5),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(state.selectedSubject,
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 20)),
                    Text(
                        '${results.length} peer tutors · students who passed this course',
                        style: AppTextStyles.caption.copyWith(fontSize: 12)),
                  ])),
            ]),
          ),
          SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children:
                    ['Free this week', 'In person', 'Online'].map((value) {
                  final selected = filter == value;
                  return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(value),
                        selected: selected,
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                        selectedColor: AppColors.green,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                            color:
                                selected ? AppColors.green : AppColors.border),
                        onSelected: (_) => ref
                            .read(tutorFilterProvider.notifier)
                            .state = value,
                      ));
                }).toList(),
              )),
          const SizedBox(height: 10),
          Expanded(
              child: state.isLoadingTutors
                  ? const LoadingIndicator()
                  : visible.isEmpty
                      ? EmptyState(
                          title: 'No tutors found',
                          message:
                              'Try another subject or broaden your search to find a peer who can help.',
                          actionLabel: 'Back to search',
                          onAction: () => context.go('/search'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 11),
                          itemBuilder: (context, index) => TutorResultCard(
                            tutor: visible[index],
                            onTap: () {
                              ref
                                  .read(studyLinkProvider.notifier)
                                  .selectTutor(visible[index]);
                              context.push('/tutor-profile');
                            },
                          ),
                        )),
        ]),
      ))),
    );
  }
}
