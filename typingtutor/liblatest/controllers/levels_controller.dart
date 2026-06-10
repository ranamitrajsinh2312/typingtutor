// =========================================================================
// 📚 LEVELS CONTROLLER - GETX STATE MANAGEMENT
// =========================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typingtutor/models/practice_level.dart';
import 'package:typingtutor/controllers/keyboard_controller.dart';

/// GetX Controller for managing typing practice levels
class LevelsController extends GetxController {
  // =========================================================================
  // 📊 OBSERVABLE STATE
  // =========================================================================

  /// Current language code
  final _currentLanguage = 'en'.obs;

  /// Current practice type
  final _currentType = PracticeType.word.obs;

  /// All levels for current language and type
  final _levels = <PracticeLevel>[].obs;

  /// Currently selected level
  final _selectedLevel = Rxn<PracticeLevel>();

  /// Current typing content
  final _currentContent = <TypingContent>[].obs;

  /// Loading state
  final _isLoading = false.obs;

  /// Error message
  final _errorMessage = ''.obs;

  /// Total stars earned
  final _totalStars = 0.obs;

  /// Level progress map (levelId -> LevelCompletionResult)
  final _levelProgress = <int, LevelCompletionResult>{}.obs;

  // =========================================================================
  // 🔍 GETTERS
  // =========================================================================

  String get currentLanguage => _currentLanguage.value;
  PracticeType get currentType => _currentType.value;
  List<PracticeLevel> get levels => _levels;
  PracticeLevel? get selectedLevel => _selectedLevel.value;
  List<TypingContent> get currentContent => _currentContent;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  int get totalStars => _totalStars.value;
  Map<int, LevelCompletionResult> get levelProgress => _levelProgress;

  /// Get levels filtered by type
  List<PracticeLevel> getLevelsByType(PracticeType type) {
    return _levels.where((l) => l.type == type).toList();
  }

  /// Get completed levels count
  int get completedLevelsCount {
    return _levels.where((l) => l.isCompleted).length;
  }

  /// Get total levels count
  int get totalLevelsCount => _levels.length;

  // =========================================================================
  // 🔄 INITIALIZATION
  // =========================================================================

  @override
  void onInit() {
    super.onInit();
    _initializeLevels();
    _loadProgress();
  }

  void _initializeLevels() {
    // Generate default levels for all practice types
    _levels.value = _generateDefaultLevels();
  }

  /// Generate default levels for all types and languages
  List<PracticeLevel> _generateDefaultLevels() {
    final List<PracticeLevel> allLevels = [];
    int levelId = 1;

    // Generate levels for each practice type
    for (final type in PracticeType.values) {
      final typeInfo = _getTypeInfo(type);
      final count = typeInfo['count'] as int;

      for (int i = 1; i <= count; i++) {
        allLevels.add(
          PracticeLevel(
            id: levelId++,
            title: '${type.displayName} Level $i',
            description: _getLevelDescription(type, i),
            type: type,
            languageCode: _currentLanguage.value,
            contentCount: _getContentCount(type, i),
            difficulty: _getDifficulty(i),
            isLocked: false, // All levels unlocked
          ),
        );
      }
    }

    return allLevels;
  }

  Map<String, dynamic> _getTypeInfo(PracticeType type) {
    switch (type) {
      case PracticeType.word:
        return {'count': 10, 'baseContent': 5};
      case PracticeType.sentence:
        return {'count': 8, 'baseContent': 3};
      case PracticeType.paragraph:
        return {'count': 5, 'baseContent': 1};
    }
  }

  String _getLevelDescription(PracticeType type, int level) {
    switch (type) {
      case PracticeType.word:
        if (level <= 3) return 'Basic word practice';
        if (level <= 6) return 'Intermediate words';
        return 'Advanced vocabulary';
      case PracticeType.sentence:
        if (level <= 3) return 'Simple sentences';
        if (level <= 5) return 'Complex sentences';
        return 'Advanced sentences';
      case PracticeType.paragraph:
        if (level <= 2) return 'Short paragraphs';
        if (level <= 4) return 'Medium paragraphs';
        return 'Long paragraphs';
    }
  }

  int _getContentCount(PracticeType type, int level) {
    switch (type) {
      case PracticeType.word:
        return 5 + (level - 1) * 2;
      case PracticeType.sentence:
        return 3 + (level - 1);
      case PracticeType.paragraph:
        return 1;
    }
  }

