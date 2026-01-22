import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.brandWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          HomeNavItem(icon: Icons.home, label: 'Home', selected: true),
          HomeNavItem(icon: Icons.work_outline, label: 'Cases'),
          HomeNavItem(icon: Icons.quiz_outlined, label: 'Quiz'),
          HomeNavItem(icon: Icons.menu_book_outlined, label: 'Courses'),
        ],
      ),
    );
  }
}

class HomeNavItem extends StatelessWidget {
  const HomeNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brandBlue : AppColors.mutedText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
