// =========================================================================
// ⌨️ TYPING CONTROLLER — delegates all key mapping to IndicKeyMappings
// =========================================================================
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:characters/characters.dart';
import 'package:typingtutor/services/atomic_typing_service.dart';
import 'package:typingtutor/services/indic_key_mappings.dart';

class TypingController extends GetxController {
  final _currentLanguage = 'en'.obs;
  final _isShiftPressed  = false.obs;
  final _currentFinger   = Rxn<String>();
  final _lastPhysicalKey = ''.obs;

  String  get currentLanguage  => _currentLanguage.value;
  bool    get isShiftPressed   => _isShiftPressed.value;
  String? get currentFinger    => _currentFinger.value;
  String  get lastPhysicalKey  => _lastPhysicalKey.value;

  void setLanguage(String code) { _currentLanguage.value = code; update(); }
  void setShift(bool v)          { _isShiftPressed.value  = v;    update(); }

  // ── Key processing ────────────────────────────────────────────────────────

  ProcessedKeyResult? processKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return null;
    final lk = event.logicalKey;

    if (lk == LogicalKeyboardKey.space) {
      _updateFingerHighlight(' ');
      return ProcessedKeyResult(physicalKey: ' ', mappedChar: ' ',
          isSpecialKey: false, specialKeyType: null, finger: 'thumb');
    }
    if (lk == LogicalKeyboardKey.backspace) {
      return ProcessedKeyResult(physicalKey: 'BACKSPACE', mappedChar: '',
          isSpecialKey: true, specialKeyType: SpecialKeyType.backspace, finger: null);
    }
    if (lk == LogicalKeyboardKey.shiftLeft || lk == LogicalKeyboardKey.shiftRight) {
      setShift(true);
      return ProcessedKeyResult(physicalKey: 'SHIFT', mappedChar: '',
          isSpecialKey: true, specialKeyType: SpecialKeyType.shift, finger: 'left_pinky');
    }
    if (lk == LogicalKeyboardKey.tab || lk == LogicalKeyboardKey.capsLock ||
        lk == LogicalKeyboardKey.enter || lk == LogicalKeyboardKey.escape) {
      return ProcessedKeyResult(physicalKey: lk.keyLabel, mappedChar: '',
          isSpecialKey: true, specialKeyType: SpecialKeyType.modifier, finger: null);
    }

    String? physChar = event.character;
    if (physChar == null || physChar.isEmpty) {
      physChar = lk.keyLabel;
      if (physChar.isEmpty) return null;
    }

    _lastPhysicalKey.value = physChar;
    final finger = getFingerForKey(physChar);
    _updateFingerHighlight(physChar);
    final mapped = getMappedCharacter(physChar);

