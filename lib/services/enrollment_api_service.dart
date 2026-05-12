import 'dart:convert';
import 'package:lexgo/services/api_client.dart' as http;
import '../models/course_model.dart';
import '../models/enrollment_model.dart';
import 'package:lexgo/services/auth_api_service.dart';
import '../config/app_config.dart';

class EnrollmentApiService {
  static String get _baseUrl => '$kApiBase/api/v1/Enrollments';

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final accessToken = AuthApiService.memoryAccessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // ---------------------------------------------------------------------------
  // Student Endpoints
  // ---------------------------------------------------------------------------

  /// 1. Apply for a Course
  /// [courseId] is the ID from the course URL shared by the lecturer.
  /// [courseCode] is the secret code shared by the lecturer.
  Future<Map<String, dynamic>> applyForCourse(
    String courseId,
    String courseCode,
  ) async {
    final uri = Uri.parse('$_baseUrl/apply/$courseId');
    final headers = await _getHeaders();
    final body = json.encode({'courseCode': courseCode});

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      return {
        'success': true,
        'message':
            jsonResponse['message'] ??
            'Application submitted! Your request is awaiting approval.',
      };
    } else if (response.statusCode == 400) {
      dynamic msg = 'Incorrect course code or you have already applied.';
      try {
        msg = json.decode(response.body)['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    } else if (response.statusCode == 404) {
      throw Exception('Course not found. Please check the Course ID.');
    } else if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please log in again.');
    } else {
      dynamic msg =
          'Failed to apply (${response.statusCode}). Please try again.';
      try {
        msg = json.decode(response.body)['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// 2. Get My Enrolled Courses (approved only)
  Future<Map<String, dynamic>> getMyCourses({
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, String>{'limit': '$limit'};
    if (cursor != null) queryParams['cursor'] = cursor;

    final uri = Uri.parse(
      '$_baseUrl/my-courses',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return {
        'success': true,
        'courses': data.map((j) => Course.fromJson(j)).toList(),
        'total': jsonResponse['total'] ?? data.length,
        'nextCursor': jsonResponse['nextCursor'],
        'hasMore': jsonResponse['hasMore'] ?? false,
      };
    } else if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please log in again.');
    } else {
      throw Exception(
        'Could not load your courses (${response.statusCode}). Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Lecturer Endpoints (kept for completeness — not used in student UI)
  // ---------------------------------------------------------------------------

  /// 3. Get Pending Enrollment Requests for a course (Lecturer only)
  Future<Map<String, dynamic>> getPendingRequests(
    String courseId, {
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, String>{'limit': '$limit'};
    if (cursor != null) queryParams['cursor'] = cursor;

    final uri = Uri.parse(
      '$_baseUrl/requests/$courseId/pending',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? [];
      return {
        'success': true,
        'requests': data.map((j) => EnrollmentRequest.fromJson(j)).toList(),
        'total': jsonResponse['total'] ?? data.length,
        'nextCursor': jsonResponse['nextCursor'],
        'hasMore': jsonResponse['hasMore'] ?? false,
      };
    } else if (response.statusCode == 403) {
      throw Exception('You are not the owner of this course.');
    } else if (response.statusCode == 401) {
      throw Exception('Your session has expired. Please log in again.');
    } else {
      throw Exception(
        'Could not load pending requests (${response.statusCode}).',
      );
    }
  }

  /// 4. Approve or Reject a Student (Lecturer only)
  Future<Map<String, dynamic>> handleRequest(
    String courseId,
    String userId,
    bool approve,
  ) async {
    final uri = Uri.parse('$_baseUrl/requests/$courseId/$userId');
    final headers = await _getHeaders();
    final body = json.encode({'action': approve ? 'approve' : 'reject'});

    final response = await http
        .patch(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return {
        'success': true,
        'message':
            jsonResponse['message'] ?? 'Student status updated successfully.',
      };
    } else if (response.statusCode == 403) {
      throw Exception('You are not the owner of this course.');
    } else if (response.statusCode == 400) {
      dynamic msg = 'Invalid action or student never applied.';
      try {
        msg = json.decode(response.body)['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    } else {
      dynamic msg = 'Failed to update student status.';
      try {
        msg = json.decode(response.body)['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
