// =========================================================================
// 👆 FINGER MAPPING DATA - FINGER POSITION FOR ALL LANGUAGES
// =========================================================================

/// Finger types for typing
enum FingerType {
  leftPinky,
  leftRing,
  leftMiddle,
  leftIndex,
  leftThumb,
  rightThumb,
  rightIndex,
  rightMiddle,
  rightRing,
  rightPinky,
}

/// Finger mapping data for all supported languages
class FingerMappingData {
  // =========================================================================
  // 🇺🇸 ENGLISH FINGER MAPPING
  // =========================================================================

  /// English keyboard finger mapping (QWERTY layout)
  static const Map<String, FingerType> englishFingerMap = {
    // Left Pinky
    'q': FingerType.leftPinky,
    'Q': FingerType.leftPinky,
    'a': FingerType.leftPinky,
    'A': FingerType.leftPinky,
    'z': FingerType.leftPinky,
    'Z': FingerType.leftPinky,
    'TAB': FingerType.leftPinky,
    'CAPS': FingerType.leftPinky,
    'SHIFT': FingerType.leftPinky,

    // Left Ring
    'w': FingerType.leftRing,
    'W': FingerType.leftRing,
    's': FingerType.leftRing,
    'S': FingerType.leftRing,
    'x': FingerType.leftRing,
    'X': FingerType.leftRing,

    // Left Middle
    'e': FingerType.leftMiddle,
    'E': FingerType.leftMiddle,
    'd': FingerType.leftMiddle,
    'D': FingerType.leftMiddle,
    'c': FingerType.leftMiddle,
    'C': FingerType.leftMiddle,

    // Left Index (includes T, G, B for home row reach)
    'r': FingerType.leftIndex,
    'R': FingerType.leftIndex,
    'f': FingerType.leftIndex,
    'F': FingerType.leftIndex,
    'v': FingerType.leftIndex,
    'V': FingerType.leftIndex,
    't': FingerType.leftIndex,
    'T': FingerType.leftIndex,
    'g': FingerType.leftIndex,
    'G': FingerType.leftIndex,
    'b': FingerType.leftIndex,
    'B': FingerType.leftIndex,

    // Right Index (includes Y, H, N for home row reach)
    'y': FingerType.rightIndex,
    'Y': FingerType.rightIndex,
    'h': FingerType.rightIndex,
    'H': FingerType.rightIndex,
    'n': FingerType.rightIndex,
    'N': FingerType.rightIndex,
    'u': FingerType.rightIndex,
    'U': FingerType.rightIndex,
    'j': FingerType.rightIndex,
    'J': FingerType.rightIndex,
    'm': FingerType.rightIndex,
    'M': FingerType.rightIndex,

    // Right Middle
    'i': FingerType.rightMiddle,
    'I': FingerType.rightMiddle,
    'k': FingerType.rightMiddle,
    'K': FingerType.rightMiddle,
    ',': FingerType.rightMiddle,

    // Right Ring
    'o': FingerType.rightRing,
    'O': FingerType.rightRing,
    'l': FingerType.rightRing,
    'L': FingerType.rightRing,
    '.': FingerType.rightRing,

    // Right Pinky
    'p': FingerType.rightPinky,
    'P': FingerType.rightPinky,
    ';': FingerType.rightPinky,
    ':': FingerType.rightPinky,
    '/': FingerType.rightPinky,
    '?': FingerType.rightPinky,
    'ENTER': FingerType.rightPinky,
    '[': FingerType.rightPinky,
    ']': FingerType.rightPinky,
    '\\': FingerType.rightPinky,
    '\'': FingerType.rightPinky,

    // Thumbs for space
    ' ': FingerType.rightThumb,
    'SPACE': FingerType.rightThumb,
  };

  // =========================================================================
  // 🇮🇳 HINDI FINGER MAPPING (INSCRIPT LAYOUT)
  // =========================================================================

