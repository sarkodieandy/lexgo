import 'package:flutter/material.dart';

import '../../models/submission_filters.dart';
import '../../theme/app_colors.dart';

class AssignmentFilterSortSheet extends StatefulWidget {
  const AssignmentFilterSortSheet({
    super.key,
    required this.initialFilter,
    required this.initialSort,
    this.onApply,
  });

  final SubmissionFilter initialFilter;
  final SubmissionSort initialSort;
  final void Function(SubmissionFilter filter, SubmissionSort sort)? onApply;

  @override
  State<AssignmentFilterSortSheet> createState() =>
      _AssignmentFilterSortSheetState();
}

class _AssignmentFilterSortSheetState extends State<AssignmentFilterSortSheet> {
  late SubmissionFilter _selectedFilter;
  late SubmissionSort _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _selectedSort = widget.initialSort;
  }

  void _handleApply() {
    widget.onApply?.call(_selectedFilter, _selectedSort);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: AppColors.brandWhite,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter & Sort Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filter By',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<SubmissionFilter>(
                  value: _selectedFilter,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF6F0F6),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  iconEnabledColor: AppColors.brandDark,
                  style: const TextStyle(color: AppColors.brandDark),
                  items: SubmissionFilter.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        _filterLabelText(option),
                        style: const TextStyle(color: AppColors.brandDark),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedFilter = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<SubmissionSort>(
                  value: _selectedSort,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF6F0F6),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  iconEnabledColor: AppColors.brandDark,
                  style: const TextStyle(color: AppColors.brandDark),
                  items: SubmissionSort.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        _sortLabelText(option),
                        style: const TextStyle(color: AppColors.brandDark),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSort = value);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _filterLabelText(SubmissionFilter option) {
    switch (option) {
      case SubmissionFilter.graded:
        return 'Graded';
      case SubmissionFilter.pending:
        return 'Pending';
      case SubmissionFilter.all:
      default:
        return 'All Submissions';
    }
  }

  static String _sortLabelText(SubmissionSort option) {
    switch (option) {
      case SubmissionSort.alphabetical:
        return 'Alphabetically (A - Z)';
    }
    return '';
  }
}
