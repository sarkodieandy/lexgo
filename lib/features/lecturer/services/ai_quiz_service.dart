import 'dart:convert';

import 'api_config.dart';
import 'api_client.dart';

class AiQuizJobResponse {
  const AiQuizJobResponse({
    required this.jobId,
    required this.status,
    this.message,
  });

  final String jobId;
  final String status;
  final String? message;

  factory AiQuizJobResponse.fromJson(Map<String, dynamic> json) {
    return AiQuizJobResponse(
      jobId: json['jobId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String?,
    );
  }
}

class AiQuizQuestionModel {
  const AiQuizQuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  final String question;
  final List<String> options;
  final String correctAnswer;

  factory AiQuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsRaw = json['options'];
    final options = (optionsRaw is List ? optionsRaw : const <dynamic>[])
        .map((e) => e.toString())
        .toList();
    return AiQuizQuestionModel(
      question: json['question'] as String? ?? '',
      options: options,
      correctAnswer: json['correctAnswer'] as String? ?? '',
    );
  }
}

class AiQuizModel {
  const AiQuizModel({
    required this.id,
    required this.topic,
    required this.difficultyLevel,
    required this.totalQuestions,
    required this.questions,
    required this.score,
    required this.completed,
    required this.totalQuizzes,
    required this.totalQuizzesScores,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String topic;
  final String difficultyLevel;
  final int totalQuestions;
  final List<AiQuizQuestionModel> questions;
  final int score;
  final bool completed;
  final int totalQuizzes;
  final num totalQuizzesScores;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AiQuizModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    DateTime parseDate(String? value) {
      return DateTime.tryParse(value ?? '') ?? DateTime.now();
    }

    num parseNum(dynamic value, num fallback) {
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final questionsRaw = json['questions'];
    final questions = (questionsRaw is List ? questionsRaw : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(AiQuizQuestionModel.fromJson)
        .toList();

    return AiQuizModel(
      id: json['_id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      difficultyLevel: json['difficultyLevel'] as String? ?? '',
      totalQuestions: parseInt(json['totalQuestions'], questions.length),
      questions: questions,
      score: parseInt(json['score'], 0),
      completed: parseBool(json['completed']),
      totalQuizzes: parseInt(json['totalQuizzes'], 0),
      totalQuizzesScores: parseNum(json['totalQuizzesScores'], 0),
      createdAt: parseDate(json['createdAt'] as String?),
      updatedAt: parseDate(json['updatedAt'] as String?),
    );
  }
}

class AiQuizJobStatus {
  const AiQuizJobStatus({
    required this.status,
    this.progress,
    this.message,
    this.quizId,
    this.quiz,
  });

  final String status;
  final num? progress;
  final String? message;
  final String? quizId;
  final AiQuizModel? quiz;

  factory AiQuizJobStatus.fromJson(Map<String, dynamic> json) {
    final quizJson = json['quiz'];
    return AiQuizJobStatus(
      status: json['status'] as String? ?? '',
      progress: json['progress'] is num
          ? json['progress'] as num
          : num.tryParse(json['progress']?.toString() ?? ''),
      message: json['message'] as String?,
      quizId: json['quizId'] as String?,
      quiz: quizJson is Map<String, dynamic> ? AiQuizModel.fromJson(quizJson) : null,
    );
  }
}

class AiQuizzesPagination {
  const AiQuizzesPagination({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.startIndex,
    required this.endIndex,
  });

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int startIndex;
  final int endIndex;

  factory AiQuizzesPagination.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    return AiQuizzesPagination(
      page: parseInt(json['page'], 1),
      limit: parseInt(json['limit'], 10),
      totalItems: parseInt(json['totalItems'], 0),
      totalPages: parseInt(json['totalPages'], 1),
      hasNextPage: parseBool(json['hasNextPage']),
      hasPrevPage: parseBool(json['hasPrevPage']),
      startIndex: parseInt(json['startIndex'], 0),
      endIndex: parseInt(json['endIndex'], 0),
    );
  }
}

class AiQuizzesResponse {
  const AiQuizzesResponse({
    required this.quizzes,
    required this.pagination,
  });

  final List<AiQuizModel> quizzes;
  final AiQuizzesPagination? pagination;

  factory AiQuizzesResponse.fromJson(Map<String, dynamic> json) {
    final rawQuizzes = json['quizzes'];
    final quizzes = (rawQuizzes is List ? rawQuizzes : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(AiQuizModel.fromJson)
        .toList();
    final paginationRaw = json['pagination'];
    final pagination = paginationRaw is Map<String, dynamic>
        ? AiQuizzesPagination.fromJson(paginationRaw)
        : null;
    return AiQuizzesResponse(quizzes: quizzes, pagination: pagination);
  }
}

class AiQuizSubmitResponse {
  const AiQuizSubmitResponse({
    required this.quizId,
    required this.score,
    required this.totalQuizzes,
    required this.totalQuizzesScores,
    this.message,
  });

  final String quizId;
  final int score;
  final int totalQuizzes;
  final num totalQuizzesScores;
  final String? message;

  factory AiQuizSubmitResponse.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    num parseNum(dynamic value, num fallback) {
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final quizJson = json['quiz'];
    if (quizJson is Map<String, dynamic>) {
      return AiQuizSubmitResponse(
        quizId: quizJson['quizId'] as String? ?? '',
        score: parseInt(quizJson['score'], 0),
        totalQuizzes: parseInt(quizJson['totalQuizzes'], 0),
        totalQuizzesScores: parseNum(quizJson['totalQuizzesScores'], 0),
        message: json['message'] as String?,
      );
    }
    return AiQuizSubmitResponse(
      quizId: '',
      score: 0,
      totalQuizzes: 0,
      totalQuizzesScores: 0,
      message: json['message'] as String?,
    );
  }
}

class AiQuizService {
  AiQuizService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.aiQuizBaseUrl,
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

  Future<AiQuizJobResponse> createQuiz({
    required String topic,
    required String difficultyLevel,
    required int numberOfQuiz,
  }) async {
    final uri = Uri.parse('$_baseUrl/quiz');
    final payload = <String, dynamic>{
      'topic': topic,
      'difficultyLevel': difficultyLevel,
      'numberOfQuiz': numberOfQuiz,
    };
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 202 && response.statusCode != 200) {
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
      return AiQuizJobResponse.fromJson(body);
    }
    return const AiQuizJobResponse(jobId: '', status: '');
  }

  Future<AiQuizJobStatus> fetchQuizStatus(String jobId) async {
    final uri = Uri.parse('$_baseUrl/quiz/status/${Uri.encodeComponent(jobId)}');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch quiz status'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch quiz status',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return AiQuizJobStatus.fromJson(body);
    }
    return const AiQuizJobStatus(status: '');
  }

  Future<AiQuizModel> fetchQuiz(String quizId) async {
    final uri = Uri.parse('$_baseUrl/quiz/${Uri.encodeComponent(quizId)}');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch quiz'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch quiz',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final quizJson = body['quiz'];
      if (quizJson is Map<String, dynamic>) return AiQuizModel.fromJson(quizJson);
      if (body['_id'] != null) return AiQuizModel.fromJson(body);
    }
    return AiQuizModel.fromJson(const {});
  }

  Future<AiQuizzesResponse> fetchQuizzes({
    int page = 1,
    int limit = 10,
    bool? completed,
    String? difficultyLevel,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (completed != null) query['completed'] = completed.toString();
    if (difficultyLevel?.isNotEmpty == true) {
      query['difficultyLevel'] = difficultyLevel!;
    }

    final uri = Uri.parse('$_baseUrl/quizzes').replace(queryParameters: query);
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
      return AiQuizzesResponse.fromJson(body);
    }
    return const AiQuizzesResponse(quizzes: [], pagination: null);
  }

  Future<AiQuizSubmitResponse> submitScore({
    required String quizId,
    required int score,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/quiz/submit/${Uri.encodeComponent(quizId)}',
    );
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'score': score}),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to submit quiz score'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to submit quiz score',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return AiQuizSubmitResponse.fromJson(body);
    }
    return const AiQuizSubmitResponse(
      quizId: '',
      score: 0,
      totalQuizzes: 0,
      totalQuizzesScores: 0,
    );
  }

  Future<void> deleteQuiz(String quizId) async {
    final uri = Uri.parse('$_baseUrl/quiz/${Uri.encodeComponent(quizId)}');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to delete quiz'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to delete quiz',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
