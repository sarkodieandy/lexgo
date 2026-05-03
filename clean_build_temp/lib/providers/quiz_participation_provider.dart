import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz/quiz_model.dart';
import '../services/student_quiz_service.dart';

class QuizParticipationProvider extends ChangeNotifier {
  QuizParticipationProvider({StudentQuizService? service})
    : _service = service ?? StudentQuizService();

  final StudentQuizService _service;

  QuizModel? _quiz;
  QuizModel? get quiz => _quiz;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final Map<String, String> _selectedAnswers = {};
  Map<String, String> get selectedAnswers => Map.unmodifiable(_selectedAnswers);

  Timer? _timer;
  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  Map<String, dynamic>? _result;
  Map<String, dynamic>? get result => _result;

  String get timeLabel {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> startQuiz(String quizId) async {
    _isLoading = true;
    _error = null;
    _result = null;
    _currentIndex = 0;
    _selectedAnswers.clear();
    notifyListeners();

    try {
      _quiz = await _service.getQuizDetails(quizId);
      if (_quiz != null) {
        _secondsRemaining = (_quiz!.durationMinutes ?? 0) * 60;
        _startTimer();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        submitQuiz(); 
      }
    });
  }

  void selectOption(String questionId, String option) {
    if (_isSubmitting) return;
    _selectedAnswers[questionId] = option;
    notifyListeners();
  }

  void nextQuestion() {
    if (_quiz == null || _currentIndex >= _quiz!.questions.length - 1) return;
    _currentIndex++;
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentIndex <= 0) return;
    _currentIndex--;
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (_quiz == null || index < 0 || index >= _quiz!.questions.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> submitQuiz() async {
    if (_quiz == null || _isSubmitting) return;

    _timer?.cancel();
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final answers = _selectedAnswers.entries.map((e) => {
        'questionId': e.key,
        'selectedOption': e.value,
      }).toList();

      _result = await _service.submitQuiz(_quiz!.id, answers);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
