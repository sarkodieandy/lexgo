import 'dart:convert';
import 'api_config.dart';
import 'api_client.dart';
import '../models/quiz/quiz_model.dart';

class StudentQuizService {
  StudentQuizService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.studentQuizBaseUrl,
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

  /// Fetches quiz details for student participation.
  /// Standardly strips correctAnswer and explanation from questions on the backend.
  Future<QuizModel> getQuizDetails(String quizId) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(quizId)}');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch quiz details'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch quiz details',
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
    throw ApiException('Unexpected response format', uri: uri);
  }

  /// Submits student answers for a quiz.
  /// answers: List of Map with 'questionId' and 'selectedOption'.
  Future<Map<String, dynamic>> submitQuiz(
    String quizId,
    List<Map<String, String>> answers,
  ) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(quizId)}/submit');
    final payload = {'answers': answers};

    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to submit quiz'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to submit quiz',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return body['data'] ?? body;
    }
    throw ApiException('Unexpected response format', uri: uri);
  }
}
