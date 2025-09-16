// Simple model to store typing test results
class TypingTestModel {
  final int? id;
  final String testType;        // character, word, number, sentence, moving_word
  final String originalText;    // What user was supposed to type
  final String typedText;       // What user actually typed
  final double wpm;             // Words per minute
  final double accuracy;        // Accuracy percentage
  final int correctWords;       // Number of correct words
  final int wrongWords;         // Number of wrong words
  final int totalWords;         // Total words in test
  final int timeSeconds;        // Time taken in seconds
  final DateTime testDate;      // When test was taken

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

  // Convert to Map for database storage
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

  // Create from Map (database)
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

  // Get formatted time string (mm:ss)
  String get formattedTime {
    int minutes = timeSeconds ~/ 60;
    int seconds = timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get date string (yyyy-mm-dd)
  String get dateString {
    return '${testDate.year}-${testDate.month.toString().padLeft(2, '0')}-${testDate.day.toString().padLeft(2, '0')}';
  }
}
