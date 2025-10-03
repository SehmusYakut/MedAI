import 'package:flutter/material.dart';
import 'medicine.dart';

class MedicineSource {
  final String name;
  final String? url;
  final String? description;

  MedicineSource({required this.name, this.url, this.description});
}

class MedicineProgram {
  final String id;
  final String name;
  final String? description;
  final List<String> days;
  final List<TimeOfDay> reminderTimes;
  final List<Medicine> medicines;
  final bool isActive;

  MedicineProgram({
    required this.id,
    required this.name,
    this.description,
    required this.days,
    required this.reminderTimes,
    required this.medicines,
    this.isActive = true,
  });

  MedicineProgram copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? days,
    List<TimeOfDay>? reminderTimes,
    List<Medicine>? medicines,
    bool? isActive,
  }) {
    return MedicineProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      medicines: medicines ?? this.medicines,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'days': days,
      'reminderTimes':
          reminderTimes.map((time) => '${time.hour}:${time.minute}').toList(),
      'medicines': medicines.map((medicine) => medicine.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory MedicineProgram.fromJson(Map<String, dynamic> json) {
    return MedicineProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      days: (json['days'] as List<dynamic>).map((e) => e as String).toList(),
      reminderTimes:
          (json['reminderTimes'] as List<dynamic>).map((e) {
            final parts = (e as String).split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList(),
      medicines:
          (json['medicines'] as List<dynamic>)
              .map((e) => Medicine.fromJson(e as Map<String, dynamic>))
              .toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  DateTime get endDate {
    if (medicines.isEmpty) return DateTime.now();

    DateTime latestEnd = medicines.first.endDate ?? medicines.first.startDate;
    for (var medicine in medicines.skip(1)) {
      final endDate = medicine.endDate ?? medicine.startDate;
      if (endDate.isAfter(latestEnd)) {
        latestEnd = endDate;
      }
    }
    return latestEnd;
  }
}
