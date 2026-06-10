import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); }
  @override void dispose()   { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override void didChangeMetrics() { super.didChangeMetrics(); }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.getTheme(),
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash,    page: () => const Splash()),
        GetPage(name: AppRoutes.dashboard, page: () => const DashboardPage()),
        GetPage(name: AppRoutes.profile,   page: () => ProfileScreen()),
        GetPage(name: AppRoutes.guide,     page: () => const GuideScreen()),

        // ── Practice ───────────────────────────────────────────────────────
        GetPage(
          name: AppRoutes.practice,
          page: () {
            final args = Get.arguments;
            String lessonType   = 'word';
            String difficulty   = 'easy';
            String languageCode = 'en';

            if (args is Map<String, String>) {
              lessonType   = args['lessonType']   ?? 'word';
              difficulty   = args['difficulty']   ?? 'easy';
              languageCode = args['languageCode'] ?? 'en';
            } else if (args is Map<String, dynamic>) {
              lessonType   = args['lessonType']   as String? ?? 'word';
              difficulty   = args['difficulty']   as String? ?? 'easy';
              languageCode = args['languageCode'] as String? ?? 'en';
            }

            return PracticeScreen(
              lessonType:   lessonType,
              difficulty:   difficulty,
              languageCode: languageCode,
              // To switch to API: pass ApiPracticeContentRepository(baseUrl: '...')
            );
          },
        ),

        // ── Level 1 (key guide) ────────────────────────────────────────────
        GetPage(
          name: AppRoutes.level1,
          page: () {
            final args = Get.arguments;
            if (args is Map<String, dynamic>) {
              return Level1(args['lesson'] as String? ?? 'Home Row',
                  languageCode: args['languageCode'] as String? ?? 'en');
            } else if (args is String) {
              return Level1(args, languageCode: 'en');
            }
            return Level1('Home Row', languageCode: 'en');
          },
          transition: Transition.rightToLeft,
        ),

        GetPage(name: AppRoutes.practiceRecords, page: () => const PracticeRecordsScreen()),

        // Multilingual levels
        GetPage(name: AppRoutes.levels, page: () {
          final raw  = Get.arguments;
          final args = raw is Map<String, dynamic> ? raw : null;
          return LevelsScreen(
            practiceType: args?['type'] as PracticeType? ?? PracticeType.word,
            initialLanguageCode: args?['languageCode'] as String? ?? 'en',
          );
        }, transition: Transition.rightToLeft),

        GetPage(name: AppRoutes.wordLevels, page: () {
          final raw  = Get.arguments;
          final args = raw is Map<String, dynamic> ? raw : null;
          final lang = args?['languageCode'] as String? ?? 'en';
          return LevelsScreen(
            practiceType: PracticeType.word,
            initialLanguageCode: lang,
          );
        }, transition: Transition.rightToLeft),
        GetPage(name: AppRoutes.sentenceLevels, page: () {
          final raw  = Get.arguments;
          final args = raw is Map<String, dynamic> ? raw : null;
          final lang = args?['languageCode'] as String? ?? 'en';
          return LevelsScreen(
            practiceType: PracticeType.sentence,
            initialLanguageCode: lang,
          );
        }, transition: Transition.rightToLeft),
        GetPage(name: AppRoutes.paragraphLevels, page: () {
          final raw  = Get.arguments;
          final args = raw is Map<String, dynamic> ? raw : null;
          final lang = args?['languageCode'] as String? ?? 'en';
          return LevelsScreen(
            practiceType: PracticeType.paragraph,
            initialLanguageCode: lang,
          );
        }, transition: Transition.rightToLeft),

        GetPage(name: AppRoutes.levelPractice, page: () {
          final raw   = Get.arguments;
          final args  = raw is Map<String, dynamic> ? raw : null;
          final level = args?['level'] as PracticeLevel?;
          if (level == null) {
            // Safety guard: if level is missing, go back instead of crashing.
            WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
            return const SizedBox.shrink();
          }
          return LevelPracticeScreen(
            level:        level,
            type:         args?['type']         as PracticeType? ?? PracticeType.word,
            languageCode: args?['languageCode'] as String?       ?? 'en',
          );
        }, transition: Transition.rightToLeft),

        // Keyboard lessons
        GetPage(name: AppRoutes.keyboardLessons, page: () {
          return KeyboardLessonsListScreen(languageCode: Get.arguments as String? ?? 'en');
        }, transition: Transition.rightToLeft),

        GetPage(name: AppRoutes.keyboardLessonPractice, page: () {
          final raw    = Get.arguments;
          final args   = raw is Map<String, dynamic> ? raw : null;
          final lesson = args?['lesson'] as KeyboardLesson?;
          if (lesson == null) {
            // Safety guard: go back instead of throwing a TypeError.
            WidgetsBinding.instance.addPostFrameCallback((_) => Get.back());
            return const SizedBox.shrink();
          }
          return KeyboardLessonScreen(
            lesson:       lesson,
            languageCode: args?['languageCode'] as String? ?? 'en',
          );
        }, transition: Transition.rightToLeft),
      ],
    );
  }
}
