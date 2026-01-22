class QuizItem {
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final int questions;
  final Duration duration;

  const QuizItem({
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.questions,
    required this.duration,
  });
}
