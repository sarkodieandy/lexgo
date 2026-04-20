import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../widgets/sidebar.dart';
import 'home_screen.dart';
import 'cases/cases_screen.dart';
import 'quiz/quiz_screen.dart';
import 'courses/courses_list_screen.dart';
import 'quiz/quize_1.dart';
import 'cases/upload_new_case_screen.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/courses/create_course_sheet.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomeScreen(),
    const CasesScreen(),
    const QuizScreen(),
    const Courses(),
  ];

  void _onItemTapped(int index) {
    context.read<HomeProvider>().updateTabIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<HomeProvider>().selectedTabIndex;
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFAB(selectedIndex),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget? _buildFAB(int selectedIndex) {
    final isLecturer =
        context.watch<AuthProvider>().currentUser?.role?.toLowerCase() ==
        'lecturer';

    switch (selectedIndex) {
      case 1: // Cases
        return FloatingActionButton(
          onPressed: _openUploadCase,
          backgroundColor: Colors.black,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        );
      default:
        return null;
    }
  }

  void _openUploadCase() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UploadNewCaseScreen()),
    );
  }

  void _openCreateCourseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateCourseSheet(),
    );
  }
}
