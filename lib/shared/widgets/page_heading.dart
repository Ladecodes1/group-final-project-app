import 'package:material_ui/material_ui.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(
      {required this.title,
      this.subtitle,
      this.onBack,
      this.trailing,
      super.key});
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 44),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.text),
          ),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.pageTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: AppTextStyles.caption.copyWith(fontSize: 13))
          ],
        ])),
        if (trailing != null) trailing!,
      ]);
}
