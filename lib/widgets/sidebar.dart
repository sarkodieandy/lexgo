import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../screens/help_center_screen.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_colors.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Drawer(
      width: 260,
      child: Container(
        color: AppColors.brandWhite,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              child: Row(
                children: [
                  Image.asset('assets/union.png', width: 32, height: 32),
                  const SizedBox(width: 14),
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
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...provider.primaryMenu.map(
                    (item) => _SidebarItem(
                      item: item,
                      badgeCount: item.hasBadge
                          ? provider.notificationCount
                          : null,
                      onTap: () => _navigate(context, item),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...provider.secondaryMenu.map(
                    (item) => _SidebarItem(
                      item: item,
                      badgeCount: item.hasBadge
                          ? provider.notificationCount
                          : null,
                      onTap: () => _navigate(context, item),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.brandWhite,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Dr.Johnson Coffie',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lecturer',
                        style: TextStyle(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, SidebarItem item) {
    Navigator.of(context).pop();
    if (item.label == 'Notifications') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    } else if (item.label == 'Help Center') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
    }
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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
    return ListTile(
      leading: Icon(item.icon, color: color),
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: badgeCount != null && badgeCount! > 0
          ? Container(
              width: 22,
              height: 22,
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
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
