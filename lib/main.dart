import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:lexgo/services/notes_api_service.dart';
import 'package:lexgo/models/note_model.dart';
import 'package:lexgo/features/courses/screens/course_list_screen.dart';
import 'package:lexgo/features/ask_ai/screens/ask_ai_screen.dart';
import 'package:lexgo/features/help/screens/help_center_screen.dart';
import 'package:lexgo/features/dictionary/screens/dictionary_screen.dart';
import 'package:lexgo/services/user_stats_service.dart';
import 'package:lexgo/services/auth_api_service.dart';
import 'package:lexgo/services/quiz_api_service.dart';
import 'package:lexgo/models/quiz_model.dart';
import 'package:lexgo/features/auth/screens/forgot_password_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lexgo/features/ask_ai/screens/companion_screen.dart';
import 'package:lexgo/features/help/screens/case_help_screen.dart';
import 'package:lexgo/shared/widgets/hero_carousel.dart';

import 'package:lexgo/features/auth/screens/role_selection_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize tokens from secure storage before app start
  await AuthApiService.initTokens();
  
  runApp(const LexGoApp());
}

class LexGoApp extends StatelessWidget {
  const LexGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B162C), // Deep dark navy from image
          primary: const Color(0xFF0B162C),
          surface: const Color(0xFFF5F5F5), // Light gray background
        ),
        scaffoldBackgroundColor: const Color(0xFFEBEBEB),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final base = GoogleFonts.poppins(fontSize: 12);
            if (states.contains(WidgetState.selected)) {
              return base.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              );
            }
            return base.copyWith(color: Colors.grey);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.black);
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<Widget> get _screens => [
    DashboardScreen(onNavigateToQuiz: () => _onItemTapped(2)),
    CasesScreen(onNavigateToQuiz: () => _onItemTapped(2)),
    const QuizCreationScreen(),
    const CourseListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Cases',
            ),
            NavigationDestination(
              icon: Icon(Icons.access_time),
              selectedIcon: Icon(Icons.access_time_filled),
              label: 'Quiz',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'courses',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToQuiz;

  const DashboardScreen({super.key, this.onNavigateToQuiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      drawer: const LexGoDrawer(),
      body: Builder(
        builder: (context) => SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildHeroCarousel(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Home',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.list, color: Colors.black),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              if (NotificationsScreen.notifications.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${NotificationsScreen.notifications.length}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel(BuildContext context) {
    return HeroCarousel(
      onCaseTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CaseDetailsScreen(onNavigateToQuiz: onNavigateToQuiz),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B162C),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildActionItem(
                  'Practice Quiz',
                  'Test your knowledge',
                  Icons.chat_bubble_outline,
                  const Color(0xFFFFF6DF), // Light yellow
                  const Color(0xFFD4A017), // Yellow icon color
                  onTap: onNavigateToQuiz,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionItem(
                  'Ask AI',
                  'Get instant help with legal concept',
                  Icons.help_outline,
                  Colors.white,
                  Colors.blue,
                  iconWidget: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.question_mark,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AskAiScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildActionItem(
                  'Take Notes',
                  'organize your thoughts',
                  Icons.auto_stories_outlined, // Book icon
                  const Color(0xFFFFF0F0), // Light red
                  Colors.redAccent,
                  iconWidget: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, color: Colors.red, size: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotesListScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionItem(
                  'Dictionary',
                  'Study landmark decisions',
                  Icons.book_outlined,
                  const Color(0xFFF5F5F5), // Light grey
                  Colors.grey.shade800,
                  iconWidget: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.menu_book,
                      color: Colors.grey.shade800,
                      size: 20,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DictionaryScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    Widget? iconWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          if (iconWidget != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: iconWidget),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class LexGoDrawer extends StatefulWidget {
  const LexGoDrawer({super.key});

  @override
  State<LexGoDrawer> createState() => _LexGoDrawerState();
}

class _LexGoDrawerState extends State<LexGoDrawer> {
  int _studyStreak = 0;
  int _casesStudied = 0;
  int _aiChats = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final statsService = UserStatsService();
    await statsService.updateStudyStreak();
    final stats = await statsService.getStats();
    if (mounted) {
      setState(() {
        _studyStreak = stats['studyStreak'] ?? 0;
        _casesStudied = stats['casesStudied'] ?? 0;
        _aiChats = stats['aiChats'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Header: LexGo Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LexGo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B162C),
                        ),
                      ),
                      Text(
                        'Smart Legal Learning',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Quick Stats Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Quick Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Study Streak',
              '$_studyStreak days',
              const Color(0xFFE88A1A),
            ), // Orange text
            const SizedBox(height: 12),
            _buildStatRow('Cases Studied', '$_casesStudied', Colors.blue),
            const SizedBox(height: 12),
            _buildStatRow('AI Chats', '$_aiChats', Colors.grey.shade800),

            const Spacer(),

            // Menu Items
            _buildMenuItem(
              context,
              Icons.notifications_none,
              'Notification',
              badgeCount: NotificationsScreen.notifications.length,
              onTap: () {
                // Close the drawer first
                Navigator.pop(context);
                // Then navigate
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.headset_mic_outlined,
              'Companion',
              customIcon: Image.asset(
                'assets/images/companion_icon.png',
                width: 24,
                height: 24,
                color: const Color(0xFF2D3748),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanionScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.info_outline,
              'Help Center',
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.logout,
              'Log Out',
              onTap: () async {
                try {
                  await AuthApiService().logout();
                } catch (_) {}
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                await prefs.setBool(
                  'onboardingComplete',
                  false,
                ); // Reset for testing

                if (context.mounted) {
                  // Safely clear the navigation stack to avoid context errors
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 48),

            // Bottom Profile Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBBF24), // Yellow-orange from image
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Law Student',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0B162C),
                        ),
                      ),
                      FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          String name = 'LexGo Member';
                          if (snapshot.hasData) {
                            name =
                                snapshot.data!.getString('userName') ??
                                'LexGo Member';
                          }
                          return Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatRow(String label, String value, Color valueColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF2D3748)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------

Widget _buildMenuItem(
  BuildContext context,
  IconData icon,
  String title, {
  int badgeCount = 0,
  Widget? customIcon,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap ?? () {},
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              customIcon ??
                  Icon(icon, color: const Color(0xFF2D3748), size: 24),
              if (badgeCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF2D3748)),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// A single source of truth for notification data.
// Replace these items with real API data when the notifications endpoint
// is implemented. The badge counts on the home screen and drawer are
// automatically derived from this list's length.
// ---------------------------------------------------------------------------

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String time;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  /// All current notifications in one place.
  /// The badge count on the home screen and drawer is
  /// `notifications.length` — no separate hardcoded number needed.
  // ignore: library_private_types_in_public_api
  static List<_NotificationItem> notifications = [
    _NotificationItem(
      icon: Icons.article_outlined,
      iconColor: Color(0xFFD4A017),
      iconBgColor: Color(0xFFFFF6DF),
      title: 'New Case Added',
      subtitle: 'The Republic vs. Agnes Baidoo has been added to cases',
      time: '06:00AM',
    ),
    _NotificationItem(
      icon: Icons.menu_book_outlined,
      iconColor: Colors.blue,
      iconBgColor: Color(0xFFEBF8FF),
      title: 'New Course Added',
      subtitle: 'Basic Law Terms has been added to Courses',
      time: '06:30AM',
    ),
    _NotificationItem(
      icon: Icons.military_tech_outlined,
      iconColor: Colors.red,
      iconBgColor: Color(0xFFFFEBEE),
      title: 'Course Completed',
      subtitle: 'Congratulations on your new knowledge acquired.',
      time: '08:00AM',
    ),
    _NotificationItem(
      icon: Icons.article_outlined,
      iconColor: Color(0xFFD4A017),
      iconBgColor: Color(0xFFFFF6DF),
      title: 'New Case Added',
      subtitle: 'Max Trade Ltd vs. Rex Trade Ltd has been added to cases',
      time: '08:00AM',
    ),
    _NotificationItem(
      icon: Icons.chat_outlined,
      iconColor: Color(0xFF374151),
      iconBgColor: Color(0xFFE5E7EB),
      title: 'Case of the Day',
      subtitle:
          'The Republic vs. Mensah has been updated as the case of the day',
      time: '12:00PM',
    ),
    _NotificationItem(
      icon: Icons.chat_outlined,
      iconColor: Color(0xFF374151),
      iconBgColor: Color(0xFFE5E7EB),
      title: 'Today in Legal History',
      subtitle: 'Aug 18, 1960 was Ghana\'s first Supreme Court session',
      time: '06:00AM',
    ),
    _NotificationItem(
      icon: Icons.menu_book_outlined,
      iconColor: Colors.blue,
      iconBgColor: Color(0xFFEBF8FF),
      title: 'New Course Added',
      subtitle: 'Contract Law has been added to Courses',
      time: '06:30AM',
    ),
  ];

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB), // Light grey background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          80.0,
        ), // Custom height for curved appbar
        child: Container(
          padding: const EdgeInsets.only(
            top: 40,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0B162C),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Expanded(
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 48,
              ), // To balance the back button for centering
            ],
          ),
        ),
      ),
      body: NotificationsScreen.notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: NotificationsScreen.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = NotificationsScreen.notifications[index];
                return Dismissible(
                  key: ValueKey('${n.title}_${n.time}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      NotificationsScreen.notifications.removeAt(index);
                    });
                  },
                  child: _buildNotificationCard(
                    icon: n.icon,
                    iconColor: n.iconColor,
                    iconBgColor: n.iconBgColor,
                    title: n.title,
                    subtitle: n.subtitle,
                    time: n.time,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = await AuthApiService.isLoggedIn();

    if (isLoggedIn) {
      try {
        final authService = AuthApiService();
        // Load tokens into memory before doing anything else
        await AuthApiService.initTokens();

        // Wait at least a bit to show splash screen, while refreshing token
        await Future.wait([
          Future.delayed(const Duration(seconds: 2)),
          authService.refreshToken(),
        ]);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        }
      } catch (e) {
        // Only force logout if the server specifically rejected the token
        if (e.toString().contains('Session expired')) {
          await prefs.setBool('isLoggedIn', false);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          // It's a network error/timeout. Allow entry to the dashboard.
          // ApiClient will handle any actual 401s on subsequent requests.
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
            );
          }
        }
      }
    } else {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

      if (!onboardingComplete) {
        // First-time user — show the onboarding flow
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      } else {
        // Returning user who logged out — go straight to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C), // Dark navy
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_white.png',
                  width: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/tagline_white.png',
                  width: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 80), // offset slightly
              ],
            ),
          ),

          // Loader at the bottom
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _universityController = TextEditingController();
  final _studentIdController = TextEditingController();

  String _selectedLevel = 'Level 100';
  String _selectedProgram = 'LL.B';

  final List<String> _academicLevels = [
    'Level 100',
    'Level 200',
    'Level 300',
    'Level 400',
    'Level 500',
    'Post-Graduate'
  ];

  final List<String> _programs = ['LL.B', 'LL.M', 'M.A', 'PFD'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _universityController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Success: ${account.email}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    }
  }

  Future<void> _handleSignUp() async {
    // ── Client-side validation ────────────────────────────────────────────────
    if (!_agreeToTerms) {
      _showError('You must agree to the terms and conditions.');
      return;
    }

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneNumberController.text.trim();
    final university = _universityController.text.trim();
    final studentId = _studentIdController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        university.isEmpty ||
        studentId.isEmpty) {
      _showError('Please fill in all required fields.');
      return;
    }

    final parts = fullName.split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;

    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthApiService();
      await authService.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone,
        university: university,
        email: email,
        password: password,
        confirmPassword: password,
        role: 'student',
        acadamicLevel: _selectedLevel,
        program: _selectedProgram,
        studentId: studentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSocialIcon(Widget icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0B162C)),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(fontSize: 12, color: Color(0xFFE84C3D)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Icon(icon, color: const Color(0xFF0B162C), size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0B162C), size: 20),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (route) => false,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Us and Be Part of Something Great!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // ── Fields ──
              _buildInputField(
                label: 'Email',
                hint: 'Enter your Email',
                icon: Icons.mail_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Full Name',
                hint: 'Enter Your Full Name',
                icon: Icons.person_outline,
                controller: _fullNameController,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Phone Number',
                hint: 'e.g. +233XXXXXXXXX',
                icon: Icons.phone_outlined,
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'University',
                hint: 'Enter Your University',
                icon: Icons.school_outlined,
                controller: _universityController,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                label: 'Student ID',
                hint: 'Enter Your Student ID',
                icon: Icons.badge_outlined,
                controller: _studentIdController,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Academic Level',
                      value: _selectedLevel,
                      items: _academicLevels,
                      onChanged: (v) => setState(() => _selectedLevel = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Program',
                      value: _selectedProgram,
                      items: _programs,
                      onChanged: (v) => setState(() => _selectedProgram = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Terms checkbox ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (v) =>
                          setState(() => _agreeToTerms = v ?? false),
                      activeColor: const Color(0xFF0B162C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade400, width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: 'By clicking Sign Up, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: TextStyle(color: Color(0xFFE84C3D)),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: TextStyle(color: Color(0xFFE84C3D)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Sign Up button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _agreeToTerms ? _handleSignUp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B162C),
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Social divider ──
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(
                    Text(
                      'G',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    _handleGoogleSignIn,
                  ),
                  const SizedBox(width: 24),
                  _buildSocialIcon(
                    const Icon(Icons.apple, size: 28, color: Color(0xFF0B162C)),
                    () {},
                  ),
                  const SizedBox(width: 24),
                  _buildSocialIcon(
                    Text(
                      'X',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Login link ──
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(
                            color: Color(0xFF0B162C),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google Sign-In Success: ${account.email}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthApiService();
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);

      String userName = 'LexGo User';
      if (_emailController.text.isNotEmpty) {
        userName = _emailController.text.split('@').first;
      }
      await prefs.setString('userName', userName);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildSocialIcon(Widget icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC), // Very faint grey background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Icon(icon, color: const Color(0xFF0B162C), size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0B162C), size: 20),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (route) => false,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Logo Header
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),

              // Title Section
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log In to Unlock the Experience',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildInputField(
                label: 'Email',
                hint: 'Enter your Email',
                icon: Icons.mail_outline,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0B162C),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Log In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B162C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              // Social Icons
              Wrap(
                spacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildSocialIcon(
                    Text(
                      'G',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    _handleGoogleSignIn,
                  ),
                  _buildSocialIcon(
                    const Icon(Icons.apple, size: 28, color: Color(0xFF0B162C)),
                    () {},
                  ),
                  _buildSocialIcon(
                    Text(
                      'X',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Bottom Sign Up Text
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(text: "Don't have an Account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF0B162C),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data model for a case entry ─────────────────────────────────────────────
class _CaseEntry {
  final String title;
  final String source;
  final String code;
  final String category;
  final Color categoryColor;
  final bool hasReadButton;

  const _CaseEntry({
    required this.title,
    required this.source,
    required this.code,
    required this.category,
    required this.categoryColor,
    this.hasReadButton = true,
  });
}

class CasesScreen extends StatefulWidget {
  final VoidCallback? onNavigateToQuiz;
  const CasesScreen({super.key, this.onNavigateToQuiz});

  @override
  State<CasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory; // null means "All"

  static const List<_CaseEntry> _allCases = [
    _CaseEntry(
      title: 'The Republic v. Kofi Mensah',
      source: 'Supreme Court of Ghana',
      code: '[2024] GHASC 15',
      category: 'Administrative Law',
      categoryColor: Color(0xFFD32F2F),
      hasReadButton: true,
    ),
    _CaseEntry(
      title: 'Mensah v. Attorney General',
      source: 'Court of Appeal, Accra',
      code: '[2023] GHACA 42',
      category: 'Constitutional Law',
      categoryColor: Color(0xFF673AB7),
      hasReadButton: true,
    ),
    _CaseEntry(
      title: 'Asante Trading Co. v. Boateng',
      source: 'High Court, Kumasi',
      code: '[2022] GHHCK 07',
      category: 'Contract Law',
      categoryColor: Color(0xFF0277BD),
      hasReadButton: false,
    ),
    _CaseEntry(
      title: 'Republic v. Adjei-Mensah',
      source: 'Supreme Court of Ghana',
      code: '[2021] GHASC 30',
      category: 'Criminal Law',
      categoryColor: Color(0xFFE65100),
      hasReadButton: true,
    ),
    _CaseEntry(
      title: 'Owusu v. Ghana Revenue Authority',
      source: 'Tax Appeals Board',
      code: '[2023] GHTAB 11',
      category: 'Administrative Law',
      categoryColor: Color(0xFFD32F2F),
      hasReadButton: false,
    ),
  ];

  static const List<String> _categories = [
    'All',
    'Administrative Law',
    'Constitutional Law',
    'Contract Law',
    'Criminal Law',
  ];

  List<_CaseEntry> get _filteredCases {
    return _allCases.where((c) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.source.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || c.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Filter by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B162C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      final isSelected = cat == 'All'
                          ? _selectedCategory == null
                          : _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {});
                          setState(() {
                            _selectedCategory = cat == 'All' ? null : cat;
                          });
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0B162C)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0B162C)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCases;
    final isFiltered = _selectedCategory != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      drawer: const LexGoDrawer(),
      body: Builder(
        builder: (context) => SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cases',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.list, color: Colors.black),
                          ),
                          if (NotificationsScreen.notifications.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${NotificationsScreen.notifications.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Content Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search and Filter Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) =>
                                      setState(() => _searchQuery = val),
                                  decoration: const InputDecoration(
                                    hintText: 'Search cases...',
                                    hintStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _openFilterSheet,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isFiltered
                                      ? const Color(0xFFD32F2F)
                                      : const Color(0xFF0B162C),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.tune, color: Colors.white),
                                    if (isFiltered)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Active filter chip
                      if (isFiltered)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 10,
                            right: 20,
                          ),
                          child: Row(
                            children: [
                              Chip(
                                label: Text(
                                  _selectedCategory!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF0B162C),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                onDeleted: () =>
                                    setState(() => _selectedCategory = null),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Cases List
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No cases found',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (ctx, i) {
                                  final c = filtered[i];
                                  return _buildCaseCard(
                                    context: ctx,
                                    title: c.title,
                                    source: c.source,
                                    code: c.code,
                                    category: c.category,
                                    categoryColor: c.categoryColor,
                                    hasReadButton: c.hasReadButton,
                                    onReadPressed: i == 0
                                        ? () {
                                            UserStatsService()
                                                .incrementCasesStudied();
                                            Navigator.push(
                                              ctx,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CaseDetailsScreen(
                                                      caseTitle: c.title,
                                                      onNavigateToQuiz: widget
                                                          .onNavigateToQuiz,
                                                    ),
                                              ),
                                            );
                                          }
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard({
    BuildContext? context,
    required String title,
    required String source,
    required String code,
    required String category,
    required Color categoryColor,
    required bool hasReadButton,
    VoidCallback? onReadPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Watermark (Scales of Justice)
          Positioned(
            right: 0,
            top: 20,
            child: Icon(
              Icons.balance,
              size: 160,
              color: Colors.grey.withValues(alpha: 0.06), // Very faint
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B162C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  source,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.balance, size: 16, color: categoryColor),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                if (hasReadButton) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onReadPressed ?? () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Read',
                        style: TextStyle(
                          color: Color(0xFF0B162C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CaseDetailsScreen extends StatefulWidget {
  final VoidCallback? onNavigateToQuiz;
  final String caseTitle;

  const CaseDetailsScreen({
    super.key,
    this.onNavigateToQuiz,
    this.caseTitle = 'The Republic v. Kofi Mensah',
  });

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  bool _isGeneratingQuiz = false;

  Future<void> _launchCaseQuiz(int questionCount) async {
    Navigator.pop(context); // close bottom sheet
    setState(() => _isGeneratingQuiz = true);
    try {
      final apiService = QuizApiService();
      final jobId = await apiService.createQuiz(
        topic: widget.caseTitle,
        difficultyLevel: 'Medium',
        numberOfQuiz: questionCount,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizLoadingScreen(jobId: jobId)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGeneratingQuiz = false);
    }
  }

  void _showQuizCountPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Test Your Knowledge',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0B162C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How many questions would you like?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Questions are generated specifically for:\n"${widget.caseTitle}"',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            // 5 Questions option
            _buildQuizOption(
              count: 5,
              label: '5 Questions',
              subtitle: 'Quick review · ~3 min',
              icon: Icons.flash_on_rounded,
              iconColor: Colors.amber.shade700,
            ),
            const SizedBox(height: 12),
            // 10 Questions option
            _buildQuizOption(
              count: 10,
              label: '10 Questions',
              subtitle: 'Deep dive · ~6 min',
              icon: Icons.school_rounded,
              iconColor: const Color(0xFF0B162C),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption({
    required int count,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => _launchCaseQuiz(count),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B162C),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            widget.caseTitle.length > 22
                ? '${widget.caseTitle.substring(0, 22)}..'
                : widget.caseTitle,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CaseHelpScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 32.0,
            bottom: 40.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon
              Center(
                child: Icon(
                  Icons.balance,
                  size: 64,
                  color: const Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Meta
              Center(
                child: Text(
                  widget.caseTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B162C),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Supreme Court of Ghana',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  '[2023] GHASC 15',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ),
              const SizedBox(height: 32),

              // Coram
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Coram: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B162C),
                      ),
                    ),
                    TextSpan(
                      text: 'Anin-Yeboah CJ, Dotse JSC, Appau JSC',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Structured Sections Title
              const Text(
                'Structured Sections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionField(
                'Facts',
                '- The accused allegedly robbed a shopkeeper at night.\n'
                    '- Witnesses claimed they saw Mensah fleeing the scene.\n\n'
                    'Kofi Mensah was charged with robbery under the Criminal Offences Act, 1960 (Act 29). It was alleged that on the 3rd of January 2022, he attacked and robbed a shopkeeper in Kumasi. Mensah denied the charges, claiming mistaken identity. The case escalated to the Supreme Court after an appeal from the Court of Appeal.',
              ),
              const SizedBox(height: 20),

              _buildSectionField(
                'Issues',
                '- Whether the identification of Mensah was reliable.\n'
                    '- Whether the conviction at the lower court was valid.',
              ),
              const SizedBox(height: 20),

              _buildSectionField(
                'Holding',
                '- The Supreme Court overturned the conviction.',
              ),
              const SizedBox(height: 20),

              _buildSectionField(
                'Reasoning',
                '- Whether the conviction at the lower court was valid.\n\n'
                    'Identification evidence was unreliable; prosecution failed to prove guilt beyond reasonable doubt.',
              ),
              const SizedBox(height: 20),

              _buildSectionField(
                'Significance',
                '- Reinforces the principle that criminal convictions must rest on strong, reliable identification evidence.',
              ),
              const SizedBox(height: 20),

              _buildSectionField(
                'Related Cases',
                '-- Republic v. Arthur [2018] GHASC 10\n'
                    '-- Republic v. Boateng [2015] GCA 22',
              ),
              const SizedBox(height: 48),

              // Quiz Section
              const Text(
                'Test your knowledge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B162C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-generated questions tailored to this case.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isGeneratingQuiz ? null : _showQuizCountPicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B162C),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isGeneratingQuiz
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Take Quiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionField(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B162C),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.5, // nice line height for readability
            ),
          ),
        ),
      ],
    );
  }
}

class QuizCreationScreen extends StatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  State<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final QuizApiService _apiService = QuizApiService();
  String? _selectedArea;
  static const List<String> _legalAreas = [
    'Constitutional Law',
    'Criminal Law',
    'Contract Law',
    'Tort Law',
    'Evidence Law',
    'Property Law',
    'Administrative Law',
    'Corporate Law',
    'Family Law',
  ];
  String _selectedDifficulty = 'Easy';
  int _selectedQuestions = 10;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      drawer: const LexGoDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Builder(
                    builder: (BuildContext innerContext) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuizListScreen(),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.list, color: Colors.black),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '6',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Content Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Legal Area Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedArea,
                        hint: Text(
                          'Choose a legal area to practice',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade100),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0B162C),
                            ),
                          ),
                        ),
                        items: _legalAreas.map((area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(
                              area,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedArea = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Difficulty Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDifficultyCard(
                        'Easy',
                        'Basic concepts and definitions',
                      ),
                      const SizedBox(height: 12),
                      _buildDifficultyCard(
                        'Medium',
                        'Application and analysis',
                      ),
                      const SizedBox(height: 12),
                      _buildDifficultyCard(
                        'Hard',
                        'Complex scenarios and synthesis',
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'Number of Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildNumberButton(5),
                          _buildNumberButton(10),
                          _buildNumberButton(15),
                          _buildNumberButton(20),
                        ],
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  if (_selectedArea == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select a legal area to practice.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final jobId = await _apiService.createQuiz(
                                      topic: _selectedArea ?? 'General Law',
                                      difficultyLevel: _selectedDifficulty
                                          .toLowerCase(),
                                      numberOfQuiz: _selectedQuestions,
                                    );

                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              QuizLoadingScreen(jobId: jobId),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceAll(
                                              'Exception: ',
                                              '',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                          label: Text(
                            _isLoading ? 'Generating...' : 'Start Quiz',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B162C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(String title, String subtitle) {
    bool isSelected = _selectedDifficulty == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0B162C)
              : const Color(0xFFFCFCFC), // Off-white if unselected
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEB82), // Soft yellow
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    bool isSelected = _selectedQuestions == number;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuestions = number;
        });
      },
      child: Container(
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B162C) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B162C) : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class TakeQuizScreen extends StatefulWidget {
  final String quizId;
  const TakeQuizScreen({super.key, required this.quizId});

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int _selectedOption = -1;
  int _currentQuestionIndex = 0;
  final QuizApiService _apiService = QuizApiService();
  Quiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;
  int _score = 0;
  final List<int> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final quiz = await _apiService.getQuiz(widget.quizId);
      if (mounted) {
        setState(() {
          _quiz = quiz;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _handleNextOrSubmit() async {
    if (_quiz == null || _selectedOption == -1) return;

    _userAnswers.add(_selectedOption);
    final currentQ = _quiz!.questions[_currentQuestionIndex];
    final selectedText = currentQ.options[_selectedOption].trim().toLowerCase();
    final correct = currentQ.correctAnswer.trim();

    // The API may return correctAnswer as "A"/"B"/"C"/"D" (letter index)
    // OR as the full option text. Handle both.
    bool isCorrect = false;
    if (correct.length == 1 &&
        correct.toUpperCase().codeUnitAt(0) >= 65 &&
        correct.toUpperCase().codeUnitAt(0) <= 90) {
      // Letter index format: A=0, B=1, C=2, D=3
      final correctIndex = correct.toUpperCase().codeUnitAt(0) - 65;
      isCorrect = _selectedOption == correctIndex;
    } else {
      // Full text comparison (case-insensitive, trimmed)
      isCorrect = selectedText == correct.toLowerCase();
    }
    if (isCorrect) {
      _score++;
    }

    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = -1; // Reset selection
      });
    } else {
      // Submit score
      setState(() => _isLoading = true);
      try {
        await _apiService.submitQuizScore(widget.quizId, _score);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizResultScreen(
                score: _score,
                total: _quiz!.questions.length,
                quiz: _quiz!,
                userAnswers: _userAnswers,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to submit: ${e.toString().replaceAll('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exit Quiz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'If you quit now, your progress in this quiz will be lost and your answers will not be saved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainNavigationScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B162C),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _showExitConfirmation(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            title: Text(
              'Review Quiz',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        body: _isLoading || _quiz == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              )
            : Column(
                children: [
                  // Header info & progress
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF0B162C),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Answer these questions to review core concepts in criminal law.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Progress Bar Background
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            // Progress Fill
                            child: FractionallySizedBox(
                              widthFactor:
                                  (_currentQuestionIndex + 1) /
                                  _quiz!.questions.length,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B7F76),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Main White Card Content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Question Number and Timer Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.help_outline,
                                              color: Colors.blueAccent,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Question ${_currentQuestionIndex + 1} of ${_quiz!.questions.length}',
                                              style: GoogleFonts.poppins(
                                                color: Colors.blueAccent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: Colors.grey.shade600,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '60S',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Question Text
                                    Text(
                                      _quiz!.questions[_currentQuestionIndex].question,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Options
                                    ...List.generate(
                                      _quiz!
                                          .questions[_currentQuestionIndex]
                                          .options
                                          .length,
                                      (i) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: _buildOptionCard(
                                          i,
                                          '${String.fromCharCode(65 + i)})', // Converts 0 to A), 1 to B)
                                          _quiz!
                                              .questions[_currentQuestionIndex]
                                              .options[i],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Bottom Navigation Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 52,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        if (_currentQuestionIndex > 0) {
                                          setState(() {
                                            _currentQuestionIndex--;
                                            _selectedOption = -1;
                                          });
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Previous',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _selectedOption == -1
                                          ? null
                                          : _handleNextOrSubmit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0B162C,
                                        ),
                                        disabledBackgroundColor:
                                            Colors.grey.shade300,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        _currentQuestionIndex ==
                                                _quiz!.questions.length - 1
                                            ? 'Finish Quiz'
                                            : 'Next Question',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOptionCard(int index, String letter, String text) {
    bool isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              letter,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesApiService _apiService = NotesApiService();
  List<Note> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.getAllNotes(limit: 50);
      setState(() {
        _notes = result['notes'] as List<Note>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            'Notes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: _buildBodyContent(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0B162C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
          ).then(
            (_) => _fetchNotes(),
          ); // Refresh list when returning from CreateNoteScreen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading notes',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchNotes, child: Text('Retry')),
          ],
        ),
      );
    }

    if (_notes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24.0),
      itemCount: _notes.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey.shade300, height: 32),
      itemBuilder: (context, index) {
        final note = _notes[index];
        // Assign a tag color based on importance for now
        Color tagColor = const Color(0xFFF5F5F5); // default grey
        if (note.importanceLevel == 'High Priority') {
          tagColor = const Color(0xFFFFEBEE); // red
        }
        if (note.importanceLevel == 'Medium Priority') {
          tagColor = const Color(0xFFFFF3E0); // orange
        }
        if (note.importanceLevel == 'Low Priority') {
          tagColor = const Color(0xFFE8F5E9); // green
        }

        return _buildNoteItem(note, tagColor);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0B162C), width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: Color(0xFF0B162C),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notes Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B162C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You haven't created any notes. Start writing to save important ideas and key points for later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(Note note, Color tagColor) {
    return GestureDetector(
      onTap: () {
        // We'll pass the note to the workspace screen to edit
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteWorkspaceScreen(note: note)),
        ).then((_) => _fetchNotes()); // Refresh list when returning
      },
      child: Container(
        color: Colors.transparent, // Ensure tap area covers whole row
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.legalTopic,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy').format(note.updatedAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.more_horiz, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final NotesApiService _apiService = NotesApiService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedTopic = 'Contracts';
  String _selectedImportance = 'Medium Priority';
  bool _isSaving = false;

  final List<String> _topics = [
    'Contracts',
    'Family Law',
    'Criminal Law',
    'Tort Law',
    'Constitutional Law',
  ];
  final List<String> _importanceLevels = [
    'Low Priority',
    'Medium Priority',
    'High Priority',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and note details.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newNote = await _apiService.createNote(
        title: title,
        legalTopic: _selectedTopic,
        importanceLevel: _selectedImportance,
        content: content,
      );

      if (!mounted) return;

      // Go to workspace directly and pass the newly created Note object
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NoteWorkspaceScreen(note: newNote)),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            'Notes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.grey.shade600,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Contracts',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTopic,
                    items: _topics.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTopic = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Importance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedImportance,
                    items: _importanceLevels.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedImportance = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Note Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Start writing...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _createNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B162C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Create Note',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteWorkspaceScreen extends StatefulWidget {
  final Note note;
  const NoteWorkspaceScreen({super.key, required this.note});

  @override
  State<NoteWorkspaceScreen> createState() => _NoteWorkspaceScreenState();
}

class _NoteWorkspaceScreenState extends State<NoteWorkspaceScreen> {
  final NotesApiService _apiService = NotesApiService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    final updatedTitle = _titleController.text.trim();
    final updatedContent = _contentController.text;
    if (updatedTitle == widget.note.title &&
        updatedContent == widget.note.content) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _apiService.updateNote(
        id: widget.note.id,
        title: updatedTitle,
        content: updatedContent,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note saved!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF162541),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            'Note Label',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.greenAccent),
              tooltip: 'Save Note',
              onPressed: _isSaving ? null : _updateNote,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              offset: const Offset(0, 48),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(context);
                } else if (value == 'share') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon'),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share_outlined,
                        color: Color(0xFF0B162C),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Share',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0B162C),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF0B162C),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0B162C),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.05,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5A5A5A),
                      ),
                      decoration: InputDecoration(
                        hintText: '|Title',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5A5A5A).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Type notes here',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 60,
              width: double.infinity,
              color: const Color(0xFF0B162C),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.format_bold, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Text(
                      '/',
                      style: GoogleFonts.poppins(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.format_strikethrough,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.format_underlined,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Note',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.black87),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  setState(() => _isSaving = true);
                  await _apiService.deleteNote(widget.note.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting: ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// QUIZ SCREENS (List, Loading, Result)
// ---------------------------------------------------------------------------

class QuizListScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const QuizListScreen({super.key, this.onBackToHome});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final QuizApiService _apiService = QuizApiService();
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final res = await _apiService.getAllQuizzes(limit: 50);
      if (mounted) {
        setState(() {
          _quizzes = res['quizzes'] as List<Quiz>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          if (widget.onBackToHome != null) {
                            widget.onBackToHome!();
                          } else if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Quizzes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              )
            : _quizzes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No past quizzes found.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuizCreationScreen(),
                          ),
                        ).then((_) => _fetchQuizzes());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B162C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create New Quiz',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount:
                    _quizzes.length + 1, // Add 1 for the "Create" button at top
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizCreationScreen(),
                            ),
                          ).then(
                            (_) => _fetchQuizzes(),
                          ); // Refresh list when popping back
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B162C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '+ Create New Quiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final quiz = _quizzes[index - 1];
                  final percentage = quiz.totalQuestions > 0
                      ? (quiz.score / quiz.totalQuestions * 100).toInt()
                      : 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.topic,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${quiz.difficultyLevel.toUpperCase()} • ${quiz.totalQuestions} Questions',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                color: percentage >= 70
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              quiz.completed ? 'Completed' : 'In Progress',
                              style: TextStyle(
                                color: quiz.completed
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class QuizLoadingScreen extends StatefulWidget {
  final String jobId;
  const QuizLoadingScreen({super.key, required this.jobId});

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> {
  final QuizApiService _apiService = QuizApiService();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pollStatus();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _pollStatus() async {
    while (!_isDisposed) {
      try {
        final res = await _apiService.getQuizStatus(widget.jobId);
        final status = res['status'];

        if (status == 'completed') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => TakeQuizScreen(quizId: res['quizId']),
            ),
          );
          return; // Exit polling loop
        } else if (status == 'failed') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Quiz generation failed')),
          );
          Navigator.pop(context);
          return; // Exit polling loop
        }
      } catch (e) {
        // Just swallow error during polling, keep trying unless it's a fatal crash
      }

      // Wait before next ping
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.grey.shade400,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Please wait... setting things up',
              style: TextStyle(
                color: Color(0xFF0B162C),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final Quiz quiz;
  final List<int> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.quiz,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (score / total) * 100 : 0;
    final int wrong = total - score;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkmark circles
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE8F6EE),
                        ),
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFC0EACF),
                            ),
                            child: Center(
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00D170),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Congratulations',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Excellent Work Done',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'You Scored',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _buildStatBox('Total Questions', total.toString()),
                          const SizedBox(width: 12),
                          _buildStatBox('Correct', score.toString()),
                          const SizedBox(width: 12),
                          _buildStatBox('wrong', wrong.toString()),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuestionReviewScreen(
                                        quiz: quiz,
                                        userAnswers: userAnswers,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black87),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Review Quiz',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MainNavigationScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B162C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Return to home',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF8F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionReviewScreen extends StatelessWidget {
  final Quiz quiz;
  final List<int> userAnswers;

  const QuestionReviewScreen({
    super.key,
    required this.quiz,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B162C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Question Review',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: quiz.questions.length,
          itemBuilder: (context, index) {
            final question = quiz.questions[index];
            final userAnswerIndex = userAnswers.length > index
                ? userAnswers[index]
                : -1;
            final correct = question.correctAnswer.trim();
            bool isCorrect = false;
            if (userAnswerIndex != -1) {
              final selected = question.options[userAnswerIndex]
                  .trim()
                  .toLowerCase();
              if (correct.length == 1 &&
                  correct.toUpperCase().codeUnitAt(0) >= 65 &&
                  correct.toUpperCase().codeUnitAt(0) <= 90) {
                final correctIndex = correct.toUpperCase().codeUnitAt(0) - 65;
                isCorrect = userAnswerIndex == correctIndex;
              } else {
                isCorrect = selected == correct.toLowerCase();
              }
            }

            return _buildQuestionCard(
              index + 1,
              question,
              userAnswerIndex,
              isCorrect,
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    int number,
    QuizQuestion question,
    int userAnswerIndex,
    bool isCorrect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Question $number',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // User Answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFFE8F6EE)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Your answer: ${userAnswerIndex != -1 ? question.options[userAnswerIndex] : "No answer"}',
              style: TextStyle(
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (!isCorrect) ...[
            const SizedBox(height: 12),
            // Correct Answer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Correct Answer: ${question.correctAnswer}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          // Explanation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explanation : ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Text(
                  question.explanation.isNotEmpty
                      ? question.explanation
                      : 'No explanation available.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
