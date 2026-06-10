// =========================================================================
// ⌨️ TYPING CONTROLLER - UNIFIED TYPING LOGIC FOR ALL LANGUAGES
// =========================================================================
//
// Supports atomic character-based typing for Indic scripts (Hindi/Gujarati)
// Each Unicode code point is treated as a separate keystroke.
//
// Example: "નમસ્તે" → ["ન", "મ", "સ", "્", "ત", "ે"]
//
// =========================================================================

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:characters/characters.dart';
import 'package:typingtutor/services/atomic_typing_service.dart';
import 'package:typingtutor/services/indic_key_mappings.dart';

/// Unified controller for handling typing input across all languages
/// Handles physical key mapping, character counting, and finger highlighting
class TypingController extends GetxController {
  // =========================================================================
  // 📊 OBSERVABLE STATE
  // =========================================================================

  /// Current language code (en, hi, gu)
  final _currentLanguage = 'en'.obs;

  /// Is shift currently pressed
  final _isShiftPressed = false.obs;

  /// Current highlighted finger
  final _currentFinger = Rxn<String>();

  /// Last pressed physical key (for finger highlighting)
  final _lastPhysicalKey = ''.obs;

  // =========================================================================
  // 🔍 GETTERS
  // =========================================================================

  String get currentLanguage => _currentLanguage.value;
  bool get isShiftPressed => _isShiftPressed.value;
  String? get currentFinger => _currentFinger.value;
  String get lastPhysicalKey => _lastPhysicalKey.value;

  // =========================================================================
  // 🗺️ PHYSICAL KEY TO INDIC CHARACTER MAPPING
  // =========================================================================

  /// Hindi Inscript mapping: Physical English key → Hindi character
  /// Based on standard Inscript keyboard layout
  static const Map<String, String> _hindiKeyMap = {
    // Row 1 (Top row - QWERTY)
    'q': 'ौ',
    'w': 'ै',
    'e': 'ा',
    'r': 'ी',
    't': 'ू',
    'y': 'ब',
    'u': 'ह',
    'i': 'ग',
    'o': 'द',
    'p': 'ज',
    '[': 'ड',
    ']': '़',
    '\\': 'ॉ',

    // Row 2 (Home row - ASDF)
    'a': 'ो',
    's': 'े',
    'd': '्',
    'f': 'ि',
    'g': 'ु',
    'h': 'प',
    'j': 'र',
    'k': 'क',
    'l': 'त',
    ';': 'च',
    '\'': 'ट',

    // Row 3 (Bottom row - ZXCV)
    'z': 'ॅ',
    'x': 'ं',
    'c': 'म',
    'v': 'न',
    'b': 'व',
    'n': 'ल',
    'm': 'स',
    ',': ',',
    '.': '.',
    '/': 'य',
  };

  /// Hindi Shift mapping: Physical English key (with shift) → Hindi character
  static const Map<String, String> _hindiShiftKeyMap = {
    // Row 1 (Top row - QWERTY with Shift)
    'Q': 'औ',
    'W': 'ऐ',
    'E': 'आ',
    'R': 'ई',
    'T': 'ऊ',
    'Y': 'भ',
    'U': 'ङ',
    'I': 'घ',
    'O': 'ध',
    'P': 'झ',
    '{': 'ढ',
    '}': 'ञ',
    '|': 'ऑ',

    // Row 2 (Home row - ASDF with Shift)
    'A': 'ओ',
    'S': 'ए',
    'D': 'अ',
    'F': 'इ',
    'G': 'उ',
    'H': 'फ',
    'J': 'ऱ',
    'K': 'ख',
    'L': 'थ',
    ':': 'छ',
    '"': 'ठ',

    // Row 3 (Bottom row - ZXCV with Shift)
    'Z': 'ऋ',
    'X': 'ः',
    'C': 'ष',
    'V': 'श',
    'B': 'ण',
    'N': 'ळ',
    'M': 'ऽ',
    '<': '।',
    '>': '॥',
    '?': '?',
  };

