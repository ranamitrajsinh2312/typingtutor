// =========================================================================
// 📚 KEYBOARD LESSONS DATA - PRACTICE CONTENT FOR ALL LANGUAGES
// =========================================================================

import 'package:typingtutor/models/keyboard_lesson.dart';

/// Repository of keyboard lessons for all supported languages
class KeyboardLessonsData {
  // =========================================================================
  // 🇺🇸 ENGLISH KEYBOARD LESSONS
  // =========================================================================

  /// English QWERTY keyboard layout data
  static const List<List<String>> englishKeyboardLayout = [
    ['TAB', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\\'],
    ['CAPS', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\'', 'ENTER'],
    ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'SHIFT'],
    ['SPACE'],
  ];

  /// Home row keys for English
  static const List<String> englishHomeRowKeys = [
    'A',
    'S',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    ';',
  ];

  /// Top row keys for English
  static const List<String> englishTopRowKeys = [
    'Q',
    'W',
    'E',
    'R',
    'T',
    'Y',
    'U',
    'I',
    'O',
    'P',
  ];

  /// Bottom row keys for English
  static const List<String> englishBottomRowKeys = [
    'Z',
    'X',
    'C',
    'V',
    'B',
    'N',
    'M',
  ];

  /// English keyboard lessons
  static List<KeyboardLesson> getEnglishLessons() {
    return [
      // Lesson 1: Home Row
      KeyboardLesson(
        id: 1,
        title: 'Home Row',
        description: 'Learn the home row keys - ASDF JKL;',
        lessonType: KeyboardLessonType.homeRow,
        languageCode: 'en',
        practiceText:
            'asdf jkl; asdf jkl; fjdk slaf jkl; asdf fjdk slaf asdf jkl; fjfj dkdk slsl afaf jkjk l;l; asdfjkl; fjdksla',
        highlightKeys: englishHomeRowKeys,
        difficulty: 1,
        isLocked: false,
        imagePath: 'assets/keybord_image/homeRow.png',
      ),
      // Lesson 2: Home Row Extended
      KeyboardLesson(
        id: 2,
        title: 'Home Row Words',
        description: 'Type words using home row keys',
        lessonType: KeyboardLessonType.homeRow,
        languageCode: 'en',
        practiceText:
            'add dad sad fad had lad ask flask task fall hall shall dash flash slash glass salad',
        highlightKeys: englishHomeRowKeys,
        difficulty: 1,
        isLocked: false,
        imagePath: 'assets/keybord_image/homeRow.png',
      ),
      // Lesson 3: Top Row
      KeyboardLesson(
        id: 3,
        title: 'Top Row',
        description: 'Learn the top row keys - QWERTY',
        lessonType: KeyboardLessonType.topRow,
        languageCode: 'en',
        practiceText:
            'qwer tyui opqw erty uiop qwerty uiop qwer tyui werp qwerty poor wipe tire wire ripe type trip',
        highlightKeys: englishTopRowKeys,
        difficulty: 1,
        isLocked: true,
        imagePath: 'assets/keybord_image/toprow.png',
      ),
      // Lesson 4: Bottom Row
      KeyboardLesson(
        id: 4,
        title: 'Bottom Row',
        description: 'Learn the bottom row keys - ZXCVBNM',
        lessonType: KeyboardLessonType.bottomRow,
        languageCode: 'en',
        practiceText:
            'zxcv bnm zxcv bnm cvbn mzxc vbnm zxcvbnm bnm zxc cvb nmz',
        highlightKeys: englishBottomRowKeys,
        difficulty: 1,
        isLocked: true,
        imagePath: 'assets/keybord_image/bottomRow.png',
      ),
      // Lesson 5: Home + Top Row
      KeyboardLesson(
        id: 5,
        title: 'Home & Top Row',
        description: 'Combine home and top row practice',
        lessonType: KeyboardLessonType.homeTopRow,
        languageCode: 'en',
        practiceText:
            'the quick red fox typed fast with old keys said hello dear world we are here',
        highlightKeys: [...englishHomeRowKeys, ...englishTopRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/hometop.png',
      ),
      // Lesson 6: Home + Bottom Row
      KeyboardLesson(
        id: 6,
        title: 'Home & Bottom Row',
        description: 'Combine home and bottom row practice',
        lessonType: KeyboardLessonType.homeBottomRow,
        languageCode: 'en',
        practiceText:
            'jazz club max can van man fan dam jam ham slam clam zinc blank flanks',
        highlightKeys: [...englishHomeRowKeys, ...englishBottomRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowbottomRow.png',
      ),
      // Lesson 7: Top + Bottom Row
      KeyboardLesson(
        id: 7,
        title: 'Top & Bottom Row',
        description: 'Practice top and bottom row together',
        lessonType: KeyboardLessonType.topBottomRow,
        languageCode: 'en',
        practiceText:
            'mix box fix wax next text except expect exact oxygen vex hex rex complex',
        highlightKeys: [...englishTopRowKeys, ...englishBottomRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/BOTTOMtop.png',
      ),
      // Lesson 8: All Rows
      KeyboardLesson(
        id: 8,
        title: 'All Rows',
        description: 'Full keyboard mastery with all rows',
        lessonType: KeyboardLessonType.allRows,
        languageCode: 'en',
        practiceText:
            'the quick brown fox jumps over the lazy dog pack my box with five dozen liquor jugs',
        highlightKeys: [
          ...englishHomeRowKeys,
          ...englishTopRowKeys,
          ...englishBottomRowKeys,
        ],
        difficulty: 3,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowtop.png',
      ),
      // Lesson 9: Home Row + Shift
      KeyboardLesson(
        id: 9,
        title: 'Home Row + Shift',
        description: 'Practice uppercase with shift key',
        lessonType: KeyboardLessonType.homeRowShift,
        languageCode: 'en',
        practiceText:
            'Ask Dad Add Sad Fall Hall Shall Flask Task Glass Salad Dash Flash Slash',
        highlightKeys: [...englishHomeRowKeys, 'SHIFT'],
        difficulty: 3,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowSHIFT.png',
      ),
    ];
  }

  // =========================================================================
  // 🇮🇳 HINDI (DEVANAGARI INSCRIPT) KEYBOARD LESSONS
  // =========================================================================

  /// Hindi Inscript keyboard layout (same structure as English)
  static const List<List<String>> hindiKeyboardLayout = [
    ['TAB', 'ौ', 'ै', 'ा', 'ी', 'ू', 'ब', 'ह', 'ग', 'द', 'ज', 'ड', '़', 'ॉ'],
    ['CAPS', 'ो', 'े', '्', 'ि', 'ु', 'प', 'र', 'क', 'त', 'च', 'ट', 'ENTER'],
    ['SHIFT', 'ॅ', 'ं', 'म', 'न', 'व', 'ल', 'स', ',', '.', 'य', 'SHIFT'],
    ['SPACE'],
  ];

  /// Hindi Shift keyboard layout (aspirated consonants and full vowels)
  static const List<List<String>> hindiShiftKeyboardLayout = [
    ['TAB', 'औ', 'ऐ', 'आ', 'ई', 'ऊ', 'भ', 'ङ', 'घ', 'ध', 'झ', 'ढ', 'ञ', 'ऑ'],
    ['CAPS', 'ओ', 'ए', 'अ', 'इ', 'उ', 'फ', 'ऱ', 'ख', 'थ', 'छ', 'ठ', 'ENTER'],
    ['SHIFT', 'ऋ', 'ः', 'ष', 'श', 'ण', 'ळ', 'ऽ', '।', '॥', '?', 'SHIFT'],
    ['SPACE'],
  ];

  /// Hindi home row keys (matras and consonants)
  static const List<String> hindiHomeRowKeys = [
    'ो',
    'े',
    '्',
    'ि',
    'ु',
    'प',
    'र',
    'क',
    'त',
    'च',
    'ट',
  ];

  /// Hindi top row keys
  static const List<String> hindiTopRowKeys = [
    'ौ',
    'ै',
    'ा',
    'ी',
    'ू',
    'ब',
    'ह',
    'ग',
    'द',
    'ज',
    'ड',
  ];

  /// Hindi bottom row keys
  static const List<String> hindiBottomRowKeys = [
    'ं',
    'म',
    'न',
    'व',
    'ल',
    'स',
    'य',
  ];

  /// Hindi keyboard lessons
  static List<KeyboardLesson> getHindiLessons() {
    return [
      // Lesson 1: Hindi Home Row - Matras
      KeyboardLesson(
        id: 101,
        title: 'होम रो',
        description: 'मात्राएँ और व्यंजन सीखें - ो े ् ि ु प र क त च ट',
        lessonType: KeyboardLessonType.homeRow,
        languageCode: 'hi',
        practiceText: 'कर पर तर चक रक कप तप रत करत कर पर रत तप कप कर करत पत',
        highlightKeys: hindiHomeRowKeys,
        difficulty: 1,
        isLocked: false,
        imagePath: 'assets/keybord_image/homeRow.png',
      ),
      // Lesson 2: Hindi Home Row Words
      KeyboardLesson(
        id: 102,
        title: 'होम रो शब्द',
        description: 'होम रो से शब्द बनाएं',
        lessonType: KeyboardLessonType.homeRow,
        languageCode: 'hi',
        practiceText: 'कर करो करता करते परत पकर रकत तरक तरप',
        highlightKeys: hindiHomeRowKeys,
        difficulty: 1,
        isLocked: false,
        imagePath: 'assets/keybord_image/homeRow.png',
      ),
      // Lesson 3: Hindi Top Row
      KeyboardLesson(
        id: 103,
        title: 'टॉप रो',
        description: 'ऊपरी पंक्ति सीखें - ौ ै ा ी ू ब ह ग द ज ड',
        lessonType: KeyboardLessonType.topRow,
        languageCode: 'hi',
        practiceText: 'बाग दाग हाथ जाग बाद गाद दाद जाद बाँध गाँठ',
        highlightKeys: hindiTopRowKeys,
        difficulty: 1,
        isLocked: true,
        imagePath: 'assets/keybord_image/toprow.png',
      ),
      // Lesson 4: Hindi Bottom Row
      KeyboardLesson(
        id: 104,
        title: 'बॉटम रो',
        description: 'निचली पंक्ति सीखें - म न व ल स य',
        lessonType: KeyboardLessonType.bottomRow,
        languageCode: 'hi',
        practiceText: 'मन वन सन लम नल सम मल नम वल सव यम',
        highlightKeys: hindiBottomRowKeys,
        difficulty: 1,
        isLocked: true,
        imagePath: 'assets/keybord_image/bottomRow.png',
      ),
      // Lesson 5: Hindi Home + Top Row
      KeyboardLesson(
        id: 105,
        title: 'होम + टॉप',
        description: 'होम और टॉप रो का अभ्यास',
        lessonType: KeyboardLessonType.homeTopRow,
        languageCode: 'hi',
        practiceText:
            'कहा जाता है कि राम ने बाग में दो पेड़ लगाए और हर दिन पानी दिया',
        highlightKeys: [...hindiHomeRowKeys, ...hindiTopRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/hometop.png',
      ),
      // Lesson 6: Hindi Home + Bottom Row
      KeyboardLesson(
        id: 106,
        title: 'होम + बॉटम',
        description: 'होम और बॉटम रो का अभ्यास',
        lessonType: KeyboardLessonType.homeBottomRow,
        languageCode: 'hi',
        practiceText:
            'मन में कर समय लेकर नल से पानी लाना चाहिए मल कर सबकी सेवा करो',
        highlightKeys: [...hindiHomeRowKeys, ...hindiBottomRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowbottomRow.png',
      ),
      // Lesson 7: Hindi All Rows
      KeyboardLesson(
        id: 107,
        title: 'सभी पंक्तियाँ',
        description: 'पूर्ण कीबोर्ड अभ्यास',
        lessonType: KeyboardLessonType.allRows,
        languageCode: 'hi',
        practiceText:
            'भारत एक महान देश है यहाँ की संस्कृति और परंपराएँ विश्व में प्रसिद्ध हैं हम सबको मिलकर देश की सेवा करनी चाहिए',
        highlightKeys: [
          ...hindiHomeRowKeys,
          ...hindiTopRowKeys,
          ...hindiBottomRowKeys,
        ],
        difficulty: 3,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowtop.png',
      ),
      // Lesson 8: Hindi Common Words
      KeyboardLesson(
        id: 108,
        title: 'आम शब्द',
        description: 'रोज़मर्रा के शब्दों का अभ्यास',
        lessonType: KeyboardLessonType.allRows,
        languageCode: 'hi',
        practiceText:
            'नमस्ते धन्यवाद कृपया माफ़ कीजिए शुभ प्रभात शुभ रात्रि कैसे हो आप कहाँ जा रहे हो क्या हाल है',
        highlightKeys: [
          ...hindiHomeRowKeys,
          ...hindiTopRowKeys,
          ...hindiBottomRowKeys,
        ],
        difficulty: 3,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowtop.png',
      ),
    ];
  }

  // =========================================================================
  // 🇮🇳 GUJARATI (INSCRIPT) KEYBOARD LESSONS
  // =========================================================================

  /// Gujarati Inscript keyboard layout (same structure as English)
  static const List<List<String>> gujaratiKeyboardLayout = [
    ['TAB', 'ૌ', 'ૈ', 'ા', 'ી', 'ૂ', 'બ', 'હ', 'ગ', 'દ', 'જ', 'ડ', '઼', 'ૉ'],
    ['CAPS', 'ો', 'ે', '્', 'િ', 'ુ', 'પ', 'ર', 'ક', 'ત', 'ચ', 'ટ', 'ENTER'],
    ['SHIFT', 'ૅ', 'ં', 'મ', 'ન', 'વ', 'લ', 'સ', ',', '.', 'ય', 'SHIFT'],
    ['SPACE'],
  ];

  /// Gujarati Shift keyboard layout (aspirated consonants and full vowels)
  static const List<List<String>> gujaratiShiftKeyboardLayout = [
    ['TAB', 'ઔ', 'ઐ', 'આ', 'ઈ', 'ઊ', 'ભ', 'ઙ', 'ઘ', 'ધ', 'ઝ', 'ઢ', 'ઞ', 'ઑ'],
    ['CAPS', 'ઓ', 'એ', 'અ', 'ઇ', 'ઉ', 'ફ', 'ર', 'ખ', 'થ', 'છ', 'ઠ', 'ENTER'],
    ['SHIFT', 'ઋ', 'ઃ', 'ષ', 'શ', 'ણ', 'ળ', 'ઽ', '।', '॥', '?', 'SHIFT'],
    ['SPACE'],
  ];

  /// Gujarati home row keys
  static const List<String> gujaratiHomeRowKeys = [
    'ો',
    'ે',
    '્',
    'િ',
    'ુ',
    'પ',
    'ર',
    'ક',
    'ત',
    'ચ',
    'ટ',
  ];

  /// Gujarati top row keys
  static const List<String> gujaratiTopRowKeys = [
    'ૌ',
    'ૈ',
    'ા',
    'ી',
    'ૂ',
    'બ',
    'હ',
    'ગ',
    'દ',
    'જ',
    'ડ',
  ];

  /// Gujarati bottom row keys
  static const List<String> gujaratiBottomRowKeys = [
    'ં',
    'મ',
    'ન',
    'વ',
    'લ',
    'સ',
    'ય',
  ];

  /// Gujarati keyboard lessons
  static List<KeyboardLesson> getGujaratiLessons() {
    return [
      // Lesson 1: Gujarati Home Row
      KeyboardLesson(
        id: 201,
        title: 'હોમ રો',
        description: 'માત્રાઓ અને વ્યંજનો શીખો - ો ે ્ િ ુ પ ર ક ત ચ ટ',
        lessonType: KeyboardLessonType.homeRow,
        languageCode: 'gu',
        practiceText: 'કર પર તર ચક રક કપ તપ રત કરત કર પર રત તપ કપ કર કરત પત',
        highlightKeys: gujaratiHomeRowKeys,
        difficulty: 1,
        isLocked: false,
        imagePath: 'assets/keybord_image/homeRow.png',
      ),
      // Lesson 2: Gujarati Home Row Words
      KeyboardLesson(
        id: 202,
        title: 'હોમ રો શબ્દો',
        description: 'હોમ રોથી શબ્દો બનાવો',
        lessonType: KeyboardLessonType.homeRow,
        languageCode: 'gu',
        practiceText: 'કર કરો કરતા પરત પકર રકત તરક',
        highlightKeys: gujaratiHomeRowKeys,
        difficulty: 1,
        isLocked: false,
        imagePath: 'assets/keybord_image/homeRow.png',
      ),
      // Lesson 3: Gujarati Top Row
      KeyboardLesson(
        id: 203,
        title: 'ટોપ રો',
        description: 'ઉપરની હરોળ શીખો - ૌ ૈ ા ી ૂ બ હ ગ દ જ ડ',
        lessonType: KeyboardLessonType.topRow,
        languageCode: 'gu',
        practiceText: 'બાગ દાગ હાથ જાગ બાદ ગાદ દાદ જાદ',
        highlightKeys: gujaratiTopRowKeys,
        difficulty: 1,
        isLocked: true,
        imagePath: 'assets/keybord_image/toprow.png',
      ),
      // Lesson 4: Gujarati Bottom Row
      KeyboardLesson(
        id: 204,
        title: 'બોટમ રો',
        description: 'નીચેની હરોળ શીખો - મ ન વ લ સ ય',
        lessonType: KeyboardLessonType.bottomRow,
        languageCode: 'gu',
        practiceText: 'મન વન સન લમ નલ સમ મલ નમ વલ સવ યમ',
        highlightKeys: gujaratiBottomRowKeys,
        difficulty: 1,
        isLocked: true,
        imagePath: 'assets/keybord_image/bottomRow.png',
      ),
      // Lesson 5: Gujarati Home + Top Row
      KeyboardLesson(
        id: 205,
        title: 'હોમ + ટોપ',
        description: 'હોમ અને ટોપ રોનો અભ્યાસ',
        lessonType: KeyboardLessonType.homeTopRow,
        languageCode: 'gu',
        practiceText:
            'કહેવાય છે કે રામે બાગમાં બે ઝાડ વાવ્યા અને દરરોજ પાણી પાયું',
        highlightKeys: [...gujaratiHomeRowKeys, ...gujaratiTopRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/hometop.png',
      ),
      // Lesson 6: Gujarati Home + Bottom Row
      KeyboardLesson(
        id: 206,
        title: 'હોમ + બોટમ',
        description: 'હોમ અને બોટમ રોનો અભ્યાસ',
        lessonType: KeyboardLessonType.homeBottomRow,
        languageCode: 'gu',
        practiceText: 'મનમાં કર સમય લઈને નળથી પાણી લાવવું જોઈએ સૌની સેવા કરો',
        highlightKeys: [...gujaratiHomeRowKeys, ...gujaratiBottomRowKeys],
        difficulty: 2,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowbottomRow.png',
      ),
      // Lesson 7: Gujarati All Rows
      KeyboardLesson(
        id: 207,
        title: 'બધી હરોળો',
        description: 'સંપૂર્ણ કીબોર્ડ અભ્યાસ',
        lessonType: KeyboardLessonType.allRows,
        languageCode: 'gu',
        practiceText:
            'ગુજરાત ભારતનું એક મહાન રાજ્ય છે અહીંની સંસ્કૃતિ અને પરંપરાઓ વિશ્વમાં પ્રખ્યાત છે',
        highlightKeys: [
          ...gujaratiHomeRowKeys,
          ...gujaratiTopRowKeys,
          ...gujaratiBottomRowKeys,
        ],
        difficulty: 3,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowtop.png',
      ),
      // Lesson 8: Gujarati Common Words
      KeyboardLesson(
        id: 208,
        title: 'સામાન્ય શબ્દો',
        description: 'રોજિંદા શબ્દોનો અભ્યાસ',
        lessonType: KeyboardLessonType.allRows,
        languageCode: 'gu',
        practiceText:
            'નમસ્તે આભાર કૃપા કરીને માફ કરશો સુપ્રભાત શુભ રાત્રિ કેમ છો ક્યાં જાઓ છો શું ચાલે છે',
        highlightKeys: [
          ...gujaratiHomeRowKeys,
          ...gujaratiTopRowKeys,
          ...gujaratiBottomRowKeys,
        ],
        difficulty: 3,
        isLocked: true,
        imagePath: 'assets/keybord_image/homeRowtop.png',
      ),
    ];
  }

  // =========================================================================
  // 🔧 UTILITY METHODS
  // =========================================================================

  /// Get lessons for a specific language
  static List<KeyboardLesson> getLessonsForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return getEnglishLessons();
      case 'hi':
        return getHindiLessons();
      case 'gu':
        return getGujaratiLessons();
      default:
        return getEnglishLessons();
    }
  }

  /// Get keyboard layout for a specific language
  static List<List<String>> getKeyboardLayoutForLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return englishKeyboardLayout;
      case 'hi':
        return hindiKeyboardLayout;
      case 'gu':
        return gujaratiKeyboardLayout;
      default:
        return englishKeyboardLayout;
    }
  }

  /// Get shift keyboard layout for a specific language
  static List<List<String>> getShiftKeyboardLayoutForLanguage(
    String languageCode,
  ) {
    switch (languageCode) {
      case 'en':
        return englishKeyboardLayout; // English uses same layout with uppercase
      case 'hi':
        return hindiShiftKeyboardLayout;
      case 'gu':
        return gujaratiShiftKeyboardLayout;
      default:
        return englishKeyboardLayout;
    }
  }

  /// Get all supported language codes
  static List<String> get supportedLanguages => ['en', 'hi', 'gu'];

  /// Get language name by code
  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी';
      case 'gu':
        return 'ગુજરાતી';
      default:
        return 'English';
    }
  }

  /// Get language native name by code
  static String getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English (QWERTY)';
      case 'hi':
        return 'Hindi (Inscript)';
      case 'gu':
        return 'Gujarati (Inscript)';
      default:
        return 'English (QWERTY)';
    }
  }

  /// Get flag emoji for language
  static String getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'hi':
        return '🇮🇳';
      case 'gu':
        return '🇮🇳';
      default:
        return '🌐';
    }
  }
}
