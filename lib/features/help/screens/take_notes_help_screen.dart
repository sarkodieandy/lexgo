import 'package:flutter/material.dart';

class TakeNotesHelpScreen extends StatelessWidget {
  const TakeNotesHelpScreen({super.key});

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
              const Text(
                'Take Notes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'Create Notes',
                content:
                    'Tap the plus (+) icon to make a new note. Add a title, choose your legal topic, and set its importance level. Once saved, it appears instantly in your notes list.',
              ),
              _buildSection(
                title: 'Edit Notes',
                content:
                    'Open any note to make changes. You can update the title, topic, or importance level, and your changes will save automatically — keeping everything up to date.',
              ),
              _buildSection(
                title: 'Delete Note',
                content:
                    'Swipe a note to the left and tap the delete icon to remove it permanently. This helps you keep your notes clean and focused on what you really need.',
              ),
              _buildSection(
                title: 'Share Note',
                content:
                    'You can share your notes directly with friends or classmates through apps like WhatsApp, Instagram, or email. It\'s an easy way to collaborate and help others learn.',
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B162C),
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
