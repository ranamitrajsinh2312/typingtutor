// =========================================================================
// 🎓 KEY GUIDE SCREEN — Row-wise Keyboard Lesson With Finger Highlighting
// Production-Ready with Proper Keymapping + Attractive UI
// =========================================================================

import 'dart:math';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/data/indic_keyboard_lessons.dart';
import 'package:get/get.dart';

class Level1 extends StatefulWidget {
  final String whichRow;
  final String languageCode;
  const Level1(this.whichRow, {this.languageCode = 'en', super.key});
  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> with TickerProviderStateMixin {
  // ── Stats ────────────────────────────────────────────────────────────────
  var test = '';
  int wpm = 0, correct = 0, incorrect = 0;
  double accuracy = 100.0;

  // ── Animations ───────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl, _shakeCtrl;
  late Animation<double> _pulseAnim, _shakeAnim;
  String? wrongKey;

  // ── Scroll ───────────────────────────────────────────────────────────────
  final ScrollController _textScroll = ScrollController();

  // ── Keyboard state ────────────────────────────────────────────────────────
  List<List<String>> keys = AppConstants.keyboardLayout;
  List<List<Color>> c = [];

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      if (_isMounted) {
        _setupKeyboardLayout();
        whichString(widget.whichRow, widget.languageCode);
        _setupAnimations();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isMounted) _scrollToCurrent();
        });
      }
    });
  }

  void _setupKeyboardLayout() {
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
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.keyPulse,
    );
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: AppDurations.keyShake,
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _shakeAnim = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _isMounted = false;
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _timer?.cancel();
    _textScroll.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _scrollToCurrent() {
    if (!_isMounted || !_textScroll.hasClients || count >= test.length) return;
    final w = MediaQuery.of(context).size.width;
    final charW = w < 600 ? 20.0 : 22.0;
    final viewport = _textScroll.position.viewportDimension;
    final maxOff = _textScroll.position.maxScrollExtent;
    final charOff = count * charW;
    final center = _textScroll.offset + viewport / 2;
    if (charOff > center) {
      final desired = (charOff - viewport / 2 + charW / 2).clamp(0.0, maxOff);
      if (desired > _textScroll.offset) {
        _textScroll.animateTo(
          desired,
          duration: AppDurations.scrollFast,
          curve: Curves.easeOut,
        );
      }
    }
  }

  String _elapsed() {
    if (startTime == null) return '00:00';
    final e = DateTime.now().difference(startTime!);
    return '${e.inMinutes.toString().padLeft(2, '0')}:${(e.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double _accuracy() {
    final total = correct + incorrect;
    return total == 0 ? 100.0 : (correct / total * 100).clamp(0.0, 100.0);
  }

  double _progress() =>
      test.isEmpty ? 0.0 : (count / test.length).clamp(0.0, 1.0);

  void _calcStats() {
    if (startTime != null) {
      final secs = DateTime.now().difference(startTime!).inSeconds;
      if (secs > 0) wpm = ((correct / 5) / (secs / 60)).round();
      accuracy = _accuracy();
    }
  }

  // ── Populate test string ───────────────────────────────────────────────────
  void whichString(String row, String lang) {
    if (lang == 'hi' || lang == 'gu') {
      test = IndicKeyboardLessons.getPracticeString(lang, row);
    } else {
      test = AppConstants.typingPatterns[row] ?? '';
    }
    colors = List.filled(test.length, const Color(0xFF4A5A7A));
    _highlightCurrentKeys();
    setState(() {});
  }

  // ── Highlight keyboard keys for current char ───────────────────────────────
  void _highlightCurrentKeys() {
    // Reset all
    for (int r = 0; r < c.length; r++) {
      for (int k = 0; k < c[r].length; k++) {
        c[r][k] = Colors.white;
      }
    }
    if (count >= test.length) return;
    final ch = test[count];
    _highlightChar(ch, const Color(0xFF00E5FF));
    if (count + 1 < test.length) {
      _highlightChar(test[count + 1], const Color(0xFF80DEEA));
    }
    if (_isMounted) setState(() {});
  }

  void _highlightChar(String ch, Color color) {
    final upper = ch.toUpperCase();
    for (int r = 0; r < keys.length; r++) {
      for (int k = 0; k < keys[r].length; k++) {
        final key = keys[r][k];
        if (ch == ' ' && key == 'SPACE') {
          c[r][k] = color;
          return;
        }
        if (key == upper || key == ch) {
          c[r][k] = color;
          return;
        }
      }
    }
  }

  // ── Key event handler ─────────────────────────────────────────────────────
  void _onKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (!isGameStarted) {
      isGameStarted = true;
      startTime = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_isMounted) {
          _calcStats();
          setState(() {});
        }
      });
    }
    _processKey(event);
  }

  void _processKey(RawKeyEvent event) {
    if (count >= test.length) return;
    final expected = test[count];
    String pressed = '';

    if (event.logicalKey == LogicalKeyboardKey.space) {
      pressed = ' ';
    } else if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      setState(() => isShiftPressed = true);
      return;
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (count > 0) {
        count--;
        colors[count] = const Color(0xFF4A5A7A);
        _highlightCurrentKeys();
        _scrollToCurrent();
      }
      return;
    } else {
      pressed = event.character ?? '';
    }

    if (pressed.isEmpty) return;

    final isCorrect =
        pressed == expected ||
        (expected == pressed.toUpperCase()) ||
        (expected.toUpperCase() == pressed.toUpperCase());

    if (isCorrect) {
      colors[count] = const Color(0xFF00C853); // correct green
      correct++;
      _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
    } else {
      colors[count] = const Color(0xFFFF1744); // wrong red
      incorrect++;
      wrongKey = pressed.toUpperCase();
      _shakeCtrl.forward().then((_) {
        _shakeCtrl.reset();
        if (_isMounted) setState(() => wrongKey = null);
      });
      HapticFeedback.heavyImpact();
    }

    count++;
    _highlightCurrentKeys();
    _calcStats();
    _scrollToCurrent();

    if (count >= test.length) _onComplete();

    if (_isMounted) setState(() {});
  }

  void _onComplete() {
    _timer?.cancel();
    final finalWpm = wpm;
    final finalAcc = _accuracy();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isMounted && mounted) {
        _showCompletionDialog(finalWpm, finalAcc);
      }
    });
  }

  void _showCompletionDialog(int finalWpm, double finalAcc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF311B92)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lesson Complete!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),
                _statRow(
                  'Speed',
                  '$finalWpm WPM',
                  Icons.speed_rounded,
                  const Color(0xFF1A237E),
                ),
                _statRow(
                  'Accuracy',
                  '${finalAcc.toInt()}%',
                  Icons.gps_fixed_rounded,
                  const Color(0xFF43A047),
                ),
                _statRow(
                  'Correct',
                  '$correct',
                  Icons.check_circle_rounded,
                  const Color(0xFF00BCD4),
                ),
                _statRow(
                  'Errors',
                  '$incorrect',
                  Icons.cancel_rounded,
                  const Color(0xFFE53935),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetLesson();
                },
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Get.back();
                },
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );

  void _resetLesson() {
    _timer?.cancel();
    setState(() {
      count = 0;
      correct = 0;
      incorrect = 0;
      wpm = 0;
      accuracy = 100;
      startTime = null;
      isGameStarted = false;
      wrongKey = null;
      colors = List.filled(test.length, const Color(0xFF4A5A7A));
      _highlightCurrentKeys();
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: RawKeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKey: _onKey,
        child: _buildBody(size),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: const Color(0xFF1A237E),
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
        size: 20,
      ),
      onPressed: () => Get.back(),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.whichRow,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'Tap keys on your keyboard',
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
        ),
      ],
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _elapsed(),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
      IconButton(
        onPressed: _resetLesson,
        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
      ),
    ],
  );

  Widget _buildBody(Size size) {
    return Column(
      children: [
        // Stats bar
        _buildStatsBar(),
        // Text display
        Expanded(flex: 2, child: _buildTextDisplay(size)),
        // Keyboard
        Expanded(flex: 3, child: _buildKeyboardArea()),
      ],
    );
  }

  Widget _buildStatsBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    color: const Color(0xFF141927),
    child: Row(
      children: [
        _miniStat('WPM', '$wpm', const Color(0xFF00E5FF)),
        _miniStat('Accuracy', '${accuracy.toInt()}%', const Color(0xFF00C853)),
        _miniStat('Correct', '$correct', const Color(0xFF64B5F6)),
        _miniStat('Errors', '$incorrect', const Color(0xFFFF5252)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                LinearProgressIndicator(
                  value: _progress(),
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF00E5FF),
                  ),
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _miniStat(String label, String value, Color color) => Container(
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 9),
        ),
      ],
    ),
  );

  Widget _buildTextDisplay(Size size) {
    final fs = size.width < 800 ? 15.0 : 18.0;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: SingleChildScrollView(
        controller: _textScroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(test.length, (i) {
            final col = i < colors.length ? colors[i] : const Color(0xFF4A5A7A);
            Color bg, txt;
            if (col == const Color(0xFF00C853)) {
              bg = const Color(0xFF1B5E20);
              txt = const Color(0xFF69F0AE);
            } else if (col == const Color(0xFFFF1744)) {
              bg = const Color(0xFF7F0000);
              txt = const Color(0xFFFF8A80);
            } else if (i == count) {
              bg = const Color(0xFF0D47A1);
              txt = const Color(0xFF82B1FF);
            } else {
              bg = Colors.transparent;
              txt = const Color(0xFF5C6BC0);
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              margin: EdgeInsets.symmetric(
                horizontal: 1,
                vertical: i == count ? 0 : 2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(5),
                border:
                    i == count
                        ? Border.all(color: const Color(0xFF00E5FF), width: 1.5)
                        : null,
              ),
              child: Text(
                test[i] == ' ' ? '·' : test[i],
                style: TextStyle(
                  fontSize: i == count ? fs + 2 : fs,
                  fontWeight: i == count ? FontWeight.w900 : FontWeight.w600,
                  color: txt,
                  height: 1.2,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildKeyboardArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder:
            (_, child) => Transform.translate(
              offset: Offset(_shakeAnim.value * sin(count * pi), 0),
              child: child,
            ),
        child: _KeyGuideKeyboard(
          keys: keys,
          keyColors: c,
          wrongKey: wrongKey,
          currentChar: count < test.length ? test[count] : '',
          languageCode: widget.languageCode,
        ),
      ),
    );
  }
}

// ── Key Guide Keyboard ────────────────────────────────────────────────────────

class _KeyGuideKeyboard extends StatelessWidget {
  final List<List<String>> keys;
  final List<List<Color>> keyColors;
  final String? wrongKey;
  final String currentChar;
  final String languageCode;

  const _KeyGuideKeyboard({
    required this.keys,
    required this.keyColors,
    required this.wrongKey,
    required this.currentChar,
    required this.languageCode,
  });

  bool get _isIndic => languageCode == 'hi' || languageCode == 'gu';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cons) {
        final maxW = min(cons.maxWidth * 0.99, 840.0);
        final maxH = min(cons.maxHeight * 0.99, 260.0);
        return Center(
          child: Container(
            width: maxW,
            height: maxH,
            padding: EdgeInsets.symmetric(
              horizontal: maxW * 0.012,
              vertical: maxH * 0.04,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E2640), Color(0xFF141927)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
              border: Border.all(color: const Color(0xFF2E3A59), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                keys.length,
                (ri) => _buildRow(ctx, ri, maxW, maxH),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(BuildContext ctx, int ri, double maxW, double maxH) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      keys[ri].length,
      (ci) => _buildKey(ctx, ri, ci, maxW, maxH),
    ),
  );

  Widget _buildKey(BuildContext ctx, int ri, int ci, double maxW, double maxH) {
    final k = keys[ri][ci];
    final isSpecial = ['TAB', 'CAPS', 'ENTER', 'SHIFT', 'SPACE'].contains(k);
    final isHomeRow = ri == 1 && !isSpecial;
    final isCurrentRow =
        ci < keyColors[ri].length &&
        (keyColors[ri][ci] == const Color(0xFF00E5FF) ||
            keyColors[ri][ci] == Colors.blue ||
            keyColors[ri][ci] == Colors.blue.shade200 ||
            keyColors[ri][ci] == Colors.blue.shade400 ||
            keyColors[ri][ci] == const Color(0xFF80DEEA));
    final isNext =
        ci < keyColors[ri].length &&
        keyColors[ri][ci] == const Color(0xFF80DEEA);
    final isCurrent =
        ci < keyColors[ri].length &&
        keyColors[ri][ci] == const Color(0xFF00E5FF);
    final isWrong =
        wrongKey != null &&
        (k == wrongKey ||
            (k == 'SPACE' &&
                (wrongKey?.toLowerCase() == 'space' || wrongKey == ' ')));

    final List<Color> grad;
    if (isWrong)
      grad = [const Color(0xFFFF1744), const Color(0xFFD50000)];
    else if (isCurrent)
      grad = [const Color(0xFF00E5FF), const Color(0xFF00B8D4)];
    else if (isNext)
      grad = [const Color(0xFF80DEEA), const Color(0xFF4DD0E1)];
    else if (isHomeRow && !_isIndic)
      grad = [const Color(0xFFFFA726), const Color(0xFFEF6C00)];
    else if (isSpecial)
      grad = [const Color(0xFF2E3A59), const Color(0xFF253047)];
    else
      grad = [const Color(0xFF3A4A6B), const Color(0xFF2E3A59)];

    final Color txtColor;
    if (isWrong || isCurrent || isNext)
      txtColor = const Color(0xFF0D1117);
    else if (isHomeRow && !_isIndic)
      txtColor = const Color(0xFF1A0A00);
    else if (isSpecial)
      txtColor = const Color(0xFF8A9CC0);
    else
      txtColor = const Color(0xFFD0D8EF);

    final Color glowColor;
    if (isWrong)
      glowColor = const Color(0xFFFF1744);
    else if (isCurrent)
      glowColor = const Color(0xFF00E5FF);
    else if (isNext)
      glowColor = const Color(0xFF80DEEA);
    else if (isHomeRow)
      glowColor = const Color(0xFFFFA726);
    else
      glowColor = Colors.transparent;

    final kw = _keyWidth(k, maxW);
    final kh = maxH < 180 ? 24.0 : (maxH < 230 ? 30.0 : 36.0);

    return Container(
      width: kw,
      height: kh,
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: grad,
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: (isCurrent || isWrong) ? grad[0] : const Color(0xFF4A5A7A),
          width: (isCurrent || isWrong) ? 1.5 : 0.8,
        ),
        boxShadow: [
          if (glowColor != Colors.transparent)
            BoxShadow(
              color: glowColor.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _disp(k),
              style: TextStyle(
                color: txtColor,
                fontSize: isSpecial ? 8.5 : 12,
                fontWeight:
                    (isCurrent || isWrong) ? FontWeight.w900 : FontWeight.w600,
                fontFamily:
                    (_isIndic && !isSpecial) ? 'Noto Sans Devanagari' : null,
              ),
            ),
          ),
          if (isHomeRow && !_isIndic)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  String _disp(String k) {
    switch (k) {
      case 'TAB':
        return 'Tab';
      case 'CAPS':
        return 'Caps';
      case 'ENTER':
        return '↵';
      case 'SHIFT':
        return '⇧';
      case 'SPACE':
        return '⎵';
      default:
        return k;
    }
  }

  double _keyWidth(String k, double mw) {
    final base = mw / 16.5;
    switch (k) {
      case 'TAB':
        return base * 1.55;
      case 'CAPS':
        return base * 1.65;
      case 'ENTER':
        return base * 1.65;
      case 'SHIFT':
        return base * 2.1;
      case 'SPACE':
        return base * 6.8;
      default:
        return base;
    }
  }
}
