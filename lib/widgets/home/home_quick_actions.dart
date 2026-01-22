import 'package:flutter/material.dart';

import '../../models/home/quick_action.dart';
import '../../theme/app_colors.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.actions,
  });

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDark,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions
                    .map(
                      (action) => SizedBox(
                        width: width,
                        child: _QuickActionCard(action: action),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.actionTile,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: AppColors.brandDark),
          ),
          const SizedBox(height: 12),
          Text(
            action.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
