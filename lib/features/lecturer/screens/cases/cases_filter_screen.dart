import 'package:flutter/material.dart';

import '../../models/filter_selection.dart';
import '../../theme/app_colors.dart';

class CasesFilterScreen extends StatefulWidget {
  const CasesFilterScreen({
    super.key,
    required this.categories,
    this.initialSelection,
  });

  final List<String> categories;
  final FilterSelection? initialSelection;

  @override
  State<CasesFilterScreen> createState() => _CasesFilterScreenState();
}

class _CasesFilterScreenState extends State<CasesFilterScreen> {
  String? _selectedCategory;
  late FilterSort _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.initialSelection?.category ??
        (widget.categories.isNotEmpty ? widget.categories.first : null);
    _selectedSort = widget.initialSelection?.sort ?? FilterSort.alphabeticalAsc;
  }

  void _applyFilters() {
    if (_selectedCategory == null) return;
    Navigator.of(
      context,
    ).pop(FilterSelection(category: _selectedCategory!, sort: _selectedSort));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.brandWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter & Sort Options',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Filter By',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _buildDropdown<String>(
                value: _selectedCategory,
                hint: 'Case Category',
                items: widget.categories,
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sort By',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _buildDropdown<FilterSort>(
                value: _selectedSort,
                hint: 'Alphabetically (A - Z)',
                items: FilterSort.values,
                itemLabel: (sort) {
                  switch (sort) {
                    case FilterSort.alphabeticalAsc:
                      return 'Alphabetically (A - Z)';
                    case FilterSort.alphabeticalDesc:
                      return 'Alphabetically (Z - A)';
                    case FilterSort.dateNewest:
                      return 'Date Created (Newest → Oldest)';
                    case FilterSort.dateOldest:
                      return 'Date Created (Oldest → Newest)';
                  }
                },
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSort = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandWhite,
                    side: const BorderSide(
                      color: AppColors.brandDark,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          initialValue: value,
          decoration: const InputDecoration(border: InputBorder.none),
          hint: Text(hint, style: TextStyle(color: AppColors.mutedText)),
          isExpanded: true,
          items: items
              .map(
                (entry) => DropdownMenuItem<T>(
                  value: entry,
                  child: Text(itemLabel?.call(entry) ?? entry.toString()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
