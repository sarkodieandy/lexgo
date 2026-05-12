import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/course_assignment.dart';

class CourseAssignmentsProvider extends ChangeNotifier {
  final Map<String, List<CourseAssignment>> _assignmentsByCourse = {};
  final List<String> _searchHistory = [
    'Assignment 1',
    'Assignment 2',
    'Assignment 3',
    'Assignment 4',
  ];

  List<CourseAssignment> assignmentsFor(Course course) {
    return List.unmodifiable(
      _assignmentsByCourse.putIfAbsent(
        course.code,
        () => _seedAssignments(course),
      ),
    );
  }

  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  void addAssignment(Course course, CourseAssignment assignment) {
    final assignments = _assignmentsByCourse.putIfAbsent(
      course.code,
      () => _seedAssignments(course),
    );
    assignments.insert(0, assignment);
    notifyListeners();
  }

  void recordSearchTerm(String term) {
    final normalized = term.trim();
    if (normalized.isEmpty) return;
    _searchHistory.remove(normalized);
    _searchHistory.insert(0, normalized);
    notifyListeners();
  }

  void removeSearchTerm(String term) {
    _searchHistory.remove(term);
    notifyListeners();
  }

  List<CourseAssignment> _seedAssignments(Course course) {
    final now = DateTime(2025, 10, 29);
    return [
      CourseAssignment(
        id: '${course.code}-1',
        title: 'Assignment 1 : ${course.title}',
        description: 'Test your knowledge',
        dueDate: now,
        dueTime: '11:59 PM',
        points: 10,
        gradeScale: '100 marks',
        submissionType: 'file Upload',
      ),
      CourseAssignment(
        id: '${course.code}-2',
        title: 'Assignment 2 : ${course.title}',
        description: 'Apply the main principles from the last module.',
        dueDate: now.add(const Duration(days: 7)),
        dueTime: '5:00 PM',
        points: 12,
      ),
      CourseAssignment(
        id: '${course.code}-3',
        title: 'Assignment 3 : ${course.title}',
        description: 'Deep dive into real-world scenarios.',
        dueDate: now.add(const Duration(days: 14)),
        dueTime: '11:59 PM',
        points: 15,
      ),
      CourseAssignment(
        id: '${course.code}-4',
        title: 'Assignment 4 : ${course.title}',
        description: 'Reflect on the key takeaways from the term.',
        dueDate: now.add(const Duration(days: 22)),
        dueTime: '8:00 PM',
        points: 8,
      ),
    ];
  }
}
