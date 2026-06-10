// =========================================================================
// 📱 APP CONSTANTS - CENTRALIZED CONFIGURATION
// =========================================================================

/// Central repository for all app constants and configuration values
class AppConstants {
  // =========================================================================
  // 🏷️ APP IDENTITY
  // =========================================================================

  static const String appName = 'Typing Tutor';
  static const String appVersion = '1.0.0';
  static const String packageId = 'com.aswdc_typing_tutor';
  static const String defaultUsername = 'Typing Student';
  static const String defaultCountry = 'Unknown';

  // =========================================================================
  // 🗄️ DATABASE CONFIGURATION
  // =========================================================================

  static const String databaseName = 'typing_records.db';
  static const int databaseVersion = 1;
  static const String recordsTableName = 'records';
  static const String statsTableName = 'typing_stats';

  // =========================================================================
  // 🔑 STORAGE KEYS
  // =========================================================================

  static const String usernameKey = 'username';
  static const String countryKey = 'country';
  static const String firstLaunchKey = 'first_launch';
  static const String bestWpmKey = 'best_wpm';
  static const String bestAccuracyKey = 'best_accuracy';
  static const String totalPracticeTimeKey = 'total_practice_time';

  // =========================================================================
  // ⌨️ KEYBOARD LAYOUT CONSTANTS
  // =========================================================================

