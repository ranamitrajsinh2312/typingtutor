import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/utils/responsive_helper.dart';
import 'package:typingtutor/constants/app_constants.dart';

class PracticeScreen extends StatefulWidget {
  final String lessonType;
  final String difficulty;

  const PracticeScreen({
    super.key,
    required this.lessonType,
    required this.difficulty,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  // Keyboard layout
  static const List<List<String>> _keyboardLayout = AppConstants.keyboardLayout;

  // ==========================================================================
  // STATE VARIABLES
  // ==========================================================================

  // Lesson data
  late Lesson currentLesson;
  String test = '';
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
  GlobalKey? _currentCharacterKey;

  // Keyboard state
  late List<List<String>> keys;
  late List<List<Color>> keyColors;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation when this screen opens
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeKeyboard();
    _loadLesson();
  }

  // ==========================================================================
  // INITIALIZATION METHODS
  // ==========================================================================

  void _initializeKeyboard() {
    // Initialize keyboard layout from constants
    keys = _keyboardLayout.map((row) => List<String>.from(row)).toList();

    // Initialize keyboard colors
    keyColors = [
      List.filled(14, Colors.white),
      List.filled(13, Colors.white),
      List.filled(12, Colors.white),
      [Colors.white],
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textScrollController.dispose();
    // Reset to portrait orientation when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _loadLesson() {
    final filteredLessons =
        lessons
            .where(
              (lesson) =>
                  lesson.type == widget.lessonType &&
                  lesson.difficulty == widget.difficulty,
            )
            .toList();
    setState(() {
      currentLesson =
          filteredLessons.isNotEmpty
              ? filteredLessons[0]
              : Lesson(
                type: widget.lessonType,
                content: 'Sample ${widget.lessonType}',
                difficulty: widget.difficulty,
              );
      test = currentLesson.content + '   ';
      colors = List.filled(test.length, Colors.grey.shade600);
      if (test.isNotEmpty) colors[0] = Colors.blue.shade700;
      count = 0;
      correct = 0;
      incorrect = 0;
      wpm = 0;
      startTime = null;
      isGameStarted = false;
      isShiftPressed = false;
      _currentCharacterKey = null;
      for (var row in keyColors) {
        for (int i = 0; i < row.length; i++) {
          row[i] = Colors.white;
        }
      }
      _highlightCurrentKey(0, Colors.blue.shade700);
      if (_isShiftRequired()) _highlightShiftKey(true);
    });
  }

  void _highlightCurrentKey(int charIndex, Color color) {
    if (charIndex >= test.length) return;
    String currentChar = test[charIndex];
    if (currentChar == ' ') {
      keyColors[3][0] = color;
      return;
    }
    String keyToHighlight = currentChar.toUpperCase();
    for (int row = 0; row < keys.length - 1; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == keyToHighlight) {
          keyColors[row][col] = color;
          return;
        }
      }
    }
  }

