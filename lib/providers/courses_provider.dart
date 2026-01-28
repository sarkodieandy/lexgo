import 'package:flutter/material.dart';

import '../services/courses_service.dart';

class CoursesProvider extends ChangeNotifier {
  CoursesProvider({CoursesService? service}) : _service = service ?? CoursesService();

  final CoursesService _service;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  Future<CourseModel> createCourse({
    required String title,
    required String category,
    required String institution,
    required String level,
    required String courseCode,
    String? description,
    required String imagePath,
  }) async {
    _isCreating = true;
    notifyListeners();
    try {
      return await _service.createCourse(
        title: title,
        category: category,
        institution: institution,
        level: level,
        courseCode: courseCode,
        description: description,
        imagePath: imagePath,
      );
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }
}
