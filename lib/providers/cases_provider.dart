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

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  FilterSelection? _activeFilter;
  FilterSelection? get activeFilter => _activeFilter;

  String? _searchTerm;

  List<String> get availableCategories {
    final categories = _cases.map((item) => item.tag).toSet().toList()..sort();
    return ['All Categories', ...categories];
  }

  Future<void> loadCases({int page = 1}) async {
    await _fetchCases(page);
  }

  Future<void> applyFilter(FilterSelection filter) async {
    _activeFilter = filter;
    await _fetchCases(1);
  }

  Future<void> search(String? query) async {
    _searchTerm = query?.trim().isEmpty == true ? null : query;
    await _fetchCases(1);
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

  Future<void> _fetchCases(int page) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _service.fetchAllCases(
        page: page,
        title: _searchTerm,
        category: _activeFilter?.category == 'All Categories'
            ? null
            : _activeFilter?.category,
        sortedBy: _sortFieldFromFilter(_activeFilter?.sort),
        sortOrder: _sortOrderFromFilter(_activeFilter?.sort),
      );
      _cases
        ..clear()
        ..addAll(response.data.map(CaseItem.fromModel));
      _currentPage = response.currentPage;
      _totalPages = response.totalPages;
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _sortFieldFromFilter(FilterSort? sort) {
    switch (sort) {
      case FilterSort.alphabeticalAsc:
      case FilterSort.alphabeticalDesc:
        return 'title';
      case FilterSort.dateNewest:
      case FilterSort.dateOldest:
        return '_id';
      default:
        return '_id';
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
