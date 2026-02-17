import 'package:flutter/material.dart';

import '../models/resource.dart';
import '../services/courses_service.dart';

class CourseResourcesProvider extends ChangeNotifier {
  CourseResourcesProvider({
    required this.courseId,
    CoursesService? service,
  }) : _service = service ?? CoursesService();

  final String courseId;
  final CoursesService _service;

  final List<CourseResource> _resources = [];
  List<CourseResource> get resources => List.unmodifiable(_resources);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _error;
  String? get error => _error;

  Future<void> load({int page = 1, int limit = 20}) async {
    if (courseId.trim().isEmpty) {
      _error = 'Missing course ID';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _service.fetchCourseResources(
        courseId: courseId,
        page: page,
        limit: limit,
      );
      _resources
        ..clear()
        ..addAll(response.data);
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upload(String filePath) async {
    if (courseId.trim().isEmpty) {
      _error = 'Missing course ID';
      notifyListeners();
      return;
    }

    _isUploading = true;
    _error = null;
    notifyListeners();
    try {
      final resource = await _service.uploadResource(
        courseId: courseId,
        filePath: filePath,
      );
      _resources.insert(0, resource);
    } catch (err) {
      _error = err.toString();
      rethrow;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}

