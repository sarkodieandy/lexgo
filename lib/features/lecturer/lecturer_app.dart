import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cases_provider.dart';
import 'providers/course_assignments_provider.dart';
import 'providers/courses_provider.dart';
import 'providers/home_provider.dart';
import 'providers/quiz_participation_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

class LecturerApp extends StatelessWidget {
  /// Called when the user taps the back button on the auth screens.
  /// This should pop the outer (main app) navigator, returning to
  /// the role selection screen.
  final VoidCallback? onBack;

  const LecturerApp({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (_) => HomeProvider(),
          update: (_, auth, home) {
            if (home == null) return HomeProvider()..userName = auth.userName;
            return home..userName = auth.userName;
          },
        ),
        ChangeNotifierProvider(create: (_) => CourseAssignmentsProvider()),
        ChangeNotifierProvider(create: (_) => CasesProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => QuizParticipationProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'LexGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AuthGate(onBack: onBack),
      ),
    );
  }
}
