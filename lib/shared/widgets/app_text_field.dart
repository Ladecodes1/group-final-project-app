import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.hintText,
    this.labelText,
    this.initialValue,
    this.onChanged,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    super.key,
  });
  final String? hintText;
  final String? labelText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue,
    onChanged: onChanged,
    obscureText: obscureText,
    maxLines: obscureText ? 1 : maxLines,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    style: const TextStyle(fontSize: 14, color: AppColors.text),
    decoration: InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      alignLabelWithHint: maxLines > 1,
    ),
  );
}
