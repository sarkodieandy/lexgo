import 'dart:convert';

import 'api_config.dart';
import 'api_client.dart';

class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.legalTopic,
    required this.importanceLevel,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String legalTopic;
  final String importanceLevel;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String? value) {
      return DateTime.tryParse(value ?? '') ?? DateTime.now();
    }

    return NoteModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      legalTopic: json['legalTopic'] as String? ?? '',
      importanceLevel: json['importanceLevel'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: parseDate(json['createdAt'] as String?),
      updatedAt: parseDate(json['updatedAt'] as String?),
    );
  }
}

class NotesPagination {
  const NotesPagination({
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

  factory NotesPagination.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    return NotesPagination(
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

class PaginatedNotesResponse {
  const PaginatedNotesResponse({
    required this.data,
    required this.pagination,
  });

  final List<NoteModel> data;
  final NotesPagination? pagination;

  factory PaginatedNotesResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = (rawData is List ? rawData : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(NoteModel.fromJson)
        .toList();

    final paginationRaw = json['pagination'];
    final pagination = paginationRaw is Map<String, dynamic>
        ? NotesPagination.fromJson(paginationRaw)
        : null;

    return PaginatedNotesResponse(data: data, pagination: pagination);
  }
}

class NotesService {
  NotesService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.notesBaseUrl,
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

  Future<PaginatedNotesResponse> fetchNotes({
    int page = 1,
    int limit = 10,
    String? legalTopic,
    String? importanceLevel,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (legalTopic?.isNotEmpty == true) query['legalTopic'] = legalTopic!;
    if (importanceLevel?.isNotEmpty == true) {
      query['importanceLevel'] = importanceLevel!;
    }
    if (search?.isNotEmpty == true) query['search'] = search!;

    final uri = Uri.parse('$_baseUrl/get-all').replace(queryParameters: query);
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch notes'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch notes',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return PaginatedNotesResponse.fromJson(body);
    }
    return const PaginatedNotesResponse(data: [], pagination: null);
  }

  Future<NoteModel> fetchNote(String id) async {
    final uri = Uri.parse('$_baseUrl/get/${Uri.encodeComponent(id)}');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch note'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch note',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) return NoteModel.fromJson(data);
      if (body['_id'] != null) return NoteModel.fromJson(body);
    }
    return NoteModel.fromJson(const {});
  }

  Future<NoteModel> createNote({
    required String title,
    required String legalTopic,
    required String importanceLevel,
    required String content,
  }) async {
    final uri = Uri.parse('$_baseUrl/create');
    final payload = <String, dynamic>{
      'title': title,
      'legalTopic': legalTopic,
      'importanceLevel': importanceLevel,
      'content': content,
    };
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to create note'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to create note',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) return NoteModel.fromJson(data);
      if (body['_id'] != null) return NoteModel.fromJson(body);
    }
    return NoteModel.fromJson(const {});
  }

  Future<NoteModel> updateNote(
    String id, {
    String? title,
    String? legalTopic,
    String? importanceLevel,
    String? content,
  }) async {
    final uri = Uri.parse('$_baseUrl/update/${Uri.encodeComponent(id)}');
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (legalTopic != null) 'legalTopic': legalTopic,
      if (importanceLevel != null) 'importanceLevel': importanceLevel,
      if (content != null) 'content': content,
    };
    final response = await _client.patch(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to update note'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to update note',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) return NoteModel.fromJson(data);
      if (body['_id'] != null) return NoteModel.fromJson(body);
    }
    return NoteModel.fromJson(const {});
  }

  Future<void> deleteNote(String id) async {
    final uri = Uri.parse('$_baseUrl/delete/${Uri.encodeComponent(id)}');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to delete note'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
