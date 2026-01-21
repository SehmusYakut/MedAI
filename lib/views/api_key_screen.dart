import 'package:flutter/material.dart';
import '../services/api_key_service.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _chatGPTKeyController = TextEditingController();
  final _mistralKeyController = TextEditingController();
  final _geminiKeyController = TextEditingController();
  late ApiKeyService _apiKeyService;
  String? _currentApiKey;
  String? _currentChatGPTKey;
  String? _currentMistralKey;
  String? _currentGeminiKey;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    _apiKeyService = await ApiKeyService.getInstance();
    setState(() {
      _currentApiKey = _apiKeyService.getApiKey();
      _currentChatGPTKey = _apiKeyService.getChatGPTApiKey();
      _currentMistralKey = _apiKeyService.getMistralApiKey();
      _currentGeminiKey = _apiKeyService.getGeminiApiKey();
      _lastUpdated = _apiKeyService.getLastUpdated();
    });
  }

  Future<void> _saveApiKey() async {
    if (_formKey.currentState!.validate()) {
      await _apiKeyService.setApiKey(_apiKeyController.text);
      await _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key saved successfully')),
        );
      }
    }
  }

  Future<void> _saveChatGPTApiKey() async {
    if (_chatGPTKeyController.text.isNotEmpty) {
      await _apiKeyService.setChatGPTApiKey(_chatGPTKeyController.text);
      await _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ChatGPT API key saved successfully')),
        );
      }
    }
  }

  Future<void> _saveMistralApiKey() async {
    if (_mistralKeyController.text.isNotEmpty) {
      await _apiKeyService.setMistralApiKey(_mistralKeyController.text);
      await _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mistral API key saved successfully')),
        );
      }
    }
  }

  Future<void> _saveGeminiApiKey() async {
    if (_geminiKeyController.text.isNotEmpty) {
      await _apiKeyService.setGeminiApiKey(_geminiKeyController.text);
      await _loadApiKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gemini API key saved successfully')),
        );
      }
    }
  }

  Future<void> _clearApiKey() async {
    await _apiKeyService.clearApiKey();
    await _loadApiKeys();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key cleared')),
      );
    }
  }

  Future<void> _clearAllApiKeys() async {
    await _apiKeyService.clearAllApiKeys();
    await _loadApiKeys();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All API keys cleared')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Key Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // General API Key Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General API Key',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_currentApiKey != null) ...[
                      Text(
                        _currentApiKey!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_lastUpdated != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${_lastUpdated!.toLocal()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _clearApiKey,
                        child: const Text('Clear API Key'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _apiKeyController,
                            decoration: const InputDecoration(
                              labelText: 'New API Key',
                              hintText: 'Enter your API key',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an API key';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _saveApiKey,
                            child: const Text('Save API Key'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI Services Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Services',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // ChatGPT API Key
                    Text(
                      'ChatGPT API Key',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_currentChatGPTKey != null) ...[
                      Text(
                        _currentChatGPTKey!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _chatGPTKeyController,
                      decoration: const InputDecoration(
                        labelText: 'ChatGPT API Key',
                        hintText: 'Enter your ChatGPT API key',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _saveChatGPTApiKey,
                      child: const Text('Save ChatGPT API Key'),
                    ),
                    const SizedBox(height: 16),

                    // Mistral API Key
                    Text(
                      'Mistral API Key',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_currentMistralKey != null) ...[
                      Text(
                        _currentMistralKey!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _mistralKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Mistral API Key',
                        hintText: 'Enter your Mistral API key',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _saveMistralApiKey,
                      child: const Text('Save Mistral API Key'),
                    ),
                    const SizedBox(height: 16),

                    // Gemini API Key
                    Text(
                      'Gemini API Key',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_currentGeminiKey != null) ...[
                      Text(
                        _currentGeminiKey!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _geminiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'Enter your Gemini API key',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _saveGeminiApiKey,
                      child: const Text('Save Gemini API Key'),
                    ),
                    const SizedBox(height: 16),

                    // Clear All Button
                    OutlinedButton(
                      onPressed: _clearAllApiKeys,
                      child: const Text('Clear All API Keys'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _chatGPTKeyController.dispose();
    _mistralKeyController.dispose();
    _geminiKeyController.dispose();
    super.dispose();
  }
}
