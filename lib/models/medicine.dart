class Medicine {
  final String id;
  final String name;
  final String? description;
  final String dosage;
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final String? source;

  const Medicine({
    required this.id,
    required this.name,
    this.description,
    required this.dosage,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.source,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? description,
    String? dosage,
    DateTime? startDate,
    DateTime? endDate,
    String? instructions,
    String? source,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'source': source,
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      dosage: json['dosage'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] != null
              ? DateTime.parse(json['endDate'] as String)
              : null,
      instructions: json['instructions'] as String?,
      source: json['source'] as String?,
    );
  }
}
