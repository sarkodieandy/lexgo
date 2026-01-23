import 'package:flutter/material.dart';

import '../../../models/quiz/submission_record.dart';
import '../../../theme/app_colors.dart';

class SubmissionTile extends StatelessWidget {
  const SubmissionTile({super.key, required this.record});

  final SubmissionRecord record;

  @override
  Widget build(BuildContext context) {
    final initials = record.name.isNotEmpty ? record.name.trim().substring(0, 1) : '?';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: record.avatarColor,
                child: Text(
                  initials,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.brandWhite),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.id,
                      style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${record.score}/${record.total}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 14, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                'Correct Answer: ${record.correctAnswers}/${record.total}',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                'Submitted ${record.submittedAt}',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timer, size: 14, color: AppColors.mutedText),
              const SizedBox(width: 6),
              Text(
                'Time Taken : ${record.duration}',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
