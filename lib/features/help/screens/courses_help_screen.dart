import 'package:flutter/material.dart';

class CoursesHelpScreen extends StatelessWidget {
  const CoursesHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Topics',
                content:
                    'Here, you\'ll find all the lessons under your selected course. Each topic shows its title and number of pages or sections. You can tap any topic to start reading and track your progress as you go along.',
              ),
              _buildSection(
                title: 'Assignments',
                content:
                    'When your lecturer posts an assignment, it appears right here. You can read the instructions, check the due date, and submit your work directly in the app. Once it\'s graded, you\'ll be able to see your score, feedback, and submission details in the same section.',
              ),
              _buildSection(
                title: 'Test & Quizzes',
                content:
                    'All your course quizzes and tests are displayed here. You can take them directly through the app and view your results once they\'re graded. You\'ll also be able to review your answers and see which ones you got right or wrong.',
              ),
              _buildSection(
                title: 'Resources',
                content:
                    'This is where your lecturer uploads materials for your course such as notes, textbooks, slides, or case documents. You can view or download them anytime to help with your studies.',
              ),
              _buildSection(
                title: 'GradeBook',
                content:
                    'Your GradeBook shows all your scores from assignments, quizzes, and tests in one place. You can quickly check your performance on each task and see how well you\'re doing. Tap the bar chart icon to view detailed insights including score analysis, comparisons, and performance graphs.',
              ),
              _buildSection(
                title: 'Q&A(Questions & Answers)',
                content:
                    'You can ask your lecturer questions about anything you don\'t understand. Your question goes straight to your lecturer, and their reply appears right under it.',
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(
                0xFF000000,
              ), // Pure black matching the mockup headers
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
