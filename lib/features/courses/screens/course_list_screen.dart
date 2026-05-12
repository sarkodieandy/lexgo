import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/course_model.dart';
import '../../../../services/enrollment_api_service.dart';
import 'course_details_screen.dart';
import 'course_search_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final EnrollmentApiService _enrollmentApiService = EnrollmentApiService();
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  String? _selectedTopic;
  bool _isLoading = true;
  String? _errorMessage;

  static const List<String> _legalTopics = [
    'Criminal Law',
    'Contract Law',
    'Tort Law',
    'Evidence Law',
    'Immovable Property',
    'Administrative Law',
    'Company Law',
    'Family Law',
    'Commercial Law',
    'Ghana Legal System',
    'Public International Law',
    'Equity',
    'Succession',
    'Jurisprudence',
    'Taxation',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _enrollmentApiService.getMyCourses();
      if (mounted) {
        final fetched = List<Course>.from(result['courses'] ?? []);
        setState(() {
          // Always show the two default courses alongside (or as fallback for) enrolled ones
          _courses = fetched.isEmpty ? _mockCourses : fetched;
          _filteredCourses = _courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to mock data when backend is unreachable / no auth token
      if (mounted) {
        setState(() {
          _courses = _mockCourses;
          _filteredCourses = _mockCourses;
          _isLoading = false;
        });
      }
    }
  }

  void _applyTopicFilter(String? topic) {
    setState(() {
      _selectedTopic = topic;
      if (topic == null) {
        _filteredCourses = _courses;
      } else {
        _filteredCourses = _courses
            .where((c) =>
                c.title.toLowerCase().contains(topic.toLowerCase()) ||
                (c.institution?.toLowerCase().contains(topic.toLowerCase()) ??  false))
            .toList();
      }
    });
  }

  void _showTopicFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Filter by Legal Topic',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0B162C),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedTopic != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _applyTopicFilter(null);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: _legalTopics.length,
                itemBuilder: (ctx, i) {
                  final topic = _legalTopics[i];
                  final isSelected = _selectedTopic == topic;
                  return ListTile(
                    title: Text(
                      topic,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF0B162C)
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check,
                            color: Color(0xFF0B162C), size: 18)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _applyTopicFilter(topic);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static final List<Course> _mockCourses = [
    Course(
      id: 'default-1',
      title: 'Contract Law',
      institution: 'University of Ghana School of Law',
      level: '200',
    ),
    Course(
      id: 'default-2',
      title: 'Criminal Law',
      institution: 'University of Ghana School of Law',
      level: '200',
    ),
  ];

  // Curated imagery mapped by keywords in the course title
  static const Map<String, String> _topicImages = {
    'contract': 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800&q=80',
    'criminal': 'https://images.unsplash.com/photo-1453847668862-487637052f8a?w=800&q=80',
    'tort': 'https://images.unsplash.com/photo-1616400619175-5beda3a17896?w=800&q=80',
    'constitutional': 'https://images.unsplash.com/photo-1575505586569-646b2ca898fc?w=800&q=80',
    'property': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&q=80',
    'evidence': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&q=80',
    'equity': 'https://images.unsplash.com/photo-1593115057322-e94b77572f20?w=800&q=80',
    'law': 'https://images.unsplash.com/photo-1589578527966-fdac0f44566c?w=800&q=80',
  };

  String _imageForCourse(String title) {
    final lower = title.toLowerCase();
    for (final entry in _topicImages.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return _topicImages['law']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Courses',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Join Course button
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.list, color: Colors.black),
              tooltip: 'Join a course',
              onPressed: _showJoinCourseDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  if (mounted) setState(() {});
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty && _courses.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseSearchScreen(allCourses: _courses),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _showTopicFilter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _selectedTopic != null
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF0B162C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF0B162C)),
            SizedBox(height: 16),
            Text(
              'Loading your courses...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_courses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF0B162C),
      onRefresh: _fetchCourses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCourses.length,
        itemBuilder: (context, index) => _buildCourseCard(_filteredCourses[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: const Color(0xFF0B162C),
      onRefresh: _fetchCourses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0B162C).withAlpha(13),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 48,
                color: Color(0xFF0B162C),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No courses yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B162C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your lecturer will share a Course ID and a secret code with you. Tap the + button above to join your first course.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showJoinCourseDialog,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Join a Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B162C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Could not load courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B162C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchCourses,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B162C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final imageUrl = _imageForCourse(course.title);
    // Determine lesson count from topics if available, otherwise show 4 as default
    final lessonCount = 4;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailsScreen(course: course),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image banner
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF0B162C),
                  child: const Center(
                    child: Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 48),
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF0B162C).withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0B162C), strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Course info below image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0B162C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$lessonCount Lessons',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (course.institution != null &&
                      course.institution!.isNotEmpty) ...
                    [
                      const SizedBox(height: 2),
                      Text(
                        course.institution!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinCourseDialog() {
    final courseIdController = TextEditingController();
    final courseCodeController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.school, color: Color(0xFF0B162C), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Join a Course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B162C),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your lecturer will share both the Course ID and the secret code with you.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDialogField(
                    controller: courseIdController,
                    label: 'Course ID',
                    hint: 'e.g. 64b8a3f1c2...',
                    icon: Icons.tag,
                  ),
                  const SizedBox(height: 14),
                  _buildDialogField(
                    controller: courseCodeController,
                    label: 'Course Code',
                    hint: 'e.g. 12345789',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final courseId = courseIdController.text.trim();
                          final courseCode = courseCodeController.text.trim();
                          final messenger = ScaffoldMessenger.of(context);
                          if (courseId.isEmpty || courseCode.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in both fields.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSubmitting = true);
                          try {
                            final res = await _enrollmentApiService.applyForCourse(
                              courseId,
                              courseCode,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    res['message'] ??
                                        'Application submitted! Waiting for approval.',
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (dialogContext.mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B162C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B162C),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF0B162C)),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

}
