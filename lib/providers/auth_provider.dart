import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service})
    : _service = service ?? AuthService(),
      _isAuthenticated = ApiConfig.defaultAuthToken.trim().isNotEmpty {
    _bootstrap();
    // Listen for terminal session failures from the API layer
    ApiClient.shared.onSessionExpired.addListener(_handleSessionExpired);
  }

  void _handleSessionExpired() {
    if (ApiClient.shared.onSessionExpired.value) {
      if (_isAuthenticated) {
        _isAuthenticated = false;
        _currentUser = null;
        _error = 'Session expired. Please login again.';
        notifyListeners();
      }
      // Reset the notifier
      ApiClient.shared.onSessionExpired.value = false;
    }
  }

  final AuthService _service;

  bool _isBootstrapping = true;
  bool get isBootstrapping => _isBootstrapping;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  bool _isAuthenticated;
  bool get isAuthenticated => _isAuthenticated;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String get userName => _currentUser?.firstName ?? 'Dr.';

  String? _error;
  String? get error => _error;

  Future<void> _bootstrap() async {
    await ApiClient.shared.init();
    if (_isAuthenticated || ApiClient.shared.authHeaders.isNotEmpty) {
      _isBootstrapping = false;
      notifyListeners();
      return;
    }

    _error = null;
    notifyListeners();
    try {
      _currentUser = await _service.refreshSession();
      _isAuthenticated = _currentUser != null;
    } catch (err, stackTrace) {
      debugPrint('[AuthProvider] bootstrap failed: $err');
      debugPrintStack(
        stackTrace: stackTrace,
        label: '[AuthProvider] bootstrap stack',
      );
      _error = err.toString();
      _isAuthenticated = false;
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _service.login(email: email, password: password);
      _isAuthenticated = true;
    } catch (err, stackTrace) {
      debugPrint('[AuthProvider] login failed: $err');
      debugPrintStack(
        stackTrace: stackTrace,
        label: '[AuthProvider] login stack',
      );
      _error = err.toString();
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

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
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      await _service.register(
        firstName: firstName,
        lastName: lastName,
        otherName: otherName,
        phoneNumber: phoneNumber,
        university: university,
        acadamicLevel: acadamicLevel,
        program: program,
        studentId: studentId,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        detectedCountry: detectedCountry,
      );
    } catch (err, stackTrace) {
      debugPrint('[AuthProvider] register failed: $err');
      debugPrintStack(
        stackTrace: stackTrace,
        label: '[AuthProvider] register stack',
      );
      _error = err.toString();
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      await _service.logout();
      _isAuthenticated = false;
    } catch (err, stackTrace) {
      debugPrint('[AuthProvider] logout failed: $err');
      debugPrintStack(
        stackTrace: stackTrace,
        label: '[AuthProvider] logout stack',
      );
      _error = err.toString();
      rethrow;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isBootstrapping = true;
    notifyListeners();
    await _bootstrap();
  }
}
