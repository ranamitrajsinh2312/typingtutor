// =========================================================================
// ⌨️ KEYBOARD LESSON SCREEN - TYPING PRACTICE WITH LESSONS
// =========================================================================
//
// Supports atomic character-based typing for Indic scripts (Hindi/Gujarati)
// Each keystroke is matched against individual Unicode code points.
//
// =========================================================================

import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/utils/responsive_helper.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/services/atomic_typing_service.dart';
import 'package:get/get.dart';

class KeyboardLessonScreen extends StatefulWidget {
  final KeyboardLesson lesson;
  final String languageCode;

  const KeyboardLessonScreen({
    super.key,
    required this.lesson,
    required this.languageCode,
  });

  @override
  State<KeyboardLessonScreen> createState() => _KeyboardLessonScreenState();
}

class _KeyboardLessonScreenState extends State<KeyboardLessonScreen> {
  // Keyboard layout
  late List<List<String>> _keyboardLayout;

  // State variables - use atomic units for proper Unicode (code points)
  // Each matra, virama, etc. is a separate typing unit
  late String test;
  late List<String> testChars; // Atomic units (code points)
  List<Color> colors = [];

  // Progress tracking
  int count = 0;
  int correct = 0;
  int incorrect = 0;
  int wpm = 0;

  // Game state
  DateTime? startTime;
  bool isGameStarted = false;
  bool isShiftPressed = false;

  // UI state
  Timer? _timer;
  String? wrongKey;
  DateTime? wrongKeyTime;

  // Controllers and keys
  final ScrollController _textScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  TypingController? _typingController;
  GlobalKey? _currentCharacterKey;

  // Keyboard state
  late List<List<String>> keys;
  late List<List<Color>> keyColors;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeTypingController();
    _initializeKeyboard();
    _loadLesson();

