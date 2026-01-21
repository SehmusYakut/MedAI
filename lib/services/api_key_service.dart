import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _apiKeyKey = 'api_key';
  static const String _lastUpdatedKey = 'api_key_last_updated';
  static const String _chatGPTKeyKey = 'chatgpt_api_key';
  static const String _mistralKeyKey = 'mistral_api_key';
  static const String _geminiKeyKey = 'gemini_api_key';

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

  // AI Service specific methods
  String? getChatGPTApiKey() {
    return _prefs.getString(_chatGPTKeyKey);
  }

  Future<void> setChatGPTApiKey(String apiKey) async {
    await _prefs.setString(_chatGPTKeyKey, apiKey);
  }

  String? getMistralApiKey() {
    return _prefs.getString(_mistralKeyKey);
  }

  Future<void> setMistralApiKey(String apiKey) async {
    await _prefs.setString(_mistralKeyKey, apiKey);
  }

  String? getGeminiApiKey() {
    return _prefs.getString(_geminiKeyKey);
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    await _prefs.setString(_geminiKeyKey, apiKey);
  }

  Future<void> clearAllApiKeys() async {
    await clearApiKey();
    await _prefs.remove(_chatGPTKeyKey);
    await _prefs.remove(_mistralKeyKey);
    await _prefs.remove(_geminiKeyKey);
  }
}
