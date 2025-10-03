import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_key_service.dart';

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

class AIServiceManager {
  static final AIServiceManager _instance = AIServiceManager._internal();
  factory AIServiceManager() => _instance;
  AIServiceManager._internal();

  List<AIService>? _services;

  Future<List<AIService>> getServices() async {
    if (_services != null) return _services!;

    final apiKeyService = await ApiKeyService.getInstance();
    final chatGPTKey = apiKeyService.getChatGPTApiKey();
    final mistralKey = apiKeyService.getMistralApiKey();

    _services = [];

    if (chatGPTKey != null) {
      _services!.add(ChatGPTService(chatGPTKey));
    }

    if (mistralKey != null) {
      _services!.add(MistralService(mistralKey));
    }

    return _services!;
  }

  Future<void> setAPIKey(String serviceName, String apiKey) async {
    final apiKeyService = await ApiKeyService.getInstance();

    if (serviceName.toLowerCase() == 'chatgpt') {
      await apiKeyService.setChatGPTApiKey(apiKey);
    } else if (serviceName.toLowerCase() == 'mistral') {
      await apiKeyService.setMistralApiKey(apiKey);
    }

    _services = null; // Reset services to force reload
  }
}
