// =========================================================================
// 📚 LEVELS SCREEN — Practice Level Selection, Responsive Grid
// =========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/constants/practice_content.dart'
    show PracticeDifficulty;
import 'package:typingtutor/models/practice_level.dart';
import 'package:typingtutor/controllers/levels_controller.dart';
import 'package:typingtutor/controllers/keyboard_controller.dart';
import 'package:typingtutor/data/keyboard_layouts_data.dart';

class LevelsScreen extends StatefulWidget {
  final PracticeType practiceType;
  final String initialLanguageCode;

  const LevelsScreen({
    Key? key,
    required this.practiceType,
    this.initialLanguageCode = 'en',
  }) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen>
    with TickerProviderStateMixin {
  late LevelsController _levelsCtrl;
  late KeyboardController _keyboardCtrl;
  late AnimationController _headerCtrl;
  late List<AnimationController> _cardCtrls;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setupAnimations();
  }

  void _initControllers() {
    if (!Get.isRegistered<LevelsController>()) Get.put(LevelsController());
    if (!Get.isRegistered<KeyboardController>()) Get.put(KeyboardController());
    _levelsCtrl = Get.find<LevelsController>();
    _keyboardCtrl = Get.find<KeyboardController>();
    if (widget.initialLanguageCode != _levelsCtrl.currentLanguage)
      _levelsCtrl.changeLanguage(widget.initialLanguageCode);
    _levelsCtrl.setPracticeType(widget.practiceType);
  }

  void _setupAnimations() {
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final levels = _levelsCtrl.getLevelsByType(widget.practiceType);
    _cardCtrls = List.generate(
      levels.length,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 280 + i * 40),
      ),
    );
    _headerCtrl.forward();
    for (int i = 0; i < _cardCtrls.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 40), () {
        if (mounted) _cardCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    for (final c in _cardCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(size, isWide),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final color = _typeColor();
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.75)],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Icon(_typeIcon(), color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.practiceType.displayName} Practice',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Obx(
                  () => Text(
                    _keyboardCtrl.currentLanguageInfo?.nativeName ?? 'English',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Language switcher
        Obx(() {
          final langs = _keyboardCtrl.availableLanguages;
          final current = _levelsCtrl.currentLanguage;
          return Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: current,
                isDense: true,
                dropdownColor: color,
                icon: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                items:
                    langs
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.code,
                            child: Text(
                              l.nativeName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) {
                    HapticFeedback.selectionClick();
                    _levelsCtrl.changeLanguage(v);
                    _keyboardCtrl.changeLanguage(v);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBody(Size size, bool isWide) {
    return Obx(() {
      final levels = _levelsCtrl.getLevelsByType(widget.practiceType);
      if (_levelsCtrl.isLoading) {
        return Center(child: CircularProgressIndicator(color: _typeColor()));
      }
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(size, isWide, levels)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver:
                isWide
                    ? SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) =>
                            i < levels.length
                                ? _buildLevelCard(levels[i], i, isWide)
                                : null,
                        childCount: levels.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: size.width > 900 ? 3 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.35,
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) =>
                            i < levels.length
                                ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildLevelCard(levels[i], i, isWide),
                                )
                                : null,
                        childCount: levels.length,
                      ),
                    ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader(Size size, bool isWide, List<PracticeLevel> levels) {
    final color = _typeColor();
    final done = levels.where((l) => l.isCompleted).length;
    final total = levels.length;
    return AnimatedBuilder(
      animation: _headerCtrl,
      builder:
          (_, __) => Opacity(
            opacity: _headerCtrl.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.all(isWide ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_typeIcon(), color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _typeSubtitle(),
                          style: GoogleFonts.poppins(
                            fontSize: isWide ? 14 : 12,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '$done / $total completed',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : done / total,
                                backgroundColor: color.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(color),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLevelCard(PracticeLevel level, int index, bool isWide) {
    final color = _typeColor();
    final isLocked = level.isLocked;
    final isDone = level.isCompleted;
    final ctrl = index < _cardCtrls.length ? _cardCtrls[index] : null;

    Widget card = GestureDetector(
      onTap:
          isLocked
              ? null
              : () {
                HapticFeedback.lightImpact();
                Get.toNamed(
                  AppRoutes.levelPractice,
                  arguments: {
                    'level': level,
                    'type': widget.practiceType,
                    'languageCode': _levelsCtrl.currentLanguage,
                  },
                );
              },
      child: AnimatedOpacity(
        opacity: isLocked ? 0.55 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(
              color:
                  isDone
                      ? color.withOpacity(0.4)
                      : (isLocked
                          ? Colors.grey.shade200
                          : color.withOpacity(0.15)),
              width: isDone ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top accent stripe
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isLocked
                              ? [Colors.grey.shade300, Colors.grey.shade200]
                              : isDone
                              ? [color, color.withOpacity(0.6)]
                              : [
                                color.withOpacity(0.5),
                                color.withOpacity(0.2),
                              ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isWide ? 14 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Level number badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  isLocked
                                      ? Colors.grey.shade100
                                      : color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    isLocked
                                        ? Colors.grey.shade200
                                        : color.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${level.id}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isLocked ? Colors.grey : color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        isLocked
                                            ? Colors.grey
                                            : const Color(0xFF1A237E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _diffLabel(
                                    PracticeDifficulty
                                        .values[(level.difficulty - 1).clamp(
                                      0,
                                      2,
                                    )],
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _diffColor(
                                      PracticeDifficulty
                                          .values[(level.difficulty - 1).clamp(
                                        0,
                                        2,
                                      )],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isDone)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: color,
                                size: 14,
                              ),
                            )
                          else if (isLocked)
                            const Icon(
                              Icons.lock_rounded,
                              color: Colors.grey,
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        level.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Stars
                      Row(
                        children: List.generate(
                          3,
                          (i) => Icon(
                            i < (level.starsEarned)
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color:
                                i < (level.starsEarned)
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ctrl != null) {
      return AnimatedBuilder(
        animation: ctrl,
        builder:
            (_, c) => Transform.translate(
              offset: Offset(0, 20 * (1 - ctrl.value)),
              child: Opacity(opacity: ctrl.value, child: card),
            ),
      );
    }
    return card;
  }

  Color _typeColor() {
    switch (widget.practiceType) {
      case PracticeType.sentence:
        return const Color(0xFFF57C00);
      case PracticeType.paragraph:
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF43A047);
    }
  }

  IconData _typeIcon() {
    switch (widget.practiceType) {
      case PracticeType.sentence:
        return Icons.short_text_rounded;
      case PracticeType.paragraph:
        return Icons.article_rounded;
      default:
        return Icons.text_fields_rounded;
    }
  }

  String _typeSubtitle() {
    switch (widget.practiceType) {
      case PracticeType.sentence:
        return 'Type complete sentences to build natural rhythm and flow.';
      case PracticeType.paragraph:
        return 'Master long-form typing for real-world speed and endurance.';
      default:
        return 'Practice individual words to build accuracy and muscle memory.';
    }
  }

  Color _diffColor(PracticeDifficulty d) {
    switch (d) {
      case PracticeDifficulty.medium:
        return const Color(0xFFF57C00);
      case PracticeDifficulty.hard:
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF43A047);
    }
  }

  String _diffLabel(PracticeDifficulty d) {
    switch (d) {
      case PracticeDifficulty.medium:
        return 'Intermediate';
      case PracticeDifficulty.hard:
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }
}
