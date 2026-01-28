import 'package:flutter/material.dart';

import '../../models/assignment_submission.dart';
import '../../theme/app_colors.dart';

class AssignmentSubmissionCard extends StatelessWidget {
  const AssignmentSubmissionCard({super.key, required this.submission});

  final AssignmentSubmission submission;

  bool get _isGraded => submission.status == SubmissionStatus.graded;

  Color get _badgeColor =>
      _isGraded ? const Color(0xFFFEE8F0) : const Color(0xFFFFF7DF);

  Color get _badgeTextColor =>
      _isGraded ? const Color(0xFFC81D62) : const Color(0xFFB08700);

  String get _statusLabel => _isGraded ? 'Graded' : 'pending';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F1F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surface,
                child: Text(
                  submission.studentName[0],
                  style: const TextStyle(
                    color: AppColors.brandDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      submission.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${submission.studentId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _badgeTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  submission.score != '--'
                      ? Text(
                          submission.score,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandDark,
                          ),
                        )
                      : const SizedBox(height: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.insert_drive_file,
            text: submission.fileName,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            icon: Icons.calendar_today,
            text: submission.submittedAt,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(icon: Icons.access_time, text: submission.dueTime),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
