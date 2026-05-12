import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lexgo/features/auth/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lexgo/features/lecturer/lecturer_app.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _animationState = 0;

  @override
  void initState() {
    super.initState();
    _playAnimation();
  }

  Future<void> _playAnimation() async {
    // 0: Start with blank background
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _animationState = 1); // Fade in Logo

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _animationState = 2); // Fade in Text

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _animationState = 3); // Fade in Buttons
  }

  Future<void> _openLecturerApp(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', 'lecturer');
    if (!ctx.mounted) return;
    // Capture navigator BEFORE the async gap so it stays valid.
    final navigator = Navigator.of(ctx);
    navigator.push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LecturerApp(
          // When the user taps back inside LecturerApp, pop this route
          // and return to the role selection screen.
          onBack: () => navigator.pop(),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  AnimatedOpacity(
                    opacity: _animationState >= 1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      'assets/images/logo_white.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: _animationState >= 1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: Image.asset(
                      'assets/images/tagline_white.png',
                      width: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Role Buttons
                  AnimatedOpacity(
                    opacity: _animationState >= 3 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        _RoleButton(
                          title: 'Law Student',
                          onTap: () async {
                            if (_animationState < 3) return;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('userRole', 'student');
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const OnboardingScreen(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(opacity: anim, child: child),
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _RoleButton(
                          title: 'Law Lecturer',
                          onTap: () async {
                            if (_animationState < 3) return;
                            await _openLecturerApp(context);
                          },
                        ),
                        const SizedBox(height: 16),
                        _RoleButton(
                          title: 'Law Aspirant',
                          onTap: () async {
                            if (_animationState < 3) return;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('userRole', 'law aspirant');
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Law Aspirant flow coming soon.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0B162C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

