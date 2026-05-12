import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
export 'package:http/http.dart'
    hide get, post, put, patch, delete, head, read, readBytes;
import 'package:lexgo/services/auth_api_service.dart';

// Provides a drop-in replacement for the global `http` functions
final _client = ApiClient();

Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
    _client.get(url, headers: headers);
Future<http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => _client.post(url, headers: headers, body: body, encoding: encoding);
Future<http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => _client.put(url, headers: headers, body: body, encoding: encoding);
Future<http.Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => _client.patch(url, headers: headers, body: body, encoding: encoding);
Future<http.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) => _client.delete(url, headers: headers, body: body, encoding: encoding);
Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
    _client.head(url, headers: headers);
Future<String> read(Uri url, {Map<String, String>? headers}) =>
    _client.read(url, headers: headers);
Future<List<int>> readBytes(Uri url, {Map<String, String>? headers}) =>
    _client.readBytes(url, headers: headers);

/// HTTP client that:
///   1. Injects `Cookie: accessToken=<token>` (when available) on every request.
///   2. On 401 responses, silently calls `refresh-token`, updates the stored token,
///      and retries the original request exactly once.
///   3. On a failed refresh (session truly expired), passes the 401 up so the
///      caller / UI can force a logout.
class ApiClient extends http.BaseClient {
  final http.Client _inner = _buildClient();
  final AuthApiService _authService = AuthApiService();

  /// Creates an IOClient backed by a dart:io HttpClient.
  /// In debug mode, bad certificates are accepted (fixes Render.com / self-signed
  /// SSL handshake failures on older Android devices).
  static http.Client _buildClient() {
    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    if (kDebugMode) {
      // Allow all certificates in debug — avoids handshake failures on
      // Android devices that don't have the Render.com root CA in their trust store.
      ioClient.badCertificateCallback = (cert, host, port) => true;
    }
    return IOClient(ioClient);
  }

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Wait for any concurrent refresh to finish before sending
    if (_isRefreshing && _refreshCompleter != null) {
      await _refreshCompleter!.future;
    }

    // Inject the accessToken cookie on every request (if we have one)
    _injectCookie(request);

    // Clone the request before sending (requests can only be sent once)
    final clonedRequest = await _copyRequest(request);

    final response = await _inner.send(request);

    // 403 Forbidden = user lacks permission — no point trying a refresh
    if (response.statusCode == 403) {
      return response;
    }

    // 401 Unauthorized = accessToken expired — try to refresh once
    if (response.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshCompleter = Completer<bool>();

        try {
          await _authService.refreshToken();
          _refreshCompleter!.complete(true);
        } catch (_) {
          _refreshCompleter!.complete(false);
          _isRefreshing = false;
          // Refresh failed — return 401 so the app can force logout
          return response;
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Another request already triggered the refresh — wait for it
        final success = await _refreshCompleter!.future;
        if (!success) return response;
      }

      // Retry with updated accessToken
      _injectCookie(clonedRequest);
      return _inner.send(clonedRequest);
    }

    return response;
  }

  /// Inject `Cookie: accessToken=...` (and refreshToken if present) into [request].
  void _injectCookie(http.BaseRequest request) {
    final parts = <String>[];
    if (AuthApiService.memoryAccessToken  != null) parts.add('accessToken=${AuthApiService.memoryAccessToken}');
    if (AuthApiService.memoryRefreshToken != null) parts.add('refreshToken=${AuthApiService.memoryRefreshToken}');
    if (parts.isNotEmpty) {
      request.headers['Cookie'] = parts.join('; ');
    }
  }

  Future<http.BaseRequest> _copyRequest(http.BaseRequest request) async {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url);
      copy.headers.addAll(request.headers);
      copy.encoding = request.encoding;
      copy.bodyBytes = request.bodyBytes;
      return copy;
    } else if (request is http.MultipartRequest) {
      final copy = http.MultipartRequest(request.method, request.url);
      copy.headers.addAll(request.headers);
      copy.fields.addAll(request.fields);
      copy.files.addAll(request.files);
      return copy;
    }
    return request;
  }
}
