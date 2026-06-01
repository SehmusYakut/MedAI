import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CentralConfig {
  static String get chatGPTKey {
    final key = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['CHATGPT_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] OPENAI_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get mistralKey {
    final key = dotenv.env['MISTRAL_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] MISTRAL_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get geminiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] GEMINI_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get claudeKey {
    final key = dotenv.env['CLAUDE_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] CLAUDE_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get groqKey {
    final key = dotenv.env['GROQ_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] GROQ_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get huggingFaceKey {
    final key = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] HUGGINGFACE_API_KEY is missing in environment config.');
    }
    return key;
  }

  static String get openRouterKey {
    final key = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (key.isEmpty) {
      debugPrint('[Developer Warning] OPENROUTER_API_KEY is missing in environment config.');
    }
    return key;
  }

  static bool get hasAnyConfiguredKey =>
      chatGPTKey.isNotEmpty ||
      mistralKey.isNotEmpty ||
      geminiKey.isNotEmpty ||
      claudeKey.isNotEmpty ||
      groqKey.isNotEmpty ||
      huggingFaceKey.isNotEmpty ||
      openRouterKey.isNotEmpty;
}
