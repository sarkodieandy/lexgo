import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/notification_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<HomeProvider>().notifications;
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: Column(
        children: [
          const NotificationsHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (_, index) =>
                    NotificationTile(item: notifications[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
