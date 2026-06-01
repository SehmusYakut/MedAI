import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medway/viewmodels/medicine_program_view_model.dart';
import 'package:medway/viewmodels/ocr_view_model.dart';
import 'package:medway/models/question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MedicineProgramViewModel Persistence Tests', () {
    test('Should save and load medicine programs', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create VM and add a program
      final vm1 = MedicineProgramViewModel(prefs: prefs);
      expect(vm1.programs, isEmpty);

      vm1.createProgram(
        name: 'Aspirin Daily',
        description: 'For cardio health',
        days: ['Monday', 'Wednesday', 'Friday'],
        reminderTimes: [const TimeOfDay(hour: 8, minute: 0)],
      );
      expect(vm1.programs.length, 1);
      expect(vm1.programs.first.name, 'Aspirin Daily');

      // Create a new VM with the same SharedPreferences and check if it loads
      final vm2 = MedicineProgramViewModel(prefs: prefs);
      expect(vm2.programs.length, 1);
      expect(vm2.programs.first.name, 'Aspirin Daily');
      expect(vm2.programs.first.days, contains('Monday'));
      expect(vm2.programs.first.reminderTimes.first.hour, 8);
    });
  });

  group('OCRViewModel Persistence Tests', () {
    test('Should save and load scanned questions', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Create VM and add a question
      final vm1 = OCRViewModel(prefs: prefs);
      expect(vm1.questions, isEmpty);

      final question = Question(
        id: 'q-101',
        text: 'What is the powerhouse of the cell?',
        createdAt: DateTime.now(),
        subject: 'Physiology',
      );
      vm1.addQuestion(question);
      expect(vm1.questions.length, 1);

      // Create a new VM with the same SharedPreferences and check if it loads
      final vm2 = OCRViewModel(prefs: prefs);
      expect(vm2.questions.length, 1);
      expect(vm2.questions.first.id, 'q-101');
      expect(vm2.questions.first.text, 'What is the powerhouse of the cell?');
      expect(vm2.questions.first.subject, 'Physiology');
    });
  });
}
