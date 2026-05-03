import 'dart:convert';

import 'api_config.dart';
import 'api_client.dart';

class AiService {
  AiService({ApiClient? client, String? baseUrl, String? authToken})
    : _client = client ?? ApiClient.shared,
      _baseUrl = baseUrl ?? ApiConfig.aiBaseUrl,
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

  Future<void> askAi() async {
    final uri = Uri.parse('$_baseUrl/ask-AI');
    final response = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(const {}),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        ApiClient.extractMessage(response, fallback: 'Failed to ask AI'),
        statusCode: response.statusCode,
        uri: uri,
      );
    }
    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to ask AI',
        statusCode: response.statusCode,
        uri: uri,
      );
    }
  }
}
