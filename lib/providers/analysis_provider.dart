import 'package:flutter/material.dart';

import '../models/analysis/score_metric.dart';
import '../models/analysis/score_distribution_item.dart';
import '../models/analysis/pie_segment.dart';
import '../models/analysis/top_performer.dart';

class AnalysisProvider extends ChangeNotifier {
  AnalysisProvider();

  List<ScoreMetric> get metrics => const [
    ScoreMetric(
      label: 'Lowest Score',
      value: '30.4%',
      icon: Icons.arrow_downward,
      color: Color(0xFFFF3D71),
    ),
    ScoreMetric(
      label: 'Avg Score',
      value: '78.5%',
      icon: Icons.bar_chart,
      color: Color(0xFF0D0D0D),
    ),
    ScoreMetric(
      label: 'Highest Score',
      value: '97%',
      icon: Icons.arrow_upward,
      color: Color(0xFF32CD32),
    ),
  ];

  List<ScoreDistributionItem> get scoreDistribution => const [
    ScoreDistributionItem('0-50', 150),
    ScoreDistributionItem('51-60', 120),
    ScoreDistributionItem('61-70', 230),
    ScoreDistributionItem('71-80', 310),
    ScoreDistributionItem('81-90', 150),
    ScoreDistributionItem('91-100', 70),
  ];

  List<PieSegment> get pieSegments => const [
    PieSegment(label: '91-100', percent: 32, color: Color(0xFF0D6EFD)),
    PieSegment(label: '81-90', percent: 15.4, color: Color(0xFF198754)),
    PieSegment(label: '71-80', percent: 32, color: Color(0xFF0DCAF0)),
    PieSegment(label: '61-70', percent: 14.3, color: Color(0xFFFFC107)),
    PieSegment(label: '51-60', percent: 8.0, color: Color(0xFFFD7E14)),
  ];

  List<TopPerformer> get topPerformers => const [
    TopPerformer(name: 'Elkanah Wiseman', id: '22153123', score: 18, total: 20),
    TopPerformer(name: 'Andrew Kaine', id: '22153145', score: 17, total: 20),
    TopPerformer(name: 'Kofi Ajaho', id: '22153467', score: 16, total: 20),
  ];
}
