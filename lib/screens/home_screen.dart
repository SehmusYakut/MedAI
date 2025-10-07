import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/ocr_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OCRService _ocrService = OCRService();
  final AIServiceManager _aiManager = AIServiceManager();
  String _recognizedText = '';
  final Map<String, String> _aiResponses = {};
  bool _isProcessing = false;
  File? _selectedImage;

  Future<void> _processImage(bool fromCamera) async {
    try {
      setState(() => _isProcessing = true);
      final imageFile = await _ocrService.pickImage(fromCamera: fromCamera);

      if (imageFile != null) {
        setState(() => _selectedImage = imageFile);
        final text = await _ocrService.recognizeText(imageFile);
        setState(() => _recognizedText = text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _getAIResponses() async {
    if (_recognizedText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please scan some text first')),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final services = await _aiManager.getServices();
      for (final service in services) {
        try {
          final response = await service.generateResponse(_recognizedText);
          if (mounted) {
            setState(() {
              _aiResponses[service.name] = response;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _aiResponses[service.name] = 'Error: $e';
            });
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showAPIKeyDialog() async {
    final TextEditingController chatGPTController = TextEditingController();
    final TextEditingController mistralController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set API Keys'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chatGPTController,
              decoration: const InputDecoration(
                labelText: 'ChatGPT API Key',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: mistralController,
              decoration: const InputDecoration(
                labelText: 'Mistral API Key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (chatGPTController.text.isNotEmpty) {
                await _aiManager.setAPIKey('chatgpt', chatGPTController.text);
              }
              if (mistralController.text.isNotEmpty) {
                await _aiManager.setAPIKey('mistral', mistralController.text);
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API keys saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Question Solver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showAPIKeyDialog,
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_selectedImage != null) ...[
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Recognized Text:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(_recognizedText.isEmpty
                                ? 'No text recognized yet'
                                : _recognizedText),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed:
                              _recognizedText.isEmpty ? null : _getAIResponses,
                          icon: const Icon(Icons.psychology),
                          label: const Text('Get AI Responses'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_aiResponses.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final serviceName =
                              _aiResponses.keys.elementAt(index);
                          final response = _aiResponses[serviceName]!;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        serviceName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: response));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Response copied to clipboard'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        tooltip: 'Copy to clipboard',
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: MarkdownBody(
                                    data: response,
                                    selectable: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: _aiResponses.length,
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _processImage(true),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => _processImage(false),
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
