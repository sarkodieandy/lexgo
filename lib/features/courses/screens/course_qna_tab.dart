import 'package:flutter/material.dart';

class CourseQnATab extends StatefulWidget {
  const CourseQnATab({super.key});

  @override
  State<CourseQnATab> createState() => _CourseQnATabState();
}

class _CourseQnATabState extends State<CourseQnATab> {
  final List<Map<String, String>> _questions = [
    {
      'author': 'Dr. Johnson',
      'content': "Please I don't Understand the meaning of the Separation of Powers in the 1992 Constitution.",
      'time': '2 mins ago',
      'initials': 'DJ',
      'color': '0xFFF59E0B',
    },
    {
      'author': 'Sarah Mensah',
      'content': 'Will the mid-sem exams cover the entire Chapter 5?',
      'time': '1 hour ago',
      'initials': 'SM',
      'color': '0xFF3B82F6',
    },
    {
      'author': 'Kofi Adams',
      'content': 'Can someone share the link to the case study on Republic v. Mensah?',
      'time': '3 hours ago',
      'initials': 'KA',
      'color': '0xFF10B981',
    },
  ];

  void _showAddQuestionDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Question'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Type your question here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _questions.insert(0, {
                    'author': 'You',
                    'content': controller.text.trim(),
                    'time': 'Just now',
                    'initials': 'ME',
                    'color': '0xFF0F172A',
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
            ),
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _questions.isEmpty
          ? const Center(child: Text('No questions yet. Be the first to ask!'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(int.parse(q['color']!)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          q['initials']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      q['author']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['content']!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            q['time']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Implementation for viewing thread details
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuestionDialog,
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
