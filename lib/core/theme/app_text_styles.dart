import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 27,
    height: 1.12,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  static const pageTitle = TextStyle(
    color: AppColors.text,
    fontSize: 25,
    height: 1.18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );
  static const section = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );
  static const caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );
  static const eyebrow = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
  static const button = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
}
