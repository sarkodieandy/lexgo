import 'package:flutter/material.dart';
import 'get_started_screen.dart';
import 'case_help_screen.dart';
import 'quiz_help_screen.dart';
import 'ask_ai_help_screen.dart';
import 'courses_help_screen.dart';
import 'take_notes_help_screen.dart';

class HelpCenterSearchScreen extends StatefulWidget {
  const HelpCenterSearchScreen({super.key});

  @override
  State<HelpCenterSearchScreen> createState() => _HelpCenterSearchScreenState();
}

class _HelpCenterSearchScreenState extends State<HelpCenterSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock search history exactly matching the provided user image
  final List<String> _searchHistory = [
    'Taking Quiz',
    'Review Answers',
    'Assignments',
    'Resources',
    'view Grades',
  ];

  // Helper Topics mapping keyword phrases to the screens they represent
  final List<Map<String, dynamic>> _helpTopics = [
    {
      'title': 'Get Started',
      'keywords': [
        'welcome',
        'sign in',
        'features',
        'companion',
        'how it works',
      ],
      'screen': const GetStartedScreen(),
    },
    {
      'title': 'Cases',
      'keywords': [
        'law cases',
        'citation',
        'coram',
        'date of judgment',
        'holding',
        'facts',
        'issues',
      ],
      'screen': const CaseHelpScreen(),
    },
    {
      'title': 'Quiz',
      'keywords': [
        'taking quiz',
        'review answers',
        'difficulty level',
        'number of questions',
        'ai assistance',
      ],
      'screen': const QuizHelpScreen(),
    },
    {
      'title': 'Courses',
      'keywords': [
        'assignments',
        'resources',
        'view grades',
        'topics',
        'test & quizzes',
        'q&a',
      ],
      'screen': const CoursesHelpScreen(),
    },
    {
      'title': 'Ask AI',
      'keywords': ['ai assistant', 'educational purposes', 'chat', 'model'],
      'screen': const AskAiHelpScreen(),
    },
    {
      'title': 'Take Notes',
      'keywords': ['create notes', 'edit notes', 'delete note', 'share note'],
      'screen': const TakeNotesHelpScreen(),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _removeHistoryItem(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
  }

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;

    // Optional: Add to history if unique
    if (!_searchHistory.contains(query.trim())) {
      setState(() {
        _searchHistory.insert(0, query.trim());
      });
    }

    // Force exact string injection for UI processing
    _searchController.text = query;
    _onSearchChanged(query);
  }

  List<Map<String, dynamic>> get _filteredResults {
    if (_searchQuery.trim().isEmpty) return [];

    final lowerQuery = _searchQuery.toLowerCase().trim();
    return _helpTopics.where((topic) {
      final titleMatch = topic['title'].toString().toLowerCase().contains(
        lowerQuery,
      );
      final keywords = List<String>.from(topic['keywords']);
      final keywordMatch = keywords.any(
        (k) => k.toLowerCase().contains(lowerQuery),
      );

      return titleMatch || keywordMatch;
    }).toList();
  }

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
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: true,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search help Center',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: Color(0xFF0B162C),
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searchQuery.isEmpty) ...[
                const Text(
                  'Search History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchHistory.length,
                    itemBuilder: (context, index) {
                      final historyItem = _searchHistory[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _executeSearch(historyItem),
                                child: Text(
                                  historyItem,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _removeHistoryItem(historyItem),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Text(
                  'Search Results for "$_searchQuery"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _filteredResults.isEmpty
                      ? Center(
                          child: Text(
                            'No results found.\nTry a different keyword.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredResults.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = _filteredResults[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.article_outlined,
                                color: Color(0xFF0B162C),
                              ),
                              title: Text(
                                result['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        result['screen'] as Widget,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
