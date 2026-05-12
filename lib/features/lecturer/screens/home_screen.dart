import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../widgets/home/home_assignment_stats_section.dart';
import '../widgets/home/home_quick_actions.dart';
import '../widgets/home/home_recent_activities_section.dart';
import '../widgets/home/home_top_section.dart';
import '../models/home/quick_action.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Column(
      children: [
        HomeTopSection(
          userName: provider.userName,
          notificationCount: provider.notificationCount,
          onMenuTap: () => Scaffold.of(context).openDrawer(),
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
                  HomeHeroCard(userName: provider.userName),
                  const SizedBox(height: 24),
                  HomeQuickActions(
                    actions: provider.quickActions.map<QuickAction>((action) {
                      return QuickAction(
                        title: action.title,
                        subtitle: action.subtitle,
                        icon: action.icon,
                        background: action.background,
                        iconColor: action.iconColor,
                        onTap: () {
                          switch (action.title) {
                            case 'Create Quiz':
                            case 'Quiz':
                            case 'Submissions':
                              provider.updateTabIndex(2);
                              break;
                            case 'View Cases':
                              provider.updateTabIndex(1);
                              break;
                            case 'Upload Material':
                              provider.updateTabIndex(3);
                              break;
                            default:
                              debugPrint('No navigation for ${action.title}');
                          }
                        },
                      );
                    }).toList(),
                  ),
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
    );
  }
}
