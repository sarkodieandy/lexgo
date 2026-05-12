import 'package:flutter/material.dart';

class ActivityItem {
  final String title;
  final String detail;
  final String time;
  final IconData icon;
  final Color iconBackground;

  const ActivityItem({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
    required this.iconBackground,
  });
}
