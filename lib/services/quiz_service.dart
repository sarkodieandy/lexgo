import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_client.dart';
import '../models/quiz/quiz_model.dart';

class QuizService {
  QuizService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.quizBaseUrl,
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

  Future<QuizModel> createManualQuiz({
    required String courseId,
    required String title,
    required String description,
    required int quizDurationMinutes,
    required DateTime quizStartTime,
    DateTime? quizEndTime,
    int? attempts,
    Map<String, dynamic>? grade,
    bool? shuffleQuestions,
    bool? shuffleAnswers,
    bool? showScoresImmediately,
    required List<Map<String, dynamic>> questions,
  }) async {
    final uri = Uri.parse('$_baseUrl/create/manual');
    final payload = <String, dynamic>{
      'courseId': courseId,
      'title': title,
      'description': description,
      'quizDuration': quizDurationMinutes,
      'quizStartTime': quizStartTime.toIso8601String(),
      if (quizEndTime != null) 'quizEndTime': quizEndTime.toIso8601String(),
      if (attempts != null) 'attempts': attempts,
      if (grade != null) 'grade': grade,
      if (shuffleQuestions != null) 'shuffleQuestions': shuffleQuestions,
      if (shuffleAnswers != null) 'shuffleAnswers': shuffleAnswers,
      if (showScoresImmediately != null)
        'showScoresImmediately': showScoresImmediately,
      'questions': questions,
    };
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to create quiz'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to create quiz',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return QuizModel.fromJson(data);
      }
      if (body['_id'] != null) return QuizModel.fromJson(body);
    }
    return const QuizModel(id: '', title: 'Quiz');
  }

  Future<QuizModel> createAutoQuiz({
    required String courseId,
    required String title,
    required String description,
    required String documentPath,
    int? quizDurationMinutes,
    DateTime? quizStartTime,
    DateTime? quizEndTime,
    int? attempts,
    bool? shuffleQuestions,
    bool? shuffleAnswers,
    bool? showScoresImmediately,
    int? numberOfQuestions,
    String? difficultyLevel,
  }) async {
    final uri = Uri.parse('$_baseUrl/create/auto');
    final response = await _client.sendMultipart(() async {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_headers)
        ..fields['courseId'] = courseId
        ..fields['title'] = title
        ..fields['description'] = description;
      if (quizDurationMinutes != null) {
        request.fields['quizDuration'] = quizDurationMinutes.toString();
      }
      if (quizStartTime != null) {
        request.fields['quizStartTime'] = quizStartTime.toIso8601String();
      }
      if (quizEndTime != null) {
        request.fields['quizEndTime'] = quizEndTime.toIso8601String();
      }
      if (attempts != null) {
        request.fields['attempts'] = attempts.toString();
      }
      if (shuffleQuestions != null) {
        request.fields['shuffleQuestions'] = shuffleQuestions.toString();
      }
      if (shuffleAnswers != null) {
        request.fields['shuffleAnswers'] = shuffleAnswers.toString();
      }
      if (showScoresImmediately != null) {
        request.fields['showScoresImmediately'] =
            showScoresImmediately.toString();
      }
      if (numberOfQuestions != null) {
        request.fields['numberOfQuestions'] = numberOfQuestions.toString();
      }
      if (difficultyLevel != null) {
        request.fields['difficultyLevel'] = difficultyLevel;
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', documentPath),
      );
      return request;
    });
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to create quiz'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to create quiz',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return QuizModel.fromJson(data);
      }
      if (body['_id'] != null) return QuizModel.fromJson(body);
    }
    return const QuizModel(id: '', title: 'Quiz');
  }

  Future<List<QuizModel>> fetchCourseQuizzes(String courseId) async {
    final uri = Uri.parse(
      '$_baseUrl/course/${Uri.encodeComponent(courseId)}',
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch course quizzes',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch course quizzes',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final rawData = body['data'];
      final List<dynamic> list = rawData is List
          ? rawData
          : (rawData is Map<String, dynamic> && rawData['data'] is List)
              ? rawData['data'] as List<dynamic>
              : const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(QuizModel.fromJson)
          .toList();
    }
    return const [];
  }

  Future<List<QuizModel>> fetchMyQuizzes({
    int page = 1,
    int limit = 10,
    String? title,
    String? sortedBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (title?.isNotEmpty == true) {
      queryParameters['title'] = title!;
    }
    if (sortedBy?.isNotEmpty == true) {
      queryParameters['sortedBy'] = sortedBy!;
    }
    if (sortOrder?.isNotEmpty == true) {
      queryParameters['sortOrder'] = sortOrder!;
    }

    final uri = Uri.parse(
      '$_baseUrl/my-quizzes',
    ).replace(queryParameters: queryParameters);
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch quizzes'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch quizzes',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      final List<dynamic> rawData = data is List
          ? data
          : (data is Map<String, dynamic> && data['data'] is List)
              ? data['data'] as List<dynamic>
              : const [];
      return rawData
          .whereType<Map<String, dynamic>>()
          .map(QuizModel.fromJson)
          .toList();
    }
    return const [];
  }

  Future<void> deleteQuiz(String quizId) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(quizId)}');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to delete quiz'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
