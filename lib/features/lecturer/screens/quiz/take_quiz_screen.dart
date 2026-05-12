import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/quiz_participation_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/navigation/app_back_button.dart';
import 'quiz_results_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  const TakeQuizScreen({super.key, required this.quizId});

  final String quizId;

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizParticipationProvider>().startQuiz(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizParticipationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.brandDark,
            body: Center(child: CircularProgressIndicator(color: AppColors.brandWhite)),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            backgroundColor: AppColors.brandDark,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final quiz = provider.quiz;
        if (quiz == null) return const SizedBox.shrink();

        final currentQuestion = quiz.questions[provider.currentIndex];

        return Scaffold(
          backgroundColor: AppColors.brandDark,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(provider),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildProgressIndicator(provider),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildQuestionText(provider.currentIndex + 1, currentQuestion.question),
                                const SizedBox(height: 24),
                                ...currentQuestion.options.map((option) => _buildOptionTile(
                                      provider,
                                      currentQuestion.id,
                                      option,
                                    )),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                        _buildFooter(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(QuizParticipationProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.quiz?.title ?? 'Quiz',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  provider.quiz?.courseTitle ?? "",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandNavy,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  provider.timeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(QuizParticipationProvider provider) {
    final total = provider.quiz?.questions.length ?? 1;
    final progress = (provider.currentIndex + 1) / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${provider.currentIndex + 1} of $total',
                style: const TextStyle(
                  color: AppColors.brandDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Done',
                style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EAF3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionText(int number, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'QUESTION $number',
            style: const TextStyle(
              color: AppColors.brandDark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.brandDark,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(QuizParticipationProvider provider, String questionId, String option) {
    final isSelected = provider.selectedAnswers[questionId] == option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => provider.selectOption(questionId, option),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0F4FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.brandDark : const Color(0xFFE8EAF3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.brandDark.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.brandDark : const Color(0xFF4B4B4B),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.brandDark, size: 24)
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE8EAF3), width: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(QuizParticipationProvider provider) {
    final isLast = provider.currentIndex == (provider.quiz?.questions.length ?? 0) - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (provider.currentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isSubmitting ? null : provider.previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE8EAF3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(color: AppColors.brandDark, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (provider.currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: provider.isSubmitting
                  ? null
                  : (isLast ? _showSubmitConfirmation : provider.nextQuestion),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? const Color(0xFF10C17D) : AppColors.brandDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                isLast ? (provider.isSubmitting ? 'Submitting...' : 'Submit Quiz') : 'Next Question',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch, size: 64, color: AppColors.brandDark),
            const SizedBox(height: 24),
            const Text(
              'Submit Quiz?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to submit? You cannot change your answers after submission.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedText, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(modalContext).pop(),
                    child: const Text('No, keep working', style: TextStyle(color: AppColors.mutedText)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                      _handleFinalSubmit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Yes, Submit',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFinalSubmit() async {
    final provider = context.read<QuizParticipationProvider>();
    await provider.submitQuiz();
    if (mounted && provider.result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultsScreen(result: provider.result!),
        ),
      );
    }
  }
}
