import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'api_config.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient.shared;

  final ApiClient _client;

  Future<void> register({
    required String firstName,
    required String lastName,
    String? otherName,
    required String phoneNumber,
    required String university,
    String? acadamicLevel,
    String? program,
    String? studentId,
    required String email,
    required String password,
    required String confirmPassword,
    String role = 'lecturer',
    String? detectedCountry,
  }) async {
    final uri = ApiConfig.resolve('/api/Auth/register');
    try {
      final payload = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'university': university,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
        if (otherName?.trim().isNotEmpty == true) 'otherName': otherName!.trim(),
        if (acadamicLevel?.trim().isNotEmpty == true)
          'acadamicLevel': acadamicLevel!.trim(),
        if (program?.trim().isNotEmpty == true) 'program': program!.trim(),
        if (studentId?.trim().isNotEmpty == true)
          'studentId': studentId!.trim(),
        if (detectedCountry?.trim().isNotEmpty == true)
          'detectedCountry': detectedCountry!.trim(),
      };

      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
        retryOn401: false,
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException(
          ApiClient.extractMessage(response, fallback: 'Signup failed'),
          statusCode: response.statusCode,
          uri: uri,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == false) {
        throw ApiException(
          (decoded['message'] as String?) ?? 'Signup failed',
          statusCode: response.statusCode,
          uri: uri,
        );
      }
    } catch (error, stackTrace) {
      _logError('register', error, stackTrace);
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final uri = ApiConfig.resolve('/api/Auth/login');
    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode != 200) {
        throw ApiException(
          ApiClient.extractMessage(response, fallback: 'Login failed'),
          statusCode: response.statusCode,
          uri: uri,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final token = decoded['accessToken'];
        if (token is String && token.trim().isNotEmpty) {
          _client.setAccessToken(token);
        }
      }
    } on FormatException {
      // Ignore non-JSON responses when login succeeds via cookies only.
    } catch (error, stackTrace) {
      _logError('login', error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    final uri = ApiConfig.resolve('/api/Auth/logout');
    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(const {}),
        retryOn401: false,
      );
      if (response.statusCode != 200) {
        throw ApiException(
          ApiClient.extractMessage(response, fallback: 'Logout failed'),
          statusCode: response.statusCode,
          uri: uri,
        );
      }
      _client.clearSession();
    } catch (error, stackTrace) {
      _logError('logout', error, stackTrace);
      rethrow;
    }
  }

  Future<bool> refreshSession() => _client.refreshToken();

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint('[AuthService] $action failed: $error');
    debugPrintStack(
      stackTrace: stackTrace,
      label: '[AuthService] $action stack',
    );
  }
}
