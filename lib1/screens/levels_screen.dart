// =========================================================================
// 📚 LEVELS SCREEN - PRACTICE LEVEL SELECTION
// =========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:typingtutor/models/practice_level.dart';
import 'package:typingtutor/controllers/levels_controller.dart';
import 'package:typingtutor/controllers/keyboard_controller.dart';
import 'package:typingtutor/data/keyboard_layouts_data.dart';

class LevelsScreen extends StatefulWidget {
  final PracticeType practiceType;

  const LevelsScreen({Key? key, required this.practiceType}) : super(key: key);

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen>
    with TickerProviderStateMixin {
  late LevelsController _levelsController;
  late KeyboardController _keyboardController;
  late AnimationController _animationController;
  late List<AnimationController> _cardAnimationControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    // Initialize GetX controllers
    if (!Get.isRegistered<LevelsController>()) {
      Get.put(LevelsController());
    }
    if (!Get.isRegistered<KeyboardController>()) {
      Get.put(KeyboardController());
    }

    _levelsController = Get.find<LevelsController>();
    _keyboardController = Get.find<KeyboardController>();

    // Set practice type
    _levelsController.setPracticeType(widget.practiceType);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppDurations.dashboardIntro,
      vsync: this,
    );

    final levels = _levelsController.getLevelsByType(widget.practiceType);
    _cardAnimationControllers = List.generate(
      levels.length,
      (index) => AnimationController(
        duration: Duration(
          milliseconds:
              AppDurations.cardAnimationBase.inMilliseconds +
              (index * AppDurations.cardAnimationStagger.inMilliseconds),
        ),
        vsync: this,
      ),
    );