  static const List<List<String>> keyboardLayout = [
    ['TAB', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '|'],
    ['CAPS', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\'', 'ENTER'],
    ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'SHIFT'],
    ['SPACE'],
  ];

  // =========================================================================
  // 🎯 TYPING LEVELS & EXERCISES
  // =========================================================================

  static const List<String> typingLevels = [
    'Home Row',
    'Home & Top Row',
    'Home & Bottom Row',
    'Top & Bottom Row',
    'Home & Top Row & Bottom',
    'Home Row & shift',
    'Top Row & shift',
    'Top Row',
    'Bottom Row',
  ];

  static const Map<String, String> typingPatterns = {
    'Home Row': 'asdf ;lkj hjkl asdf ;lkj hjkl asdf ;lkj hjkl ',
    'Home & Top Row': 'asdf qwer ;lkj uiop asdf qwer ;lkj uiop ',
    'Home & Bottom Row': 'asdf zxcv ;lkj nm,. asdf zxcv ;lkj nm,. ',
    'Top & Bottom Row': 'qwer zxcv uiop nm,. qwer zxcv uiop nm,. ',
    'Home & Top Row & Bottom':
        'asdf qwer zxcv ;lkj uiop nm,. the quick brown fox ',
    'Home Row & shift': 'AsDf ;LkJ HjKl AsDf ;LkJ HjKl AsDf ;LkJ ',
    'Top Row & shift': 'QweR UioP QweR UioP QweR UioP QweR UioP ',
    'Top Row': 'qwer uiop qwer uiop qwer uiop qwer uiop ',
    'Bottom Row': 'zxcv nm,. zxcv nm,. zxcv nm,. zxcv nm,. ',
  };

  static const List<String> levelDescriptions = [
    'Beginner Key Basics',
    'Top Row Practice',
    'Bottom Row Reach',
    'Upper Lower Combos',
    'Full Keyboard Mastery',
    'Uppercase and Symbols',
    'Advanced Shift Symbols',
    'Number Row Mastery',
    'Punctuation and Navigation',
  ];

  static const List<String> keyboardImages = [
    'assets/keybord_image/homeRow.png',
    'assets/keybord_image/hometop.png',
    'assets/keybord_image/homeRowbottomRow.png',
    'assets/keybord_image/BOTTOMtop.png',
    'assets/keybord_image/homeRowtop.png',
    'assets/keybord_image/homeRowSHIFT.png',
    'assets/keybord_image/toprowshift.png',
    'assets/keybord_image/toprow.png',
    'assets/keybord_image/bottomRow.png',
  ];

  // =========================================================================
  // 📊 PERFORMANCE THRESHOLDS
  // =========================================================================

  // WPM (Words Per Minute) classifications
  static const int expertWpm = 80;
  static const int excellentWpm = 60;
  static const int goodWpm = 40;
  static const int averageWpm = 20;
  static const int beginnerWpm = 10;

  // Accuracy percentage classifications
  static const double expertAccuracy = 98.0;
  static const double excellentAccuracy = 95.0;
  static const double goodAccuracy = 90.0;
  static const double averageAccuracy = 80.0;
  static const double beginnerAccuracy = 70.0;

  // =========================================================================
  // ⏱️ TIMING CONSTANTS
  // =========================================================================

  // Animation durations
  static const Duration extraShortAnimation = Duration(milliseconds: 150);
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  static const Duration extraLongAnimation = Duration(milliseconds: 1200);

  // Debounce and delay durations
  static const Duration keyPressDebounce = Duration(milliseconds: 100);
  static const Duration errorDisplayDuration = Duration(seconds: 2);
  static const Duration statsUpdateInterval = Duration(seconds: 1);
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);

  // =========================================================================
  // 📐 UI DIMENSIONS
  // =========================================================================

  // Border radius values
  static const double extraSmallRadius = 4.0;
  static const double smallRadius = 6.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Padding and margin values
  static const double extraSmallPadding = 4.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Icon sizes
  static const double smallIcon = 16.0;
  static const double mediumIcon = 24.0;
  static const double largeIcon = 32.0;
  static const double extraLargeIcon = 48.0;

  // Avatar and image sizes
  static const double smallAvatar = 24.0;
  static const double mediumAvatar = 32.0;
  static const double largeAvatar = 48.0;
  static const double extraLargeAvatar = 64.0;

  // Screen breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Keyboard specific dimensions
  static const double keyboardSidebarWidth = 120.0;
  static const double minKeyboardWidth = 300.0;
  static const double maxKeyboardWidth = 800.0;
  static const double keyboardAspectRatio = 3.5; // width/height

  // =========================================================================
  // 🎨 COLOR VALUES
  // =========================================================================

  // Semantic color indicators
  static const int correctColorValue = 0xFF4CAF50; // Green
  static const int incorrectColorValue = 0xFFF44336; // Red
  static const int currentColorValue = 0xFF2196F3; // Blue
  static const int pendingColorValue = 0xFF9E9E9E; // Grey

  // =========================================================================
  // 👨‍💻 DEVELOPER & ORGANIZATION INFO
  // =========================================================================

  static const String developerName = '''Rajveer Parmar (21010101139)  
                                          Maintained by : Rana Mitrajsinh (24010101678)''';
  static const String mentorName =
      'Prof. Mehul Bhundiya (Computer Engineering Department)';
  static const String instituteName = 'ASWDC, School Of Computer Science';
  static const String organizationUrl = 'https://aswdc.in';
  static const String supportEmail = 'support@aswdc.in';

  // =========================================================================
  // 🔗 EXTERNAL LINKS
  // =========================================================================

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageId';
  static const String appStoreUrl =
      'https://apps.apple.com'; // Update when available
  static const String privacyPolicyUrl = 'https://aswdc.in/privacy-policy';
  static const String termsOfServiceUrl = 'https://aswdc.in/terms-of-service';

  static const String shareMessage =
      'Improve your typing skills with Typing Tutor!\n\n'
      'Download: $playStoreUrl';

  // =========================================================================
  // 🖼️ ASSET PATHS
  // =========================================================================

  static const String appLogo = 'assets/splash_screen/ic_logo.png';
  static const String splashBackground = 'assets/splash_screen/splash_bg.png';

  // Hand position images
  static const String leftPinkyImage = 'assets/images/pinkey.png';
  static const String leftRingImage = 'assets/images/ring.png';
  static const String leftMiddleImage = 'assets/images/middle.png';
  static const String leftIndexImage = 'assets/images/index.png';
  static const String leftDefaultImage = 'assets/images/leftDefault.png';
  static const String spaceLeftImage = 'assets/images/spaceLeft.png';

  static const String rightPinkyImage = 'assets/images/rightPinkey.png';
  static const String rightRingImage = 'assets/images/rightRing.png';
  static const String rightMiddleImage = 'assets/images/rightMiddle.png';
  static const String rightIndexImage = 'assets/images/rightIndex.png';
  static const String rightDefaultImage = 'assets/images/rightDefault.png';
  static const String spaceRightImage = 'assets/images/space.png';

  // =========================================================================
  // 🔧 UTILITY METHODS
  // =========================================================================

  /// Get performance level based on WPM
  static String getWpmLevel(int wpm) {
    if (wpm >= expertWpm) return 'Expert';
    if (wpm >= excellentWpm) return 'Excellent';
    if (wpm >= goodWpm) return 'Good';
    if (wpm >= averageWpm) return 'Average';
    if (wpm >= beginnerWpm) return 'Beginner';
    return 'Learning';
  }

  /// Get accuracy level based on percentage
  static String getAccuracyLevel(double accuracy) {
    if (accuracy >= expertAccuracy) return 'Expert';
    if (accuracy >= excellentAccuracy) return 'Excellent';
    if (accuracy >= goodAccuracy) return 'Good';
    if (accuracy >= averageAccuracy) return 'Average';
    if (accuracy >= beginnerAccuracy) return 'Beginner';
    return 'Learning';
  }

  /// Get typing pattern for a specific level
  static String getTypingPattern(String level) {
    return typingPatterns[level] ?? typingPatterns['Home Row']!;
  }

  /// Get description for a specific level
  static String getLevelDescription(String level) {
    final index = typingLevels.indexOf(level);
    return index >= 0 && index < levelDescriptions.length
        ? levelDescriptions[index]
        : 'Practice typing with this level';
  }

  /// Get keyboard image for a specific level
  static String getKeyboardImage(String level) {
    final index = typingLevels.indexOf(level);
    return index >= 0 && index < keyboardImages.length
        ? keyboardImages[index]
        : keyboardImages[0];
  }

  /// Check if level requires shift key
  static bool requiresShift(String level) {
    return level.toLowerCase().contains('shift');
  }

  /// Get appropriate hand image for character (supports English, Hindi, Gujarati)
  static String getLeftHandImage(String character) {
    // English characters
    if ([
      'a',
      'A',
      'q',
      'Q',
      'z',
      'Z',
      'TAB',
      'CAPS',
      'SHIFT',
    ].contains(character)) {
      return leftPinkyImage;
    } else if (['s', 'S', 'w', 'W', 'x', 'X'].contains(character)) {
      return leftRingImage;
    } else if (['d', 'D', 'e', 'E', 'c', 'C'].contains(character)) {
      return leftMiddleImage;
    } else if ([
      'f',
      'F',
      'r',
      'R',
      'v',
      'V',
      't',
      'T',
      'g',
      'G',
      'b',
      'B',
    ].contains(character)) {
      return leftIndexImage;
    } else if (character == ' ' || character == 'SPACE') {
      return spaceLeftImage;
    }

    // Hindi characters - Left Pinky
    if (['ौ', 'ो', 'ॅ', 'औ', 'ओ', 'ऋ'].contains(character)) {
      return leftPinkyImage;
    }
    // Hindi - Left Ring
    if (['ै', 'े', 'ं', 'ऐ', 'ए', 'ः'].contains(character)) {
      return leftRingImage;
    }
    // Hindi - Left Middle
    if (['ा', '्', 'म', 'आ', 'अ', 'ष'].contains(character)) {
      return leftMiddleImage;
    }
    // Hindi - Left Index
    if ([
      'ी',
      'ू',
      'ब',
      'ि',
      'ु',
      'प',
      'न',
      'व',
      'ल',
      'ई',
      'ऊ',
      'भ',
      'इ',
      'उ',
      'फ',
      'श',
      'ण',
      'ळ',
    ].contains(character)) {
      return leftIndexImage;
    }

    // Gujarati characters - Left Pinky
    if (['ૌ', 'ો', 'ૅ', 'ઔ', 'ઓ', 'ઋ'].contains(character)) {
      return leftPinkyImage;
    }
    // Gujarati - Left Ring (x key = ં anusvara, Shift+X = ઁ chandrabindu)
    if (['ૈ', 'ે', 'ં', 'ઐ', 'એ', 'ઁ'].contains(character)) {
      return leftRingImage;
    }
    // Gujarati - Left Middle
    if (['ા', '્', 'મ', 'આ', 'અ', 'ષ'].contains(character)) {
      return leftMiddleImage;
    }
    // Gujarati - Left Index
    if ([
      'ી',
      'ૂ',
      'બ',
      'િ',
      'ુ',
      'પ',
      'ન',
      'વ',
      'લ',
      'ઈ',
      'ઊ',
      'ભ',
      'ઇ',
      'ઉ',
      'ફ',
      'શ',
      'ણ',
      'ળ',
    ].contains(character)) {
      return leftIndexImage;
    }

    return leftDefaultImage;
  }

  static String getRightHandImage(String character) {
    // English characters
    if ([
      ';',
      ':',
      'p',
      'P',
      '/',
      '?',
      'ENTER',
      '[',
      ']',
      '\\',
      '\'',
    ].contains(character)) {
      return rightPinkyImage;
    } else if (['l', 'L', 'o', 'O', '.'].contains(character)) {
      return rightRingImage;
    } else if (['k', 'K', 'i', 'I', ','].contains(character)) {
      return rightMiddleImage;
    } else if ([
      'j',
      'J',
      'u',
      'U',
      'h',
      'H',
      'y',
      'Y',
      'n',
      'N',
      'm',
      'M',
    ].contains(character)) {
      return rightIndexImage;
    } else if (character == ' ' || character == 'SPACE') {
      return spaceRightImage;
    }

    // Hindi characters - Right Pinky (includes visarga ः and other shift characters)
    if ([
      'ड',
      '़',
      'ॉ',
      'ट',
      'ढ',
      'ञ',
      'ठ',
      'ः',
      'ॄ',
      'ऑ',
      'ृ',
    ].contains(character)) {
      return rightPinkyImage;
    }
    // Hindi - Right Ring
    if (['ज', 'च', 'य', 'झ', 'छ'].contains(character)) {
      return rightRingImage;
    }
    // Hindi - Right Middle
    if (['द', 'त', '.', 'ध', 'थ', '॥'].contains(character)) {
      return rightMiddleImage;
    }
    // Hindi - Right Index
    if ([
      'ह',
      'ग',
      'र',
      'क',
      'स',
      ',',
      'ङ',
      'घ',
      'ऱ',
      'ख',
      '।',
    ].contains(character)) {
      return rightIndexImage;
    }

    // Gujarati characters - Right Pinky (includes visarga ઃ and other shift characters)
    if ([
      'ડ',
      '઼',
      'ૉ',
      'ટ',
      'ઢ',
      'ઞ',
      'ઠ',
      'ઃ',
      'ૄ',
      'ઑ',
      'ૃ',
    ].contains(character)) {
      return rightPinkyImage;
    }
    // Gujarati - Right Ring
    if (['જ', 'ચ', 'ય', 'ઝ', 'છ'].contains(character)) {
      return rightRingImage;
    }
    // Gujarati - Right Middle
    if (['દ', 'ત', '.', 'ધ', 'થ', '॥'].contains(character)) {
      return rightMiddleImage;
    }
    // Gujarati - Right Index
    if ([
      'હ',
      'ગ',
      'ર',
      'ક',
      'સ',
      ',',
      'ઙ',
      'ઘ',
      'ખ',
      '।',
    ].contains(character)) {
      return rightIndexImage;
    }

    return rightDefaultImage;
  }
}

