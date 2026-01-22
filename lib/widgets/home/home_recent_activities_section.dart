import 'package:flutter/material.dart';

import '../../models/home/activity_item.dart';
import '../../theme/app_colors.dart';

class HomeRecentActivities extends StatelessWidget {
  const HomeRecentActivities({
    super.key,
    required this.activities,
  });

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Column(
          children: activities
              .map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ActivityTile(activity: activity),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.activity});

  final ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activity.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.icon, color: AppColors.brandDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.detail,
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            activity.time,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
