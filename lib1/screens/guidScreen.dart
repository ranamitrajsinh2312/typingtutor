import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

class Lesson {
  final String type;
  final String content;
  final String difficulty;
  final String languageCode;

  const Lesson({
    required this.type,
    required this.content,
    required this.difficulty,
    this.languageCode = 'en',
  });
}

final List<Lesson> lessons = [
  // ==========================================================================
  // ENGLISH LESSONS
  // ==========================================================================
  // Word Lessons
  Lesson(type: 'word', content: 'cat', difficulty: 'easy', languageCode: 'en'),
  Lesson(type: 'word', content: 'dog', difficulty: 'easy', languageCode: 'en'),
  Lesson(type: 'word', content: 'tree', difficulty: 'easy', languageCode: 'en'),
  Lesson(
    type: 'word',
    content: 'house',
    difficulty: 'easy',
    languageCode: 'en',
  ),
  Lesson(
    type: 'word',
    content: 'programming',
    difficulty: 'medium',
    languageCode: 'en',
  ),
  Lesson(
    type: 'word',
    content: 'keyboard',
    difficulty: 'medium',
    languageCode: 'en',
  ),
  Lesson(
    type: 'word',
    content: 'algorithm',
    difficulty: 'hard',
    languageCode: 'en',
  ),
  Lesson(
    type: 'word',
    content: 'synchronization',
    difficulty: 'hard',
    languageCode: 'en',
  ),
  // Sentence Lessons
  Lesson(
    type: 'sentence',
    content: 'The cat runs fast.',
    difficulty: 'easy',
    languageCode: 'en',
  ),
  Lesson(
    type: 'sentence',
    content: 'A dog barks loudly.',
    difficulty: 'easy',
    languageCode: 'en',
  ),
  Lesson(
    type: 'sentence',
    content: 'Quick foxes climb steep hills.',
    difficulty: 'medium',
    languageCode: 'en',
  ),
  Lesson(
    type: 'sentence',
    content: 'The programmer types code daily.',
    difficulty: 'medium',
    languageCode: 'en',
  ),
  Lesson(
    type: 'sentence',
    content: 'Complex algorithms require careful planning.',
    difficulty: 'hard',
    languageCode: 'en',
  ),
  Lesson(
    type: 'sentence',
    content: 'Synchronization issues can cause errors.',
    difficulty: 'hard',
    languageCode: 'en',
  ),
  // Paragraph Lessons
  Lesson(
    type: 'paragraph',
    content:
        'The quick brown fox jumps over the lazy dog. This is a classic typing test used to practice all letters.',
    difficulty: 'easy',
    languageCode: 'en',
  ),
  Lesson(
    type: 'paragraph',
    content:
        'Typing improves with consistent practice. Focus on accuracy before speed. Take breaks to avoid fatigue.',
    difficulty: 'medium',
    languageCode: 'en',
  ),
  Lesson(
    type: 'paragraph',
    content:
        'Developing software requires attention to detail. Programmers must balance efficiency with readability. Complex systems demand robust testing.',
    difficulty: 'hard',
    languageCode: 'en',
  ),

  // ==========================================================================
  // HINDI (हिंदी) LESSONS
  // ==========================================================================
  // Word Lessons
  Lesson(type: 'word', content: 'कर', difficulty: 'easy', languageCode: 'hi'),
  Lesson(type: 'word', content: 'पर', difficulty: 'easy', languageCode: 'hi'),
  Lesson(type: 'word', content: 'जल', difficulty: 'easy', languageCode: 'hi'),
  Lesson(type: 'word', content: 'घर', difficulty: 'easy', languageCode: 'hi'),
  Lesson(
    type: 'word',
    content: 'किताब',
    difficulty: 'medium',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'word',
    content: 'कंप्यूटर',
    difficulty: 'medium',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'word',
    content: 'अनुप्रयोग',
    difficulty: 'hard',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'word',
    content: 'विश्वविद्यालय',
    difficulty: 'hard',
    languageCode: 'hi',
  ),
  // Sentence Lessons
  Lesson(
    type: 'sentence',
    content: 'मेरा नाम राम है।',
    difficulty: 'easy',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'sentence',
    content: 'आज मौसम अच्छा है।',
    difficulty: 'easy',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'sentence',
    content: 'भारत एक विशाल देश है।',
    difficulty: 'medium',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'sentence',
    content: 'गंगा हमारी पवित्र नदी है।',
    difficulty: 'medium',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'sentence',
    content: 'हिंदी हमारी राष्ट्रभाषा है।',
    difficulty: 'hard',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'sentence',
    content: 'प्रौद्योगिकी विकास महत्वपूर्ण है।',
    difficulty: 'hard',
    languageCode: 'hi',
  ),
  // Paragraph Lessons
  Lesson(
    type: 'paragraph',
    content:
        'भारत एक महान देश है। यहाँ अनेक भाषाएँ बोली जाती हैं। हिंदी सबसे अधिक बोली जाने वाली भाषा है।',
    difficulty: 'easy',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'paragraph',
    content:
        'स्वस्थ शरीर में स्वस्थ मन निवास करता है। नियमित व्यायाम और संतुलित आहार स्वस्थ जीवन की कुंजी है।',
    difficulty: 'medium',
    languageCode: 'hi',
  ),
  Lesson(
    type: 'paragraph',
    content:
        'प्रौद्योगिकी विकास महत्वपूर्ण है। इससे रोजगार मिलता है और देश की अर्थव्यवस्था मजबूत होती है।',
    difficulty: 'hard',
    languageCode: 'hi',
  ),

  // ==========================================================================
  // GUJARATI (ગુજરાતી) LESSONS
  // ==========================================================================
  // Word Lessons
  Lesson(type: 'word', content: 'કર', difficulty: 'easy', languageCode: 'gu'),
  Lesson(type: 'word', content: 'પર', difficulty: 'easy', languageCode: 'gu'),
  Lesson(type: 'word', content: 'જળ', difficulty: 'easy', languageCode: 'gu'),
  Lesson(type: 'word', content: 'ઘર', difficulty: 'easy', languageCode: 'gu'),
  Lesson(
    type: 'word',
    content: 'પુસ્તક',
    difficulty: 'medium',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'word',
    content: 'કમ્પ્યુટર',
    difficulty: 'medium',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'word',
    content: 'ઉપયોગ',
    difficulty: 'hard',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'word',
    content: 'વિશ્વવિદ્યાલય',
    difficulty: 'hard',
    languageCode: 'gu',
  ),
  // Sentence Lessons
  Lesson(
    type: 'sentence',
    content: 'મારું નામ રામ છે।',
    difficulty: 'easy',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'sentence',
    content: 'આજે હવામાન સારું છે।',
    difficulty: 'easy',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'sentence',
    content: 'ગુજરાત એક સુંદર રાજ્ય છે।',
    difficulty: 'medium',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'sentence',
    content: 'સાબરમતી નદી ગુજરાતમાં વહે છે।',
    difficulty: 'medium',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'sentence',
    content: 'ગુજરાતી અમારી માતૃભાષા છે।',
    difficulty: 'hard',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'sentence',
    content: 'ઉદ્યોગ વિકાસ મહત્વપૂર્ણ છે।',
    difficulty: 'hard',
    languageCode: 'gu',
  ),
  // Paragraph Lessons
  Lesson(
    type: 'paragraph',
    content:
        'ગુજરાત એક સુંદર રાજ્ય છે। અહીં ઘણા લોકો ગુજરાતી બોલે છે। ગુજરાતી એક પ્રાચીન ભાષા છે।',
    difficulty: 'easy',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'paragraph',
    content:
        'તંદુરસ્ત શરીરમાં તંદુરસ્ત મન વસે છે। નિયમિત કસરત અને સંતુલિત આહાર તંદુરસ્ત જીવનની ચાવી છે।',
    difficulty: 'medium',
    languageCode: 'gu',
  ),
  Lesson(
    type: 'paragraph',
    content:
        'ઉદ્યોગ વિકાસ મહત્વપૂર્ણ છે। તેનાથી રોજગારી મળે છે અને દેશની અર્થવ્યવસ્થા મજબૂત થાય છે।',
    difficulty: 'hard',
    languageCode: 'gu',
  ),
];

