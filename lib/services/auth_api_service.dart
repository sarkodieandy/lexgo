import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';

/// Authentication service — all calls hit the real `/api/Auth` backend.
///
/// ## Cookie strategy
/// The server sets `accessToken`, `refreshToken`, and `otpCodeToken` as
/// **HttpOnly cookies**. Flutter's `http` package doesn't manage cookies
/// automatically, so we:
///   1. Parse `Set-Cookie` headers from every response.
///   2. Store tokens in static in-memory fields (never in SharedPreferences).
///   3. Inject `Cookie: ...` headers on every outbound request (handled by
///      [ApiClient.send]).
class AuthApiService {
  static String get _base => '$kApiBase/api/v1/Auth';

  // ── Token persistence ──────────────────────────────────────────────────────

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Save the access token to encrypted secure storage.
  static Future<void> saveLoginToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Save the refresh token to encrypted secure storage.
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  /// Check if the user has an active session in secure storage.
  static Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'auth_token');
    String? refresh = await _storage.read(key: 'refresh_token');
    return (token?.isNotEmpty ?? false) || (refresh?.isNotEmpty ?? false);
  }

  /// Loads tokens from Secure Storage into memory.
  static Future<void> initTokens() async {
    memoryAccessToken = await _storage.read(key: 'auth_token');
    memoryRefreshToken = await _storage.read(key: 'refresh_token');
  }

  // ── In-memory token storage (cleared on app restart / logout if not persisted) ─────────────

  /// Short-lived JWT — used in `Authorization: Bearer` + `Cookie: accessToken`.
  static String? memoryAccessToken;

  /// Long-lived JWT — sent automatically with refresh calls.
  static String? memoryRefreshToken;

  /// OTP session token — valid only during password-reset flow.
  static String? memoryOtpToken;

  // ── Cookie helpers ─────────────────────────────────────────────────────────

  static Future<void> _extractCookies(http.Response response) async {
    final raw = response.headers['set-cookie'] ?? '';
    if (raw.isEmpty) return;

    final at = RegExp(r'accessToken=([^;]+)').firstMatch(raw)?.group(1)?.trim();
    if (at != null && at.isNotEmpty) {
      memoryAccessToken = at;
      await saveLoginToken(at);
    }
    
    final rt = RegExp(r'refreshToken=([^;]+)').firstMatch(raw)?.group(1)?.trim();
    if (rt != null && rt.isNotEmpty) {
      memoryRefreshToken = rt;
      await saveRefreshToken(rt);
    }

    final ot = RegExp(r'otpCodeToken=([^;]+)').firstMatch(raw)?.group(1)?.trim();
    if (ot != null && ot.isNotEmpty) memoryOtpToken = ot;
  }

  /// Build the `Cookie` header string from currently stored tokens.
  static String? _buildCookieHeader({
    bool includeAccess   = false,
    bool includeRefresh  = false,
    bool includeOtp      = false,
  }) {
    final parts = <String>[];
    if (includeAccess  && memoryAccessToken  != null) parts.add('accessToken=$memoryAccessToken');
    if (includeRefresh && memoryRefreshToken != null) parts.add('refreshToken=$memoryRefreshToken');
    if (includeOtp     && memoryOtpToken     != null) parts.add('otpCodeToken=$memoryOtpToken');
    return parts.isEmpty ? null : parts.join('; ');
  }

  /// Clear every in-memory token and the persisted session flags.
  Future<void> _clearSession() async {
    memoryAccessToken  = null;
    memoryRefreshToken = null;
    memoryOtpToken     = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }

  /// Decode the error message from a non-2xx response body.
  String _errorMessage(http.Response response) {
    try {
      final body = json.decode(response.body) as Map<String, dynamic>;
      // Validation errors return an `errors` array
      if (body.containsKey('errors')) {
        final errors = body['errors'] as List<dynamic>;
        return errors.map((e) => e['message'] ?? e.toString()).join('\n');
      }
      return body['message'] as String? ?? 'Unexpected error (${response.statusCode})';
    } catch (_) {
      return 'Unexpected error (${response.statusCode})';
    }
  }

  // ── 1. Register ────────────────────────────────────────────────────────────

  /// Creates a new user account.
  ///
  /// [role] must be `'student'`, `'lecturer'`, or `'admin'` (default: `'student'`).
  /// Student-only fields ([acadamicLevel], [program], [studentId]) are required
  /// when [role] is `'student'`.
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    String?         otherName,
    required String phoneNumber,
    required String university,
    required String email,
    required String password,
    required String confirmPassword,
    String          role            = 'student',
    String?         acadamicLevel,
    String?         program,
    String?         studentId,
  }) async {
    final body = <String, dynamic>{
      'firstName':        firstName,
      'lastName':         lastName,
      'phoneNumber':      phoneNumber,
      'university':       university,
      'email':            email,
      'password':         password,
      'confirmPassword':  confirmPassword,
      'role':             role,
    };

    if (otherName != null && otherName.isNotEmpty) body['otherName'] = otherName;

    if (role == 'student') {
      if (acadamicLevel != null) body['acadamicLevel'] = acadamicLevel;
      if (program       != null) body['program']       = program;
      if (studentId     != null) body['studentId']     = studentId;
    }

    final response = await http.post(
      Uri.parse('$_base/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      User? user;
      if (data['data'] != null) {
        user = User.fromJson(data['data'] as Map<String, dynamic>);
      }
      return {
        'success': true,
        'message': data['message'] ?? 'Account created successfully',
        'user': user,
      };
    }

    throw Exception(_errorMessage(response));
  }

  // ── 2. Login ───────────────────────────────────────────────────────────────

  /// Authenticates the user.
  ///
  /// On success the server sets `accessToken` and `refreshToken` cookies which
  /// are parsed and stored in memory. `isLoggedIn` is persisted to
  /// SharedPreferences so the splash screen can detect returning sessions.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      await _extractCookies(response);

      // Also try to extract tokens from response body as a fallback
      // (in case Set-Cookie headers are not accessible on this platform)
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final bodyData = data['data'] as Map<String, dynamic>?;

        // Token might be at top-level or inside 'data'
        final bodyAccessToken =
            data['accessToken'] as String? ??
            bodyData?['accessToken'] as String? ??
            data['token'] as String? ??
            bodyData?['token'] as String?;
        final bodyRefreshToken =
            data['refreshToken'] as String? ??
            bodyData?['refreshToken'] as String?;

        if (bodyAccessToken != null && bodyAccessToken.isNotEmpty) {
          memoryAccessToken = bodyAccessToken;
          await AuthApiService.saveLoginToken(bodyAccessToken);
        }
        if (bodyRefreshToken != null && bodyRefreshToken.isNotEmpty) {
          memoryRefreshToken = bodyRefreshToken;
          await AuthApiService.saveRefreshToken(bodyRefreshToken);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        final userName = email.contains('@') ? email.split('@').first : email;
        await prefs.setString('userName', userName);

        return {
          'success': true,
          'message': data['message'] ?? 'Logged in successfully',
        };
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      final userName = email.contains('@') ? email.split('@').first : email;
      await prefs.setString('userName', userName);

      return {
        'success': true,
        'message': 'Logged in successfully',
      };
    }

    if (response.statusCode == 429) {
      throw Exception('Too many login attempts. Please try again in 15 minutes.');
    }

    throw Exception(_errorMessage(response));
  }

  // ── 3. Logout ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> logout() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final cookie = _buildCookieHeader(includeAccess: true, includeRefresh: true);
    if (cookie != null) headers['Cookie'] = cookie;

    try {
      final response = await http.post(
        Uri.parse('$_base/logout'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      await _clearSession();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      }
      // Even if the server errors, we clear local state so the user is logged out.
      return {'success': true, 'message': 'Logged out'};
    } catch (_) {
      await _clearSession();
      return {'success': true, 'message': 'Logged out'};
    }
  }

  // ── 4.1 Send OTP ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    final response = await http.post(
      Uri.parse('$_base/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      await _extractCookies(response); // stores otpCodeToken
      final data = json.decode(response.body) as Map<String, dynamic>;
      return {
        'success': true,
        'message': data['message'] ?? 'If an account exists, an OTP has been sent.',
      };
    }

    if (response.statusCode == 429) {
      throw Exception('Too many OTP requests. Please try again in 15 minutes.');
    }

    throw Exception(_errorMessage(response));
  }

  // ── 4.2 Verify OTP ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyOtp({required String otpCode}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final cookie = _buildCookieHeader(includeOtp: true);
    if (cookie != null) headers['Cookie'] = cookie;

    final response = await http.post(
      Uri.parse('$_base/verify-otp'),
      headers: headers,
      body: json.encode({'otpCode': otpCode}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return {
        'success': true,
        'message': data['message'] ?? 'OTP verified successfully',
      };
    }

    throw Exception(_errorMessage(response));
  }

  // ── 4.3 Reset Password ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> resetPassword({
    required String password,
    required String confirmPassword,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final cookie = _buildCookieHeader(includeOtp: true);
    if (cookie != null) headers['Cookie'] = cookie;

    final response = await http.patch(
      Uri.parse('$_base/reset-password'),
      headers: headers,
      body: json.encode({
        'password':        password,
        'confirmPassword': confirmPassword,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      memoryOtpToken = null; // server clears the cookie; clear ours too
      final data = json.decode(response.body) as Map<String, dynamic>;
      return {
        'success': true,
        'message': data['message'] ?? 'Password reset successfully',
      };
    }

    throw Exception(_errorMessage(response));
  }

  // ── 5. Refresh Token ──────────────────────────────────────────────────────

  /// Silently rotate both tokens using the stored refresh token.
  ///
  /// Throws on failure so [ApiClient] can trigger a logout.
  Future<Map<String, dynamic>> refreshToken() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final cookie = _buildCookieHeader(includeRefresh: true);
    if (cookie != null) headers['Cookie'] = cookie;

    final response = await http.post(
      Uri.parse('$_base/refresh-token'),
      headers: headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      await _extractCookies(response); // updates accessToken + refreshToken

      // Also try to extract tokens from body as a fallback
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final bodyData = data['data'] as Map<String, dynamic>?;

        final bodyAccessToken =
            data['accessToken'] as String? ??
            bodyData?['accessToken'] as String? ??
            data['token'] as String? ??
            bodyData?['token'] as String?;
        final bodyRefreshToken =
            data['refreshToken'] as String? ??
            bodyData?['refreshToken'] as String?;

        if (bodyAccessToken != null && bodyAccessToken.isNotEmpty) {
          memoryAccessToken = bodyAccessToken;
          await AuthApiService.saveLoginToken(bodyAccessToken);
        }
        if (bodyRefreshToken != null && bodyRefreshToken.isNotEmpty) {
          memoryRefreshToken = bodyRefreshToken;
          await AuthApiService.saveRefreshToken(bodyRefreshToken);
        }
      } catch (_) {}

      final data = json.decode(response.body) as Map<String, dynamic>;
      return {
        'success': true,
        'message': data['message'] ?? 'Token refreshed successfully',
      };
    }

    // 401 means the refresh token has expired — caller should force logout
    throw Exception('Session expired. Please log in again.');
  }
}