  /// Gujarati Inscript mapping: Physical English key → Gujarati character
  static const Map<String, String> _gujaratiKeyMap = {
    // Row 1 (Top row - QWERTY)
    'q': 'ૌ',
    'w': 'ૈ',
    'e': 'ા',
    'r': 'ી',
    't': 'ૂ',
    'y': 'બ',
    'u': 'હ',
    'i': 'ગ',
    'o': 'દ',
    'p': 'જ',
    '[': 'ડ',
    ']': '઼',
    '\\': 'ૉ',

    // Row 2 (Home row - ASDF)
    'a': 'ો',
    's': 'ે',
    'd': '્',
    'f': 'િ',
    'g': 'ુ',
    'h': 'પ',
    'j': 'ર',
    'k': 'ક',
    'l': 'ત',
    ';': 'ચ',
    '\'': 'ટ',

    // Row 3 (Bottom row - ZXCV)
    'z': 'ૅ',
    'x': 'ઃ',
    'c': 'મ',
    'v': 'ન',
    'b': 'વ',
    'n': 'લ',
    'm': 'સ',
    ',': ',',
    '.': '.',
    '/': 'ય',
  };

  /// Gujarati Shift mapping: Physical English key (with shift) → Gujarati character
  static const Map<String, String> _gujaratiShiftKeyMap = {
    // Row 1 (Top row - QWERTY with Shift)
    'Q': 'ઔ',
    'W': 'ઐ',
    'E': 'આ',
    'R': 'ઈ',
    'T': 'ઊ',
    'Y': 'ભ',
    'U': 'ઙ',
    'I': 'ઘ',
    'O': 'ધ',
    'P': 'ઝ',
    '{': 'ઢ',
    '}': 'ઞ',
    '|': 'ઑ',

    // Row 2 (Home row - ASDF with Shift)
    'A': 'ઓ',
    'S': 'એ',
    'D': 'અ',
    'F': 'ઇ',
    'G': 'ઉ',
    'H': 'ફ',
    'J': 'ર',
    'K': 'ખ',
    'L': 'થ',
    ':': 'છ',
    '"': 'ઠ',

    // Row 3 (Bottom row - ZXCV with Shift)
    'Z': 'ઋ',
    'X': 'ઁ',
    'C': 'ષ',
    'V': 'શ',
    'B': 'ણ',
    'N': 'ળ',
    'M': 'ઽ',
    '<': '।',
    '>': '॥',
    '?': '?',
  };

  // =========================================================================
  // 👆 FINGER MAPPING (Based on Physical Key Position)
  // =========================================================================

  /// Map physical key to finger name (works for all languages)
  static const Map<String, String> _fingerMap = {
    // Left Pinky
    'q': 'left_pinky',
    'a': 'left_pinky',
    'z': 'left_pinky',
    'Q': 'left_pinky',
    'A': 'left_pinky',
    'Z': 'left_pinky',
    '`': 'left_pinky',
    '~': 'left_pinky',
    '1': 'left_pinky',
    '!': 'left_pinky',

    // Left Ring
    'w': 'left_ring',
    's': 'left_ring',
    'x': 'left_ring',
    'W': 'left_ring',
    'S': 'left_ring',
    'X': 'left_ring',
    '2': 'left_ring',
    '@': 'left_ring',

    // Left Middle
    'e': 'left_middle',
    'd': 'left_middle',
    'c': 'left_middle',
    'E': 'left_middle',
    'D': 'left_middle',
    'C': 'left_middle',
    '3': 'left_middle',
    '#': 'left_middle',

    // Left Index (includes reach keys)
    'r': 'left_index',
    'f': 'left_index',
    'v': 'left_index',
    't': 'left_index',
    'g': 'left_index',
    'b': 'left_index',
    'R': 'left_index',
    'F': 'left_index',
    'V': 'left_index',
    'T': 'left_index',
    'G': 'left_index',
    'B': 'left_index',
    '4': 'left_index',
    '5': 'left_index',
    r'$': 'left_index',
    '%': 'left_index',

    // Right Index (includes reach keys)
    'y': 'right_index',
    'h': 'right_index',
    'n': 'right_index',
    'u': 'right_index',
    'j': 'right_index',
    'm': 'right_index',
    'Y': 'right_index',
    'H': 'right_index',
    'N': 'right_index',
    'U': 'right_index',
    'J': 'right_index',
    'M': 'right_index',
    '6': 'right_index',
    '7': 'right_index',
    '^': 'right_index',
    '&': 'right_index',

    // Right Middle
    'i': 'right_middle',
    'k': 'right_middle',
    ',': 'right_middle',
    'I': 'right_middle',
    'K': 'right_middle',
    '<': 'right_middle',
    '8': 'right_middle',
    '*': 'right_middle',

    // Right Ring
    'o': 'right_ring',
    'l': 'right_ring',
    '.': 'right_ring',
    'O': 'right_ring',
    'L': 'right_ring',
    '>': 'right_ring',
    '9': 'right_ring',
    '(': 'right_ring',

    // Right Pinky
    'p': 'right_pinky',
    ';': 'right_pinky',
    '/': 'right_pinky',
    'P': 'right_pinky',
    ':': 'right_pinky',
    '?': 'right_pinky',
    '[': 'right_pinky',
    ']': 'right_pinky',
    '\\': 'right_pinky',
    '{': 'right_pinky',
    '}': 'right_pinky',
    '|': 'right_pinky',
    '\'': 'right_pinky',
    '"': 'right_pinky',
    '0': 'right_pinky',
    ')': 'right_pinky',
    '-': 'right_pinky',
    '_': 'right_pinky',
    '=': 'right_pinky',
    '+': 'right_pinky',

    // Thumbs (space)
    ' ': 'thumb',
  };