// =========================================================================
// 📦 GROUPED CONSTANTS (Aliases referencing AppConstants where possible)
// =========================================================================

/// App configuration and identity
class AppConfig {
  static const String appName = AppConstants.appName;
  static const String appVersion = AppConstants.appVersion;
  static const String packageId = AppConstants.packageId;
  static const String versionLabel = 'v${AppConstants.appVersion}';
}

/// Shared preference keys and storage keys
class AppKeys {
  static const String username = AppConstants.usernameKey;
  static const String country = AppConstants.countryKey;
  static const String firstLaunch = AppConstants.firstLaunchKey;
  static const String bestWpm = AppConstants.bestWpmKey;
  static const String bestAccuracy = AppConstants.bestAccuracyKey;
  static const String totalPracticeTime = AppConstants.totalPracticeTimeKey;
}

/// Durations and timed constants
class AppDurations {
  // App flows
  static const Duration splashFade = Duration(milliseconds: 2000);
  static const Duration splashDelay = Duration(milliseconds: 3500);
  static const Duration pageTransitionShort = Duration(milliseconds: 400);

  // Dashboard animations
  static const Duration dashboardIntro = Duration(milliseconds: 1000);
  static const Duration cardAnimationBase = Duration(milliseconds: 800);
  static const Duration cardAnimationStagger = Duration(milliseconds: 100);
  static const Duration cardStaggerDelay = Duration(milliseconds: 150);

