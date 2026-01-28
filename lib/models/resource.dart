class CourseResource {
  const CourseResource({
    required this.title,
    required this.size,
    required this.timestamp,
  });

  final String title;
  final String size;
  final DateTime timestamp;

  String get formattedTimestamp {
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
    final month = monthNames[timestamp.month - 1];
    final day = timestamp.day.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final isPm = timestamp.hour >= 12;
    final hour = (timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12)
        .toString()
        .padLeft(2, '0');
    final suffix = isPm ? 'PM' : 'AM';
    return '$size • $month $day, ${timestamp.year} • $hour:$minute $suffix';
  }
}
