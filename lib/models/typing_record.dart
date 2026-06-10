/// Model class for storing typing exercise records
class TypingRecord {
  final int? id;
  final String username;
  final String country;
  final int wpm;
  final double accuracy;
  final DateTime createdAt;
  final String languageCode; // e.g. 'en', 'hi', 'gu'

  TypingRecord({
    this.id,
    required this.username,
    required this.country,
    required this.wpm,
    required this.accuracy,
    DateTime? createdAt,
    this.languageCode = 'en',
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert TypingRecord to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'country': country,
      'wpm': wpm,
      'accuracy': accuracy,
      'created_at': createdAt.millisecondsSinceEpoch,
      'language_code': languageCode,
    };
  }

  /// Create TypingRecord from Map (database result)
  factory TypingRecord.fromMap(Map<String, dynamic> map) {
    return TypingRecord(
      id: (map['id'] as int?),
      username: map['username'] as String? ?? '',
      country: map['country'] as String? ?? '',
      wpm: (map['wpm'] as int?) ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      languageCode: map['language_code'] as String? ?? 'en',
    );
  }

  /// Create a copy of this TypingRecord with updated values
  TypingRecord copyWith({
    int? id,
    String? username,
    String? country,
    int? wpm,
    double? accuracy,
    DateTime? createdAt,
    String? languageCode,
  }) {
    return TypingRecord(
      id: id ?? this.id,
      username: username ?? this.username,
      country: country ?? this.country,
      wpm: wpm ?? this.wpm,
      accuracy: accuracy ?? this.accuracy,
      createdAt: createdAt ?? this.createdAt,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  String toString() {
    return 'TypingRecord{id: $id, username: $username, country: $country, wpm: $wpm, accuracy: $accuracy, createdAt: $createdAt, languageCode: $languageCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypingRecord &&
        other.id == id &&
        other.username == username &&
        other.country == country &&
        other.wpm == wpm &&
        other.accuracy == accuracy &&
        other.createdAt == createdAt &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        country.hashCode ^
        wpm.hashCode ^
        accuracy.hashCode ^
        createdAt.hashCode ^
        languageCode.hashCode;
  }
}
