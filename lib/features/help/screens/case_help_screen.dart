import 'package:flutter/material.dart';

class CaseHelpScreen extends StatelessWidget {
  const CaseHelpScreen({super.key});

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
              // Main Title 1
              const Text(
                'Understanding Case\nSummaries',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Introduction Paragraph
              Text(
                'Reading and analyzing legal cases can feel overwhelming, especially if you are new to law studies. '
                'Each case is broken down into specific sections to help you understand the background, the questions '
                'before the court, the decision, and why it matters. '
                'This guide explains what each section of a case summary means so that you can follow along more '
                'easily and get the most out of your reading. Use it whenever you need clarity on how cases are '
                'structured in the app.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Main Title 2
              const Text(
                'Case Sessions Explained',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 24),

              // Detailed Sections
              _buildSection(
                title: 'Case Title',
                content:
                    'The official name of the case, usually written as Person A v. Person B (civil cases) or The Republic v. Person (criminal cases).\nExample: Republic v. Mensah',
              ),
              _buildSection(
                title: 'Court & Citation',
                content:
                    'The court that decided the case and the official reference for locating the case in law reports.',
              ),
              _buildSection(
                title: 'Date of Judgment',
                content:
                    'The exact day the decision was given. Helps place the case in time.',
              ),
              _buildSection(
                title: 'Coram (Judges)',
                content:
                    'The judges who heard the case. This is important because senior judges\' opinions often guide future rulings.',
              ),
              _buildSection(
                title: 'Parties',
                content:
                    'The people or entities involved. In criminal cases: The Republic (state) v. the accused. In civil cases: Person v. Person.',
              ),
              _buildSection(
                title: 'Facts',
                content:
                    'A short background story of what happened before the case came to court. Helps you understand the context.',
              ),
              _buildSection(
                title: 'Issues',
                content: 'The key legal questions the court had to answer.',
              ),
              _buildSection(
                title: 'Decision/Holding',
                content:
                    'The short answer to the issues — what the court decided.',
              ),
              _buildSection(
                title: 'Reasoning',
                content:
                    'Why the judges made that decision. The explanation of their thought process.',
              ),
              _buildSection(
                title: 'Judgment/Disposition',
                content:
                    'The final outcome (e.g., "appeal dismissed," "defendant acquitted," "conviction upheld").',
              ),
              _buildSection(
                title: 'Significance',
                content:
                    'Explains why the case matters — how it affects future cases, or what principle of law it clarifies.',
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
