class CentralConfig {
  static const String chatGPTKey = String.fromEnvironment('CHATGPT_API_KEY');
  static const String mistralKey = String.fromEnvironment('MISTRAL_API_KEY');
  static const String geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String claudeKey = String.fromEnvironment('CLAUDE_API_KEY');
  static const String groqKey = String.fromEnvironment('GROQ_API_KEY');
  static const String huggingFaceKey = String.fromEnvironment('HUGGINGFACE_API_KEY');
  static const String openRouterKey = String.fromEnvironment('OPENROUTER_API_KEY');

  static bool get hasAnyConfiguredKey =>
      chatGPTKey.isNotEmpty ||
      mistralKey.isNotEmpty ||
      geminiKey.isNotEmpty ||
      claudeKey.isNotEmpty ||
      groqKey.isNotEmpty ||
      huggingFaceKey.isNotEmpty ||
      openRouterKey.isNotEmpty;
}
