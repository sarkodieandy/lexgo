import 'dart:convert';
import 'package:lexgo/services/api_client.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'package:lexgo/services/auth_api_service.dart';

class UserStatsService {
  static String get _defaultBaseUrl => '$kApiBase/api/v1/Stats';
  String get baseUrl => _defaultBaseUrl;

  static const String _studyStreakKey = 'study_streak_count';
  static const String _lastActiveDateKey = 'last_active_date';
  static const String _casesStudiedKey = 'cases_studied_count';
  static const String _aiChatsKey = 'ai_chats_count';

  Future<Map<String, String>> _getHeaders() async {
    final token = AuthApiService.memoryAccessToken;
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Call this when the app opens or drawer is loaded
  Future<void> updateStudyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActiveStr = prefs.getString(_lastActiveDateKey);
    final currentStreak = prefs.getInt(_studyStreakKey) ?? 0;

    int newStreak = currentStreak;

    if (lastActiveStr == null) {
      newStreak = 1;
    } else {
      final lastActiveDate = DateTime.parse(lastActiveStr);
      final difference = today.difference(lastActiveDate).inDays;
      if (difference == 1) {
        newStreak = currentStreak + 1;
      } else if (difference > 1) {
        newStreak = 1;
      } else if (difference == 0 && currentStreak == 0) {
        newStreak = 1;
      }
    }

    try {
      final uri = Uri.parse('$baseUrl/sync');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'studyStreak': newStreak,
        'lastActiveDate': today.toIso8601String(),
      });
      await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Offline fallback: save locally
      await prefs.setInt(_studyStreakKey, newStreak);
      await prefs.setString(_lastActiveDateKey, today.toIso8601String());
    }
  }

  Future<void> incrementCasesStudied() async {
    try {
      final uri = Uri.parse('$baseUrl/sync');
      final headers = await _getHeaders();
      await http
          .post(uri, headers: headers, body: jsonEncode({'incrementCases': 1}))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Offline fallback: save locally
      final prefs = await SharedPreferences.getInstance();
      final currentCases = prefs.getInt(_casesStudiedKey) ?? 0;
      await prefs.setInt(_casesStudiedKey, currentCases + 1);
    }
  }

  Future<void> incrementAiChats() async {
    try {
      final uri = Uri.parse('$baseUrl/sync');
      final headers = await _getHeaders();
      await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({'incrementAiChats': 1}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      // Offline fallback: save locally
      final prefs = await SharedPreferences.getInstance();
      final currentChats = prefs.getInt(_aiChatsKey) ?? 0;
      await prefs.setInt(_aiChatsKey, currentChats + 1);
    }
  }

  Future<Map<String, int>> getStats() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final uri = Uri.parse(baseUrl);
      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Cache API response for future offline use
        await prefs.setInt(_studyStreakKey, data['studyStreak'] ?? 0);
        await prefs.setInt(_casesStudiedKey, data['casesStudied'] ?? 0);
        await prefs.setInt(_aiChatsKey, data['aiChats'] ?? 0);

        return {
          'studyStreak': data['studyStreak'] ?? 0,
          'casesStudied': data['casesStudied'] ?? 0,
          'aiChats': data['aiChats'] ?? 0,
        };
      }
    } catch (_) {
      // Ignore exception and drop to local fallback
    }

    // Offline fallback: load from SharedPreferences
    return {
      'studyStreak': prefs.getInt(_studyStreakKey) ?? 0,
      'casesStudied': prefs.getInt(_casesStudiedKey) ?? 0,
      'aiChats': prefs.getInt(_aiChatsKey) ?? 0,
    };
  }
}
