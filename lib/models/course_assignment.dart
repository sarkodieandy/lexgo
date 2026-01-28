class CourseAssignment {
  const CourseAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.points,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String dueTime;
  final int points;

  String get dueDateLabel {
    final month = _monthNames[dueDate.month - 1];
    return 'Due $month ${dueDate.day}, ${dueDate.year}';
  }

  String get pointsLabel => '$points points';

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
