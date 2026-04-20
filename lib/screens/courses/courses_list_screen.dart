import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/courses_provider.dart';
import '../../providers/home_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/navigation/app_back_button.dart';
import '../../widgets/courses/create_course_sheet.dart';
import '../../widgets/sidebar.dart';
import 'course_detail_screen.dart';

class Courses extends StatefulWidget {
  const Courses({super.key, this.autoOpenCreate = false});
  final bool autoOpenCreate;

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
      if (widget.autoOpenCreate) {
        _openCreateCourseSheet();
      }
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
    final homeProvider = context.watch<HomeProvider>();
    final courses = _getFilteredCourses(provider.courses);

    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Courses',
                style: TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.brandWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFF0D0D0D),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  if (homeProvider.notificationCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3D71),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${homeProvider.notificationCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Search & Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF98A2B3),
                                size: 22,
                              ),
                              hintText: 'Search Courses..',
                              hintStyle: TextStyle(
                                color: Color(0xFF98A2B3),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
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
                            color: const Color(0xFF0D253F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildActiveFilterRow(),
                const SizedBox(height: 8),

                // Courses List
                Expanded(
                  child: provider.isLoading && provider.courses.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => provider.loadCourses(),
                          child: courses.isEmpty
                              ? const Center(child: Text('No courses found'))
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                                  itemCount: courses.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final course = courses[index];
                                    return _buildCourseCard(course, index == 0);
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Course course, bool isSpecial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    course.image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: const Color(0xFFEDF2F7),
                      child: const Icon(Icons.image_outlined, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () => _showCourseActions(course),
                    ),
                  ),
                ),
                if (isSpecial)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD14234),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Special',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${course.code} : ${course.title}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D0D0D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              course.category,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              course.institution,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C757D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
