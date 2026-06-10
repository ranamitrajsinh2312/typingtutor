// =========================================================================
// 🔤 ATOMIC TYPING SERVICE - UNICODE-AWARE CHARACTER HANDLING
// =========================================================================
//
// This service handles atomic character splitting for Indic scripts (Hindi/Gujarati)
// Each visible character part must be typed step-by-step, including:
// - Base consonants (व्यंजन)
// - Vowel signs/matras (मात्राएँ)
// - Virama/halant (्)
// - Nukta (़)
// - Anusvara (ं)
// - Visarga (ः)
//
// Example:
// "નમસ્તે" splits into: ["ન", "મ", "સ", "્", "ત", "ે"]
// "नमस्ते" splits into: ["न", "म", "स", "्", "त", "े"]
//
// =========================================================================

import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

/// Service for handling atomic character-based typing for Indic scripts
class AtomicTypingService {
  // =========================================================================
  // 📊 UNICODE RANGES FOR INDIC SCRIPTS
  // =========================================================================

  /// Hindi (Devanagari) Unicode ranges
  static const int _devanagariStart = 0x0900;
  static const int _devanagariEnd = 0x097F;

  /// Gujarati Unicode ranges
  static const int _gujaratiStart = 0x0A80;
  static const int _gujaratiEnd = 0x0AFF;

  /// Virama (halant) code points
  static const int _devanagariVirama = 0x094D; // ्
  static const int _gujaratiVirama = 0x0ACD; // ્

  /// Nukta code points
  static const int _devanagariNukta = 0x093C; // ़
  static const int _gujaratiNukta = 0x0ABC; // ઼

  // =========================================================================
  // 🔤 ATOMIC CHARACTER SPLITTING
  // =========================================================================

  /// Split text into atomic typing units
  /// Each unit represents a single keystroke required
  ///
  /// For English: Each character is one unit
  /// For Hindi/Gujarati: Each Unicode code point is one unit
  ///   - Base characters are separate
  ///   - Matras (vowel signs) are separate
  ///   - Virama (halant) is separate
  ///   - Nukta is separate
  ///
  /// Example:
  /// "નમસ્તે" → ["ન", "મ", "સ", "્", "ત", "ે"]
  static List<String> splitIntoAtomicUnits(String text, String languageCode) {
    if (text.isEmpty) return [];

    switch (languageCode) {
      case 'hi':
      case 'gu':
        return _splitIndicText(text);
      case 'en':
      default:
        return _splitEnglishText(text);
    }
  }

  /// Split English text into characters
  static List<String> _splitEnglishText(String text) {
    return text.split('');
  }

  /// Split Indic text into atomic units (code points)
  /// This ensures each keystroke is counted separately
  static List<String> _splitIndicText(String text) {
    final List<String> units = [];

    // Use runes to get individual code points
    for (final rune in text.runes) {
      units.add(String.fromCharCode(rune));
    }

    return units;
  }

  /// Alternative split using Characters package for grapheme clusters
  /// Use this when you want to preserve visual characters
  static List<String> splitIntoGraphemes(String text) {
    return text.characters.toList();
  }

  // =========================================================================
  // 🔍 CHARACTER TYPE DETECTION
  // =========================================================================

  /// Check if a character is from Devanagari script (Hindi)
  static bool isDevanagari(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;
    return codePoint >= _devanagariStart && codePoint <= _devanagariEnd;
  }

  /// Check if a character is from Gujarati script
  static bool isGujarati(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;
    return codePoint >= _gujaratiStart && codePoint <= _gujaratiEnd;
  }

  /// Check if a character is a virama (halant)
  static bool isVirama(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;
    return codePoint == _devanagariVirama || codePoint == _gujaratiVirama;
  }

  /// Check if a character is a nukta
  static bool isNukta(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;
    return codePoint == _devanagariNukta || codePoint == _gujaratiNukta;
  }

  /// Check if a character is a vowel sign (matra)
  static bool isMatra(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;

    // Devanagari matras: 0x093E - 0x094C, 0x0962 - 0x0963
    if ((codePoint >= 0x093E && codePoint <= 0x094C) ||
        (codePoint >= 0x0962 && codePoint <= 0x0963)) {
      return true;
    }

    // Gujarati matras: 0x0ABE - 0x0ACC
    if (codePoint >= 0x0ABE && codePoint <= 0x0ACC) {
      return true;
    }

    return false;
  }

  /// Check if a character is a dependent sign (matra, virama, nukta, etc.)
  static bool isDependentSign(String char) {
    return isMatra(char) ||
        isVirama(char) ||
        isNukta(char) ||
        isAnusvara(char) ||
        isVisarga(char);
  }

