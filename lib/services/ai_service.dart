import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'central_config.dart';

abstract class AIService {
  Future<String> generateResponse(String prompt);
  String get name;
}

class ChatGPTService implements AIService {
  final String apiKey;

  ChatGPTService(this.apiKey);

  @override
  String get name => 'ChatGPT';

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(
          'Failed to get response from ChatGPT: ${response.statusCode}');
    }
  }
}

class MistralService implements AIService {
  final String apiKey;

  MistralService(this.apiKey);

  @override
  String get name => 'Mistral';

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.mistral.ai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'mistral-tiny',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(
          'Failed to get response from Mistral: ${response.statusCode}');
    }
  }
}

class GeminiService implements AIService {
  final String apiKey;

  GeminiService(this.apiKey);

  @override
  String get name => 'Gemini';

  @override
  Future<String> generateResponse(String prompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-pro',
        apiKey: apiKey,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        throw Exception('No response from Gemini');
      }
    } catch (e) {
      throw Exception('Failed to get response from Gemini: $e');
    }
  }
}

class ClaudeService implements AIService {
  final String apiKey;

  ClaudeService(this.apiKey);

  @override
  String get name => 'Claude';

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1024,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['content'] is List && data['content'].isNotEmpty) {
        return data['content'][0]['text'] ?? 'No response from Claude';
      }
      throw Exception('Invalid response format from Claude');
    } else {
      throw Exception(
          'Failed to get response from Claude: ${response.statusCode} - ${response.body}');
    }
  }
}

class GroqService implements AIService {
  final String apiKey;

  GroqService(this.apiKey);

  @override
  String get name => 'Groq';

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'mixtral-8x7b-32768',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ??
          'No response from Groq';
    } else {
      throw Exception(
          'Failed to get response from Groq: ${response.statusCode}');
    }
  }
}

class HuggingFaceService implements AIService {
  final String apiKey;

  HuggingFaceService(this.apiKey);

  @override
  String get name => 'HuggingFace';

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(
          'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1'),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'inputs': prompt,
        'parameters': {
          'max_length': 512,
          'temperature': 0.7,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data[0]['generated_text'] ?? 'No response from HuggingFace';
      }
      return 'No response from HuggingFace';
    } else {
      throw Exception(
          'Failed to get response from HuggingFace: ${response.statusCode}');
    }
  }
}

class OpenRouterService implements AIService {
  final String apiKey;

  OpenRouterService(this.apiKey);

  @override
  String get name => 'OpenRouter';

  @override
  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://github.com/yourusername/medai',
        'X-Title': 'MedAI',
      },
      body: jsonEncode({
        'model': 'meta-llama/llama-2-70b-chat',
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ??
          'No response from OpenRouter';
    } else {
      throw Exception(
          'Failed to get response from OpenRouter: ${response.statusCode}');
    }
  }
}

class MockAIService implements AIService {
  @override
  String get name => 'MockAI (Demo)';

  @override
  Future<String> generateResponse(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));
    return '''
## Answer
This is a mock clinical insight response to demonstrate the app logic without an active API key.

## Explanation
To run this with real AI models, compile the app with:
`flutter run --dart-define=GEMINI_API_KEY=your_key`

## Key Points
- Free queries limit is active: 5 queries per day.
- Daily Access counter will decrement.
- Once it hits 0, the Premium Paywall will be triggered!
''';
  }
}

class AIServiceManager {
  static final AIServiceManager _instance = AIServiceManager._internal();
  factory AIServiceManager() => _instance;
  AIServiceManager._internal();

  List<AIService>? _services;

  Future<List<AIService>> getServices() async {
    if (_services != null) return _services!;

    _services = [];

    if (CentralConfig.chatGPTKey.isNotEmpty) {
      _services!.add(ChatGPTService(CentralConfig.chatGPTKey));
    }

    if (CentralConfig.mistralKey.isNotEmpty) {
      _services!.add(MistralService(CentralConfig.mistralKey));
    }

    if (CentralConfig.geminiKey.isNotEmpty) {
      _services!.add(GeminiService(CentralConfig.geminiKey));
    }

    if (CentralConfig.claudeKey.isNotEmpty) {
      _services!.add(ClaudeService(CentralConfig.claudeKey));
    }

    if (CentralConfig.groqKey.isNotEmpty) {
      _services!.add(GroqService(CentralConfig.groqKey));
    }

    if (CentralConfig.huggingFaceKey.isNotEmpty) {
      _services!.add(HuggingFaceService(CentralConfig.huggingFaceKey));
    }

    if (CentralConfig.openRouterKey.isNotEmpty) {
      _services!.add(OpenRouterService(CentralConfig.openRouterKey));
    }

    // Fallback: If no keys are provided, we add a mock service so the application is immediately testable.
    if (_services!.isEmpty) {
      _services!.add(MockAIService());
    }

    return _services!;
  }

  Future<void> setAPIKey(String serviceName, String apiKey) async {
    // Deprecated: API keys are now securely managed from central environment config.
    // Kept as no-op for backward compatibility.
  }
}
