import 'package:flutter/material.dart';

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
  });
}

class AssignmentProgress {
  final String title;
  final String description;
  final int completed;
  final int total;

  const AssignmentProgress({
    required this.title,
    required this.description,
    required this.completed,
    required this.total,
  });
}

class AssignedCategory {
  final String subject;
  final List<AssignmentProgress> assignments;

  const AssignedCategory({required this.subject, required this.assignments});
}

class ActivityItem {
  final String title;
  final String detail;
  final String time;
  final IconData icon;
  final Color iconBackground;

  const ActivityItem({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
    required this.iconBackground,
  });
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconBackground;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconBackground,
  });
}

class SidebarItem {
  final String label;
  final IconData icon;
  final bool selected;
  final bool hasBadge;

  const SidebarItem({
    required this.label,
    required this.icon,
    this.selected = false,
    this.hasBadge = false,
  });
}

class HomeProvider extends ChangeNotifier {
  final DateTime _today = DateTime.now();

  String get greeting {
    final hour = _today.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get userName => 'Dr. Johnson';

  String get formattedDate => '${_today.month}/${_today.day}/${_today.year}';

  int get notificationCount => notifications.length;

  List<QuickAction> get quickActions => const [
    QuickAction(
      title: 'Create Quiz',
      subtitle: 'Test your knowledge',
      icon: Icons.quiz,
      background: Color(0xFFFCECBB),
    ),
    QuickAction(
      title: 'Upload Material',
      subtitle: 'Send course materials',
      icon: Icons.upload_file,
      background: Color(0xFFE7F0FF),
    ),
    QuickAction(
      title: 'Submissions',
      subtitle: 'View test and quizzes',
      icon: Icons.upload_file_outlined,
      background: Color(0xFFE9F5EF),
    ),
    QuickAction(
      title: 'View Cases',
      subtitle: 'Open cases',
      icon: Icons.business_center_outlined,
      background: Color(0xFFFFF3F3),
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
      title: 'Case Reminder',
      message: 'Courtroom B | The Republic vs Agnes Baidoo at 11:30 AM.',
      time: '09:00 AM',
      icon: Icons.notifications_active_outlined,
      iconBackground: Color(0xFFE9F5EF),
    ),
    NotificationItem(
      title: 'Quiz Submission',
      message: 'Sarah Amoako hasn’t finished Question 8 yet.',
      time: '09:30 AM',
      icon: Icons.quiz_outlined,
      iconBackground: Color(0xFFFCECBB),
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
