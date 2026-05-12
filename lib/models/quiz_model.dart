class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

class Quiz {
  final String id;
  final String userId;
  final String topic;
  final String difficultyLevel;
  final int totalQuestions;
  final List<QuizQuestion> questions;
  final int score;
  final bool completed;
  final int? totalQuizzes;
  final num? totalQuizzesScores;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.userId,
    required this.topic,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.questions,
    this.score = 0,
    this.completed = false,
    this.totalQuizzes,
    this.totalQuizzesScores,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      topic: json['topic'] ?? '',
      difficultyLevel: json['difficultyLevel'] ?? 'medium',
      totalQuestions: json['totalQuestions'] ?? 0,
      questions:
          (json['questions'] as List<dynamic>?)
               ?.map((q) => QuizQuestion.fromJson(q))
               .toList() ??
          [],
      score: json['score'] ?? 0,
      completed: json['completed'] ?? false,
      totalQuizzes: json['totalQuizzes'],
      totalQuizzesScores: json['totalQuizzesScores'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'topic': topic,
      'difficultyLevel': difficultyLevel,
      'totalQuestions': totalQuestions,
      'questions': questions.map((q) => q.toJson()).toList(),
      'score': score,
      'completed': completed,
      'totalQuizzes': totalQuizzes,
      'totalQuizzesScores': totalQuizzesScores,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
