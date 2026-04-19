import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ai_material.dart';
import '../services/courses_service.dart';

class AiMaterialsProvider extends ChangeNotifier {
  AiMaterialsProvider({required this.courseId, CoursesService? service})
      : _service = service ?? CoursesService();

  final String courseId;
  final CoursesService _service;

  List<AiMaterial> _materials = [];
  List<AiMaterial> get materials => _materials;

  GenerationJobStatus _status = GenerationJobStatus.idle;
  GenerationJobStatus get status => _status;

  String? _error;
  String? get error => _error;

  Timer? _pollingTimer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadMaterials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _materials = await _service.fetchCourseMaterials(courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startGeneration() async {
    if (_status.isInProgress) return;

    _isLoading = true;
    _error = null;
    _status = GenerationJobStatus.pending;
    notifyListeners();

    try {
      final jobId = await _service.createCourseMaterialJob(courseId);
      if (jobId.isNotEmpty) {
        _startPolling(jobId);
      } else {
        _status = GenerationJobStatus.failed;
        _error = 'Failed to start generation job';
      }
    } catch (e) {
      _status = GenerationJobStatus.failed;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling(String jobId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final statusData = await _service.fetchCourseMaterialStatus(jobId);
        final statusStr = statusData['status'] as String? ?? 'pending';
        final newStatus = GenerationJobStatus.fromString(statusStr);

        if (newStatus != _status) {
          _status = newStatus;
          notifyListeners();
        }

        if (newStatus.isFinal) {
          _pollingTimer?.cancel();
          if (newStatus == GenerationJobStatus.completed) {
            await loadMaterials();
          }
        }
      } catch (e) {
        debugPrint('[AiMaterialsProvider] Polling error: $e');
        // We don't necessarily stop on first polling error, but could if needed
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
