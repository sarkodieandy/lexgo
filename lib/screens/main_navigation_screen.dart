import 'package:flutter/material.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../widgets/sidebar.dart';
import 'home_screen.dart';
import 'cases/cases_screen.dart';
import 'quiz/quiz_screen.dart';
import 'courses/courses_list_screen.dart';
import '../theme/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CasesScreen(),
    const QuizScreen(),
    const Courses(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
