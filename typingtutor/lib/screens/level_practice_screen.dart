// =========================================================================
// ⌨️ LEVEL PRACTICE SCREEN - TYPING PRACTICE FOR LEVELS
// =========================================================================
//
// UI matches PracticeScreen exactly:
// - Colors.grey.shade100 background
// - Colors.blue.shade800 stats sidebar on the right (110px)
// - Same white semi-transparent stat card style
// - Typing text: white card, vertical scroll, Wrap layout
// - No hand diagrams, full-screen landscape
//
// Supports atomic character-based typing for Indic scripts (Hindi/Gujarati)
// =========================================================================

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
import 'package:typingtutor/services/indic_key_mappings.dart';

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
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;

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

  // Current char key for scroll (same approach as PracticeScreen)
  GlobalKey? _currentCharacterKey;

  // Focus
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeControllers();
    _setupAnimations();
    _loadContent();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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

  void _highlightCurrentKey(int charIndex, Color color) {
    if (charIndex >= _typingChars.length) return;
    String currentChar = _getCharAt(charIndex);

    if (_keyboardController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardController != null) {
          _keyboardController!.highlightKeyByChar(currentChar);
        }
      });
      if (widget.languageCode == 'en') {
        _updateLocalKeyColor(currentChar, color);
      }
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
        if (mounted && _keyboardController != null) {
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
    Color color = highlight ? Colors.blue.shade700 : Colors.white;
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
        _highlightCurrentKey(_currentIndex, Colors.blue.shade700);
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
      final shiftLayout = KeyboardLessonsData.hindiShiftKeyboardLayout;
      for (var row in shiftLayout) {
        if (row.contains(currentChar)) return true;
      }
      return false;
    }
    if (widget.languageCode == 'gu') {
      final shiftLayout = KeyboardLessonsData.gujaratiShiftKeyboardLayout;
      for (var row in shiftLayout) {
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

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

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
        _charColors = List.filled(_typingChars.length, Colors.grey.shade600);
        if (_typingChars.isNotEmpty) {
          _charColors[0] = Colors.blue.shade700;
        }
        _currentIndex = 0;
        _correct = 0;
        _incorrect = 0;
        _wpm = 0;
        _isGameStarted = false;
        _isCompleted = false;
        _currentCharacterKey = null;
      });

      for (var row in _keyColors) {
        for (int i = 0; i < row.length; i++) {
          row[i] = Colors.white;
        }
      }
      _highlightCurrentKey(0, Colors.blue.shade700);
      if (_isShiftRequired()) _highlightShiftKey(true);
    }
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
  // GAME LOGIC
  // =========================================================================

  void _startGame() {
    if (!_isGameStarted) {
      setState(() {
        _startTime = DateTime.now();
        _isGameStarted = true;
      });
      _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && !_isCompleted) _calculateStats();
      });
    }
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

  double _getAccuracy() {
    final total = _correct + _incorrect;
    if (total == 0) return 100.0;
    return (_correct / total * 100).clamp(0.0, 100.0);
  }

  double _getProgress() {
    if (_typingChars.isEmpty) return 0.0;
    return (_currentIndex / _typingChars.length * 100).clamp(0.0, 100.0);
  }

  String _getCurrentChar() {
    if (_currentIndex >= _typingChars.length) return '';
    return _typingChars[_currentIndex];
  }

  String _getCharAt(int index) {
    if (index < 0 || index >= _typingChars.length) return '';
    return _typingChars[index];
  }

  String _getElapsedTime() {
    if (_startTime == null) return '00:00';
    final elapsed = DateTime.now().difference(_startTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    setState(() {
      _charColors[_currentIndex] = Colors.green;
      _correct++;
      _removeKeyHighlight(_currentIndex);
      if (_isShiftRequired()) _highlightShiftKey(false);
      _currentIndex++;
      _currentCharacterKey = GlobalKey();
      _wrongKey = null;

      if (_currentIndex < _typingChars.length) {
        _charColors[_currentIndex] = Colors.blue.shade700;
        _highlightCurrentKey(_currentIndex, Colors.blue.shade700);
        if (_isShiftRequired()) _highlightShiftKey(true);
      } else {
        _highlightShiftKey(false);
        _completeLevel();
      }
      _calculateStats();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPosition();
    });

    HapticFeedback.lightImpact();
  }

  void _handleIncorrectInput(String key) {
    setState(() {
      _charColors[_currentIndex] = Colors.red;
      _incorrect++;
      _wrongKey = key == 'SPACE' ? 'SPACE' : key.toUpperCase();
      _wrongKeyTime = DateTime.now();
    });

    if (_keyboardController != null) {
      final expectedChar = _getCurrentChar();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardController != null) {
          _keyboardController!.showKeyErrorByChar(expectedChar);
        }
      });
    }

    _shakeController.forward().then((_) => _shakeController.reverse());
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted &&
          _wrongKeyTime != null &&
          DateTime.now().difference(_wrongKeyTime!).inMilliseconds >= 800) {
        setState(() {
          _wrongKey = null;
          _wrongKeyTime = null;
        });
      }
    });
  }

  void _handleBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        if (_currentIndex < _charColors.length) {
          _charColors[_currentIndex] = Colors.grey.shade600;
        }
        _removeKeyHighlight(_currentIndex);
        if (_isShiftRequired()) _highlightShiftKey(false);
        _currentIndex--;
        _charColors[_currentIndex] = Colors.blue.shade700;
        _highlightCurrentKey(_currentIndex, Colors.blue.shade700);
        if (_isShiftRequired()) _highlightShiftKey(true);
        _currentCharacterKey = GlobalKey();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentPosition();
      });
    }
  }

  void _scrollToCurrentPosition() {
    final currentCharKey = _currentCharacterKey;
    if (currentCharKey?.currentContext != null) {
      Scrollable.ensureVisible(
        currentCharKey!.currentContext!,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
        alignment: 0.3,
      );
    }
  }

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
        languageCode: widget.languageCode,
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
    _statsTimer?.cancel();
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
      Get.off(
        () => LevelCompletionScreen(
          result: result,
          level: widget.level,
          type: widget.type,
          languageCode: widget.languageCode,
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
    });
  }

  // =========================================================================
  // BUILD UI  —  mirrors PracticeScreen layout exactly
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        top: false,
        bottom: false,
        left: false,
        right: false,
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
                setState(() => _isShiftPressed = true);
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
                setState(() => _isShiftPressed = false);
              }
            }
          },
          child: Row(
            children: <Widget>[
              // ── Main content (text + keyboard) ──────────────────────────
              Expanded(
                flex: 7,
                child: Column(
                  children: <Widget>[
                    // Text area
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 4.0),
                        child: _buildParagraphText(),
                      ),
                    ),
                    // Keyboard area
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 8.0),
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
                          languageCode: widget.languageCode,
                          indicToPhysical:
                              widget.languageCode == 'hi'
                                  ? IndicKeyMappings.hindiReverseKeyMap
                                  : widget.languageCode == 'gu'
                                  ? IndicKeyMappings.gujaratiReverseKeyMap
                                  : const {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Stats sidebar (right) ────────────────────────────────────
              _buildVerticalStats(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Text area: white card + vertical scroll Wrap ──────────────────────────

  Widget _buildParagraphText() {
    final width = MediaQuery.of(context).size.width;
    final baseFontSize = width < 800 ? 16.0 : 18.0;

    if (_currentIndex < _typingChars.length && _currentCharacterKey == null) {
      _currentCharacterKey = GlobalKey();
    }

    final textWidgets = List.generate(_typingChars.length, (i) {
      final char = _getCharAt(i);
      final isCurrent = i == _currentIndex;

      Color backgroundColor = Colors.transparent;
      Color borderColor = Colors.transparent;
      Color textColor = const Color(0xFFD0D8EF);

      if (_charColors[i] == Colors.green) {
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade800;
      } else if (_charColors[i] == Colors.red) {
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red.shade700;
      } else if (_charColors[i] == Colors.blue.shade700) {
        backgroundColor = Colors.blue.withOpacity(0.15);
        borderColor = Colors.blue.shade700;
        textColor = Colors.blue.shade800;
      }

      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return Transform.scale(
            scale: isCurrent ? _pulseAnimation.value : 1.0,
            child: Container(
              key: isCurrent ? _currentCharacterKey : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 3.0,
                vertical: 2.0,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 0.5,
                vertical: 1.0,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
                border:
                    borderColor != Colors.transparent
                        ? Border.all(color: borderColor, width: 1.0)
                        : null,
              ),
              child: Text(
                char == ' ' ? ' ' : char,
                style: TextStyle(
                  fontSize: baseFontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
          );
        },
      );
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Obx(() {
        if (_levelsController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_levelsController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.red),
                const SizedBox(height: 12),
                Text(_levelsController.errorMessage),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadContent,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          controller: _textScrollController,
          physics: const ClampingScrollPhysics(),
          child: Wrap(spacing: 1.0, runSpacing: 6.0, children: textWidgets),
        );
      }),
    );
  }

  // ── Stats sidebar — identical style to PracticeScreen ─────────────────────

  Widget _buildVerticalStatCard(
    BuildContext context,
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      margin: const EdgeInsets.only(bottom: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalStats(BuildContext context) {
    const sidebarWidth = 110.0;
    return Container(
      width: sidebarWidth,
      color: const Color(0xFF1A237E),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildVerticalStatCard(context, 'Time', _getElapsedTime()),
            _buildVerticalStatCard(context, 'WPM', '$_wpm'),
            _buildVerticalStatCard(context, 'Correct', '$_correct'),
            _buildVerticalStatCard(context, 'Incorrect', '$_incorrect'),
            _buildVerticalStatCard(
              context,
              'Accuracy',
              '${_getAccuracy().toInt()}%',
            ),
            // Progress card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              margin: const EdgeInsets.only(bottom: 6.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: <Widget>[
                  const Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: _getProgress() / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade200,
                    ),
                    minHeight: 3.0,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    '${_getProgress().toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _sidebarWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w < 500 ? 80.0 : (w < 800 ? 96.0 : 110.0);
  }
}
