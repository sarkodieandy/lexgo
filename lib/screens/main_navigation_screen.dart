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
import '../widgets/courses/create_course_sheet.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget? _buildFAB() {
    final isLecturer =
        context.watch<AuthProvider>().currentUser?.role?.toLowerCase() ==
        'lecturer';

    switch (_selectedIndex) {
      case 1: // Cases
        return FloatingActionButton(
          onPressed: _openUploadCase,
          backgroundColor: Colors.black,
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        );
      case 2: // Quiz
        if (!isLecturer) return null;
        return FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const Quiz1()),
          ),
          backgroundColor: const Color(0xFF0D0D0D),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        );
      case 3: // Courses
        return FloatingActionButton(
          backgroundColor: AppColors.brandDark,
          onPressed: _openCreateCourseSheet,
          child: const Icon(Icons.add, color: AppColors.brandWhite),
        );
      default:
        return null;
    }
  }

  void _openUploadCase() {
    // This will be reachable as long as UploadNewCaseScreen exists
    Navigator.of(context).pushNamed('/upload-case').catchError((_) {
      // Fallback if routes aren't registered
      // We can just import and use push
    });
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
