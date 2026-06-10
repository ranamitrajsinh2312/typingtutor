// =========================================================================
// 🎹 KEYBOARD CONTROLLER - GETX STATE MANAGEMENT
// =========================================================================

import 'package:get/get.dart';
import 'package:typingtutor/models/keyboard_layout.dart';
import 'package:typingtutor/data/keyboard_layouts_data.dart';
import 'package:typingtutor/data/finger_mapping_data.dart';

/// GetX Controller for managing keyboard language and layout state
class KeyboardController extends GetxController {
  // =========================================================================
  // 📊 OBSERVABLE STATE
  // =========================================================================

  /// Current language code (en, hi, gu)
  final _currentLanguage = 'en'.obs;

  /// Current keyboard layout
  final _currentLayout = Rx<KeyboardLayout>(KeyboardLayouts.english);

  /// Is shift mode active
  final _isShiftActive = false.obs;

  /// Is caps lock active
  final _isCapsLock = false.obs;

  /// Is keyboard visible
  final _isKeyboardVisible = true.obs;

  /// Current highlighted key index (row, col)
  final _highlightedKeyPosition = Rxn<List<int>>();

  /// Error key position (for wrong key press feedback)
  final _errorKeyPosition = Rxn<List<int>>();

  // =========================================================================
  // 🔍 GETTERS
  // =========================================================================

  String get currentLanguage => _currentLanguage.value;
  KeyboardLayout get currentLayout => _currentLayout.value;
  bool get isShiftActive => _isShiftActive.value;
  bool get isCapsLock => _isCapsLock.value;
  bool get isKeyboardVisible => _isKeyboardVisible.value;
  List<int>? get highlightedKeyPosition => _highlightedKeyPosition.value;
  List<int>? get errorKeyPosition => _errorKeyPosition.value;

  /// Get current rows (considering shift state)
  List<List<String>> get currentRows {
    if ((_isShiftActive.value || _isCapsLock.value) &&
        _currentLayout.value.shiftRows != null) {
      return _currentLayout.value.shiftRows!;
    }
    return _currentLayout.value.rows;
  }

  /// Get all available language options
  List<LanguageInfo> get availableLanguages => LanguageInfo.supportedLanguages;

  /// Get current language info
  LanguageInfo? get currentLanguageInfo =>
      LanguageInfo.getByCode(_currentLanguage.value);

  // =========================================================================
  // 🔄 LANGUAGE METHODS
  // =========================================================================

  /// Change the current keyboard language
  void changeLanguage(String languageCode) {
    if (!KeyboardLayouts.isSupported(languageCode)) {
      Get.snackbar(
        'Language Not Supported',
        'The selected language is not available',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newLayout = KeyboardLayouts.getLayout(languageCode);
    if (newLayout != null) {
      _currentLanguage.value = languageCode;
      _currentLayout.value = newLayout;
      _isShiftActive.value = false;
      _isCapsLock.value = false;
      _highlightedKeyPosition.value = null;
      _errorKeyPosition.value = null;

      update(); // Notify all listeners
    }
  }

  /// Change language without triggering update (for use during build)
  void changeLanguageSilent(String languageCode) {
    if (!KeyboardLayouts.isSupported(languageCode)) {
      return;
    }

    final newLayout = KeyboardLayouts.getLayout(languageCode);
    if (newLayout != null) {
      _currentLanguage.value = languageCode;
      _currentLayout.value = newLayout;
      _isShiftActive.value = false;
      _isCapsLock.value = false;
      _highlightedKeyPosition.value = null;
      _errorKeyPosition.value = null;
      // No update() call - prevents "markNeedsBuild" error during build
    }
  }

  /// Change to practice layout for current language
  void usePracticeLayout() {
    final practiceCode = '${_currentLanguage.value}_practice';
    if (KeyboardLayouts.isSupported(practiceCode)) {
      final practiceLayout = KeyboardLayouts.getLayout(practiceCode);
      if (practiceLayout != null) {
        _currentLayout.value = practiceLayout;
        update();
      }
    }
  }

  /// Reset to full layout for current language
  void useFullLayout() {
    final fullLayout = KeyboardLayouts.getLayout(_currentLanguage.value);
    if (fullLayout != null) {
      _currentLayout.value = fullLayout;
      update();
    }
  }

  // =========================================================================
  // ⌨️ KEYBOARD STATE METHODS
  // =========================================================================

  /// Toggle shift state
  void toggleShift() {
    _isShiftActive.value = !_isShiftActive.value;
    update();
  }

  /// Set shift state
  void setShift(bool active) {
    _isShiftActive.value = active;
    update();
  }

  /// Toggle caps lock
  void toggleCapsLock() {
    _isCapsLock.value = !_isCapsLock.value;
    update();
  }

  /// Set caps lock state
  void setCapsLock(bool active) {
    _isCapsLock.value = active;
    update();
  }

  /// Toggle keyboard visibility
  void toggleKeyboardVisibility() {
    _isKeyboardVisible.value = !_isKeyboardVisible.value;
    update();
  }

  /// Set keyboard visibility
  void setKeyboardVisibility(bool visible) {
    _isKeyboardVisible.value = visible;
    update();
  }

  // =========================================================================
  // 🎯 KEY HIGHLIGHTING METHODS
  // =========================================================================

  /// Highlight a specific key by position
  void highlightKey(int row, int col) {
    _highlightedKeyPosition.value = [row, col];
    update();
  }

  /// Highlight key by character
  void highlightKeyByChar(String char) {
    final position = _findKeyPosition(char);
    if (position != null) {
      _highlightedKeyPosition.value = position;
      update();
    }
  }

  /// Clear key highlight
  void clearHighlight() {
    _highlightedKeyPosition.value = null;
    update();
  }

  /// Show error on a key by position
  void showKeyError(int row, int col) {
    _errorKeyPosition.value = [row, col];
    update();

    // Auto-clear error after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      clearKeyError();
    });
  }

