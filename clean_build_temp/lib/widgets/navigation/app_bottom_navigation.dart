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
    _NavigationItem(icon: Icons.home_filled, label: 'Home'),
    _NavigationItem(icon: Icons.work_outline, label: 'Cases'),
    _NavigationItem(icon: Icons.access_time, label: 'Quiz'),
    _NavigationItem(icon: Icons.menu_book_outlined, label: 'Courses'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
    final color = selected ? Colors.black : const Color(0xFF868282);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
