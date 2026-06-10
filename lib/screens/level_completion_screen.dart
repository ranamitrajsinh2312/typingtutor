// =========================================================================
// 🏆 LEVEL COMPLETION SCREEN — Beautiful Results Screen
// =========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/models/practice_level.dart';
import 'package:typingtutor/constants/app_constants.dart';

class LevelCompletionScreen extends StatefulWidget {
  final LevelCompletionResult result;
  final PracticeLevel level;
  final PracticeType type;
  final String languageCode;
  final VoidCallback? onContinue;
  final VoidCallback? onRetry;

  const LevelCompletionScreen({
    Key? key,
    required this.result,
    required this.level,
    required this.type,
    this.languageCode = 'en',
    this.onContinue,
    this.onRetry,
  }) : super(key: key);

  @override
  State<LevelCompletionScreen> createState() => _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends State<LevelCompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _statsCtrl;
  late AnimationController _starsCtrl;
  late Animation<double> _heroAnim;
  late Animation<double> _statsAnim;
  late Animation<double> _starsAnim;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.elasticOut);
    _statsAnim = CurvedAnimation(
      parent: _statsCtrl,
      curve: Curves.easeOutCubic,
    );
    _starsAnim = CurvedAnimation(parent: _starsCtrl, curve: Curves.elasticOut);

    _heroCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _statsCtrl.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 500),
      () => _starsCtrl.forward(),
    );
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _statsCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  int get _stars => widget.result.starsEarned;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B6E), Color(0xFF1A237E), Color(0xFF2E0052)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: Column(
              children: [
                // ── Trophy / Medal ────────────────────────────────────────────
                ScaleTransition(scale: _heroAnim, child: _buildTrophy()),
                const SizedBox(height: 24),
                // ── Stars ─────────────────────────────────────────────────────
                ScaleTransition(scale: _starsAnim, child: _buildStars()),
                const SizedBox(height: 8),
                Text(
                  _levelMessage(),
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                // ── Stats ─────────────────────────────────────────────────────
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_statsAnim),
                  child: FadeTransition(
                    opacity: _statsAnim,
                    child: _buildStats(isWide),
                  ),
                ),
                const SizedBox(height: 28),
                // ── Buttons ───────────────────────────────────────────────────
                FadeTransition(
                  opacity: _statsAnim,
                  child: _buildButtons(isWide),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy() => Column(
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          color: Colors.amber,
          size: 52,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Level Complete!',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        widget.level.title,
        style: GoogleFonts.poppins(
          color: const Color(0xFF80DEEA),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _buildStars() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      3,
      (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AnimatedBuilder(
          animation: _starsCtrl,
          builder: (_, __) {
            final delay = i * 0.15;
            final t = ((_starsCtrl.value - delay) / (1.0 - delay)).clamp(
              0.0,
              1.0,
            );
            final filled = i < _stars;
            return Transform.scale(
              scale: filled ? (0.5 + 0.5 * t) : 1.0,
              child: Icon(
                i < _stars ? Icons.star_rounded : Icons.star_border_rounded,
                color: i < _stars ? Colors.amber : Colors.white24,
                size: 44,
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildStats(bool isWide) {
    final r = widget.result;
    final items = [
      _S('Speed', '${r.wpm} WPM', Icons.speed_rounded, const Color(0xFF69F0AE)),
      _S(
        'Accuracy',
        '${r.accuracy.toInt()}%',
        Icons.gps_fixed_rounded,
        const Color(0xFF82B1FF),
      ),
      _S(
        'Correct',
        '${r.correctChars}',
        Icons.check_circle_rounded,
        const Color(0xFF69F0AE),
      ),
      _S(
        'Errors',
        '${r.incorrectChars}',
        Icons.cancel_rounded,
        const Color(0xFFFF5252),
      ),
      _S(
        'Time',
        _fmtDuration(r.timeTaken),
        Icons.timer_rounded,
        const Color(0xFFFFD740),
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            'Your Results',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          isWide
              ? Row(
                children:
                    items.map((s) => Expanded(child: _statCell(s))).toList(),
              )
              : GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: items.map(_statCell).toList(),
              ),
        ],
      ),
    );
  }

  Widget _statCell(_S s) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: s.color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(s.icon, color: s.color, size: 18),
      ),
      const SizedBox(height: 6),
      Text(
        s.value,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: s.color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      Text(
        s.label,
        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
      ),
    ],
  );

  Widget _buildButtons(bool isWide) {
    return isWide
        ? Row(
          children: [
            Expanded(child: _retryBtn()),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: _continueBtn()),
          ],
        )
        : Column(
          children: [_continueBtn(), const SizedBox(height: 10), _retryBtn()],
        );
  }

  Widget _continueBtn() => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: const Color(0xFF0D1117),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        if (widget.onContinue != null)
          widget.onContinue!();
        else
          Get.back();
      },
      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
      label: Text(
        'Continue',
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
  );

  Widget _retryBtn() => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        if (widget.onRetry != null)
          widget.onRetry!();
        else
          Get.back();
      },
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: Text(
        'Try Again',
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );

  String _levelMessage() {
    if (_stars == 3) return '🔥 Perfect Score! Outstanding!';
    if (_stars == 2) return '👏 Great job! Keep it up!';
    if (_stars == 1) return '💪 Good start! Practice more!';
    return '📚 Keep practicing to earn stars!';
  }
}

class _S {
  final String label, value;
  final IconData icon;
  final Color color;
  const _S(this.label, this.value, this.icon, this.color);
}

String _fmtDuration(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return m > 0 ? '${m}m ${s}s' : '${s}s';
}
