import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/medicine_program.dart' show MedicineProgram, MedicineSource;
import '../models/medicine.dart';
import 'package:uuid/uuid.dart';

class MedicineProgramViewModel extends ChangeNotifier {
  final List<MedicineProgram> _programs = [];
  bool _isLoading = false;

  List<MedicineProgram> get programs => List.unmodifiable(_programs);
  List<MedicineProgram> get activePrograms =>
      _programs.where((p) => p.isActive).toList();
  bool get isLoading => _isLoading;

  // Common medicine sources
  static final List<MedicineSource> commonSources = [
    // Academic Medical Departments
    MedicineSource(
      name: 'Internal Medicine',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'General internal medicine and subspecialties',
    ),
    MedicineSource(
      name: 'Surgery',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'General surgery and surgical subspecialties',
    ),
    MedicineSource(
      name: 'Cardiology',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Heart and cardiovascular system diseases',
    ),
    MedicineSource(
      name: 'Neurology',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Neurological disorders and treatments',
    ),
    MedicineSource(
      name: 'Psychiatry',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Mental health and psychiatric disorders',
    ),
    MedicineSource(
      name: 'Respiratory Medicine',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Pulmonary diseases and respiratory system',
    ),
    MedicineSource(
      name: 'Urology',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Urinary tract and male reproductive system',
    ),
    MedicineSource(
      name: 'Orthopedics',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Musculoskeletal system and injuries',
    ),
    MedicineSource(
      name: 'ENT',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Ear, nose, and throat disorders',
    ),
    MedicineSource(
      name: 'Emergency Medicine',
      url: 'https://tip.akdeniz.edu.tr',
      description: 'Acute care and emergency treatments',
    ),
    // Online Medical Resources
    MedicineSource(
      name: 'WebMD',
      url: 'https://www.webmd.com',
      description: 'Trusted medical information and support',
    ),
    MedicineSource(
      name: 'Mayo Clinic',
      url: 'https://www.mayoclinic.org',
      description: 'Comprehensive medical resource',
    ),
    MedicineSource(
      name: 'NHS',
      url: 'https://www.nhs.uk',
      description: 'UK National Health Service information',
    ),
    MedicineSource(
      name: 'MedlinePlus',
      url: 'https://medlineplus.gov',
      description: 'US National Library of Medicine information',
    ),
  ];

  void createProgram({
    required String name,
    String? description,
    required List<String> days,
    required List<TimeOfDay> reminderTimes,
  }) {
    final program = MedicineProgram(
      id: const Uuid().v4(),
      name: name,
      description: description,
      days: days,
      reminderTimes: reminderTimes,
      medicines: [],
    );

    _programs.add(program);
    notifyListeners();
  }

  void updateProgram(MedicineProgram program) {
    final index = _programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      _programs[index] = program;
      notifyListeners();
    }
  }

  void deleteProgram(String id) {
    _programs.removeWhere((program) => program.id == id);
    notifyListeners();
  }

  void toggleProgramStatus(String id) {
    final index = _programs.indexWhere((p) => p.id == id);
    if (index != -1) {
      final program = _programs[index];
      _programs[index] = program.copyWith(isActive: !program.isActive);
      notifyListeners();
    }
  }

  void addMedicine(String programId, Medicine medicine) {
    final index = _programs.indexWhere((p) => p.id == programId);
    if (index != -1) {
      final program = _programs[index];
      final updatedMedicines = List<Medicine>.from(program.medicines)
        ..add(medicine);
      _programs[index] = program.copyWith(medicines: updatedMedicines);
      notifyListeners();
    }
  }

  void removeMedicine(String programId, String medicineId) {
    final index = _programs.indexWhere((p) => p.id == programId);
    if (index != -1) {
      final program = _programs[index];
      final updatedMedicines =
          program.medicines.where((m) => m.id != medicineId).toList();
      _programs[index] = program.copyWith(medicines: updatedMedicines);
      notifyListeners();
    }
  }

  void updateMedicine(String programId, Medicine medicine) {
    final programIndex = _programs.indexWhere((p) => p.id == programId);
    if (programIndex != -1) {
      final program = _programs[programIndex];
      final medicineIndex = program.medicines.indexWhere(
        (m) => m.id == medicine.id,
      );
      if (medicineIndex != -1) {
        final updatedMedicines = List<Medicine>.from(program.medicines);
        updatedMedicines[medicineIndex] = medicine;
        _programs[programIndex] = program.copyWith(medicines: updatedMedicines);
        notifyListeners();
      }
    }
  }

  void updateProgramDays(String programId, List<String> days) {
    final index = _programs.indexWhere((p) => p.id == programId);
    if (index != -1) {
      final program = _programs[index];
      _programs[index] = program.copyWith(days: days);
      notifyListeners();
    }
  }

  void updateProgramReminderTimes(
    String programId,
    List<TimeOfDay> reminderTimes,
  ) {
    final index = _programs.indexWhere((p) => p.id == programId);
    if (index != -1) {
      final program = _programs[index];
      _programs[index] = program.copyWith(reminderTimes: reminderTimes);
      notifyListeners();
    }
  }

  // TODO: Add methods for persistence (e.g., save to local storage)
  // TODO: Add methods for scheduling notifications
}
