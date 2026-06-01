import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ai_response.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';

enum ProcessingStatus { idle, processing, error }

class MedicalSnippet {
  final String type; // 'contraindication', 'warning', 'note'
  final String content;
  final String? source; // Which AI service provided this

  MedicalSnippet({
    required this.type,
    required this.content,
    this.source,
  });
}

class HomeViewModel extends ChangeNotifier {
  final OCRService _ocrService;
  final AIServiceManager _aiManager;

  HomeViewModel({OCRService? ocrService, AIServiceManager? aiManager})
      : _ocrService = ocrService ?? OCRService(),
        _aiManager = aiManager ?? AIServiceManager();

  String _recognizedText = '';
  File? _selectedImage;
  List<AIResponse> _aiResponses = [];
  ProcessingStatus _status = ProcessingStatus.idle;
  String? _errorMessage;
  final List<MedicalSnippet> _quickReviewSnippets = [];
  String? _generatedMnemonic;

  // Getters
  String get recognizedText => _recognizedText;
  File? get selectedImage => _selectedImage;
  List<AIResponse> get aiResponses => _aiResponses;
  ProcessingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasRecognizedText => _recognizedText.isNotEmpty;
  bool get isProcessing => _status == ProcessingStatus.processing;
  List<MedicalSnippet> get quickReviewSnippets => _quickReviewSnippets;
  String? get generatedMnemonic => _generatedMnemonic;

  Future<void> processImage(bool fromCamera) async {
    try {
      _setStatus(ProcessingStatus.processing);
      final imageFile = await _ocrService.pickImage(fromCamera: fromCamera);

      if (imageFile != null) {
        _selectedImage = imageFile;
        final text = await _ocrService.recognizeText(imageFile);
        _recognizedText = text;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error processing image: $e';
      _setStatus(ProcessingStatus.error);
    } finally {
      if (_status != ProcessingStatus.error) {
        _setStatus(ProcessingStatus.idle);
      }
    }
  }

  Future<void> getAIResponses() async {
    if (_recognizedText.isEmpty) {
      _errorMessage = 'Please scan some text first';
      notifyListeners();
      return;
    }

    try {
      _setStatus(ProcessingStatus.processing);
      final services = await _aiManager.getServices();

      if (services.isEmpty) {
        _errorMessage = 'Please configure AI service API keys first';
        _setStatus(ProcessingStatus.error);
        return;
      }

      _aiResponses = [];
      notifyListeners();

      for (final service in services) {
        try {
          final response = await service.generateResponse(_recognizedText);
          _aiResponses.add(
            AIResponse(serviceName: service.name, response: response),
          );
        } catch (e) {
          _aiResponses.add(AIResponse.error(service.name, e.toString()));
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(ProcessingStatus.error);
    } finally {
      _setStatus(ProcessingStatus.idle);
    }
  }

  Future<void> setAPIKey(String serviceName, String apiKey) async {
    await _aiManager.setAPIKey(serviceName, apiKey);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == ProcessingStatus.error) {
      _status = ProcessingStatus.idle;
    }
    notifyListeners();
  }

  void _setStatus(ProcessingStatus status) {
    _status = status;
    notifyListeners();
  }

  /// Extracts quick-review snippets (contraindications, warnings) from AI responses
  void extractMedicalSnippets() {
    _quickReviewSnippets.clear();

    for (final response in _aiResponses) {
      if (response.isError) continue;

      // Extract contraindications (marked with ** or - Contraindication:)
      final contraPattern = RegExp(
        r'\*\*[^*]*(?:contraindication|warning|caution)[^*]*\*\*|^[-•]\s*(?:Contraindication|Warning|Caution)[:\s].*',
        multiLine: true,
        caseSensitive: false,
      );

      final matches = contraPattern.allMatches(response.response);
      for (final match in matches) {
        final text = match.group(0)?.replaceAll(RegExp(r'\*\*'), '') ?? '';
        if (text.isNotEmpty) {
          _quickReviewSnippets.add(
            MedicalSnippet(
              type: 'contraindication',
              content: text.trim(),
              source: response.serviceName,
            ),
          );
        }
      }

      // Extract key points (marked with ###)
      final keyPointsPattern = RegExp(
        r'^###\s+(.+)$',
        multiLine: true,
      );

      final keyMatches = keyPointsPattern.allMatches(response.response);
      for (final match in keyMatches) {
        final text = match.group(1)?.trim() ?? '';
        if (text.isNotEmpty) {
          _quickReviewSnippets.add(
            MedicalSnippet(
              type: 'note',
              content: text,
              source: response.serviceName,
            ),
          );
        }
      }
    }

    notifyListeners();
  }

  /// Generates a medical mnemonic from the AI responses using pattern extraction
  Future<void> generateMnemonic() async {
    if (_aiResponses.isEmpty) {
      _errorMessage = 'No AI responses available for mnemonic generation';
      notifyListeners();
      return;
    }

    try {
      _setStatus(ProcessingStatus.processing);

      // Combine all non-error responses
      final combinedText = _aiResponses
          .where((r) => !r.isError)
          .map((r) => r.response)
          .join('\n\n');

      if (combinedText.isEmpty) {
        _errorMessage = 'No valid AI responses to generate mnemonic';
        _setStatus(ProcessingStatus.error);
        notifyListeners();
        return;
      }

      // Extract key terms (capitalized medical terms and important concepts)
      final keyTerms = <String>[];
      final lines = combinedText.split('\n');

      for (final line in lines) {
        // Extract capitalized words and medical terms
        final wordPattern = RegExp(r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)\b');
        final matches = wordPattern.allMatches(line);

        for (final match in matches) {
          final term = match.group(0)?.trim() ?? '';
          if (term.length > 2 && !_commonWords.contains(term.toLowerCase())) {
            keyTerms.add(term);
            if (keyTerms.length >= 6) break; // Limit to 6 terms for mnemonic
          }
        }
        if (keyTerms.length >= 6) break;
      }

      // Generate acronym
      if (keyTerms.isEmpty) {
        _generatedMnemonic = 'MEDAI'; // Fallback
      } else {
        final acronym = keyTerms.map((t) => t[0]).join('').toUpperCase();
        _generatedMnemonic = acronym.length > 1 ? acronym : 'MEDAI';
      }

      _errorMessage = null;
      _setStatus(ProcessingStatus.idle);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error generating mnemonic: $e';
      _setStatus(ProcessingStatus.error);
    }
  }

  /// Common words to exclude from mnemonic generation
  static const _commonWords = {
    'the',
    'and',
    'or',
    'a',
    'an',
    'is',
    'are',
    'be',
    'was',
    'were',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'will',
    'would',
    'should',
    'could',
    'can',
    'may',
    'might',
    'must',
    'this',
    'that',
    'these',
    'those',
    'i',
    'you',
    'he',
    'she',
    'it',
    'we',
    'they',
    'what',
    'which',
    'who',
  };

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