  // Keyboard/game animations
  static const Duration keyPulse = Duration(milliseconds: 500);
  static const Duration keyShake = Duration(milliseconds: 300);
  static const Duration scrollFast = Duration(milliseconds: 200);
  static const Duration statsTick = Duration(seconds: 1);
  static const Duration wrongKeyHintShort = Duration(seconds: 1);

  // Existing generic durations
  static const Duration errorDisplay = AppConstants.errorDisplayDuration; // 2s
  static const Duration scroll = AppConstants.scrollAnimationDuration; // 300ms
  static const Duration typewriterSpeed = Duration(milliseconds: 100);
}

/// User-facing texts and labels
class AppText {
  // General
  static const String appTitle = AppConfig.appName;
  static const String chooseYourLevel = 'Choose Your Level';
  static const String startPractice = 'Start Practice';

  // Sections
  static const String keyboardLessons = 'Keyboard Lessons';
  static const String keyboardLessonsSubtitle =
      'Swipe to explore different keyboard rows and difficulty levels';
  static const String practiceModes = 'Practice Modes';
  static const String practiceModesSubtitle =
      'Different practice modes to improve your typing skills progressively';

  // Practice types
  static const String wordPractice = 'Word Practice';
  static const String wordPracticeDesc =
      'Practice single words to build vocabulary and finger memory';
  static const String sentencePractice = 'Sentence Practice';
  static const String sentencePracticeDesc =
      'Type complete sentences with proper punctuation and spacing';
  static const String paragraphPractice = 'Paragraph Practice';
  static const String paragraphPracticeDesc =
      'Master longer texts and develop sustained typing rhythm';

