import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'http_client_factory.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.uri});

  final String message;
  final int? statusCode;
  final Uri? uri;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._({http.Client? inner}) : _inner = inner ?? createPlatformHttpClient() {
    final token = ApiConfig.defaultAuthToken.trim();
    if (token.isNotEmpty) {
      _accessToken = token;
    }
  }

  static final ApiClient shared = ApiClient._();

  final http.Client _inner;
  final Map<String, String> _cookies = {};
  String? _accessToken;

  static const String _acceptHeader = 'Accept';
  static const String _authorizationHeader = 'Authorization';
  static const String _contentTypeHeader = 'Content-Type';
  static const String _cookieHeader = 'Cookie';

  void setAccessToken(String? token) {
    final normalized = token?.trim();
    if (normalized == null || normalized.isEmpty) return;
    _accessToken = normalized;
  }

  void clearSession() {
    _cookies.clear();
    final token = ApiConfig.defaultAuthToken.trim();
    _accessToken = token.isNotEmpty ? token : null;
  }

  Future<bool> refreshToken() async {
    final uri = ApiConfig.resolve('/api/Auth/refresh-token');
    try {
      final response = await post(
        uri,
        headers: const {_contentTypeHeader: 'application/json'},
        body: jsonEncode(const {}),
        retryOn401: false,
      );
      if (response.statusCode != 200) return false;

      final accessTokenFromBody = _extractAccessTokenFromBody(response.body);
      if (accessTokenFromBody != null) {
        _accessToken = accessTokenFromBody;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    return _requestWithRefresh(
      retryOn401: retryOn401,
      request: () async {
        final merged = _mergeHeaders(headers);
        _applyDefaults(merged);
        return _inner.get(uri, headers: merged);
      },
    );
  }

  Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    return _requestWithRefresh(
      retryOn401: retryOn401,
      request: () async {
        final merged = _mergeHeaders(headers);
        _applyDefaults(merged);
        return _inner.delete(uri, headers: merged);
      },
    );
  }

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool retryOn401 = true,
  }) async {
    return _requestWithRefresh(
      retryOn401: retryOn401,
      request: () async {
        final merged = _mergeHeaders(headers);
        _applyDefaults(merged);
        return _inner.post(
          uri,
          headers: merged,
          body: body,
          encoding: encoding,
        );
      },
    );
  }

  Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool retryOn401 = true,
  }) async {
    return _requestWithRefresh(
      retryOn401: retryOn401,
      request: () async {
        final merged = _mergeHeaders(headers);
        _applyDefaults(merged);
        return _inner.patch(
          uri,
          headers: merged,
          body: body,
          encoding: encoding,
        );
      },
    );
  }

  Future<http.Response> sendMultipart(
    Future<http.MultipartRequest> Function() buildRequest, {
    bool retryOn401 = true,
  }) async {
    return _requestWithRefresh(
      retryOn401: retryOn401,
      request: () async {
        final request = await buildRequest();
        _applyDefaults(request.headers);
        final streamed = await _inner.send(request);
        final response = await http.Response.fromStream(streamed);
        _storeCookiesFromResponse(response);
        return response;
      },
    );
  }

  Future<http.Response> _requestWithRefresh({
    required bool retryOn401,
    required Future<http.Response> Function() request,
  }) async {
    final response = await request();
    _storeCookiesFromResponse(response);

    if (!retryOn401 || response.statusCode != 401) {
      return response;
    }

    final refreshed = await refreshToken();
    if (!refreshed) return response;

    final retryResponse = await request();
    _storeCookiesFromResponse(retryResponse);
    return retryResponse;
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    final merged = <String, String>{};
    if (headers != null) {
      merged.addAll(headers);
    }
    return merged;
  }

  void _applyDefaults(Map<String, String> headers) {
    headers.putIfAbsent(_acceptHeader, () => 'application/json');

    final accessToken = _accessToken;
    if (accessToken != null &&
        accessToken.isNotEmpty &&
        !headers.containsKey(_authorizationHeader)) {
      headers[_authorizationHeader] = 'Bearer $accessToken';
    }

    if (!kIsWeb && !headers.containsKey(_cookieHeader)) {
      final cookieHeader = _cookieHeaderValue;
      if (cookieHeader.isNotEmpty) {
        headers[_cookieHeader] = cookieHeader;
      }
    }
  }

  String get _cookieHeaderValue {
    if (_cookies.isEmpty) return '';
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  void _storeCookiesFromResponse(http.Response response) {
    final raw = response.headers['set-cookie'];
    if (raw == null || raw.isEmpty) return;

    for (final value in _splitSetCookieHeader(raw)) {
      try {
        final nameValue = value.split(';').first;
        final equalsIndex = nameValue.indexOf('=');
        if (equalsIndex <= 0) continue;
        final name = nameValue.substring(0, equalsIndex).trim();
        final cookieValue = nameValue.substring(equalsIndex + 1).trim();
        if (name.isEmpty) continue;

        if (cookieValue.isEmpty) {
          _cookies.remove(name);
        } else {
          _cookies[name] = cookieValue;
        }
        if (name == 'accessToken' && cookieValue.isNotEmpty) {
          _accessToken = cookieValue;
        }
      } catch (_) {
        // Ignore malformed cookie values.
      }
    }
  }

  List<String> _splitSetCookieHeader(String headerValue) {
    final results = <String>[];
    var start = 0;
    var inExpires = false;

    for (var i = 0; i < headerValue.length; i++) {
      final char = headerValue[i];

      if (!inExpires && _matchesAt(headerValue, i, 'expires=')) {
        inExpires = true;
        continue;
      }

      if (inExpires && char == ';') {
        inExpires = false;
        continue;
      }

      if (char == ',' && !inExpires) {
        final part = headerValue.substring(start, i).trim();
        if (part.isNotEmpty) results.add(part);
        start = i + 1;
      }
    }

    final last = headerValue.substring(start).trim();
    if (last.isNotEmpty) results.add(last);
    return results;
  }

  bool _matchesAt(String source, int index, String pattern) {
    if (index + pattern.length > source.length) return false;
    return source.substring(index, index + pattern.length).toLowerCase() ==
        pattern.toLowerCase();
  }

  String? _extractAccessTokenFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final direct = decoded['accessToken'];
        if (direct is String && direct.trim().isNotEmpty) {
          return direct.trim();
        }
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final nested = data['accessToken'];
          if (nested is String && nested.trim().isNotEmpty) {
            return nested.trim();
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static String extractMessage(http.Response response, {String fallback = 'Request failed'}) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {}
    return fallback;
  }
}