  // =========================================================================
  // 🔄 LANGUAGE METHODS
  // =========================================================================

  /// Set current language
  void setLanguage(String languageCode) {
    _currentLanguage.value = languageCode;
    update();
  }

  /// Set shift state
  void setShift(bool pressed) {
    _isShiftPressed.value = pressed;
    update();
  }

  // =========================================================================
  // ⌨️ KEY PROCESSING METHODS
  // =========================================================================

  /// Process a raw keyboard event and return the mapped character
  /// Returns null if the key should be ignored
  ProcessedKeyResult? processKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return null;

    final logicalKey = event.logicalKey;

    // Handle special keys
    if (logicalKey == LogicalKeyboardKey.space) {
      _updateFingerHighlight(' ');
      return ProcessedKeyResult(
        physicalKey: ' ',
        mappedChar: ' ',
        isSpecialKey: false,
        specialKeyType: null,
        finger: 'thumb',
      );
    }

    if (logicalKey == LogicalKeyboardKey.backspace) {
      return ProcessedKeyResult(
        physicalKey: 'BACKSPACE',
        mappedChar: '',
        isSpecialKey: true,
        specialKeyType: SpecialKeyType.backspace,
        finger: null,
      );
    }

    if (logicalKey == LogicalKeyboardKey.shiftLeft ||
        logicalKey == LogicalKeyboardKey.shiftRight) {
      setShift(true);
      return ProcessedKeyResult(
        physicalKey: 'SHIFT',
        mappedChar: '',
        isSpecialKey: true,
        specialKeyType: SpecialKeyType.shift,
        finger: 'left_pinky',
      );
    }

    if (logicalKey == LogicalKeyboardKey.tab ||
        logicalKey == LogicalKeyboardKey.capsLock ||
        logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.escape) {
      return ProcessedKeyResult(
        physicalKey: logicalKey.keyLabel,
        mappedChar: '',
        isSpecialKey: true,
        specialKeyType: SpecialKeyType.modifier,
        finger: null,
      );
    }

    // Get the physical character from the event
    String? physicalChar = event.character;

    // If no character, try keyLabel
    if (physicalChar == null || physicalChar.isEmpty) {
      physicalChar = logicalKey.keyLabel;
      if (physicalChar.isEmpty) return null;
    }

    // Store physical key for finger highlighting
    _lastPhysicalKey.value = physicalChar;

    // Get finger for physical key
    final finger = getFingerForKey(physicalChar);
    _updateFingerHighlight(physicalChar);

    // Map to target language character
    final mappedChar = getMappedCharacter(physicalChar);

