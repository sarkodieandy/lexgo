import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quiz/quiz_card.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/navigation/app_back_button.dart';
import 'quize_1.dart';
import 'take_quiz_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isLecturer = authProvider.currentUser?.role?.toLowerCase() == 'lecturer';
    final quizzes = quizProvider.quizItems;

    return Column(
      children: [
        _Header(onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildQuizList(quizzes, quizProvider, isLecturer),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizList(List<QuizItem> quizzes, QuizProvider provider, bool isLecturer) {
    if (provider.isLoading && quizzes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandDark),
      );
    }

    if (quizzes.isEmpty) {
      final message = provider.error ?? 'No quizzes available';
      return Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.mutedText),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: quizzes.length,
      itemBuilder: (_, index) {
        final item = quizzes[index];
        return QuizCard(
          item: item,
          onTap: () {
            if (isLecturer) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Quiz1(title: item.title, quizId: item.id),
                ),
              );
            } else {
              _showQuizInfoSheet(item);
            }
          },
        );
      },
    );
  }

  void _showQuizInfoSheet(QuizItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              item.subtitle,
              style: const TextStyle(color: AppColors.mutedText, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildInfoBadge(Icons.timer_outlined, '${item.duration.inMinutes} mins'),
                const SizedBox(width: 12),
                _buildInfoBadge(Icons.list_alt_outlined, '${item.questions} Qns'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TakeQuizScreen(quizId: item.id)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brandDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          const Text(
            'Quiz',
            style: TextStyle(
              color: AppColors.brandWhite,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/Union.png', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
