import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

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
              // Main Title
              const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 24),

              // Content Sections
              _buildSection(
                title: 'Welcome to LexGo',
                content:
                    'LexGo helps you learn, practice, and engage with law content through interactive lessons, case studies, and quizzes. Get ready to explore and make learning law easier and fun.',
              ),
              _buildSection(
                title: 'Signing In and Getting Access',
                content:
                    'Use your registered email or school account to sign in. Once logged in, your personalized dashboard will appear, showing all your enrolled courses and key features.',
              ),
              _buildSection(
                title: 'Exploring the Dashboard',
                content:
                    'The dashboard is your main control center. From here, you can access your courses, assignments, quizzes, and cases. Use the tabs at the top to switch between sections easily.',
              ),
              _buildSection(
                title: 'Taking Your First Quiz',
                content:
                    'Go to the Quiz tab to start practicing. Select a quiz, check its duration and number of questions, and begin. Your progress saves automatically until you submit.',
              ),
              _buildSection(
                title: 'Accessing Course Resources',
                content:
                    'Under each course, you\'ll find a Resources tab. Here, your lecturer may upload notes, readings, or videos you can open directly or download for later.',
              ),
              _buildSection(
                title: 'Reading Case Summaries',
                content:
                    'The Cases feature helps you review important legal cases quickly. Each case includes summaries, key points, and related topics to help you study more effectively.',
              ),
              _buildSection(
                title: 'Using the Legal Dictionary',
                content:
                    'Can\'t remember a legal term? Tap Dictionary to look up definitions and meanings instantly. The search works both online and offline.',
              ),
              _buildSection(
                title: 'Ask AI',
                content:
                    'Use the Ask AI tool to get instant explanations or clarifications on legal concepts, case laws, or assignment hints. Simply type your question — the AI will guide you with summarized and easy-to-understand answers.',
              ),
              _buildSection(
                title: 'Meet Your AI Companion',
                content:
                    'Chat naturally with your AI Companion — your personal study buddy. You can type or speak your questions and get quick, conversational answers. It can help you explain topics, summarize cases, or even quiz you verbally.',
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B162C),
            ),
          ),
          const SizedBox(height: 8),
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
