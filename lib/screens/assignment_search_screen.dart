import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_assignments_provider.dart';
import '../theme/app_colors.dart';

class AssignmentSearchScreen extends StatefulWidget {
  const AssignmentSearchScreen({super.key});

  @override
  State<AssignmentSearchScreen> createState() => _AssignmentSearchScreenState();
}

class _AssignmentSearchScreenState extends State<AssignmentSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submitSearch() {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    context.read<CourseAssignmentsProvider>().recordSearchTerm(term);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseAssignmentsProvider>();
    final history = provider.searchHistory;
    return Scaffold(
      backgroundColor: const Color(0xFF020F20),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2138),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.brandWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                color: AppColors.brandDark,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: '|Search legal terms...',
                              ),
                              onSubmitted: (_) => _submitSearch(),
                            ),
                          ),
                          GestureDetector(
                            onTap: _submitSearch,
                            child: const Icon(
                              Icons.search,
                              color: AppColors.brandDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.brandWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 24, top: 24, bottom: 8),
                      child: Text(
                        'Search History',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: history.isEmpty
                          ? const Center(
                              child: Text(
                                'No search history yet.',
                                style: TextStyle(color: AppColors.mutedText),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              itemCount: history.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 18),
                              itemBuilder: (context, index) {
                                final term = history[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF000000,
                                        ).withOpacity(0.04),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            context
                                                .read<
                                                  CourseAssignmentsProvider
                                                >()
                                                .recordSearchTerm(term);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            term,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.brandDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            provider.removeSearchTerm(term),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
