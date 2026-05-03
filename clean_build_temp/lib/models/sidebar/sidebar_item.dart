import 'package:flutter/material.dart';

class SidebarItem {
  final String label;
  final IconData icon;
  final bool selected;
  final bool hasBadge;

  const SidebarItem({
    required this.label,
    required this.icon,
    this.selected = false,
    this.hasBadge = false,
  });
}
