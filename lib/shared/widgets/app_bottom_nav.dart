import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.selectedIndex, super.key});
  final int selectedIndex;

  void _go(BuildContext context, int index) {
    const routes = ['/home', '/search', '/sessions'];
    if (index != selectedIndex) context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(children: [
              _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home', selected: selectedIndex == 0, onTap: () => _go(context, 0)),
              _NavItem(icon: Icons.search_rounded, selectedIcon: Icons.search_rounded, label: 'Find', selected: selectedIndex == 1, onTap: () => _go(context, 1)),
              _NavItem(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded, label: 'Sessions', selected: selectedIndex == 2, onTap: () => _go(context, 2)),
            ]),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.selectedIcon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: SizedBox.expand(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(selected ? selectedIcon : icon, color: selected ? AppColors.green : AppColors.textSecondary, size: 23),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.green : AppColors.textSecondary)),
            ]),
          ),
        ),
      );
}
