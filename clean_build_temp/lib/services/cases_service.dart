import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_client.dart';

class CaseModel {
  const CaseModel({
    required this.id,
    required this.title,
    required this.caseCode,
    required this.sourceOfCase,
    required this.caseCategory,
    this.documentUrl,
  });

  final String id;
  final String title;
  final String caseCode;
  final String sourceOfCase;
  final String caseCategory;
  final String? documentUrl;

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled case',
      caseCode: json['caseCode'] as String? ?? '',
      sourceOfCase: json['sourceOfCase'] as String? ?? '',
      caseCategory: json['caseCategory'] as String? ?? 'General',
      documentUrl: json['url'] as String?,
    );
  }
}

/// Response model matching the API's cursor-based pagination format.
class CursorPagedCasesResponse {
  const CursorPagedCasesResponse({
    required this.data,
    required this.count,
    required this.total,
    this.nextCursor,
    required this.hasMore,
  });

  final List<CaseModel> data;
  final int count;
  final int total;
  final String? nextCursor;
  final bool hasMore;

  factory CursorPagedCasesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawData = json['data'] as List<dynamic>? ?? [];
    return CursorPagedCasesResponse(
      data: rawData
          .map((item) => CaseModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? rawData.length,
      total: json['total'] as int? ?? rawData.length,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

class CasesService {
  CasesService({ApiClient? client})
    : _client = client ?? ApiClient.shared,
      _baseUrl = ApiConfig.casesBaseUrl;

  final ApiClient _client;
  final String _baseUrl;

  /// GET / — All cases by the authenticated lecturer (cursor-based pagination).
  Future<CursorPagedCasesResponse> fetchAllCases({
    int limit = 25,
    String? cursor,
    String? title,
    String? category,
    String sortOrder = 'desc',
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'sortOrder': sortOrder,
    };
    if (cursor?.isNotEmpty == true) queryParameters['cursor'] = cursor!;
    if (title?.isNotEmpty == true) queryParameters['title'] = title!;
    if (category?.isNotEmpty == true) queryParameters['category'] = category!;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch cases'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to fetch cases',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    return CursorPagedCasesResponse.fromJson(body);
  }

  /// GET /:courseId — Cases for a specific course (cursor-based pagination).
  Future<CursorPagedCasesResponse> fetchCourseCases({
    required String courseId,
    int limit = 25,
    String? cursor,
    String? title,
    String? category,
    String sortOrder = 'desc',
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'sortOrder': sortOrder,
    };
    if (cursor?.isNotEmpty == true) queryParameters['cursor'] = cursor!;
    if (title?.isNotEmpty == true) queryParameters['title'] = title!;
    if (category?.isNotEmpty == true) queryParameters['category'] = category!;

    final uri = Uri.parse(
      '$_baseUrl/${Uri.encodeComponent(courseId)}',
    ).replace(queryParameters: queryParameters);
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to fetch course cases',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to fetch course cases',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    return CursorPagedCasesResponse.fromJson(body);
  }

  /// POST /:courseId — Create a new case with a document file.
  Future<CaseModel> createCase({
    required String courseId,
    required String title,
    required String sourceOfCase,
    required String caseCode,
    required String caseCategory,
    required String documentPath,
  }) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(courseId)}');
    final response = await _client.sendMultipart(() async {
      final request = http.MultipartRequest('POST', uri)
        ..fields['title'] = title
        ..fields['sourceOfCase'] = sourceOfCase
        ..fields['caseCode'] = caseCode
        ..fields['caseCategory'] = caseCategory;
      request.files.add(
        await http.MultipartFile.fromPath('caseDocument', documentPath),
      );
      return request;
    });
    if (response.statusCode != 201) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to create case'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to create case',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return CaseModel.fromJson(data);
  }

  /// DELETE /:id — Delete a case by its ID.
  Future<void> deleteCase(String id) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(id)}');
    final response = await _client.delete(uri);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to delete case'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
