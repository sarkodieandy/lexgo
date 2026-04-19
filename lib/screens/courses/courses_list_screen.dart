import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/courses_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/navigation/app_back_button.dart';
import '../../widgets/courses/create_course_sheet.dart';
import 'course_detail_screen.dart';

class Courses extends StatefulWidget {
  const Courses({super.key});

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  static const _categories = [
    'All Categories',
    'Criminal Law',
    'Contract Law',
    'Tort Law',
    'Evidence Law',
    'Property Law',
    'Administrative Law',
    'Corporate Law',
    'Family Law',
  ];

  static const _sortOptions = [
    'Alphabetically (A - Z)',
    'Alphabetically (Z - A)',
    'Date Created (Newest - Oldest)',
    'Date Created (Oldest - Newest)',
  ];

  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesProvider>().loadCourses();
    });
  }

  String _selectedCategory = _categories.first;
  String _selectedSort = _sortOptions.first;

  List<Course> _getFilteredCourses(List<Course> courses) {
    final query = _searchController.text.toLowerCase();
    final filtered = courses.where((course) {
      final matchesCategory =
          _selectedCategory == 'All Categories' ||
          course.category == _selectedCategory;
      final matchesSearch =
          course.title.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    switch (_selectedSort) {
      case 'Alphabetically (Z - A)':
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Date Created (Newest - Oldest)':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Date Created (Oldest - Newest)':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      default:
        filtered.sort((a, b) => a.title.compareTo(b.title));
    }
    return filtered;
  }

  void _showFilterSheet() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter & Sort Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filter by Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                label: '',
                value: _selectedCategory,
                hint: 'Select a category',
                items: _categories,
                onChanged: (value) => setState(
                  () => _selectedCategory = value ?? _selectedCategory,
                ),
                showLabel: false,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sort order',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildDropdown(
                label: '',
                value: _selectedSort,
                hint: 'Select sort',
                items: _sortOptions,
                onChanged: (value) =>
                    setState(() => _selectedSort = value ?? _selectedSort),
                showLabel: false,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.brandDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseActions(Course course) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive course'),
              subtitle: Text('${course.code} • ${course.title}'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${course.title} archived'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openCreateCourseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateCourseSheet(),
    );
  }

  Widget _buildActiveFilterRow() {
    final showCategory = _selectedCategory != 'All Categories';
    final showSort = _selectedSort != _sortOptions.first;
    if (!showCategory && !showSort) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (showCategory) _buildFilterChip(label: _selectedCategory),
          if (showSort) _buildFilterChip(label: _selectedSort),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.close, size: 14),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool showLabel = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F5FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint),
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoursesProvider>();
    final courses = _getFilteredCourses(provider.courses);
    return Scaffold(
      backgroundColor: AppColors.brandWhite,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandDark,
        onPressed: _openCreateCourseSheet,
        child: const Icon(Icons.add, color: AppColors.brandWhite),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.brandDark,
              padding: const EdgeInsets.fromLTRB(16, 20, 24, 18),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 16),
                  const Text(
                    'Courses',
                    style: TextStyle(
                      color: AppColors.brandWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset('assets/Union.png', fit: BoxFit.contain),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '| Search Courses...',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.brandDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: AppColors.brandWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildActiveFilterRow(),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (provider.error != null && provider.courses.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load courses: ${provider.error}',
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () => provider.loadCourses(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (courses.isEmpty)
              const Expanded(child: Center(child: Text('No courses found')))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadCourses(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 0,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CourseDetailScreen(course: course),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.brandWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                    child: Image.asset(
                                      course.image,
                                      fit: BoxFit.cover,
                                      height: 140,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                            color: AppColors.brandDark,
                                            height: 140,
                                            width: double.infinity,
                                          ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 16,
                                    child: GestureDetector(
                                      onTap: () => _showCourseActions(course),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: AppColors.brandWhite,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0x22000000),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.more_vert,
                                          color: AppColors.brandDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${course.code} : ${course.title}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brandDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      course.category,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.institution,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
