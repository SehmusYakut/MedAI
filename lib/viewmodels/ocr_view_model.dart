import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/question.dart';

class OCRViewModel extends ChangeNotifier {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _uuid = const Uuid();
  final List<Question> _questions = [];
  bool _isProcessing = false;

  // Medical subjects for categorization
  static const List<String> medicalSubjects = [
    'Anatomy',
    'Physiology',
    'Biochemistry',
    'Pathology',
    'Pharmacology',
    'Microbiology',
    'Internal Medicine',
    'Surgery',
    'Pediatrics',
    'Obstetrics',
    'Gynecology',
    'Psychiatry',
    'Emergency Medicine',
    'Family Medicine',
  ];

  // Exam types
  static const List<String> examTypes = [
    'USMLE Step 1',
    'USMLE Step 2 CK',
    'USMLE Step 3',
    'MCQ',
    'OSCE',
    'Clinical Vignette',
    'Case Study',
  ];

  List<Question> get questions => List.unmodifiable(_questions);
  bool get isProcessing => _isProcessing;

  // Method for testing
  void addQuestion(Question question) {
    _questions.add(question);
    notifyListeners();
  }

  Future<String> processImage(File imageFile) async {
    _isProcessing = true;
    notifyListeners();

    try {
      debugPrint('OCRViewModel: Processing image: ${imageFile.path}');

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      debugPrint('OCRViewModel: Recognized text: ${recognizedText.text}');

      // Save the image to app's local storage
      final savedImagePath = await _saveImage(imageFile);

      // Process and clean the recognized text
      final processedText = processRecognizedText(recognizedText.text);

      debugPrint('OCRViewModel: Processed text: $processedText');

      // Create a new question from the recognized text
      final question = Question(
        id: _uuid.v4(),
        text: processedText,
        imagePath: savedImagePath,
        createdAt: DateTime.now(),
      );

      _questions.add(question);
      notifyListeners();

      return processedText;
    } catch (e) {
      debugPrint('OCRViewModel Error: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Made public for testing
  String processRecognizedText(String text) {
    // Remove extra whitespace and normalize line breaks
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Fix common OCR mistakes in medical terms
    final commonMistakes = {
      'rnicro': 'micro',
      'rnicrobiology': 'microbiology',
      'rnicroscopy': 'microscopy',
      'rnicroorganism': 'microorganism',
      'rnicrobial': 'microbial',
      'rnicrobe': 'microbe',
      'rnicrobiome': 'microbiome',
      'rnicrobiota': 'microbiota',
      'rnicrobiologist': 'microbiologist',
      'rnicroscopic': 'microscopic',
    };

    commonMistakes.forEach((mistake, correction) {
      text = text.replaceAll(mistake, correction);
    });

    return text;
  }

  Future<String> _saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  void addQuestionAttempt(String questionId, QuestionAttempt attempt) {
    final questionIndex = _questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      final question = _questions[questionIndex];
      final updatedQuestion = question.copyWith(
        attempts: [...question.attempts, attempt],
      );
      _questions[questionIndex] = updatedQuestion;
      notifyListeners();
    }
  }

  List<Question> getQuestionsBySubject(String subject) {
    return _questions.where((q) => q.subject == subject).toList();
  }

  List<Question> getQuestionsByDifficulty(String difficulty) {
    return _questions.where((q) => q.difficulty == difficulty).toList();
  }

  List<Question> getQuestionsByExamType(String examType) {
    return _questions.where((q) => q.examType == examType).toList();
  }

  List<Question> getQuestionsByYear(int year) {
    return _questions.where((q) => q.year == year).toList();
  }

  Map<String, double> getPerformanceBySubject() {
    final performance = <String, List<bool>>{};

    for (final question in _questions) {
      if (question.subject != null) {
        performance.putIfAbsent(question.subject!, () => []);
        final attempts = question.attempts;
        if (attempts.isNotEmpty) {
          performance[question.subject!]!.add(attempts.last.isCorrect);
        }
      }
    }

    return performance.map((subject, attempts) {
      final successRate = attempts.isEmpty
          ? 0.0
          : attempts.where((correct) => correct).length / attempts.length;
      return MapEntry(subject, successRate);
    });
  }

  Map<String, Duration> getAverageTimeBySubject() {
    final times = <String, List<Duration>>{};

    for (final question in _questions) {
      if (question.subject != null) {
        times.putIfAbsent(question.subject!, () => []);
        final attempts = question.attempts;
        if (attempts.isNotEmpty) {
          times[question.subject!]!.add(attempts.last.timeSpent);
        }
      }
    }

    return times.map((subject, durations) {
      final averageSeconds = durations.isEmpty
          ? 0.0
          : durations.map((d) => d.inSeconds).reduce((a, b) => a + b) /
              durations.length;
      return MapEntry(subject, Duration(seconds: averageSeconds.round()));
    });
  }

  Map<String, int> getQuestionCountBySubject() {
    final counts = <String, int>{};
    for (final question in _questions) {
      if (question.subject != null) {
        final subject = question.subject!;
        counts[subject] = (counts[subject] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }
}
