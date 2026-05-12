import 'dart:convert';
import 'package:lexgo/services/api_client.dart' as http;
import '../config/app_config.dart';
import '../models/quiz_model.dart';
import 'package:lexgo/services/auth_api_service.dart';

class QuizApiService {
  static String get _baseUrl => '$kApiBase/api/v1/Ai';

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final accessToken = AuthApiService.memoryAccessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  // ---------------------------------------------------------------------------
  // 1. Create Quiz
  // ---------------------------------------------------------------------------
  Future<String> createQuiz({
    required String topic,
    required String difficultyLevel,
    required int numberOfQuiz,
  }) async {
    if (topic.trim().isEmpty) throw Exception('Quiz topic is required.');
    if (numberOfQuiz <= 0) throw Exception('Number of questions must be > 0.');

    final uri = Uri.parse('$_baseUrl/quiz');
    final headers = await _getHeaders();
    final body = json.encode({
      'topic': topic.trim(),
      'difficultyLevel': difficultyLevel,
      'numberOfQuiz': numberOfQuiz,
    });

    final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 90));


    if (response.statusCode == 202 || response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['jobId'] as String;
    } else {
      dynamic msg = 'Failed to generate quiz (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Get Quiz Status
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getQuizStatus(String jobId) async {
    final uri = Uri.parse('$_baseUrl/quiz/status/$jobId');
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      dynamic msg = 'Failed to get quiz status (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Get Single Quiz
  // ---------------------------------------------------------------------------
  Future<Quiz> getQuiz(String quizId) async {
    final uri = Uri.parse('$_baseUrl/quiz/$quizId');
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));


    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Backend returns {"message": "...", "quiz": {...}}
      return Quiz.fromJson(jsonResponse['quiz']);
    } else {
      dynamic msg = 'Failed to fetch quiz (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Get All Quizzes
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getAllQuizzes({
    int page = 1,
    int limit = 10,
    bool? completed,
    String? difficultyLevel,
    String? cursor, // Retained for frontend legacy signature
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (completed != null) queryParams['completed'] = completed.toString();
    if (difficultyLevel != null && difficultyLevel.isNotEmpty) {
      queryParams['difficultyLevel'] = difficultyLevel;
    }

    final uri = Uri.parse('$_baseUrl/quizzes').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['quizzes'] ?? [];
      
      return {
        'success': true,
        'quizzes': data.map((j) => Quiz.fromJson(j)).toList(),
        'pagination': jsonResponse['pagination'] ?? {},
        'hasMore': false, // Minimal bridge for legacy cursor UI
        'nextCursor': null, // Minimal bridge for legacy cursor UI
      };
    } else {
      dynamic msg = 'Failed to load quizzes (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Submit Quiz Score
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> submitQuizScore(
    String quizId,
    int score, {
    int? totalQuestions, // Retained for frontend legacy signature
  }) async {
    final uri = Uri.parse('$_baseUrl/quiz/submit/$quizId');
    final headers = await _getHeaders();
    final body = json.encode({'score': score});

    final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return {
        'success': true,
        'quiz': jsonResponse['quiz'],
        'message': jsonResponse['message'] ?? 'Quiz score submitted successfully'
      };
    } else {
      dynamic msg = 'Failed to submit score (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Delete Quiz
  // ---------------------------------------------------------------------------
  Future<void> deleteQuiz(String quizId) async {
    final uri = Uri.parse('$_baseUrl/quiz/$quizId');
    final headers = await _getHeaders();

    final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return;
    } else {
      dynamic msg = 'Failed to delete quiz (${response.statusCode}).';
      try {
        final decoded = json.decode(response.body);
        msg = decoded['message'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
