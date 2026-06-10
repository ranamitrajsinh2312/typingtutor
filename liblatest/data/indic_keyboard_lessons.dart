// =============================================================================
// INDIC KEYBOARD LESSONS DATA
// =============================================================================
// Structured lesson progressions for Hindi (Devanagari) and Gujarati keyboards
// Based on Inscript keyboard layout for practical typing training
//
// LESSON STRUCTURE:
// Lesson 1 → Home Row (most frequently used consonants + halant)
// Lesson 2 → Top Row keys (consonants + matras)
// Lesson 3 → Bottom Row keys (consonants + anusvara + punctuation)
// Lesson 4 → Vowels & Matras (all dependent vowel signs)
// Lesson 5 → Full keyboard practice (all letters combined)
// =============================================================================

/// Hindi (Devanagari) Inscript Keyboard Lessons
/// Layout Reference:
/// Top Row:    ौ ै ा ी ू ब ह ग द ज ड ़ ॉ
/// Home Row:   ो े ् ि ु प र क त च ट
/// Bottom Row: ं म न व ल स , . य
class HindiKeyboardLessons {
  // ---------------------------------------------------------------------------
  // LESSON 1: HOME ROW
  // Focus: Most frequently used consonants (प र क त च ट) + halant (्)
  // These are the foundation keys for finger placement
  // ---------------------------------------------------------------------------
  static const List<String> homeRow = [
    'प', 'र', 'क', 'त', 'च', 'ट', // Consonants
    '्', // Halant (virama)
  ];

  static const List<String> homeRowMatras = [
    'ो', 'े', 'ि', 'ु', // Matras on home row
  ];

  // ---------------------------------------------------------------------------
  // LESSON 2: TOP ROW
  // Focus: Consonants (ब ह ग द ज ड) + matras (ौ ै ा ी ू ॉ)
  // ---------------------------------------------------------------------------
  static const List<String> topRow = [
    'ब', 'ह', 'ग', 'द', 'ज', 'ड', // Consonants
  ];

  static const List<String> topRowMatras = [
    'ौ', 'ै', 'ा', 'ी', 'ू', 'ॉ', // Matras on top row
    '़', // Nukta
  ];

  // ---------------------------------------------------------------------------
  // LESSON 3: BOTTOM ROW
  // Focus: Consonants (म न व ल स य) + anusvara (ं) + punctuation
  // ---------------------------------------------------------------------------
  static const List<String> bottomRow = [
    'म', 'न', 'व', 'ल', 'स', 'य', // Consonants
    'ं', // Anusvara
    ',', '.', // Punctuation
  ];

  // ---------------------------------------------------------------------------
  // LESSON 4: VOWELS & MATRAS
  // Focus: All dependent vowel signs (matras) for comprehensive practice
  // ---------------------------------------------------------------------------
  static const List<String> vowelsAndMatras = [
    // All matras (dependent vowels)
    'ा', 'ि', 'ी', 'ु', 'ू', 'े', 'ै', 'ो', 'ौ', 'ॉ',
    '्', // Halant
    'ं', // Anusvara
    'ः', // Visarga (Shift access)
    'ॅ', // Candra E (Shift access)
  ];

  // Independent vowels (accessed via Shift combinations)
  static const List<String> independentVowels = [
    'अ',
    'आ',
    'इ',
    'ई',
    'उ',
    'ऊ',
    'ए',
    'ऐ',
    'ओ',
    'औ',
    'ऋ',
  ];

  // ---------------------------------------------------------------------------
  // LESSON 5: FULL SET
  // Focus: Complete keyboard - all consonants, matras, and punctuation
  // ---------------------------------------------------------------------------
  static List<String> get fullSet => [
    ...homeRow,
    ...homeRowMatras,
    ...topRow,
    ...topRowMatras,
    ...bottomRow,
  ];