  /// Hindi Inscript keyboard finger mapping
  static const Map<String, FingerType> hindiFingerMap = {
    // Left Pinky - Row 1 (Top)
    'TAB': FingerType.leftPinky,
    'ौ': FingerType.leftPinky,

    // Left Ring - Row 1
    'ै': FingerType.leftRing,

    // Left Middle - Row 1
    'ा': FingerType.leftMiddle,

    // Left Index - Row 1 (includes reach keys)
    'ी': FingerType.leftIndex,
    'ू': FingerType.leftIndex,
    'ब': FingerType.leftIndex,

    // Right Index - Row 1
    'ह': FingerType.rightIndex,
    'ग': FingerType.rightIndex,

    // Right Middle - Row 1
    'द': FingerType.rightMiddle,

    // Right Ring - Row 1
    'ज': FingerType.rightRing,

    // Right Pinky - Row 1
    'ड': FingerType.rightPinky,
    '़': FingerType.rightPinky,
    'ॉ': FingerType.rightPinky,

    // Left Pinky - Row 2 (Home)
    'CAPS': FingerType.leftPinky,
    'ो': FingerType.leftPinky,

    // Left Ring - Row 2
    'े': FingerType.leftRing,

    // Left Middle - Row 2
    '्': FingerType.leftMiddle,

    // Left Index - Row 2 (includes reach keys)
    'ि': FingerType.leftIndex,
    'ु': FingerType.leftIndex,
    'प': FingerType.leftIndex,

    // Right Index - Row 2
    'र': FingerType.rightIndex,
    'क': FingerType.rightIndex,

    // Right Middle - Row 2
    'त': FingerType.rightMiddle,

    // Right Ring - Row 2
    'च': FingerType.rightRing,

    // Right Pinky - Row 2
    'ट': FingerType.rightPinky,
    'ENTER': FingerType.rightPinky,

    // Left Pinky - Row 3 (Bottom)
    'SHIFT': FingerType.leftPinky,
    'ॅ': FingerType.leftPinky,

    // Left Ring - Row 3
    'ं': FingerType.leftRing,

    // Left Middle - Row 3
    'म': FingerType.leftMiddle,

    // Left Index - Row 3 (includes reach keys)
    'न': FingerType.leftIndex,
    'व': FingerType.leftIndex,
    'ल': FingerType.leftIndex,

    // Right Index - Row 3
    'स': FingerType.rightIndex,
    ',': FingerType.rightIndex,

    // Right Middle - Row 3
    '.': FingerType.rightMiddle,

    // Right Ring - Row 3
    'य': FingerType.rightRing,

    // Right Pinky - Row 3
    // SHIFT already mapped

    // === SHIFT LAYER (Aspirated consonants & full vowels) ===

    // Full vowels (shift layer)
    'औ': FingerType.leftPinky,
    'ऐ': FingerType.leftRing,
    'आ': FingerType.leftMiddle,
    'ई': FingerType.leftIndex,
    'ऊ': FingerType.leftIndex,
    'भ': FingerType.leftIndex,
    'ङ': FingerType.rightIndex,
    'घ': FingerType.rightIndex,
    'ध': FingerType.rightMiddle,
    'झ': FingerType.rightRing,
    'ढ': FingerType.rightPinky,
    'ञ': FingerType.rightPinky,

    'ओ': FingerType.leftPinky,
    'ए': FingerType.leftRing,
    'अ': FingerType.leftMiddle,
    'इ': FingerType.leftIndex,
    'उ': FingerType.leftIndex,
    'फ': FingerType.leftIndex,
    'ऱ': FingerType.rightIndex,
    'ख': FingerType.rightIndex,
    'थ': FingerType.rightMiddle,
    'छ': FingerType.rightRing,
    'ठ': FingerType.rightPinky,

    'ऋ': FingerType.leftPinky,
    'ष': FingerType.leftMiddle,
    'श': FingerType.leftIndex,
    'ण': FingerType.leftIndex,
    'ळ': FingerType.leftIndex,

    // Space
    ' ': FingerType.rightThumb,
    'SPACE': FingerType.rightThumb,
  };

  // =========================================================================
  // 🇮🇳 GUJARATI FINGER MAPPING (INSCRIPT LAYOUT)
  // =========================================================================

  /// Gujarati Inscript keyboard finger mapping
  static const Map<String, FingerType> gujaratiFingerMap = {
    // Left Pinky - Row 1 (Top)
    'TAB': FingerType.leftPinky,
    'ૌ': FingerType.leftPinky,

    // Left Ring - Row 1
    'ૈ': FingerType.leftRing,

    // Left Middle - Row 1
    'ા': FingerType.leftMiddle,

    // Left Index - Row 1 (includes reach keys)
    'ી': FingerType.leftIndex,
    'ૂ': FingerType.leftIndex,
    'બ': FingerType.leftIndex,

    // Right Index - Row 1
    'હ': FingerType.rightIndex,
    'ગ': FingerType.rightIndex,

    // Right Middle - Row 1
    'દ': FingerType.rightMiddle,

    // Right Ring - Row 1
    'જ': FingerType.rightRing,

    // Right Pinky - Row 1
    'ડ': FingerType.rightPinky,
    '઼': FingerType.rightPinky,
    'ૉ': FingerType.rightPinky,

    // Left Pinky - Row 2 (Home)
    'CAPS': FingerType.leftPinky,
    'ો': FingerType.leftPinky,

    // Left Ring - Row 2
    'ે': FingerType.leftRing,

    // Left Middle - Row 2
    '્': FingerType.leftMiddle,

    // Left Index - Row 2 (includes reach keys)
    'િ': FingerType.leftIndex,
    'ુ': FingerType.leftIndex,
    'પ': FingerType.leftIndex,

    // Right Index - Row 2
    'ર': FingerType.rightIndex,
    'ક': FingerType.rightIndex,

    // Right Middle - Row 2
    'ત': FingerType.rightMiddle,

    // Right Ring - Row 2
    'ચ': FingerType.rightRing,

    // Right Pinky - Row 2
    'ટ': FingerType.rightPinky,
    'ENTER': FingerType.rightPinky,

    // Left Pinky - Row 3 (Bottom)
    'SHIFT': FingerType.leftPinky,
    'ૅ': FingerType.leftPinky,

    // Left Ring - Row 3
    'ં': FingerType.leftRing,
    'ઃ': FingerType.leftRing,

    // Left Middle - Row 3
    'મ': FingerType.leftMiddle,

    // Left Index - Row 3 (includes reach keys)
    'ન': FingerType.leftIndex,
    'વ': FingerType.leftIndex,
    'લ': FingerType.leftIndex,

    // Right Index - Row 3
    'સ': FingerType.rightIndex,
    ',': FingerType.rightIndex,

    // Right Middle - Row 3
    '.': FingerType.rightMiddle,

    // Right Ring - Row 3
    'ય': FingerType.rightRing,

    // === SHIFT LAYER (Aspirated consonants & full vowels) ===

    // Full vowels (shift layer)
    'ઔ': FingerType.leftPinky,
    'ઐ': FingerType.leftRing,
    'આ': FingerType.leftMiddle,
    'ઈ': FingerType.leftIndex,
    'ઊ': FingerType.leftIndex,
    'ભ': FingerType.leftIndex,
    'ઙ': FingerType.rightIndex,
    'ઘ': FingerType.rightIndex,
    'ધ': FingerType.rightMiddle,
    'ઝ': FingerType.rightRing,
    'ઢ': FingerType.rightPinky,
    'ઞ': FingerType.rightPinky,

    'ઓ': FingerType.leftPinky,
    'એ': FingerType.leftRing,
    'અ': FingerType.leftMiddle,
    'ઇ': FingerType.leftIndex,
    'ઉ': FingerType.leftIndex,
    'ફ': FingerType.leftIndex,
    'ખ': FingerType.rightIndex,
    'થ': FingerType.rightMiddle,
    'છ': FingerType.rightRing,
    'ઠ': FingerType.rightPinky,

    'ઋ': FingerType.leftPinky,
    'ષ': FingerType.leftMiddle,
    'શ': FingerType.leftIndex,
    'ણ': FingerType.leftIndex,
    'ળ': FingerType.leftIndex,

    // Space
    ' ': FingerType.rightThumb,
    'SPACE': FingerType.rightThumb,
  };

