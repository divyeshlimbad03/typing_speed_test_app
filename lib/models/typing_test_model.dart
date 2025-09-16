class TypingTestModel {
  final int? id;
  final String testType;
  final String originalText;
  final String typedText;
  final double wpm;
  final double accuracy;
  final int correctWords;
  final int wrongWords;
  final int totalWords;
  final int timeSeconds;
  final DateTime testDate;

  TypingTestModel({
    this.id,
    required this.testType,
    required this.originalText,
    required this.typedText,
    required this.wpm,
    required this.accuracy,
    required this.correctWords,
    required this.wrongWords,
    required this.totalWords,
    required this.timeSeconds,
    required this.testDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'test_type': testType,
      'original_text': originalText,
      'typed_text': typedText,
      'wpm': wpm,
      'accuracy': accuracy,
      'correct_words': correctWords,
      'wrong_words': wrongWords,
      'total_words': totalWords,
      'time_seconds': timeSeconds,
      'test_date': testDate.toIso8601String(),
    };
  }

  factory TypingTestModel.fromMap(Map<String, dynamic> map) {
    return TypingTestModel(
      id: map['id']?.toInt(),
      testType: map['test_type'] ?? '',
      originalText: map['original_text'] ?? '',
      typedText: map['typed_text'] ?? '',
      wpm: map['wpm']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble() ?? 0.0,
      correctWords: map['correct_words']?.toInt() ?? 0,
      wrongWords: map['wrong_words']?.toInt() ?? 0,
      totalWords: map['total_words']?.toInt() ?? 0,
      timeSeconds: map['time_seconds']?.toInt() ?? 0,
      testDate: DateTime.parse(map['test_date']),
    );
  }

  String get formattedTime {
    int minutes = timeSeconds ~/ 60;
    int seconds = timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get dateString {
    return '${testDate.year}-${testDate.month.toString().padLeft(2, '0')}-${testDate.day.toString().padLeft(2, '0')}';
  }
}
