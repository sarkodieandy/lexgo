import 'package:flutter/material.dart';

import '../../../models/quiz/submission_record.dart';
import '../../../theme/app_colors.dart';
import 'submission_tile.dart';

class SubmissionsTab extends StatefulWidget {
  const SubmissionsTab({super.key, required this.submissions});

  final List<SubmissionRecord> submissions;

  @override
  State<SubmissionsTab> createState() => _SubmissionsTabState();
}

class _SubmissionsTabState extends State<SubmissionsTab> {
  late final TextEditingController _controller;
  late final List<String> _sortOptions;
  late final List<String> _categoryOptions;
  late List<SubmissionRecord> _filtered;
  String _selectedCategory = 'All Categories';
  String _selectedSort = 'Alphabetically (A - Z)';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onSearchChanged);
    _sortOptions = [
      'Alphabetically (A - Z)',
      'Alphabetically (Z - A)',
      'Score (High → Low)',
      'Score (Low → High)',
      'Newest Submissions',
      'Oldest Submissions',
    ];
    final categories = widget.submissions
        .map((entry) => entry.category)
        .toSet()
        .toList()
      ..sort();
    _categoryOptions = [
      'All Categories',
      ...categories,
    ];
    _filtered = widget.submissions;
    _applyFilters(notify: false);
  }

  @override
  void didUpdateWidget(covariant SubmissionsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submissions != widget.submissions) {
      _filtered = widget.submissions;
      _applyFilters(notify: false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters({bool notify = true}) {
    var list = widget.submissions.toList();
    if (_selectedCategory != 'All Categories') {
      list = list.where((record) => record.category == _selectedCategory).toList();
    }
    final query = _controller.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((record) => record.name.toLowerCase().contains(query)).toList();
    }
    switch (_selectedSort) {
      case 'Alphabetically (A - Z)':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Alphabetically (Z - A)':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Score (High → Low)':
        list.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'Score (Low → High)':
        list.sort((a, b) => a.score.compareTo(b.score));
        break;
      case 'Newest Submissions':
        list.sort((a, b) => b.submittedAtDate.compareTo(a.submittedAtDate));
        break;
      case 'Oldest Submissions':
        list.sort((a, b) => a.submittedAtDate.compareTo(b.submittedAtDate));
        break;
    }
    if (notify) {
      setState(() => _filtered = list);
    } else {
      _filtered = list;
    }
  }

  void _showFilters() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter submissions',
      transitionDuration: const Duration(milliseconds: 320),
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        String tempCategory = _selectedCategory;
        String tempSort = _selectedSort;
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Material(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.brandWhite,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter & Sort Options',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      const Text('Filter By'),
                      const SizedBox(height: 8),
                      InputDecorator(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF2F4F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: _categoryOptions
                                .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => tempCategory = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Sort By'),
                      const SizedBox(height: 8),
                      InputDecorator(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF2F4F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempSort,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: _sortOptions
                                .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => tempSort = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.brandDark),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: AppColors.brandWhite,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: AppColors.brandDark),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = tempCategory;
                                  _selectedSort = tempSort;
                                });
                                _applyFilters();
                                Navigator.of(context).pop();
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('Apply Filters'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.mutedText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '|Search Courses...',
                          hintStyle: TextStyle(color: AppColors.mutedText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showFilters,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.brandDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.tune, color: AppColors.brandWhite),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => SubmissionTile(record: _filtered[index]),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
