import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AiApiService {
  final List<Map<String, String>> _sessionHistory = [];

  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqWhisperUrl = 'https://api.groq.com/openai/v1/audio/transcriptions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Asks the AI a question using the Groq API (LLaMA-3 model) and streams the response.
  Stream<String> askAiStream(String question) async* {
    if (question.trim().isEmpty) {
      throw Exception('Please enter a question.');
    }

    final apiKey = kGroqApiKey;
    if (apiKey.isEmpty) {
      yield* _fallbackStream(question);
      return;
    }

    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'You are LexGo AI, a helpful and knowledgeable legal assistant built into the LexGo app. Provide concise, accurate legal information in simple language. Remind users to consult a licensed attorney for specific legal advice.',
        },
        ..._sessionHistory,
        {'role': 'user', 'content': question},
      ];

      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer =
            data['choices'][0]['message']['content'] as String? ?? '';

        _sessionHistory.add({'role': 'user', 'content': question});
        _sessionHistory.add({'role': 'assistant', 'content': answer});

        // Keep only the last 10 messages to avoid token limits
        if (_sessionHistory.length > 10) {
          _sessionHistory.removeRange(0, _sessionHistory.length - 10);
        }

        // Stream word-by-word for the typing effect
        final words = answer.split(RegExp(r'(?<=\s)|(?=\s)'));
        for (final word in words) {
          yield word;
          await Future.delayed(const Duration(milliseconds: 12));
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Invalid API key. Please check your Groq API key configuration.',
        );
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit reached. Please wait a moment and try again.');
      } else {
        throw Exception('AI service error (${response.statusCode}). Please try again.');
      }
    } catch (e) {
      throw Exception(
        'AI error: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  /// Transcribes audio file using Groq Whisper API.
  Future<String> transcribeAudio(String filePath) async {
    final apiKey = kGroqApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Groq API key not configured.');
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_groqWhisperUrl))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['model'] = kGroqWhisperModel
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text'] ?? '';
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']?['message'] ?? 'Transcription failed (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Audio transcription error: $e');
    }
  }

  /// Fallback stream when no API key is configured
  Stream<String> _fallbackStream(String question) async* {
    _sessionHistory.add({'role': 'user', 'content': question});
    const msg =
        'The LexGo AI requires a Groq API key to function. Please add a free key from console.groq.com to enable AI responses. Contact your administrator to configure the GROQ_API_KEY.';
    _sessionHistory.add({'role': 'assistant', 'content': msg});

    final words = msg.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield words[i] + (i < words.length - 1 ? ' ' : '');
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  /// Retrieves the user's past AI interactions for this session.
  Future<Map<String, dynamic>> getHistory({
    int limit = 25,
    String? cursor,
  }) async {
    final history = <Map<String, dynamic>>[];
    for (int i = 0; i < _sessionHistory.length - 1; i += 2) {
      if (i + 1 < _sessionHistory.length) {
        history.add({
          'question': _sessionHistory[i]['content'] ?? '',
          'answer': _sessionHistory[i + 1]['content'] ?? '',
        });
      }
    }

    return {
      'success': history.isNotEmpty,
      'aiHistory': history.reversed.toList(),
      'nextCursor': null,
      'hasMore': false,
    };
  }
}