  // Tooltips / actions
  static const String profile = 'Profile';
  static const String aboutDeveloper = 'About Developer';

  // Dialogs
  static const String congratulations = 'Congratulations!';
  static const String exerciseCompleted =
      'You have completed the typing exercise!';
  static const String back = 'Back';
  static const String continueText = 'Continue';

  // Records
  static const String practiceRecords = 'Practice Records';
  static const String sortByDate = 'Sort by Date';
  static const String sortByWpm = 'Sort by WPM';
  static const String sortByAccuracy = 'Sort by Accuracy';
  static const String clearAllRecords = 'Clear All Records';
  static const String clearAllRecordsConfirm =
      'Are you sure you want to delete all typing records? This action cannot be undone.';
  static const String cancel = 'Cancel';
  static const String deleteAll = 'Delete All';
  static const String refreshRecords = 'Refresh Records';
  static const String noRecordsYet = 'No Records Yet';
  static const String recordsEmptySubtitle =
      'Complete typing exercises to see your records here';
  static const String startPracticing = 'Start Practicing';

  // Profile
  static const String editUsername = 'Edit Username';
  static const String enterUsernamePrompt =
      'Enter your username to personalize your profile:';
  static const String usernameLabel = 'Username';
  static const String usernameHint = 'Enter your name';
  static const String save = 'Save';
  static const String typingEnthusiast = 'Typing Enthusiast';
  static const String recentPerformance = 'Recent Performance';
  static const String seeAll = 'See all';

  // Guide
  static const String typingTips = 'Typing Tips';
  static const String typingTipsList =
      '• Accuracy first\n• Proper hand position\n• Take breaks';

  // Splash
  static const String splashTagline = 'Master your keyboard skills';
}

/// Asset aliases
class AppAssets {
  static const String appLogo = AppConstants.appLogo;
}

/// App route names used with Get.toNamed/Get.offNamed
class AppRoutes {
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String guide = '/guide';
  static const String practice = '/practice';
  static const String level1 = '/level1';
  static const String practiceRecords = '/practice-records';

  // Multilingual typing levels
  static const String levels = '/levels';
  static const String levelPractice = '/level-practice';
  static const String levelCompletion = '/level-completion';
  static const String wordLevels = '/word-levels';
  static const String sentenceLevels = '/sentence-levels';
  static const String paragraphLevels = '/paragraph-levels';

  // Keyboard lessons
  static const String keyboardLessons = '/keyboard-lessons';
  static const String keyboardLessonPractice = '/keyboard-lesson-practice';
}
