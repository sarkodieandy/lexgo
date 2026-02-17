import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/quiz/quiz_model.dart';
import '../models/quiz_item.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider({QuizService? service}) : _service = service ?? QuizService();

  final QuizService _service;
  final List<QuizModel> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  UnmodifiableListView<QuizItem> get quizItems =>
      UnmodifiableListView(_quizzes.map(QuizItem.fromModel).toList());

  bool get isLoading => _isLoading;
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
}
