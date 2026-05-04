import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _apiKeyKey = 'api_key';
  static const String _lastUpdatedKey = 'api_key_last_updated';
  static const String _chatGPTKeyKey = 'chatgpt_api_key';
  static const String _mistralKeyKey = 'mistral_api_key';
  static const String _geminiKeyKey = 'gemini_api_key';
  static const String _claudeKeyKey = 'claude_api_key';
  static const String _groqKeyKey = 'groq_api_key';
  static const String _huggingFaceKeyKey = 'huggingface_api_key';
  static const String _openRouterKeyKey = 'openrouter_api_key';

  final SharedPreferences _prefs;

  ApiKeyService._(this._prefs);

  static Future<ApiKeyService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return ApiKeyService._(prefs);
  }

  String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyKey, apiKey);
    await _prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  DateTime? getLastUpdated() {
    final dateStr = _prefs.getString(_lastUpdatedKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  Future<void> clearApiKey() async {
    await _prefs.remove(_apiKeyKey);
    await _prefs.remove(_lastUpdatedKey);
  }

  // ChatGPT API Key methods
  String? getChatGPTApiKey() {
    return _prefs.getString(_chatGPTKeyKey);
  }

  Future<void> setChatGPTApiKey(String apiKey) async {
    await _prefs.setString(_chatGPTKeyKey, apiKey);
  }

  // Mistral API Key methods
  String? getMistralApiKey() {
    return _prefs.getString(_mistralKeyKey);
  }

  Future<void> setMistralApiKey(String apiKey) async {
    await _prefs.setString(_mistralKeyKey, apiKey);
  }

  // Gemini API Key methods
  String? getGeminiApiKey() {
    return _prefs.getString(_geminiKeyKey);
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    await _prefs.setString(_geminiKeyKey, apiKey);
  }

  // Claude API Key methods
  String? getClaudeApiKey() {
    return _prefs.getString(_claudeKeyKey);
  }

  Future<void> setClaudeApiKey(String apiKey) async {
    await _prefs.setString(_claudeKeyKey, apiKey);
  }

  // Groq API Key methods
  String? getGroqApiKey() {
    return _prefs.getString(_groqKeyKey);
  }

  Future<void> setGroqApiKey(String apiKey) async {
    await _prefs.setString(_groqKeyKey, apiKey);
  }

  // HuggingFace API Key methods
  String? getHuggingFaceApiKey() {
    return _prefs.getString(_huggingFaceKeyKey);
  }

  Future<void> setHuggingFaceApiKey(String apiKey) async {
    await _prefs.setString(_huggingFaceKeyKey, apiKey);
  }

  // OpenRouter API Key methods
  String? getOpenRouterApiKey() {
    return _prefs.getString(_openRouterKeyKey);
  }

  Future<void> setOpenRouterApiKey(String apiKey) async {
    await _prefs.setString(_openRouterKeyKey, apiKey);
  }

  // Clear all API keys
  Future<void> clearAllApiKeys() async {
    await clearApiKey();
    await _prefs.remove(_chatGPTKeyKey);
    await _prefs.remove(_mistralKeyKey);
    await _prefs.remove(_geminiKeyKey);
    await _prefs.remove(_claudeKeyKey);
    await _prefs.remove(_groqKeyKey);
    await _prefs.remove(_huggingFaceKeyKey);
    await _prefs.remove(_openRouterKeyKey);
  }
}
