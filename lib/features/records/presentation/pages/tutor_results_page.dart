import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../widgets/tutor_result_card.dart';

class TutorResultsPage extends StatelessWidget {
  const TutorResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    final filter = state.tutorFilter;
    final subject = state.selectedSubject.toLowerCase();
    final results = sampleTutors
        .where(
          (t) => t.subjects.any(
            (s) =>
                s.toLowerCase().contains(subject) ||
                subject.contains(s.toLowerCase()),
          ),
        )
        .toList();
    final countLabel = state.selectedSubject == 'Data Structures & Algorithms'
        ? '6 peer tutors'
        : '${results.length} peer tutors';
    final visible = results; // Keep booked tutors visible as muted cards, as in the Figma prototype.

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 44,
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.selectedSubject,
                              style: AppTextStyles.pageTitle.copyWith(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '$countLabel · all passed this course',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    children: ['Free this week', 'In person', 'Online'].map((
                      value,
                    ) {
                      final selected = filter == value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(value),
                          selected: selected,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          selectedColor: AppColors.green,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: selected
                                ? AppColors.green
                                : AppColors.border,
                          ),
                          onSelected: (_) => context
                              .read<StudyLinkCubit>()
                              .setTutorFilter(value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: visible.isEmpty
                      ? EmptyState(
                          title: 'No tutors found',
                          message: 'Try another subject or broaden your search to find a peer who can help.',
                          actionLabel: 'Back to search',
                          onAction: () => context.pushReplacement('/search'),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 2, 18, 24),
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 11),
                          itemBuilder: (context, index) => TutorResultCard(
                            tutor: visible[index],
                            onTap: () {
                              context.read<StudyLinkCubit>().selectTutor(
                                visible[index],
                              );
                              context.push('/tutor-profile');
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
