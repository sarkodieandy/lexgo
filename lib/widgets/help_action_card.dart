import 'package:flutter/material.dart';

import '../models/help_center/help_center_option.dart';
import '../theme/app_colors.dart';

class HelpActionCard extends StatelessWidget {
  const HelpActionCard({super.key, required this.option});

  final HelpCenterOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(option.icon, size: 48, color: AppColors.brandDark),
          const SizedBox(height: 16),
          Text(
            option.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.brandDark),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: Text(option.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
