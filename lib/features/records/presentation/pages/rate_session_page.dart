import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/initials_avatar.dart';

class RateSessionPage extends StatelessWidget {
  const RateSessionPage({this.session, super.key});

  /// The session being rated. Null when opened without one, in which case
  /// the first past session that has not been rated yet is used.
  final StudySession? session;

  static const feedbackOptions = [
    'Clear explanations',
    'Patient',
    'On time',
    'Well prepared',
    'Easy to ask questions',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    final current =
        session ??
        state.sessions.firstWhere(
          (s) => !s.isUpcoming && !s.isRated,
          orElse: () => state.sessions.first,
        );
    final firstName = current.tutorName.split(' ').first;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.close_rounded, size: 21),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: InitialsAvatar(
                            initials: current.initials,
                            backgroundColor: AppColors.mintDark,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'How was your session with $firstName?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${current.subject} · ${current.day} ${current.date} · ${current.mode}',
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final selected = index < state.rating;
                            return IconButton(
                              onPressed: () => context
                                  .read<StudyLinkCubit>()
                                  .setRating(index + 1),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 42,
                                minHeight: 48,
                              ),
                              icon: Icon(
                                selected
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 34,
                                color: selected
                                    ? AppColors.star
                                    : const Color(0xFF9AA19C),
                              ),
                            );
                          }),
                        ),
                        Center(
                          child: Text(
                            state.rating >= 4
                                ? 'Helpful'
                                : state.rating == 3
                                ? 'Good'
                                : 'Could be better',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 21),
                        const Text(
                          'Did you get unstuck?',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Yes', 'Partly', 'No'].map((answer) {
                            final selected = state.unstuckAnswer == answer;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 7),
                                child: SizedBox(
                                  height: 43,
                                  child: OutlinedButton(
                                    onPressed: () => context
                                        .read<StudyLinkCubit>()
                                        .setUnstuckAnswer(answer),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: selected
                                          ? AppColors.green
                                          : Colors.white,
                                      foregroundColor: selected
                                          ? Colors.white
                                          : AppColors.text,
                                      side: BorderSide(
                                        color: selected
                                            ? AppColors.green
                                            : AppColors.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    child: Text(answer),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'What went well?',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: feedbackOptions.map((value) {
                            final selected = state.feedbackTags.contains(value);
                            return FilterChip(
                              label: Text(
                                value,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.greenDark
                                      : AppColors.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: selected,
                              onSelected: (_) => context
                                  .read<StudyLinkCubit>()
                                  .toggleFeedbackTag(value),
                              selectedColor: AppColors.mint,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.green
                                    : AppColors.border,
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Anything else? ',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: '(optional)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: state.extraFeedback,
                          onChanged: context
                              .read<StudyLinkCubit>()
                              .setExtraFeedback,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'A short note for $firstName',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                  child: AppButton(
                    label: 'Submit rating',
                    onPressed: () {
                      context.read<StudyLinkCubit>().submitRating(current.id);
                      context.pop();
                    },
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
