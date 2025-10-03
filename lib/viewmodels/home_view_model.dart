import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ai_response.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';

enum ProcessingStatus { idle, processing, error }

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

  // Getters
  String get recognizedText => _recognizedText;
  File? get selectedImage => _selectedImage;
  List<AIResponse> get aiResponses => _aiResponses;
  ProcessingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get hasRecognizedText => _recognizedText.isNotEmpty;
  bool get isProcessing => _status == ProcessingStatus.processing;

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

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