  /// Show error on key by character
  void showKeyErrorByChar(String char) {
    final position = _findKeyPosition(char);
    if (position != null) {
      showKeyError(position[0], position[1]);
    }
  }

  /// Clear key error
  void clearKeyError() {
    _errorKeyPosition.value = null;
    update();
  }

  /// Find key position by character - Unicode safe
  List<int>? _findKeyPosition(String char) {
    if (char.isEmpty) return null;

    final rows = currentRows;
    final isEnglish = _currentLanguage.value == 'en';

    for (int row = 0; row < rows.length; row++) {
      for (int col = 0; col < rows[row].length; col++) {
        final key = rows[row][col];

        // For English: case-insensitive comparison
        // For Indic scripts: exact Unicode comparison
        bool matches;
        if (isEnglish) {
          matches = key.toLowerCase() == char.toLowerCase();
        } else {
          // Exact comparison for Unicode characters (Hindi/Gujarati)
          matches = key == char;
          // Also check if the character's runes match (for combining characters)
          if (!matches && char.runes.isNotEmpty && key.runes.isNotEmpty) {
            matches = char.runes.first == key.runes.first;
          }
        }

        if (matches) {
          return [row, col];
        }
      }
    }
    return null;
  }

  // =========================================================================
  // 🔧 UTILITY METHODS
  // =========================================================================

  /// Get full keyboard layout as 2D list for current state
  List<List<String>> getKeyboardRows() {
    return currentRows;
  }

  /// Get row count
  int get rowCount => currentRows.length;

  /// Get specific row
  List<String> getRow(int index) {
    if (index >= 0 && index < currentRows.length) {
      return currentRows[index];
    }
    return [];
  }

  /// Check if character requires shift
  bool requiresShift(String char) {
    if (_currentLanguage.value == 'en') {
      // English: uppercase letters need shift
      return char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90;
    }
    // For Hindi/Gujarati, check if character is in shift rows
    if (_currentLayout.value.shiftRows != null) {
      for (var row in _currentLayout.value.shiftRows!) {
        if (row.contains(char)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get character at position
  String? getCharAt(int row, int col) {
    final rows = currentRows;
    if (row >= 0 && row < rows.length && col >= 0 && col < rows[row].length) {
      return rows[row][col];
    }
    return null;
  }

  /// Get matras for current language (Hindi/Gujarati)
  List<String>? get currentMatras => _currentLayout.value.matras;

  /// Get conjuncts for current language (Hindi/Gujarati)
  List<String>? get currentConjuncts => _currentLayout.value.conjuncts;

  // =========================================================================
  // � FINGER MAPPING METHODS
  // =========================================================================

  /// Get finger type for current character
  FingerType? getFingerForChar(String char) {
    return FingerMappingData.getFingerForChar(char, _currentLanguage.value);
  }

  /// Get left hand image for a character
  String getLeftHandImageForChar(String char) {
    final finger = getFingerForChar(char);
    return FingerMappingData.getLeftHandImage(finger);
  }

  /// Get right hand image for a character
  String getRightHandImageForChar(String char) {
    final finger = getFingerForChar(char);
    return FingerMappingData.getRightHandImage(finger);
  }

  /// Check if character uses left hand
  bool isLeftHandChar(String char) {
    final finger = getFingerForChar(char);
    if (finger == null) return false;
    return FingerMappingData.isLeftHandFinger(finger);
  }

  /// Check if character uses right hand
  bool isRightHandChar(String char) {
    final finger = getFingerForChar(char);
    if (finger == null) return false;
    return FingerMappingData.isRightHandFinger(finger);
  }

  /// Get finger name for a character
  String? getFingerNameForChar(String char) {
    final finger = getFingerForChar(char);
    if (finger == null) return null;
    return FingerMappingData.getFingerName(finger);
  }

  // =========================================================================
  // �🔄 LIFECYCLE
  // =========================================================================

  @override
  void onInit() {
    super.onInit();
    // Initialize with default English layout
    _currentLayout.value = KeyboardLayouts.english;
  }

  /// Reset controller to initial state
  void reset() {
    _currentLanguage.value = 'en';
    _currentLayout.value = KeyboardLayouts.english;
    _isShiftActive.value = false;
    _isCapsLock.value = false;
    _isKeyboardVisible.value = true;
    _highlightedKeyPosition.value = null;
    _errorKeyPosition.value = null;
    update();
  }
}
