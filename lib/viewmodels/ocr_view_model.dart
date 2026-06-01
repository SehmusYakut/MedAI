import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../services/ai_service.dart';
import '../services/ocr_service.dart';
import '../services/usage_limit_service.dart';

enum OcrSessionPhase { idle, picking, recognizing, askingAi, complete, error }

class OCRViewModel extends ChangeNotifier {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _uuid = const Uuid();
  late final OCRService _ocrService;
  late final AIServiceManager _aiManager;
  final List<Question> _questions = [];

  // Active OCR session state
  OcrSessionPhase _sessionPhase = OcrSessionPhase.idle;
  File? _sessionImage;
  String _sessionText = '';
  final Map<String, String> _sessionAiResponses = {};
  String? _sessionError;

  OCRViewModel({OCRService? ocrService, AIServiceManager? aiManager}) {
    _ocrService = ocrService ?? OCRService();
    _aiManager = aiManager ?? AIServiceManager();
  }

  // Existing question list getters
  List<Question> get questions => List.unmodifiable(_questions);
  bool get isProcessing => _sessionPhase == OcrSessionPhase.recognizing;

  // Session getters
  OcrSessionPhase get sessionPhase => _sessionPhase;
  File? get sessionImage => _sessionImage;
  String get sessionText => _sessionText;
  Map<String, String> get sessionAiResponses =>
      Map.unmodifiable(_sessionAiResponses);
  String? get sessionError => _sessionError;
  bool get hasSessionText => _sessionText.isNotEmpty;
  bool get hasAiResponses => _sessionAiResponses.isNotEmpty;

  static const List<String> medicalSubjects = [
    'Anatomy', 'Physiology', 'Biochemistry', 'Pathology', 'Pharmacology',
    'Microbiology', 'Internal Medicine', 'Surgery', 'Pediatrics',
    'Obstetrics', 'Gynecology', 'Psychiatry', 'Emergency Medicine',
    'Family Medicine',
  ];

  static const List<String> examTypes = [
    'USMLE Step 1', 'USMLE Step 2 CK', 'USMLE Step 3',
    'MCQ', 'OSCE', 'Clinical Vignette', 'Case Study',
  ];

  /// Picks an image and runs OCR in one atomic session step.
  Future<void> captureAndRecognize({required bool fromCamera}) async {
    _sessionPhase = OcrSessionPhase.picking;
    _sessionError = null;
    notifyListeners();

    try {
      final imageFile =
          await _ocrService.pickImage(fromCamera: fromCamera);
      if (imageFile == null) {
        _sessionPhase =
            _sessionImage != null ? OcrSessionPhase.complete : OcrSessionPhase.idle;
        notifyListeners();
        return;
      }
      _sessionImage = imageFile;
      _sessionText = '';
      _sessionAiResponses.clear();
      _sessionPhase = OcrSessionPhase.recognizing;
      notifyListeners();

      _sessionText = await _runOcr(imageFile);
      _sessionPhase = OcrSessionPhase.complete;
    } catch (e) {
      _sessionError = e.toString();
      _sessionPhase = OcrSessionPhase.error;
    }
    notifyListeners();
  }

  /// Sends the recognized text to all configured AI services.
  Future<void> analyzeWithAI(UsageLimitService limitService) async {
    if (_sessionText.isEmpty) return;

    await limitService.checkAndResetDailyLimit();
    if (limitService.getRemainingRights() <= 0) {
      _sessionError = 'premium_required';
      _sessionPhase = OcrSessionPhase.error;
      notifyListeners();
      return;
    }

    _sessionPhase = OcrSessionPhase.askingAi;
    _sessionAiResponses.clear();
    _sessionError = null;
    notifyListeners();

    try {
      final services = await _aiManager.getServices();
      if (services.isEmpty) {
        _sessionError = 'no_ai_services';
        _sessionPhase = OcrSessionPhase.error;
        notifyListeners();
        return;
      }
      for (final service in services) {
        try {
          final response = await service.generateResponse(_buildMedicalPrompt());
          _sessionAiResponses[service.name] = response;
          await limitService.decrementRight();
        } catch (e) {
          _sessionAiResponses[service.name] = '**Error:** ${e.toString()}';
        }
        notifyListeners();
      }
      _sessionPhase = OcrSessionPhase.complete;
    } catch (e) {
      _sessionError = e.toString();
      _sessionPhase = OcrSessionPhase.error;
    }
    notifyListeners();
  }

