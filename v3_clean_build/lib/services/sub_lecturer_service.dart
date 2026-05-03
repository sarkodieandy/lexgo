import 'dart:convert';

import 'api_config.dart';
import 'api_client.dart';

class LecturerSummary {
  const LecturerSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  factory LecturerSummary.fromJson(Map<String, dynamic> json) {
    return LecturerSummary(
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class SubLecturerRequestModel {
  const SubLecturerRequestModel({
    required this.id,
    required this.status,
    this.lecturer,
  });

  final String id;
  final String status;
  final LecturerSummary? lecturer;

  factory SubLecturerRequestModel.fromJson(Map<String, dynamic> json) {
    final lecturerJson = json['lecturerId'];
    return SubLecturerRequestModel(
      id: json['_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      lecturer: lecturerJson is Map<String, dynamic>
          ? LecturerSummary.fromJson(lecturerJson)
          : null,
    );
  }
}

class SubLecturerService {
  SubLecturerService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.subLecturerBaseUrl,
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

  Future<void> requestToBecomeSubLecturer(String courseId) async {
    final uri = Uri.parse(
      '$_baseUrl/request/${Uri.encodeComponent(courseId)}',
    );
    final response = await _client.post(uri, headers: _headers);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to request sub-lecturer access',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to request sub-lecturer access',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }

  Future<List<SubLecturerRequestModel>> fetchPendingRequests(String courseId) async {
    final uri = Uri.parse(
      '$_baseUrl/requests/${Uri.encodeComponent(courseId)}',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch sub-lecturer requests',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch sub-lecturer requests',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SubLecturerRequestModel.fromJson)
            .toList();
      }
    }
    return const [];
  }

  Future<void> handleRequest({
    required String courseId,
    required String lecturerId,
    required String action,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/request/${Uri.encodeComponent(courseId)}/${Uri.encodeComponent(lecturerId)}',
    );
    final response = await _client.patch(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'action': action}),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to handle sub-lecturer request',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to handle sub-lecturer request',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }

  Future<List<LecturerSummary>> fetchApprovedSubLecturers(String courseId) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(courseId)}');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch approved sub-lecturers',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ??
              'Failed to fetch approved sub-lecturers',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'] ?? body;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(LecturerSummary.fromJson)
            .toList();
      }
    }
    return const [];
  }

  Future<void> removeSubLecturer({
    required String courseId,
    required String lecturerId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/${Uri.encodeComponent(courseId)}/${Uri.encodeComponent(lecturerId)}',
    );
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to remove sub-lecturer'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to remove sub-lecturer',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
