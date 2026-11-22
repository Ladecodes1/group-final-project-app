import 'package:material_ui/material_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

Future<void> showStudyLinkMessage(BuildContext context,
    {required String title, required String message, String action = 'OK'}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(title, style: AppTextStyles.section),
      content: Text(message, style: AppTextStyles.body),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(action,
                style: const TextStyle(
                    color: AppColors.green, fontWeight: FontWeight.w700)))
      ],
    ),
  );
}
