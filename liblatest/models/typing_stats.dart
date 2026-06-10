/// Model class for storing typing statistics
class TypingStats {
  final int bestWpm;
  final int avgWpm;
  final double avgAccuracy;
  final int totalAttempts;

  const TypingStats({
    required this.bestWpm,
    required this.avgWpm,
    required this.avgAccuracy,
    required this.totalAttempts,
  });

  /// Create a copy of this TypingStats with updated values
  TypingStats copyWith({
    int? bestWpm,
    int? avgWpm,
    double? avgAccuracy,
    int? totalAttempts,
  }) {
    return TypingStats(
      bestWpm: bestWpm ?? this.bestWpm,
      avgWpm: avgWpm ?? this.avgWpm,
      avgAccuracy: avgAccuracy ?? this.avgAccuracy,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }

  /// Create empty stats
  factory TypingStats.empty() {
    return const TypingStats(
      bestWpm: 0,
      avgWpm: 0,
      avgAccuracy: 0.0,
      totalAttempts: 0,
    );
  }

  @override
  String toString() {
    return 'TypingStats{bestWpm: $bestWpm, avgWpm: $avgWpm, avgAccuracy: $avgAccuracy, totalAttempts: $totalAttempts}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypingStats &&
        other.bestWpm == bestWpm &&
        other.avgWpm == avgWpm &&
        other.avgAccuracy == avgAccuracy &&
        other.totalAttempts == totalAttempts;
  }

  @override
  int get hashCode {
    return bestWpm.hashCode ^
        avgWpm.hashCode ^
        avgAccuracy.hashCode ^
        totalAttempts.hashCode;
  }
}