  void _removeKeyHighlight(int charIndex) {
    if (charIndex >= test.length || charIndex < 0) return;
    String prevChar = test[charIndex];
    if (prevChar == ' ') {
      keyColors[3][0] = Colors.white;
      return;
    }
    String keyToRemove = prevChar.toUpperCase();
    for (int row = 0; row < keys.length - 1; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == keyToRemove) {
          keyColors[row][col] = Colors.white;
          return;
        }
      }
    }
  }

  void _highlightShiftKey(bool highlight) {
    Color color = highlight ? Colors.blue.shade700 : Colors.white;
    keyColors[2][0] = color;
    keyColors[2][11] = color;
  }

  bool _isShiftRequired() {
    if (count >= test.length) return false;
    String currentChar = test[count];
    return currentChar.codeUnitAt(0) >= 65 && currentChar.codeUnitAt(0) <= 90;
  }

  List<String> _getRequiredKeys() {
    List<String> requiredKeys = [];
    for (var row in keys) {
      requiredKeys.addAll(row);
    }
    return requiredKeys;
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
    if (test.isEmpty) return 0;
    return (count / test.length * 100).clamp(0, 100);
  }

  void _calculateStats() {
    if (startTime != null) {
      final elapsed = DateTime.now().difference(startTime!).inSeconds;
      if (elapsed > 0) {
        setState(() {
          wpm = ((correct / 5) / (elapsed / 60)).round();
        });
      }
    }
  }

  void _scrollToCurrentPosition() {
    if (!_textScrollController.hasClients || count >= test.length) return;

    final currentCharKey = _currentCharacterKey;
    if (currentCharKey?.currentContext != null) {
      Scrollable.ensureVisible(
        currentCharKey!.currentContext!,
        duration: AppDurations.scrollFast,
        curve: Curves.easeOutQuad,
        alignment: 0.3,
      );
    } else {
      // Fallback: Estimate scroll position if key is not yet rendered
      final width = MediaQuery.of(context).size.width;
      final baseFontSize = width < 800 ? 16.0 : 18.0;
      final lineHeight = baseFontSize * 1.4 + 8.0;
      final charWidth = baseFontSize * 0.6 + 6.0;
      final availableWidth = width - 136.0; // Account for sidebar and margins

      double currentLineOffset = 0;
      double currentLineWidth = 0;

      for (int i = 0; i <= count && i < test.length; i++) {
        final charWidthEstimate = test[i] == ' ' ? charWidth * 0.5 : charWidth;
        if (currentLineWidth + charWidthEstimate > availableWidth) {
          currentLineOffset += lineHeight;
          currentLineWidth = charWidthEstimate;
        } else {
          currentLineWidth += charWidthEstimate;
        }
      }

      final viewportHeight = _textScrollController.position.viewportDimension;
      final maxScrollOffset = _textScrollController.position.maxScrollExtent;
      final targetOffset = (currentLineOffset - viewportHeight * 0.3).clamp(
        0.0,
        maxScrollOffset,
      );

      _textScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
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
      if (count < test.length) {
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
      if (count < test.length) {
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
    if (event is! RawKeyDownEvent || count >= test.length) return;

    _startGame();

    String expectedChar = test[count];
    String inputKey = event.logicalKey.keyLabel ?? '';
    bool isShiftPressed = event.isShiftPressed;

    if (inputKey == 'Shift Left' || inputKey == 'Shift Right') {
      setState(() {
        this.isShiftPressed = isShiftPressed;
        if (_isShiftRequired()) {
          _highlightShiftKey(isShiftPressed);
        }
      });
      return;
    }

    bool isCorrect = false;
    if (expectedChar == ' ') {
      isCorrect = inputKey.toLowerCase() == 'space' || inputKey == ' ';
    } else if (_isShiftRequired()) {
      isCorrect =
          isShiftPressed &&
          inputKey.toLowerCase() == expectedChar.toLowerCase();
    } else {
      isCorrect =
          !isShiftPressed &&
          inputKey.toLowerCase() == expectedChar.toLowerCase();
    }

    if (isCorrect) {
      _handleCorrectInput();
    } else {
      _handleIncorrectInput(inputKey);
    }
  }

  void _loadNextLesson() {
    final filteredLessons =
        lessons
            .where(
              (lesson) =>
                  lesson.type == widget.lessonType &&
                  lesson.difficulty == widget.difficulty,
            )
            .toList();
    int currentIndex = filteredLessons.indexOf(currentLesson);
    setState(() {
      currentLesson =
          filteredLessons.length > currentIndex + 1
              ? filteredLessons[currentIndex + 1]
              : filteredLessons[0];
      test = currentLesson.content + '   ';
      colors = List.filled(test.length, Colors.grey.shade600);
      if (test.isNotEmpty) colors[0] = Colors.blue.shade700;
      count = 0;
      correct = 0;
      incorrect = 0;
      wpm = 0;
      startTime = null;
      isGameStarted = false;
      isShiftPressed = false;
      _currentCharacterKey = null;
      for (var row in keyColors) {
        for (int i = 0; i < row.length; i++) {
          row[i] = Colors.white;
        }
      }
      _highlightCurrentKey(0, Colors.blue.shade700);
      if (_isShiftRequired()) _highlightShiftKey(true);
    });
  }

  Future<void> _saveRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername =
          prefs.getString(AppKeys.username) ?? AppConstants.defaultUsername;
      final record = TypingRecord(
        username: savedUsername,
        country: AppConstants.defaultCountry,
        wpm: wpm,
        accuracy: _getAccuracy(),
      );
      await DatabaseHelper.instance.insertRecord(record);
    } catch (e) {
      print('Error saving record: $e');
    }
  }

  void _showCompletionDialog() {
    _saveRecord();
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
            padding: EdgeInsets.all(10.0),
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
                SizedBox(width: 10.0),
                Text(
                  AppText.congratulations,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      FontSizeType.medium,
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
                  SizedBox(height: 10.0),
                  Text(
                    AppText.exerciseCompleted,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        FontSizeType.small,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
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
              child: Text(AppText.back),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadNextLesson();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD8469),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              ),
              child: Text(AppText.continueText),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParagraphText() {
    final width = MediaQuery.of(context).size.width;
    final baseFontSize = width < 800 ? 16.0 : 18.0;
    const horizontalPadding = 3.0;
    const verticalPadding = 2.0;

    List<Widget> textWidgets = [];

    if (count < test.length && _currentCharacterKey == null) {
      _currentCharacterKey = GlobalKey();
    }

    for (int i = 0; i < test.length; i++) {
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

      textWidgets.add(
        Container(
          key: i == count ? _currentCharacterKey : null,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          margin: EdgeInsets.symmetric(horizontal: 0.5, vertical: 1.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border:
                borderColor != Colors.transparent
                    ? Border.all(color: borderColor, width: 1.0)
                    : null,
          ),
          child: Text(
            test[i],
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

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: width - 136.0, // Account for sidebar and margins
      ),
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: SingleChildScrollView(
        controller: _textScrollController,
        child: Wrap(spacing: 1.0, runSpacing: 6.0, children: textWidgets),
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
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      margin: EdgeInsets.only(bottom: 6.0),
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3.0),
          Text(
            label,
            style: TextStyle(
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
      color: Colors.blue.shade800,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              margin: EdgeInsets.only(bottom: 6.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: _getProgressPercentage() / 100,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade200,
                    ),
                    minHeight: 3.0,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    '${_getProgressPercentage().toInt()}%',
                    style: TextStyle(
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
      padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
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
          SizedBox(width: 6.0),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
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

    // Always use landscape layout for dialog in landscape screen
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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        top: false,
        bottom: false,
        left: false,
        right: false,
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
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
                        margin: EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 4.0),
                        child: SingleChildScrollView(
                          controller: _textScrollController,
                          physics: const ClampingScrollPhysics(),
                          child: _buildParagraphText(),
                        ),
                      ),
                    ),
                    // Keyboard area - bottom section
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(8.0, 4.0, 4.0, 8.0),
                        child: ModernKeyboardWidget(
                          keys: keys,
                          keyColors: keyColors,
                          currentChar: count < test.length ? test[count] : '',
                          requiredKeys: _getRequiredKeys(),
                          wrongKey: wrongKey,
                          testString: test,
                          currentIndex: count,
                          onKeyPressed: (String key) {},
                          isLandscape: true,
                          languageCode: 'en',
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
