class Question {
  final String id;
  final String text;
  final String? imagePath;
  final DateTime createdAt;
  final String? subject;
  final String? difficulty;
  final List<QuestionAttempt> attempts;
  final String? correctAnswer;
  final String? explanation;
  final List<String>? tags;
  final String? source;
  final int? year;
  final String? examType;

  Question({
    required this.id,
    required this.text,
    this.imagePath,
    required this.createdAt,
    this.subject,
    this.difficulty,
    List<QuestionAttempt>? attempts,
    this.correctAnswer,
    this.explanation,
    this.tags,
    this.source,
    this.year,
    this.examType,
  }) : attempts = attempts ?? [];

  Question copyWith({
    String? id,
    String? text,
    String? imagePath,
    DateTime? createdAt,
    String? subject,
    String? difficulty,
    List<QuestionAttempt>? attempts,
    String? correctAnswer,
    String? explanation,
    List<String>? tags,
    String? source,
    int? year,
    String? examType,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      attempts: attempts ?? this.attempts,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      year: year ?? this.year,
      examType: examType ?? this.examType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'subject': subject,
      'difficulty': difficulty,
      'attempts': attempts.map((a) => a.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'tags': tags,
      'source': source,
      'year': year,
      'examType': examType,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subject: json['subject'] as String?,
      difficulty: json['difficulty'] as String?,
      attempts: (json['attempts'] as List?)
              ?.map((a) => QuestionAttempt.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] as String?,
      explanation: json['explanation'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
      source: json['source'] as String?,
      year: json['year'] as int?,
      examType: json['examType'] as String?,
    );
  }
}

class QuestionAttempt {
  final DateTime timestamp;
  final Duration timeSpent;
  final bool isCorrect;
  final String? userAnswer;
  final String? explanation;
  final Map<String, dynamic>? metadata;

  QuestionAttempt({
    required this.timestamp,
    required this.timeSpent,
    required this.isCorrect,
    this.userAnswer,
    this.explanation,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'timeSpent': timeSpent.inSeconds,
      'isCorrect': isCorrect,
      'userAnswer': userAnswer,
      'explanation': explanation,
      'metadata': metadata,
    };
  }

  factory QuestionAttempt.fromJson(Map<String, dynamic> json) {
    return QuestionAttempt(
      timestamp: DateTime.parse(json['timestamp'] as String),
      timeSpent: Duration(seconds: json['timeSpent'] as int),
      isCorrect: json['isCorrect'] as bool,
      userAnswer: json['userAnswer'] as String?,
      explanation: json['explanation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
