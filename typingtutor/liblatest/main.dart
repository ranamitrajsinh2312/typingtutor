import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/constants/app_constants.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // Set immersive mode to hide status and navigation bars globally
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Allow both portrait and landscape orientations
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

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // No orientation-based UI changes needed
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.getTheme(),
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => const Splash()),
        GetPage(name: AppRoutes.dashboard, page: () => const DashboardPage()),
        GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
        GetPage(name: AppRoutes.guide, page: () => const GuideScreen()),
        GetPage(
          name: AppRoutes.practice,
          page: () {
            final args = Get.arguments;
            String lessonType = 'word';
            String difficulty = 'easy';

            if (args is Map<String, String>) {
              lessonType = args['lessonType'] ?? 'word';
              difficulty = args['difficulty'] ?? 'easy';
            } else if (args is Map<String, dynamic>) {
              lessonType = args['lessonType'] as String? ?? 'word';
              difficulty = args['difficulty'] as String? ?? 'easy';
            }

            return PracticeScreen(
              lessonType: lessonType,
              difficulty: difficulty,
            );
          },
        ),
        GetPage(
          name: AppRoutes.level1,
          page: () {
            // Handle both old String and new Map argument formats
            final args = Get.arguments;
            if (args is Map<String, dynamic>) {
              return Level1(
                args['lesson'] as String? ?? 'Home Row',
                languageCode: args['languageCode'] as String? ?? 'en',
              );
            } else if (args is String) {
              return Level1(args, languageCode: 'en');
            }
            return Level1('Home Row', languageCode: 'en');
          },
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.practiceRecords,
          page: () => const PracticeRecordsScreen(),
        ),

        // Multilingual typing levels routes
        GetPage(
          name: AppRoutes.levels,
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            final type = args?['type'] as PracticeType? ?? PracticeType.word;
            return LevelsScreen(practiceType: type);
          },
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.wordLevels,
          page: () => const LevelsScreen(practiceType: PracticeType.word),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.sentenceLevels,
          page: () => const LevelsScreen(practiceType: PracticeType.sentence),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.paragraphLevels,
          page: () => const LevelsScreen(practiceType: PracticeType.paragraph),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.levelPractice,
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            final level = args?['level'] as PracticeLevel;
            final type = args?['type'] as PracticeType? ?? PracticeType.word;
            final languageCode = args?['languageCode'] as String? ?? 'en';
            return LevelPracticeScreen(
              level: level,
              type: type,
              languageCode: languageCode,
            );
          },
          transition: Transition.rightToLeft,
        ),

        // Keyboard lessons routes
        GetPage(
          name: AppRoutes.keyboardLessons,
          page: () {
            final languageCode = Get.arguments as String? ?? 'en';
            return KeyboardLessonsListScreen(languageCode: languageCode);
          },
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: AppRoutes.keyboardLessonPractice,
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            final lesson = args?['lesson'] as KeyboardLesson;
            final languageCode = args?['languageCode'] as String? ?? 'en';
            return KeyboardLessonScreen(
              lesson: lesson,
              languageCode: languageCode,
            );
          },
          transition: Transition.rightToLeft,
        ),
      ],
    );
  }
}
