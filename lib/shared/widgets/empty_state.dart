import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.green,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTextStyles.section,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              expand: false,
              style: AppButtonStyle.secondary,
            ),
          ],
        ],
      ),
    ),
  );
}
