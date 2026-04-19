import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/courses_service.dart';

class CoursesProvider extends ChangeNotifier {
  CoursesProvider({CoursesService? service}) : _service = service ?? CoursesService();

  final CoursesService _service;

  List<Course> _courses = [];
  List<Course> get courses => List.unmodifiable(_courses);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  String? _error;
  String? get error => _error;

  /// Load all courses for the authenticated lecturer.
  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _courses = await _service.fetchCourses();
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Course> createCourse({
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
      final course = await _service.createCourse(
        title: title,
        category: category,
        institution: institution,
        level: level,
        courseCode: courseCode,
        description: description,
        imagePath: imagePath,
      );
      _courses.insert(0, course);
      notifyListeners();
      return course;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }
}
