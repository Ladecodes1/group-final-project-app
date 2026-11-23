import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.label});
  final String? label;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: AppColors.green,
          strokeWidth: 2.5,
        ),
        if (label != null) ...[
          const SizedBox(height: 12),
          Text(label!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ],
    ),
  );
}
