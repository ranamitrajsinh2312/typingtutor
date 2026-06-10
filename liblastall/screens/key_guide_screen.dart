// Row Wise Selected Keyboard Guidance With HHighlighted Fingers.

import 'package:typingtutor/utils/responsive_helper.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/data/indic_keyboard_lessons.dart';

class Level1 extends StatefulWidget {
  late List<Widget> list = [];
  final String whichRow;
  final String languageCode;

  Level1(this.whichRow, {this.languageCode = 'en', super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> with TickerProviderStateMixin {
  var test = '';
  int divide = 1, wpm = 0, correct = 0, incorrect = 0, timeCount = 0, cpm = 0;
  double avg = 0;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  // Error feedback
  String? wrongKey;
  DateTime? wrongKeyTime;

  // Scroll controller for text display
  final ScrollController _textScrollController = ScrollController();

  List<List<String>> keys = AppConstants.keyboardLayout;

  List<List<Color>> c = [
    List.filled(14, Colors.white),
    List.filled(13, Colors.white),
    List.filled(12, Colors.white),
    [Colors.white],
  ];

  List<Color> colors = [];
  int count = 0;
  DateTime? startTime;
  bool isGameStarted = false;
  bool isShiftPressed = false;
  Timer? _timer;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    // Lock to landscape orientation immediately
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      if (_isMounted) {
        _setupKeyboardLayout();
        whichString(widget.whichRow, widget.languageCode);
        _setupAnimations();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isMounted) {
            _scrollToCurrentPosition();
          }
        });
      }
    });
  }

  void _setupKeyboardLayout() {
    // Set keyboard layout based on language
    if (widget.languageCode == 'hi') {
      keys = [
        ['ौ', 'ै', 'ा', 'ी', 'ू', 'ब', 'ह', 'ग', 'द', 'ज', 'ड', '़', 'ॉ'],
        ['ो', 'े', '्', 'ि', 'ु', 'प', 'र', 'क', 'त', 'च', 'ट', 'ENTER'],
        ['SHIFT', 'ं', 'म', 'न', 'व', 'ल', 'स', ',', '.', 'य', 'SHIFT'],
        ['SPACE'],
      ];
      c = [
        List.filled(13, Colors.white),
        List.filled(12, Colors.white),
        List.filled(11, Colors.white),
        [Colors.white],
      ];
    } else if (widget.languageCode == 'gu') {
      keys = [
        ['ૌ', 'ૈ', 'ા', 'ી', 'ૂ', 'બ', 'હ', 'ગ', 'દ', 'જ', 'ડ', '઼', 'ૉ'],
        ['ો', 'ે', '્', 'િ', 'ુ', 'પ', 'ર', 'ક', 'ત', 'ચ', 'ટ', 'ENTER'],
        ['SHIFT', 'ં', 'મ', 'ન', 'વ', 'લ', 'સ', ',', '.', 'ય', 'SHIFT'],
        ['SPACE'],
      ];
      c = [
        List.filled(13, Colors.white),
        List.filled(12, Colors.white),
        List.filled(11, Colors.white),
        [Colors.white],
      ];
    } else {
      // Default English layout
      keys = AppConstants.keyboardLayout;
      c = [
        List.filled(14, Colors.white),
        List.filled(13, Colors.white),
        List.filled(12, Colors.white),
        [Colors.white],
      ];
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: AppDurations.keyPulse,
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: AppDurations.keyShake,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _pulseController.dispose();
    _shakeController.dispose();
    _timer?.cancel();
    _textScrollController.dispose();
    // Restore default orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Scroll to current character position
  void _scrollToCurrentPosition() {
    if (!_isMounted ||
        !_textScrollController.hasClients ||
        count >= test.length)
      return;

    final width = MediaQuery.of(context).size.width;
    final charWidth = width < 600 ? 20.0 : (width < 800 ? 22.0 : 24.0);
    final containerWidth = _textScrollController.position.viewportDimension;
    final maxOffset = _textScrollController.position.maxScrollExtent;
    final currentCharOffset = count * charWidth;
    final currentScrollOffset = _textScrollController.offset;
    final centerPosition = currentScrollOffset + containerWidth / 2;

    if (currentCharOffset > centerPosition) {
      double desiredOffset =
          currentCharOffset - (containerWidth / 2) + (charWidth / 2);
      desiredOffset = desiredOffset.clamp(0.0, maxOffset);
      if (desiredOffset > currentScrollOffset) {
        _textScrollController.animateTo(
          desiredOffset,
          duration: AppDurations.scrollFast,
          curve: Curves.easeOut,
        );
      }
    }
  }

  // Time and stats calculations
  String _getElapsedTime() {
    if (startTime == null) return "00:00";
    final elapsed = DateTime.now().difference(startTime!);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  double _getAccuracy() {
    if ((correct + incorrect) == 0) return 100;
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
        wpm = ((correct / 5) / (elapsed / 60)).round();
        cpm = wpm;
      }
    }
    avg = correct + incorrect > 0 ? (correct / (correct + incorrect)) * 100 : 0;
  }

  // Key highlighting and input handling
  void _clearWrongKeyHighlight() {
    if (!_isMounted || wrongKey == null || wrongKeyTime == null) return;
    final elapsed = DateTime.now().difference(wrongKeyTime!).inMilliseconds;
    if (elapsed > AppDurations.errorDisplay.inMilliseconds) {
      setState(() {
        wrongKey = null;
        wrongKeyTime = null;
      });
    }
  }

  void _highlightWrongKey(String key) {
    if (!_isMounted) return;
    setState(() {
      wrongKey = key.toUpperCase();
      wrongKeyTime = DateTime.now();
    });
    Future.delayed(AppDurations.errorDisplay, () {
      if (_isMounted && mounted) {
        setState(() {
          wrongKey = null;
          wrongKeyTime = null;
        });
      }
    });
  }

  void changeValue(String s, int count) {
    if (s == 'addColor') {
      _highlightCurrentKey(count, Colors.blue.shade200);
    } else if (s == 'removeColor' && count > 0) {
      _removeKeyHighlight(count - 1);
    }
  }

  void _highlightCurrentKey(int charIndex, Color color) {
    if (!_isMounted || charIndex >= test.length) return;
    String currentChar = test[charIndex];
    if (currentChar == ' ') {
      c[3][0] = color;
      return;
    }
    String keyToHighlight = currentChar.toUpperCase();
    for (int row = 0; row < keys.length - 1; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == keyToHighlight) {
          c[row][col] = color;
          return;
        }
      }
    }
  }

  void _removeKeyHighlight(int charIndex) {
    if (!_isMounted || charIndex >= test.length || charIndex < 0) return;
    String prevChar = test[charIndex];
    if (prevChar == ' ') {
      c[3][0] = Colors.white;
      return;
    }
    String keyToRemove = prevChar.toUpperCase();
    for (int row = 0; row < keys.length - 1; row++) {
      for (int col = 0; col < keys[row].length; col++) {
        if (keys[row][col] == keyToRemove) {
          c[row][col] = Colors.white;
          return;
        }
      }
    }
  }

  void _highlightShiftKey(bool highlight) {
    if (!_isMounted) return;
    Color color = highlight ? Colors.blue.shade200 : Colors.white;
    c[2][0] = color;
    c[2][11] = color;
  }

  String _getCurrentExpectedKey() {
    if (count >= test.length) return '';
    return test[count];
  }

  bool _isShiftRequired() {
    if (count >= test.length) return false;
    String currentChar = test[count];
    return currentChar.codeUnitAt(0) >= 65 && currentChar.codeUnitAt(0) <= 90;
  }

  List<String> _getRequiredKeys() {
    List<String> requiredKeys = [];
    List<String> activeRowKeys = _getActiveRowKeys();
    requiredKeys.addAll(activeRowKeys);
    if (count < test.length) {
      String currentChar = test[count];
      if (_isShiftRequired()) {
        requiredKeys.add('SHIFT');
      }
      if (currentChar == ' ') {
        if (!requiredKeys.contains('SPACE')) {
          requiredKeys.add('SPACE');
        }
      } else {
        String currentKey = currentChar.toUpperCase();
        if (!requiredKeys.contains(currentKey)) {
          requiredKeys.add(currentKey);
        }
      }
    }
    return requiredKeys;
  }

  List<String> _getActiveRowKeys() {
    // For Hindi/Gujarati, use the IndicKeyboardLessons data
    if (widget.languageCode == 'hi' || widget.languageCode == 'gu') {
      List<String> activeKeys = IndicKeyboardLessons.getLessonKeys(
        widget.languageCode,
        widget.whichRow,
      );
      activeKeys.add('SPACE');
      return activeKeys;
    }

    // English keys
    List<String> activeKeys = [];
    switch (widget.whichRow) {
      case 'Home Row':
        activeKeys.addAll([
          'A',
          'S',
          'D',
          'F',
          'G',
          'H',
          'J',
          'K',
          'L',
          ';',
          "'",
          'SPACE',
        ]);
        break;
      case 'Home & Top Row':
        activeKeys.addAll([
          'A',
          'S',
          'D',
          'F',
          'G',
          'H',
          'J',
          'K',
          'L',
          ';',
          "'",
        ]);
        activeKeys.addAll([
          'Q',
          'W',
          'E',
          'R',
          'T',
          'Y',
          'U',
          'I',
          'O',
          'P',
          'SPACE',
        ]);
        break;
      case 'Home & Bottom Row':
        activeKeys.addAll([
          'A',
          'S',
          'D',
          'F',
          'G',
          'H',
          'J',
          'K',
          'L',
          ';',
          "'",
        ]);
        activeKeys.addAll([
          'Z',
          'X',
          'C',
          'V',
          'B',
          'N',
          'M',
          ',',
          '.',
          '/',
          'SPACE',
        ]);
        break;
      case 'Top & Bottom Row':
        activeKeys.addAll(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']);
        activeKeys.addAll([
          'Z',
          'X',
          'C',
          'V',
          'B',
          'N',
          'M',
          ',',
          '.',
          '/',
          'SPACE',
        ]);
        break;
      case 'Home & Top Row & Bottom':
        activeKeys.addAll([
          'A',
          'S',
          'D',
          'F',
          'G',
          'H',
          'J',
          'K',
          'L',
          ';',
          "'",
        ]);
        activeKeys.addAll(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']);
        activeKeys.addAll([
          'Z',
          'X',
          'C',
          'V',
          'B',
          'N',
          'M',
          ',',
          '.',
          '/',
          'SPACE',
        ]);
        break;
      case 'Home Row & shift':
        activeKeys.addAll([
          'A',
          'S',
          'D',
          'F',
          'G',
          'H',
          'J',
          'K',
          'L',
          ';',
          "'",
          'SPACE',
        ]);
        break;
      case 'Top Row & shift':
      case 'Top Row':
        activeKeys.addAll([
          'Q',
          'W',
          'E',
          'R',
          'T',
          'Y',
          'U',
          'I',
          'O',
          'P',
          'SPACE',
        ]);
        break;
      case 'Bottom Row':
        activeKeys.addAll([
          'Z',
          'X',
          'C',
          'V',
          'B',
          'N',
          'M',
          ',',
          '.',
          '/',
          'SPACE',
        ]);
        break;
    }
    return activeKeys;
  }

  // Game logic
  void demo() {
    if (!_isMounted) return;
    setState(() {
      calculateTime(correct + incorrect);
      cpm = getCPM(correct + incorrect);
    });
  }

  int getCPM(int totalChars) {
    if (startTime != null && totalChars > 0) {
      final elapsed = DateTime.now().difference(startTime!).inSeconds;
      if (elapsed > 0) {
        return (totalChars / (elapsed / 60)).round();
      }
    }
    return 0;
  }

  void _processKeyInput(RawKeyEvent event) {
    if (!_isMounted || event is! RawKeyDownEvent || count >= test.length)
      return;

    _startGame();
    _clearWrongKeyHighlight();

    String expectedChar = test[count];
    String inputKey = event.logicalKey.keyLabel ?? '';
    bool isShiftPressed = event.isShiftPressed;

    if (inputKey == "Shift Left" || inputKey == "Shift Right") {
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

  void calculateTime(int totalChars) {
    if (startTime != null && totalChars > 0) {
      final elapsed = DateTime.now().difference(startTime!).inSeconds;
      if (elapsed > 0) {
        wpm = ((totalChars / 5) / (elapsed / 60)).round();
      }
    }
  }

  void _startGame() {
    if (!_isMounted || isGameStarted) return;
    startTime = DateTime.now();
    isGameStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMounted && mounted) {
        setState(() {});
      }
    });
  }

  void _handleCorrectInput() {
    if (!_isMounted) return;
    setState(() {
      if (count < colors.length) {
        colors[count] = Colors.green;
      }
      correct++;
      _removeKeyHighlight(count);
      count++;
      if (count < test.length) {
        if (count < colors.length) {
          colors[count] = Colors.blue;
        }
        _highlightCurrentKey(count, Colors.blue.shade200);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        } else {
          _highlightShiftKey(false);
        }
        _scrollToCurrentPosition();
      } else {
        _highlightShiftKey(false);
      }
      _calculateStats();
      if (count >= test.length) {
        _timer?.cancel();
        _showCompletionDialog();
      }
      widget.list = getSplitValue(test, colors);
    });
  }

  void _handleIncorrectInput(String inputKey) {
    if (!_isMounted) return;
    setState(() {
      if (count < colors.length) {
        colors[count] = Colors.red;
      }
      incorrect++;
      String wrongKeyToHighlight = inputKey;
      if (inputKey.toLowerCase() == 'space' || inputKey == ' ') {
        wrongKeyToHighlight = 'SPACE';
      }
      _highlightWrongKey(wrongKeyToHighlight);
      _shakeController.forward().then((_) => _shakeController.reverse());
      _calculateStats();
      _removeKeyHighlight(count);
      count++;
      if (count < test.length) {
        if (count < colors.length) {
          colors[count] = Colors.blue;
        }
        _highlightCurrentKey(count, Colors.blue.shade200);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        } else {
          _highlightShiftKey(false);
        }
        _scrollToCurrentPosition();
      } else {
        _highlightShiftKey(false);
      }
      if (count >= test.length) {
        _timer?.cancel();
        _showCompletionDialog();
      }
      widget.list = getSplitValue(test, colors);
    });
  }

  // Save record and show completion dialog
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
    if (!_isMounted) return;
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          scrollable: true,
          title: Container(
            padding: const EdgeInsets.all(10),
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
                const SizedBox(width: 10),
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
                children: [
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _buildResultStats(context),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                AppText.back,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    FontSizeType.small,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetRound();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFD8469),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    FontSizeType.small,
                  ),
                ),
              ),
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
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
    final dialogWidth = MediaQuery.of(context).size.width * 0.9;
    final itemWidth = (dialogWidth - 36) / 2;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children:
          [
            _buildStatRow(context, 'Time:', _getElapsedTime(), Colors.purple),
            _buildStatRow(context, 'WPM:', wpm.toString(), Colors.blue),
            _buildStatRow(
              context,
              'Accuracy:',
              '${_getAccuracy().toInt()}%',
              Colors.green,
            ),
            _buildStatRow(
              context,
              'Correct:',
              correct.toString(),
              Colors.green,
            ),
            _buildStatRow(context, 'Wrong:', incorrect.toString(), Colors.red),
          ].map((w) => SizedBox(width: itemWidth, child: w)).toList(),
    );
  }

  void _resetRound() {
    if (!_isMounted) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isMounted && mounted) {
        setState(() {
          _timer?.cancel();
          startTime = null;
          isGameStarted = false;
          for (int i = 0; i < colors.length; i++) {
            colors[i] = Colors.grey;
          }
          for (int row = 0; row < c.length; row++) {
            for (int col = 0; col < c[row].length; col++) {
              c[row][col] = Colors.white;
            }
          }
          count = 0;
          correct = 0;
          incorrect = 0;
          wpm = 0;
          cpm = 0;
          avg = 0;
          widget.list = getSplitValue(test, colors);
          if (colors.isNotEmpty) {
            colors[0] = Colors.blue;
          }
          _highlightCurrentKey(0, Colors.blue.shade200);
          if (_isShiftRequired()) {
            _highlightShiftKey(true);
          }
          _scrollToCurrentPosition();
        });
      }
    });
  }

  // UI components
  // Widget _buildStatCard(BuildContext context, String label, String value) {
  //   final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
  //   final labelFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.small);
  //   final valueFontSize = ResponsiveHelper.getResponsiveFontSize(context, FontSizeType.medium);
  //   final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.small);
  //   final spacing = ResponsiveHelper.getResponsiveSpacing(context, SpacingType.small);
  //
  //   return Expanded(
  //     child: Container(
  //       padding: EdgeInsets.all(spacing * 0.6),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(borderRadius),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: Colors.white70,
  //               fontSize: labelFontSize,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             textAlign: TextAlign.center,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           SizedBox(height: spacing * 0.2),
  //           Text(
  //             value,
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: valueFontSize,
  //               fontWeight: FontWeight.bold,
  //             ),
  //             textAlign: TextAlign.center,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
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
    final compactPadding = width < 600 ? 8.0 : (width < 800 ? 8.0 : 8.0);

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
                  '$wpm',
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
                const SizedBox(height: 8),
                _buildUltraCompactStatCard(
                  context,
                  'Correct',
                  '$correct',
                  compactFontSize,
                  compactValueFontSize,
                  compactPadding,
                ),
                const SizedBox(height: 8),
                _buildUltraCompactStatCard(
                  context,
                  'Incorrect',
                  '$incorrect',
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

  // Hand image helpers - Now supports English, Hindi, and Gujarati
  String whichImage(String c) {
    // Use AppConstants which supports all languages
    return AppConstants.getLeftHandImage(c);
  }

  String whichImageOnRight(String c) {
    // Use AppConstants which supports all languages
    return AppConstants.getRightHandImage(c);
  }

  void whichString(String lessonName, String languageCode) {
    if (!_isMounted) return;

    // English practice strings
    Map<String, String> englishStrings = {
      'Home Row': 'asdf ;lkj hjkl asdf ;lkj hjkl asdf ;lkj hjkl ',
      'Home & Top Row': 'asdf qwer ;lkj uiop asdf qwer ;lkj uiop ',
      'Home & Bottom Row': 'asdf zxcv ;lkj nm,. asdf zxcv ;lkj nm,. ',
      'Top & Bottom Row': 'qwer zxcv uiop nm,. qwer zxcv uiop nm,. ',
      'Home & Top Row & Bottom':
          'asdf qwer zxcv ;lkj uiop nm,. the quick brown fox ',
      'Home Row & shift': 'AsDf ;LkJ HjKl AsDf ;LkJ HjKl AsDf ;LkJ ',
      'Top Row & shift': 'QweR UioP QweR UioP QweR UioP QweR UioP ',
      'Top Row': 'qwer uiop qwer uiop qwer uiop qwer uiop ',
      'Bottom Row': 'zxcv nm,. zxcv nm,. zxcv nm,. zxcv nm,. ',
    };

    // Select the appropriate language strings
    String practiceText;
    if (languageCode == 'hi' || languageCode == 'gu') {
      practiceText = IndicKeyboardLessons.getPracticeString(
        languageCode,
        lessonName,
      );
      if (practiceText.isEmpty) {
        practiceText = englishStrings[lessonName] ?? '';
      }
    } else {
      practiceText = englishStrings[lessonName] ?? '';
    }

    setState(() {
      test = practiceText;
      colors = List.filled(test.length, Colors.grey);
      if (test.isNotEmpty) colors[0] = Colors.blue;
    });
  }

  List<Widget> getSplitValue(String text, List<Color> colors) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < 600 ? 14.0 : (width < 800 ? 16.0 : 18.0);
    final horizontalPadding = width < 600 ? 2.0 : 3.0;
    final verticalPadding = width < 600 ? 1.0 : 1.5;

    List<Widget> widgets = [];
    for (int i = 0; i < text.length && i < colors.length; i++) {
      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          margin: EdgeInsets.symmetric(horizontal: 0.8),
          decoration: BoxDecoration(
            color:
                colors[i] == Colors.grey
                    ? Colors.grey.shade100
                    : colors[i] == Colors.blue
                    ? Colors.blue.shade50
                    : colors[i] == Colors.green
                    ? Colors.green.shade50
                    : colors[i] == Colors.red
                    ? Colors.red.shade50
                    : colors[i],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  colors[i] == Colors.blue
                      ? Colors.blue.shade400
                      : colors[i] == Colors.green
                      ? Colors.green.shade400
                      : colors[i] == Colors.red
                      ? Colors.red.shade400
                      : Colors.grey.shade300,
              width: 1.0,
            ),
            boxShadow:
                colors[i] != Colors.grey
                    ? [
                      BoxShadow(
                        color: (colors[i] == Colors.blue
                                ? Colors.blue
                                : colors[i] == Colors.green
                                ? Colors.green
                                : colors[i] == Colors.red
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
            text[i],
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color:
                  colors[i] == Colors.grey
                      ? Colors.black87
                      : colors[i] == Colors.blue
                      ? Colors.blue.shade800
                      : colors[i] == Colors.green
                      ? Colors.green.shade800
                      : colors[i] == Colors.red
                      ? Colors.red.shade800
                      : Colors.white,
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  // Main build method
  @override
  Widget build(BuildContext context) {
    if (!_isMounted || !mounted) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.list.isEmpty) {
      widget.list = getSplitValue(test, colors);
      setState(() {
        demo();
        if (colors.isNotEmpty) {
          colors[count] = Colors.blue;
        }
        _highlightCurrentKey(count, Colors.blue.shade200);
        if (_isShiftRequired()) {
          _highlightShiftKey(true);
        }
        _scrollToCurrentPosition();
      });
    }

    final layoutType = ResponsiveHelper.getLayoutType(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return Row(
                children: [
                  // LEFT SIDE (Text + Keyboard)
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Text Display (top)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          constraints: BoxConstraints(
                            maxHeight: max(
                              ResponsiveHelper.getTextDisplayHeight(context),
                              10,
                            ),
                            minHeight: 10,
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              controller: _textScrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: widget.list,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Keyboard covers rest of screen
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            child: _buildMainContent(context, layoutType),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RIGHT SIDE (Stats Section)
                  Container(
                    height: double.infinity,
                    width: 100,
                    color: Colors.blue.shade800,
                    padding: const EdgeInsets.all(12),
                    child: _buildUltraCompactLandscapeStats(context),
                  ),
                ],
              );
            } catch (e, stackTrace) {
              // Log error for debugging
              print('Build error: $e\n$stackTrace');
              return const Center(
                child: Text(
                  'An error occurred. Please try again.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, LayoutType layoutType) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: _processKeyInput,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final showHandImages =
              ResponsiveHelper.shouldShowHandImages(context, availableHeight) &&
              count < test.length;
          final handImageSize = ResponsiveHelper.getHandImageSize(context);
          final iconSize = ResponsiveHelper.getIconSize(
            context,
            IconSizeType.large,
          );
          return _buildLandscapeLayout(
            context,
            showHandImages,
            handImageSize,
            iconSize,
          );
        },
      ),
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    bool showHandImages,
    double handImageSize,
    double iconSize,
  ) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showHandImages || width > 600)
            Flexible(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: width < 800 ? 6 : 10),
                child: Image.asset(
                  whichImage(count < test.length ? test[count] : ' '),
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.back_hand_outlined,
                        size: width < 800 ? 36 : (width < 900 ? 44 : 60),
                        color: Colors.grey.shade400,
                      ),
                  height: min(
                    handImageSize * (width < 800 ? 0.9 : 1.1),
                    width < 800 ? 120 : 180,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Flexible(
            flex: (showHandImages || width > 600) ? 10 : 6,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal:
                    (showHandImages || width > 600)
                        ? (width < 800 ? 8 : 16)
                        : 16,
                vertical: width < 800 ? 6 : 10,
              ),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * sin(count * pi), 0),
                    child: ModernKeyboardWidget(
                      keys: keys,
                      keyColors: c,
                      currentChar: count < test.length ? test[count] : '',
                      requiredKeys: _getRequiredKeys(),
                      wrongKey: wrongKey,
                      testString: test,
                      currentIndex: count,
                      onKeyPressed: (String key) {},
                      isLandscape: true,
                    ),
                  );
                },
              ),
            ),
          ),
          if (showHandImages || width > 600)
            Flexible(
              flex: 3,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: width < 800 ? 6 : 10),
                child: Image.asset(
                  whichImageOnRight(count < test.length ? test[count] : ' '),
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        Icons.back_hand_outlined,
                        size: width < 800 ? 36 : (width < 900 ? 44 : 60),
                        color: Colors.grey.shade400,
                      ),
                  height: min(
                    handImageSize * (width < 800 ? 0.9 : 1.1),
                    width < 800 ? 120 : 180,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
