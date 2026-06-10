// =========================================================================
// ⌨️ LEVEL PRACTICE SCREEN - TYPING PRACTICE FOR LEVELS
// =========================================================================
//
// UI matches Level1 exactly:
//   - Colors.grey.shade100 background
//   - Text display: horizontal scroll Row of styled char widgets (top)
//   - Keyboard: centered with shake animation (middle/bottom)
//   - Stats sidebar: Colors.blue.shade800, width=100, ultra-compact cards
//   - No hand images
//   - Full-screen landscape
//
// Supports atomic character-based typing for Indic scripts (Hindi/Gujarati)
// =========================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/models/practice_level.dart';
import 'package:typingtutor/controllers/levels_controller.dart';
import 'package:typingtutor/screens/level_completion_screen.dart';
import 'package:typingtutor/data/keyboard_lessons_data.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/services/atomic_typing_service.dart';
import 'package:typingtutor/utils/responsive_helper.dart';

class LevelPracticeScreen extends StatefulWidget {
  final PracticeLevel level;
  final PracticeType type;
  final String languageCode;

  const LevelPracticeScreen({
    Key? key,
    required this.level,
    required this.type,
    this.languageCode = 'en',
  }) : super(key: key);

  @override
  State<LevelPracticeScreen> createState() => _LevelPracticeScreenState();
}