    _animationController.forward();
    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      Future.delayed(
        Duration(
          milliseconds: i * AppDurations.cardStaggerDelay.inMilliseconds,
        ),
        () {
          if (mounted) _cardAnimationControllers[i].forward();
        },
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_getTypeColor(), _getTypeColor().withOpacity(0.8)],
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppTheme.textLightColor),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Icon(_getTypeIcon(), color: AppTheme.textLightColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.practiceType.displayName} Practice',
                  style: TextStyle(
                    color: AppTheme.textLightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Obx(
                  () => Text(
                    'Language: ${_keyboardController.currentLanguageInfo?.nativeName ?? 'English'}',
                    style: TextStyle(
                      color: AppTheme.textLightColor.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Language selector
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.language, color: AppTheme.textLightColor),
            tooltip: 'Change Language',
            onSelected: (String code) {
              _keyboardController.changeLanguage(code);
              _levelsController.changeLanguage(code);
              setState(() {});
            },
            itemBuilder:
                (context) =>
                    LanguageInfo.supportedLanguages
                        .map(
                          (lang) => PopupMenuItem<String>(
                            value: lang.code,
                            child: Row(
                              children: [
                                Text(
                                  lang.flagEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lang.name),
                                    Text(
                                      lang.nativeName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
          ),
        ),
        // Stars counter
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_levelsController.totalStars}',
                  style: TextStyle(
                    color: AppTheme.textLightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 8),
          _buildProgressSection(),
          const SizedBox(height: 16),
          _buildLevelsGrid(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getTypeColor().withOpacity(0.1),
                    _getTypeColor().withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getTypeColor().withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getTypeColor().withOpacity(0.2),
                          _getTypeColor().withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.practiceType.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHeaderTitle(),
                          style: TextStyle(
                            color: _getTypeColor(),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getHeaderDescription(),
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Obx(() {
      final levels = _levelsController.getLevelsByType(widget.practiceType);
      final completedCount = levels.where((l) => l.isCompleted).length;
      final totalStars = levels.fold(0, (sum, l) => sum + l.starsEarned);
      final maxStars = levels.length * 3;
      final progress = levels.isEmpty ? 0.0 : completedCount / levels.length;

      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '$totalStars / $maxStars',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTypeColor(),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount of ${levels.length} levels completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildLevelsGrid() {
    return Obx(() {
      final levels = _levelsController.getLevelsByType(widget.practiceType);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Level',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                return _buildLevelCard(levels[index], index);
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLevelCard(PracticeLevel level, int index) {
    final isLocked = level.isLocked;
    final isCompleted = level.isCompleted;

    return AnimatedBuilder(
      animation:
          index < _cardAnimationControllers.length
              ? _cardAnimationControllers[index]
              : _animationController,
      builder: (context, child) {
        final animation =
            index < _cardAnimationControllers.length
                ? _cardAnimationControllers[index]
                : _animationController;

        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: GestureDetector(
              onTap:
                  isLocked
                      ? () {
                        HapticFeedback.lightImpact();
                        Get.snackbar(
                          'Level Locked',
                          'Complete the previous level to unlock!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange.withOpacity(0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      }
                      : () {
                        HapticFeedback.lightImpact();
                        _levelsController.selectLevel(level);
                        Get.toNamed(
                          AppRoutes.levelPractice,
                          arguments: {
                            'level': level,
                            'type': widget.practiceType,
                            'languageCode': _levelsController.currentLanguage,
                          },
                        );
                      },
              child: Container(
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isLocked
                            ? Colors.grey.shade300
                            : isCompleted
                            ? _getTypeColor()
                            : _getTypeColor().withOpacity(0.3),
                    width: isCompleted ? 2 : 1,
                  ),
                  boxShadow:
                      isLocked
                          ? []
                          : [
                            BoxShadow(
                              color: _getTypeColor().withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                ),
                child: Stack(
                  children: [
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level number
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isLocked
                                      ? Colors.grey.shade400
                                      : _getTypeColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Level ${level.id}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Difficulty badge
                          Row(
                            children: [
                              ...List.generate(
                                level.difficulty,
                                (i) => Icon(
                                  Icons.star,
                                  size: 12,
                                  color:
                                      isLocked
                                          ? Colors.grey.shade400
                                          : Colors.amber,
                                ),
                              ),
                              ...List.generate(
                                3 - level.difficulty,
                                (i) => Icon(
                                  Icons.star_border,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Description
                          Expanded(
                            child: Text(
                              level.description,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isLocked
                                        ? Colors.grey.shade500
                                        : AppTheme.textSecondaryColor,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Stars earned
                          Row(
                            children: [
                              ...List.generate(
                                3,
                                (i) => Icon(
                                  i < level.starsEarned
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 18,
                                  color:
                                      i < level.starsEarned
                                          ? Colors.amber
                                          : Colors.grey.shade400,
                                ),
                              ),
                              const Spacer(),
                              if (level.bestWpm > 0)
                                Text(
                                  '${level.bestWpm} WPM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getTypeColor(),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Lock overlay
                    if (isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Completed checkmark
                    if (isCompleted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getTypeColor() {
    switch (widget.practiceType) {
      case PracticeType.word:
        return Colors.green;
      case PracticeType.sentence:
        return Colors.orange;
      case PracticeType.paragraph:
        return Colors.red;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.practiceType) {
      case PracticeType.word:
        return Icons.text_fields;
      case PracticeType.sentence:
        return Icons.short_text;
      case PracticeType.paragraph:
        return Icons.article;
    }
  }

  String _getHeaderTitle() {
    switch (widget.practiceType) {
      case PracticeType.word:
        return '📝 Word Practice';
      case PracticeType.sentence:
        return '📄 Sentence Practice';
      case PracticeType.paragraph:
        return '📖 Paragraph Practice';
    }
  }

  String _getHeaderDescription() {
    switch (widget.practiceType) {
      case PracticeType.word:
        return 'Practice individual words to build vocabulary and improve finger memory. Complete all levels to master word typing!';
      case PracticeType.sentence:
        return 'Practice complete sentences with proper punctuation and spacing. Improve your typing flow and accuracy!';
      case PracticeType.paragraph:
        return 'Master longer texts and develop sustained typing rhythm. Challenge yourself with paragraphs!';
    }
  }
}