    return ProcessedKeyResult(
      physicalKey: physicalChar,
      mappedChar: mappedChar,
      isSpecialKey: false,
      specialKeyType: null,
      finger: finger,
    );
  }

  /// Get the mapped character for a physical key based on current language
  String getMappedCharacter(String physicalKey) {
    switch (_currentLanguage.value) {
      case 'hi':
        // Check shift first
        if (_isShiftPressed.value) {
          // For shift, check uppercase version
          final shiftChar = _hindiShiftKeyMap[physicalKey.toUpperCase()];
          if (shiftChar != null) return shiftChar;
        }
        // Check normal map
        final hindiChar = _hindiKeyMap[physicalKey.toLowerCase()];
        return hindiChar ?? physicalKey;

      case 'gu':
        // Check shift first
        if (_isShiftPressed.value) {
          final shiftChar = _gujaratiShiftKeyMap[physicalKey.toUpperCase()];
          if (shiftChar != null) return shiftChar;
        }
        // Check normal map
        final gujaratiChar = _gujaratiKeyMap[physicalKey.toLowerCase()];
        return gujaratiChar ?? physicalKey;

      case 'en':
      default:
        // English: return as-is
        return physicalKey;
    }
  }

  /// Get finger name for a physical key
  String? getFingerForKey(String physicalKey) {
    return _fingerMap[physicalKey] ?? _fingerMap[physicalKey.toLowerCase()];
  }

  /// Update finger highlight
  void _updateFingerHighlight(String physicalKey) {
    _currentFinger.value = getFingerForKey(physicalKey);
    update();
  }

  /// Clear finger highlight
  void clearFingerHighlight() {
    _currentFinger.value = null;
    update();
  }

  // =========================================================================
  // 📊 CHARACTER COUNTING (Unicode Safe - Atomic Units)
  // =========================================================================

  /// Count characters using atomic units (handles combining characters)
  /// This properly counts Hindi matras and Gujarati combined letters
  /// Each keystroke counts as 1 unit
  int countCharacters(String text) {
    // For Indic scripts, use atomic units (code points)
    // For English, use standard character count
    switch (_currentLanguage.value) {
      case 'hi':
      case 'gu':
        return AtomicTypingService.countAtomicUnits(
          text,
          _currentLanguage.value,
        );
      case 'en':
      default:
        return text.length;
    }
  }

  /// Count characters for WPM calculation
  /// Uses atomic units for accurate counting of Indic scripts
  int countCharactersForWpm(String text) {
    return countCharacters(text);
  }

  /// Calculate WPM from correct character count and elapsed seconds
  int calculateWpm(int correctChars, int elapsedSeconds) {
    if (elapsedSeconds <= 0) return 0;
    final minutes = elapsedSeconds / 60.0;
    // Standard: 5 characters = 1 word
    return ((correctChars / 5) / minutes).round();
  }

  /// Calculate accuracy percentage
  double calculateAccuracy(int correct, int incorrect) {
    final total = correct + incorrect;
    if (total == 0) return 100.0;
    return (correct / total * 100).clamp(0.0, 100.0);
  }

  // =========================================================================
  // 🔍 CHARACTER COMPARISON (Unicode Safe)
  // =========================================================================

  /// Compare two characters considering language-specific rules
  bool compareCharacters(String input, String expected, String languageCode) {
    if (input.isEmpty || expected.isEmpty) return false;

    switch (languageCode) {
      case 'en':
        // English: case-insensitive
        return input.toLowerCase() == expected.toLowerCase();

      case 'hi':
      case 'gu':
        // Indic scripts: exact match
        if (input == expected) return true;

        // Compare grapheme clusters
        final inputChars = input.characters;
        final expectedChars = expected.characters;

        if (inputChars.isEmpty || expectedChars.isEmpty) return false;

        // Compare first grapheme cluster
        return inputChars.first == expectedChars.first;

      default:
        return input == expected;
    }
  }

  // =========================================================================
  // � ATOMIC CHARACTER TYPING (Hindi/Gujarati)
  // =========================================================================

  /// Split text into atomic typing units
  /// Each unit represents a single keystroke required
  ///
  /// Example:
  /// "નમસ્તે" → ["ન", "મ", "સ", "્", "ત", "ે"]
  /// "नमस्ते" → ["न", "म", "स", "्", "त", "े"]
  List<String> splitIntoAtomicUnits(String text) {
    return AtomicTypingService.splitIntoAtomicUnits(
      text,
      _currentLanguage.value,
    );
  }

  /// Compare atomic units for typing
  bool compareAtomicUnits(String input, String expected) {
    return AtomicTypingService.compareAtomicUnits(
      input,
      expected,
      _currentLanguage.value,
    );
  }

  /// Count atomic units for WPM calculation
  int countAtomicUnits(String text) {
    return AtomicTypingService.countAtomicUnits(text, _currentLanguage.value);
  }

  /// Calculate WPM using atomic units
  int calculateWpmAtomic(int correctUnits, int elapsedSeconds) {
    return AtomicTypingService.calculateWpm(correctUnits, elapsedSeconds);
  }

  /// Get the physical key that produces an Indic character
  /// Used for finger highlighting with Indic scripts
  String? getPhysicalKeyForChar(String char) {
    return IndicKeyMappings.getPhysicalKeyForChar(char, _currentLanguage.value);
  }

  /// Get finger type for an Indic character
  /// First converts to physical key, then gets finger
  String? getFingerForIndicChar(String char) {
    final finger = PhysicalKeyFingerMapping.getFingerForIndicChar(
      char,
      _currentLanguage.value,
    );
    return PhysicalKeyFingerMapping.getFingerName(finger);
  }

  /// Check if a character requires shift key
  bool charRequiresShift(String char) {
    return IndicKeyMappings.requiresShift(char, _currentLanguage.value);
  }

  /// Get expected physical key for a character (for highlighting)
  /// Works for both English and Indic scripts
  String? getExpectedPhysicalKey(String char) {
    switch (_currentLanguage.value) {
      case 'hi':
      case 'gu':
        return IndicKeyMappings.getPhysicalKeyForChar(
          char,
          _currentLanguage.value,
        );
      case 'en':
      default:
        return char;
    }
  }

  /// Update finger highlight based on expected character
  /// This handles the conversion from Indic char → physical key → finger
  void highlightFingerForChar(String char) {
    String? physicalKey;

    switch (_currentLanguage.value) {
      case 'hi':
      case 'gu':
        physicalKey = getPhysicalKeyForChar(char);
        break;
      case 'en':
      default:
        physicalKey = char;
        break;
    }

    if (physicalKey != null) {
      _updateFingerHighlight(physicalKey);
    }
  }

  // =========================================================================
  // �🖼️ HAND IMAGE PATHS
  // =========================================================================

  /// Get left hand image path for current finger
  String getLeftHandImage() {
    switch (_currentFinger.value) {
      case 'left_pinky':
        return 'assets/images/hand/left_pinky.png';
      case 'left_ring':
        return 'assets/images/hand/left_ring.png';
      case 'left_middle':
        return 'assets/images/hand/left_middle.png';
      case 'left_index':
        return 'assets/images/hand/left_index.png';
      case 'thumb':
        return 'assets/images/hand/left_thumb.png';
      default:
        return 'assets/images/hand/left_default.png';
    }
  }

  /// Get right hand image path for current finger
  String getRightHandImage() {
    switch (_currentFinger.value) {
      case 'right_pinky':
        return 'assets/images/hand/right_pinky.png';
      case 'right_ring':
        return 'assets/images/hand/right_ring.png';
      case 'right_middle':
        return 'assets/images/hand/right_middle.png';
      case 'right_index':
        return 'assets/images/hand/right_index.png';
      case 'thumb':
        return 'assets/images/hand/right_thumb.png';
      default:
        return 'assets/images/hand/right_default.png';
    }
  }

  /// Check if current finger is on left hand
  bool isLeftHandFinger() {
    final finger = _currentFinger.value;
    if (finger == null) return false;
    return finger.startsWith('left') || finger == 'thumb';
  }

  /// Check if current finger is on right hand
  bool isRightHandFinger() {
    final finger = _currentFinger.value;
    if (finger == null) return false;
    return finger.startsWith('right') || finger == 'thumb';
  }

  // =========================================================================
  // 🔄 LIFECYCLE
  // =========================================================================

  @override
  void onInit() {
    super.onInit();
    _currentLanguage.value = 'en';
  }

  /// Reset controller state
  void reset() {
    _currentLanguage.value = 'en';
    _isShiftPressed.value = false;
    _currentFinger.value = null;
    _lastPhysicalKey.value = '';
    update();
  }
}

// =========================================================================
// 📦 RESULT CLASSES
// =========================================================================

/// Result of processing a key event
class ProcessedKeyResult {
  final String physicalKey;
  final String mappedChar;
  final bool isSpecialKey;
  final SpecialKeyType? specialKeyType;
  final String? finger;

  ProcessedKeyResult({
    required this.physicalKey,
    required this.mappedChar,
    required this.isSpecialKey,
    this.specialKeyType,
    this.finger,
  });
}

/// Types of special keys
enum SpecialKeyType { backspace, shift, modifier, enter, tab }