class ScreenBreakpoints {
  static const double mobile = AppConstants.mobileBreakpoint;
  static const double tablet = AppConstants.tabletBreakpoint;
  static const double desktop = AppConstants.desktopBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

class GuideResponsiveHelper {
  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppConstants.mobileBreakpoint) {
      return const EdgeInsets.all(12);
    } else if (width < AppConstants.tabletBreakpoint) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppConstants.mobileBreakpoint) {
      return baseFontSize * 0.85;
    } else if (width < AppConstants.tabletBreakpoint) {
      return baseFontSize * 0.95;
    } else {
      return baseFontSize;
    }
  }

  static double getMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return screenWidth;
    } else if (screenWidth >= AppConstants.desktopBreakpoint) {
      return screenWidth * 0.85;
    } else if (screenWidth >= AppConstants.tabletBreakpoint) {
      return screenWidth * 0.92;
    } else {
      return screenWidth;
    }
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape && width >= AppConstants.tabletBreakpoint) {
      return 2;
    } else if (width >= AppConstants.tabletBreakpoint) {
      return 2;
    } else {
      return 1;
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (width < AppConstants.mobileBreakpoint) {
      return isLandscape ? 3.5 : 2.5;
    } else if (width < AppConstants.tabletBreakpoint) {
      return isLandscape ? 3.0 : 2.2;
    } else {
      return 2.0;
    }
  }
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = GuideResponsiveHelper.getPadding(context);
    final maxWidth = GuideResponsiveHelper.getMaxWidth(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: maxWidth,
          padding: padding,
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: GuideResponsiveHelper.getGridColumns(context),
                  crossAxisSpacing: padding.left * 0.75,
                  mainAxisSpacing: padding.left * 0.75,
                  childAspectRatio: GuideResponsiveHelper.getChildAspectRatio(
                    context,
                  ),
                  children: [
                    _buildPracticeCard(
                      context,
                      AppText.wordPractice,
                      AppText.wordPracticeDesc,
                      Icons.text_fields,
                      'word',
                      'easy',
                    ),
                    _buildPracticeCard(
                      context,
                      AppText.sentencePractice,
                      AppText.sentencePracticeDesc,
                      Icons.short_text,
                      'sentence',
                      'medium',
                    ),
                    _buildPracticeCard(
                      context,
                      AppText.paragraphPractice,
                      AppText.paragraphPracticeDesc,
                      Icons.article,
                      'paragraph',
                      'hard',
                    ),
                    _buildInfoCard(
                      context,
                      AppText.typingTips,
                      AppText.typingTipsList,
                      Icons.lightbulb_outline,
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

  Widget _buildPracticeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String lessonType,
    String difficulty,
  ) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = width < 600 ? 18.0 : (width < 900 ? 20.0 : 22.0);
    final containerSize = width < 600 ? 36.0 : (width < 900 ? 40.0 : 44.0);
    final arrowSize = width < 600 ? 12.0 : (width < 900 ? 14.0 : 16.0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.practice,
            arguments: {'lessonType': lessonType, 'difficulty': difficulty},
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: GuideResponsiveHelper.getPadding(context) * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFFD8469).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFD8469),
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: GuideResponsiveHelper.getFontSize(
                          context,
                          14,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: GuideResponsiveHelper.getFontSize(
                          context,
                          11,
                        ),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFFFD8469),
                size: arrowSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = width < 600 ? 18.0 : (width < 900 ? 20.0 : 22.0);
    final containerSize = width < 600 ? 36.0 : (width < 900 ? 40.0 : 44.0);

    return Container(
      padding: GuideResponsiveHelper.getPadding(context) * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: const Color(0xFFFD8469).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: const Color(0xFFFD8469), size: iconSize),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: GuideResponsiveHelper.getFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: GuideResponsiveHelper.getFontSize(context, 11),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

  // Using the implementation from line ~1018 instead of this duplicate

  // Using the implementation from line ~1060 instead of this duplicate

  // Using the implementation from line ~1100 instead of this duplicate

