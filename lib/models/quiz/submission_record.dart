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
}
