import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class LLMService {
  Future<String> generateResponse({
    required String provider,
    required String model,
    required String apiKey,
    required String prompt,
    List<Map<String, String>> history = const [],
  }) async {
    try {
      switch (provider) {
        case 'Groq':
          return _callOpenAICompatible(
            baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
            apiKey: apiKey,
            model: model,
            prompt: prompt,
            history: history,
          );
        case 'DeepSeek':
          return _callOpenAICompatible(
            baseUrl: 'https://api.deepseek.com/chat/completions',
            apiKey: apiKey,
            model: model,
            prompt: prompt,
            history: history,
          );
        case 'OpenAI':
          return _callOpenAICompatible(
            baseUrl: 'https://api.openai.com/v1/chat/completions',
            apiKey: apiKey,
            model: model,
            prompt: prompt,
            history: history,
          );
        case 'Ollama':
          return _callOllama(model: model, prompt: prompt, history: history);
        default:
          throw Exception('Provider $provider not supported');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> _callOpenAICompatible({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String prompt,
    required List<Map<String, String>> history,
  }) async {
    final messages = [
      {'role': 'system', 'content': AppConstants.systemPrompt},
      ...history,
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({'model': model, 'messages': messages}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception('Failed to fetch response: ${response.body}');
    }
  }

  Future<String> _callOllama({
    required String model,
    required String prompt,
    required List<Map<String, String>> history,
  }) async {
    final messages = [
      {'role': 'system', 'content': AppConstants.systemPrompt},
      ...history,
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(
      Uri.parse('http://localhost:11434/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'model': model, 'messages': messages, 'stream': false}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message']['content'] ?? '';
    } else {
      throw Exception('Failed to connect to Ollama: ${response.body}');
    }
  }
}
