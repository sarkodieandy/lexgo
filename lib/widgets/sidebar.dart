import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sidebar/sidebar_item.dart';
import '../providers/home_provider.dart';
import '../screens/help_center_screen.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_colors.dart';
import 'footer.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Drawer(
      width: 280,
      child: SafeArea(
        child: Container(
          color: AppColors.brandWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoSection(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              ..._buildMenuItems(
                provider.primaryMenu,
                context,
                provider.notificationCount,
              ),
                      const SizedBox(height: 32),
              ..._buildMenuItems(
                provider.secondaryMenu,
                context,
                provider.notificationCount,
              ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/Union.png',
          width: 32,
          height: 32,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'LexGo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDark,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Smart Legal Learning',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems(List<SidebarItem> items, BuildContext context, int badgeCount) {
    final widgets = <Widget>[];
    for (var item in items) {
      widgets.add(_SidebarEntry(
        item: item,
        badgeCount: item.hasBadge ? badgeCount : null,
        onTap: () => _navigate(context, item),
      ));
      widgets.add(const SizedBox(height: 12));
    }
    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }
    return widgets;
  }

  void _navigate(BuildContext context, dynamic item) {
    Navigator.of(context).pop();
    if (item.label == 'Notifications') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ));
    } else if (item.label == 'Help Center') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const HelpCenterScreen(),
      ));
    }
  }
}

class _SidebarEntry extends StatelessWidget {
  const _SidebarEntry({
    required this.item,
    required this.onTap,
    this.badgeCount,
  });

  final SidebarItem item;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = item.selected ? AppColors.brandBlue : AppColors.brandDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(item.icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: AppColors.brandWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