class _LevelPracticeScreenState extends State<LevelPracticeScreen>
    with TickerProviderStateMixin {
  // Controllers
  late LevelsController _levelsController;
  KeyboardController? _keyboardController;
  TypingController? _typingController;
  final ScrollController _textScrollController = ScrollController();

  // Animation controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Keyboard state
  late List<List<String>> _keys;
  late List<List<Color>> _keyColors;
  bool _isShiftPressed = false;

  // Game state - atomic units for proper Unicode support
  String _typingText = '';
  List<String> _typingChars = [];
  List<Color> _charColors = [];
  int _currentIndex = 0;
  int _correct = 0;
  int _incorrect = 0;
  int _wpm = 0;
  DateTime? _startTime;
  bool _isGameStarted = false;
  bool _isCompleted = false;
  Timer? _statsTimer;
  String? _wrongKey;
  DateTime? _wrongKeyTime;
  bool _isMounted = false;

  // Char widgets list (same as Level1's widget.list)
  List<Widget> _charWidgets = [];

  // Focus
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      if (_isMounted) {
        _initializeControllers();
        _setupAnimations();
        _loadContent();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isMounted) {
            _focusNode.requestFocus();
            _scrollToCurrentPosition();
          }
        });
      }
    });
  }

  void _initializeControllers() {
    if (!Get.isRegistered<LevelsController>()) {
      Get.put(LevelsController());
    }
    _levelsController = Get.find<LevelsController>();

    if (!Get.isRegistered<KeyboardController>()) {
      Get.put(KeyboardController());
    }
    _keyboardController = Get.find<KeyboardController>();

    if (!Get.isRegistered<TypingController>()) {
      Get.put(TypingController());
    }
    _typingController = Get.find<TypingController>();
    _typingController!.setLanguage(widget.languageCode);

    _keyboardController!.changeLanguageSilent(widget.languageCode);
    _initializeKeyboard();
  }

  void _initializeKeyboard() {
    final keyboardLayout = KeyboardLessonsData.getKeyboardLayoutForLanguage(
      widget.languageCode,
    );
    _keys = keyboardLayout.map((row) => List<String>.from(row)).toList();
    _keyColors =
        _keys.map((row) => List.filled(row.length, Colors.white)).toList();
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _shakeController.dispose();
    _statsTimer?.cancel();
    _textScrollController.dispose();
    _focusNode.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // =========================================================================
  // CHAR WIDGETS — mirrors Level1.getSplitValue()
  // =========================================================================

  List<Widget> _buildCharWidgets() {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < 600 ? 14.0 : (width < 800 ? 16.0 : 18.0);
    final horizontalPadding = width < 600 ? 2.0 : 3.0;
    final verticalPadding = width < 600 ? 1.0 : 1.5;

    List<Widget> widgets = [];
    for (int i = 0; i < _typingChars.length && i < _charColors.length; i++) {
      final char = _typingChars[i];
      final color = _charColors[i];

      Color bgColor;
      Color borderColor;
      Color textColor;

      if (color == Colors.grey) {
        bgColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        textColor = Colors.black87;
      } else if (color == Colors.blue) {
        bgColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade400;
        textColor = Colors.blue.shade800;
      } else if (color == Colors.green) {
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade400;
        textColor = Colors.green.shade800;
      } else if (color == Colors.red) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade400;
        textColor = Colors.red.shade800;
      } else {
        bgColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        textColor = Colors.black87;
      }

      final isCurrent = i == _currentIndex;

      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 0.8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: color != Colors.grey
                ? [
                    BoxShadow(
                      color: (color == Colors.blue
                              ? Colors.blue
                              : color == Colors.green
                                  ? Colors.green
                                  : color == Colors.red
                                      ? Colors.red
                                      : Colors.grey)
                          .withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            char == ' ' ? '␣' : char,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // =========================================================================
  // SCROLL
  // =========================================================================

  void _scrollToCurrentPosition() {
    if (!_isMounted ||
        !_textScrollController.hasClients ||
        _currentIndex >= _typingChars.length) return;

    final width = MediaQuery.of(context).size.width;
    final charWidth = width < 600 ? 20.0 : (width < 800 ? 22.0 : 24.0);
    final containerWidth = _textScrollController.position.viewportDimension;
    final maxOffset = _textScrollController.position.maxScrollExtent;
    final currentCharOffset = _currentIndex * charWidth;
    final currentScrollOffset = _textScrollController.offset;
    final centerPosition = currentScrollOffset + containerWidth / 2;

    if (currentCharOffset > centerPosition) {
      double desiredOffset =
          currentCharOffset - (containerWidth / 2) + (charWidth / 2);
      desiredOffset = desiredOffset.clamp(0.0, maxOffset);
      if (desiredOffset > currentScrollOffset) {
        _textScrollController.animateTo(
          desiredOffset,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    }
  }

  // =========================================================================
  // STATS HELPERS
  // =========================================================================

  String _getElapsedTime() {
    if (_startTime == null) return '00:00';
    final elapsed = DateTime.now().difference(_startTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getAccuracy() {
    final total = _correct + _incorrect;
    if (total == 0) return 100.0;
    return (_correct / total * 100).clamp(0.0, 100.0);
  }

  double _getProgress() {
    if (_typingChars.isEmpty) return 0.0;
    return (_currentIndex / _typingChars.length * 100).clamp(0.0, 100.0);
  }

  void _calculateStats() {
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      if (elapsed > 0) {
        setState(() {
          _wpm = AtomicTypingService.calculateWpm(_correct, elapsed);
        });
      }
    }
  }

  // =========================================================================
  // KEY HIGHLIGHT HELPERS
  // =========================================================================

  void _highlightCurrentKey(int charIndex, Color color) {
    if (charIndex >= _typingChars.length) return;
    String currentChar = _getCharAt(charIndex);

    if (_keyboardController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted && mounted && _keyboardController != null) {
          _keyboardController!.highlightKeyByChar(currentChar);
        }
      });
      if (widget.languageCode == 'en') _updateLocalKeyColor(currentChar, color);
      return;
    }
    _updateLocalKeyColor(currentChar, color);
  }

  void _updateLocalKeyColor(String currentChar, Color color) {
    if (currentChar == ' ') {
      if (_keys.isNotEmpty && _keys.last.isNotEmpty) {
        _keyColors[_keys.length - 1][0] = color;
      }
      return;
    }
    String keyToHighlight =
        widget.languageCode == 'en' ? currentChar.toUpperCase() : currentChar;
    for (int row = 0; row < _keys.length; row++) {
      for (int col = 0; col < _keys[row].length; col++) {
        if (_keys[row][col] == keyToHighlight ||
            (widget.languageCode == 'en' &&
                _keys[row][col].toUpperCase() == keyToHighlight)) {
          _keyColors[row][col] = color;
          return;
        }
      }
    }
  }

  void _removeKeyHighlight(int charIndex) {
    if (charIndex >= _typingChars.length || charIndex < 0) return;
    String prevChar = _getCharAt(charIndex);

    if (_keyboardController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted && mounted && _keyboardController != null) {
          _keyboardController!.clearHighlight();
        }
      });
      if (widget.languageCode == 'en') _clearLocalKeyColor(prevChar);
      return;
    }
    _clearLocalKeyColor(prevChar);
  }

  void _clearLocalKeyColor(String prevChar) {
    if (prevChar == ' ') {
      if (_keys.isNotEmpty && _keys.last.isNotEmpty) {
        _keyColors[_keys.length - 1][0] = Colors.white;
      }
      return;
    }
    String keyToRemove =
        widget.languageCode == 'en' ? prevChar.toUpperCase() : prevChar;
    for (int row = 0; row < _keys.length; row++) {
      for (int col = 0; col < _keys[row].length; col++) {
        if (_keys[row][col] == keyToRemove ||
            (widget.languageCode == 'en' &&
                _keys[row][col].toUpperCase() == keyToRemove)) {
          _keyColors[row][col] = Colors.white;
          return;
        }
      }
    }
  }

  void _highlightShiftKey(bool highlight) {
    Color color = highlight ? Colors.blue.shade200 : Colors.white;
    if (_keys.length > 2 && _keys[2].isNotEmpty) {
      _keyColors[2][0] = color;
      if (_keys[2].length > 1) {
        _keyColors[2][_keys[2].length - 1] = color;
      }
    }

    if (widget.languageCode != 'en' && highlight != _isShiftPressed) {
      setState(() {
        _isShiftPressed = highlight;
        if (_isShiftPressed) {
          _keys =
              KeyboardLessonsData.getShiftKeyboardLayoutForLanguage(
                widget.languageCode,
              ).map((row) => List<String>.from(row)).toList();
        } else {
          _keys =
              KeyboardLessonsData.getKeyboardLayoutForLanguage(
                widget.languageCode,
              ).map((row) => List<String>.from(row)).toList();
        }
        _keyColors =
            _keys.map((row) => List.filled(row.length, Colors.white)).toList();
        _highlightCurrentKey(_currentIndex, Colors.blue.shade200);
      });
    }
  }

  bool _isShiftRequired() {
    if (_currentIndex >= _typingChars.length) return false;
    final currentChar = _getCurrentChar();
    if (currentChar.isEmpty) return false;

    if (widget.languageCode == 'en') {
      final codeUnit = currentChar.codeUnitAt(0);
      return codeUnit >= 65 && codeUnit <= 90;
    }
    if (widget.languageCode == 'hi') {
      for (var row in KeyboardLessonsData.hindiShiftKeyboardLayout) {
        if (row.contains(currentChar)) return true;
      }
      return false;
    }
    if (widget.languageCode == 'gu') {
      for (var row in KeyboardLessonsData.gujaratiShiftKeyboardLayout) {
        if (row.contains(currentChar)) return true;
      }
      return false;
    }
    return false;
  }

  List<String> _getRequiredKeys() {
    List<String> requiredKeys = [];
    for (var row in _keys) {
      requiredKeys.addAll(row);
    }
    return requiredKeys;
  }

  String _getCurrentChar() {
    if (_currentIndex >= _typingChars.length) return '';
    return _typingChars[_currentIndex];
  }

  String _getCharAt(int index) {
    if (index < 0 || index >= _typingChars.length) return '';
    return _typingChars[index];
  }

  // =========================================================================
  // LOAD CONTENT
  // =========================================================================

  Future<void> _loadContent() async {
    if (_levelsController.currentLanguage != widget.languageCode) {
      _levelsController.changeLanguage(widget.languageCode);
    }
    await _levelsController.fetchContent(widget.level);
    final content = _levelsController.currentContent;
    if (content.isNotEmpty) {
      setState(() {
        _typingText = content.map((c) => c.text).join(' ');
        _typingChars = AtomicTypingService.splitIntoAtomicUnits(
          _typingText,
          widget.languageCode,
        );
        _charColors = List.filled(_typingChars.length, Colors.grey);
        if (_typingChars.isNotEmpty) {
          _charColors[0] = Colors.blue;
        }
        _currentIndex = 0;
        _correct = 0;
        _incorrect = 0;
        _wpm = 0;
        _isGameStarted = false;
        _isCompleted = false;

        for (var row in _keyColors) {
          for (int i = 0; i < row.length; i++) {
            row[i] = Colors.white;
          }
        }
        _highlightCurrentKey(0, Colors.blue.shade200);
        if (_isShiftRequired()) _highlightShiftKey(true);

        _charWidgets = _buildCharWidgets();
      });
    }
    _focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) _scrollToCurrentPosition();
    });
  }

  // =========================================================================
  // GAME LOGIC
  // =========================================================================

  void _startGame() {
    if (!_isMounted || _isGameStarted) return;
    setState(() {
      _startTime = DateTime.now();
      _isGameStarted = true;
    });
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMounted && mounted) {
        setState(() {});
      }
    });
  }

  void _handleKeyPress(String key, {String? physicalKey}) {
    if (_isCompleted || _currentIndex >= _typingChars.length) return;
    _startGame();

    final expectedChar = _getCurrentChar();

    if (key == 'SPACE') {
      if (expectedChar == ' ') {
        _handleCorrectInput();
      } else {
        _handleIncorrectInput(key);
      }
      return;
    }
    if (key == 'BACKSPACE') {
      _handleBackspace();
      return;
    }
    if (key == 'SHIFT' || key == 'CAPS' || key == 'TAB' || key == 'ENTER') {
      return;
    }

    bool isCorrect = AtomicTypingService.compareAtomicUnits(
      key,
      expectedChar,
      widget.languageCode,
    );

    if (isCorrect) {
      _handleCorrectInput();
    } else {
      _handleIncorrectInput(key);
    }
  }

  void _handleCorrectInput() {
    if (!_isMounted) return;
    setState(() {
      if (_currentIndex < _charColors.length) {
        _charColors[_currentIndex] = Colors.green;
      }
      _correct++;
      _removeKeyHighlight(_currentIndex);
      _currentIndex++;
      _wrongKey = null;

      if (_currentIndex < _typingChars.length) {
        if (_currentIndex < _charColors.length) {
          _charColors[_currentIndex] = Colors.blue;
        }
        _highlightCurrentKey(_currentIndex, Colors.blue.shade200);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        } else {
          _highlightShiftKey(false);
        }
      } else {
        _highlightShiftKey(false);
      }
      _calculateStats();
      _charWidgets = _buildCharWidgets();

      if (_currentIndex >= _typingChars.length) {
        _statsTimer?.cancel();
        _completeLevel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPosition();
    });

    HapticFeedback.lightImpact();
  }

  void _handleIncorrectInput(String key) {
    if (!_isMounted) return;
    setState(() {
      if (_currentIndex < _charColors.length) {
        _charColors[_currentIndex] = Colors.red;
      }
      _incorrect++;
      _wrongKey = key == 'SPACE' ? 'SPACE' : key.toUpperCase();
      _wrongKeyTime = DateTime.now();
    });

    if (_keyboardController != null) {
      final expectedChar = _getCurrentChar();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted && mounted && _keyboardController != null) {
          _keyboardController!.showKeyErrorByChar(expectedChar);
        }
      });
    }

    _shakeController.forward().then((_) => _shakeController.reverse());
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_isMounted && mounted) {
        setState(() {
          _wrongKey = null;
          _wrongKeyTime = null;
        });
      }
    });

    setState(() {
      _removeKeyHighlight(_currentIndex);
      _currentIndex++;
      if (_currentIndex < _typingChars.length) {
        if (_currentIndex < _charColors.length) {
          _charColors[_currentIndex] = Colors.blue;
        }
        _highlightCurrentKey(_currentIndex, Colors.blue.shade200);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        } else {
          _highlightShiftKey(false);
        }
      } else {
        _highlightShiftKey(false);
      }
      _calculateStats();
      _charWidgets = _buildCharWidgets();

      if (_currentIndex >= _typingChars.length) {
        _statsTimer?.cancel();
        _completeLevel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPosition();
    });
  }

  void _handleBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        if (_currentIndex < _charColors.length) {
          _charColors[_currentIndex] = Colors.grey;
        }
        _removeKeyHighlight(_currentIndex);
        if (_isShiftRequired()) _highlightShiftKey(false);
        _currentIndex--;
        _charColors[_currentIndex] = Colors.blue;
        _highlightCurrentKey(_currentIndex, Colors.blue.shade200);
        if (_isShiftRequired()) _highlightShiftKey(true);
        _charWidgets = _buildCharWidgets();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentPosition();
      });
    }
  }

  // =========================================================================
  // SAVE & COMPLETE
  // =========================================================================

  Future<void> _saveRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername =
          prefs.getString(AppKeys.username) ?? AppConstants.defaultUsername;

      final record = TypingRecord(
        username: savedUsername,
        country: AppConstants.defaultCountry,
        wpm: _wpm,
        accuracy: _getAccuracy(),
      );
      await DatabaseHelper.instance.insertRecord(record);

      final starsEarned = LevelCompletionResult.calculateStars(
        _wpm,
        _getAccuracy(),
      );
      await DatabaseHelper.instance.saveLevelProgress(
        levelId: widget.level.id,
        practiceType: widget.type.name,
        languageCode: widget.languageCode,
        isCompleted: true,
        starsEarned: starsEarned,
        wpm: _wpm,
        accuracy: _getAccuracy(),
      );
    } catch (e) {
      print('Error saving record: $e');
    }
  }

  void _completeLevel() {
    setState(() {
      _isCompleted = true;
    });
    _saveRecord();

    final timeTaken =
        _startTime != null
            ? DateTime.now().difference(_startTime!)
            : Duration.zero;
    final starsEarned = LevelCompletionResult.calculateStars(
      _wpm,
      _getAccuracy(),
    );
    final result = LevelCompletionResult(
      levelId: widget.level.id,
      starsEarned: starsEarned,
      wpm: _wpm,
      accuracy: _getAccuracy(),
      timeTaken: timeTaken,
      correctChars: _correct,
      incorrectChars: _incorrect,
      isNewBest:
          _wpm > widget.level.bestWpm ||
          _getAccuracy() > widget.level.bestAccuracy,
      completedAt: DateTime.now(),
    );
    _levelsController.updateLevelCompletion(result);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isMounted && mounted) {
        Get.off(
          () => LevelCompletionScreen(
            result: result,
            level: widget.level,
            onRetry: () {
              Get.off(
                () => LevelPracticeScreen(
                  level: widget.level,
                  type: widget.type,
                  languageCode: widget.languageCode,
                ),
              );
            },
          ),
        );
      }
    });
  }

  // =========================================================================
  // BUILD UI  —  mirrors Level1 layout exactly
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    if (!_isMounted || !mounted) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.space) {
                _handleKeyPress('SPACE');
              } else if (key == LogicalKeyboardKey.backspace) {
                _handleKeyPress('BACKSPACE');
              } else if (key == LogicalKeyboardKey.shiftLeft ||
                  key == LogicalKeyboardKey.shiftRight) {
                setState(() {
                  _isShiftPressed = true;
                  if (_isShiftRequired()) _highlightShiftKey(true);
                });
              } else {
                final result = _typingController?.processKeyEvent(event);
                if (result != null && result.mappedChar.isNotEmpty) {
                  _handleKeyPress(
                    result.mappedChar,
                    physicalKey: result.physicalKey,
                  );
                }
              }
            } else if (event is RawKeyUpEvent) {
              if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                  event.logicalKey == LogicalKeyboardKey.shiftRight) {
                setState(() {
                  _isShiftPressed = false;
                });
              }
            }
          },
          child: Row(
            children: [
              // ── LEFT: Text display + Keyboard ────────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Text display (horizontal scroll, same as Level1)
                    _buildTextDisplay(),

                    const SizedBox(height: 8),

                    // Keyboard fills rest
                    Expanded(
                      flex: 3,
                      child: _buildKeyboardArea(),
                    ),
                  ],
                ),
              ),

              // ── RIGHT: Stats sidebar (same as Level1) ─────────────────────
              Container(
                height: double.infinity,
                width: 100,
                color: Colors.blue.shade800,
                padding: const EdgeInsets.all(12),
                child: _buildUltraCompactLandscapeStats(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Text display — horizontal scroll Row, same as Level1 ─────────────────

  Widget _buildTextDisplay() {
    final width = MediaQuery.of(context).size.width;
    final maxHeight = max(
      // same call as Level1: ResponsiveHelper.getTextDisplayHeight(context)
      (width < 600 ? 52.0 : (width < 800 ? 58.0 : 64.0)),
      10.0,
    );

    return Obx(() {
      if (_levelsController.isLoading) {
        return SizedBox(
          height: maxHeight,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (_levelsController.errorMessage.isNotEmpty) {
        return SizedBox(
          height: maxHeight,
          child: Center(
            child: TextButton.icon(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: Text(
                _levelsController.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
        );
      }
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 10),
        child: Center(
          child: SingleChildScrollView(
            controller: _textScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _charWidgets,
            ),
          ),
        ),
      );
    });
  }

  // ── Keyboard area — centered, with shake animation (same as Level1) ───────

  Widget _buildKeyboardArea() {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Keyboard (no hand images, just center it with flex)
          Flexible(
            flex: 10,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: width < 800 ? 8 : 16,
                vertical: width < 800 ? 6 : 10,
              ),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value * sin(_currentIndex * pi),
                      0,
                    ),
                    child: ModernKeyboardWidget(
                      keys: _keys,
                      keyColors: _keyColors,
                      currentChar: _getCurrentChar(),
                      requiredKeys: _getRequiredKeys(),
                      wrongKey: _wrongKey,
                      testString: _typingText,
                      currentIndex: _currentIndex,
                      onKeyPressed: _handleKeyPress,
                      isLandscape: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ultra-compact stats — mirrors Level1._buildUltraCompactLandscapeStats ──

  Widget _buildUltraCompactStatCard(
    BuildContext context,
    String label,
    String value,
    double labelFontSize,
    double valueFontSize,
    double padding,
  ) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      constraints: BoxConstraints(
        minWidth: width < 600 ? 52 : 52,
        maxWidth: width < 600 ? 48 : 52,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: labelFontSize,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: valueFontSize,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraCompactLandscapeStats(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compactFontSize = width < 600 ? 7.0 : (width < 800 ? 8.0 : 9.0);
    final compactValueFontSize =
        width < 600 ? 9.0 : (width < 800 ? 10.0 : 11.0);
    final compactPadding = 8.0;

    return Container(
      width: double.infinity,
      height: width < 600 ? 52 : 52,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildUltraCompactStatCard(
                  context,
                  'Time',
                  _getElapsedTime(),
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
                const SizedBox(height: 8),
                _buildUltraCompactStatCard(
                  context,
                  'WPM',
                  '$_wpm',
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
                const SizedBox(height: 8),
                _buildUltraCompactStatCard(
                  context,
                  'Correct',
                  '$_correct',
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
                const SizedBox(height: 8),
                _buildUltraCompactStatCard(
                  context,
                  'Incorrect',
                  '$_incorrect',
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
                const SizedBox(height: 8),
                _buildUltraCompactStatCard(
                  context,
                  'Accuracy',
                  '${_getAccuracy().toInt()}%',
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}