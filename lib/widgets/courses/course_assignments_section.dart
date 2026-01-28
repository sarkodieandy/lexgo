import 'package:flutter/material.dart';

import '../../models/course_assignment.dart';
import '../../models/submission_filters.dart';
import '../../theme/app_colors.dart';
import '../../screens/assignment_search_screen.dart';
import '../assignments/filter_sort_sheet.dart';
import 'course_assignment_card.dart';

class CourseAssignmentsSection extends StatelessWidget {
  const CourseAssignmentsSection({
    super.key,
    required this.assignments,
    this.onAssignmentTap,
  });

  final List<CourseAssignment> assignments;
  final ValueChanged<CourseAssignment>? onAssignmentTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AssignmentSearchScreen(),
                  ),
                ),
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
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _showFilterSheet(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: AppColors.brandWhite),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...assignments.map(
          (assignment) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CourseAssignmentCard(
              assignment: assignment,
              onTap: onAssignmentTap,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AssignmentFilterSortSheet(
        initialFilter: SubmissionFilter.all,
        initialSort: SubmissionSort.alphabetical,
      ),
    );
  }
}
