// =============================================================================
// 🎯 PRACTICE SCREEN — Words / Sentences / Paragraphs
// =============================================================================
//
// Layout  (landscape):
//   ┌────────────────────────────────────────┬──────────┐
//   │  TEXT STRIP  (Wrap, vertical scroll)   │  Stats   │
//   │  Characters coloured green/red/blue    │  sidebar │
//   ├────────────────────────────────────────┤  (blue)  │
//   │  KEYBOARD  (same style as key guide)   │          │
//   │  Orange home-row · Blue current key    │          │
//   │  Indic keys: tiny English sub-label    │          │
//   └────────────────────────────────────────┴──────────┘
//
// • Word mode      → single-line horizontal strip (short text)
// • Sentence/Para  → multi-line Wrap with vertical auto-scroll
// • No hand images
// • languageCode is a first-class param  → correct Inscript mapping
// • Content from PracticeContent; swap to API via contentRepository
// =============================================================================

import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/constants/language_config.dart';
import 'package:typingtutor/constants/practice_content.dart';
import 'package:typingtutor/database/database_helper.dart';
import 'package:typingtutor/models/typing_record.dart';
import 'package:typingtutor/services/atomic_typing_service.dart';
import 'package:typingtutor/services/indic_key_mappings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class PracticeScreen extends StatefulWidget {
  /// 'word' | 'sentence' | 'paragraph'
  final String lessonType;
  /// 'easy' | 'medium' | 'hard'
  final String difficulty;
  /// 'en' | 'hi' | 'gu'
  final String languageCode;
  /// Optional: inject ApiPracticeContentRepository() to pull from network.
  /// Leave null to use bundled local content from practice_content.dart.
  final PracticeContentRepository? contentRepository;

  const PracticeScreen({
    super.key,
    required this.lessonType,
    required this.difficulty,
    this.languageCode = 'en',
    this.contentRepository,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {

  // ── Repository & content ───────────────────────────────────────────────────
  late final PracticeContentRepository _repo;
  List<PracticeItem> _items     = [];
  int                _itemIndex = 0;

  // ── Current text ───────────────────────────────────────────────────────────
  /// Unicode-safe list of atomic units (each = one keystroke).
  List<String> _units  = [];
  List<Color>  _colors = [];

  // ── Typing progress ────────────────────────────────────────────────────────
  int  _count     = 0;
  int  _correct   = 0;
  int  _incorrect = 0;
  int  _wpm       = 0;

  // ── Game state ─────────────────────────────────────────────────────────────
  DateTime? _startTime;
  bool      _started      = false;
  bool      _shiftPressed = false;
  Timer?    _timer;
  bool      _mounted      = false;

  // ── Keyboard UI ────────────────────────────────────────────────────────────
  late List<List<String>> _keys;
  late List<List<Color>>  _kc;
  String? _wrongKey;

  // ── Animation ──────────────────────────────────────────────────────────────
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  // ── Scroll (text strip) ────────────────────────────────────────────────────
  final ScrollController _textScroll = ScrollController();

  // ── Loading ────────────────────────────────────────────────────────────────
  bool _loading = true;

  // ── Convenience getters ────────────────────────────────────────────────────
  bool    get _isWordMode  => widget.lessonType == 'word';
  bool    get _isIndic     => LanguageConfig.isIndic(widget.languageCode);
  String? get _fontFamily  => LanguageConfig.fontFamily(widget.languageCode);

  /// Indic char → English physical key  (used for tiny sub-labels on keys)
  Map<String, String> get _indicToPhysical {
    if (widget.languageCode == 'hi') return IndicKeyMappings.hindiReverseKeyMap;
    if (widget.languageCode == 'gu') return IndicKeyMappings.gujaratiReverseKeyMap;
    return {};
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mounted = true;
    _repo    = widget.contentRepository
        ?? const LocalPracticeContentRepository();

    _shakeCtrl = AnimationController(
        duration: AppDurations.keyShake, vsync: this);
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) { if (_mounted) _fetchContent(); });
  }

  @override
  void dispose() {
    _mounted = false;
    _timer?.cancel();
    _shakeCtrl.dispose();
    _textScroll.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONTENT FETCHING  (single swap-point for API)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _fetchContent() async {
    if (!_mounted) return;
    setState(() => _loading = true);
    try {
      final items = await _repo.fetch(
        languageCode: widget.languageCode,
        type:         _toType(widget.lessonType),
        difficulty:   _toDiff(widget.difficulty),
      );
      if (!_mounted) return;
      if (items.isEmpty) { setState(() => _loading = false); return; }
      setState(() { _items = items; _itemIndex = 0; _loading = false; });
      _loadItem(0);
    } catch (e) {
      if (!_mounted) return;
      setState(() => _loading = false);
      debugPrint('PracticeScreen: fetch failed — $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOAD ONE ITEM
  // ─────────────────────────────────────────────────────────────────────────

  void _loadItem(int index) {
    if (!_mounted || _items.isEmpty) return;
    final item  = _items[index % _items.length];
    final units = AtomicTypingService.splitIntoAtomicUnits(
        item.text, widget.languageCode);

    _setupKeyboard();
    _timer?.cancel();

    setState(() {
      _units        = units;
      _colors       = List.filled(units.length, Colors.grey.shade400);
      _count        = 0;
      _correct      = 0;
      _incorrect    = 0;
      _wpm          = 0;
      _startTime    = null;
      _started      = false;
      _shiftPressed = false;
      _wrongKey     = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mounted) return;
      setState(() {
        if (_colors.isNotEmpty) _colors[0] = Colors.blue.shade200;
        _setKeyColor(0, Colors.blue.shade200);
        if (_isShiftRequired()) _highlightShift(true);
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KEYBOARD SETUP
  // ─────────────────────────────────────────────────────────────────────────

  void _setupKeyboard() {
    if (widget.languageCode == 'hi') {
      _keys = [
        ['TAB','ौ','ै','ा','ी','ू','ब','ह','ग','द','ज','ड','़','ॉ'],
        ['CAPS','ो','े','्','ि','ु','प','र','क','त','च','ट','ENTER'],
        ['SHIFT','ॅ','ं','म','न','व','ल','स',',','.','य','SHIFT'],
        ['SPACE'],
      ];
    } else if (widget.languageCode == 'gu') {
      _keys = [
        ['TAB','ૌ','ૈ','ા','ી','ૂ','બ','હ','ગ','દ','જ','ડ','઼','ૉ'],
        ['CAPS','ો','ે','્','િ','ુ','પ','ર','ક','ત','ચ','ટ','ENTER'],
        ['SHIFT','ૅ','ં','મ','ન','વ','લ','સ',',','.','ય','SHIFT'],
        ['SPACE'],
      ];
    } else {
      _keys = AppConstants.keyboardLayout
          .map((r) => List<String>.from(r)).toList();
    }
    _kc = _keys.map((r) =>
        List<Color>.filled(r.length, Colors.white)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KEY COLOUR HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void _setKeyColor(int i, Color color) {
    if (i >= _units.length) return;
    final ch     = _units[i];
    if (ch == ' ') { _kc[3][0] = color; return; }
    final lookup = _isIndic ? ch : ch.toUpperCase();
    for (int r = 0; r < _keys.length - 1; r++) {
      for (int c = 0; c < _keys[r].length; c++) {
        if (_keys[r][c] == lookup) { _kc[r][c] = color; return; }
      }
    }
  }

  void _clearKeyColor(int i) {
    if (i < 0 || i >= _units.length) return;
    final ch     = _units[i];
    if (ch == ' ') { _kc[3][0] = Colors.white; return; }
    final lookup = _isIndic ? ch : ch.toUpperCase();
    for (int r = 0; r < _keys.length - 1; r++) {
      for (int c = 0; c < _keys[r].length; c++) {
        if (_keys[r][c] == lookup) { _kc[r][c] = Colors.white; return; }
      }
    }
  }

  void _highlightShift(bool on) {
    final col = on ? Colors.blue.shade200 : Colors.white;
    _kc[2][0]                   = col;
    _kc[2][_keys[2].length - 1] = col;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHIFT DETECTION (language-aware)
  // ─────────────────────────────────────────────────────────────────────────

  bool _isShiftRequired() {
    if (_count >= _units.length) return false;
    final ch = _units[_count];
    if (!_isIndic) {
      if (ch.isEmpty) return false;
      final code = ch.codeUnitAt(0);
      return code >= 65 && code <= 90;
    }
    return IndicKeyMappings.requiresShift(ch, widget.languageCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KEY INPUT HANDLER
  // ─────────────────────────────────────────────────────────────────────────

  void _onKey(RawKeyEvent event) {
    if (!_mounted ||
        event is! RawKeyDownEvent ||
        _count >= _units.length) return;
    _startGame();

    final label = event.logicalKey.keyLabel ?? '';
    final lower = label.toLowerCase();
    final shift = event.isShiftPressed;

    // Shift key itself — just update state
    if (label == 'Shift Left' || label == 'Shift Right') {
      setState(() {
        _shiftPressed = shift;
        if (_isShiftRequired()) _highlightShift(shift);
      });
      return;
    }

    final expected = _units[_count];
    bool isCorrect;

    if (!_isIndic) {
      // ── English ──────────────────────────────────────────────────────────
      if (expected == ' ') {
        isCorrect = lower == 'space' || label == ' ';
      } else if (_isShiftRequired()) {
        isCorrect = shift && lower == expected.toLowerCase();
      } else {
        isCorrect = !shift && lower == expected.toLowerCase();
      }
    } else {
      // ── Indic: physical key → language char, compare atomically ──────────
      if (expected == ' ') {
        isCorrect = lower == 'space' || label == ' ';
      } else {
        final mapped = IndicKeyMappings.getMappedCharacter(
            lower, widget.languageCode, shift);
        isCorrect = AtomicTypingService.compareAtomicUnits(
            mapped, expected, widget.languageCode);
      }
    }

    isCorrect ? _handleCorrect() : _handleIncorrect(label);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CORRECT / INCORRECT HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  void _handleCorrect() {
    if (!_mounted) return;
    setState(() {
      if (_count < _colors.length) _colors[_count] = Colors.green;
      _correct++;
      _clearKeyColor(_count);
      _count++;

      if (_count < _units.length) {
        if (_count < _colors.length) _colors[_count] = Colors.blue.shade200;
        _setKeyColor(_count, Colors.blue.shade200);
        _highlightShift(_isShiftRequired());
        _autoScroll();
      } else {
        _highlightShift(false);
        _timer?.cancel();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showDialog());
      }
      _calcStats();
    });
  }

  void _handleIncorrect(String label) {
    if (!_mounted) return;
    setState(() {
      if (_count < _colors.length) _colors[_count] = Colors.red;
      _incorrect++;
      _wrongKey = label == ' ' ? 'SPACE' : label.toUpperCase();
      _shakeCtrl.forward().then((_) => _shakeCtrl.reverse());
      _clearKeyColor(_count);
      _count++;

      if (_count < _units.length) {
        if (_count < _colors.length) _colors[_count] = Colors.blue.shade200;
        _setKeyColor(_count, Colors.blue.shade200);
        _highlightShift(_isShiftRequired());
        _autoScroll();
      } else {
        _highlightShift(false);
        _timer?.cancel();
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _showDialog());
      }
      _calcStats();
    });

    Future.delayed(AppDurations.wrongKeyHintShort,
            () { if (_mounted) setState(() => _wrongKey = null); });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GAME TIMER / STATS
  // ─────────────────────────────────────────────────────────────────────────

  void _startGame() {
    if (_started) return;
    _startTime = DateTime.now();
    _started   = true;
    _timer = Timer.periodic(AppDurations.statsTick, (_) {
      if (_mounted) setState(() => _calcStats());
    });
  }

  void _calcStats() {
    if (_startTime == null) return;
    final elapsed = DateTime.now().difference(_startTime!).inSeconds;
    if (elapsed > 0) {
      _wpm = AtomicTypingService.calculateWpm(_correct, elapsed);
    }
  }

  double _accuracy() =>
      AtomicTypingService.calculateAccuracy(_correct, _incorrect);

  String _elapsed() {
    if (_startTime == null) return '00:00';
    final d = DateTime.now().difference(_startTime!);
    return '${d.inMinutes.toString().padLeft(2, '0')}'
        ':${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double _progress() =>
      _units.isEmpty ? 0 : (_count / _units.length).clamp(0.0, 1.0);

  // ─────────────────────────────────────────────────────────────────────────
  // AUTO-SCROLL  (sentence / paragraph only)
  // ─────────────────────────────────────────────────────────────────────────

  void _autoScroll() {
    if (_isWordMode) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mounted || !_textScroll.hasClients) return;
      final maxExt = _textScroll.position.maxScrollExtent;
      if (maxExt <= 0) return;
      final fraction = _count / _units.length.clamp(1, 999999);
      final target   = (maxExt * fraction - 20).clamp(0.0, maxExt);
      _textScroll.animateTo(target,
          duration: AppDurations.scrollFast, curve: Curves.easeOut);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SAVE RECORD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _saveRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user  = prefs.getString(AppKeys.username)
          ?? AppConstants.defaultUsername;
      await DatabaseHelper.instance.insertRecord(TypingRecord(
        username:     user,
        country:      AppConstants.defaultCountry,
        wpm:          _wpm,
        accuracy:     _accuracy(),
        languageCode: widget.languageCode,
      ));
    } catch (e) { debugPrint('Save error: $e'); }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPLETION DIALOG
  // ─────────────────────────────────────────────────────────────────────────

  void _showDialog() {
    if (!_mounted) return;
    _saveRecord();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
        scrollable: true,
        title: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFD8469), Color(0xFFFF6B35)]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.celebration, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text('Congratulations!',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ]),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth:  MediaQuery.of(context).size.width  * 0.9,
          ),
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            const Text('Exercise completed!',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _statsGrid(),
          ])),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD8469),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _itemIndex = (_itemIndex + 1) % _items.length;
              _loadItem(_itemIndex);
            },
            child: const Text('Continue',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid() {
    final w  = MediaQuery.of(context).size.width;
    final iw = (w * 0.9 - 36) / 2;
    final rows = [
      _dialogStatRow('Time',     _elapsed(),                Colors.purple),
      _dialogStatRow('WPM',      '$_wpm',                   Colors.blue),
      _dialogStatRow('Accuracy', '${_accuracy().toInt()}%', Colors.green),
      _dialogStatRow('Correct',  '$_correct',               Colors.green),
      _dialogStatRow('Wrong',    '$_incorrect',             Colors.red),
    ];
    return Wrap(spacing: 10, runSpacing: 6,
        children: rows.map((r) =>
            SizedBox(width: iw, child: r)).toList());
  }

  Widget _dialogStatRow(
      String label, String value, MaterialColor color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Row(children: [
          Expanded(flex: 3,
              child: Text(label,
                  style: TextStyle(fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700, fontSize: 12))),
          const SizedBox(width: 6),
          Expanded(flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(value,
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: color.shade800, fontSize: 12)),
              )),
        ]),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // STATIC HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  static PracticeType _toType(String s) {
    switch (s) {
      case 'sentence':  return PracticeType.sentence;
      case 'paragraph': return PracticeType.paragraph;
      default:          return PracticeType.word;
    }
  }

  static PracticeDifficulty _toDiff(String s) {
    switch (s) {
      case 'medium': return PracticeDifficulty.medium;
      case 'hard':   return PracticeDifficulty.hard;
      default:       return PracticeDifficulty.easy;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF0F2F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min,
            children: [
          const Text('No content available.',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _fetchContent,
              child: const Text('Retry')),
        ])),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        top: false, bottom: false,
        left: false, right: false,
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: _onKey,
          child: Row(children: [
            Expanded(
              flex: 7,
              child: Column(children: [
                _buildTextStrip(),
                const SizedBox(height: 6),
                Expanded(child: _buildKeyboardArea()),
              ]),
            ),
            _buildStatsSidebar(),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TEXT STRIP
  //   Word mode      → horizontal single-line Row (centred)
  //   Sentence/Para  → vertical Wrap with auto-scroll
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTextStrip() {
    final w      = MediaQuery.of(context).size.width;
    final fs     = w < 800 ? 15.0 : 17.0;
    final stripH = _isWordMode
        ? (w < 600 ? 54.0 : 62.0)   // compact: 1 line
        : (w < 600 ? 104.0 : 124.0); // taller: 3-4 lines

    final tiles = List.generate(_units.length, (i) {
      final col = i < _colors.length
          ? _colors[i]
          : Colors.grey.shade400;

      Color bg, border, txt;
      if (col == Colors.green) {
        bg = Colors.green.shade50; txt = Colors.green.shade800;
        border = Colors.green.shade300;
      } else if (col == Colors.red) {
        bg = Colors.red.shade50; txt = Colors.red.shade800;
        border = Colors.red.shade300;
      } else if (col == Colors.blue.shade200 || col == const Color(0xFF90CAF9)) {
        bg = const Color(0xFF0D47A1); txt = const Color(0xFF82B1FF);
        border = const Color(0xFF1565C0);
      } else {
        bg = const Color(0xFF1A2035); txt = const Color(0xFF5C6BC0);
        border = const Color(0xFF2E3A59);
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(_units[i],
          style: TextStyle(
            fontSize: fs,
            fontWeight: FontWeight.w600,
            color: txt,
            height: 1.25,
            fontFamily: _fontFamily,
          ),
        ),
      );
    });

    return Container(
      height: stripH,
      margin: const EdgeInsets.fromLTRB(8, 8, 4, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2035),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3))],
        border: Border.all(color: const Color(0xFF2E3A59)),
      ),
      child: _isWordMode
          // ── Word: horizontal single row, centred ─────────────────────────
          ? SingleChildScrollView(
              controller: _textScroll,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: tiles,
              ),
            )
          // ── Sentence / Paragraph: vertical wrap, auto-scroll only ────────
          : SingleChildScrollView(
              controller: _textScroll,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              child: Wrap(
                spacing: 1,
                runSpacing: 4,
                children: tiles,
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KEYBOARD AREA
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildKeyboardArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 4, 8),
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(_shakeAnim.value * sin(_count * pi), 0),
          child: child,
        ),
        child: _PracticeKeyboard(
          keys:         _keys,
          keyColors:    _kc,
          wrongKey:     _wrongKey,
          currentUnit:  _count < _units.length ? _units[_count] : '',
          languageCode: widget.languageCode,
          indicMap:     _indicToPhysical,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STATS SIDEBAR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatsSidebar() {
    final w = MediaQuery.of(context).size.width;
    final sideW = w < 500 ? 80.0 : (w < 800 ? 96.0 : 110.0);
    return Container(
      width: sideW,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF0D1B6E)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sideCard('Time',     _elapsed(),              const Color(0xFF80DEEA)),
        _sideCard('WPM',      '$_wpm',                 const Color(0xFF69F0AE)),
        _sideCard('Correct',  '$_correct',             const Color(0xFF64B5F6)),
        _sideCard('Errors',   '$_incorrect',           const Color(0xFFFF5252)),
        _sideCard('Accuracy', '${_accuracy().toInt()}%', const Color(0xFFFFD740)),
        _sideProgress(),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Column(children: [
              Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 14),
              SizedBox(height: 2),
              Text('Exit', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _sideCard(String label, String value, Color accent) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    margin: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: accent.withOpacity(0.25), width: 1),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value,
        style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()]),
        textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 1),
      Text(label,
        style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _sideProgress() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
    margin: const EdgeInsets.only(bottom: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF00E5FF).withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Progress',
        style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      LinearProgressIndicator(
        value: _progress(),
        backgroundColor: Colors.white12,
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
        minHeight: 5,
        borderRadius: BorderRadius.circular(3),
      ),
      const SizedBox(height: 3),
      Text('${(_progress() * 100).toInt()}%',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    ]),
  );
}

// =============================================================================
// _PracticeKeyboard  — same visual style as key_guide_screen.dart / Level1
//
// Differences from plain ModernKeyboardWidget:
//   • No hand-image coupling
//   • Tiny English sub-label beneath every Indic key
//   • Orange home-row keys (row index 1), with orange dot for English
// =============================================================================

class _PracticeKeyboard extends StatelessWidget {
  final List<List<String>>  keys;
  final List<List<Color>>   keyColors;
  final String?             wrongKey;
  final String              currentUnit;
  final String              languageCode;
  /// Indic char → English physical key letter  (empty for English)
  final Map<String, String> indicMap;

  const _PracticeKeyboard({
    required this.keys,
    required this.keyColors,
    required this.wrongKey,
    required this.currentUnit,
    required this.languageCode,
    required this.indicMap,
  });

  bool get _isIndic =>
      languageCode == 'hi' || languageCode == 'gu';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cons) {
      final maxW = min(cons.maxWidth  * 0.99, 820.0);
      final maxH = min(cons.maxHeight * 0.99, 265.0);

      return Center(
        child: Container(
          width: maxW, height: maxH,
          padding: EdgeInsets.symmetric(
              horizontal: maxW * 0.012,
              vertical:   maxH * 0.035),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:   Alignment.bottomCenter,
                colors: [const Color(0xFF1E2640), const Color(0xFF141927)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color:  Colors.black.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(keys.length,
                    (ri) => _buildRow(ctx, ri, maxW)),
          ),
        ),
      );
    });
  }

  Widget _buildRow(BuildContext ctx, int ri, double maxW) {
    final row = keys[ri];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(row.length,
              (ci) => _buildKey(ctx, row[ci], ri, ci, maxW)),
    );
  }

  Widget _buildKey(
      BuildContext ctx, String k, int ri, int ci, double maxW) {
    final isSpecial     = _isSpecialKey(k);
    final kw            = _keyWidth(k, maxW);
    final kh            = _keyHeight(ctx);
    final isHomeRow     = ri == 1 && !isSpecial;
    final isCurrent     = _isCurrent(k);
    final isHighlighted = ci < keyColors[ri].length &&
        keyColors[ri][ci] == Colors.blue.shade200;
    final isWrong = wrongKey != null &&
        (k == wrongKey ||
            (k == 'SPACE' && wrongKey?.toLowerCase() == 'space'));

    // gradient
    final List<Color> grad;
    if      (isWrong)                    grad = [const Color(0xFFFF1744), const Color(0xFFD50000)];
    else if (isCurrent || isHighlighted) grad = [const Color(0xFF00E5FF), const Color(0xFF00B8D4)];
    else if (isHomeRow)                  grad = [const Color(0xFFFFA726), const Color(0xFFEF6C00)];
    else if (isSpecial)                  grad = [const Color(0xFF2E3A59), const Color(0xFF253047)];
    else                                 grad = [const Color(0xFF3A4A6B), const Color(0xFF2E3A59)];

    // text colour
    final Color txtColor;
    if      (isWrong || isCurrent || isHighlighted) txtColor = const Color(0xFF0D1117);
    else if (isHomeRow)                             txtColor = const Color(0xFF1A0A00);
    else if (isSpecial)                             txtColor = const Color(0xFF8A9CC0);
    else                                            txtColor = const Color(0xFFD0D8EF);

    // tiny English sub-label for Indic keys
    final String? subLabel =
    _isIndic && !isSpecial && k != 'SPACE'
        ? indicMap[k]?.toUpperCase()
        : null;

    return Container(
      width: kw, height: kh,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: grad),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isCurrent || isWrong) ? grad[0] : const Color(0xFF4A5A7A),
          width: (isCurrent || isWrong) ? 1.5 : 0.8,
        ),
        boxShadow: [
          if (isCurrent) BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 8, spreadRadius: 1),
          if (isWrong)  BoxShadow(color: const Color(0xFFFF1744).withOpacity(0.5), blurRadius: 8, spreadRadius: 1),
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
        // ── Main character
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(_displayText(k),
            style: TextStyle(
              color:      txtColor,
              fontSize:   _fontSize(k),
              fontWeight: (isCurrent || isWrong)
                  ? FontWeight.bold : FontWeight.w600,
              fontFamily: _isIndic && !isSpecial
                  ? 'Noto Sans Devanagari' : null,
            ),
          ),
        ),
        // ── English sub-label for Indic keyboards
        if (subLabel != null && subLabel.isNotEmpty)
          Text(subLabel,
            style: TextStyle(
              color:      txtColor.withOpacity(0.60),
              fontSize:   7,
              fontWeight: FontWeight.w500,
              height:     1.0,
            ),
          ),
        // ── Home-row dot  (English only)
        if (isHomeRow && !_isIndic)
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 3, height: 2,
            decoration: BoxDecoration(
              color: Colors.orange.shade500,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ]),
    );
  }

  bool _isCurrent(String k) {
    if (currentUnit.isEmpty) return false;
    if (currentUnit == ' ')  return k == 'SPACE';
    if (!_isIndic) return k == currentUnit.toUpperCase();
    return k == currentUnit;
  }

  bool   _isSpecialKey(String k) =>
      ['TAB','CAPS','ENTER','SHIFT','SPACE'].contains(k);

  double _fontSize(String k) =>
      _isSpecialKey(k) ? 10 : 13;

  String _displayText(String k) {
    switch (k) {
      case 'TAB':   return 'Tab';
      case 'CAPS':  return 'Caps';
      case 'ENTER': return '⏎';
      case 'SHIFT': return '⇧';
      case 'SPACE': return 'Space';
      default:      return k;
    }
  }

  double _keyWidth(String k, double maxW) {
    final base = maxW / 15.5;
    switch (k) {
      case 'TAB':   return base * 1.5;
      case 'CAPS':  return base * 1.6;
      case 'ENTER': return base * 1.6;
      case 'SHIFT': return base * 2.0;
      case 'SPACE': return base * 6.5;
      default:      return base;
    }
  }

  double _keyHeight(BuildContext ctx) {
    final h = MediaQuery.of(ctx).size.height;
    return h < 400 ? 26 : (h < 550 ? 30 : 36);
  }
}