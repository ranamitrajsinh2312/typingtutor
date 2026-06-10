// =========================================================================
// 🗺️ INDIC KEY MAPPINGS - PHYSICAL KEY ↔ INDIC CHARACTER
// =========================================================================
//
// Complete bidirectional mappings for Hindi and Gujarati (Inscript layout)
//
// Usage:
// 1. Physical key → Indic character (for typing input)
// 2. Indic character → Physical key (for finger highlighting)
//
// =========================================================================

/// Comprehensive key mappings for Indic scripts
class IndicKeyMappings {
  // =========================================================================
  // 🇮🇳 HINDI (DEVANAGARI) - INSCRIPT LAYOUT
  // =========================================================================

  /// Hindi: Physical Key → Devanagari Character (Normal)
  static const Map<String, String> hindiKeyMap = {
    // Row 1 (Top row - QWERTY)
    '`': 'ॊ',
    '1': '१',
    '2': '२',
    '3': '३',
    '4': '४',
    '5': '५',
    '6': '६',
    '7': '७',
    '8': '८',
    '9': '९',
    '0': '०',
    '-': '-',
    '=': 'ृ',

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
    'd': '्', // Virama (halant)
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
    'x': 'ं', // Anusvara
    'c': 'म',
    'v': 'न',
    'b': 'व',
    'n': 'ल',
    'm': 'स',
    ',': ',',
    '.': '.',
    '/': 'य',

    // Space
    ' ': ' ',
  };

  /// Hindi: Physical Key → Devanagari Character (with Shift)
  static const Map<String, String> hindiShiftKeyMap = {
    // Row 1 (Top row with Shift)
    '~': 'ऒ',
    '!': 'ऍ',
    '@': '॔',
    '#': '्र',
    '\$': 'र्',
    '%': 'ज्ञ',
    '^': 'त्र',
    '&': 'क्ष',
    '*': 'श्र',
    '(': '(',
    ')': ')',
    '_': 'ः', // Visarga
    '+': 'ॄ',

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

    // Row 2 (Home row with Shift)
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

    // Row 3 (Bottom row with Shift)
    'Z': 'ऋ',
    'X': 'ँ', // Chandrabindu
    'C': 'ष',
    'V': 'श',
    'B': 'ण',
    'N': 'ळ',
    'M': 'ऽ',
    '<': '।', // Danda
    '>': '॥', // Double Danda
    '?': 'य़',
  };

  /// Hindi: Devanagari Character → Physical Key (Reverse mapping for finger highlight)
  static Map<String, String> get hindiReverseKeyMap {
    final Map<String, String> reverse = {};
    hindiKeyMap.forEach((key, value) {
      reverse[value] = key;
    });
    hindiShiftKeyMap.forEach((key, value) {
      reverse[value] = key;
    });
    return reverse;
  }

  // =========================================================================
  // 🇮🇳 GUJARATI - INSCRIPT LAYOUT
  // =========================================================================

  /// Gujarati: Physical Key → Gujarati Character (Normal)
  static const Map<String, String> gujaratiKeyMap = {
    // Row 1 (Top row - QWERTY)
    '`': 'ૉ',
    '1': '૧',
    '2': '૨',
    '3': '૩',
    '4': '૪',
    '5': '૫',
    '6': '૬',
    '7': '૭',
    '8': '૮',
    '9': '૯',
    '0': '૦',
    '-': '-',
    '=': 'ૃ',

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
    'd': '્', // Virama (halant)
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
    'x': 'ં', // Anusvara
    'c': 'મ',
    'v': 'ન',
    'b': 'વ',
    'n': 'લ',
    'm': 'સ',
    ',': ',',
    '.': '.',
    '/': 'ય',

    // Space
    ' ': ' ',
  };

  /// Gujarati: Physical Key → Gujarati Character (with Shift)
  static const Map<String, String> gujaratiShiftKeyMap = {
    // Row 1 (Top row with Shift)
    '~': 'ઑ',
    '!': 'ઍ',
    '@': '૰',
    '#': '્ર',
    '\$': 'ર્',
    '%': 'જ્ઞ',
    '^': 'ત્ર',
    '&': 'ક્ષ',
    '*': 'શ્ર',
    '(': '(',
    ')': ')',
    '_': 'ઃ', // Visarga
    '+': 'ૄ',

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

    // Row 2 (Home row with Shift)
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

    // Row 3 (Bottom row with Shift)
    'Z': 'ઋ',
    'X': 'ઁ', // Chandrabindu
    'C': 'ષ',
    'V': 'શ',
    'B': 'ણ',
    'N': 'ળ',
    'M': 'ઽ',
    '<': '।', // Danda
    '>': '॥', // Double Danda
    '?': 'ય઼',
  };