    return ProcessedKeyResult(physicalKey: physChar, mappedChar: mapped,
        isSpecialKey: false, specialKeyType: null, finger: finger);
  }

  /// Single source of truth — delegates to IndicKeyMappings.
  String getMappedCharacter(String physicalKey) =>
      IndicKeyMappings.getMappedCharacter(
          physicalKey, _currentLanguage.value, _isShiftPressed.value);

  String? getFingerForKey(String physicalKey) {
    final f = PhysicalKeyFingerMapping.getFingerForPhysicalKey(physicalKey)
        ?? PhysicalKeyFingerMapping.getFingerForPhysicalKey(physicalKey.toLowerCase());
    return f == null ? null : PhysicalKeyFingerMapping.getFingerName(f);
  }

  void _updateFingerHighlight(String physicalKey) {
    _currentFinger.value = getFingerForKey(physicalKey);
    update();
  }

  void clearFingerHighlight() { _currentFinger.value = null; update(); }

  // ── Counting / WPM / accuracy ─────────────────────────────────────────────

  int    countCharacters(String text)                        => AtomicTypingService.countAtomicUnits(text, _currentLanguage.value);
  int    countCharactersForWpm(String text)                  => countCharacters(text);
  int    calculateWpm(int correctChars, int elapsedSeconds)  => AtomicTypingService.calculateWpm(correctChars, elapsedSeconds);
  double calculateAccuracy(int correct, int incorrect)       => AtomicTypingService.calculateAccuracy(correct, incorrect);

  // ── Comparison ────────────────────────────────────────────────────────────

  bool compareCharacters(String input, String expected, String languageCode) {
    if (input.isEmpty || expected.isEmpty) return false;
    if (languageCode == 'en') return input.toLowerCase() == expected.toLowerCase();
    if (input == expected) return true;
    final ic = input.characters; final ec = expected.characters;
    if (ic.isEmpty || ec.isEmpty) return false;
    return ic.first == ec.first;
  }

  // ── Atomic splitting ──────────────────────────────────────────────────────

  List<String> splitIntoAtomicUnits(String text) =>
      AtomicTypingService.splitIntoAtomicUnits(text, _currentLanguage.value);

  bool compareAtomicUnits(String input, String expected) =>
      AtomicTypingService.compareAtomicUnits(input, expected, _currentLanguage.value);

  int  countAtomicUnits(String text) =>
      AtomicTypingService.countAtomicUnits(text, _currentLanguage.value);

  int  calculateWpmAtomic(int correctUnits, int elapsedSeconds) =>
      AtomicTypingService.calculateWpm(correctUnits, elapsedSeconds);

  // ── Finger / key helpers ──────────────────────────────────────────────────

  String? getPhysicalKeyForChar(String char) =>
      IndicKeyMappings.getPhysicalKeyForChar(char, _currentLanguage.value);

  String? getFingerForIndicChar(String char) {
    final f = PhysicalKeyFingerMapping.getFingerForIndicChar(char, _currentLanguage.value);
    return PhysicalKeyFingerMapping.getFingerName(f);
  }

  bool    charRequiresShift(String char) =>
      IndicKeyMappings.requiresShift(char, _currentLanguage.value);

  String? getExpectedPhysicalKey(String char) =>
      _currentLanguage.value == 'en'
          ? char
          : IndicKeyMappings.getPhysicalKeyForChar(char, _currentLanguage.value);

  void highlightFingerForChar(String char) {
    _updateFingerHighlight(getExpectedPhysicalKey(char) ?? char);
  }

  // ── Hand images ───────────────────────────────────────────────────────────

  String getLeftHandImage() {
    switch (_currentFinger.value) {
      case 'left_pinky':  return 'assets/images/hand/left_pinky.png';
      case 'left_ring':   return 'assets/images/hand/left_ring.png';
      case 'left_middle': return 'assets/images/hand/left_middle.png';
      case 'left_index':  return 'assets/images/hand/left_index.png';
      case 'thumb':       return 'assets/images/hand/left_thumb.png';
      default:            return 'assets/images/hand/left_default.png';
    }
  }

  String getRightHandImage() {
    switch (_currentFinger.value) {
      case 'right_pinky':  return 'assets/images/hand/right_pinky.png';
      case 'right_ring':   return 'assets/images/hand/right_ring.png';
      case 'right_middle': return 'assets/images/hand/right_middle.png';
      case 'right_index':  return 'assets/images/hand/right_index.png';
      case 'thumb':        return 'assets/images/hand/right_thumb.png';
      default:             return 'assets/images/hand/right_default.png';
    }
  }

  bool isLeftHandFinger()  { final f = _currentFinger.value; return f != null && (f.startsWith('left')  || f == 'thumb'); }
  bool isRightHandFinger() { final f = _currentFinger.value; return f != null && (f.startsWith('right') || f == 'thumb'); }

  @override void onInit() { super.onInit(); _currentLanguage.value = 'en'; }

  void reset() {
    _currentLanguage.value = 'en';
    _isShiftPressed.value  = false;
    _currentFinger.value   = null;
    _lastPhysicalKey.value = '';
    update();
  }
}

class ProcessedKeyResult {
  final String physicalKey;
  final String mappedChar;
  final bool isSpecialKey;
  final SpecialKeyType? specialKeyType;
  final String? finger;

  ProcessedKeyResult({
    required this.physicalKey, required this.mappedChar,
    required this.isSpecialKey, this.specialKeyType, this.finger,
  });
}

enum SpecialKeyType { backspace, shift, modifier, enter, tab }
