import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/home/home_assignment_stats_section.dart';
import '../widgets/home/home_quick_actions.dart';
import '../widgets/home/home_recent_activities_section.dart';
import '../widgets/home/home_top_section.dart';
import '../widgets/navigation/app_bottom_navigation.dart';
import '../widgets/sidebar.dart';
import 'quiz/quiz_screen.dart';
import 'courses/courses_list_screen.dart';
import '../widgets/navigation/app_back_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Scaffold(
      // Removed drawer and bottomNavigationBar as they are now in MainNavigationScreen
      backgroundColor: AppColors.brandDark,
      body: SafeArea(
        child: Column(
          children: [
            Builder(
              builder: (builderContext) => HomeTopSection(
                userName: provider.userName,
                notificationCount: provider.notificationCount,
                onMenuTap: () => Scaffold.of(builderContext).openDrawer(),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero card is the first item, separated from dark header
                      HomeHeroCard(userName: provider.userName),
                      const SizedBox(height: 24),
                      HomeQuickActions(actions: provider.quickActions),
                      const SizedBox(height: 24),
                      HomeAssignmentStats(categories: provider.assignmentStats),
                      const SizedBox(height: 24),
                      HomeRecentActivities(
                        activities: provider.recentActivities,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _handleNavigation as it's now handled by MainNavigationScreen
}