    // Ensure focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _initializeTypingController() {
    if (!Get.isRegistered<TypingController>()) {
      Get.put(TypingController());
    }
    _typingController = Get.find<TypingController>();
    _typingController!.setLanguage(widget.languageCode);
  }

  void _initializeKeyboard() {
    // Get keyboard layout for the current language
    _keyboardLayout = KeyboardLessonsData.getKeyboardLayoutForLanguage(
      widget.languageCode,
    );

    // Initialize keyboard keys from layout
    keys = _keyboardLayout.map((row) => List<String>.from(row)).toList();

    // Initialize keyboard colors based on layout structure
    keyColors =
        keys.map((row) => List.filled(row.length, Colors.white)).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textScrollController.dispose();
    _focusNode.dispose();
    // Reset to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _loadLesson() {
    setState(() {
      test = widget.lesson.practiceText + '   ';
      // Use atomic units for proper Unicode handling (Hindi/Gujarati)
      // Each matra, virama, etc. is a separate typing unit
      testChars = AtomicTypingService.splitIntoAtomicUnits(
        test,
        widget.languageCode,
      );
      colors = List.filled(testChars.length, Colors.grey.shade600);
      if (testChars.isNotEmpty) colors[0] = Colors.blue.shade700;
      count = 0;
      correct = 0;
      incorrect = 0;
      wpm = 0;
      startTime = null;
      isGameStarted = false;
      isShiftPressed = false;
      _currentCharacterKey = null;

      // Reset all key colors
      for (var row in keyColors) {
        for (int i = 0; i < row.length; i++) {
          row[i] = Colors.white;
        }
      }

      // Highlight keys for this lesson
      _highlightLessonKeys();

      // Highlight current key
      _highlightCurrentKey(0, Colors.blue.shade700);
      if (_isShiftRequired()) _highlightShiftKey(true);
    });
  }

  // =========================================================================
  // 👆 HAND IMAGE HELPERS - Supports English, Hindi, and Gujarati
  // =========================================================================

  /// Get left hand image path for current character
  String _getLeftHandImage() {
    if (count >= testChars.length) {
      return AppConstants.leftDefaultImage;
    }
    return AppConstants.getLeftHandImage(testChars[count]);
  }

  /// Get right hand image path for current character
  String _getRightHandImage() {
    if (count >= testChars.length) {
      return AppConstants.rightDefaultImage;
    }
    return AppConstants.getRightHandImage(testChars[count]);
  }

  void _highlightLessonKeys() {
    // Highlight all keys that are part of this lesson
    for (String key in widget.lesson.highlightKeys) {
      for (int row = 0; row < keys.length; row++) {
        for (int col = 0; col < keys[row].length; col++) {
          if (keys[row][col].toUpperCase() == key.toUpperCase()) {
            keyColors[row][col] = Colors.orange.shade200;
          }
        }
      }
    }
  }

  void _highlightCurrentKey(int charIndex, Color color) {
    if (charIndex >= testChars.length) return;
    String currentChar = testChars[charIndex];

    if (currentChar == ' ') {
      // Find SPACE key
      for (int row = 0; row < keys.length; row++) {
        for (int col = 0; col < keys[row].length; col++) {
          if (keys[row][col] == 'SPACE') {
            keyColors[row][col] = color;
            return;
          }
        }
      }
      return;
    }

    // For English, match uppercase
    String keyToHighlight =
        widget.languageCode == 'en' ? currentChar.toUpperCase() : currentChar;

    for (int row = 0; row < keys.length - 1; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == keyToHighlight ||
            keys[row][col].toUpperCase() == keyToHighlight.toUpperCase()) {
          keyColors[row][col] = color;
          return;
        }
      }
    }
  }

  void _removeKeyHighlight(int charIndex) {
    if (charIndex >= testChars.length || charIndex < 0) return;
    String prevChar = testChars[charIndex];

    if (prevChar == ' ') {
      for (int row = 0; row < keys.length; row++) {
        for (int col = 0; col < keys[row].length; col++) {
          if (keys[row][col] == 'SPACE') {
            // Reset to lesson highlight if this key is part of lesson
            keyColors[row][col] = Colors.white;
            return;
          }
        }
      }
      return;
    }

    String keyToRemove =
        widget.languageCode == 'en' ? prevChar.toUpperCase() : prevChar;

    for (int row = 0; row < keys.length - 1; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == keyToRemove ||
            keys[row][col].toUpperCase() == keyToRemove.toUpperCase()) {
          // Reset to lesson highlight color if this key is part of lesson
          bool isLessonKey = widget.lesson.highlightKeys.any(
            (k) => k.toUpperCase() == keys[row][col].toUpperCase(),
          );
          keyColors[row][col] =
              isLessonKey ? Colors.orange.shade200 : Colors.white;
          return;
        }
      }
    }
  }

  void _highlightShiftKey(bool highlight) {
    Color color = highlight ? Colors.blue.shade700 : Colors.white;
    for (int row = 0; row < keys.length; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == 'SHIFT') {
          keyColors[row][col] = color;
        }
      }
    }

    // Update keyboard layout when shift is pressed (for Hindi/Gujarati)
    if (widget.languageCode != 'en' && highlight != isShiftPressed) {
      setState(() {
        isShiftPressed = highlight;
        if (isShiftPressed) {
          keys =
              KeyboardLessonsData.getShiftKeyboardLayoutForLanguage(
                widget.languageCode,
              ).map((row) => List<String>.from(row)).toList();
        } else {
          keys =
              KeyboardLessonsData.getKeyboardLayoutForLanguage(
                widget.languageCode,
              ).map((row) => List<String>.from(row)).toList();
        }
        // Reset key colors
        keyColors =
            keys.map((row) => List.filled(row.length, Colors.white)).toList();
        // Re-highlight current key
        if (count < testChars.length) {
          _highlightCurrentKey(count, Colors.blue.shade700);
        }
      });
    }
  }

  bool _isShiftRequired() {
    if (count >= testChars.length) return false;
    String currentChar = testChars[count];

    // For English: check if uppercase letter
    if (widget.languageCode == 'en') {
      final codeUnits = currentChar.codeUnits;
      if (codeUnits.isEmpty) return false;
      return codeUnits[0] >= 65 && codeUnits[0] <= 90;
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
    return widget.lesson.highlightKeys;
  }

  String _getElapsedTime() {
    if (startTime == null) return '00:00';
    final elapsed = DateTime.now().difference(startTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getAccuracy() {
    if (correct + incorrect == 0) return 100;
    return (correct / (correct + incorrect) * 100).clamp(0, 100);
  }

  double _getProgressPercentage() {
    if (testChars.isEmpty) return 0;
    return (count / testChars.length * 100).clamp(0, 100);
  }

  void _calculateStats() {
    if (startTime != null) {
      final elapsed = DateTime.now().difference(startTime!).inSeconds;
      if (elapsed > 0) {
        setState(() {
          // Unicode-safe WPM using atomic units
          wpm = AtomicTypingService.calculateWpm(correct, elapsed);
        });
      }
    }
  }

  void _scrollToCurrentPosition() {
    if (!_textScrollController.hasClients || count >= testChars.length) return;

    final currentCharKey = _currentCharacterKey;
    if (currentCharKey?.currentContext != null) {
      Scrollable.ensureVisible(
        currentCharKey!.currentContext!,
        duration: AppDurations.scrollFast,
        curve: Curves.easeOutQuad,
        alignment: 0.3,
      );
    }
  }

  void _startGame() {
    if (!isGameStarted) {
      setState(() {
        startTime = DateTime.now();
        isGameStarted = true;
      });
      _timer = Timer.periodic(AppDurations.statsTick, (timer) {
        if (mounted) {
          _calculateStats();
        }
      });
    }
  }

  void _highlightWrongKey(String key) {
    setState(() {
      wrongKey = key.toUpperCase();
      wrongKeyTime = DateTime.now();
    });
    Future.delayed(AppDurations.wrongKeyHintShort, () {
      if (mounted &&
          wrongKeyTime != null &&
          DateTime.now().difference(wrongKeyTime!).inSeconds >= 1) {
        setState(() {
          wrongKey = null;
          wrongKeyTime = null;
        });
      }
    });
  }

  void _handleCorrectInput() {
    setState(() {
      if (count < colors.length) {
        colors[count] = Colors.green;
      }
      correct++;
      _removeKeyHighlight(count);
      count++;
      _currentCharacterKey = GlobalKey();
      if (count < testChars.length) {
        if (count < colors.length) {
          colors[count] = Colors.blue.shade700;
        }
        _highlightCurrentKey(count, Colors.blue.shade700);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        } else {
          _highlightShiftKey(false);
        }
      } else {
        _highlightShiftKey(false);
        _timer?.cancel();
        _showCompletionDialog();
      }
      _calculateStats();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentPosition();
      });
    });
  }

  void _handleIncorrectInput(String inputKey) {
    setState(() {
      if (count < colors.length) {
        colors[count] = Colors.red;
      }
      incorrect++;
      String wrongKeyToHighlight =
          inputKey == ' ' ? 'SPACE' : inputKey.toUpperCase();
      _highlightWrongKey(wrongKeyToHighlight);
      _removeKeyHighlight(count);
      count++;
      _currentCharacterKey = GlobalKey();
      if (count < testChars.length) {
        if (count < colors.length) {
          colors[count] = Colors.blue.shade700;
        }
        _highlightCurrentKey(count, Colors.blue.shade700);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        } else {
          _highlightShiftKey(false);
        }
      } else {
        _highlightShiftKey(false);
        _timer?.cancel();
        _showCompletionDialog();
      }
      _calculateStats();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentPosition();
      });
    });
  }

  void _processKeyInput(RawKeyEvent event) {
    if (event is! RawKeyDownEvent || count >= testChars.length) return;

    _startGame();

    String expectedChar = testChars[count];
    final key = event.logicalKey;

    // Handle shift keys
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight) {
      setState(() {
        isShiftPressed = event.isShiftPressed;
        if (_isShiftRequired()) {
          _highlightShiftKey(isShiftPressed);
        }
      });
      return;
    }

    // Handle space
    if (key == LogicalKeyboardKey.space) {
      if (expectedChar == ' ') {
        _handleCorrectInput();
      } else {
        _handleIncorrectInput('SPACE');
      }
      return;
    }

    // Use TypingController to map physical key to language character
    final result = _typingController?.processKeyEvent(event);
    if (result == null || result.mappedChar.isEmpty) return;

    String mappedChar = result.mappedChar;

    // Compare mapped character with expected character using atomic units
    bool isCorrect = AtomicTypingService.compareAtomicUnits(
      mappedChar,
      expectedChar,
      widget.languageCode,
    );

    if (isCorrect) {
      _handleCorrectInput();
    } else {
      _handleIncorrectInput(mappedChar);
    }
  }

  Future<void> _saveRecord() async {
    try {
      final accuracy = _getAccuracy();
      final stars = KeyboardLessonResult.calculateStars(accuracy, wpm);

      // Save to database
      await DatabaseHelper.instance.saveKeyboardLessonProgress(
        lessonId: widget.lesson.id,
        languageCode: widget.languageCode,
        isCompleted: true,
        starsEarned: stars,
        wpm: wpm,
        accuracy: accuracy,
      );
    } catch (e) {
      debugPrint('Error saving keyboard lesson record: $e');
    }
  }

  void _showCompletionDialog() {
    _saveRecord();
    final accuracy = _getAccuracy();
    final stars = KeyboardLessonResult.calculateStars(accuracy, wpm);

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
                      color: const Color(0xFF1A2035),
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
                    widget.lesson.title,
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
                _loadLesson(); // Retry the same lesson
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

  Widget _buildParagraphText() {
    final width = MediaQuery.of(context).size.width;
    final baseFontSize = width < 800 ? 16.0 : 18.0;

    if (count < testChars.length && _currentCharacterKey == null) {
      _currentCharacterKey = GlobalKey();
    }

    final spans = List.generate(testChars.length, (i) {
      Color backgroundColor = Colors.transparent;
      Color borderColor = Colors.transparent;
      Color textColor = Colors.black87;

      if (colors[i] == Colors.green) {
        backgroundColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade800;
      } else if (colors[i] == Colors.red) {
        backgroundColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red.shade700;
      } else if (colors[i] == Colors.blue.shade700) {
        backgroundColor = Colors.blue.withOpacity(0.15);
        borderColor = Colors.blue.shade700;
        textColor = Colors.blue.shade800;
      }

      if (i == count) {
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            key: _currentCharacterKey,
            padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
            margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    borderColor != Colors.transparent
                        ? borderColor
                        : Colors.blue.shade700,
                width: 1.0,
              ),
            ),
            child: Text(
              testChars[i] == ' ' ? ' ' : testChars[i],
              style: TextStyle(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
        );
      }

      return TextSpan(
        text: testChars[i] == ' ' ? ' ' : testChars[i],
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w500,
          color: textColor,
          backgroundColor:
              backgroundColor == Colors.transparent ? null : backgroundColor,
          height: 1.5,
          letterSpacing: 1.0,
        ),
      );
    });

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: width - 136.0),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      child: SingleChildScrollView(
        controller: _textScrollController,
        child: RichText(text: TextSpan(children: spans)),
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

  Widget _buildVerticalStats(BuildContext context) {
    const sidebarWidth = 110.0;
    return Container(
      width: sidebarWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF0D1B6E)],
        ),
      ),
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
            _buildVerticalStatCard(context, 'WPM', '$wpm'),
            _buildVerticalStatCard(context, 'Correct', '$correct'),
            _buildVerticalStatCard(context, 'Incorrect', '$incorrect'),
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
                    value: _getProgressPercentage() / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade200,
                    ),
                    minHeight: 3.0,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    '${_getProgressPercentage().toInt()}%',
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
      _buildStatRow(context, 'WPM:', wpm.toString(), Colors.blue),
      _buildStatRow(
        context,
        'Accuracy:',
        '${_getAccuracy().toInt()}%',
        Colors.green,
      ),
      _buildStatRow(context, 'Correct:', correct.toString(), Colors.green),
      _buildStatRow(context, 'Wrong:', incorrect.toString(), Colors.red),
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
          autofocus: true,
          focusNode: _focusNode,
          onKey: _processKeyInput,
          child: Row(
            children: <Widget>[
              // Main content area (text + keyboard)
              Expanded(
                flex: 7,
                child: Column(
                  children: <Widget>[
                    // Text area - top section
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 4.0),
                        child: SingleChildScrollView(
                          controller: _textScrollController,
                          physics: const ClampingScrollPhysics(),
                          child: _buildParagraphText(),
                        ),
                      ),
                    ),
                    // Keyboard area with hand images - bottom section
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left hand image
                            Flexible(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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
                                keys: keys,
                                keyColors: keyColors,
                                currentChar:
                                    count < testChars.length
                                        ? testChars[count]
                                        : '',
                                requiredKeys: _getRequiredKeys(),
                                wrongKey: wrongKey,
                                testString: test,
                                currentIndex: count,
                                onKeyPressed: (String key) {},
                                isLandscape: true,
                              ),
                            ),
                            // Right hand image
                            Flexible(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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
                      ),
                    ),
                  ],
                ),
              ),
              // Stats sidebar - right side
              _buildVerticalStats(context),
            ],
          ),
        ),
      ),
    );
  }
}
