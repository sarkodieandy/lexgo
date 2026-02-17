import 'dart:convert';

import 'api_client.dart';
import 'api_config.dart';

class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.university,
    this.academicLevel,
    this.program,
    this.studentId,
    this.onboardingCompleted,
    this.askAi,
    this.detectedCountry,
    this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? university;
  final String? academicLevel;
  final String? program;
  final String? studentId;
  final bool? onboardingCompleted;
  final int? askAi;
  final String? detectedCountry;
  final DateTime? createdAt;

  String get fullName {
    final value = '$firstName $lastName'.trim();
    return value.isEmpty ? email : value;
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    bool? parseBool(dynamic value) {
      if (value is bool) return value;
      if (value == null) return null;
      return value.toString().toLowerCase() == 'true';
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    return AdminUserModel(
      id: json['_id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      university: json['university'] as String?,
      academicLevel: json['acadamicLevel'] as String?,
      program: json['program'] as String?,
      studentId: json['studentId'] as String?,
      onboardingCompleted: parseBool(json['onboardingCompleted']),
      askAi: parseInt(json['askAI'] ?? json['askAi']),
      detectedCountry: json['detectedCountry'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class AdminUsersPagination {
  const AdminUsersPagination({
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

  factory AdminUsersPagination.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    return AdminUsersPagination(
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

class PaginatedAdminUsersResponse {
  const PaginatedAdminUsersResponse({
    required this.data,
    required this.pagination,
  });

  final List<AdminUserModel> data;
  final AdminUsersPagination? pagination;

  factory PaginatedAdminUsersResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = (rawData is List ? rawData : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(AdminUserModel.fromJson)
        .toList();

    final paginationRaw = json['pagination'];
    final pagination = paginationRaw is Map<String, dynamic>
        ? AdminUsersPagination.fromJson(paginationRaw)
        : null;

    return PaginatedAdminUsersResponse(data: data, pagination: pagination);
  }
}

class AdminUsersService {
  AdminUsersService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.adminBaseUrl,
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

  Future<PaginatedAdminUsersResponse> fetchUsers({
    int page = 1,
    int limit = 10,
    String? role,
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
    if (role?.isNotEmpty == true) query['role'] = role!;
    if (search?.isNotEmpty == true) query['search'] = search!;

    final uri = Uri.parse('$_baseUrl/users').replace(queryParameters: query);
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to fetch users'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          (body['message'] as String?) ?? 'Failed to fetch users',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      return PaginatedAdminUsersResponse.fromJson(body);
    }
    return const PaginatedAdminUsersResponse(data: [], pagination: null);
  }
}

