import 'dart:math' show max;
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Language meta
// ─────────────────────────────────────────────────────────────────────────────

class _LangMeta {
  final String code;
  final String label;
  final String flag;
  final Color  color;
  const _LangMeta(this.code, this.label, this.flag, this.color);
}

const _kLangs = [
  _LangMeta('en', 'English',  '🇬🇧', Color(0xFF3B82F6)),
  _LangMeta('hi', 'Hindi',    '🇮🇳', Color(0xFFEC4899)),
  _LangMeta('gu', 'Gujarati', '🇮🇳', Color(0xFF10B981)),
];

_LangMeta _metaFor(String code) => _kLangs.firstWhere(
      (l) => l.code == code,
      orElse: () => _LangMeta(code, code.toUpperCase(), '🌐', const Color(0xFF8B5CF6)),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Language stats data class
// ─────────────────────────────────────────────────────────────────────────────

class _LangStats {
  final String code;
  final double avgWpm;
  final double bestWpm;
  final double avgAccuracy;
  final double total;
  const _LangStats({
    required this.code,
    required this.avgWpm,
    required this.bestWpm,
    required this.avgAccuracy,
    required this.total,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  TypingStats?       stats;
  List<TypingRecord> recentRecords = [];
  List<_LangStats>   langStats     = [];
  bool   isLoading = true;
  String username  = AppConstants.defaultUsername;

  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // ── data loading ───────────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    await _loadUsername();
    await _loadStats();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppKeys.username);
    if (saved != null && saved.isNotEmpty) {
      setState(() => username = saved);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showUsernameDialog());
    }
  }

  Future<void> _saveUsername(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeys.username, newName);
    setState(() => username = newName);
  }

  Future<void> _loadStats() async {
    try {
      final s      = await DatabaseHelper.instance.getStats();
      final all    = await DatabaseHelper.instance.fetchAllRecords();
      final byLang = await DatabaseHelper.instance.getStatsByLanguage();

      final ls = byLang.entries
          .map((e) => _LangStats(
                code:        e.key,
                avgWpm:      e.value['avg_wpm']      ?? 0,
                bestWpm:     e.value['best_wpm']     ?? 0,
                avgAccuracy: e.value['avg_accuracy'] ?? 0,
                total:       e.value['total']        ?? 0,
              ))
          .toList()
        ..sort((a, b) => b.avgWpm.compareTo(a.avgWpm));

      setState(() {
        stats         = s;
        recentRecords = all.take(5).toList();
        langStats     = ls;
        isLoading     = false;
      });
    } catch (e) {
      debugPrint('ProfileScreen: $e');
      setState(() => isLoading = false);
    }
  }

  // ── username dialog ────────────────────────────────────────────────────────

  void _showUsernameDialog() {
    final ctrl = TextEditingController(
        text: username == AppConstants.defaultUsername ? '' : username);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Username',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF1E293B))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter your username',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
          const SizedBox(height: 20),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Your name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person, color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
          ),
        ]),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final name = ctrl.text.trim();
                  if (name.isNotEmpty) {
                    _saveUsername(name);
                    Navigator.pop(context);
                  } else {
                    Get.snackbar('Invalid', 'Please enter a valid username',
                        backgroundColor: const Color(0xFFEF4444),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(12),
                        borderRadius: 8);
                  }
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';
    }
    if (diff.inDays == 1)  return 'Yesterday';
    if (diff.inDays < 7)   return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(children: [
        _buildHeader(),
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabCtrl,
            labelColor: const Color(0xFF1E40AF),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF3B82F6),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Language Stats'),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildOverviewTab(),
                    _buildLanguageStatsTab(),
                  ],
                ),
        ),
      ]),
    );
  }

  // ── header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF60A5FA)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        child: Row(children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: _showUsernameDialog,
                child: Row(children: [
                  Expanded(
                    child: Text(username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ]),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Typing Enthusiast',
                    style: TextStyle(
                        fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OVERVIEW TAB
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Stat cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statCard('Best WPM',       '${stats?.bestWpm ?? 0}',
                Icons.speed,         const Color(0xFF3B82F6)),
            _statCard('Avg WPM',        '${stats?.avgWpm ?? 0}',
                Icons.trending_up,   const Color(0xFFEC4899)),
            _statCard('Avg Accuracy',   '${(stats?.avgAccuracy ?? 0).toInt()}%',
                Icons.track_changes, const Color(0xFF10B981)),
            _statCard('Total Sessions', '${stats?.totalAttempts ?? 0}',
                Icons.assessment,    const Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 20),
        if (recentRecords.isNotEmpty) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Performance',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            TextButton(
              onPressed: () async {
                await Get.toNamed(AppRoutes.practiceRecords);
                _loadStats();
              },
              child: const Text('See All',
                  style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: recentRecords.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Color(0xFFE2E8F0), height: 16),
              itemBuilder: (_, i) => _recordItem(recentRecords[i]),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 32, height: 32,
            decoration:
                BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _recordItem(TypingRecord r) {
    final meta = _metaFor(r.languageCode);
    return Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('${r.wpm}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${r.wpm} WPM',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Row(children: [
            // language badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: meta.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Text('${meta.flag} ${meta.label}',
                  style: TextStyle(
                      fontSize: 10, color: meta.color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            // accuracy badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: Text('${r.accuracy.toInt()}%',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(_formatDate(r.createdAt),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ]),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LANGUAGE STATS TAB
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLanguageStatsTab() {
    if (langStats.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bar_chart_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No language data yet',
              style: TextStyle(
                  fontSize: 16, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Complete some practice sessions\nto see your language stats here',
              style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              textAlign: TextAlign.center),
        ]),
      );
    }

    final maxBestWpm    = langStats.map((s) => s.bestWpm).fold(0.0, max);
    final maxAvgWpm     = langStats.map((s) => s.avgWpm).fold(0.0, max);
    final maxSessions   = langStats.map((s) => s.total).fold(0.0, max);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Per-language summary cards
        ...langStats.map(_buildLangCard),
        const SizedBox(height: 8),
        // ── Chart 1: Avg WPM ──────────────────────────────────────────────
        _sectionTitle('Average WPM by Language', Icons.speed),
        const SizedBox(height: 10),
        _barChart(
          values: langStats.map((s) => s.avgWpm).toList(),
          labels: langStats.map((s) => _metaFor(s.code).label).toList(),
          colors: langStats.map((s) => _metaFor(s.code).color).toList(),
          maxVal: maxAvgWpm <= 0 ? 1 : maxAvgWpm * 1.15,
          unit:   'wpm',
        ),
        const SizedBox(height: 20),
        // ── Chart 2: Best WPM ─────────────────────────────────────────────
        _sectionTitle('Best WPM by Language', Icons.emoji_events),
        const SizedBox(height: 10),
        _barChart(
          values:      langStats.map((s) => s.bestWpm).toList(),
          labels:      langStats.map((s) => _metaFor(s.code).label).toList(),
          colors:      langStats.map((s) => _metaFor(s.code).color).toList(),
          maxVal:      maxBestWpm <= 0 ? 1 : maxBestWpm * 1.15,
          unit:        'wpm',
          highlighted: true,
        ),
        const SizedBox(height: 20),
        // ── Chart 3: Accuracy ─────────────────────────────────────────────
        _sectionTitle('Average Accuracy by Language', Icons.track_changes),
        const SizedBox(height: 10),
        _barChart(
          values: langStats.map((s) => s.avgAccuracy).toList(),
          labels: langStats.map((s) => _metaFor(s.code).label).toList(),
          colors: langStats.map((s) => _metaFor(s.code).color).toList(),
          maxVal: 100,
          unit:   '%',
        ),
        const SizedBox(height: 20),
        // ── Chart 4: Sessions ─────────────────────────────────────────────
        _sectionTitle('Sessions by Language', Icons.bar_chart),
        const SizedBox(height: 10),
        _barChart(
          values: langStats.map((s) => s.total).toList(),
          labels: langStats.map((s) => _metaFor(s.code).label).toList(),
          colors: langStats.map((s) => _metaFor(s.code).color).toList(),
          maxVal: maxSessions <= 0 ? 1 : maxSessions * 1.15,
          unit:   '',
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildLangCard(_LangStats ls) {
    final meta = _metaFor(ls.code);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: meta.color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: meta.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text('${meta.flag}  ${meta.label}',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: meta.color)),
          ),
          const Spacer(),
          Text('${ls.total.toInt()} sessions',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _miniStat('Best WPM',  '${ls.bestWpm.toInt()}',      meta.color),
          const SizedBox(width: 10),
          _miniStat('Avg WPM',   '${ls.avgWpm.toInt()}',       const Color(0xFF8B5CF6)),
          const SizedBox(width: 10),
          _miniStat('Accuracy',  '${ls.avgAccuracy.toInt()}%', const Color(0xFF10B981)),
        ]),
        const SizedBox(height: 12),
        // Accuracy progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (ls.avgAccuracy / 100).clamp(0.0, 1.0),
            backgroundColor: meta.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(meta.color),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF1E40AF)),
      const SizedBox(width: 6),
      Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
    ]);
  }

  Widget _barChart({
    required List<double> values,
    required List<String> labels,
    required List<Color>  colors,
    required double       maxVal,
    required String       unit,
    bool highlighted = false,
  }) {
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: CustomPaint(
        painter: _BarChartPainter(
          values:      values,
          labels:      labels,
          colors:      colors,
          maxVal:      maxVal,
          unit:        unit,
          highlighted: highlighted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BAR CHART PAINTER  (pure CustomPainter — no extra packages needed)
// ─────────────────────────────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color>  colors;
  final double       maxVal;
  final String       unit;
  final bool         highlighted;

  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.colors,
    required this.maxVal,
    required this.unit,
    this.highlighted = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const double botPad  = 34;   // x-axis label space
    const double topPad  = 20;   // value label space
    const double lPad    = 36;   // left: y-axis labels
    const double rPad    = 8;

    final chartH = size.height - botPad - topPad;
    final chartW = size.width  - lPad  - rPad;
    final n      = values.length;

    // ── grid lines + y-axis labels ──────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    const gridCount = 4;
    for (int g = 0; g <= gridCount; g++) {
      final y   = topPad + chartH - chartH * g / gridCount;
      final val = maxVal * g / gridCount;

      canvas.drawLine(Offset(lPad, y), Offset(lPad + chartW, y), gridPaint);

      final label = unit == '%'
          ? '${val.toInt()}%'
          : val >= 1000
              ? '${(val / 1000).toStringAsFixed(1)}k'
              : val.toInt().toString();

      _paintText(canvas,
          text:  label,
          style: const TextStyle(fontSize: 8.5, color: Color(0xFFCBD5E1)),
          x:     0,
          y:     y - 5,
          maxW:  lPad - 2);
    }

    // ── bars ────────────────────────────────────────────────────────────────
    final groupW = chartW / n;
    final barW   = (groupW * 0.55).clamp(18.0, 72.0);

    for (int i = 0; i < n; i++) {
      final ratio = (values[i] / maxVal).clamp(0.0, 1.0);
      final barH  = max(chartH * ratio, 4.0);
      final x     = lPad + i * groupW + (groupW - barW) / 2;
      final y     = topPad + chartH - barH;
      final c     = colors[i];

      // drop shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2, y + 4, barW, barH),
          const Radius.circular(7),
        ),
        Paint()
          ..color      = c.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // bar gradient
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, barH),
          const Radius.circular(7),
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: highlighted
                ? [c, c.withOpacity(0.65)]
                : [c.withOpacity(0.85), c.withOpacity(0.55)],
          ).createShader(Rect.fromLTWH(x, y, barW, barH)),
      );

      // value on top
      final valStr = unit == '%'
          ? '${values[i].toInt()}%'
          : unit.isEmpty
              ? '${values[i].toInt()}'
              : '${values[i].toInt()}';
      _paintText(canvas,
          text:    valStr,
          style:   TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: c),
          centerX: x + barW / 2,
          y:       y - 14);

      // x-axis label
      _paintText(canvas,
          text:    labels[i].length > 8 ? '${labels[i].substring(0, 7)}..' : labels[i],
          style:   const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          centerX: x + barW / 2,
          y:       topPad + chartH + 8);
    }
  }

  void _paintText(
    Canvas canvas, {
    required String    text,
    required TextStyle style,
    double? x,
    double? centerX,
    required double y,
    double? maxW,
  }) {
    final tp = TextPainter(
      text:      TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines:  1,
    )..layout(maxWidth: maxW ?? double.infinity);

    final dx = centerX != null
        ? centerX - tp.width / 2
        : (x ?? 0);
    tp.paint(canvas, Offset(dx, y));
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.values.toString() != values.toString() || old.maxVal != maxVal;
}
