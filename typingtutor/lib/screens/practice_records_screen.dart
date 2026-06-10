// =========================================================================
// 📊 PRACTICE RECORDS SCREEN — Beautiful History & Stats
// =========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';

class PracticeRecordsScreen extends StatefulWidget {
  const PracticeRecordsScreen({Key? key}) : super(key: key);
  @override
  State<PracticeRecordsScreen> createState() => _PracticeRecordsScreenState();
}

class _PracticeRecordsScreenState extends State<PracticeRecordsScreen>
    with SingleTickerProviderStateMixin {
  List<TypingRecord> _records = [];
  TypingStats?       _stats;
  bool               _loading = true;
  late TabController _tabCtrl;
  String             _filterLang = 'all';

  static const _langs = [
    {'code': 'all', 'flag': '🌐', 'name': 'All'},
    {'code': 'en',  'flag': '🇺🇸', 'name': 'English'},
    {'code': 'hi',  'flag': '🇮🇳', 'name': 'Hindi'},
    {'code': 'gu',  'flag': '🇮🇳', 'name': 'Gujarati'},
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final db = DatabaseHelper.instance;
      final s  = await db.getStats();
      final r  = await db.fetchAllRecords();
      if (mounted) setState(() { _stats = s; _records = r; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TypingRecord> get _filtered => _filterLang == 'all'
      ? _records
      : _records.where((r) => (r.languageCode) == _filterLang).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : TabBarView(controller: _tabCtrl, children: [
              _buildRecordsTab(),
              _buildStatsTab(MediaQuery.of(context).size.width > 600),
            ]),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTheme.heroGradient)),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
      onPressed: () => Get.back()),
    title: Text('Records & Stats', style: GoogleFonts.poppins(
      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
    actions: [
      IconButton(
        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70, size: 22),
        onPressed: _confirmClear),
    ],
    bottom: TabBar(
      controller: _tabCtrl,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicatorColor: const Color(0xFF00E5FF),
      indicatorWeight: 3,
      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
      tabs: const [Tab(text: 'Records'), Tab(text: 'Statistics')],
    ),
  );

  // ── Records Tab ───────────────────────────────────────────────────────────

  Widget _buildRecordsTab() => Column(children: [
    _buildFilterRow(),
    Expanded(child: _filtered.isEmpty
        ? _emptyState() : _buildList()),
  ]);

  Widget _buildFilterRow() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
    child: SingleChildScrollView(scrollDirection: Axis.horizontal,
      child: Row(children: _langs.map((l) {
        final sel = _filterLang == l['code'];
        return GestureDetector(
          onTap: () => setState(() => _filterLang = l['code']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? AppTheme.primaryColor : Colors.grey.shade200),
              boxShadow: sel ? AppTheme.cardShadow : null,
            ),
            child: Row(children: [
              Text(l['flag']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(l['name']!, style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: sel ? Colors.white : Colors.black54)),
            ]),
          ),
        );
      }).toList()),
    ),
  );

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    itemCount: _filtered.length,
    itemBuilder: (_, i) => _buildRecordCard(_filtered[i], i),
  );

  Widget _buildRecordCard(TypingRecord r, int index) {
    final wpm  = r.wpm;
    final acc  = r.accuracy;
    final lang = _langs.firstWhere((l) => l['code'] == (r.languageCode),
        orElse: () => {'code': 'en', 'flag': '🌐', 'name': 'Unknown'});
    final wpmColor = wpm >= 60 ? const Color(0xFF43A047)
        : (wpm >= 30 ? const Color(0xFFF57C00) : const Color(0xFFE53935));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: wpmColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: wpmColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text('${index + 1}',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: wpmColor)))),
        const SizedBox(width: 12),
        Expanded(child: Row(children: [
          Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.username, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A237E))),
            Text(lang['name']!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
          ])),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _chip('$wpm WPM', wpmColor),
          const SizedBox(height: 4),
          _chip('${acc.toInt()}%', acc >= 90 ? const Color(0xFF43A047)
              : (acc >= 70 ? const Color(0xFFF57C00) : const Color(0xFFE53935))),
        ]),
      ]),
    );
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor.withOpacity(0.3), size: 64),
    const SizedBox(height: 16),
    Text('No records yet', style: GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black38)),
    Text('Complete sessions to see records here', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black26)),
  ]));

  // ── Stats Tab ─────────────────────────────────────────────────────────────

  Widget _buildStatsTab(bool isWide) {
    if (_stats == null || _records.isEmpty) return _emptyState();
    final s = _stats!;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      _buildTopStats(s, isWide),
      const SizedBox(height: 20),
      _buildWpmBars(isWide),
    ]));
  }

  Widget _buildTopStats(TypingStats s, bool isWide) {
    final items = [
      _SI('Total Sessions', '${s.totalAttempts}',               Icons.repeat_rounded,         const Color(0xFF1E88E5)),
      _SI('Best WPM',       '${s.bestWpm}',                      Icons.military_tech_rounded,  Colors.amber),
      _SI('Avg WPM',        '${s.avgWpm.toDouble().toInt()}',           Icons.speed_rounded,          const Color(0xFF43A047)),
      _SI('Avg Accuracy',   '${s.avgAccuracy.toInt()}%',     Icons.gps_fixed_rounded,      const Color(0xFF00BCD4)),
    ];
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: isWide ? 2.0 : 1.6,
      children: items.map((s) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: s.color.withOpacity(0.15)),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: s.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(s.icon, color: s.color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(s.value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w900, color: s.color)),
            Text(s.label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
          ])),
        ]),
      )).toList(),
    );
  }

  Widget _buildWpmBars(bool isWide) {
    if (_records.isEmpty) return const SizedBox.shrink();
    final recent = _records.take(10).toList().reversed.toList();
    final maxWpm = recent.map((r) => r.wpm).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recent WPM Trend', style: GoogleFonts.poppins(
          fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF1A237E))),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: recent.asMap().entries.map((e) {
              final i     = e.key;
              final r     = e.value;
              final frac  = maxWpm == 0 ? 0.0 : r.wpm / maxWpm;
              final color = r.wpm >= 60 ? const Color(0xFF43A047)
                  : (r.wpm >= 30 ? const Color(0xFFF57C00) : const Color(0xFFE53935));
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${r.wpm}', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + i * 50),
                    height: 120 * frac.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [color.withOpacity(0.9), color]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ]),
              ));
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text('Last ${recent.length} sessions', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38)),
      ]),
    );
  }

  void _confirmClear() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Clear All Records?', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: const Color(0xFFE53935))),
      content: Text('This action cannot be undone.', style: GoogleFonts.poppins(color: Colors.black54)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
          onPressed: () async {
            Navigator.pop(context);
            await DatabaseHelper.instance.resetData();
            await _load();
          },
          child: Text('Clear', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }
}

class _SI { // Stat Item
  final String label, value; final IconData icon; final Color color;
  const _SI(this.label, this.value, this.icon, this.color);
}
