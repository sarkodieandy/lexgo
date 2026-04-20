import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/quiz/quiz_model.dart';
import '../models/quiz/submission_record.dart';
import '../models/quiz_item.dart';
import '../services/quiz_service.dart';
import '../services/student_quiz_service.dart';

class QuizProvider extends ChangeNotifier {
   QuizProvider({QuizService? service, StudentQuizService? studentService})
    : _service = service ?? QuizService(),
      _studentService = studentService ?? StudentQuizService();

  final QuizService _service;
  final StudentQuizService _studentService;
  final List<QuizModel> _quizzes = [];
  final List<SubmissionRecord> _submissions = [];
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _error;

  UnmodifiableListView<QuizItem> get quizItems =>
      UnmodifiableListView(_quizzes.map(QuizItem.fromModel).toList());

  List<QuizModel> get quizzes => List.unmodifiable(_quizzes);
  List<SubmissionRecord> get submissions => List.unmodifiable(_submissions);
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get error => _error;

  Future<void> loadQuizzes({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await _service.fetchMyQuizzes(page: page, limit: limit);
      _quizzes
        ..clear()
        ..addAll(items);
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseQuizzes(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await _service.fetchCourseQuizzes(courseId);
      _quizzes
        ..clear()
        ..addAll(items);
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<QuizModel> createManualQuiz({
    required String courseId,
    required String title,
    required String description,
    required int quizDurationMinutes,
    required DateTime quizStartTime,
    DateTime? quizEndTime,
    int? attempts,
    Map<String, dynamic>? grade,
    bool? shuffleQuestions,
    bool? shuffleAnswers,
    bool? showScoresImmediately,
    required List<Map<String, dynamic>> questions,
  }) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      final quiz = await _service.createManualQuiz(
        courseId: courseId,
        title: title,
        description: description,
        quizDurationMinutes: quizDurationMinutes,
        quizStartTime: quizStartTime,
        quizEndTime: quizEndTime,
        attempts: attempts,
        grade: grade,
        shuffleQuestions: shuffleQuestions,
        shuffleAnswers: shuffleAnswers,
        showScoresImmediately: showScoresImmediately,
        questions: questions,
      );
      _quizzes.insert(0, quiz);
      return quiz;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<QuizModel> createAutoQuiz({
    required String courseId,
    required String title,
    required String description,
    required String documentPath,
    int? quizDurationMinutes,
    DateTime? quizStartTime,
    DateTime? quizEndTime,
    int? attempts,
    bool? shuffleQuestions,
    bool? shuffleAnswers,
    bool? showScoresImmediately,
    int? numberOfQuestions,
    String? difficultyLevel,
  }) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      final quiz = await _service.createAutoQuiz(
        courseId: courseId,
        title: title,
        description: description,
        documentPath: documentPath,
        quizDurationMinutes: quizDurationMinutes,
        quizStartTime: quizStartTime,
        quizEndTime: quizEndTime,
        attempts: attempts,
        shuffleQuestions: shuffleQuestions,
        shuffleAnswers: shuffleAnswers,
        showScoresImmediately: showScoresImmediately,
        numberOfQuestions: numberOfQuestions,
        difficultyLevel: difficultyLevel,
      );
      _quizzes.insert(0, quiz);
      return quiz;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    _isActionLoading = true;
    notifyListeners();
    try {
      await _service.deleteQuiz(quizId);
      _quizzes.removeWhere((q) => q.id == quizId);
    } catch (err) {
      _error = err.toString();
      rethrow;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  /// For Students: Fetches full details including questions (correct answer stripped by backend)
  Future<QuizModel> getStudentQuizDetails(String quizId) async {
    return await _studentService.getQuizDetails(quizId);
  }

  Future<void> loadSubmissions(String quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await _service.fetchQuizSubmissions(quizId);
      _submissions
        ..clear()
        ..addAll(items);
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
