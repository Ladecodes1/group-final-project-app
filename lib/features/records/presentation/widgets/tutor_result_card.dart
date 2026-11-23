import 'package:flutter/material.dart';

import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';

class TutorResultCard extends StatelessWidget {
  const TutorResultCard({required this.tutor, required this.onTap, super.key});
  final Tutor tutor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(15),
    onTap: tutor.fullyBooked ? null : onTap,
    color: tutor.fullyBooked ? AppColors.surfaceSoft : Colors.white,
    child: Column(
      children: [
        Row(
          children: [
            InitialsAvatar(
              initials: tutor.initials,
              backgroundColor: tutor.avatarColor,
              size: 50,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutor.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${tutor.year} · ${tutor.programme}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (tutor.fullyBooked)
              const Text(
                'Fully booked',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (tutor.isNew)
              const Text(
                'New tutor',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.star,
                    size: 17,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    tutor.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: AppColors.border),
        ),
        Row(
          children: [
            const Text('Next open slot', style: AppTextStyles.caption),
            const SizedBox(width: 12),
            // Flexible so a long value shrinks instead of overflowing.
            Expanded(
              child: Text(
                tutor.nextSlot,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tutor.fullyBooked
                      ? AppColors.textSecondary
                      : AppColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
