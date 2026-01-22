import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/notification_widgets.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<HomeProvider>().notifications;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const NotificationsHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                itemCount: notifications.length,
                separatorBuilder: (context, _) => const SizedBox(height: 16),
                itemBuilder: (_, index) =>
                    NotificationCard(item: notifications[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