  /// Gujarati: Gujarati Character → Physical Key (Reverse mapping for finger highlight)
  static Map<String, String> get gujaratiReverseKeyMap {
    final Map<String, String> reverse = {};
    gujaratiKeyMap.forEach((key, value) {
      reverse[value] = key;
    });
    gujaratiShiftKeyMap.forEach((key, value) {
      reverse[value] = key;
    });
    return reverse;
  }

  // =========================================================================
  // 🔧 UTILITY METHODS
  // =========================================================================

  /// Get the physical key for an Indic character
  /// Returns null if not found
  static String? getPhysicalKeyForChar(String char, String languageCode) {
    if (char.isEmpty) return null;

    switch (languageCode) {
      case 'hi':
        return hindiReverseKeyMap[char];
      case 'gu':
        return gujaratiReverseKeyMap[char];
      case 'en':
        return char;
      default:
        return char;
    }
  }

  /// Get the mapped character for a physical key
  static String getMappedCharacter(
    String physicalKey,
    String languageCode,
    bool isShiftPressed,
  ) {
    switch (languageCode) {
      case 'hi':
        if (isShiftPressed) {
          final shiftChar = hindiShiftKeyMap[physicalKey.toUpperCase()];
          if (shiftChar != null) return shiftChar;
        }
        return hindiKeyMap[physicalKey.toLowerCase()] ?? physicalKey;

      case 'gu':
        if (isShiftPressed) {
          final shiftChar = gujaratiShiftKeyMap[physicalKey.toUpperCase()];
          if (shiftChar != null) return shiftChar;
        }
        return gujaratiKeyMap[physicalKey.toLowerCase()] ?? physicalKey;

      case 'en':
      default:
        return physicalKey;
    }
  }

  /// Check if a character requires shift key
  static bool requiresShift(String char, String languageCode) {
    switch (languageCode) {
      case 'hi':
        return hindiShiftKeyMap.containsValue(char);
      case 'gu':
        return gujaratiShiftKeyMap.containsValue(char);
      case 'en':
        // English: check if uppercase letter
        if (char.isEmpty) return false;
        final codeUnit = char.codeUnitAt(0);
        return codeUnit >= 65 && codeUnit <= 90;
      default:
        return false;
    }
  }

  /// Get all characters available for a language
  static Set<String> getAllCharacters(String languageCode) {
    final Set<String> chars = {};

    switch (languageCode) {
      case 'hi':
        chars.addAll(hindiKeyMap.values);
        chars.addAll(hindiShiftKeyMap.values);
        break;
      case 'gu':
        chars.addAll(gujaratiKeyMap.values);
        chars.addAll(gujaratiShiftKeyMap.values);
        break;
    }

    return chars;
  }
}

// =========================================================================
// 👆 FINGER MAPPING DATA (Physical Key Based)
// =========================================================================

/// Finger type for each physical key
enum FingerType {
  leftPinky,
  leftRing,
  leftMiddle,
  leftIndex,
  rightIndex,
  rightMiddle,
  rightRing,
  rightPinky,
  thumb,
}