  /// Check if a character is anusvara (ं/ં)
  static bool isAnusvara(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;
    return codePoint == 0x0902 || // Devanagari anusvara
        codePoint == 0x0A82; // Gujarati anusvara
  }

  /// Check if a character is visarga (ः/ઃ)
  static bool isVisarga(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;
    return codePoint == 0x0903 || // Devanagari visarga
        codePoint == 0x0A83; // Gujarati visarga
  }

  /// Check if a character is a base consonant
  static bool isConsonant(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;

    // Devanagari consonants: 0x0915 - 0x0939
    if (codePoint >= 0x0915 && codePoint <= 0x0939) {
      return true;
    }

    // Gujarati consonants: 0x0A95 - 0x0AB9
    if (codePoint >= 0x0A95 && codePoint <= 0x0AB9) {
      return true;
    }

    return false;
  }

  /// Check if a character is a vowel (independent)
  static bool isVowel(String char) {
    if (char.isEmpty) return false;
    final codePoint = char.runes.first;

    // Devanagari vowels: 0x0904 - 0x0914
    if (codePoint >= 0x0904 && codePoint <= 0x0914) {
      return true;
    }

    // Gujarati vowels: 0x0A85 - 0x0A94
    if (codePoint >= 0x0A85 && codePoint <= 0x0A94) {
      return true;
    }

    return false;
  }

  // =========================================================================
  // 🎯 CHARACTER COMPARISON
  // =========================================================================

  /// Compare two atomic units for typing
  /// Returns true if input matches expected
  static bool compareAtomicUnits(
    String input,
    String expected,
    String languageCode,
  ) {
    if (input.isEmpty || expected.isEmpty) return false;

    switch (languageCode) {
      case 'en':
        // English: case-insensitive
        return input.toLowerCase() == expected.toLowerCase();
      case 'hi':
      case 'gu':
        // Indic: exact code point match
        if (input.runes.isEmpty || expected.runes.isEmpty) return false;
        return input.runes.first == expected.runes.first;
      default:
        return input == expected;
    }
  }

  // =========================================================================
  // 📊 WPM CALCULATION (Unicode Safe)
  // =========================================================================

  /// Count atomic units for WPM calculation
  /// Uses code points for accurate counting
  static int countAtomicUnits(String text, String languageCode) {
    return splitIntoAtomicUnits(text, languageCode).length;
  }

  /// Calculate WPM using atomic units
  /// Standard: 5 characters = 1 word
  static int calculateWpm(int correctUnits, int elapsedSeconds) {
    if (elapsedSeconds <= 0) return 0;
    final minutes = elapsedSeconds / 60.0;
    return ((correctUnits / 5) / minutes).round();
  }

  /// Calculate accuracy percentage
  static double calculateAccuracy(int correct, int incorrect) {
    final total = correct + incorrect;
    if (total == 0) return 100.0;
    return (correct / total * 100).clamp(0.0, 100.0);
  }

  // =========================================================================
  // 📝 DEBUG HELPERS
  // =========================================================================

  /// Get detailed breakdown of a word for debugging
  static List<Map<String, dynamic>> analyzeWord(
    String word,
    String languageCode,
  ) {
    final units = splitIntoAtomicUnits(word, languageCode);
    final analysis = <Map<String, dynamic>>[];

    for (int i = 0; i < units.length; i++) {
      final unit = units[i];
      final codePoint = unit.runes.first;

      analysis.add({
        'index': i,
        'char': unit,
        'codePoint': '0x${codePoint.toRadixString(16).toUpperCase()}',
        'isConsonant': isConsonant(unit),
        'isVowel': isVowel(unit),
        'isMatra': isMatra(unit),
        'isVirama': isVirama(unit),
        'isNukta': isNukta(unit),
        'isAnusvara': isAnusvara(unit),
        'isVisarga': isVisarga(unit),
      });
    }

    return analysis;
  }

  /// Print word analysis for debugging
  static void debugWord(String word, String languageCode) {
    debugPrint('=== Analyzing word: $word ===');
    final analysis = analyzeWord(word, languageCode);
    for (final item in analysis) {
      debugPrint(
        '  [${item['index']}] "${item['char']}" (${item['codePoint']})',
      );
      if (item['isConsonant'] == true) debugPrint('      - Consonant');
      if (item['isVowel'] == true) debugPrint('      - Vowel');
      if (item['isMatra'] == true) debugPrint('      - Matra (vowel sign)');
      if (item['isVirama'] == true) debugPrint('      - Virama (halant)');
      if (item['isNukta'] == true) debugPrint('      - Nukta');
      if (item['isAnusvara'] == true) debugPrint('      - Anusvara');
      if (item['isVisarga'] == true) debugPrint('      - Visarga');
    }
  }
}
