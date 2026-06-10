// =========================================================================
// ⌨️ LEVEL PRACTICE SCREEN - TYPING PRACTICE FOR LEVELS
// =========================================================================
//
// Supports atomic character-based typing for Indic scripts (Hindi/Gujarati)
// Each keystroke is matched against individual Unicode code points.
//
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
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;

  // Keyboard state
  late List<List<String>> _keys;
  late List<List<Color>> _keyColors;
  bool _isShiftPressed = false;

  // Game state - Use atomic units for proper Unicode support (code points)
  // Each matra, virama, etc. is a separate typing unit
  String _typingText = '';
  List<String> _typingChars = []; // Atomic units for proper Unicode
  List<Color> _charColors = [];
  int _currentIndex = 0; // Index into _typingChars (atomic units)
  int _correct = 0; // Correct atomic units
  int _incorrect = 0; // Incorrect atomic units
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
        // Convert to atomic units for proper Unicode handling (Hindi/Gujarati)
        // Each matra, virama, etc. is a separate typing unit
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
          // Unicode-safe WPM using atomic units
          // Each keystroke (code point) counts as 1 unit
          // Standard: 5 units = 1 word
          _wpm = AtomicTypingService.calculateWpm(_correct, elapsed);
        });
      }
    }
  }

  double _getAccuracy() {
    final total = _correct + _incorrect;
    if (total == 0) return 100.0;
    // Unicode-safe accuracy: Correct atomic units / Total * 100
    return (_correct / total * 100).clamp(0.0, 100.0);
  }

  double _getProgress() {
    if (_typingChars.isEmpty) return 0.0;
    // Progress based on atomic units count
    return (_currentIndex / _typingChars.length * 100).clamp(0.0, 100.0);
  }

  /// Get character at current index (atomic unit)
  String _getCurrentChar() {
    if (_currentIndex >= _typingChars.length) return '';
    return _typingChars[_currentIndex];
  }

  /// Get character at specific index (atomic unit)
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

    // Compare characters - Unicode safe using atomic units
    // For English: case-insensitive comparison
    // For Hindi/Gujarati: exact code point match
    bool isCorrect = AtomicTypingService.compareAtomicUnits(
      inputChar,
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

    final starsEarned = LevelCompletionResult.calculateStars(
      _wpm,
      _getAccuracy(),
    );

    // Show completion dialog instead of navigating to separate screen
    _showCompletionDialog(starsEarned);
  }

  void _showCompletionDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFD8469), Color(0xFFFF6B35)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration, color: Colors.white, size: 30),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    stars >= 3
                        ? 'Excellent!'
                        : stars >= 2
                        ? 'Great Job!'
                        : 'Completed!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        FontSizeType.medium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 10.0),
                  // Stars display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '${widget.type.displayName} - Level ${widget.level.id}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        FontSizeType.small,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  _buildResultStats(context),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadContent(); // Retry the same level
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD8469),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    MaterialColor color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  FontSizeType.small,
                ),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 5.0,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    FontSizeType.small,
                  ),
                  fontWeight: FontWeight.bold,
                  color: color.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStats(BuildContext context) {
    final children = <Widget>[
      _buildStatRow(context, 'Time:', _getElapsedTime(), Colors.purple),
      _buildStatRow(context, 'WPM:', _wpm.toString(), Colors.blue),
      _buildStatRow(
        context,
        'Accuracy:',
        '${_getAccuracy().toInt()}%',
        Colors.green,
      ),
      _buildStatRow(context, 'Correct:', _correct.toString(), Colors.green),
      _buildStatRow(context, 'Wrong:', _incorrect.toString(), Colors.red),
    ];

    final dialogWidth = MediaQuery.of(context).size.width * 0.9;
    final itemWidth = (dialogWidth - 30.0) / 2.0;
    return Wrap(
      spacing: 10.0,
      runSpacing: 6.0,
      children:
          children.map((w) => SizedBox(width: itemWidth, child: w)).toList(),
    );
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
        backgroundColor: Colors.grey.shade100,
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
    const sidebarWidth = 110.0;
    return Container(
      width: sidebarWidth,
      color: Colors.blue.shade800,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Language indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              margin: const EdgeInsets.only(bottom: 6.0),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    KeyboardLessonsData.getLanguageFlag(widget.languageCode),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    KeyboardLessonsData.getLanguageName(widget.languageCode),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _buildVerticalStatCard(context, 'Time', _getElapsedTime()),
            _buildVerticalStatCard(context, 'WPM', '$_wpm'),
            _buildVerticalStatCard(context, 'Correct', '$_correct'),
            _buildVerticalStatCard(context, 'Incorrect', '$_incorrect'),
            _buildVerticalStatCard(
              context,
              'Accuracy',
              '${_getAccuracy().toInt()}%',
            ),
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
    // Add hand images like in keyboard_lesson_screen
    return Container(
      margin: const EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left hand image
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(
                _getLeftHandImage(),
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.back_hand_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Keyboard
          Expanded(
            flex: 8,
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
            ),
          ),
          // Right hand image
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(
                _getRightHandImage(),
                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.back_hand_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 👆 HAND IMAGE HELPERS - Supports English, Hindi, and Gujarati
  // =========================================================================

  /// Get left hand image path for current character
  String _getLeftHandImage() {
    if (_currentIndex >= _typingChars.length) {
      return AppConstants.leftDefaultImage;
    }
    return AppConstants.getLeftHandImage(_typingChars[_currentIndex]);
  }

  /// Get right hand image path for current character
  String _getRightHandImage() {
    if (_currentIndex >= _typingChars.length) {
      return AppConstants.rightDefaultImage;
    }
    return AppConstants.getRightHandImage(_typingChars[_currentIndex]);
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
