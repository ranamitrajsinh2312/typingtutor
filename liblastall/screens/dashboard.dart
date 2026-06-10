import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  List<String> imageList = AppConstants.keyboardImages;

  List<String> lang = AppConstants.typingLevels;

  List<String> descriptions = AppConstants.levelDescriptions;

  // Selected language for keyboard lessons
  String _selectedLanguage = 'en';

  // Selected language for Practice Modes (Word/Sentence/Paragraph)
  String _selectedPracticeLanguage = 'en';

  // Language options for dropdown
  final List<Map<String, String>> _languageOptions = [
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English', 'layout': 'QWERTY'},
    {'code': 'hi', 'flag': '🇮🇳', 'name': 'हिंदी', 'layout': 'Inscript'},
    {'code': 'gu', 'flag': '🇮🇳', 'name': 'ગુજરાતી', 'layout': 'Inscript'},
  ];

  late AnimationController _animationController;
  late List<AnimationController> _cardAnimationControllers;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.dashboardIntro,
      vsync: this,
    );

    _cardAnimationControllers = List.generate(
      lang.length,
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

  //    Widget Tree Starts From here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: _buildDashboardBody(),
    );
  }

  // DashBoard Function Includes all body functions

  Widget _buildDashboardBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 8),
          _buildStatsSection(),
          const SizedBox(height: 12),
          _buildKeyboardLessonsSection(),
          const SizedBox(height: 12),
          _buildPracticeModesSection(),
        ],
      ),
    );
  }

  ////

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
      actions: [
        // Profile Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.profile);
            },
            icon: Icon(
              Icons.person_outline,
              color: AppTheme.textLightColor,
              size: 22,
            ),
            tooltip: AppText.profile,
          ),
        ),
        // Developer Button
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(
                () => DeveloperScreen(
                  developerName: AppConstants.developerName,
                  mentorName: AppConstants.mentorName,
                  exploredByName: AppConstants.instituteName,
                  isAdmissionApp: false,
                  shareMessage: AppConstants.shareMessage,
                  appTitle: AppConfig.appName,
                  appLogo: AppAssets.appLogo,
                ),
              );
            },
            icon: Icon(
              Icons.info_outline,
              color: AppTheme.textLightColor,
              size: 22,
            ),
            tooltip: AppText.aboutDeveloper,
          ),
        ),
      ],
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.keyboard_alt_outlined,
              color: AppTheme.textLightColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.appTitle,
                  style: TextStyle(
                    color: AppTheme.textLightColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  AppText.chooseYourLevel,
                  style: TextStyle(
                    color: AppTheme.textLightColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
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
                      Icons.lightbulb_outline,
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
                          '🚀 Getting Started',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select a keyboard row to practice your typing skills. Start with Home Row for beginners and work your way up!',
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

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    '9',
                    'Levels',
                    Icons.layers_outlined,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '3',
                    'Difficulties',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard('∞', 'Practice', Icons.refresh, Colors.green),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimaryColor.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int index) {
    if (index == 0 || index == 8) {
      return AppColors.beginnerPerformance; // Green for beginner
    } else if (index == 1 || index == 2 || index == 7) {
      return AppColors.averagePerformance; // Orange for intermediate
    } else {
      return AppColors.expertPerformance; // Purple for advanced
    }
  }

  String _getDifficultyText(int index) {
    if (index == 0 || index == 8) {
      return 'Beginner';
    } else if (index == 1 || index == 2 || index == 7) {
      return 'Intermediate';
    } else {
      return 'Advanced';
    }
  }

  IconData _getDifficultyIcon(int index) {
    if (index == 0 || index == 8) {
      return Icons.star_border;
    } else if (index == 1 || index == 2 || index == 7) {
      return Icons.star_half;
    } else {
      return Icons.star;
    }
  }

  Widget _buildKeyboardLessonsSection() {
    final selectedLang = _languageOptions.firstWhere(
      (l) => l['code'] == _selectedLanguage,
      orElse: () => _languageOptions[0],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_alt,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppText.keyboardLessons,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                // Language dropdown
                _buildLanguageDropdown(selectedLang),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppText.keyboardLessonsSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimaryColor.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Keyboard layout lessons (horizontal scroll)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: lang.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _cardAnimationControllers[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _cardAnimationControllers[index].value,
                      child: Opacity(
                        opacity: _cardAnimationControllers[index].value,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: const EdgeInsets.only(right: 16),
                          child: _buildHorizontalTypingCard(index),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(Map<String, String> selectedLang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          items:
              _languageOptions.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        lang['name']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedLanguage = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalTypingCard(int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageHeight =
        screenWidth < 600 ? screenHeight * 0.15 : screenHeight * 0.18;
    final cardPadding = screenWidth < 600 ? 12.0 : 16.0;
    final iconSize = screenWidth < 600 ? 40.0 : 48.0;

    final difficultyColor = _getDifficultyColor(index);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Pass both lesson name and language code
        Get.toNamed(
          AppRoutes.level1,
          arguments: {'lesson': lang[index], 'languageCode': _selectedLanguage},
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryLightColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: difficultyColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section (top)
              Container(
                height: imageHeight,
                margin: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: difficultyColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imageList[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.keyboard_alt,
                          color: difficultyColor,
                          size: iconSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Content (bottom)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    cardPadding,
                    0,
                    cardPadding,
                    cardPadding,
                  ),
                  child: _buildCardContent(index, screenWidth, difficultyColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    int index,
    double screenWidth,
    Color difficultyColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Difficulty badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 600 ? 8 : 12,
                    vertical: screenWidth < 600 ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getDifficultyIcon(index),
                        color: Colors.white,
                        size: screenWidth < 600 ? 10 : 10,
                      ),
                      SizedBox(width: screenWidth < 600 ? 3 : 4),
                      Flexible(
                        child: Text(
                          _getDifficultyText(index),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth < 600 ? 8 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenWidth < 600 ? 8 : 12),

                // Title
                Text(
                  lang[index],
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: screenWidth < 600 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: screenWidth < 600 ? 6 : 8),

                // Description
                Flexible(
                  child: Text(
                    descriptions[index],
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor.withOpacity(0.7),
                      fontSize: screenWidth < 600 ? 12 : 14,
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: screenWidth < 600 ? 10 : 14),

                // Action button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth < 600 ? 10 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: difficultyColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: difficultyColor,
                        size: screenWidth < 600 ? 18 : 20,
                      ),
                      SizedBox(width: screenWidth < 600 ? 6 : 8),
                      Flexible(
                        child: Text(
                          AppText.startPractice,
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: screenWidth < 600 ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPracticeModesSection() {
    final selectedPracticeLang = _languageOptions.firstWhere(
      (l) => l['code'] == _selectedPracticeLanguage,
      orElse: () => _languageOptions[0],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.school, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppText.practiceModes,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
                // Language selector for Practice Modes
                _buildPracticeLanguageDropdown(selectedPracticeLang),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppText.practiceModesSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimaryColor.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLargePracticeCard(
            AppText.wordPractice,
            AppText.wordPracticeDesc,
            Icons.text_fields,
            Colors.green,
            'word',
            'easy',
          ),
          const SizedBox(height: 16),
          _buildLargePracticeCard(
            AppText.sentencePractice,
            AppText.sentencePracticeDesc,
            Icons.short_text,
            Colors.orange,
            'sentence',
            'medium',
          ),
          const SizedBox(height: 16),
          _buildLargePracticeCard(
            AppText.paragraphPractice,
            AppText.paragraphPracticeDesc,
            Icons.article,
            Colors.red,
            'paragraph',
            'hard',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPracticeLanguageDropdown(Map<String, String> selectedLang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPracticeLanguage,
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          items: _languageOptions.map((lang) {
            return DropdownMenuItem<String>(
              value: lang['code'],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedPracticeLanguage = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildLargePracticeCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String lessonType,
    String difficulty,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    final cardPadding = screenWidth < 600 ? 16.0 : 20.0;
    final iconSize = screenWidth < 600 ? 24.0 : 28.0;
    final titleFontSize = screenWidth < 600 ? 16.0 : 18.0;
    final descriptionFontSize = screenWidth < 600 ? 12.0 : 14.0;
    final arrowIconSize = screenWidth < 600 ? 16.0 : 18.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth < 600 ? 12.0 : 16.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to levels screen based on lesson type, passing language
            String route;
            switch (lessonType) {
              case 'word':
                route = AppRoutes.wordLevels;
                break;
              case 'sentence':
                route = AppRoutes.sentenceLevels;
                break;
              case 'paragraph':
                route = AppRoutes.paragraphLevels;
                break;
              default:
                route = AppRoutes.wordLevels;
            }
            Get.toNamed(route, arguments: {'languageCode': _selectedPracticeLanguage});
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: iconSize),
                ),
                SizedBox(width: screenWidth < 600 ? 16 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      SizedBox(height: screenWidth < 600 ? 6 : 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: AppTheme.textPrimaryColor.withOpacity(0.7),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(screenWidth < 600 ? 10 : 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: color,
                    size: arrowIconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    String languageCode,
    String flag,
    String languageName,
    String layoutType,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600 ? 150.0 : 170.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Get.toNamed(AppRoutes.keyboardLessons, arguments: languageCode);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flag emoji
                Text(flag, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                // Language name
                Text(
                  languageName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Layout type
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    layoutType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Start button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline, color: color, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