  // All consonants combined
  static const List<String> allConsonants = [
    'क',
    'ख',
    'ग',
    'घ',
    'ङ',
    'च',
    'छ',
    'ज',
    'झ',
    'ञ',
    'ट',
    'ठ',
    'ड',
    'ढ',
    'ण',
    'त',
    'थ',
    'द',
    'ध',
    'न',
    'प',
    'फ',
    'ब',
    'भ',
    'म',
    'य',
    'र',
    'ल',
    'व',
    'श',
    'ष',
    'स',
    'ह',
  ];

  // Practice strings for each lesson
  static const Map<String, String> practiceStrings = {
    'Home Row': 'पर कत चट पर कत चट प्र क्त पर कत ',
    'Top Row': 'बह गद जड बह गद जड बह गद जड बह ',
    'Bottom Row': 'मन वल सय मन वल सय मनं वल सय ',
    'Home & Top Row': 'पर बह कत गद चट जड पर बह कत ',
    'Home & Bottom Row': 'पर मन कत वल चट सय पर मन कत ',
    'Top & Bottom Row': 'बह मन गद वल जड सय बह मन गद ',
    'Vowels & Matras': 'का कि की कु कू के कै को कौ क्र ',
    'Home & Top Row & Bottom': 'पर बह मन कत गद वल चट जड सय ',
  };
}

/// Gujarati Inscript Keyboard Lessons
/// Layout Reference:
/// Top Row:    ૌ ૈ ા ી ૂ બ હ ગ દ જ ડ ઼ ૉ
/// Home Row:   ો ે ્ િ ુ પ ર ક ત ચ ટ
/// Bottom Row: ં મ ન વ લ સ , . ય
class GujaratiKeyboardLessons {
  // ---------------------------------------------------------------------------
  // LESSON 1: HOME ROW
  // Focus: Most frequently used consonants (પ ર ક ત ચ ટ) + halant (્)
  // ---------------------------------------------------------------------------
  static const List<String> homeRow = [
    'પ', 'ર', 'ક', 'ત', 'ચ', 'ટ', // Consonants
    '્', // Halant (virama)
  ];

  static const List<String> homeRowMatras = [
    'ો', 'ે', 'િ', 'ુ', // Matras on home row
  ];

  // ---------------------------------------------------------------------------
  // LESSON 2: TOP ROW
  // Focus: Consonants (બ હ ગ દ જ ડ) + matras (ૌ ૈ ા ી ૂ ૉ)
  // ---------------------------------------------------------------------------
  static const List<String> topRow = [
    'બ', 'હ', 'ગ', 'દ', 'જ', 'ડ', // Consonants
  ];

  static const List<String> topRowMatras = [
    'ૌ', 'ૈ', 'ા', 'ી', 'ૂ', 'ૉ', // Matras on top row
    '઼', // Nukta
  ];

  // ---------------------------------------------------------------------------
  // LESSON 3: BOTTOM ROW
  // Focus: Consonants (મ ન વ લ સ ય) + anusvara (ં) + punctuation
  // ---------------------------------------------------------------------------
  static const List<String> bottomRow = [
    'મ', 'ન', 'વ', 'લ', 'સ', 'ય', // Consonants
    'ં', // Anusvara
    ',', '.', // Punctuation
  ];

  // ---------------------------------------------------------------------------
  // LESSON 4: VOWELS & MATRAS
  // Focus: All dependent vowel signs (matras) for comprehensive practice
  // ---------------------------------------------------------------------------
  static const List<String> vowelsAndMatras = [
    // All matras (dependent vowels)
    'ા', 'િ', 'ી', 'ુ', 'ૂ', 'ે', 'ૈ', 'ો', 'ૌ', 'ૉ',
    '્', // Halant
    'ં', // Anusvara
    'ઃ', // Visarga (Shift access)
  ];

  // Independent vowels (accessed via Shift combinations)
  static const List<String> independentVowels = [
    'અ',
    'આ',
    'ઇ',
    'ઈ',
    'ઉ',
    'ઊ',
    'એ',
    'ઐ',
    'ઓ',
    'ઔ',
    'ઋ',
  ];

