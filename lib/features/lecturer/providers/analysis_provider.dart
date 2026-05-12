import 'package:flutter/material.dart';
import '../models/analysis/score_metric.dart';
import '../models/analysis/score_distribution_item.dart';
import '../models/analysis/pie_segment.dart';
import '../models/analysis/top_performer.dart';
import '../services/quiz_service.dart';

class AnalysisProvider extends ChangeNotifier {
  AnalysisProvider({QuizService? service}) : _service = service ?? QuizService();

  final QuizService _service;
  bool _isLoading = false;
  String? _error;

  List<ScoreMetric> _metrics = [];
  List<ScoreDistributionItem> _scoreDistribution = [];
  List<PieSegment> _pieSegments = [];
  List<TopPerformer> _topPerformers = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ScoreMetric> get metrics => _metrics;
  List<ScoreDistributionItem> get scoreDistribution => _scoreDistribution;
  List<PieSegment> get pieSegments => _pieSegments;
  List<TopPerformer> get topPerformers => _topPerformers;

  Future<void> loadAnalysis(String quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.fetchQuizAnalysis(quizId);
      
      // Map Metrics
      _metrics = [
        ScoreMetric(
          label: 'Lowest Score',
          value: '${data['lowestScore'] ?? 0}%',
          icon: Icons.arrow_downward,
          color: const Color(0xFFFF3D71),
        ),
        ScoreMetric(
          label: 'Avg Score',
          value: '${data['averageScore'] ?? 0}%',
          icon: Icons.bar_chart,
          color: const Color(0xFF0D0D0D),
        ),
        ScoreMetric(
          label: 'Highest Score',
          value: '${data['highestScore'] ?? 0}%',
          icon: Icons.arrow_upward,
          color: const Color(0xFF32CD32),
        ),
      ];

      // Map Distribution
      final distribution = data['distribution'] as List?;
      if (distribution != null) {
        _scoreDistribution = distribution.map((item) {
          return ScoreDistributionItem(
            item['range'] as String? ?? '',
            (item['count'] as num?)?.toInt() ?? 0,
          );
        }).toList();
        
        // Map Pie Segments from distribution for simplicity or if backend provides them
        _pieSegments = distribution.map((item) {
          final count = (item['count'] as num?)?.toInt() ?? 0;
          final total = _scoreDistribution.fold<int>(0, (sum, e) => sum + e.value);
          final percent = total > 0 ? (count / total * 100) : 0.0;
          
          // Generate colors
          final index = distribution.indexOf(item);
          final colors = [
            const Color(0xFF0D6EFD),
            const Color(0xFF198754),
            const Color(0xFF0DCAF0),
            const Color(0xFFFFC107),
            const Color(0xFFFD7E14),
            const Color(0xFFDC3545),
          ];
          
          return PieSegment(
            label: item['range'] as String? ?? '',
            percent: percent,
            color: colors[index % colors.length],
          );
        }).toList();
      }

      // Map Top Performers
      final performers = data['topPerformers'] as List?;
      if (performers != null) {
        _topPerformers = performers.map((item) {
          return TopPerformer(
            name: item['userName'] as String? ?? item['name'] as String? ?? 'Student',
            id: item['userId'] as String? ?? item['id'] as String? ?? '',
            score: (item['score'] as num?)?.toInt() ?? 0,
            total: (item['totalQuestions'] as num?)?.toInt() ?? 100,
          );
        }).toList();
      }

    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
