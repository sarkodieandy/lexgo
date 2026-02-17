class QuizModel {
  const QuizModel({
    required this.id,
    required this.title,
    this.description,
    this.courseId,
    this.courseTitle,
    this.quizStartTime,
    this.quizEndTime,
    this.durationMinutes,
    this.questionCount,
    this.attempts,
    this.isPublished,
  });

  final String id;
  final String title;
  final String? description;
  final String? courseId;
  final String? courseTitle;
  final DateTime? quizStartTime;
  final DateTime? quizEndTime;
  final int? durationMinutes;
  final int? questionCount;
  final int? attempts;
  final bool? isPublished;

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    String? parseCourseId(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return (value['_id'] as String?) ?? (value['id'] as String?);
      }
      return null;
    }

    String? parseCourseTitle(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['title'] as String?;
      }
      return null;
    }

    int? parseQuestionCount(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is List) return value.length;
      return int.tryParse(value.toString());
    }

    return QuizModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Quiz',
      description: json['description'] as String?,
      courseId: parseCourseId(json['courseId'] ?? json['course']),
      courseTitle: json['courseTitle'] as String? ??
          parseCourseTitle(json['courseId'] ?? json['course']),
      quizStartTime: parseDate(json['quizStartTime'] as String?),
      quizEndTime: parseDate(json['quizEndTime'] as String?),
      durationMinutes: parseInt(json['quizDuration']),
      questionCount:
          parseQuestionCount(json['questionCount'] ?? json['questions']),
      attempts: parseInt(json['attempts']),
      isPublished: json['isPublished'] as bool?,
    );
  }
}
