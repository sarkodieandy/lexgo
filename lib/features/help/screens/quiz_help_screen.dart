import 'package:flutter/material.dart';

class QuizHelpScreen extends StatelessWidget {
  const QuizHelpScreen({super.key});

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
                title: 'Overview',
                titleFontSize: 24,
                content:
                    'The Quiz feature helps you test your knowledge across different legal topics. Choose a topic, select a difficulty level, and answer a set of questions designed to strengthen your understanding of key legal principles.',
              ),
              _buildSection(
                title: 'Selecting a Legal Topic',
                titleFontSize: 20,
                content:
                    'Start by choosing a Legal Topic from the list provided such as Contract Law, Criminal Law, or Constitutional Law. Each topic focuses on a particular area of study, allowing you to practice and master one subject at a time.',
              ),
              _buildSection(
                title: 'Choosing Difficulty Level',
                titleFontSize: 20,
                content:
                    'You can select from three difficulty levels depending on your comfort and experience. Each level adjusts the question types and depth of reasoning required, helping you learn progressively',
              ),
              _buildSection(
                title: 'Setting Number of Questions',
                titleFontSize: 20,
                content:
                    'Decide how many questions you want in your quiz This flexibility lets you take a quick test or a full-length challenge depending on your available time.',
              ),
              _buildSection(
                title: 'Starting the Quiz',
                titleFontSize: 20,
                content:
                    'Once your preferences are selected, tap Start Quiz to begin. Each question will appear one at a time, often with multiple-choice answers. You can skip and return to unanswered questions before submitting.',
              ),
              _buildSection(
                title: 'Reviewing Your Answers',
                titleFontSize: 20,
                content:
                    'After completing the quiz, you can review your questions and see which answers were correct or incorrect. The app highlights your score, explanations for correct answers, and areas to improve.',
              ),
              _buildSection(
                title: 'Need Help with a Question?',
                titleFontSize: 20,
                content:
                    'If you find a question confusing, tap "Ask AI" for instant clarification. LexGo\'s AI will explain the question, provide reasoning behind the right answer, and simplify complex legal terms.',
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
    double titleFontSize = 16,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B162C),
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
