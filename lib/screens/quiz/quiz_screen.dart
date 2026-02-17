import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_item.dart';
import '../../providers/quiz_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quiz/quiz_card.dart';
import '../../widgets/sidebar.dart';
import 'quize_1.dart';

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
    final quizzes = quizProvider.quizItems;
    return Scaffold(
      drawer: const Sidebar(),
      backgroundColor: AppColors.brandDark,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const Quiz1())),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Text(
          '+',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
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
                child: _buildQuizList(quizzes, quizProvider),
              ),
            ),
          ],
        ),
      ),
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
      physics: const BouncingScrollPhysics(),
      itemCount: quizzes.length,
      itemBuilder: (_, index) => QuizCard(
        item: quizzes[index],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Quiz1(title: quizzes[index].title)),
        ),
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
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.brandDark,
              ),
            ),
          ),
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
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset('assets/Union.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
