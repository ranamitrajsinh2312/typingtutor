import 'dart:math' show max;
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

// ─── Language meta ───────────────────────────────────────────────────────────
class _LangMeta {
  final String code, label, flag;
  final Color  color;
  const _LangMeta(this.code, this.label, this.flag, this.color);
}
const _kLangs = [
  _LangMeta('en', 'English',  '🇺🇸', Color(0xFF1E88E5)),
  _LangMeta('hi', 'Hindi',    '🇮🇳', Color(0xFFE91E63)),
  _LangMeta('gu', 'Gujarati', '🇮🇳', Color(0xFF00BCD4)),
];
_LangMeta _metaFor(String code) => _kLangs.firstWhere(
  (l) => l.code == code,
  orElse: () => _LangMeta(code, code.toUpperCase(), '🌐', const Color(0xFF8B5CF6)),
);

class _LangStats {
  final String code;
  final double avgWpm, bestWpm, avgAccuracy, total;
  const _LangStats({required this.code, required this.avgWpm,
      required this.bestWpm, required this.avgAccuracy, required this.total});
}

// ── Profile Screen ────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  TypingStats?       stats;
  List<TypingRecord> recentRecords = [];
  List<_LangStats>   langStats     = [];
  bool   isLoading = true;
  String username   = AppConstants.defaultUsername;
  late TabController _tabCtrl;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
    ]);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    await _loadUsername();
    await _loadStats();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppKeys.username);
    if (saved != null && saved.isNotEmpty) setState(() => username = saved);
  }

  Future<void> _saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.username, name);
    setState(() => username = name);
  }

  Future<void> _loadStats() async {
    try {
      final db = DatabaseHelper.instance;
      final s  = await db.getStats();
      final r  = await db.fetchAllRecords();
      final map = <String, List<TypingRecord>>{};
      for (final rec in r) {
        map.putIfAbsent(rec.languageCode, () => []).add(rec);
      }
      final ls = map.entries.map((e) {
        final recs = e.value;
        return _LangStats(
          code:        e.key,
          avgWpm:      recs.map((r) => r.wpm.toDouble()).reduce((a, b) => a + b) / recs.length,
          bestWpm:     recs.map((r) => r.wpm.toDouble()).reduce(max),
          avgAccuracy: recs.map((r) => r.accuracy).reduce((a, b) => a + b) / recs.length,
          total:       recs.length.toDouble(),
        );
      }).toList();
      if (mounted) setState(() { stats = s; recentRecords = r; langStats = ls; isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _buildBody(size, isWide),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.heroGradient)),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
      onPressed: () => Get.back()),
    title: Text('My Profile', style: GoogleFonts.poppins(
      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
    actions: [
      IconButton(
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
        onPressed: _showEditNameDialog),
    ],
    bottom: TabBar(
      controller: _tabCtrl,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicatorColor: const Color(0xFF00E5FF),
      indicatorWeight: 3,
      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
      tabs: const [Tab(text: 'Overview'), Tab(text: 'History')],
    ),
  );

  Widget _buildBody(Size size, bool isWide) => TabBarView(
    controller: _tabCtrl,
    children: [
      _buildOverview(size, isWide),
      _buildHistory(size, isWide),
    ],
  );

  // ── Overview tab ─────────────────────────────────────────────────────────

  Widget _buildOverview(Size size, bool isWide) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildProfileHero(isWide),
      const SizedBox(height: 20),
      _buildStatsGrid(isWide),
      const SizedBox(height: 20),
      if (langStats.isNotEmpty) ...[
        _sectionTitle('By Language'),
        const SizedBox(height: 10),
        ...langStats.map((l) => _buildLangCard(l)),
      ],
    ]),
  );

  Widget _buildProfileHero(bool isWide) => Container(
    padding: EdgeInsets.all(isWide ? 24 : 18),
    decoration: BoxDecoration(
      gradient: AppTheme.heroGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Row(children: [
      // Avatar
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF00E5FF), width: 2.5),
        ),
        child: Center(child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(username, style: GoogleFonts.poppins(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.keyboard_alt_outlined, color: Colors.white54, size: 14),
          const SizedBox(width: 4),
          Text('${stats?.totalAttempts ?? 0} sessions',
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        _buildBestBadge(),
      ])),
    ]),
  );

  Widget _buildBestBadge() {
    final best = stats?.bestWpm ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 14),
        const SizedBox(width: 5),
        Text('Best: $best WPM', style: GoogleFonts.poppins(
          color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildStatsGrid(bool isWide) {
    final items = [
      _StatItem('Total Sessions', '${stats?.totalAttempts ?? 0}', Icons.repeat_rounded,      const Color(0xFF1E88E5)),
      _StatItem('Avg Speed',      '${(stats?.avgWpm.toDouble() ?? 0).toInt()} WPM', Icons.speed_rounded, const Color(0xFF43A047)),
      _StatItem('Best Speed',     '${stats?.bestWpm ?? 0} WPM', Icons.military_tech_rounded, Colors.amber),
      _StatItem('Avg Accuracy',   '${(stats?.avgAccuracy ?? 0).toInt()}%', Icons.gps_fixed_rounded, const Color(0xFF00BCD4)),
      _StatItem('Total Chars',    '${0}', Icons.text_fields_rounded, const Color(0xFF8E24AA)),
      _StatItem('Practice Time',  _formatTime(0), Icons.timer_rounded, const Color(0xFFF57C00)),
    ];
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: isWide ? 1.6 : 1.5,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildStatCard(items[i]),
    );
  }

  Widget _buildStatCard(_StatItem s) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.cardShadow,
      border: Border.all(color: s.color.withOpacity(0.15)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: s.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(s.icon, color: s.color, size: 18)),
      const Spacer(),
      Text(s.value, style: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w900, color: s.color,
        fontFeatures: const [FontFeature.tabularFigures()])),
      Text(s.label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _buildLangCard(_LangStats ls) {
    final meta = _metaFor(ls.code);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: meta.color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Text(meta.flag, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(meta.label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF1A237E))),
          const SizedBox(height: 4),
          Row(children: [
            _langChip('⚡ ${ls.bestWpm.toInt()} WPM', meta.color),
            const SizedBox(width: 6),
            _langChip('🎯 ${ls.avgAccuracy.toInt()}%', meta.color),
            const SizedBox(width: 6),
            _langChip('${ls.total.toInt()} sessions', meta.color),
          ]),
        ])),
        Column(children: [
          Text('Avg', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black45)),
          Text('${ls.avgWpm.toInt()}', style: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w900, color: meta.color)),
          Text('WPM', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black45)),
        ]),
      ]),
    );
  }

  Widget _langChip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );

  // ── History tab ──────────────────────────────────────────────────────────

  Widget _buildHistory(Size size, bool isWide) {
    if (recentRecords.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(Icons.history_rounded, color: AppTheme.primaryColor, size: 48)),
        const SizedBox(height: 16),
        Text('No records yet!', style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryColor)),
        const SizedBox(height: 8),
        Text('Complete a session to see your history', style: GoogleFonts.poppins(
          fontSize: 13, color: Colors.black45)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentRecords.length,
      itemBuilder: (_, i) => _buildRecordCard(recentRecords[i], i),
    );
  }

  Widget _buildRecordCard(TypingRecord r, int index) {
    final wpm  = r.wpm;
    final acc  = r.accuracy;
    final lang = _metaFor(r.languageCode);
    final wpmColor = wpm >= 60 ? const Color(0xFF43A047) : (wpm >= 30 ? const Color(0xFFF57C00) : const Color(0xFFE53935));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: wpmColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: wpmColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text('#${index + 1}',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: wpmColor))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(lang.flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Text(lang.label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A237E))),
          ]),
          const SizedBox(height: 3),
          Text(r.username, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$wpm WPM', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: wpmColor)),
          Text('${acc.toInt()}% acc', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
        ]),
      ]),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String t) => Text(t, style: GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryColor));

  String _formatTime(int seconds) {
    if (seconds < 60)   return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }

  void _showEditNameDialog() {
    _nameCtrl.text = username;
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Edit Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
      content: TextField(
        controller: _nameCtrl,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: GoogleFonts.poppins(color: Colors.black38),
          filled: true, fillColor: const Color(0xFFF0F4FF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2)),
          prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isNotEmpty) { _saveUsername(name); Navigator.pop(context); }
          },
          child: Text('Save', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
