import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/filter_selection.dart';
import '../../providers/cases_provider.dart';
import '../../providers/home_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cases/case_card.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/navigation/app_back_button.dart';
import 'cases_filter_screen.dart';
import 'upload_new_case_screen.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CasesProvider>().loadCases();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CasesProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
      backgroundColor: AppColors.brandDark,
      floatingActionButton: FloatingActionButton(
        onPressed: _openUploadCase,
        backgroundColor: Colors.black,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
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
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  // +1 for the bottom loader footer
                                  itemCount: cases.length + 1,
                                  itemBuilder: (_, index) {
                                    if (index == cases.length) {
                                      if (casesProvider.isLoadingMore) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24),
                                          child: Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      }
                                      return const SizedBox(height: 80);
                                    }
                                    return CaseCard(item: cases[index]);
                                  },
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
    final homeProvider = context.watch<HomeProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 12),
              const Text(
                'Cases',
                style: TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _NotificationBadge(
                count: homeProvider.notificationCount,
                onTap: () => Scaffold.of(context).openDrawer(),
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
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Cases..',
                hintStyle: TextStyle(
                  color: AppColors.mutedText.withAlpha(180),
                  fontSize: 15,
                ),
                suffixIcon: Icon(
                  Icons.search,
                  color: AppColors.mutedText.withAlpha(200),
                ),
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
            borderRadius: BorderRadius.circular(12),
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

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.brandWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: AppColors.brandDark, size: 20),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
