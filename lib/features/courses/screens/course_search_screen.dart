import 'package:flutter/material.dart';
import '../../../../models/course_model.dart';
import 'course_details_screen.dart';

class CourseSearchScreen extends StatefulWidget {
  final List<Course> allCourses;

  const CourseSearchScreen({super.key, required this.allCourses});

  @override
  State<CourseSearchScreen> createState() => _CourseSearchScreenState();
}

class _CourseSearchScreenState extends State<CourseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  // Mock Search History Data
  final List<String> _searchHistory = [
    'Constitutional Law',
    'Contract law',
    'Introduction to Law',
    'Basic Law terms',
    'Write Like a Lawyer',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    // Request focus on init so the keyboard pops up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Course> get _filteredCourses {
    if (_searchQuery.isEmpty) return [];

    return widget.allCourses.where((course) {
      final titleLower = course.title.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();
  }

  void _removeHistoryItem(String item) {
    setState(() {
      _searchHistory.remove(item);
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty && !_searchHistory.contains(query.trim())) {
      setState(() {
        _searchHistory.insert(0, query.trim());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          80.0,
        ), // Custom height for curved appbar
        child: Container(
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0B162C),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Dark blue back button container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              // Search Input Field
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onSubmitted: _onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: '|Search Courses..',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: null, // Removed prefix icon based on mockup
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildSearchHistory()
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchHistory() {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          'Search History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ..._searchHistory.map((item) => _buildHistoryItem(item)),
      ],
    );
  }

  Widget _buildHistoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _searchController.text = title;
                _searchFocusNode.requestFocus();
              },
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _removeHistoryItem(title),
            child: Icon(Icons.close, color: Colors.grey[500], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredCourses;

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No courses found matching "$_searchQuery".',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(course.institution ?? 'Unknown Institution'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Save to history before navigating
              _onSearchSubmitted(course.title);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailsScreen(course: course),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
