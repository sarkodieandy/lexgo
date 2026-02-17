import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cases_provider.dart';
import 'providers/course_assignments_provider.dart';
import 'providers/courses_provider.dart';
import 'providers/home_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const LexGoApp());
}

class LexGoApp extends StatelessWidget {
  const LexGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseAssignmentsProvider()),
        ChangeNotifierProvider(create: (_) => CasesProvider()),
        ChangeNotifierProvider(create: (_) => CoursesProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp(
        title: 'LexGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
