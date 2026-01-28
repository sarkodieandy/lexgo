abstract class ApiConfig {
  /// Replace the host below with the real API hostname before building.
  static const String _host = 'https://example.com';
  static const String _lecturerCasesPath = '/api/LecturerCases';
  static const String _coursesPath = '/api/Courses';

  /// Base URL for all lecturer case endpoints.
  static final String casesBaseUrl = '$_host$_lecturerCasesPath';

  /// Base URL for course endpoints.
  static final String coursesBaseUrl = '$_host$_coursesPath';

  /// Default bearer token. Provide a real token via `CasesService` or by
  /// editing this constant.
  static const String defaultAuthToken = '<REPLACE_WITH_TOKEN>';
}
