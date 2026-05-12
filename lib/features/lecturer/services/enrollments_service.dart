import 'dart:convert';

import 'api_config.dart';
import 'api_client.dart';

class EnrolledCourseModel {
  const EnrolledCourseModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.institution,
    required this.level,
  });

  final String id;
  final String title;
  final String courseCode;
  final String institution;
  final String level;

  factory EnrolledCourseModel.fromJson(Map<String, dynamic> json) {
    return EnrolledCourseModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      level: json['level'] as String? ?? '',
    );
  }
}

class EnrollmentUserSummary {
  const EnrollmentUserSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  factory EnrollmentUserSummary.fromJson(Map<String, dynamic> json) {
    return EnrollmentUserSummary(
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class EnrollmentRequestModel {
  const EnrollmentRequestModel({
    required this.id,
    required this.status,
    required this.user,
    required this.createdAt,
  });

  final String id;
  final String status;
  final EnrollmentUserSummary user;
  final DateTime createdAt;

  factory EnrollmentRequestModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['userId'];
    final user = userJson is Map<String, dynamic>
        ? EnrollmentUserSummary.fromJson(userJson)
        : EnrollmentUserSummary.fromJson(const {});
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return EnrollmentRequestModel(
      id: json['_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      user: user,
      createdAt: createdAt,
    );
  }
}

class PaginatedEnrolledCoursesResponse {
  const PaginatedEnrolledCoursesResponse({required this.data, required this.count});

  final List<EnrolledCourseModel> data;
  final int count;

  factory PaginatedEnrolledCoursesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = (rawData is List ? rawData : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(EnrolledCourseModel.fromJson)
        .toList();
    final count = json['count'] as int? ?? data.length;
    return PaginatedEnrolledCoursesResponse(data: data, count: count);
  }
}

class EnrollmentsService {
  EnrollmentsService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.enrollmentsBaseUrl,
      _authToken = authToken ?? ApiConfig.defaultAuthToken;

  final ApiClient _client;
  final String _baseUrl;
  final String _authToken;

  Map<String, String> get _headers {
    final headers = <String, String>{};
    if (_authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Map<String, String> get _jsonHeaders => {
    ..._headers,
    'Content-Type': 'application/json',
  };

  Future<void> applyForCourse({
    required String courseId,
    required String courseCode,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/apply/${Uri.encodeComponent(courseId)}');
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'courseCode': courseCode}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to apply for course'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to apply for course',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }

  Future<PaginatedEnrolledCoursesResponse> fetchMyCourses({
    int page = 1,
    int limit = 10,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final uri =
        Uri.parse('$_baseUrl/my-courses').replace(queryParameters: query);
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch enrolled courses',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch enrolled courses',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return PaginatedEnrolledCoursesResponse.fromJson(body);
    }
    return const PaginatedEnrolledCoursesResponse(data: [], count: 0);
  }

  Future<List<EnrollmentRequestModel>> fetchPendingRequests(String courseId) async {
    final uri = Uri.parse(
      '$_baseUrl/requests/${Uri.encodeComponent(courseId)}/pending',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch enrollment requests',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch enrollment requests',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final rawData = body['data'];
      if (rawData is List) {
        return rawData
            .whereType<Map<String, dynamic>>()
            .map(EnrollmentRequestModel.fromJson)
            .toList();
      }
    }
    return const [];
  }

  Future<void> handleRequest({
    required String courseId,
    required String userId,
    required String action,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/requests/${Uri.encodeComponent(courseId)}/${Uri.encodeComponent(userId)}',
    );
    final response = await _client.patch(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'action': action}),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to update enrollment'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to update enrollment',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
