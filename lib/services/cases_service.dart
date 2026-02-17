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

class PaginatedCasesResponse {
  const PaginatedCasesResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.total,
  });

  final List<CaseModel> data;
  final int currentPage;
  final int totalPages;
  final int count;
  final int total;

  factory PaginatedCasesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawData = json['data'] as List<dynamic>? ?? [];
    return PaginatedCasesResponse(
      data: rawData
          .map((item) => CaseModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      count: json['count'] as int? ?? rawData.length,
      total: json['total'] as int? ?? rawData.length,
    );
  }
}

class CasesService {
  CasesService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.casesBaseUrl,
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

  Future<PaginatedCasesResponse> fetchAllCases({
    int page = 1,
    int limit = 10,
    String? title,
    String? category,
    String sortedBy = '_id',
    String sortOrder = 'desc',
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortedBy': sortedBy,
      'sortOrder': sortOrder,
    };
    if (title?.isNotEmpty == true) {
      queryParameters['title'] = title!;
    }
    if (category?.isNotEmpty == true) {
      queryParameters['category'] = category!;
    }
    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    final response = await _client.get(uri, headers: _headers);
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
    return PaginatedCasesResponse.fromJson(body);
  }

  Future<PaginatedCasesResponse> fetchCourseCases({
    required String courseId,
    int page = 1,
    int limit = 10,
    String? title,
    String? category,
    String sortedBy = '_id',
    String sortOrder = 'desc',
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortedBy': sortedBy,
      'sortOrder': sortOrder,
    };
    if (title?.isNotEmpty == true) {
      queryParameters['title'] = title!;
    }
    if (category?.isNotEmpty == true) {
      queryParameters['category'] = category!;
    }

    final uri = Uri.parse(
      '$_baseUrl/${Uri.encodeComponent(courseId)}',
    ).replace(queryParameters: queryParameters);
    final response = await _client.get(uri, headers: _headers);
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
    return PaginatedCasesResponse.fromJson(body);
  }

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
        ..headers.addAll(_headers)
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

  Future<void> deleteCase(String id) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(id)}');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to delete case'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
