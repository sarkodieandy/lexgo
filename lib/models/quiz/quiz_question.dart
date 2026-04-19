class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String? correctAnswer;
  final String? explanation;
  final int mark;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.correctAnswer,
    this.explanation,
    this.mark = 1,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correctAnswer'] as String?,
      explanation: json['explanation'] as String?,
      mark: (json['mark'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      if (correctAnswer != null) 'correctAnswer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
      'mark': mark,
    };
  }
}
