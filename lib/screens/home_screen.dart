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
import 'cases_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 0,
        onTap: (index) => _handleNavigation(context, index),
      ),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeQuickActions(actions: provider.quickActions),
                      const SizedBox(height: 18),
                      HomeAssignmentStats(categories: provider.assignmentStats),
                      const SizedBox(height: 18),
                      HomeRecentActivities(activities: provider.recentActivities),
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

  void _handleNavigation(BuildContext context, int selectedIndex) {
    if (selectedIndex == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CasesScreen()),
      );
      return;
    }

    if (selectedIndex != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      );
    }
  }
}
