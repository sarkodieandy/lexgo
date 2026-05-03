class AssignmentProgress {
  final String title;
  final String description;
  final int completed;
  final int total;

  const AssignmentProgress({
    required this.title,
    required this.description,
    required this.completed,
    required this.total,
  });
}

class AssignedCategory {
  final String subject;
  final List<AssignmentProgress> assignments;

  const AssignedCategory({
    required this.subject,
    required this.assignments,
  });
}
