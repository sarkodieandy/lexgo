import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_assignments_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/courses/course_assignments_section.dart';
import '../widgets/create_newassignmentfab.dart';
import 'assignment_details_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final topics = [
      'Separation of Powers',
      'Fundamental Rights',
      'Judicial Review',
      'Constitutional Interpretation',
      'Free Speech',
      'Religious Freedom',
    ];
    final subtitles = [
      'Distribution of Authority',
      'Human Rights',
      'Review',
      'Translation',
      'Freedom of speech',
      'African Religion',
    ];
    final assignments = context
        .watch<CourseAssignmentsProvider>()
        .assignmentsFor(course);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.brandDark,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final provider = context.read<CourseAssignmentsProvider>();
            final nextNumber = provider.assignmentsFor(course).length + 1;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CreateNewAssignment(
                course: course,
                assignmentNumber: nextNumber,
                onCreate: (assignment) =>
                    provider.addAssignment(course, assignment),
              ),
            );
          },
          backgroundColor: AppColors.brandDark,
          child: const Icon(Icons.add, color: AppColors.brandWhite),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: AppColors.brandDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.brandNavy,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.brandWhite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            course.title,
                            style: const TextStyle(
                              color: AppColors.brandWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brandWhite,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(
                            'assets/Union.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const TabBar(
                      isScrollable: true,
                      indicatorColor: AppColors.brandWhite,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(text: 'Topics'),
                        Tab(text: 'Assignments'),
                        Tab(text: 'Resources'),
                        Tab(text: 'Q&A'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.brandWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: 80,
                    ),
                    child: TabBarView(
                      children: [
                        ListView.separated(
                          itemCount: topics.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) => _TopicTile(
                            number: index + 1,
                            title: topics[index],
                            subtitle: subtitles[index],
                          ),
                        ),
                        CourseAssignmentsSection(
                          assignments: assignments,
                          onAssignmentTap: (assignment) =>
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AssignmentDetailsScreen(
                                    assignment: assignment,
                                  ),
                                ),
                              ),
                        ),
                        const Center(child: Text('Resources content')),
                        const Center(child: Text('Q&A content')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.brandDark,
            child: Text(
              number.toString(),
              style: const TextStyle(color: AppColors.brandWhite),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.brandDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.brandWhite,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
