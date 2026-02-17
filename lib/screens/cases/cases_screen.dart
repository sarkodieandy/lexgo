import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/filter_selection.dart';
import '../../providers/cases_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cases/case_card.dart';
import '../../widgets/sidebar.dart';
import 'cases_filter_screen.dart';
import 'upload_new_case_screen.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CasesProvider>().loadCases();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final provider = context.read<CasesProvider>();
    final categories = provider.availableCategories;
    final initialSelection =
        provider.activeFilter ??
        FilterSelection(
          category: categories.isNotEmpty ? categories.first : 'All Categories',
          sort: FilterSort.alphabeticalAsc,
        );
    final result = await showGeneralDialog<FilterSelection>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter cases',
      transitionDuration: const Duration(milliseconds: 320),
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return CasesFilterScreen(
          categories: categories,
          initialSelection: initialSelection,
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
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
    if (result != null) {
      await provider.applyFilter(result);
    }
  }

  void _openUploadCase() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UploadNewCaseScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final casesProvider = context.watch<CasesProvider>();
    final cases = casesProvider.cases;
    final hasError = casesProvider.error != null;
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      floatingActionButton: FloatingActionButton(
        onPressed: _openUploadCase,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Text(
          '+',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            const _CasesHeader(),
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: 20,
                    child: Image.asset(
                      'assets/Union.png',
                      width: 220,
                      height: 220,
                      color: Colors.black12,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          _SearchRow(
                            controller: _searchController,
                            onSubmitted: (value) => casesProvider.search(value),
                            onFilterPressed: _openFilter,
                          ),
                          const SizedBox(height: 20),
                          if (casesProvider.isLoading)
                            const Expanded(
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (hasError)
                            Expanded(
                              child: Center(
                                child: Text(
                                  casesProvider.error ?? 'Unable to load cases',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else if (cases.isEmpty)
                            const Expanded(
                              child: Center(child: Text('No cases found')),
                            )
                          else
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => casesProvider.loadCases(),
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: cases.length,
                                  itemBuilder: (_, index) =>
                                      CaseCard(item: cases[index]),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CasesHeader extends StatelessWidget {
  const _CasesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              'assets/Union.png',
              width: 100,
              height: 100,
              color: AppColors.brandWhite.withAlpha(40),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.brandWhite,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/Union.png',
                width: 32,
                height: 32,
                color: AppColors.brandWhite,
              ),
              const SizedBox(width: 12),
              const Text(
                'Cases',
                style: TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onFilterPressed,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback onFilterPressed;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E3E7)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Cases...',
                hintStyle: TextStyle(color: AppColors.mutedText),
                suffixIcon: const Icon(Icons.search, color: Colors.black54),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.brandDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: onFilterPressed,
            color: AppColors.brandWhite,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}
