import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../widgets/quiz/quiz_card.dart';
import '../widgets/sidebar.dart';
import 'cases_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizzes = context.watch<HomeProvider>().quizzes;
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.brandDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Text(
          '+',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CasesScreen()),
            );
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onMenuTap: () => Scaffold.of(context).openDrawer()),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: quizzes.length,
                  itemBuilder: (_, index) => QuizCard(item: quizzes[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.brandDark,
      ),
      child: Row(
        children: [
          const Text(
            'Quiz',
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
    );
  }
}
