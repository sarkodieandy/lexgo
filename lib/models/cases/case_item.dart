import 'package:flutter/material.dart';

import '../../services/cases_service.dart';

class CaseItem {
  const CaseItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.tag,
    required this.tagColor,
    this.documentUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String tag;
  final Color tagColor;
  final String? documentUrl;

  factory CaseItem.fromModel(CaseModel model) {
    return CaseItem(
      id: model.id,
      title: model.title,
      subtitle: model.sourceOfCase,
      code: model.caseCode,
      tag: model.caseCategory,
      tagColor: _colorForCategory(model.caseCategory),
      documentUrl: model.documentUrl,
    );
  }

  static Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'constitutional law':
        return const Color(0xFF6366F1);
      case 'contract law':
        return const Color(0xFF0A5C20);
      case 'criminal law':
        return const Color(0xFFD14234);
      case 'administrative law':
        return const Color(0xFFB45309);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
