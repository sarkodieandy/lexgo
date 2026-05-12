enum SubmissionStatus { graded, pending }

class AssignmentSubmission {
  const AssignmentSubmission({
    required this.studentName,
    required this.studentId,
    required this.fileName,
    required this.submittedAt,
    required this.timeTaken,
    required this.score,
    required this.status,
    required this.dueTime,
    required this.email,
  });

  final String studentName;
  final String studentId;
  final String email;
  final String fileName;
  final String submittedAt;
  final String timeTaken;
  final String score;
  final SubmissionStatus status;
  final String dueTime;
}