  // ---------------------------------------------------------------------------
  // LESSON 5: FULL SET
  // Focus: Complete keyboard - all consonants, matras, and punctuation
  // ---------------------------------------------------------------------------
  static List<String> get fullSet => [
    ...homeRow,
    ...homeRowMatras,
    ...topRow,
    ...topRowMatras,
    ...bottomRow,
  ];

  // All consonants combined
  static const List<String> allConsonants = [
    'ક',
    'ખ',
    'ગ',
    'ઘ',
    'ઙ',
    'ચ',
    'છ',
    'જ',
    'ઝ',
    'ઞ',
    'ટ',
    'ઠ',
    'ડ',
    'ઢ',
    'ણ',
    'ત',
    'થ',
    'દ',
    'ધ',
    'ન',
    'પ',
    'ફ',
    'બ',
    'ભ',
    'મ',
    'ય',
    'ર',
    'લ',
    'વ',
    'શ',
    'ષ',
    'સ',
    'હ',
    'ળ',
  ];

  // Practice strings for each lesson
  static const Map<String, String> practiceStrings = {
    'Home Row': 'પર કત ચટ પર કત ચટ પ્ર ક્ત પર કત ',
    'Top Row': 'બહ ગદ જડ બહ ગદ જડ બહ ગદ જડ બહ ',
    'Bottom Row': 'મન વલ સય મન વલ સય મનં વલ સય ',
    'Home & Top Row': 'પર બહ કત ગદ ચટ જડ પર બહ કત ',
    'Home & Bottom Row': 'પર મન કત વલ ચટ સય પર મન કત ',
    'Top & Bottom Row': 'બહ મન ગદ વલ જડ સય બહ મન ગદ ',
    'Vowels & Matras': 'કા કિ કી કુ કૂ કે કૈ કો કૌ ક્ર ',
    'Home & Top Row & Bottom': 'પર બહ મન કત ગદ વલ ચટ જડ સય ',
  };
}

/// Unified lesson data accessor
class IndicKeyboardLessons {
  /// Get lesson keys based on language and lesson type
  static List<String> getLessonKeys(String languageCode, String lessonType) {
    switch (languageCode) {
      case 'hi':
        return _getHindiLessonKeys(lessonType);
      case 'gu':
        return _getGujaratiLessonKeys(lessonType);
      default:
        return [];
    }
  }

  static List<String> _getHindiLessonKeys(String lessonType) {
    switch (lessonType) {
      case 'Home Row':
        return [
          ...HindiKeyboardLessons.homeRow,
          ...HindiKeyboardLessons.homeRowMatras,
        ];
      case 'Top Row':
        return [
          ...HindiKeyboardLessons.topRow,
          ...HindiKeyboardLessons.topRowMatras,
        ];
      case 'Bottom Row':
        return HindiKeyboardLessons.bottomRow;
      case 'Home & Top Row':
        return [
          ...HindiKeyboardLessons.homeRow,
          ...HindiKeyboardLessons.homeRowMatras,
          ...HindiKeyboardLessons.topRow,
          ...HindiKeyboardLessons.topRowMatras,
        ];
      case 'Home & Bottom Row':
        return [
          ...HindiKeyboardLessons.homeRow,
          ...HindiKeyboardLessons.homeRowMatras,
          ...HindiKeyboardLessons.bottomRow,
        ];
      case 'Top & Bottom Row':
        return [
          ...HindiKeyboardLessons.topRow,
          ...HindiKeyboardLessons.topRowMatras,
          ...HindiKeyboardLessons.bottomRow,
        ];
      case 'Vowels & Matras':
        return HindiKeyboardLessons.vowelsAndMatras;
      case 'Home & Top Row & Bottom':
        return HindiKeyboardLessons.fullSet;
      default:
        return HindiKeyboardLessons.homeRow;
    }
  }

