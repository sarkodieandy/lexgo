import 'package:flutter/material.dart';

import '../../models/home/assignment_progress.dart';
import '../../theme/app_colors.dart';

class HomeAssignmentStats extends StatelessWidget {
  const HomeAssignmentStats({
    super.key,
    required this.categories,
  });

  final List<AssignedCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final category = categories.first;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Assignment Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            category.subject,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...category.assignments.map(
            (assignment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AssignmentProgressTile(progress: assignment),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignmentProgressTile extends StatelessWidget {
  const AssignmentProgressTile({super.key, required this.progress});

  final AssignmentProgress progress;

  @override
  Widget build(BuildContext context) {
    final total = progress.total > 0 ? progress.total.toDouble() : 1.0;
    final value = progress.completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${progress.title}: ${progress.description}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${progress.completed}/${progress.total}',
              style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            color: AppColors.brandBlue,
            backgroundColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}
