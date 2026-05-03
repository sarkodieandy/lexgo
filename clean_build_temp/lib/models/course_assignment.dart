class CourseAssignment {
  const CourseAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.points,
    this.gradeScale = '100 marks',
    this.submissionType = 'file Upload',
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String dueTime;
  final int points;
  final String gradeScale;
  final String submissionType;

  String get dueDateLabel {
    final month = _monthNames[dueDate.month - 1];
    return 'Due $month ${dueDate.day}, ${dueDate.year}';
  }

  String get dueDateOnly {
    final month = _monthNames[dueDate.month - 1];
    return '$month ${dueDate.day}, ${dueDate.year}';
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
