import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.message, required this.actionLabel, required this.onAction, this.icon = Icons.search_off_rounded, super.key});
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 30, backgroundColor: AppColors.mint, child: Icon(icon, color: AppColors.green, size: 28)),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.text)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
            const SizedBox(height: 20),
            AppButton(label: actionLabel, onPressed: onAction),
          ]),
        ),
      );
}