  int _getDifficulty(int level) {
    if (level <= 3) return 1; // Easy
    if (level <= 6) return 2; // Medium
    return 3; // Hard
  }

  // =========================================================================
  // 🌍 LANGUAGE METHODS
  // =========================================================================

  /// Change current language
  void changeLanguage(String languageCode) {
    _currentLanguage.value = languageCode;

    // Also update keyboard controller if available
    if (Get.isRegistered<KeyboardController>()) {
      Get.find<KeyboardController>().changeLanguage(languageCode);
    }

    // Reload levels for new language
    _initializeLevels();
    _loadProgress();
    update();
  }

  /// Set practice type
  void setPracticeType(PracticeType type) {
    _currentType.value = type;
    update();
  }

  // =========================================================================
  // 📚 LEVEL MANAGEMENT
  // =========================================================================

  /// Select a level to practice
  void selectLevel(PracticeLevel level) {
    if (level.isLocked) {
      Get.snackbar(
        'Level Locked',
        'Complete the previous level to unlock this one!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    _selectedLevel.value = level;
    fetchContent(level);
    update();
  }

  /// Unlock next level after completing current
  void unlockNextLevel(int completedLevelId) {
    final currentIndex = _levels.indexWhere((l) => l.id == completedLevelId);
    if (currentIndex >= 0 && currentIndex < _levels.length - 1) {
      final nextLevel = _levels[currentIndex + 1];
      if (nextLevel.isLocked && nextLevel.type == _levels[currentIndex].type) {
        _levels[currentIndex + 1] = nextLevel.copyWith(isLocked: false);
        update();
      }
    }
  }

  /// Update level completion
  void updateLevelCompletion(LevelCompletionResult result) {
    final levelIndex = _levels.indexWhere((l) => l.id == result.levelId);
    if (levelIndex >= 0) {
      final level = _levels[levelIndex];

      _levels[levelIndex] = level.copyWith(
        isCompleted: true,
        starsEarned:
            result.starsEarned > level.starsEarned
                ? result.starsEarned
                : level.starsEarned,
        bestWpm: result.wpm > level.bestWpm ? result.wpm : level.bestWpm,
        bestAccuracy:
            result.accuracy > level.bestAccuracy
                ? result.accuracy
                : level.bestAccuracy,
      );

      // Store progress
      _levelProgress[result.levelId] = result;

      // Update total stars
      _totalStars.value = _levels.fold(0, (sum, l) => sum + l.starsEarned);

      // Unlock next level
      unlockNextLevel(result.levelId);

      // Save progress
      _saveProgress();

      update();
    }
  }

  // =========================================================================
  // 🌐 CONTENT FETCHING
  // =========================================================================

  /// Fetch content for a level
  Future<void> fetchContent(PracticeLevel level) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _currentContent.clear();

    try {
      // Get content based on language
      final content = await _fetchContentForLanguage(
        _currentLanguage.value,
        level.type,
        level.contentCount,
      );

      _currentContent.value = content;
    } catch (e) {
      _errorMessage.value = 'Failed to load content: $e';
      // Fallback to default content
      _currentContent.value = _getDefaultContent(level);
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  /// Fetch content from API or local data
  Future<List<TypingContent>> _fetchContentForLanguage(
    String languageCode,
    PracticeType type,
    int count,
  ) async {
    // Try to fetch from API first
    try {
      final apiContent = await _fetchFromApi(languageCode, type, count);
      if (apiContent.isNotEmpty) {
        return apiContent;
      }
    } catch (e) {
      debugPrint('API fetch failed: $e');
    }

    // Fall back to local data
    return _getLocalContent(languageCode, type, count);
  }

  /// Fetch content from API
  Future<List<TypingContent>> _fetchFromApi(
    String languageCode,
    PracticeType type,
    int count,
  ) async {
    // API endpoint example (replace with your actual API)
    // This demonstrates the expected API response format
    /*
    Response format:
    {
      "results": [
        {"text": "मुझे पढ़ना पसंद है।", "lang": "hin"},
        {"text": "यह एक वाक्य है।", "lang": "hin"}
      ]
    }
    */

    // For now, return empty list to use local content
    // Uncomment and modify the following when you have an API:
    /*
    final langParam = _getApiLangCode(languageCode);
    final typeParam = type.name;
    
    final response = await http.get(
      Uri.parse('https://your-api.com/typing-content?lang=$langParam&type=$typeParam&count=$count'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((r) => TypingContent.fromJson(
        r,
        type: type,
        levelId: _selectedLevel.value?.id ?? 0,
      )).toList();
    }
    */

    return [];
  }

  /// Get local content as fallback
  List<TypingContent> _getLocalContent(
    String languageCode,
    PracticeType type,
    int count,
  ) {
    final content = _contentRepository[languageCode]?[type] ?? [];
    return content
        .take(count)
        .map(
          (text) => TypingContent(
            text: text,
            languageCode: languageCode,
            type: type,
            levelId: _selectedLevel.value?.id ?? 0,
          ),
        )
        .toList();
  }

  /// Get default content for error fallback
  List<TypingContent> _getDefaultContent(PracticeLevel level) {
    return _getLocalContent(level.languageCode, level.type, level.contentCount);
  }

  // =========================================================================
  // 📦 LOCAL CONTENT REPOSITORY
  // =========================================================================

  static const Map<String, Map<PracticeType, List<String>>>
  _contentRepository = {
    // English content
    'en': {
      PracticeType.word: [
        'hello',
        'world',
        'typing',
        'practice',
        'keyboard',
        'computer',
        'flutter',
        'mobile',
        'application',
        'developer',
        'programming',
        'software',
        'technology',
        'learning',
        'education',
        'beautiful',
        'wonderful',
        'excellent',
        'fantastic',
        'amazing',
      ],
      PracticeType.sentence: [
        'The quick brown fox jumps over the lazy dog.',
        'Practice makes a man perfect.',
        'Learning to type is an important skill.',
        'Technology is changing the world rapidly.',
        'Programming requires patience and dedication.',
        'The sun rises in the east and sets in the west.',
        'Reading books improves your vocabulary.',
        'Exercise is good for your health.',
      ],
      PracticeType.paragraph: [
        'Typing is an essential skill in today\'s digital world. With the increasing use of computers and smartphones, being able to type quickly and accurately has become more important than ever. Regular practice can help improve your typing speed and reduce errors.',
        'Flutter is a popular framework for building cross-platform mobile applications. It allows developers to write code once and deploy it on both iOS and Android platforms. The framework uses Dart programming language and provides a rich set of widgets.',
        'Learning a new language opens up a world of opportunities. It helps you communicate with people from different cultures and backgrounds. Language learning also improves cognitive abilities and memory.',
      ],
    },

    // Hindi content
    'hi': {
      PracticeType.word: [
        'नमस्ते',
        'भारत',
        'कंप्यूटर',
        'टाइपिंग',
        'अभ्यास',
        'शिक्षा',
        'विद्यालय',
        'पुस्तक',
        'लेखन',
        'पढ़ना',
        'सुंदर',
        'अच्छा',
        'बड़ा',
        'छोटा',
        'प्रौद्योगिकी',
        'विकास',
        'संगणक',
        'कार्यक्रम',
        'सॉफ्टवेयर',
        'हार्डवेयर',
      ],
      PracticeType.sentence: [
        'मुझे पढ़ना पसंद है।',
        'भारत एक महान देश है।',
        'अभ्यास से सब कुछ संभव है।',
        'शिक्षा जीवन का आधार है।',
        'प्रौद्योगिकी तेजी से बदल रही है।',
        'हिंदी हमारी राष्ट्रभाषा है।',
        'कंप्यूटर आधुनिक जीवन का हिस्सा है।',
        'सूर्य पूर्व में उगता है।',
      ],
      PracticeType.paragraph: [
        'टाइपिंग आज के डिजिटल युग में एक आवश्यक कौशल है। कंप्यूटर और स्मार्टफोन के बढ़ते उपयोग के साथ, तेजी से और सटीक टाइप करने की क्षमता पहले से कहीं अधिक महत्वपूर्ण हो गई है।',
        'भारत एक विविधता से भरा देश है जहाँ अनेक भाषाएँ, संस्कृतियाँ और परंपराएँ एक साथ मिलकर रहती हैं। यह एकता में विविधता का सबसे बड़ा उदाहरण है।',
        'शिक्षा व्यक्ति के समग्र विकास की नींव है। यह न केवल ज्ञान प्रदान करती है बल्कि व्यक्ति को एक बेहतर नागरिक बनने में भी मदद करती है।',
      ],
    },

    // Gujarati content
    'gu': {
      PracticeType.word: [
        'નમસ્તે',
        'ગુજરાત',
        'કમ્પ્યુટર',
        'ટાઇપિંગ',
        'અભ્યાસ',
        'શિક્ષણ',
        'શાળા',
        'પુસ્તક',
        'લેખન',
        'વાંચન',
        'સુંદર',
        'સારું',
        'મોટું',
        'નાનું',
        'ટેક્નોલોજી',
        'વિકાસ',
        'સંગણક',
        'કાર્યક્રમ',
        'સોફ્ટવેર',
        'હાર્ડવેર',
      ],
      PracticeType.sentence: [
        'મને વાંચવું ગમે છે.',
        'ગુજરાત એક મહાન રાજ્ય છે.',
        'અભ્યાસથી બધું શક્ય છે.',
        'શિક્ષણ જીવનનો આધાર છે.',
        'ટેક્નોલોજી ઝડપથી બદલાઈ રહી છે.',
        'ગુજરાતી આપણી માતૃભાષા છે.',
        'કમ્પ્યુટર આધુનિક જીવનનો ભાગ છે.',
        'સૂર્ય પૂર્વમાં ઊગે છે.',
      ],
      PracticeType.paragraph: [
        'ટાઇપિંગ આજના ડિજિટલ યુગમાં એક આવશ્યક કૌશલ્ય છે. કમ્પ્યુટર અને સ્માર્ટફોનના વધતા ઉપયોગ સાથે, ઝડપથી અને સટીક ટાઇપ કરવાની ક્ષમતા પહેલા કરતા વધુ મહત્વપૂર્ણ બની ગઈ છે.',
        'ગુજરાત વિવિધતાથી ભરેલું રાજ્ય છે જ્યાં અનેક સંસ્કૃતિઓ અને પરંપરાઓ એક સાથે મળીને રહે છે. આ એકતામાં વિવિધતાનું સૌથી મોટું ઉદાહરણ છે.',
        'શિક્ષણ વ્યક્તિના સમગ્ર વિકાસનો પાયો છે. તે માત્ર જ્ઞાન જ નથી આપતું પણ વ્યક્તિને એક સારા નાગરિક બનવામાં પણ મદદ કરે છે.',
      ],
    },
  };

  // =========================================================================
  // 💾 PERSISTENCE
  // =========================================================================

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save level progress
      final progressMap = _levelProgress.map(
        (key, value) => MapEntry(key.toString(), json.encode(value.toMap())),
      );
      await prefs.setString('level_progress', json.encode(progressMap));

      // Save total stars
      await prefs.setInt('total_stars', _totalStars.value);
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load level progress
      final progressString = prefs.getString('level_progress');
      if (progressString != null) {
        final progressMap = json.decode(progressString) as Map<String, dynamic>;
        _levelProgress.value = progressMap.map(
          (key, value) => MapEntry(
            int.parse(key),
            LevelCompletionResult.fromMap(json.decode(value)),
          ),
        );

        // Update levels with saved progress
        for (int i = 0; i < _levels.length; i++) {
          final progress = _levelProgress[_levels[i].id];
          if (progress != null) {
            _levels[i] = _levels[i].copyWith(
              isCompleted: true,
              starsEarned: progress.starsEarned,
              bestWpm: progress.wpm,
              bestAccuracy: progress.accuracy,
            );

            // Unlock next level
            if (i < _levels.length - 1 &&
                _levels[i + 1].type == _levels[i].type) {
              _levels[i + 1] = _levels[i + 1].copyWith(isLocked: false);
            }
          }
        }
      }

      // Load total stars
      _totalStars.value = prefs.getInt('total_stars') ?? 0;

      update();
    } catch (e) {
      debugPrint('Failed to load progress: $e');
    }
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('level_progress');
      await prefs.remove('total_stars');

      _levelProgress.clear();
      _totalStars.value = 0;
      _initializeLevels();

      update();
    } catch (e) {
      debugPrint('Failed to reset progress: $e');
    }
  }
}
