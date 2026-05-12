import 'package:flutter/material.dart';

import '../../models/course_assignment.dart';
import '../../theme/app_colors.dart';

class CourseAssignmentScreen extends StatelessWidget {
  const CourseAssignmentScreen({super.key});

  static final _sampleAssignments = List.generate(
    4,
    (index) => CourseAssignment(
      id: 'sample-${index + 1}',
      title: 'Assignment ${index + 1}',
      description: 'Review key concepts and submit your answers.',
      dueDate: DateTime(2025, 10, 30 + index),
      dueTime: '11:59 PM',
      points: 10 + index * 5,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020F20),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2138),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.brandWhite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.brandWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: AppColors.brandDark),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '|Search assignments... ',
                              style: TextStyle(
                                color: AppColors.brandDark,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(Icons.mic, color: AppColors.brandDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Assignments',
                style: TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.brandWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: _sampleAssignments
                      .map(
                        (assignment) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: _AssignmentTile(assignment: assignment),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.assignment});

  final CourseAssignment assignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFEEF2FF),
          child: const Icon(
            Icons.assignment_outlined,
            color: AppColors.brandDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                assignment.description,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_month,
                    label: assignment.dueDateLabel,
                  ),
                  _InfoChip(icon: Icons.access_time, label: assignment.dueTime),
                  _InfoChip(
                    icon: Icons.stacked_line_chart,
                    label: assignment.pointsLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mutedText),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
