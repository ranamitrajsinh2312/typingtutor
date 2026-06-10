// =========================================================================
// ⌨️ KEYBOARD LESSON MODEL - TYPING LESSON DATA STRUCTURE
// =========================================================================

/// Represents a keyboard lesson type
enum KeyboardLessonType {
  homeRow,
  topRow,
  bottomRow,
  homeTopRow,
  homeBottomRow,
  topBottomRow,
  allRows,
  homeRowShift,
  numbers,
  symbols,
}

extension KeyboardLessonTypeExtension on KeyboardLessonType {
  String get displayName {
    switch (this) {
      case KeyboardLessonType.homeRow:
        return 'Home Row';
      case KeyboardLessonType.topRow:
        return 'Top Row';
      case KeyboardLessonType.bottomRow:
        return 'Bottom Row';
      case KeyboardLessonType.homeTopRow:
        return 'Home & Top Row';
      case KeyboardLessonType.homeBottomRow:
        return 'Home & Bottom Row';
      case KeyboardLessonType.topBottomRow:
        return 'Top & Bottom Row';
      case KeyboardLessonType.allRows:
        return 'All Rows';
      case KeyboardLessonType.homeRowShift:
        return 'Home Row + Shift';
      case KeyboardLessonType.numbers:
        return 'Numbers';
      case KeyboardLessonType.symbols:
        return 'Symbols';
    }
  }

  String get description {
    switch (this) {
      case KeyboardLessonType.homeRow:
        return 'Master the home row keys - your fingers\' resting position';
      case KeyboardLessonType.topRow:
        return 'Practice the top row letters';
      case KeyboardLessonType.bottomRow:
        return 'Learn the bottom row keys';
      case KeyboardLessonType.homeTopRow:
        return 'Combine home and top row practice';
      case KeyboardLessonType.homeBottomRow:
        return 'Combine home and bottom row practice';
      case KeyboardLessonType.topBottomRow:
        return 'Practice top and bottom row together';
      case KeyboardLessonType.allRows:
        return 'Full keyboard mastery';
      case KeyboardLessonType.homeRowShift:
        return 'Home row with uppercase letters';
      case KeyboardLessonType.numbers:
        return 'Number row practice';
      case KeyboardLessonType.symbols:
        return 'Special characters and symbols';
    }
  }

  String get iconAsset {
    switch (this) {
      case KeyboardLessonType.homeRow:
        return 'assets/keybord_image/homeRow.png';
      case KeyboardLessonType.topRow:
        return 'assets/keybord_image/toprow.png';
      case KeyboardLessonType.bottomRow:
        return 'assets/keybord_image/bottomRow.png';
      case KeyboardLessonType.homeTopRow:
        return 'assets/keybord_image/hometop.png';
      case KeyboardLessonType.homeBottomRow:
        return 'assets/keybord_image/homeRowbottomRow.png';
      case KeyboardLessonType.topBottomRow:
        return 'assets/keybord_image/BOTTOMtop.png';
      case KeyboardLessonType.allRows:
        return 'assets/keybord_image/homeRowtop.png';
      case KeyboardLessonType.homeRowShift:
        return 'assets/keybord_image/homeRowSHIFT.png';
      case KeyboardLessonType.numbers:
        return 'assets/keybord_image/toprow.png';
      case KeyboardLessonType.symbols:
        return 'assets/keybord_image/toprowshift.png';
    }
  }
}

/// Represents a single keyboard lesson
class KeyboardLesson {
  final int id;
  final String title;
  final String description;
  final KeyboardLessonType lessonType;
  final String languageCode;
  final String practiceText;
  final List<String> highlightKeys;
  final int difficulty; // 1-3
  final bool isLocked;
  final int starsEarned;
  final bool isCompleted;
  final int bestWpm;
  final double bestAccuracy;
  final String imagePath;

