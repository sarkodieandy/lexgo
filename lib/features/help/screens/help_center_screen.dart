import 'package:flutter/material.dart';
import 'get_started_screen.dart';
import 'case_help_screen.dart';
import 'quiz_help_screen.dart';
import 'ask_ai_help_screen.dart';
import 'courses_help_screen.dart';
import 'take_notes_help_screen.dart';
import 'help_center_search_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Chat Icon
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Color(0xFF0B162C),
                    ),
                    const SizedBox(height: 16),

                    // Header Text
                    const Text(
                      'How can we Help?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HelpCenterSearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const TextField(
                          enabled:
                              false, // Disables text input allowing InkWell tap
                          decoration: InputDecoration(
                            hintText: 'Search Help Center',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF0B162C),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Topics Label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Help Topics',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748), // Dark slate text color
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Topics List
                    _buildHelpTopicRow(
                      Icons.outlined_flag,
                      'Get Started',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GetStartedScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildHelpTopicRow(
                      Icons.work_outline,
                      'Cases',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaseHelpScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildHelpTopicRow(
                      Icons.access_time,
                      'Quiz',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizHelpScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildHelpTopicRow(
                      Icons.menu_book,
                      'Courses',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CoursesHelpScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildHelpTopicRow(
                      Icons.language,
                      'Ask AI',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AskAiHelpScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildHelpTopicRow(
                      Icons.auto_stories,
                      'Take Notes',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TakeNotesHelpScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white),
              child: ElevatedButton(
                onPressed: () => _showContactOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B162C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTopicRow(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B162C), size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContactOption(
                  icon: Icons.chat_outlined,
                  label: 'Chat with Us',
                  onTap: () => Navigator.pop(context),
                ),
                _buildContactOption(
                  icon: Icons.mail_outline,
                  label: 'Send an Email',
                  onTap: () => Navigator.pop(context),
                ),
                _buildContactOption(
                  icon: Icons.phone_outlined,
                  label: 'Call Us',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B162C), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0B162C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
