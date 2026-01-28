import 'package:flutter/material.dart';

import '../../models/course_assignment.dart';
import '../../theme/app_colors.dart';
import 'course_assignment_card.dart';

class CourseAssignmentsSection extends StatelessWidget {
  const CourseAssignmentsSection({super.key, required this.assignments});

  final List<CourseAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, size: 18, color: AppColors.mutedText),
                    SizedBox(width: 8),
                    Text(
                      'Search assignments…',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: AppColors.brandWhite),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...assignments.map(
          (assignment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CourseAssignmentCard(assignment: assignment),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
