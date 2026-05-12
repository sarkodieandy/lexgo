class CourseQuestion {
  const CourseQuestion({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.question,
    required this.askedAt,
  });

  final String id;
  final String studentName;
  final String studentId;
  final String question;
  final DateTime askedAt;

  String get formattedDate {
    const monthNames = [
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
    final month = monthNames[askedAt.month - 1];
    return '$month ${askedAt.day}, ${askedAt.year}';
  }

  String get formattedTime {
    final hour = askedAt.hour % 12 == 0 ? 12 : askedAt.hour % 12;
    final minute = askedAt.minute.toString().padLeft(2, '0');
    final suffix = askedAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
