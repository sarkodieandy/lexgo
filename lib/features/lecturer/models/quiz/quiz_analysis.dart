import 'submission_record.dart';

class QuizAnalysis {
  final double lowestScore;
  final double avgScore;
  final double highestScore;
  final int totalStudents;
  final Map<String, int> scoreDistribution;
  final List<SubmissionRecord> topPerformers;

  const QuizAnalysis({
    required this.lowestScore,
    required this.avgScore,
    required this.highestScore,
    required this.totalStudents,
    required this.scoreDistribution,
    required this.topPerformers,
  });

  factory QuizAnalysis.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final distribution = json['distribution'] as Map<String, dynamic>? ?? {};
    final performers = json['topPerformers'] as List? ?? [];

    return QuizAnalysis(
      lowestScore: (stats['lowest'] as num?)?.toDouble() ?? 0.0,
      avgScore: (stats['average'] as num?)?.toDouble() ?? 0.0,
      highestScore: (stats['highest'] as num?)?.toDouble() ?? 0.0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      scoreDistribution: distribution.map((key, value) => MapEntry(key, (value as num).toInt())),
      topPerformers: performers.map((e) => SubmissionRecord.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // Helper to generate mock data if API fails or returns empty
  factory QuizAnalysis.mock() {
    return QuizAnalysis(
      lowestScore: 30.4,
      avgScore: 78.5,
      highestScore: 97.0,
      totalStudents: 200,
      scoreDistribution: {
        '0-50': 160,
        '51-60': 120,
        '61-70': 220,
        '71-80': 310,
        '81-90': 155,
        '91-100': 65,
      },
      topPerformers: [], // Will be empty in mock
    );
  }
}
