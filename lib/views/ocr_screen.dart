import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../viewmodels/ocr_view_model.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  File? _image;
  String _recognizedText = '';
  bool _isProcessing = false;
  final AIServiceManager _aiManager = AIServiceManager();
  final OCRService _ocrService = OCRService();
  Map<String, String> _aiResponses = {};
  bool _isAiProcessing = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() => _isProcessing = true);

    try {
      debugPrint(
          'Attempting to pick image from ${source == ImageSource.camera ? "camera" : "gallery"}');

      final imageFile =
          await _ocrService.pickImage(fromCamera: source == ImageSource.camera);

      if (imageFile != null && mounted) {
        debugPrint('Image picked successfully: ${imageFile.path}');

        final ocrViewModel = context.read<OCRViewModel>();

        setState(() {
          _image = imageFile;
          _recognizedText = '';
          _aiResponses = {};
        });

        final recognizedText = await ocrViewModel.processImage(_image!);

        if (!mounted) return;
        setState(() {
          _recognizedText = recognizedText;
        });
      } else {
        debugPrint('No image was selected');
      }
    } catch (e) {
      debugPrint('Error in _getImage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _askAI() async {
    if (_recognizedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan some text first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAiProcessing = true);
    _aiResponses = {};

    try {
      final services = await _aiManager.getServices();

      if (services.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No AI services configured. Please set up API keys in the settings.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      for (final service in services) {
        try {
          final prompt = '''
Please analyze this medical question and provide a detailed answer:

$_recognizedText

Provide a comprehensive answer with explanations and key points.
''';

          final response = await service.generateResponse(prompt);
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
        setState(() => _isAiProcessing = false);
      }
    }
  }

  void _editRecognizedText() {
    showDialog(
      context: context,
      builder: (context) => _EditTextDialog(
        initialText: _recognizedText,
        onSave: (editedText) {
          setState(() {
            _recognizedText = editedText;
            _aiResponses = {};
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ocrViewModel = context.watch<OCRViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medical Questions'),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editRecognizedText,
              tooltip: 'Edit Recognized Text',
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_image == null)
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withAlpha(128),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.document_scanner,
                                  size: 64,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No image selected',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Take a photo or select from gallery',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (_recognizedText.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.text_snippet,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Recognized Text',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SelectableText(_recognizedText),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _isAiProcessing ? null : _askAI,
                          icon: _isAiProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.psychology),
                          label: Text(
                              _isAiProcessing ? 'Processing...' : 'Ask AI'),
                        ),
                      ],
                      if (_aiResponses.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'AI Responses',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ..._aiResponses.entries.map((entry) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: entry.value));
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
                                    data: entry.value,
                                    selectable: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isProcessing || ocrViewModel.isProcessing)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'camera',
            onPressed:
                _isProcessing ? null : () => _getImage(ImageSource.camera),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed:
                _isProcessing ? null : () => _getImage(ImageSource.gallery),
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}

class _EditTextDialog extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;

  const _EditTextDialog({
    required this.initialText,
    required this.onSave,
  });

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Recognized Text'),
      content: TextField(
        controller: _controller,
        maxLines: 10,
        decoration: const InputDecoration(
          hintText: 'Edit the recognized text here',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
