import 'package:flutter_test/flutter_test.dart';
import 'package:medway/viewmodels/ocr_view_model.dart';
import 'package:medway/models/question.dart';

void main() {
  late OCRViewModel viewModel;

  setUp(() {
    viewModel = OCRViewModel();
  });

  group('OCRViewModel Tests', () {
    test('Initial state', () {
      expect(viewModel.questions, isEmpty);
      expect(viewModel.isProcessing, false);
    });

    test('Medical subjects list is not empty', () {
      expect(OCRViewModel.medicalSubjects, isNotEmpty);
      expect(OCRViewModel.medicalSubjects, contains('Anatomy'));
      expect(OCRViewModel.medicalSubjects, contains('Physiology'));
    });

    test('Exam types list is not empty', () {
      expect(OCRViewModel.examTypes, isNotEmpty);
      expect(OCRViewModel.examTypes, contains('USMLE Step 1'));
      expect(OCRViewModel.examTypes, contains('MCQ'));
    });

    test('Text processing fixes common OCR mistakes', () {
      const testText = 'rnicrobiology rnicroscopy rnicroorganism';
      const expectedText = 'microbiology microscopy microorganism';

      // Access private method using reflection
      final result = viewModel.processRecognizedText(testText);
      expect(result, expectedText);
    });

    test('Question filtering by subject', () {
      final question1 = Question(
        id: '1',
        text: 'Test question 1',
        imagePath: 'path1',
        createdAt: DateTime.now(),
        subject: 'Anatomy',
      );

      final question2 = Question(
        id: '2',
        text: 'Test question 2',
        imagePath: 'path2',
        createdAt: DateTime.now(),
        subject: 'Physiology',
      );

      viewModel.addQuestion(question1);
      viewModel.addQuestion(question2);

      final anatomyQuestions = viewModel.getQuestionsBySubject('Anatomy');
      expect(anatomyQuestions.length, 1);
      expect(anatomyQuestions.first.id, '1');
    });

    test('Performance tracking', () {
      final question = Question(
        id: '1',
        text: 'Test question',
        imagePath: 'path',
        createdAt: DateTime.now(),
        subject: 'Anatomy',
      );

      viewModel.addQuestion(question);
      viewModel.addQuestionAttempt(
          '1',
          QuestionAttempt(
            isCorrect: true,
            timeSpent: const Duration(minutes: 2),
            timestamp: DateTime.now(),
          ));

      final performance = viewModel.getPerformanceBySubject();
      expect(performance['Anatomy'], 1.0);
    });
  });
}
