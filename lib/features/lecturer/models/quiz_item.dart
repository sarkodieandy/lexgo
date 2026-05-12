import 'quiz/quiz_model.dart';

class QuizItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final int questions;
  final Duration duration;

  const QuizItem({
    this.id = '',
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.questions,
    required this.duration,
  });

  factory QuizItem.fromModel(QuizModel model) {
    final due = model.quizEndTime ?? model.quizStartTime ?? DateTime.now();
    final durationMinutes = model.durationMinutes ?? 0;
    return QuizItem(
      id: model.id,
      title: model.title,
      subtitle: model.description ?? model.courseTitle ?? 'Course quiz',
      dueDate: due,
      questions: model.questionCount ?? 0,
      duration: Duration(minutes: durationMinutes),
    );
  }
}
