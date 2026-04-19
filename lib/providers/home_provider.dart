import 'package:flutter/material.dart';

import '../models/cases/case_item.dart';
import '../models/home/activity_item.dart';
import '../models/home/assignment_progress.dart';
import '../models/notifications/notification_item.dart';
import '../models/home/quick_action.dart';
import '../models/sidebar/sidebar_item.dart';

class HomeProvider extends ChangeNotifier {
  final DateTime _today = DateTime.now();

  String _userName = 'Dr.';
  String get userName => _userName;

  set userName(String value) {
    if (_userName == value) return;
    _userName = value;
    notifyListeners();
  }

  String get greeting {
    final hour = _today.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get formattedDate => '${_today.month}/${_today.day}/${_today.year}';

  int get notificationCount => notifications.length;

  List<QuickAction> get quickActions => const [
    QuickAction(
      title: 'Create Quiz',
      subtitle: 'Test your knowledge',
      icon: Icons.chat_bubble_outline_rounded,
      background: Color(0xFFFDF3DC),
      iconColor: Color(0xFFE5A800),
    ),
    QuickAction(
      title: 'Upload Material',
      subtitle: 'Send course materials',
      icon: Icons.upload_rounded,
      background: Color(0xFFEAF1FF),
      iconColor: Color(0xFF3B6FE0),
    ),
    QuickAction(
      title: 'Submissions',
      subtitle: 'View test and quizzes',
      icon: Icons.receipt_long_outlined,
      background: Color(0xFFFFECEC),
      iconColor: Color(0xFFD14234),
    ),
    QuickAction(
      title: 'View Cases',
      subtitle: 'Open cases',
      icon: Icons.menu_book_outlined,
      background: Color(0xFFF0F0F0),
      iconColor: Color(0xFF1A1A2E),
    ),
  ];

  List<AssignedCategory> get assignmentStats => const [
    AssignedCategory(
      subject: 'Criminal Law',
      assignments: [
        AssignmentProgress(
          title: 'Assignment 1',
          description: 'Introduction to Criminal Law',
          completed: 60,
          total: 120,
        ),
        AssignmentProgress(
          title: 'Assignment 2',
          description: 'Basics of Criminal Law',
          completed: 40,
          total: 120,
        ),
      ],
    ),
  ];

  List<ActivityItem> get recentActivities => const [
    ActivityItem(
      title: 'New Submissions',
      detail: '2 new submissions on Assignment 1',
      time: '06:00 AM',
      icon: Icons.assignment,
      iconBackground: Color(0xFFFCECBB),
    ),
    ActivityItem(
      title: 'Material Upload',
      detail: 'Course notes uploaded for Criminal Law',
      time: '08:45 AM',
      icon: Icons.upload_file,
      iconBackground: Color(0xFFE7F0FF),
    ),
    ActivityItem(
      title: 'Case Update',
      detail: 'The Republic vs. Baidoo scheduled for review',
      time: '11:12 AM',
      icon: Icons.gavel,
      iconBackground: Color(0xFFE9F5EF),
    ),
  ];

  List<NotificationItem> get notifications => const [
    NotificationItem(
      title: 'New Case Added',
      message: 'The Republic vs. Agnes Baidoo has been added to cases.',
      time: '06:00 AM',
      icon: Icons.book_outlined,
      iconBackground: Color(0xFFFCECBB),
    ),
    NotificationItem(
      title: 'New Course Added',
      message: 'Basic Law Terms has been added to Courses.',
      time: '06:30 AM',
      icon: Icons.library_books_outlined,
      iconBackground: Color(0xFFE7F0FF),
    ),
    NotificationItem(
      title: 'New Case Added',
      message: 'Max Trade Ltd vs. Rex Trade Ltd has been added to cases.',
      time: '06:00 AM',
      icon: Icons.book_outlined,
      iconBackground: Color(0xFFFCECBB),
    ),
    NotificationItem(
      title: 'New Submissions',
      message: 'Sarah Amoako has submitted her quiz for your review.',
      time: '06:00 AM',
      icon: Icons.download_rounded,
      iconBackground: Color(0xFFFCECBB),
    ),
    NotificationItem(
      title: 'New Submissions',
      message: 'John Doe has submitted his quiz for your review.',
      time: '06:00 AM',
      icon: Icons.download_rounded,
      iconBackground: Color(0xFFFCECBB),
    ),
    NotificationItem(
      title: 'New Submissions',
      message: 'Kofi Agyemang has submitted his assignment for grading.',
      time: '06:00 AM',
      icon: Icons.download_rounded,
      iconBackground: Color(0xFFFCECBB),
    ),
    NotificationItem(
      title: 'New Case Added',
      message: 'Max Trade Ltd vs. Rex Trade Ltd has been added to cases.',
      time: '06:00 AM',
      icon: Icons.book_outlined,
      iconBackground: Color(0xFFFCECBB),
    ),
  ];

  List<CaseItem> get cases => const [
    CaseItem(
      id: 'case-1',
      title: 'The Republic v. John Smith',
      subtitle: 'Supreme Court of Ghana',
      code: '[2024] GHASC 15',
      tag: 'Administrative Law',
      tagColor: Color(0xFFD14234),
    ),
    CaseItem(
      id: 'case-2',
      title: 'Case Title',
      subtitle: 'Source of case',
      code: 'case code',
      tag: 'Constitutional Law',
      tagColor: Color(0xFF8B5CF6),
    ),
    CaseItem(
      id: 'case-3',
      title: 'Case Title',
      subtitle: 'Source of case',
      code: 'case code',
      tag: 'Contract Law',
      tagColor: Color(0xFF6366F1),
    ),
  ];

  List<SidebarItem> get primaryMenu => const [
    SidebarItem(label: 'Home', icon: Icons.home, selected: true),
    SidebarItem(label: 'Cases', icon: Icons.work_outline),
    SidebarItem(label: 'Quiz', icon: Icons.quiz_outlined),
    SidebarItem(label: 'Courses', icon: Icons.menu_book_outlined),
    SidebarItem(label: 'Students', icon: Icons.people_outline),
  ];

  List<SidebarItem> get secondaryMenu => const [
    SidebarItem(
      label: 'Notifications',
      icon: Icons.notifications,
      hasBadge: true,
    ),
    SidebarItem(label: 'Help Center', icon: Icons.help_outline),
    SidebarItem(label: 'Companion', icon: Icons.auto_stories),
    SidebarItem(label: 'Log Out', icon: Icons.logout),
  ];
}
