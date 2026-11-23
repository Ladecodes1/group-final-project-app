import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    required this.initials,
    this.backgroundColor = AppColors.beigeAvatar,
    this.size = 48,
    super.key,
  });
  final String initials;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
    child: Text(
      initials,
      style: TextStyle(
        color: const Color(0xFF765A22),
        fontSize: size * .31,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
