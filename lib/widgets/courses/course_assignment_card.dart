import 'package:flutter/material.dart';

import '../../models/course_assignment.dart';
import '../../theme/app_colors.dart';

class CourseAssignmentCard extends StatelessWidget {
  const CourseAssignmentCard({super.key, required this.assignment});

  final CourseAssignment assignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 20,
                  color: AppColors.brandDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            assignment.description,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CourseAssignmentInfoChip(
                icon: Icons.calendar_month,
                label: assignment.dueDateLabel,
              ),
              _CourseAssignmentInfoChip(
                icon: Icons.access_time,
                label: assignment.dueTime,
              ),
              _CourseAssignmentInfoChip(
                icon: Icons.stacked_line_chart,
                label: assignment.pointsLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseAssignmentInfoChip extends StatelessWidget {
  const _CourseAssignmentInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mutedText),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
