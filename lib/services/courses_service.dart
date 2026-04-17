import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_client.dart';
import '../models/resource.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.category,
    required this.institution,
    required this.level,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String courseCode;
  final String category;
  final String institution;
  final String level;
  final String? description;
  final String? imageUrl;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      institution: json['institution'] as String? ?? '',
      level: json['level'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class PaginatedCourseResourcesResponse {
  const PaginatedCourseResourcesResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.total,
  });

  final List<CourseResource> data;
  final int currentPage;
  final int totalPages;
  final int count;
  final int total;

  factory PaginatedCourseResourcesResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['data'];
    int currentPage = json['currentPage'] as int? ?? 1;
    int totalPages = json['totalPages'] as int? ?? 1;
    int count = json['count'] as int? ?? 0;
    int total = json['total'] as int? ?? 0;

    if (rawData is Map<String, dynamic>) {
      currentPage = rawData['currentPage'] as int? ?? currentPage;
      totalPages = rawData['totalPages'] as int? ?? totalPages;
      count = rawData['count'] as int? ?? count;
      total = rawData['total'] as int? ?? total;
      rawData = rawData['data'] ?? rawData['resources'] ?? [];
    }

    final List<dynamic> list = rawData is List ? rawData : const [];
    final resources = list
        .whereType<Map<String, dynamic>>()
        .map(CourseResource.fromJson)
        .toList();

    return PaginatedCourseResourcesResponse(
      data: resources,
      currentPage: currentPage,
      totalPages: totalPages,
      count: count != 0 ? count : resources.length,
      total: total != 0 ? total : resources.length,
    );
  }
}

class CoursesService {
  CoursesService({
    ApiClient? client,
    String? baseUrl,
    String? authToken,
  })  : _client = client ?? ApiClient.shared,
        _baseUrl = baseUrl ?? ApiConfig.coursesBaseUrl,
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

  /// GET / — Fetch all courses for the authenticated lecturer.
  Future<List<CourseModel>> fetchCourses() async {
    final uri = Uri.parse(_baseUrl);
    debugPrint('[CoursesService] fetchCourses → GET $uri');
    try {
      final response = await _client.get(uri);
      debugPrint('[CoursesService] fetchCourses status: ${response.statusCode}');
      debugPrint('[CoursesService] fetchCourses body: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
      if (response.statusCode != 200) {
        throw ApiException(
          ApiClient.extractMessage(response, fallback: 'Failed to fetch courses'),
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body['success'] == false) {
          throw ApiException(
            (body['message'] as String?) ?? 'Failed to fetch courses',
            statusCode: response.statusCode,
            uri: uri,
          );
        }
        final rawData = body['data'] ?? body['courses'] ?? [];
        debugPrint('[CoursesService] rawData type: ${rawData.runtimeType}, length: ${rawData is List ? rawData.length : 'N/A'}');
        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map(CourseModel.fromJson)
              .toList();
        }
      }
      return [];
    } catch (e, stack) {
      debugPrint('[CoursesService] fetchCourses error: $e');
      debugPrint('[CoursesService] fetchCourses stack: $stack');
      rethrow;
    }
  }

  Future<CourseModel> createCourse({
    required String title,
    required String category,
    required String institution,
    required String level,
    required String courseCode,
    String? description,
    required String imagePath,
  }) async {
    final uri = Uri.parse(_baseUrl);
    debugPrint('[CoursesService] createCourse → POST $uri');
    debugPrint('[CoursesService] fields: title=$title, category=$category, institution=$institution, level=$level, courseCode=$courseCode');
    debugPrint('[CoursesService] imagePath=$imagePath');
    final response = await _client.sendMultipart(() async {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_headers)
        ..fields['title'] = title
        ..fields['category'] = category
        ..fields['institution'] = institution
        ..fields['level'] = level
        ..fields['courseCode'] = courseCode;
      if (description?.isNotEmpty == true) {
        request.fields['description'] = description!;
      }
      request.files.add(
        await http.MultipartFile.fromPath('courseImage', imagePath),
      );
      return request;
    });
    debugPrint('[CoursesService] createCourse status: ${response.statusCode}');
    debugPrint('[CoursesService] createCourse body: ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to create course'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to create course',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return CourseModel.fromJson(data);
  }

  Future<PaginatedCourseResourcesResponse> fetchCourseResources({
    required String courseId,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final uri = Uri.parse(
      '$_baseUrl/resources/${Uri.encodeComponent(courseId)}',
    ).replace(
      queryParameters: queryParameters,
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch resources'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch resources',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return PaginatedCourseResourcesResponse.fromJson(body);
    }
    return const PaginatedCourseResourcesResponse(
      data: [],
      currentPage: 1,
      totalPages: 1,
      count: 0,
      total: 0,
    );
  }

  Future<CourseResource> uploadResource({
    required String courseId,
    required String filePath,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/resource/${Uri.encodeComponent(courseId)}');
    final response = await _client.sendMultipart(() async {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_headers);
      request.files.add(
        await http.MultipartFile.fromPath('resourceFile', filePath),
      );
      return request;
    });
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to upload resource'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to upload resource',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final dynamic data = body['data'] ?? body;
      if (data is Map<String, dynamic>) {
        final resourceJson = (data['_id'] != null)
            ? data
            : (data['resource'] as Map<String, dynamic>?) ?? data;
        return CourseResource.fromJson(resourceJson);
      }
    }

    final normalizedPath = filePath.replaceAll('\\', '/');
    final title = normalizedPath.split('/').last;
    return CourseResource(
      id: '',
      title: title.isNotEmpty ? title : 'Resource',
      size: '0MB',
      timestamp: DateTime.now(),
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(courseId)}');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to delete course'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }

  Future<String> createCourseMaterialJob(String courseId) async {
    final uri = Uri.parse(
      '$_baseUrl/courseMaterial/${Uri.encodeComponent(courseId)}',
    );
    final response = await _client.post(uri, headers: _jsonHeaders);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to start course material generation',
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
              'Failed to start course material generation',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final jobId = body['jobId'] ??
          (body['data'] is Map<String, dynamic>
              ? (body['data'] as Map<String, dynamic>)['jobId']
              : null);
      if (jobId is String && jobId.isNotEmpty) return jobId;
    }
    return '';
  }

  Future<Map<String, dynamic>> fetchCourseMaterialStatus(String jobId) async {
    final uri = Uri.parse(
      '$_baseUrl/courseMaterial/status/${Uri.encodeComponent(jobId)}',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch course material status',
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
              'Failed to fetch course material status',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return body;
    }
    return const {};
  }

  Future<List<dynamic>> fetchCourseMaterials(String courseId) async {
    final uri = Uri.parse(
      '$_baseUrl/courseMaterials/${Uri.encodeComponent(courseId)}',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch course materials',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch course materials',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
    }
    return const [];
  }
}
