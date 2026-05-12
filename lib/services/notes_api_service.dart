import 'dart:convert';
import 'package:lexgo/services/api_client.dart' as http;
import '../models/note_model.dart';
import 'package:lexgo/services/auth_api_service.dart';
import '../config/app_config.dart';

class NotesApiService {
  // Base URL per docs: /api/v1/Notes
  static String get _baseUrl => '$kApiBase/api/v1/Notes';

  static const List<String> validImportanceLevels = [
    'Low Priority',
    'Medium Priority',
    'High Priority',
  ];

  Map<String, String> _getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final accessToken = AuthApiService.memoryAccessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  /// Safely decode a JSON body into a String-keyed map
  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Extract a user-friendly error message from a response body
  String _errorMsg(http.Response response, String fallback) {
    try {
      final decoded = _decodeBody(response.body);
      final msg = decoded['message'];
      if (msg != null) return msg.toString();
    } catch (_) {}
    return '$fallback (HTTP ${response.statusCode})';
  }

  // ---------------------------------------------------------------------------
  // 1. GET /api/v1/Notes/ — Get All Notes
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getAllNotes({
    int page = 1,
    int limit = 10,
    String? legalTopic,
    String? importanceLevel,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (legalTopic != null && legalTopic.isNotEmpty) {
      queryParams['legalTopic'] = legalTopic;
    }
    if (importanceLevel != null && importanceLevel.isNotEmpty) {
      queryParams['importanceLevel'] = importanceLevel;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams['sortOrder'] = sortOrder;
    }

    // Trailing slash as per docs: GET /api/v1/Notes/
    final uri = Uri.parse('$_baseUrl/').replace(queryParameters: queryParams);
    final headers = _getHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      final rawData = jsonResponse['data'];
      final List<dynamic> dataList =
          rawData is List ? rawData : [];
      final rawPagination = jsonResponse['pagination'];
      final paginationMap = rawPagination is Map
          ? rawPagination.cast<String, dynamic>()
          : <String, dynamic>{};

      return {
        'success': true,
        'notes': dataList
            .map((j) => Note.fromJson(
                  j is Map ? j.cast<String, dynamic>() : <String, dynamic>{},
                ))
            .toList(),
        'pagination': Pagination.fromJson(paginationMap),
        'message':
            jsonResponse['message']?.toString() ?? 'Notes fetched successfully',
      };
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }
    throw Exception(_errorMsg(response, 'Failed to load notes'));
  }

  // ---------------------------------------------------------------------------
  // 2. GET /api/v1/Notes/:id — Get Single Note
  // ---------------------------------------------------------------------------
  Future<Note> getNote(String id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final headers = _getHeaders();

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      final data = jsonResponse['data'];
      final noteMap = data is Map
          ? data.cast<String, dynamic>()
          : <String, dynamic>{};
      return Note.fromJson(noteMap);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }
    if (response.statusCode == 404) {
      throw Exception('Note not found.');
    }
    throw Exception(_errorMsg(response, 'Failed to fetch note'));
  }

  // ---------------------------------------------------------------------------
  // 3. POST /api/v1/Notes/ — Create Note
  // ---------------------------------------------------------------------------
  Future<Note> createNote({
    required String title,
    required String legalTopic,
    required String importanceLevel,
    required String content,
  }) async {
    if (title.trim().isEmpty ||
        legalTopic.trim().isEmpty ||
        content.trim().isEmpty) {
      throw Exception('Title, legal topic, and content are required.');
    }
    if (title.length > 200) {
      throw Exception('Title cannot exceed 200 characters.');
    }
    if (legalTopic.length > 100) {
      throw Exception('Legal topic cannot exceed 100 characters.');
    }
    if (content.length > 50000) {
      throw Exception('Content cannot exceed 50,000 characters.');
    }
    if (!validImportanceLevels.contains(importanceLevel)) {
      throw Exception(
        'Invalid importance level. Must be: Low Priority, Medium Priority, or High Priority.',
      );
    }

    // Trailing slash as per docs: POST /api/v1/Notes/
    final uri = Uri.parse('$_baseUrl/');
    final headers = _getHeaders();
    final body = json.encode({
      'title': title.trim(),
      'legalTopic': legalTopic.trim(),
      'importanceLevel': importanceLevel,
      'content': content,
    });

    final response = await http
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      final data = jsonResponse['data'];
      final noteMap = data is Map
          ? data.cast<String, dynamic>()
          : <String, dynamic>{};
      return Note.fromJson(noteMap);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }
    if (response.statusCode == 409) {
      throw Exception('A note with this title already exists.');
    }
    throw Exception(_errorMsg(response, 'Failed to create note'));
  }

  // ---------------------------------------------------------------------------
  // 4. PATCH /api/v1/Notes/:id — Update Note
  // ---------------------------------------------------------------------------
  Future<Note> updateNote({
    required String id,
    String? title,
    String? legalTopic,
    String? importanceLevel,
    String? content,
  }) async {
    if (title == null &&
        legalTopic == null &&
        importanceLevel == null &&
        content == null) {
      throw Exception('At least one field is required to update.');
    }
    if (title != null && title.length > 200) {
      throw Exception('Title cannot exceed 200 characters.');
    }
    if (legalTopic != null && legalTopic.length > 100) {
      throw Exception('Legal topic cannot exceed 100 characters.');
    }
    if (importanceLevel != null &&
        !validImportanceLevels.contains(importanceLevel)) {
      throw Exception(
        'Invalid importance level. Must be: Low Priority, Medium Priority, or High Priority.',
      );
    }
    if (content != null && content.length > 50000) {
      throw Exception('Content cannot exceed 50,000 characters.');
    }

    final uri = Uri.parse('$_baseUrl/$id');
    final headers = _getHeaders();

    final updateData = <String, dynamic>{};
    if (title != null) updateData['title'] = title.trim();
    if (legalTopic != null) updateData['legalTopic'] = legalTopic.trim();
    if (importanceLevel != null) updateData['importanceLevel'] = importanceLevel;
    if (content != null) updateData['content'] = content;

    final response = await http
        .patch(uri, headers: headers, body: json.encode(updateData))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      final data = jsonResponse['data'];
      final noteMap = data is Map
          ? data.cast<String, dynamic>()
          : <String, dynamic>{};
      return Note.fromJson(noteMap);
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }
    if (response.statusCode == 404) {
      throw Exception('Note not found.');
    }
    throw Exception(_errorMsg(response, 'Failed to update note'));
  }

  // ---------------------------------------------------------------------------
  // 5. DELETE /api/v1/Notes/:id — Delete Note
  // ---------------------------------------------------------------------------
  Future<void> deleteNote(String id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final headers = _getHeaders();

    final response = await http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please log in again.');
    }
    if (response.statusCode == 404) {
      throw Exception('Note not found or already deleted.');
    }
    throw Exception(_errorMsg(response, 'Failed to delete note'));
  }
}
