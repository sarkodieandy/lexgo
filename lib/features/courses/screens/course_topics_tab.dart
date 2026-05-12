import 'package:flutter/material.dart';
import '../../../../models/course_model.dart';
import '../../../../models/topic_model.dart';
import '../../../../services/course_topics_api_service.dart';

class CourseTopicsTab extends StatefulWidget {
  final Course course;

  const CourseTopicsTab({super.key, required this.course});

  @override
  State<CourseTopicsTab> createState() => _CourseTopicsTabState();
}

class _CourseTopicsTabState extends State<CourseTopicsTab> {
  final CourseTopicsApiService _apiService = CourseTopicsApiService();
  List<Topic> _topics = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Navigation state: null means showing top-level topics.
  // A string means showing subtopics (questions) for that specific topic.
  Topic? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      final topics = await _apiService.getCourseTopics(widget.course.id);
      setState(() {
        _topics = topics;
        if (_topics.length == 1) {
          _selectedTopic = _topics.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchTopics();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_topics.isEmpty) {
      return const Center(child: Text("No topics found for this course."));
    }

    if (_selectedTopic != null) {
      return _buildSubtopicsView();
    }
    return _buildTopicsListView();
  }

  Widget _buildTopicsListView() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Course Banner Area
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  'https://via.placeholder.com/400x150?text=Scales+of+Justice', // Placeholder for the actual image
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.balance,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_topics.length} Lessons',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.course.institution ??
                          'University of Ghana School of Law',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Topics List
        ...List.generate(_topics.length, (index) {
          final topic = _topics[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildTopicTile(index + 1, topic),
          );
        }),
      ],
    );
  }

  Widget _buildTopicTile(int number, Topic topic) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTopic = topic;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0B162C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (topic.pagesInfo != null)
                    Text(
                      topic.pagesInfo!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B162C),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtopicsView() {
    return Column(
      children: [
        // Custom Back Button Header (only if we have multiple topics to go back to)
        if (_topics.length > 1)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTopic = null; // Go back to topics list
                    });
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_ios, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'Back to Topics',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          // If no back button, add some spacing at the top
          const SizedBox(height: 16),

        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: _selectedTopic!.subtopics?.length ?? 0,
            itemBuilder: (context, index) {
              final subtopic = _selectedTopic!.subtopics![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    title: Text(
                      subtopic.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    trailing: const Icon(Icons.add, color: Color(0xFF0B162C)),
                    onTap: () {
                      // Handle question expansion/navigation here
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
