import 'package:flutter/material.dart';
import '../../../../models/course_model.dart';
import 'topic_resources_screen.dart';
import 'assignment_submission_screen.dart';
import 'course_topics_tab.dart'; // Import the new topics tab
import 'course_qna_tab.dart';
import 'course_gradebook_tab.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Topics'),
            Tab(text: 'Resources'),
            Tab(text: 'Assignments'),
            Tab(text: 'Test&Quiz'),
            Tab(text: 'GradeBook'),
            Tab(text: 'Q&A'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Topics Tab (Mockup 5.2, 5.3)
          CourseTopicsTab(course: widget.course),

          // Resources Tab (Mockup 5.5)
          const TopicResourcesScreen(),

          // Assignments Tab (Mockup 5.6)
          _buildAssignmentsList(context),

          // Test & Quiz Tab
          _buildTestAndQuizTab(context),

          // GradeBook Tab
          const CourseGradebookTab(),

          // Q&A Tab
          const CourseQnATab(),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context, {
    required String title,
    required String dateStr,
    required String timeStr,
    required String pointsStr,
    required String status,
  }) {
    Color statusBgColor;
    Color statusTextColor;

    switch (status) {
      case 'Submitted':
      case 'In progress':
        statusBgColor = Colors.red.shade50;
        statusTextColor = Colors.red.shade700;
        break;
      case 'Not started':
      default:
        statusBgColor = Colors.orange.shade50;
        statusTextColor = Colors.orange.shade700;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignmentSubmissionScreen(
                  assignmentTitle: title,
                  status: status,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_border, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(pointsStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAssignmentCard(
          context,
          title: 'Essay: The Doctrine of Separation of Powers in Ghana',
          dateStr: 'Due June 13, 2025',
          timeStr: '11:59 PM',
          pointsStr: '20 points',
          status: 'Not started',
        ),
        _buildAssignmentCard(
          context,
          title: 'Case Analysis: Republic v. Mensah',
          dateStr: 'Due June 10, 2025',
          timeStr: '11:50 PM',
          pointsStr: '15 points',
          status: 'Submitted',
        ),
        _buildAssignmentCard(
          context,
          title: 'Quiz 1: Fundamentals of Constitution',
          dateStr: 'Due Oct 29, 2025',
          timeStr: '11:59 PM',
          pointsStr: '10 points',
          status: 'In progress',
        ),
        _buildAssignmentCard(
          context,
          title: 'Group Project: Judicial Review Mechanisms',
          dateStr: 'Due Dec 1, 2025',
          timeStr: '05:00 PM',
          pointsStr: '50 points',
          status: 'Not started',
        ),
      ],
    );
  }

  Widget _buildTestAndQuizTab(BuildContext context) {
    // Sample submitted assessments data matching the screenshot
    final submittedQuizzes = [
      _QuizItem(
        title: 'Quiz one',
        subtitle: "Test Student's General Knowledge",
        dueDate: 'Due Sept 17, 2025',
        dueTime: '10:10 AM',
        questions: '45 Questions',
        duration: '1hr 50Minutes',
      ),
      _QuizItem(
        title: 'Quiz Two',
        subtitle: 'Mid Sem 1',
        dueDate: 'Due Sept 17, 2025',
        dueTime: '10:10 AM',
        questions: '45 Questions',
        duration: '1hr 50Minutes',
      ),
      _QuizItem(
        title: 'Quiz Three',
        subtitle: 'Mid Sem 2',
        dueDate: 'Due Sept 17, 2025',
        dueTime: '10:10 AM',
        questions: '45 Questions',
        duration: '1hr 50Minutes',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Current Assessment ──────────────────────────────────────
        const Text(
          'Current Assessment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You have no Quiz to take',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),

        // ── Submitted Assessments ───────────────────────────────────
        const Text(
          'Submitted Assessments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        ...submittedQuizzes.map((quiz) => _buildQuizCard(quiz)),
      ],
    );
  }

  Widget _buildQuizCard(_QuizItem quiz) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle question-mark icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0B162C), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.question_mark, size: 18, color: Color(0xFF0B162C)),
            ),
          ),
          const SizedBox(width: 12),

          // Quiz details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quiz.subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                _quizMeta(Icons.calendar_today_outlined,
                    '${quiz.dueDate} • ${quiz.dueTime}'),
                const SizedBox(height: 4),
                _quizMeta(Icons.description_outlined, quiz.questions),
                const SizedBox(height: 4),
                _quizMeta(Icons.access_time_outlined, quiz.duration),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizMeta(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

}

// Simple data class for a quiz item
class _QuizItem {
  final String title;
  final String subtitle;
  final String dueDate;
  final String dueTime;
  final String questions;
  final String duration;

  const _QuizItem({
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.dueTime,
    required this.questions,
    required this.duration,
  });
}
