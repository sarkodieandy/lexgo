import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

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
  CasesService({http.Client? httpClient, String? baseUrl, String? authToken})
    : _client = httpClient ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.casesBaseUrl,
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
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Failed to fetch cases', uri: uri);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
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
    final uri = Uri.parse('$_baseUrl/$courseId');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers)
      ..fields['title'] = title
      ..fields['sourceOfCase'] = sourceOfCase
      ..fields['caseCode'] = caseCode
      ..fields['caseCategory'] = caseCategory;
    request.files.add(
      await http.MultipartFile.fromPath('caseDocument', documentPath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != HttpStatus.created) {
      throw HttpException('Failed to create case', uri: uri);
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return CaseModel.fromJson(data);
  }

  Future<void> deleteCase(String id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('Failed to delete case', uri: uri);
    }
  }
}
