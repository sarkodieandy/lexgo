import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/filter_selection.dart';
import '../providers/home_provider.dart';
import '../models/cases/case_item.dart';
import '../theme/app_colors.dart';
import '../widgets/cases/case_card.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../widgets/sidebar.dart';
import 'cases_filter_screen.dart';
import 'quiz_screen.dart';
import 'upload_new_case_screen.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  FilterSelection? _activeFilter;

  Future<void> _openFilter() async {
    final provider = context.read<HomeProvider>();
    final categories = provider.cases.map((item) => item.tag).toSet().toList()
      ..sort();
    if (!categories.contains('All Categories')) {
      categories.insert(0, 'All Categories');
    } else {
      categories.remove('All Categories');
      categories.insert(0, 'All Categories');
    }
    final result = await showGeneralDialog<FilterSelection>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter cases',
      transitionDuration: const Duration(milliseconds: 320),
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return CasesFilterScreen(
          categories: categories,
          initialSelection:
              _activeFilter ??
              FilterSelection(
                category: categories.isNotEmpty ? categories.first : '',
                sort: FilterSort.alphabeticalAsc,
              ),
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
      setState(() => _activeFilter = result);
    }
  }

  void _openUploadCase() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UploadNewCaseScreen()));
  }

  void _handleNavigation(int selectedIndex) {
    if (selectedIndex == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (selectedIndex == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
    } else if (selectedIndex != 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Coming soon')));
    }
  }

  List<CaseItem> _prepareCases(List<CaseItem> base) {
    final baseList = base.toList();
    List<CaseItem> list = baseList;
    final category = _activeFilter?.category;
    if (category != null &&
        category.isNotEmpty &&
        category != 'All Categories') {
      list = baseList.where((item) => item.tag == category).toList();
    }
    final sort = _activeFilter?.sort;
    if (sort == FilterSort.alphabeticalAsc) {
      list.sort((a, b) => a.title.compareTo(b.title));
    } else if (sort == FilterSort.alphabeticalDesc) {
      list.sort((a, b) => b.title.compareTo(a.title));
    } else if (sort == FilterSort.dateNewest) {
      list = List.from(list.reversed);
    } else if (sort == FilterSort.dateOldest) {
      list = List.from(list);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final visibleCases = _prepareCases(provider.cases);
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
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 1,
        onTap: _handleNavigation,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (headerContext) => _CasesHeader(
                onMenuTap: () => Scaffold.of(headerContext).openDrawer(),
              ),
            ),
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
                          _SearchRow(onFilterPressed: _openFilter),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: visibleCases.length,
                              itemBuilder: (_, index) =>
                                  CaseCard(item: visibleCases[index]),
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
  const _CasesHeader({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
              const Spacer(),
              GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.brandWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: AppColors.brandDark),
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
  const _SearchRow({required this.onFilterPressed});

  final VoidCallback onFilterPressed;

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
