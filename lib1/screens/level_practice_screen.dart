// =========================================================================
// ⌨️ LEVEL PRACTICE SCREEN - TYPING PRACTICE FOR LEVELS
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

  // Game state - Use grapheme clusters for proper Unicode support
  String _typingText = '';
  List<String> _typingChars = []; // Grapheme clusters for proper Unicode
  List<Color> _charColors = [];
  int _currentIndex = 0; // Index into _typingChars
  int _correct = 0; // Correct Unicode characters
  int _incorrect = 0; // Incorrect Unicode characters
  int _wpm = 0;
  DateTime? _startTime;
  bool _isGameStarted = false;
  bool _isCompleted = false;
  Timer? _statsTimer;
  String? _wrongKey;
  DateTime? _wrongKeyTime;

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

    // Ensure focus is maintained
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _initializeControllers() {
    if (!Get.isRegistered<LevelsController>()) {
      Get.put(LevelsController());
    }
    _levelsController = Get.find<LevelsController>();

    // Always initialize KeyboardController for all languages
    if (!Get.isRegistered<KeyboardController>()) {
      Get.put(KeyboardController());
    }
    _keyboardController = Get.find<KeyboardController>();

    // Initialize TypingController for physical key mapping
    if (!Get.isRegistered<TypingController>()) {
      Get.put(TypingController());
    }
    _typingController = Get.find<TypingController>();
    _typingController!.setLanguage(widget.languageCode);

    // Set keyboard language immediately (without triggering rebuild during build)
    // The layout will be set synchronously, update() deferred
    _keyboardController!.changeLanguageSilent(widget.languageCode);

    _initializeKeyboard();
  }

  void _initializeKeyboard() {
    // Get keyboard layout based on language code
    final keyboardLayout = KeyboardLessonsData.getKeyboardLayoutForLanguage(
      widget.languageCode,
    );

    // Initialize keyboard layout
    _keys = keyboardLayout.map((row) => List<String>.from(row)).toList();

    // Initialize keyboard colors based on layout size
    _keyColors =
        _keys.map((row) => List.filled(row.length, Colors.white)).toList();
  }

  void _highlightCurrentKey(int charIndex, Color color) {
    if (charIndex >= _typingChars.length) return;
    String currentChar = _getCharAt(charIndex);

    // For all languages, use KeyboardController for highlighting (deferred to avoid build issues)
    if (_keyboardController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardController != null) {
          _keyboardController!.highlightKeyByChar(currentChar);
        }
      });
      // For English, also update local key colors
      if (widget.languageCode == 'en') {
        _updateLocalKeyColor(currentChar, color);
      }
      return;
    }

    // Fallback for when controller not available
    _updateLocalKeyColor(currentChar, color);
  }

  void _updateLocalKeyColor(String currentChar, Color color) {
    // For space, highlight the spacebar (last row, first key)
    if (currentChar == ' ') {
      if (_keys.isNotEmpty && _keys.last.isNotEmpty) {
        _keyColors[_keys.length - 1][0] = color;
      }
      return;
    }

    // For other characters, search through the keyboard
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

    // For all languages, use KeyboardController (deferred to avoid build issues)
    if (_keyboardController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardController != null) {
          _keyboardController!.clearHighlight();
        }
      });
      // For English, also update local key colors
      if (widget.languageCode == 'en') {
        _clearLocalKeyColor(prevChar);
      }
      return;
    }

    // Fallback
    _clearLocalKeyColor(prevChar);
  }

  void _clearLocalKeyColor(String prevChar) {
    // For space, clear the spacebar highlight
    if (prevChar == ' ') {
      if (_keys.isNotEmpty && _keys.last.isNotEmpty) {
        _keyColors[_keys.length - 1][0] = Colors.white;
      }
      return;
    }

    // For other characters, search through the keyboard
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
    // Highlight shift key for all languages
    Color color = highlight ? Colors.blue.shade700 : Colors.white;
    // Shift keys are typically at row index 2, positions 0 and last
    if (_keys.length > 2 && _keys[2].isNotEmpty) {
      _keyColors[2][0] = color;
      if (_keys[2].length > 1) {
        _keyColors[2][_keys[2].length - 1] = color;
      }
    }

    // Update keyboard layout when shift is pressed (for Hindi/Gujarati)
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
        // Reset key colors
        _keyColors =
            _keys.map((row) => List.filled(row.length, Colors.white)).toList();
        // Re-highlight current key
        _highlightCurrentKey(_currentIndex, Colors.blue.shade700);
      });
    }
  }

  bool _isShiftRequired() {
    if (_currentIndex >= _typingChars.length) return false;
    final currentChar = _getCurrentChar();
    if (currentChar.isEmpty) return false;

    // For English: check if uppercase letter
    if (widget.languageCode == 'en') {
      final codeUnit = currentChar.codeUnitAt(0);
      return codeUnit >= 65 && codeUnit <= 90;
    }

    // For Hindi: check if character is in shift layout
    if (widget.languageCode == 'hi') {
      final shiftLayout = KeyboardLessonsData.hindiShiftKeyboardLayout;
      for (var row in shiftLayout) {
        if (row.contains(currentChar)) {
          return true;
        }
      }
      return false;
    }

    // For Gujarati: check if character is in shift layout
    if (widget.languageCode == 'gu') {
      final shiftLayout = KeyboardLessonsData.gujaratiShiftKeyboardLayout;
      for (var row in shiftLayout) {
        if (row.contains(currentChar)) {
          return true;
        }
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
    // Ensure levels controller uses the correct language
    if (_levelsController.currentLanguage != widget.languageCode) {
      _levelsController.changeLanguage(widget.languageCode);
    }

    await _levelsController.fetchContent(widget.level);

    // Combine all content into typing text
    final content = _levelsController.currentContent;
    if (content.isNotEmpty) {
      setState(() {
        _typingText = content.map((c) => c.text).join(' ');
        // Convert to grapheme clusters for proper Unicode handling (Hindi/Gujarati)
        _typingChars = _typingText.characters.toList();
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
      });

      // Highlight first key and reset keyboard colors
      for (var row in _keyColors) {
        for (int i = 0; i < row.length; i++) {
          row[i] = Colors.white;
        }
      }
      _highlightCurrentKey(0, Colors.blue.shade700);
      if (_isShiftRequired()) _highlightShiftKey(true);
    }

    // Request focus for keyboard input
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

      // Start stats timer
      _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && !_isCompleted) {
          _calculateStats();
        }
      });
    }
  }

  void _calculateStats() {
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      if (elapsed > 0) {
        setState(() {
          // Unicode-safe WPM: (Correct characters / 5) / Time in minutes
          // Each Unicode code point counts as 1 character
          _wpm = ((_correct / 5) / (elapsed / 60)).round();
        });
      }
    }
  }

  double _getAccuracy() {
    final total = _correct + _incorrect;
    if (total == 0) return 100.0;
    // Unicode-safe accuracy: Correct / Total * 100
    return (_correct / total * 100).clamp(0.0, 100.0);
  }

  double _getProgress() {
    if (_typingChars.isEmpty) return 0.0;
    // Progress based on Unicode grapheme cluster count
    return (_currentIndex / _typingChars.length * 100).clamp(0.0, 100.0);
  }

  /// Get character at current index (Unicode-safe grapheme cluster)
  String _getCurrentChar() {
    if (_currentIndex >= _typingChars.length) return '';
    return _typingChars[_currentIndex];
  }

  /// Get character at specific index (Unicode-safe grapheme cluster)
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

    // Get expected character using Unicode-safe method
    final expectedChar = _getCurrentChar();
    final inputChar = key;

    // Handle special keys
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
      return; // Ignore modifier keys
    }

    // Compare characters - Unicode safe using grapheme clusters
    // For English: case-insensitive comparison
    // For Hindi/Gujarati: exact match (no case in Devanagari/Gujarati scripts)
    bool isCorrect;
    if (widget.languageCode == 'en') {
      isCorrect = inputChar.toLowerCase() == expectedChar.toLowerCase();
    } else {
      // For Indic scripts, compare grapheme clusters directly
      if (inputChar == expectedChar) {
        isCorrect = true;
      } else if (inputChar.characters.isNotEmpty &&
          expectedChar.characters.isNotEmpty) {
        // Compare first grapheme cluster
        isCorrect = inputChar.characters.first == expectedChar.characters.first;
      } else {
        isCorrect = false;
      }
    }

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

      // Remove highlight from current key
      _removeKeyHighlight(_currentIndex);
      if (_isShiftRequired()) _highlightShiftKey(false);

      _currentIndex++;

      // Clear error
      _wrongKey = null;

      if (_currentIndex < _typingChars.length) {
        _charColors[_currentIndex] = Colors.blue.shade700;
        _highlightCurrentKey(_currentIndex, Colors.blue.shade700);
        if (_isShiftRequired()) _highlightShiftKey(true);
        _scrollToCurrentPosition();
      } else {
        _completeLevel();
      }
    });

    HapticFeedback.lightImpact();
  }

  void _handleIncorrectInput(String key) {
    setState(() {
      _charColors[_currentIndex] = Colors.red;
      _incorrect++;
      _wrongKey = key;
      _wrongKeyTime = DateTime.now();
    });

    // Show error on keyboard for all languages (deferred to avoid build issues)
    if (_keyboardController != null) {
      final expectedChar = _getCurrentChar();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _keyboardController != null) {
          _keyboardController!.showKeyErrorByChar(expectedChar);
        }
      });
    }

    // Shake animation
    _shakeController.forward().then((_) => _shakeController.reverse());

    HapticFeedback.mediumImpact();

    // Clear error after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          if (_currentIndex < _charColors.length) {
            _charColors[_currentIndex] = Colors.blue.shade700;
          }
          _wrongKey = null;
        });
      }
    });
  }

  void _handleBackspace() {
    if (_currentIndex > 0) {
      setState(() {
        // Clear current highlight
        if (_currentIndex < _charColors.length) {
          _charColors[_currentIndex] = Colors.grey.shade600;
        }
        _removeKeyHighlight(_currentIndex);
        if (_isShiftRequired()) _highlightShiftKey(false);

        _currentIndex--;
        _charColors[_currentIndex] = Colors.blue.shade700;
        _highlightCurrentKey(_currentIndex, Colors.blue.shade700);
        if (_isShiftRequired()) _highlightShiftKey(true);
      });

      _scrollToCurrentPosition();
    }
  }

  void _scrollToCurrentPosition() {
    if (!_textScrollController.hasClients ||
        _currentIndex >= _typingChars.length)
      return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_textScrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final charWidth = screenWidth < 800 ? 14.0 : 16.0;
        final offset = (_currentIndex * charWidth) - (screenWidth / 4);

        _textScrollController.animateTo(
          offset.clamp(0.0, _textScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername =
          prefs.getString(AppKeys.username) ?? AppConstants.defaultUsername;

      // Save typing record
      final record = TypingRecord(
        username: savedUsername,
        country: AppConstants.defaultCountry,
        wpm: _wpm,
        accuracy: _getAccuracy(),
      );
      await DatabaseHelper.instance.insertRecord(record);

      // Save level progress
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

    // Save record to database
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

    // Update controller
    _levelsController.updateLevelCompletion(result);

    // Navigate to completion screen
    Future.delayed(const Duration(milliseconds: 500), () {
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
    });
  }

  // =========================================================================
  // BUILD UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
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
            });
          } else {
            // Use TypingController to map physical key to language character
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
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackgroundColor,
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              // Stats sidebar
              _buildStatsSidebar(),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Typing area
                    Expanded(flex: 3, child: _buildTypingArea()),

                    // Keyboard
                    Expanded(flex: 4, child: _buildKeyboard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _showExitConfirmation(),
          ),

          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.type.displayName} - Level ${widget.level.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  KeyboardLessonsData.getLanguageName(widget.languageCode),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.linear_scale, color: _getTypeColor(), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${_getProgress().toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSidebar() {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatBox('WPM', '$_wpm', Colors.blue),
          const SizedBox(height: 16),
          _buildStatBox(
            'Accuracy',
            '${_getAccuracy().toStringAsFixed(0)}%',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStatBox('Time', _getElapsedTime(), Colors.orange),
          const SizedBox(height: 16),
          _buildStatBox(
            'Chars',
            '$_currentIndex/${_typingChars.length}',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(_levelsController.errorMessage),
                const SizedBox(height: 16),
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
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_typingChars.length, (index) {
              final char = _getCharAt(index);
              final color = _charColors[index];
              final isCurrent = index == _currentIndex;

              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isCurrent ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.blue.shade100 : null,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            isCurrent
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                      ),
                      child: Text(
                        char == ' ' ? '␣' : char,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: color,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    // Use same keyboard UI (ModernKeyboardWidget) for all languages
    return Container(
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
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case PracticeType.word:
        return Colors.green;
      case PracticeType.sentence:
        return Colors.orange;
      case PracticeType.paragraph:
        return Colors.red;
    }
  }

  void _showExitConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Exit Practice?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
