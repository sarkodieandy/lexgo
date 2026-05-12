import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthPersistenceService {
  static const String _tokenKey = 'auth_token';
  static const String _cookiesKey = 'auth_cookies';

  Future<void> saveSession({String? token, Map<String, String>? cookies}) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    }
    if (cookies != null) {
      await prefs.setString(_cookiesKey, jsonEncode(cookies));
    }
    debugPrint('[AuthPersistenceService] Session saved.');
  }

  Future<Map<String, dynamic>> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final cookiesRaw = prefs.getString(_cookiesKey);
    
    Map<String, String>? cookies;
    if (cookiesRaw != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cookiesRaw);
        cookies = decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        debugPrint('[AuthPersistenceService] Failed to decode cookies: $e');
      }
    }

    return {
      'token': token,
      'cookies': cookies,
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_cookiesKey);
    debugPrint('[AuthPersistenceService] Session cleared.');
  }
}
