import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/cases/case_card.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../screens/upload_new_case_screen.dart';
import '../widgets/sidebar.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openUploadCase(context),
        backgroundColor: AppColors.brandDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Text(
          '+',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 1,
        onTap: (index) => _handleNavigation(context, index),
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
                          _SearchRow(),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: provider.cases.length,
                              itemBuilder: (_, index) => CaseCard(item: provider.cases[index]),
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

  void _openUploadCase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UploadNewCaseScreen()),
    );
  }

  void _handleNavigation(BuildContext context, int selectedIndex) {
    if (selectedIndex == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (selectedIndex != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      );
    }
  }
}

class _CasesHeader extends StatelessWidget {
  const _CasesHeader({
    required this.onMenuTap,
  });

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.brandDark,
      ),
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
            onPressed: () {},
            color: AppColors.brandWhite,
            icon: const Icon(Icons.tune),
          ),
        ),
      ],
    );
  }
}
