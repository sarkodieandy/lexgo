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
          NotificationsHeader(onBack: () => Navigator.of(context).maybePop()),
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
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Dismissible(
                    key: Key('${item.title}-${item.time}-$index'),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      context.read<HomeProvider>().removeNotification(index);
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: NotificationTile(item: item),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
