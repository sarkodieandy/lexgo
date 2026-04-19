import 'package:flutter/material.dart';

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color? iconColor;
  final VoidCallback? onTap;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    this.iconColor,
    this.onTap,
  });
}
