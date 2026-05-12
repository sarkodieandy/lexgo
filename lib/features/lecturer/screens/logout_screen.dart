import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandDark,
      body: Column(
        children: [
          _LogoutHeader(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brandDanger.withAlpha(38),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.info,
                            size: 36,
                            color: AppColors.brandDanger,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'leaving Already?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Are you sure you want to Log out?',
                        style: TextStyle(fontSize: 14, color: AppColors.mutedText),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppColors.brandDark, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                foregroundColor: AppColors.brandDark,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                final auth = context.read<AuthProvider>();
                                try {
                                  await auth.logout();
                                  navigator.popUntil((route) => route.isFirst);
                                } catch (_) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        auth.error ?? 'Logout failed',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandDanger,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Log Out'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutHeader extends StatelessWidget {
  const _LogoutHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.brandDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios, color: AppColors.brandDark, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Center(
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.brandWhite,
                  fontSize: 20,
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