/// Physical key to finger mapping (works for ALL languages)
class PhysicalKeyFingerMapping {
  /// Map physical key to finger (based on touch typing)
  static const Map<String, FingerType> fingerMap = {
    // Left Pinky
    '`': FingerType.leftPinky,
    '~': FingerType.leftPinky,
    '1': FingerType.leftPinky,
    '!': FingerType.leftPinky,
    'q': FingerType.leftPinky,
    'Q': FingerType.leftPinky,
    'a': FingerType.leftPinky,
    'A': FingerType.leftPinky,
    'z': FingerType.leftPinky,
    'Z': FingerType.leftPinky,

    // Left Ring
    '2': FingerType.leftRing,
    '@': FingerType.leftRing,
    'w': FingerType.leftRing,
    'W': FingerType.leftRing,
    's': FingerType.leftRing,
    'S': FingerType.leftRing,
    'x': FingerType.leftRing,
    'X': FingerType.leftRing,

    // Left Middle
    '3': FingerType.leftMiddle,
    '#': FingerType.leftMiddle,
    'e': FingerType.leftMiddle,
    'E': FingerType.leftMiddle,
    'd': FingerType.leftMiddle,
    'D': FingerType.leftMiddle,
    'c': FingerType.leftMiddle,
    'C': FingerType.leftMiddle,

    // Left Index (includes reach keys)
    '4': FingerType.leftIndex,
    '\$': FingerType.leftIndex,
    '5': FingerType.leftIndex,
    '%': FingerType.leftIndex,
    'r': FingerType.leftIndex,
    'R': FingerType.leftIndex,
    't': FingerType.leftIndex,
    'T': FingerType.leftIndex,
    'f': FingerType.leftIndex,
    'F': FingerType.leftIndex,
    'g': FingerType.leftIndex,
    'G': FingerType.leftIndex,
    'v': FingerType.leftIndex,
    'V': FingerType.leftIndex,
    'b': FingerType.leftIndex,
    'B': FingerType.leftIndex,

    // Right Index (includes reach keys)
    '6': FingerType.rightIndex,
    '^': FingerType.rightIndex,
    '7': FingerType.rightIndex,
    '&': FingerType.rightIndex,
    'y': FingerType.rightIndex,
    'Y': FingerType.rightIndex,
    'u': FingerType.rightIndex,
    'U': FingerType.rightIndex,
    'h': FingerType.rightIndex,
    'H': FingerType.rightIndex,
    'j': FingerType.rightIndex,
    'J': FingerType.rightIndex,
    'n': FingerType.rightIndex,
    'N': FingerType.rightIndex,
    'm': FingerType.rightIndex,
    'M': FingerType.rightIndex,

    // Right Middle
    '8': FingerType.rightMiddle,
    '*': FingerType.rightMiddle,
    'i': FingerType.rightMiddle,
    'I': FingerType.rightMiddle,
    'k': FingerType.rightMiddle,
    'K': FingerType.rightMiddle,
    ',': FingerType.rightMiddle,
    '<': FingerType.rightMiddle,

    // Right Ring
    '9': FingerType.rightRing,
    '(': FingerType.rightRing,
    'o': FingerType.rightRing,
    'O': FingerType.rightRing,
    'l': FingerType.rightRing,
    'L': FingerType.rightRing,
    '.': FingerType.rightRing,
    '>': FingerType.rightRing,

    // Right Pinky
    '0': FingerType.rightPinky,
    ')': FingerType.rightPinky,
    '-': FingerType.rightPinky,
    '_': FingerType.rightPinky,
    '=': FingerType.rightPinky,
    '+': FingerType.rightPinky,
    'p': FingerType.rightPinky,
    'P': FingerType.rightPinky,
    '[': FingerType.rightPinky,
    '{': FingerType.rightPinky,
    ']': FingerType.rightPinky,
    '}': FingerType.rightPinky,
    '\\': FingerType.rightPinky,
    '|': FingerType.rightPinky,
    ';': FingerType.rightPinky,
    ':': FingerType.rightPinky,
    '\'': FingerType.rightPinky,
    '"': FingerType.rightPinky,
    '/': FingerType.rightPinky,
    '?': FingerType.rightPinky,

    // Thumb
    ' ': FingerType.thumb,
  };

  /// Get finger type for a physical key
  static FingerType? getFingerForPhysicalKey(String physicalKey) {
    return fingerMap[physicalKey] ?? fingerMap[physicalKey.toLowerCase()];
  }

  /// Get finger type for an Indic character
  /// First converts to physical key, then gets finger
  static FingerType? getFingerForIndicChar(String char, String languageCode) {
    final physicalKey = IndicKeyMappings.getPhysicalKeyForChar(
      char,
      languageCode,
    );
    if (physicalKey == null) return null;
    return getFingerForPhysicalKey(physicalKey);
  }

  /// Get finger name as string
  static String getFingerName(FingerType? finger) {
    switch (finger) {
      case FingerType.leftPinky:
        return 'left_pinky';
      case FingerType.leftRing:
        return 'left_ring';
      case FingerType.leftMiddle:
        return 'left_middle';
      case FingerType.leftIndex:
        return 'left_index';
      case FingerType.rightIndex:
        return 'right_index';
      case FingerType.rightMiddle:
        return 'right_middle';
      case FingerType.rightRing:
        return 'right_ring';
      case FingerType.rightPinky:
        return 'right_pinky';
      case FingerType.thumb:
        return 'thumb';
      default:
        return 'unknown';
    }
  }

  /// Check if finger is on left hand
  static bool isLeftHand(FingerType? finger) {
    if (finger == null) return false;
    return finger == FingerType.leftPinky ||
        finger == FingerType.leftRing ||
        finger == FingerType.leftMiddle ||
        finger == FingerType.leftIndex ||
        finger == FingerType.thumb;
  }

  /// Check if finger is on right hand
  static bool isRightHand(FingerType? finger) {
    if (finger == null) return false;
    return finger == FingerType.rightPinky ||
        finger == FingerType.rightRing ||
        finger == FingerType.rightMiddle ||
        finger == FingerType.rightIndex ||
        finger == FingerType.thumb;
  }

  /// Get hand image path for finger
  static String getLeftHandImage(FingerType? finger) {
    final fingerName = getFingerName(finger);
    if (fingerName.startsWith('left') || fingerName == 'thumb') {
      return 'assets/images/hand/left_$fingerName.png';
    }
    return 'assets/images/hand/left_default.png';
  }

  /// Get right hand image path for finger
  static String getRightHandImage(FingerType? finger) {
    final fingerName = getFingerName(finger);
    if (fingerName.startsWith('right') || fingerName == 'thumb') {
      return 'assets/images/hand/right_$fingerName.png';
    }
    return 'assets/images/hand/right_default.png';
  }
}
