import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int>? onTap;

  static const _items = [
    _NavigationItem(icon: Icons.home_outlined, label: 'Home'),
    _NavigationItem(icon: Icons.business_center_outlined, label: 'Cases'),
    _NavigationItem(icon: Icons.access_time_outlined, label: 'Quiz'),
    _NavigationItem(icon: Icons.auto_stories_outlined, label: 'Courses'),
  ];

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
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return Expanded(
            child: InkWell(
              onTap: () => onTap?.call(index),
              child: _AppNavItem(
                icon: item.icon,
                label: item.label,
                selected: selectedIndex == index,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;

  const _NavigationItem({required this.icon, required this.label});
}

class _AppNavItem extends StatelessWidget {
  const _AppNavItem({
    required this.icon,
    required this.label,
    required this.selected,
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
