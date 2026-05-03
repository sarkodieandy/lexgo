import 'package:flutter/material.dart';

import '../../models/course_question.dart';
import '../../theme/app_colors.dart';
import 'answer_question_sheet.dart';

class CourseQATab extends StatelessWidget {
  const CourseQATab({super.key});

  static final List<CourseQuestion> _sampleQuestions = [
    CourseQuestion(
      id: 'qa-1',
      studentName: 'Mike Adjatey',
      studentId: '22345678',
      question:
          'Good day sir, please what is the difference between constitutional law and evidence law?',
      askedAt: DateTime(2025, 9, 4, 6, 0),
    ),
    CourseQuestion(
      id: 'qa-2',
      studentName: 'Kojo Asante',
      studentId: '22195055',
      question: 'What is the principle of Separation of Powers?',
      askedAt: DateTime(2025, 9, 5, 18, 0),
    ),
    CourseQuestion(
      id: 'qa-3',
      studentName: 'Ama Boateng',
      studentId: '22130074',
      question: 'Can you explain judicial review in simple terms?',
      askedAt: DateTime(2025, 9, 4, 6, 0),
    ),
    CourseQuestion(
      id: 'qa-4',
      studentName: 'Kofi Mensah',
      studentId: '22125693',
      question:
          'Why is the Rule of Law important for constitutional democracy?',
      askedAt: DateTime(2025, 9, 4, 6, 0),
    ),
    CourseQuestion(
      id: 'qa-5',
      studentName: 'Kwesi Nimo',
      studentId: '22191057',
      question: 'How does constitutional supremacy protect citizens?',
      askedAt: DateTime(2025, 9, 4, 6, 0),
    ),
    CourseQuestion(
      id: 'qa-6',
      studentName: 'Yaw Darko',
      studentId: '22174641',
      question: 'What are fundamental rights in constitutional law?',
      askedAt: DateTime(2025, 9, 4, 6, 0),
    ),
    CourseQuestion(
      id: 'qa-7',
      studentName: 'Andrew Kaine',
      studentId: '22153103',
      question: 'How does federalism differ from unitary governance?',
      askedAt: DateTime(2025, 9, 4, 6, 0),
    ),
  ];

  void _openAnswerSheet(BuildContext context, CourseQuestion question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnswerQuestionSheet(question: question),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _sampleQuestions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final question = _sampleQuestions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openAnswerSheet(context, question),
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: AppColors.brandWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFEC0D2F),
                  child: Text(
                    question.studentName[0],
                    style: const TextStyle(
                      color: AppColors.brandWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${question.studentName} - ${question.studentId}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                question.formattedDate,
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                question.formattedTime,
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.brandDark,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B3B3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
