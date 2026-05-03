import 'dart:convert';

import 'api_client.dart';
import 'api_config.dart';

class AdminCaseCourt {
  const AdminCaseCourt({required this.name, required this.level});

  final String name;
  final String level;

  factory AdminCaseCourt.fromJson(Map<String, dynamic> json) {
    return AdminCaseCourt(
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'level': level};
}

class AdminCaseParty {
  const AdminCaseParty({required this.name, required this.role});

  final String name;
  final String role;

  factory AdminCaseParty.fromJson(Map<String, dynamic> json) {
    return AdminCaseParty(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'role': role};
}

class AdminCaseJudge {
  const AdminCaseJudge({required this.name, required this.position});

  final String name;
  final String position;

  factory AdminCaseJudge.fromJson(Map<String, dynamic> json) {
    return AdminCaseJudge(
      name: json['name'] as String? ?? '',
      position: json['position'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'position': position};
}

class AdminCaseLegalAuthority {
  const AdminCaseLegalAuthority({required this.name, required this.section});

  final String name;
  final String section;

  factory AdminCaseLegalAuthority.fromJson(Map<String, dynamic> json) {
    return AdminCaseLegalAuthority(
      name: json['name'] as String? ?? '',
      section: json['section'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'section': section};
}

class AdminCasePrecedent {
  const AdminCasePrecedent({required this.citation, required this.title});

  final String citation;
  final String title;

  factory AdminCasePrecedent.fromJson(Map<String, dynamic> json) {
    return AdminCasePrecedent(
      citation: json['citation'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'citation': citation, 'title': title};
}

class AdminCaseModel {
  const AdminCaseModel({
    required this.id,
    required this.title,
    required this.citation,
    required this.jurisdiction,
    required this.court,
    required this.parties,
    required this.judges,
    required this.legalAuthorities,
    required this.precedents,
    required this.keywords,
    this.decision,
    this.judgmentDate,
    this.summary,
    this.ratioDecidendi,
    this.obiterDicta,
    this.proceduralHistory,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String citation;
  final String jurisdiction;
  final AdminCaseCourt court;
  final String? decision;
  final DateTime? judgmentDate;
  final String? summary;
  final String? ratioDecidendi;
  final String? obiterDicta;
  final String? proceduralHistory;
  final List<AdminCaseParty> parties;
  final List<AdminCaseJudge> judges;
  final List<AdminCaseLegalAuthority> legalAuthorities;
  final List<AdminCasePrecedent> precedents;
  final List<String> keywords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AdminCaseModel.fromJson(Map<String, dynamic> json) {
    List<T> parseObjects<T>(
      dynamic value,
      T Function(Map<String, dynamic>) parser,
    ) {
      return (value is List ? value : const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(parser)
          .toList();
    }

    final keywordsRaw = json['keywords'];
    final keywords = (keywordsRaw is List ? keywordsRaw : const <dynamic>[])
        .map((item) => item.toString())
        .where((value) => value.isNotEmpty)
        .toList();

    final courtRaw = json['court'];
    final court = courtRaw is Map<String, dynamic>
        ? AdminCaseCourt.fromJson(courtRaw)
        : const AdminCaseCourt(name: '', level: '');

    return AdminCaseModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      citation: json['citation'] as String? ?? '',
      jurisdiction: json['jurisdiction'] as String? ?? '',
      court: court,
      decision: json['decision'] as String?,
      judgmentDate: DateTime.tryParse(json['judgmentDate'] as String? ?? ''),
      summary: json['summary'] as String?,
      ratioDecidendi: json['ratioDecidendi'] as String?,
      obiterDicta: json['obiterDicta'] as String?,
      proceduralHistory: json['proceduralHistory'] as String?,
      parties: parseObjects(json['parties'], AdminCaseParty.fromJson),
      judges: parseObjects(json['judges'], AdminCaseJudge.fromJson),
      legalAuthorities: parseObjects(
        json['legalAuthorities'],
        AdminCaseLegalAuthority.fromJson,
      ),
      precedents: parseObjects(json['precedents'], AdminCasePrecedent.fromJson),
      keywords: keywords,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }
}

class PaginatedAdminCasesResponse {
  const PaginatedAdminCasesResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.count,
    required this.total,
  });

  final List<AdminCaseModel> data;
  final int currentPage;
  final int totalPages;
  final int count;
  final int total;

  factory PaginatedAdminCasesResponse.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    var currentPage = parseInt(json['currentPage'] ?? json['page'], 1);
    var totalPages = parseInt(json['totalPages'], 1);
    var count = parseInt(json['count'], 0);
    var total = parseInt(json['total'] ?? json['totalItems'], 0);

    dynamic rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      currentPage = parseInt(rawData['currentPage'] ?? rawData['page'], currentPage);
      totalPages = parseInt(rawData['totalPages'], totalPages);
      count = parseInt(rawData['count'], count);
      total = parseInt(rawData['total'] ?? rawData['totalItems'], total);
      rawData = rawData['data'] ?? rawData['cases'] ?? [];
    }

    final data = (rawData is List ? rawData : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(AdminCaseModel.fromJson)
        .toList();

    return PaginatedAdminCasesResponse(
      data: data,
      currentPage: currentPage,
      totalPages: totalPages,
      count: count == 0 ? data.length : count,
      total: total == 0 ? data.length : total,
    );
  }
}

class AdminCasesService {
  AdminCasesService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.adminCasesBaseUrl,
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

  Future<PaginatedAdminCasesResponse> fetchCases({
    int page = 1,
    int limit = 10,
    String? search,
    String? jurisdiction,
    String? courtLevel,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search?.isNotEmpty == true) query['search'] = search!;
    if (jurisdiction?.isNotEmpty == true) query['jurisdiction'] = jurisdiction!;
    if (courtLevel?.isNotEmpty == true) query['courtLevel'] = courtLevel!;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: query);
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch cases'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch cases',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return PaginatedAdminCasesResponse.fromJson(body);
    }
    return const PaginatedAdminCasesResponse(
      data: [],
      currentPage: 1,
      totalPages: 1,
      count: 0,
      total: 0,
    );
  }

  Future<AdminCaseModel> fetchCaseById(String id) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(id)}');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch case'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch case',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'] ?? body['case'] ?? body;
      if (data is Map<String, dynamic>) return AdminCaseModel.fromJson(data);
    }
    return AdminCaseModel.fromJson(const {});
  }

  Future<AdminCaseModel> createCase(Map<String, dynamic> payload) async {
    final uri = Uri.parse(_baseUrl);
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to create case'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to create case',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'] ?? body['case'] ?? body;
      if (data is Map<String, dynamic>) return AdminCaseModel.fromJson(data);
    }
    return AdminCaseModel.fromJson(const {});
  }

  Future<List<AdminCaseModel>> createCasesBulk(
    List<Map<String, dynamic>> cases,
  ) async {
    final uri = Uri.parse('$_baseUrl/bulk');
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(cases),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(
          response,
          fallback: 'Failed to create bulk cases',
        ),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to create bulk cases',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminCaseModel.fromJson)
            .toList();
      }
    }
    return const [];
  }

  Future<AdminCaseModel> updateCase({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$_baseUrl/${Uri.encodeComponent(id)}');
    final response = await _client.patch(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to update case'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to update case',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      final data = body['data'] ?? body['case'] ?? body;
      if (data is Map<String, dynamic>) return AdminCaseModel.fromJson(data);
    }
    return AdminCaseModel.fromJson(const {});
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
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to delete case',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}

