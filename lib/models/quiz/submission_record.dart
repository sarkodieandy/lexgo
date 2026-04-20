import 'package:flutter/material.dart';

class SubmissionRecord {
  final String name;
  final String id;
  final int score;
  final int total;
  final int correctAnswers;
  final String submittedAt;
  final String duration;
  final Color avatarColor;
  final String category;
  final DateTime submittedAtDate;

  const SubmissionRecord({
    required this.name,
    required this.id,
    required this.score,
    required this.total,
    required this.correctAnswers,
    required this.submittedAt,
    required this.duration,
    required this.avatarColor,
    required this.category,
    required this.submittedAtDate,
  });

  factory SubmissionRecord.fromJson(Map<String, dynamic> json) {
    final submittedAtStr = json['submittedAt'] as String? ?? '';
    final submittedAtDate = DateTime.tryParse(submittedAtStr) ?? DateTime.now();
    
    // Generate a consistent color based on name/id for the avatar
    final id = (json['userId'] as String? ?? json['id'] as String? ?? '');
    final name = (json['userName'] as String? ?? json['name'] as String? ?? 'Student');
    final colors = [
      const Color(0xFF0D6EFD),
      const Color(0xFF198754),
      const Color(0xFF0DCAF0),
      const Color(0xFFFFC107),
      const Color(0xFFFD7E14),
      const Color(0xFFDC3545),
    ];
    final color = colors[id.hashCode % colors.length];

    return SubmissionRecord(
      name: name,
      id: id,
      score: (json['score'] as num?)?.toInt() ?? 0,
      total: (json['totalQuestions'] as num?)?.toInt() ?? (json['total'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? (json['score'] as num?)?.toInt() ?? 0,
      submittedAt: submittedAtStr,
      submittedAtDate: submittedAtDate,
      duration: json['duration'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'Student',
      avatarColor: color,
    );
  }
}
