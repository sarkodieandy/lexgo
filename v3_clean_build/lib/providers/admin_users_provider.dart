import 'package:flutter/foundation.dart';

import '../services/admin_users_service.dart';

class AdminUsersProvider extends ChangeNotifier {
  AdminUsersProvider({AdminUsersService? service})
    : _service = service ?? AdminUsersService();

  final AdminUsersService _service;

  final List<AdminUserModel> _users = [];
  List<AdminUserModel> get users => List.unmodifiable(_users);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalItems = 0;
  int get totalItems => _totalItems;

  String? _role;
  String? get role => _role;

  String? _search;
  String? get search => _search;

  String _sortBy = 'createdAt';
  String get sortBy => _sortBy;

  String _sortOrder = 'desc';
  String get sortOrder => _sortOrder;

  Future<void> load({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _service.fetchUsers(
        page: page,
        limit: limit,
        role: _role,
        search: _search,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      _users
        ..clear()
        ..addAll(response.data);
      final pagination = response.pagination;
      _currentPage = pagination?.page ?? page;
      _totalPages = pagination?.totalPages ?? 1;
      _totalItems = pagination?.totalItems ?? response.data.length;
    } catch (err) {
      _error = err.toString();
      _users.clear();
      _totalItems = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setRole(String? value) async {
    _role = (value?.isEmpty ?? true) ? null : value;
    await load(page: 1);
  }

  Future<void> setSearch(String? value) async {
    final trimmed = value?.trim() ?? '';
    _search = trimmed.isEmpty ? null : trimmed;
    await load(page: 1);
  }

  Future<void> setSort({
    required String sortBy,
    required String sortOrder,
  }) async {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    await load(page: 1);
  }
}

