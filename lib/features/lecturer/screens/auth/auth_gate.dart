import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../main_navigation_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  final VoidCallback? onBack;
  const AuthGate({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isBootstrapping) {
      return const _SplashScreen();
    }

    if (!auth.isAuthenticated) {
      return LoginScreen(onBack: onBack);
    }

    return const MainNavigationScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.brandDark,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.brandWhite),
      ),
    );
  }
}

