import 'package:flutter/material.dart';

class CaseItem {
  final String title;
  final String subtitle;
  final String code;
  final String tag;
  final Color tagColor;

  const CaseItem({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.tag,
    required this.tagColor,
  });
}
