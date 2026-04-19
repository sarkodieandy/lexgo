abstract class ApiConfig {
  static const String _host = String.fromEnvironment(
    'API_HOST',
   
    defaultValue: 'https://api.lexg0.uk/api',
  );
  static const String _lecturerCasesPath = '/api/v1/LecturerCases';
  static const String _lecturerQuizPath = '/api/v1/LecturerQuiz';
  static const String _studentQuizPath = '/api/StudentQuiz';
  static const String _coursesPath = '/api/Courses';
  static const String _subLecturerPath = '/api/SubLecturer';
  static const String _notesPath = '/api/Notes';
  static const String _enrollmentsPath = '/api/Enrollments';
  static const String _aiPath = '/api/AI';
  static const String _aiQuizPath = '/api/Ai';
  static const String _adminPath = '/api/Admin';
  static const String _adminCasesPath = '/api/Cases';

  static String get host {
    var value = _host.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.toLowerCase().endsWith('/api')) {
      value = value.substring(0, value.length - 4);
    }
    return value;
  }

  /// Base URL for all lecturer case endpoints.
  static String get casesBaseUrl => '$host$_lecturerCasesPath';

  /// Base URL for all lecturer quiz endpoints.
  static String get quizBaseUrl => '$host$_lecturerQuizPath';

  /// Base URL for all student quiz endpoints.
  static String get studentQuizBaseUrl => '$host$_studentQuizPath';

  /// Base URL for course endpoints.
  static String get coursesBaseUrl => '$host$_coursesPath';

  /// Base URL for all sub-lecturer endpoints.
  static String get subLecturerBaseUrl => '$host$_subLecturerPath';

  /// Base URL for all notes endpoints.
  static String get notesBaseUrl => '$host$_notesPath';

  /// Base URL for all course enrollment endpoints.
  static String get enrollmentsBaseUrl => '$host$_enrollmentsPath';

  /// Base URL for AI ask endpoints.
  static String get aiBaseUrl => '$host$_aiPath';

  /// Base URL for AI quiz endpoints.
  static String get aiQuizBaseUrl => '$host$_aiQuizPath';

  /// Base URL for admin endpoints.
  static String get adminBaseUrl => '$host$_adminPath';

  /// Base URL for admin global case endpoints.
  static String get adminCasesBaseUrl => '$host$_adminCasesPath';

  /// Default bearer token. Provide a real token via `CasesService` or by
  /// editing this constant.
  static const String defaultAuthToken = String.fromEnvironment(
    'API_TOKEN',
    defaultValue: '',
  );

  static Uri resolve(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$host$normalized');
  }
}