  const KeyboardLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.lessonType,
    required this.languageCode,
    required this.practiceText,
    required this.highlightKeys,
    this.difficulty = 1,
    this.isLocked = false,
    this.starsEarned = 0,
    this.isCompleted = false,
    this.bestWpm = 0,
    this.bestAccuracy = 0.0,
    this.imagePath = '',
  });

  KeyboardLesson copyWith({
    int? id,
    String? title,
    String? description,
    KeyboardLessonType? lessonType,
    String? languageCode,
    String? practiceText,
    List<String>? highlightKeys,
    int? difficulty,
    bool? isLocked,
    int? starsEarned,
    bool? isCompleted,
    int? bestWpm,
    double? bestAccuracy,
    String? imagePath,
  }) {
    return KeyboardLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonType: lessonType ?? this.lessonType,
      languageCode: languageCode ?? this.languageCode,
      practiceText: practiceText ?? this.practiceText,
      highlightKeys: highlightKeys ?? this.highlightKeys,
      difficulty: difficulty ?? this.difficulty,
      isLocked: isLocked ?? this.isLocked,
      starsEarned: starsEarned ?? this.starsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      bestWpm: bestWpm ?? this.bestWpm,
      bestAccuracy: bestAccuracy ?? this.bestAccuracy,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lessonType': lessonType.name,
      'languageCode': languageCode,
      'practiceText': practiceText,
      'highlightKeys': highlightKeys.join(','),
      'difficulty': difficulty,
      'isLocked': isLocked ? 1 : 0,
      'starsEarned': starsEarned,
      'isCompleted': isCompleted ? 1 : 0,
      'bestWpm': bestWpm,
      'bestAccuracy': bestAccuracy,
      'imagePath': imagePath,
    };
  }

  /// Create from Map
  factory KeyboardLesson.fromMap(Map<String, dynamic> map) {
    return KeyboardLesson(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      lessonType: KeyboardLessonType.values.firstWhere(
        (e) => e.name == map['lessonType'],
        orElse: () => KeyboardLessonType.homeRow,
      ),
      languageCode: map['languageCode'] as String,
      practiceText: map['practiceText'] as String,
      highlightKeys: (map['highlightKeys'] as String).split(','),
      difficulty: map['difficulty'] as int? ?? 1,
      isLocked: (map['isLocked'] as int? ?? 0) == 1,
      starsEarned: map['starsEarned'] as int? ?? 0,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      bestWpm: map['bestWpm'] as int? ?? 0,
      bestAccuracy: (map['bestAccuracy'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'] as String? ?? '',
    );
  }
}

/// Result of a completed keyboard lesson
class KeyboardLessonResult {
  final int lessonId;
  final String languageCode;
  final int wpm;
  final double accuracy;
  final int timeInSeconds;
  final int starsEarned;
  final DateTime completedAt;

  const KeyboardLessonResult({
    required this.lessonId,
    required this.languageCode,
    required this.wpm,
    required this.accuracy,
    required this.timeInSeconds,
    required this.starsEarned,
    required this.completedAt,
  });

  /// Calculate stars based on performance
  static int calculateStars(double accuracy, int wpm) {
    // 3 stars: accuracy >= 95% AND wpm >= 30
    if (accuracy >= 95.0 && wpm >= 30) return 3;
    // 2 stars: accuracy >= 85% AND wpm >= 20
    if (accuracy >= 85.0 && wpm >= 20) return 2;
    // 1 star: accuracy >= 70%
    if (accuracy >= 70.0) return 1;
    // 0 stars: below 70% accuracy
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'languageCode': languageCode,
      'wpm': wpm,
      'accuracy': accuracy,
      'timeInSeconds': timeInSeconds,
      'starsEarned': starsEarned,
      'completedAt': completedAt.millisecondsSinceEpoch,
    };
  }

  factory KeyboardLessonResult.fromMap(Map<String, dynamic> map) {
    return KeyboardLessonResult(
      lessonId: map['lessonId'] as int,
      languageCode: map['languageCode'] as String,
      wpm: map['wpm'] as int,
      accuracy: (map['accuracy'] as num).toDouble(),
      timeInSeconds: map['timeInSeconds'] as int,
      starsEarned: map['starsEarned'] as int,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        map['completedAt'] as int,
      ),
    );
  }
}
