import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Forward-declare the screens we'll navigate to.
// They live in main.dart and are accessible via the library.
import 'package:lexgo/main.dart' show SignUpScreen, LoginScreen;

// ─────────────────────────────────────────────
// Data model for a single onboarding slide
// ─────────────────────────────────────────────
class _OnboardingPage {
  final IconData icon;
  final double iconSize;
  final String? headline;
  final String? body;
  final bool isCta; // last slide shows CTA buttons instead of a Next arrow

  const _OnboardingPage({
    required this.icon,
    this.iconSize = 100,
    this.headline,
    this.body,
    this.isCta = false,
  });
}

// ─────────────────────────────────────────────
// The 4 slides, matching the provided designs
// ─────────────────────────────────────────────
const _pages = [
  // Slide 1 — Cinematic logo reveal (icon only)
  _OnboardingPage(
    icon: Icons.balance,
    iconSize: 130,
  ),

  // Slide 2 — Study Smarter
  _OnboardingPage(
    icon: Icons.menu_book_rounded,
    iconSize: 90,
    headline: 'Study Smarter',
    body:
        'Access law cases, course materials, and your notes — all in one place. Built for law students on the move.',
  ),

  // Slide 3 — Practice & Quiz
  _OnboardingPage(
    icon: Icons.quiz_outlined,
    iconSize: 90,
    headline: 'Practice & Quiz',
    body:
        'Test your knowledge with AI-generated quizzes tailored to your courses. Track your progress and improve fast.',
  ),

  // Slide 4 — AI Legal Assistant (CTA)
  _OnboardingPage(
    icon: Icons.auto_awesome,
    iconSize: 90,
    headline: 'Your AI Legal\nAssistant',
    body:
        'Ask any legal question and get instant, accurate answers powered by cutting-edge AI. Law on the Go.',
    isCta: true,
  ),
];

// ─────────────────────────────────────────────
// Main OnboardingScreen widget
// ─────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Per-page content animation controllers
  late AnimationController _contentAnimCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _contentAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentAnimCtrl, curve: Curves.easeOut));
    _contentAnimCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentAnimCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _contentAnimCtrl.reset();
    _contentAnimCtrl.forward();
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }

  void _goToSignUp() {
    _markOnboardingComplete();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignUpScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _goToLogin() {
    _markOnboardingComplete();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      body: Stack(
        children: [
          // ── Legal-icon watermark background ──────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Skip button ──────────────────────────────────────────
          if (_currentPage < _pages.length - 1)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── PageView ─────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (_, index) => const SizedBox.expand(),
          ),

          // ── Animated slide content ───────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildPageContent(page, size),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom controls ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: page.isCta
                    ? _buildCtaButtons()
                    : _buildNavRow(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Slide content layout ───────────────────────────────────────────────────
  Widget _buildPageContent(_OnboardingPage page, Size size) {
    final isFirstSlide = _currentPage == 0;

    return Column(
      mainAxisAlignment:
          isFirstSlide ? MainAxisAlignment.center : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFirstSlide) ...[
          // Cinematic logo reveal — centred, big
          Center(
            child: Column(
              children: [
                Icon(
                  page.icon,
                  size: page.iconSize,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'LexGo',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Law on the Go',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Feature slides — left-aligned, Netflix style
          const SizedBox(height: 48),
          // Gradient accent line
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Icon(
            page.icon,
            size: page.iconSize,
            color: Colors.white,
          ),
          const SizedBox(height: 40),
          if (page.headline != null)
            Text(
              page.headline!,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -1,
              ),
            ),
          if (page.body != null) ...[
            const SizedBox(height: 20),
            Text(
              page.body!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.6,
              ),
            ),
          ],
        ],
      ],
    );
  }

  // ── Navigation row (slides 1-3) ────────────────────────────────────────────
  Widget _buildNavRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page dots
        Row(
          children: List.generate(_pages.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 6),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),

        // Next arrow
        GestureDetector(
          onTap: _next,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF0B162C),
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  // ── CTA buttons (last slide) ───────────────────────────────────────────────
  Widget _buildCtaButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page dots centred above buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 6),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),

        // Get Started (primary)
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _goToSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0B162C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Sign In (secondary / ghost)
        SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: _goToLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
