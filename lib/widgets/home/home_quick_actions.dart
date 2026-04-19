import 'package:flutter/material.dart';
import '../../models/home/quick_action.dart';
import '../../theme/app_colors.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brandDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: actions
              .map((action) => _QuickActionCard(action: action))
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: action.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.iconColor ?? AppColors.brandDark, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              action.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              action.subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