  // =========================================================================
  // 🔧 UTILITY METHODS
  // =========================================================================

  /// Get finger type for a character based on language
  static FingerType? getFingerForChar(String char, String languageCode) {
    switch (languageCode) {
      case 'en':
        return englishFingerMap[char];
      case 'hi':
        return hindiFingerMap[char];
      case 'gu':
        return gujaratiFingerMap[char];
      default:
        return englishFingerMap[char];
    }
  }

  /// Get hand image path for left hand based on finger
  static String getLeftHandImage(FingerType? finger) {
    switch (finger) {
      case FingerType.leftPinky:
        return 'assets/images/hand/left_pinky.png';
      case FingerType.leftRing:
        return 'assets/images/hand/left_ring.png';
      case FingerType.leftMiddle:
        return 'assets/images/hand/left_middle.png';
      case FingerType.leftIndex:
        return 'assets/images/hand/left_index.png';
      case FingerType.leftThumb:
        return 'assets/images/hand/left_thumb.png';
      default:
        return 'assets/images/hand/left_default.png';
    }
  }

  /// Get hand image path for right hand based on finger
  static String getRightHandImage(FingerType? finger) {
    switch (finger) {
      case FingerType.rightPinky:
        return 'assets/images/hand/right_pinky.png';
      case FingerType.rightRing:
        return 'assets/images/hand/right_ring.png';
      case FingerType.rightMiddle:
        return 'assets/images/hand/right_middle.png';
      case FingerType.rightIndex:
        return 'assets/images/hand/right_index.png';
      case FingerType.rightThumb:
        return 'assets/images/hand/right_thumb.png';
      default:
        return 'assets/images/hand/right_default.png';
    }
  }

  /// Check if finger is on left hand
  static bool isLeftHandFinger(FingerType finger) {
    return finger == FingerType.leftPinky ||
        finger == FingerType.leftRing ||
        finger == FingerType.leftMiddle ||
        finger == FingerType.leftIndex ||
        finger == FingerType.leftThumb;
  }

  /// Check if finger is on right hand
  static bool isRightHandFinger(FingerType finger) {
    return finger == FingerType.rightPinky ||
        finger == FingerType.rightRing ||
        finger == FingerType.rightMiddle ||
        finger == FingerType.rightIndex ||
        finger == FingerType.rightThumb;
  }

  /// Get finger name for display
  static String getFingerName(FingerType finger) {
    switch (finger) {
      case FingerType.leftPinky:
        return 'Left Pinky';
      case FingerType.leftRing:
        return 'Left Ring';
      case FingerType.leftMiddle:
        return 'Left Middle';
      case FingerType.leftIndex:
        return 'Left Index';
      case FingerType.leftThumb:
        return 'Left Thumb';
      case FingerType.rightPinky:
        return 'Right Pinky';
      case FingerType.rightRing:
        return 'Right Ring';
      case FingerType.rightMiddle:
        return 'Right Middle';
      case FingerType.rightIndex:
        return 'Right Index';
      case FingerType.rightThumb:
        return 'Right Thumb';
    }
  }
}
