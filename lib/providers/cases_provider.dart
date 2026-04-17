import 'package:flutter/material.dart';

import '../models/cases/case_item.dart';
import '../models/filter_selection.dart';
import '../services/cases_service.dart';

class CasesProvider extends ChangeNotifier {
  CasesProvider({CasesService? service}) : _service = service ?? CasesService();

  final CasesService _service;

  final List<CaseItem> _cases = [];
  List<CaseItem> get cases => List.unmodifiable(_cases);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  // Cursor-based pagination state
  String? _nextCursor;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  FilterSelection? _activeFilter;
  FilterSelection? get activeFilter => _activeFilter;

  String? _searchTerm;

  List<String> get availableCategories {
    final categories = _cases.map((item) => item.tag).toSet().toList()..sort();
    return ['All Categories', ...categories];
  }

  /// Load (or reload) the first page of cases.
  Future<void> loadCases() async {
    _nextCursor = null;
    await _fetchCases(refresh: true);
  }

  /// Load the next page using the stored cursor.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    await _fetchCases(refresh: false);
  }

  Future<void> applyFilter(FilterSelection filter) async {
    _activeFilter = filter;
    _nextCursor = null;
    await _fetchCases(refresh: true);
  }

  Future<void> search(String? query) async {
    _searchTerm = query?.trim().isEmpty == true ? null : query;
    _nextCursor = null;
    await _fetchCases(refresh: true);
  }

  Future<void> createCase({
    required String courseId,
    required String title,
    required String sourceOfCase,
    required String caseCode,
    required String caseCategory,
    required String documentPath,
  }) async {
    final model = await _service.createCase(
      courseId: courseId,
      title: title,
      sourceOfCase: sourceOfCase,
      caseCode: caseCode,
      caseCategory: caseCategory,
      documentPath: documentPath,
    );
    _cases.insert(0, CaseItem.fromModel(model));
    notifyListeners();
  }

  Future<void> deleteCase(String id) async {
    await _service.deleteCase(id);
    _cases.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> _fetchCases({required bool refresh}) async {
    if (refresh) {
      _isLoading = true;
      _error = null;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _service.fetchAllCases(
        cursor: refresh ? null : _nextCursor,
        title: _searchTerm,
        category: _activeFilter?.category == 'All Categories'
            ? null
            : _activeFilter?.category,
        sortOrder: _sortOrderFromFilter(_activeFilter?.sort),
      );

      if (refresh) {
        _cases
          ..clear()
          ..addAll(response.data.map(CaseItem.fromModel));
      } else {
        _cases.addAll(response.data.map(CaseItem.fromModel));
      }

      _nextCursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  String _sortOrderFromFilter(FilterSort? sort) {
    switch (sort) {
      case FilterSort.alphabeticalAsc:
      case FilterSort.dateOldest:
        return 'asc';
      default:
        return 'desc';
    }
  }
}
