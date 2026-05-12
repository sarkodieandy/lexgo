import 'dart:convert';
import 'package:lexgo/services/api_client.dart' as http;
import '../models/course_model.dart';
import 'package:lexgo/services/auth_api_service.dart';
import '../config/app_config.dart';

class CourseApiService {
  static String get _baseUrl => '$kApiBase/api/v1/Courses';

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final accessToken = AuthApiService.memoryAccessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  /// Create a Course
  Future<Map<String, dynamic>> createCourse({
    required String title,
    String? institution,
    String? level,
    String? courseCode,
  }) async {
    final uri = Uri.parse(_baseUrl);
    final headers = await _getHeaders();
    final body = json.encode({
      'title': title,
      'institution': institution,
      'level': level,
      'courseCode': courseCode,
    });

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return {
        'success': true,
        'course': Course.fromJson(jsonResponse['data'] ?? jsonResponse),
        'message': jsonResponse['message'] ?? 'Course created successfully!',
      };
    } else {
      dynamic msg = 'Failed to create course (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// Get Courses (Lecturer/Owner View or General List if applicable)
  Future<Map<String, dynamic>> getCourses({
    int limit = 25,
    String? cursor,
  }) async {
    final queryParams = <String, String>{'limit': '$limit'};
    if (cursor != null) queryParams['cursor'] = cursor;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
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
    } else {
      throw Exception('Could not load courses (${response.statusCode}).');
    }
  }
}
