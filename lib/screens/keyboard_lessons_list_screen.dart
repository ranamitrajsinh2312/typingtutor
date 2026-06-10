// =========================================================================
// 📚 KEYBOARD LESSONS LIST SCREEN - SELECT LESSON FOR LANGUAGE
// =========================================================================

import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

class KeyboardLessonsListScreen extends StatefulWidget {
  final String languageCode;

  const KeyboardLessonsListScreen({super.key, required this.languageCode});

  @override
  State<KeyboardLessonsListScreen> createState() =>
      _KeyboardLessonsListScreenState();
}

class _KeyboardLessonsListScreenState extends State<KeyboardLessonsListScreen>
    with TickerProviderStateMixin {
  late List<KeyboardLesson> _lessons;
  late AnimationController _animationController;
  late List<AnimationController> _cardAnimationControllers;

  Map<int, Map<String, dynamic>> _progressMap = {};
  int _totalStars = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _setupAnimations();
    _loadProgress();
  }

  void _loadLessons() {
    _lessons = KeyboardLessonsData.getLessonsForLanguage(widget.languageCode);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppDurations.dashboardIntro,
      vsync: this,
    );

    _cardAnimationControllers = List.generate(
      _lessons.length,
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

  Future<void> _loadProgress() async {
    try {
      final progressList = await DatabaseHelper.instance
          .getAllKeyboardLessonProgress(widget.languageCode);
      setState(() {
        _progressMap = {for (var p in progressList) p['lessonId'] as int: p};
        _totalStars = progressList.fold(
          0,
          (sum, p) => sum + (p['starsEarned'] as int? ?? 0),
        );
        _completedCount =
            progressList.where((p) => (p['isCompleted'] as int) == 1).length;
      });
    } catch (e) {
      debugPrint('Error loading progress: $e');
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

  bool _isLessonUnlocked(KeyboardLesson lesson, int index) {
    if (index == 0) return true; // First lesson always unlocked

    // Check if previous lesson is completed
    final previousLesson = _lessons[index - 1];
    final previousProgress = _progressMap[previousLesson.id];
    if (previousProgress != null &&
        (previousProgress['isCompleted'] as int) == 1) {
      return true;
    }
    return false;
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.beginnerPerformance;
      case 2:
        return AppColors.averagePerformance;
      case 3:
        return AppColors.expertPerformance;
      default:
        return AppColors.beginnerPerformance;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Beginner';
    }
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
            colors: [
              AppTheme.accentColor,
              AppTheme.accentColor.withOpacity(0.8),
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      title: Row(
        children: [
          Text(
            KeyboardLessonsData.getLanguageFlag(widget.languageCode),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${KeyboardLessonsData.getLanguageDisplayName(widget.languageCode)} Lessons',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$_completedCount/${_lessons.length} completed • $_totalStars ⭐',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          _buildLessonsGrid(),
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
                    AppTheme.primaryLightColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryLightColor.withOpacity(0.3),
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
                          AppTheme.primaryColor.withOpacity(0.2),
                          AppTheme.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.keyboard_alt,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⌨️ Keyboard Lessons',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Master the ${KeyboardLessonsData.getLanguageDisplayName(widget.languageCode)} keyboard layout with structured lessons.',
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
    final progress = _completedCount / _lessons.length;

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
                        'Your Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$_totalStars / ${_lessons.length * 3}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
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
                        AppTheme.primaryColor,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}% completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimaryColor.withOpacity(0.6),
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

  Widget _buildLessonsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lessons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lessons.length,
            itemBuilder: (context, index) {
              final lesson = _lessons[index];
              final isUnlocked = _isLessonUnlocked(lesson, index);
              final progress = _progressMap[lesson.id];
              final stars = progress?['starsEarned'] as int? ?? 0;
              final isCompleted = (progress?['isCompleted'] as int? ?? 0) == 1;

              return AnimatedBuilder(
                animation: _cardAnimationControllers[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardAnimationControllers[index].value,
                    child: Opacity(
                      opacity: _cardAnimationControllers[index].value,
                      child: _buildLessonCard(
                        lesson,
                        index,
                        isUnlocked,
                        isCompleted,
                        stars,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(
    KeyboardLesson lesson,
    int index,
    bool isUnlocked,
    bool isCompleted,
    int stars,
  ) {
    final difficultyColor = _getDifficultyColor(lesson.difficulty);

    return GestureDetector(
      onTap:
          isUnlocked
              ? () async {
                await Get.to(
                  () => KeyboardLessonScreen(
                    lesson: lesson,
                    languageCode: widget.languageCode,
                  ),
                );
                // Reload progress after returning
                _loadProgress();
              }
              : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Complete the previous lesson to unlock this one!',
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isCompleted
                    ? Colors.green.withOpacity(0.5)
                    : isUnlocked
                    ? difficultyColor.withOpacity(0.3)
                    : Colors.grey.shade300,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow:
              isUnlocked
                  ? [
                    BoxShadow(
                      color: difficultyColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Lesson number or lock icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isUnlocked
                        ? difficultyColor.withOpacity(0.15)
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    isUnlocked
                        ? Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: difficultyColor,
                          ),
                        )
                        : Icon(
                          Icons.lock,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
              ),
            ),
            const SizedBox(width: 16),
            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isUnlocked
                                    ? AppTheme.textPrimaryColor
                                    : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      // Stars
                      if (isCompleted)
                        Row(
                          children: List.generate(3, (i) {
                            return Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 18,
                            );
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.description,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isUnlocked
                              ? AppTheme.textPrimaryColor.withOpacity(0.7)
                              : Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getDifficultyText(lesson.difficulty),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: difficultyColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard,
                        size: 14,
                        color:
                            isUnlocked
                                ? AppTheme.textPrimaryColor.withOpacity(0.5)
                                : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lesson.lessonType.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isUnlocked
                                  ? AppTheme.textPrimaryColor.withOpacity(0.5)
                                  : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow indicator
            if (isUnlocked)
              Icon(Icons.chevron_right, color: difficultyColor, size: 24),
          ],
        ),
      ),
    );
  }
}
