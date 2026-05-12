import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_item.dart';
import '../../providers/home_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quiz/quiz_card.dart';
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
    final homeProvider = context.watch<HomeProvider>();
    final quizzes = quizProvider.quizItems;

    return Column(
      children: [
        const _Header(),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: _buildQuizList(quizzes, quizProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizList(List<QuizItem> quizzes, QuizProvider provider) {
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: quizzes.length,
      itemBuilder: (_, index) {
        final item = quizzes[index];
        return QuizCard(
          item: item,
          onTap: () => _showQuizInfoSheet(item),
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
      decoration: const BoxDecoration(color: AppColors.brandDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Quiz',
            style: TextStyle(
              color: AppColors.brandWhite,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.brandWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: Color(0xFF0D0D0D),
                      size: 24,
                    ),
                  ),
                ),
              ),
              if (homeProvider.notificationCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3D71),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${homeProvider.notificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
    );
  }
}