  static List<String> _getGujaratiLessonKeys(String lessonType) {
    switch (lessonType) {
      case 'Home Row':
        return [
          ...GujaratiKeyboardLessons.homeRow,
          ...GujaratiKeyboardLessons.homeRowMatras,
        ];
      case 'Top Row':
        return [
          ...GujaratiKeyboardLessons.topRow,
          ...GujaratiKeyboardLessons.topRowMatras,
        ];
      case 'Bottom Row':
        return GujaratiKeyboardLessons.bottomRow;
      case 'Home & Top Row':
        return [
          ...GujaratiKeyboardLessons.homeRow,
          ...GujaratiKeyboardLessons.homeRowMatras,
          ...GujaratiKeyboardLessons.topRow,
          ...GujaratiKeyboardLessons.topRowMatras,
        ];
      case 'Home & Bottom Row':
        return [
          ...GujaratiKeyboardLessons.homeRow,
          ...GujaratiKeyboardLessons.homeRowMatras,
          ...GujaratiKeyboardLessons.bottomRow,
        ];
      case 'Top & Bottom Row':
        return [
          ...GujaratiKeyboardLessons.topRow,
          ...GujaratiKeyboardLessons.topRowMatras,
          ...GujaratiKeyboardLessons.bottomRow,
        ];
      case 'Vowels & Matras':
        return GujaratiKeyboardLessons.vowelsAndMatras;
      case 'Home & Top Row & Bottom':
        return GujaratiKeyboardLessons.fullSet;
      default:
        return GujaratiKeyboardLessons.homeRow;
    }
  }

  /// Get practice string for a lesson
  static String getPracticeString(String languageCode, String lessonType) {
    switch (languageCode) {
      case 'hi':
        return HindiKeyboardLessons.practiceStrings[lessonType] ?? '';
      case 'gu':
        return GujaratiKeyboardLessons.practiceStrings[lessonType] ?? '';
      default:
        return '';
    }
  }
}

// =============================================================================
// JSON EXPORT FORMAT (for reference/documentation)
// =============================================================================
/*
{
  "hi": {
    "homeRow": ["प", "र", "क", "त", "च", "ट", "्", "ो", "े", "ि", "ु"],
    "topRow": ["ब", "ह", "ग", "द", "ज", "ड", "ौ", "ै", "ा", "ी", "ू", "ॉ", "़"],
    "bottomRow": ["म", "न", "व", "ल", "स", "य", "ं", ",", "."],
    "vowelsAndMatras": ["ा", "ि", "ी", "ु", "ू", "े", "ै", "ो", "ौ", "ॉ", "्", "ं", "ः", "ॅ"],
    "fullSet": ["प", "र", "क", "त", "च", "ट", "्", "ो", "े", "ि", "ु", "ब", "ह", "ग", "द", "ज", "ड", "ौ", "ै", "ा", "ी", "ू", "ॉ", "़", "म", "न", "व", "ल", "स", "य", "ं", ",", "."]
  },
  "gu": {
    "homeRow": ["પ", "ર", "ક", "ત", "ચ", "ટ", "્", "ો", "ે", "િ", "ુ"],
    "topRow": ["બ", "હ", "ગ", "દ", "જ", "ડ", "ૌ", "ૈ", "ા", "ી", "ૂ", "ૉ", "઼"],
    "bottomRow": ["મ", "ન", "વ", "લ", "સ", "ય", "ં", ",", "."],
    "vowelsAndMatras": ["ા", "િ", "ી", "ુ", "ૂ", "ે", "ૈ", "ો", "ૌ", "ૉ", "્", "ં", "ઃ"],
    "fullSet": ["પ", "ર", "ક", "ત", "ચ", "ટ", "્", "ો", "ે", "િ", "ુ", "બ", "હ", "ગ", "દ", "જ", "ડ", "ૌ", "ૈ", "ા", "ી", "ૂ", "ૉ", "઼", "મ", "ન", "વ", "લ", "સ", "ય", "ં", ",", "."]
  }
}
*/
