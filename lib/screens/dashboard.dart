import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

// =========================================================================
// 🏠 DASHBOARD — Production-Ready, Responsive, Attractive
// =========================================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  final List<String> _images      = AppConstants.keyboardImages;
  final List<String> _levels      = AppConstants.typingLevels;
  final List<String> _descs       = AppConstants.levelDescriptions;
  String _keyboardLang   = 'en';
  String _practiceLang   = 'en';

  static const _langOptions = [
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English',    'layout': 'QWERTY'},
    {'code': 'hi', 'flag': '🇮🇳', 'name': 'हिंदी',      'layout': 'Inscript'},
    {'code': 'gu', 'flag': '🇮🇳', 'name': 'ગુજરાતી',   'layout': 'Inscript'},
  ];

  late AnimationController _headerCtrl;
  late AnimationController _cardsCtrl;
  late List<AnimationController> _cardCtrls;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardsCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _cardCtrls  = List.generate(_levels.length, (i) =>
        AnimationController(vsync: this, duration: Duration(milliseconds: 300 + i * 60)));
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);
    _headerCtrl.forward();
    for (int i = 0; i < _cardCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + i * 50), () {
        if (mounted) _cardCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    for (final c in _cardCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(isWide),
      body: _buildBody(context, size, isWide),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWide) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppTheme.heroGradient),
      ),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.keyboard_alt_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppText.appTitle, style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
          Text('Master Your Typing', style: GoogleFonts.poppins(
            color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w400)),
        ]),
      ]),
      actions: [
        _appBarIconBtn(Icons.bar_chart_rounded, () => Get.toNamed(AppRoutes.practiceRecords), 'Records'),
        _appBarIconBtn(Icons.person_rounded, () => Get.toNamed(AppRoutes.profile), 'Profile'),
        _appBarIconBtn(Icons.info_outline_rounded, () {
          Get.to(() => DeveloperScreen(
            developerName:   AppConstants.developerName,
            mentorName:      AppConstants.mentorName,
            exploredByName:  AppConstants.instituteName,
            isAdmissionApp:  false,
            shareMessage:    AppConstants.shareMessage,
            appTitle:        AppConfig.appName,
            appLogo:         AppAssets.appLogo,
          ));
        }, 'About'),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _appBarIconBtn(IconData icon, VoidCallback onTap, String tooltip) {
    return Container(
      margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: () { HapticFeedback.lightImpact(); onTap(); },
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Size size, bool isWide) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHero(context, size, isWide),
        _buildStatsBar(context),
        _buildSectionHeader('⌨️ Keyboard Lessons', 'Learn row-by-row with highlighted keys', _keyboardLang, (v) => setState(() => _keyboardLang = v!)),
        _buildKeyboardLessonsGrid(context, size, isWide),
        _buildSectionHeader('🎯 Practice Modes', 'Build speed and accuracy with adaptive content', _practiceLang, (v) => setState(() => _practiceLang = v!)),
        _buildPracticeModes(context, size, isWide),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildHero(BuildContext context, Size size, bool isWide) {
    return AnimatedBuilder(animation: _headerAnim, builder: (_, __) {
      return Transform.translate(
        offset: Offset(0, 30 * (1 - _headerAnim.value)),
        child: Opacity(opacity: _headerAnim.value,
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: EdgeInsets.all(isWide ? 24 : 18),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3),
                    blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🚀 Start Typing!', style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: isWide ? 22 : 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Build muscle memory with guided practice. Start with Home Row and progress to full keyboard mastery!',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: isWide ? 13 : 12, height: 1.5)),
                const SizedBox(height: 16),
                _buildHeroChips(),
              ])),
              if (isWide) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.keyboard_alt_outlined, color: Colors.white, size: 52),
                ),
              ],
            ]),
          ),
        ),
      );
    });
  }

  Widget _buildHeroChips() {
    final chips = [
      ('9 Levels', Icons.layers_rounded),
      ('3 Languages', Icons.translate_rounded),
      ('WPM Tracking', Icons.speed_rounded),
    ];
    return Wrap(spacing: 8, runSpacing: 6, children: chips.map((c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(c.$2, color: Colors.white70, size: 14),
        const SizedBox(width: 5),
        Text(c.$1, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    )).toList());
  }

  Widget _buildStatsBar(BuildContext context) {
    final stats = [
      ('9', 'Lessons',    Icons.school_rounded,          const Color(0xFF3F51B5)),
      ('3', 'Languages',  Icons.translate_rounded,        const Color(0xFF009688)),
      ('∞', 'Practice',  Icons.loop_rounded,             const Color(0xFFF57C00)),
      ('📊', 'Records',  Icons.insert_chart_rounded,     const Color(0xFF8E24AA)),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: stats.asMap().entries.map((e) => Expanded(child: Container(
        margin: EdgeInsets.only(right: e.key < stats.length - 1 ? 8 : 0),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: e.value.$4.withOpacity(0.15)),
        ),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: e.value.$4.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(e.value.$3, color: e.value.$4, size: 18)),
          const SizedBox(height: 6),
          Text(e.value.$1, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: e.value.$4)),
          Text(e.value.$2, style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54, fontWeight: FontWeight.w500)),
        ]),
      ))).toList()),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, String selectedLang, ValueChanged<String?> onLangChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryColor)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
        ])),
        _buildLanguageChip(selectedLang, onLangChanged),
      ]),
    );
  }

  Widget _buildLanguageChip(String value, ValueChanged<String?> onChanged) {
    final sel = _langOptions.firstWhere((l) => l['code'] == value, orElse: () => _langOptions[0]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
      ),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(
        value: value, isDense: true,
        icon: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryColor, size: 20),
        items: _langOptions.map((l) => DropdownMenuItem<String>(
          value: l['code'],
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(l['flag']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(l['name']!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryColor)),
          ]),
        )).toList(),
        onChanged: (v) { HapticFeedback.selectionClick(); onChanged(v); },
      )),
    );
  }

  // ── Keyboard Lessons Grid ─────────────────────────────────────────────────

  Widget _buildKeyboardLessonsGrid(BuildContext context, Size size, bool isWide) {
    if (isWide) {
      // Tablet / desktop: 2-column grid
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size.width > 900 ? 3 : 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: _levels.length,
          itemBuilder: (_, i) => _buildLessonCard(i, true),
        ),
      );
    } else {
      // Phone: horizontal scroll
      return SizedBox(
        height: 210,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _levels.length,
          itemBuilder: (_, i) => AnimatedBuilder(
            animation: _cardCtrls[i],
            builder: (_, __) => Transform.translate(
              offset: Offset(0, 20 * (1 - _cardCtrls[i].value)),
              child: Opacity(opacity: _cardCtrls[i].value,
                child: SizedBox(width: size.width * 0.72, child: _buildLessonCard(i, false))),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLessonCard(int i, bool isGrid) {
    final color = _difficultyColor(i);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(AppRoutes.level1, arguments: {'lesson': _levels[i], 'languageCode': _keyboardLang});
      },
      child: Container(
        margin: EdgeInsets.only(right: isGrid ? 0 : 12, bottom: isGrid ? 0 : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Colored top strip
            Container(height: 4, decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
            )),
            Expanded(child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(_difficultyText(i), style: GoogleFonts.poppins(
                      fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ),
                  const Spacer(),
                  Icon(_difficultyIcon(i), color: color, size: 16),
                ]),
                const SizedBox(height: 8),
                Text(_levels[i], style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Expanded(child: Text(_descs[i], style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.black45, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 8),
                // Keyboard image strip
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.15)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(_images[i], fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.keyboard_alt_rounded, color: color, size: 20)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Start', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            )),
          ]),
        ),
      ),
    );
  }

  // ── Practice Modes ────────────────────────────────────────────────────────

  Widget _buildPracticeModes(BuildContext context, Size size, bool isWide) {
    final modes = [
      _PracticeMode('Word Practice',      'Single words to build accuracy and speed',
          Icons.text_fields_rounded, const Color(0xFF43A047), 'word',      AppRoutes.wordLevels),
      _PracticeMode('Sentence Practice',  'Complete sentences for natural rhythm',
          Icons.short_text_rounded,  const Color(0xFFF57C00), 'sentence',  AppRoutes.sentenceLevels),
      _PracticeMode('Paragraph Practice', 'Long-form typing for real-world speed',
          Icons.article_rounded,     const Color(0xFFE53935), 'paragraph', AppRoutes.paragraphLevels),
    ];

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: modes.asMap().entries.map((e) => Expanded(child: Container(
          margin: EdgeInsets.only(right: e.key < modes.length - 1 ? 12 : 0),
          child: _buildPracticeModeCard(e.value, true),
        ))).toList()),
      );
    }

    return Column(children: modes.map((m) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: _buildPracticeModeCard(m, false),
    )).toList());
  }

  Widget _buildPracticeModeCard(_PracticeMode mode, bool isCompact) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(mode.route, arguments: {'languageCode': _practiceLang});
      },
      child: Container(
        padding: EdgeInsets.all(isCompact ? 16 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: mode.color.withOpacity(0.2)),
        ),
        child: isCompact
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: mode.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(mode.icon, color: mode.color, size: 24)),
                const SizedBox(height: 12),
                Text(mode.title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: mode.color)),
                const SizedBox(height: 4),
                Text(mode.subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54, height: 1.4)),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Start →', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: mode.color)),
                ]),
              ])
            : Row(children: [
                Container(padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: mode.color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(mode.icon, color: mode.color, size: 26)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mode.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: mode.color)),
                  const SizedBox(height: 3),
                  Text(mode.subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, height: 1.4)),
                ])),
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: mode.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.arrow_forward_rounded, color: mode.color, size: 18)),
              ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _difficultyColor(int i) {
    if (i == 0 || i == 8) return const Color(0xFF43A047);
    if (i == 1 || i == 2 || i == 7) return const Color(0xFFF57C00);
    return const Color(0xFF7B1FA2);
  }
  String _difficultyText(int i) {
    if (i == 0 || i == 8) return 'Beginner';
    if (i == 1 || i == 2 || i == 7) return 'Intermediate';
    return 'Advanced';
  }
  IconData _difficultyIcon(int i) {
    if (i == 0 || i == 8) return Icons.star_border_rounded;
    if (i == 1 || i == 2 || i == 7) return Icons.star_half_rounded;
    return Icons.star_rounded;
  }
}

class _PracticeMode {
  final String title, subtitle, type, route;
  final IconData icon;
  final Color color;
  const _PracticeMode(this.title, this.subtitle, this.icon, this.color, this.type, this.route);
}
