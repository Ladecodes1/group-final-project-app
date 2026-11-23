import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';

class TutorProfilePage extends StatelessWidget {
  const TutorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tutor = context.watch<StudyLinkCubit>().state.selectedTutor;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            InitialsAvatar(
                              initials: tutor.initials,
                              backgroundColor: tutor.avatarColor,
                              size: 76,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tutor.name,
                                    style: AppTextStyles.pageTitle.copyWith(
                                      fontSize: 21,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tutor.year} · ${tutor.programme}',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: AppColors.star,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${tutor.rating.toStringAsFixed(1)} · ${tutor.sessions} sessions',
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'CAN HELP WITH',
                          style: AppTextStyles.eyebrow,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 7,
                          runSpacing: 8,
                          children: tutor.subjects
                              .map(
                                (subject) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    subject,
                                    style: const TextStyle(
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 23),
                        const Text('ABOUT', style: AppTextStyles.eyebrow),
                        const SizedBox(height: 8),
                        Text(
                          tutor.about,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 21),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                title: 'Session length',
                                value: '45 minutes',
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: _InfoCard(
                                title: 'Meets',
                                value: 'Campus or online',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'WHAT STUDENTS SAID',
                          style: AppTextStyles.eyebrow,
                        ),
                        const SizedBox(height: 9),
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '“${tutor.testimonial}”',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 9),
                              const Text(
                                'Year 1 student · Sep 2026',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Next open slot',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tutor.nextSlot,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        label: 'See open times',
                        expand: false,
                        onPressed: tutor.fullyBooked
                            ? null
                            : () => context.push('/availability'),
                      ),
                    ],
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(13),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.caption),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
