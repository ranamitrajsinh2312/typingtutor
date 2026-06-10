// =========================================================================
// 🎹 KEYBOARD LAYOUT MODEL - MULTILINGUAL KEYBOARD SUPPORT
// =========================================================================

/// Model class representing a keyboard layout for a specific language
class KeyboardLayout {
  final String languageCode;
  final String languageName;
  final List<List<String>> rows;
  final List<List<String>>? shiftRows; // For uppercase/shift characters
  final List<String>? matras; // For Hindi/Gujarati diacritics
  final List<String>? conjuncts; // For Hindi/Gujarati conjuncts
  final List<String>?
  nuktaVariants; // For nukta-modified consonants (क़, ख़, etc.)
  final List<String>? vowels; // Independent vowels (अ, आ, इ, etc.)
  final List<String>? consonants; // All consonants (क to ह)
  final List<String>? numbers; // Native numerals (०-९, ૦-૯)
  final List<String>? punctuation; // Punctuation marks (। ॥ etc.)
  final bool hasShiftVariant;
  final bool isRightToLeft;

  const KeyboardLayout({
    required this.languageCode,
    required this.languageName,
    required this.rows,
    this.shiftRows,
    this.matras,
    this.conjuncts,
    this.nuktaVariants,
    this.vowels,
    this.consonants,
    this.numbers,
    this.punctuation,
    this.hasShiftVariant = true,
    this.isRightToLeft = false,
  });

  /// Get row by index
  List<String> getRow(int index) {
    if (index >= 0 && index < rows.length) {
      return rows[index];
    }
    return [];
  }

  /// Get shift row by index
  List<String> getShiftRow(int index) {
    if (shiftRows != null && index >= 0 && index < shiftRows!.length) {
      return shiftRows![index];
    }
    return getRow(index);
  }

  /// Get all characters (flattened)
  List<String> getAllCharacters() {
    return rows.expand((row) => row).toList();
  }

  /// Get all shift characters (flattened)
  List<String> getAllShiftCharacters() {
    if (shiftRows != null) {
      return shiftRows!.expand((row) => row).toList();
    }
    return getAllCharacters();
  }

  /// Convert to JSON format
  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'row1': rows.isNotEmpty ? rows[0] : [],
      'row2': rows.length > 1 ? rows[1] : [],
      'row3': rows.length > 2 ? rows[2] : [],
      'row4': rows.length > 3 ? rows[3] : [],
      'row5': rows.length > 4 ? rows[4] : [],
      'row6': rows.length > 5 ? rows[5] : [],
      'shiftRow1':
          shiftRows != null && shiftRows!.isNotEmpty ? shiftRows![0] : null,
      'shiftRow2':
          shiftRows != null && shiftRows!.length > 1 ? shiftRows![1] : null,
      'shiftRow3':
          shiftRows != null && shiftRows!.length > 2 ? shiftRows![2] : null,
      'shiftRow4':
          shiftRows != null && shiftRows!.length > 3 ? shiftRows![3] : null,
      'shiftRow5':
          shiftRows != null && shiftRows!.length > 4 ? shiftRows![4] : null,
      'shiftRow6':
          shiftRows != null && shiftRows!.length > 5 ? shiftRows![5] : null,
      'matras': matras,
      'conjuncts': conjuncts,
      'nuktaVariants': nuktaVariants,
      'vowels': vowels,
      'consonants': consonants,
      'numbers': numbers,
      'punctuation': punctuation,
      'hasShiftVariant': hasShiftVariant,
      'isRightToLeft': isRightToLeft,
    };
  }

  /// Create from JSON
  factory KeyboardLayout.fromJson(Map<String, dynamic> json) {
    return KeyboardLayout(
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      rows: [
        List<String>.from(json['row1'] ?? []),
        List<String>.from(json['row2'] ?? []),
        List<String>.from(json['row3'] ?? []),
        if (json['row4'] != null) List<String>.from(json['row4']),
        if (json['row5'] != null) List<String>.from(json['row5']),
        if (json['row6'] != null) List<String>.from(json['row6']),
      ],
      shiftRows:
          json['shiftRow1'] != null
              ? [
                List<String>.from(json['shiftRow1'] ?? []),
                List<String>.from(json['shiftRow2'] ?? []),
                List<String>.from(json['shiftRow3'] ?? []),
                if (json['shiftRow4'] != null)
                  List<String>.from(json['shiftRow4']),
                if (json['shiftRow5'] != null)
                  List<String>.from(json['shiftRow5']),
                if (json['shiftRow6'] != null)
                  List<String>.from(json['shiftRow6']),
              ]
              : null,
      matras: json['matras'] != null ? List<String>.from(json['matras']) : null,
      conjuncts:
          json['conjuncts'] != null
              ? List<String>.from(json['conjuncts'])
              : null,
      nuktaVariants:
          json['nuktaVariants'] != null
              ? List<String>.from(json['nuktaVariants'])
              : null,
      vowels: json['vowels'] != null ? List<String>.from(json['vowels']) : null,
      consonants:
          json['consonants'] != null
              ? List<String>.from(json['consonants'])
              : null,
      numbers:
          json['numbers'] != null ? List<String>.from(json['numbers']) : null,
      punctuation:
          json['punctuation'] != null
              ? List<String>.from(json['punctuation'])
              : null,
      hasShiftVariant: json['hasShiftVariant'] ?? true,
      isRightToLeft: json['isRightToLeft'] ?? false,
    );
  }

  @override
  String toString() {
    return 'KeyboardLayout{languageCode: $languageCode, languageName: $languageName, rows: ${rows.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyboardLayout && other.languageCode == languageCode;
  }

  @override
  int get hashCode => languageCode.hashCode;
}
