import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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
      color: AppColors.brandDark,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          const Text(
            'Home',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.brandWhite,
            ),
          ),
          const Spacer(),
          _NotificationButton(count: notificationCount, onTap: onMenuTap),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.brandWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: AppColors.brandDark, size: 22),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.brandNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative watermark on the right
          Positioned(
            right: -8,
            top: -8,
            bottom: -8,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/Union.png',
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Day, $userName',
                style: const TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready to inspire your students? Let\'s make today productive.',
                style: TextStyle(
                  color: Color(0xFFB0BAD4),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
