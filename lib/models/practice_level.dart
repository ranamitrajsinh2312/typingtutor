// =========================================================================
// 📚 LEVEL MODEL - TYPING PRACTICE LEVELS
// =========================================================================

/// Represents a typing practice level
class PracticeLevel {
  final int id;
  final String title;
  final String description;
  final PracticeType type;
  final String languageCode;
  final int contentCount;
  final int difficulty; // 1-3 (easy, medium, hard)
  final bool isLocked;
  final int starsEarned; // 0-3 stars
  final bool isCompleted;
  final int bestWpm;
  final double bestAccuracy;

  const PracticeLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.languageCode,
    required this.contentCount,
    this.difficulty = 1,
    this.isLocked = false,
    this.starsEarned = 0,
    this.isCompleted = false,
    this.bestWpm = 0,
    this.bestAccuracy = 0.0,
  });

  /// Copy with method for updating level state
  PracticeLevel copyWith({
    int? id,
    String? title,
    String? description,
    PracticeType? type,
    String? languageCode,
    int? contentCount,
    int? difficulty,
    bool? isLocked,
    int? starsEarned,
    bool? isCompleted,
    int? bestWpm,
    double? bestAccuracy,
  }) {
    return PracticeLevel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      languageCode: languageCode ?? this.languageCode,
      contentCount: contentCount ?? this.contentCount,
      difficulty: difficulty ?? this.difficulty,
      isLocked: isLocked ?? this.isLocked,
      starsEarned: starsEarned ?? this.starsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      bestWpm: bestWpm ?? this.bestWpm,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'languageCode': languageCode,
      'contentCount': contentCount,
      'difficulty': difficulty,
      'isLocked': isLocked ? 1 : 0,
      'starsEarned': starsEarned,
      'isCompleted': isCompleted ? 1 : 0,
      'bestWpm': bestWpm,
      'bestAccuracy': bestAccuracy,
    };
  }

  /// Create from Map
  factory PracticeLevel.fromMap(Map<String, dynamic> map) {
    return PracticeLevel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      type: PracticeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PracticeType.word,
      ),
      languageCode: map['languageCode'] as String,
      contentCount: map['contentCount'] as int,
      difficulty: map['difficulty'] as int? ?? 1,
      isLocked: (map['isLocked'] as int? ?? 0) == 1,
      starsEarned: map['starsEarned'] as int? ?? 0,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      bestWpm: map['bestWpm'] as int? ?? 0,
      bestAccuracy: (map['bestAccuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'PracticeLevel{id: $id, title: $title, type: $type, language: $languageCode, stars: $starsEarned}';
  }
}

/// Types of practice content
enum PracticeType { word, sentence, paragraph }

/// Extension for PracticeType
extension PracticeTypeExtension on PracticeType {
  String get displayName {
    switch (this) {
      case PracticeType.word:
        return 'Words';
      case PracticeType.sentence:
        return 'Sentences';
      case PracticeType.paragraph:
        return 'Paragraphs';
    }
  }

  String get icon {
    switch (this) {
      case PracticeType.word:
        return '📝';
      case PracticeType.sentence:
        return '📄';
      case PracticeType.paragraph:
        return '📖';
    }
  }

  String get description {
    switch (this) {
      case PracticeType.word:
        return 'Practice individual words';
      case PracticeType.sentence:
        return 'Practice complete sentences';
      case PracticeType.paragraph:
        return 'Practice full paragraphs';
    }
  }
}

// =========================================================================
// 📝 TYPING CONTENT MODEL
// =========================================================================

/// Represents typing practice content (word, sentence, paragraph)
class TypingContent {
  final String text;
  final String languageCode;
  final PracticeType type;
  final int levelId;

  const TypingContent({
    required this.text,
    required this.languageCode,
    required this.type,
    required this.levelId,
  });

  /// Create from API JSON response
  factory TypingContent.fromJson(
    Map<String, dynamic> json, {
    PracticeType? type,
    int? levelId,
  }) {
    // Handle API response format: {"text": "...", "lang": "hin"}
    String langCode = json['lang'] as String? ?? 'en';

    // Convert language codes
    if (langCode == 'hin') langCode = 'hi';
    if (langCode == 'guj') langCode = 'gu';
    if (langCode == 'eng') langCode = 'en';

    return TypingContent(
      text: json['text'] as String,
      languageCode: langCode,
      type: type ?? PracticeType.sentence,
      levelId: levelId ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'lang': languageCode,
      'type': type.name,
      'levelId': levelId,
    };
  }

  @override
  String toString() {
    return 'TypingContent{text: ${text.substring(0, text.length > 20 ? 20 : text.length)}..., lang: $languageCode}';
  }
}

// =========================================================================
// 🏆 LEVEL COMPLETION RESULT
// =========================================================================

/// Result of completing a level
class LevelCompletionResult {
  final int levelId;
  final int starsEarned;
  final int wpm;
  final double accuracy;
  final Duration timeTaken;
  final int correctChars;
  final int incorrectChars;
  final bool isNewBest;
  final DateTime completedAt;

  const LevelCompletionResult({
    required this.levelId,
    required this.starsEarned,
    required this.wpm,
    required this.accuracy,
    required this.timeTaken,
    required this.correctChars,
    required this.incorrectChars,
    this.isNewBest = false,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? const _DefaultDateTime();

  /// Calculate stars based on performance
  static int calculateStars(int wpm, double accuracy) {
    int stars = 0;

    // Star 1: Complete the level (minimum requirements)
    if (accuracy >= 70.0) {
      stars = 1;
    }

    // Star 2: Good performance
    if (accuracy >= 85.0 && wpm >= 20) {
      stars = 2;
    }

    // Star 3: Excellent performance
    if (accuracy >= 95.0 && wpm >= 40) {
      stars = 3;
    }

    return stars;
  }

  /// Get star rating text
  String get starRatingText {
    switch (starsEarned) {
      case 0:
        return 'Keep Practicing!';
      case 1:
        return 'Good Start!';
      case 2:
        return 'Great Job!';
      case 3:
        return 'Perfect!';
      default:
        return 'Complete';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'starsEarned': starsEarned,
      'wpm': wpm,
      'accuracy': accuracy,
      'timeTaken': timeTaken.inSeconds,
      'correctChars': correctChars,
      'incorrectChars': incorrectChars,
      'isNewBest': isNewBest ? 1 : 0,
      'completedAt': completedAt.millisecondsSinceEpoch,
    };
  }

  factory LevelCompletionResult.fromMap(Map<String, dynamic> map) {
    return LevelCompletionResult(
      levelId: map['levelId'] as int,
      starsEarned: map['starsEarned'] as int,
      wpm: map['wpm'] as int,
      accuracy: (map['accuracy'] as num).toDouble(),
      timeTaken: Duration(seconds: map['timeTaken'] as int),
      correctChars: map['correctChars'] as int,
      incorrectChars: map['incorrectChars'] as int,
      isNewBest: (map['isNewBest'] as int?) == 1,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        map['completedAt'] as int,
      ),
    );
  }
}

/// Helper class for default DateTime
class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}
