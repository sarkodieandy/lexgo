import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

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

class CoursesService {
  CoursesService({
    http.Client? httpClient,
    String? baseUrl,
    String? authToken,
  })  : _client = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.coursesBaseUrl,
        _authToken = authToken ?? ApiConfig.defaultAuthToken;

  final http.Client _client;
  final String _baseUrl;
  final String _authToken;

  Map<String, String> get _headers {
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (_authToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $_authToken';
    }
    return headers;
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
    final file = await http.MultipartFile.fromPath('courseImage', imagePath);
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != HttpStatus.created &&
        response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Failed to create course',
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return CourseModel.fromJson(data);
  }
}
