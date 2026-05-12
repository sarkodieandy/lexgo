import 'dart:convert';
import 'package:lexgo/services/api_client.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/topic_model.dart';
import '../config/app_config.dart';
import 'package:lexgo/services/auth_api_service.dart';

class CourseTopicsApiService {
  static String get _defaultBaseUrl => '$kApiBase/api/Courses';

  String get baseUrl => _defaultBaseUrl;
  static const String _apiKeyKey = 'api_key'; // Space for optional API key

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    final accessToken = AuthApiService.memoryAccessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final prefs = await SharedPreferences.getInstance();

    final apiKey = prefs.getString(_apiKeyKey);
    // Alternatively, this might come from an environment variable:
    // final apiKey = const String.fromEnvironment('API_KEY');
    if (apiKey != null) {
      headers['x-api-key'] = apiKey;
    }

    return headers;
  }

  /// Get Topics for a Course
  Future<List<Topic>> getCourseTopics(String courseId) async {
    final uri = Uri.parse('$baseUrl/$courseId/topics');

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Topic.fromJson(json)).toList();
      }
    } catch (_) {
      // Return mock data for development when backend is unavailable
    }

    // Mock Data Fallback
    // Return different mock data depending on courseId

    // Constitutional Law
    if (courseId == 'mock3') {
      return [
        Topic(
          id: 'const_topic_1',
          title: 'Constitutional Law Questions',
          pagesInfo: null, // No pages info in mockup
          subtopics: [
            Subtopic(id: 'c_sub_1', title: 'What is a Constitution?'),
            Subtopic(
              id: 'c_sub_2',
              title: 'What is the principle of Separation of Powers?',
            ),
            Subtopic(id: 'c_sub_3', title: 'What is Judicial Review?'),
            Subtopic(id: 'c_sub_4', title: 'What is the Rule of Law?'),
            Subtopic(id: 'c_sub_5', title: 'What is Constitutional Supremacy?'),
            Subtopic(id: 'c_sub_6', title: 'What is a Fundamental Right?'),
            Subtopic(id: 'c_sub_7', title: 'What is Federalism?'),
          ],
        ),
      ];
    }

    // Default Fallback (Criminal Law, etc)
    return [
      Topic(
        id: 'topic_1',
        title: 'General Principles of Criminal Liability',
        pagesInfo: '15 pages',
        subtopics: _getMockSubtopics(1),
      ),
      Topic(
        id: 'topic_2',
        title: 'Actus Reus & Mens Rea',
        pagesInfo: '25 pages',
        subtopics: _getMockSubtopics(2),
      ),
      Topic(
        id: 'topic_3',
        title: 'Homicide (Murder & Manslaughter)',
        pagesInfo: '25 pages',
        subtopics: _getMockSubtopics(3),
      ),
      Topic(
        id: 'topic_4',
        title: 'Defenses (Insanity, Self-defense, Duress)',
        pagesInfo: '25 pages',
        subtopics: _getMockSubtopics(4),
      ),
    ];
  }

  List<Subtopic> _getMockSubtopics(int topicIndex) {
    if (topicIndex == 1) {
      return [
        Subtopic(id: 'c_sub_mock_1', title: 'Sample Question 1?'),
        Subtopic(id: 'c_sub_mock_2', title: 'Sample Question 2?'),
        Subtopic(id: 'c_sub_mock_3', title: 'Sample Question 3?'),
      ];
    } else {
      // Just return a standard set of mock questions for other topics for now
      return [
        Subtopic(id: 'sub_mock_1', title: 'Sample Question 1?'),
        Subtopic(id: 'sub_mock_2', title: 'Sample Question 2?'),
        Subtopic(id: 'sub_mock_3', title: 'Sample Question 3?'),
      ];
    }
  }
}