  void updateSessionText(String text) {
    _sessionText = text;
    _sessionAiResponses.clear();
    notifyListeners();
  }

  void resetSession() {
    _sessionPhase = OcrSessionPhase.idle;
    _sessionImage = null;
    _sessionText = '';
    _sessionAiResponses.clear();
    _sessionError = null;
    notifyListeners();
  }

  void clearSessionError() {
    _sessionPhase =
        _sessionImage != null ? OcrSessionPhase.complete : OcrSessionPhase.idle;
    _sessionError = null;
    notifyListeners();
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<String> _runOcr(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final result = await _textRecognizer.processImage(inputImage);
    final processed = processRecognizedText(result.text);
    final savedPath = await _saveImage(imageFile);
    _questions.add(Question(
      id: _uuid.v4(),
      text: processed,
      imagePath: savedPath,
      createdAt: DateTime.now(),
    ));
    return processed;
  }

  String _buildMedicalPrompt() => '''
Analyze this medical question and provide a structured, evidence-based answer:

$_sessionText

Use the following markdown structure:
## Answer
State the correct answer concisely.

## Explanation
Explain the underlying concept and reasoning.

## Key Points
- Must-know facts as bullet points

## ⚠️ Contraindications / Warnings
(Include only if clinically relevant)
''';

  // ── Public helpers kept for backward compatibility ────────────────────────

  void addQuestion(Question question) {
    _questions.add(question);
    notifyListeners();
  }

  /// Exposed for testing.
  String processRecognizedText(String text) {
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    const fixes = {
      'rnicro': 'micro', 'rnicrobiology': 'microbiology',
      'rnicroscopy': 'microscopy', 'rnicroorganism': 'microorganism',
      'rnicrobial': 'microbial', 'rnicrobe': 'microbe',
      'rnicrobiome': 'microbiome', 'rnicrobiota': 'microbiota',
      'rnicrobiologist': 'microbiologist', 'rnicroscopic': 'microscopic',
    };
    fixes.forEach((mistake, correction) {
      text = text.replaceAll(mistake, correction);
    });
    return text;
  }

  Future<String> _saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
    final saved = await imageFile.copy('${directory.path}/$fileName');
    return saved.path;
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  List<Question> getQuestionsBySubject(String subject) =>
      _questions.where((q) => q.subject == subject).toList();

  List<Question> getQuestionsByDifficulty(String difficulty) =>
      _questions.where((q) => q.difficulty == difficulty).toList();

  List<Question> getQuestionsByExamType(String examType) =>
      _questions.where((q) => q.examType == examType).toList();

  List<Question> getQuestionsByYear(int year) =>
      _questions.where((q) => q.year == year).toList();

  void addQuestionAttempt(String questionId, QuestionAttempt attempt) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index == -1) return;
    _questions[index] = _questions[index].copyWith(
      attempts: [..._questions[index].attempts, attempt],
    );
    notifyListeners();
  }

  Map<String, double> getPerformanceBySubject() {
    final data = <String, List<bool>>{};
    for (final q in _questions) {
      if (q.subject == null || q.attempts.isEmpty) continue;
      data.putIfAbsent(q.subject!, () => []).add(q.attempts.last.isCorrect);
    }
    return data.map((subject, results) => MapEntry(
        subject,
        results.isEmpty
            ? 0.0
            : results.where((r) => r).length / results.length));
  }

  Map<String, Duration> getAverageTimeBySubject() {
    final data = <String, List<Duration>>{};
    for (final q in _questions) {
      if (q.subject == null || q.attempts.isEmpty) continue;
      data.putIfAbsent(q.subject!, () => []).add(q.attempts.last.timeSpent);
    }
    return data.map((subject, durations) => MapEntry(
        subject,
        Duration(
            seconds: durations.isEmpty
                ? 0
                : (durations.map((d) => d.inSeconds).reduce((a, b) => a + b) /
                        durations.length)
                    .round())));
  }

  Map<String, int> getQuestionCountBySubject() {
    final counts = <String, int>{};
    for (final q in _questions) {
      if (q.subject != null) counts[q.subject!] = (counts[q.subject!] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _ocrService.dispose();
    super.dispose();
  }
}
