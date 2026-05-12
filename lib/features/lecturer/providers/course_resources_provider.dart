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

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _nextCursor;
  String? _error;
  String? get error => _error;

  Future<void> load({int limit = 25}) async {
    if (courseId.trim().isEmpty) {
      _error = 'Missing course ID';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _nextCursor = null;
    _hasMore = false;
    notifyListeners();
    try {
      final response = await _service.fetchCourseResources(
        courseId: courseId,
        limit: limit,
      );
      _resources
        ..clear()
        ..addAll(response.data);
      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({int limit = 25}) async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;

    _isLoadingMore = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _service.fetchCourseResources(
        courseId: courseId,
        cursor: _nextCursor,
        limit: limit,
      );
      _resources.addAll(response.data);
      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

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

  Future<void> deleteCourse() async {
    if (courseId.trim().isEmpty) return;
    await _service.deleteCourse(courseId);
  }
}

