import 'package:material_ui/material_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonStyle { primary, secondary, danger, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.icon,
    this.height = 52,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final IconData? icon;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label, textAlign: TextAlign.center)
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ]);
    final button = SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: switch (style) {
        AppButtonStyle.primary => FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.green.withValues(alpha: .4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
              textStyle: AppTextStyles.button,
            ),
            onPressed: onPressed,
            child: child,
          ),
        AppButtonStyle.secondary => OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            onPressed: onPressed,
            child: child,
          ),
        AppButtonStyle.danger => FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
              textStyle: AppTextStyles.button,
            ),
            onPressed: onPressed,
            child: child,
          ),
        AppButtonStyle.text => TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.green,
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              minimumSize: const Size(48, 48),
            ),
            onPressed: onPressed,
            child: child,
          ),
      },
    );
    return button;
  }
}
