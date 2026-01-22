import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Displays the dark header with the hero card and drawer trigger.
class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    required this.userName,
    required this.notificationCount,
    required this.onMenuTap,
  });

  final String userName;
  final int notificationCount;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.brandWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset('assets/Union.png', fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandWhite,
                  ),
                ),
                const Spacer(),
                NotificationToggle(count: notificationCount, onTap: onMenuTap),
              ],
            ),
            const SizedBox(height: 20),
            HomeHeroCard(userName: userName),
          ],
        ),
      ),
    );
  }
}

class NotificationToggle extends StatelessWidget {
  const NotificationToggle({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.brandWhite,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(Icons.menu, color: AppColors.brandDark),
            ),
            if (count > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.brandWhite,
                      fontSize: 10,
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

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandNavy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Image.asset(
              'assets/Vector.png',
              width: 120,
              height: 120,
              color: AppColors.brandWhite.withAlpha(51),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Day, $userName',
                style: const TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready to inspire your students? Let’s make today productive.',
                style: TextStyle(color: AppColors.brandAccent, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
