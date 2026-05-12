import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lexgo/services/dictionary_api_service.dart';
import 'package:lexgo/services/user_stats_service.dart';
import 'package:lexgo/features/dictionary/screens/dictionary_screen.dart';

// Forward-declare CaseDetailsScreen to avoid a circular import.
// main.dart passes the screen builder via a callback instead.
// We receive it through [onCaseTap].

// ─── Auto-scrolling Hero Carousel ────────────────────────────────────────────

class HeroCarousel extends StatefulWidget {
  final VoidCallback? onCaseTap;

  const HeroCarousel({super.key, this.onCaseTap});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final List<_CarouselCard> _cards;

  // ── Deterministic daily word picker ────────────────────────────────────────
  static String _wordOfTheDay() {
    final allTerms = <String>[];
    for (final terms in DictionaryApiService.legalTermsByLetter.values) {
      allTerms.addAll(terms);
    }
    if (allTerms.isEmpty) return 'Habeas Corpus';
    final now = DateTime.now();
    final dayOfYear = int.parse(DateFormat('D').format(now));
    return allTerms[dayOfYear % allTerms.length];
  }

  // ── Rotating daily dictum ───────────────────────────────────────────────────
  static const _dicta = [
    ('Justice must not only be done,\nbut must be seen to be done.', 'Lord Hewart'),
    ('The law is reason free from passion.', 'Aristotle'),
    ('Equal justice under law.', 'US Supreme Court'),
    ('No man is above the law.', 'Theodore Roosevelt'),
    ('Justice delayed is justice denied.', 'William Gladstone'),
    ('The law is the last resort of the powerless.', 'Jay-Z'),
    ('Fiat justitia ruat caelum\n– Let justice be done though the heavens fall.', 'William Murray'),
    ('An unjust law is no law at all.', 'St. Augustine'),
    ('The sword of justice has no scabbard.', 'Antoine de Rivard'),
    ('In law, nothing is certain but the expense.', 'Samuel Butler'),
  ];

  static (String, String) _dictumOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = int.parse(DateFormat('D').format(now));
    return _dicta[dayOfYear % _dicta.length];
  }

  // ── Rotating daily legal history ────────────────────────────────────────────
  static const _history = [
    ('Aug 18, 1960', "Ghana's first Supreme Court was established."),
    ('May 17, 1954', 'Brown v. Board of Education decided.'),
    ('Jul 4, 1776', 'US Declaration of Independence signed.'),
    ('Dec 10, 1948', 'Universal Declaration of Human Rights adopted.'),
    ('Mar 29, 1867', 'British North America Act enacted.'),
    ('Jun 15, 1215', 'Magna Carta sealed by King John.'),
    ('Jan 1, 1960', 'Ghana gains independence — Rule of Law anchored.'),
    ('Apr 20, 1970', 'Earth Day Act signed into law.'),
    ('Nov 20, 1989', 'UN Convention on the Rights of the Child adopted.'),
    ('Sep 17, 1787', 'US Constitution signed.'),
  ];

  static (String, String) _historyOfTheDay() {
    final now = DateTime.now();
    final dayOfYear = int.parse(DateFormat('D').format(now));
    return _history[dayOfYear % _history.length];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final word = _wordOfTheDay();
    final (dictum, dictumAuthor) = _dictumOfTheDay();
    final (historyDate, historyDesc) = _historyOfTheDay();

    _cards = [
      _CarouselCard(
        icon: Icons.balance,
        label: '⚖️ Case of the Day',
        title: 'The Republic v. John Smith',
        subtitle: 'Supreme Court of Ghana · Administrative Law · Tap to read',
        accentColor: const Color(0xFF1A2940),
        onTap: () {
          UserStatsService().incrementCasesStudied();
          widget.onCaseTap?.call();
        },
      ),
      _CarouselCard(
        icon: Icons.menu_book_outlined,
        label: '📖 Legal Term of the Day',
        title: word,
        subtitle: 'Tap to look up the full definition in the dictionary',
        accentColor: const Color(0xFF0F3460),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DictionaryScreen()),
          );
        },
      ),
      _CarouselCard(
        icon: Icons.format_quote,
        label: '💬 Dictum of the Day',
        title: '"$dictum"',
        subtitle: '— $dictumAuthor',
        accentColor: const Color(0xFF16213E),
        onTap: null,
      ),
      _CarouselCard(
        icon: Icons.history_edu,
        label: '🗓️ Today in Legal History',
        title: historyDate,
        subtitle: historyDesc,
        accentColor: const Color(0xFF1B1B2F),
        onTap: null,
      ),
    ];

    // Auto-advance every 5 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      final next = (_currentPage + 1) % _cards.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _cards.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _cards[i],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Animated indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_cards.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF0B162C) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Individual carousel card ─────────────────────────────────────────────────

class _CarouselCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback? onTap;

  const _CarouselCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -20,
              child: Icon(
                icon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tap to open →',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
