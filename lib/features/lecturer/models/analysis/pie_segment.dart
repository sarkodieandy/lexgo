import 'package:flutter/material.dart';

class PieSegment {
  const PieSegment({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final double percent;
  final Color color;
}
