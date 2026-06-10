// =============================================================================
// 📚 PRACTICE CONTENT — Centralized word / sentence / paragraph datasets
// =============================================================================
//
// HOW TO ADD CONTENT
// ------------------
// 1. Find the section for your language (English / Hindi / Gujarati).
// 2. Add entries to the appropriate list:
//      PracticeContent.english.words.easy      ← easy English words
//      PracticeContent.hindi.sentences.medium  ← medium Hindi sentences
//      PracticeContent.gujarati.paragraphs.hard
// 3. That's it. The app picks up the new content automatically.
//
// API INTEGRATION
// ---------------
// When you are ready to fetch content from an API, implement
// PracticeContentRepository and inject it wherever PracticeContent is used.
// The rest of the app does not need to change.
//
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// A single practice item (word, sentence, or paragraph).
class PracticeItem {
  final String text;
  final String languageCode; // 'en' | 'hi' | 'gu'
  final PracticeType type;
  final PracticeDifficulty difficulty;
  /// Optional: id for API round-trip / deduplication.
  final String? id;

  const PracticeItem({
    required this.text,
    required this.languageCode,
    required this.type,
    required this.difficulty,
    this.id,
  });

  @override
  String toString() => 'PracticeItem($languageCode/$type/$difficulty: "$text")';
}

enum PracticeType { word, sentence, paragraph }

enum PracticeDifficulty { easy, medium, hard }

/// Grouped bucket: all items for one type × difficulty combination.
class _Bucket {
  final List<PracticeItem> easy;
  final List<PracticeItem> medium;
  final List<PracticeItem> hard;

  const _Bucket({
    required this.easy,
    required this.medium,
    required this.hard,
  });

  List<PracticeItem> forDifficulty(PracticeDifficulty d) {
    switch (d) {
      case PracticeDifficulty.easy:   return easy;
      case PracticeDifficulty.medium: return medium;
      case PracticeDifficulty.hard:   return hard;
    }
  }
}

/// All content for one language.
class LanguageContent {
  final String languageCode;
  final _Bucket words;
  final _Bucket sentences;
  final _Bucket paragraphs;

  const LanguageContent({
    required this.languageCode,
    required this.words,
    required this.sentences,
    required this.paragraphs,
  });

  /// Fetch items by type + difficulty.
  List<PracticeItem> get({
    required PracticeType type,
    required PracticeDifficulty difficulty,
  }) {
    switch (type) {
      case PracticeType.word:      return words.forDifficulty(difficulty);
      case PracticeType.sentence:  return sentences.forDifficulty(difficulty);
      case PracticeType.paragraph: return paragraphs.forDifficulty(difficulty);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER — build PracticeItem quickly
// ─────────────────────────────────────────────────────────────────────────────

PracticeItem _w(String text, String lang, PracticeDifficulty d) =>
    PracticeItem(text: text, languageCode: lang, type: PracticeType.word, difficulty: d);

PracticeItem _s(String text, String lang, PracticeDifficulty d) =>
    PracticeItem(text: text, languageCode: lang, type: PracticeType.sentence, difficulty: d);

PracticeItem _p(String text, String lang, PracticeDifficulty d) =>
    PracticeItem(text: text, languageCode: lang, type: PracticeType.paragraph, difficulty: d);

// ─────────────────────────────────────────────────────────────────────────────
// ENGLISH CONTENT
// ─────────────────────────────────────────────────────────────────────────────

const _enWords = _Bucket(
  easy: [
    PracticeItem(text: 'cat',   languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'dog',   languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'tree',  languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'home',  languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'fish',  languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'bird',  languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'rain',  languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'sun',   languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
  ],
  medium: [
    PracticeItem(text: 'keyboard',    languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'programming', languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'laptop',      languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'network',     languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'software',    languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'database',    languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
  ],
  hard: [
    PracticeItem(text: 'algorithm',       languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'synchronization', languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'abstraction',     languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'polymorphism',    languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'encapsulation',   languageCode: 'en', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
  ],
);

const _enSentences = _Bucket(
  easy: [
    PracticeItem(text: 'The cat runs fast.',       languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'A dog barks loudly.',      languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'The sun is bright.',       languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'She reads every day.',     languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'He drinks cold water.',    languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
  ],
  medium: [
    PracticeItem(text: 'Quick foxes climb steep hills.',         languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'The programmer types code daily.',       languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'Practice makes a man perfect.',          languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'Learning to type fast takes effort.',    languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'Every keystroke counts in a typing test.', languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
  ],
  hard: [
    PracticeItem(text: 'Complex algorithms require careful planning and execution.',   languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'Synchronization issues can cause unpredictable errors.',       languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'Object-oriented programming emphasizes encapsulation and abstraction.', languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'Efficient data structures underpin every scalable application.', languageCode: 'en', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
  ],
);

const _enParagraphs = _Bucket(
  easy: [
    PracticeItem(
      text: 'The quick brown fox jumps over the lazy dog. This sentence uses every letter of the alphabet. It is often used to practice typing.',
      languageCode: 'en', type: PracticeType.paragraph, difficulty: PracticeDifficulty.easy,
    ),
    PracticeItem(
      text: 'A bright sun rose over the hills. Birds sang in the tall green trees. Children played happily in the cool morning air.',
      languageCode: 'en', type: PracticeType.paragraph, difficulty: PracticeDifficulty.easy,
    ),
  ],
  medium: [
    PracticeItem(
      text: 'Typing improves with consistent daily practice. Focus on accuracy before speed. Sit upright and keep your wrists relaxed. Take short breaks to avoid fatigue.',
      languageCode: 'en', type: PracticeType.paragraph, difficulty: PracticeDifficulty.medium,
    ),
    PracticeItem(
      text: 'Technology changes rapidly and professionals must adapt. Learning new tools is not optional but essential. Regular reading and hands-on projects keep skills sharp.',
      languageCode: 'en', type: PracticeType.paragraph, difficulty: PracticeDifficulty.medium,
    ),
  ],
  hard: [
    PracticeItem(
      text: 'Developing robust software requires careful attention to edge cases and failure modes. Programmers must balance efficiency, readability, and maintainability. Complex distributed systems demand rigorous testing and monitoring at every layer.',
      languageCode: 'en', type: PracticeType.paragraph, difficulty: PracticeDifficulty.hard,
    ),
    PracticeItem(
      text: 'Asynchronous programming models allow applications to handle many concurrent requests without blocking the main thread. Understanding event loops, futures, and streams is critical for building scalable services. Profiling tools help identify bottlenecks and guide targeted optimization efforts.',
      languageCode: 'en', type: PracticeType.paragraph, difficulty: PracticeDifficulty.hard,
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// HINDI CONTENT
// ─────────────────────────────────────────────────────────────────────────────

const _hiWords = _Bucket(
  easy: [
    PracticeItem(text: 'कर',   languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'पर',   languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'तर',   languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'रकत',  languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'करत',  languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'पकड़', languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
  ],
  medium: [
    PracticeItem(text: 'घर',       languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'जल',       languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'बाग',      languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'किताब',    languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'कंप्यूटर', languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'नमस्ते',   languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
  ],
  hard: [
    PracticeItem(text: 'अनुप्रयोग',    languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'विश्वविद्यालय', languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'प्रौद्योगिकी',  languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'महत्वपूर्ण',    languageCode: 'hi', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
  ],
);

const _hiSentences = _Bucket(
  easy: [
    PracticeItem(text: 'मेरा नाम राम है।',      languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'आज मौसम अच्छा है।',     languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'यह एक पेड़ है।',         languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'नल से पानी आता है।',    languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'बच्चे खेलते हैं।',      languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
  ],
  medium: [
    PracticeItem(text: 'भारत एक विशाल देश है।',             languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'गंगा हमारी पवित्र नदी है।',         languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'हर दिन व्यायाम करना चाहिए।',        languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'पढ़ाई से ज्ञान मिलता है।',           languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'सच बोलना सबसे बड़ी ताकत है।',       languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
  ],
  hard: [
    PracticeItem(text: 'हिंदी हमारी राष्ट्रभाषा है।',         languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'प्रौद्योगिकी विकास महत्वपूर्ण है।',   languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'नमस्ते धन्यवाद कृपया माफ कीजिए।',    languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'विज्ञान और तकनीक ने जीवन बदल दिया है।', languageCode: 'hi', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
  ],
);

const _hiParagraphs = _Bucket(
  easy: [
    PracticeItem(
      text: 'भारत एक महान देश है। यहाँ अनेक भाषाएँ बोली जाती हैं। हिंदी सबसे अधिक बोली जाने वाली भाषा है।',
      languageCode: 'hi', type: PracticeType.paragraph, difficulty: PracticeDifficulty.easy,
    ),
    PracticeItem(
      text: 'सूरज पूरब में उगता है। पक्षी गाने गाते हैं। बच्चे खुशी से खेलते हैं। दिन सुंदर और उजला होता है।',
      languageCode: 'hi', type: PracticeType.paragraph, difficulty: PracticeDifficulty.easy,
    ),
  ],
  medium: [
    PracticeItem(
      text: 'स्वस्थ शरीर में स्वस्थ मन निवास करता है। नियमित व्यायाम और संतुलित आहार स्वस्थ जीवन की कुंजी है। हर दिन कम से कम आधा घंटा चलना चाहिए।',
      languageCode: 'hi', type: PracticeType.paragraph, difficulty: PracticeDifficulty.medium,
    ),
    PracticeItem(
      text: 'टाइपिंग एक महत्वपूर्ण कौशल है। नियमित अभ्यास से गति और सटीकता दोनों बढ़ती हैं। सही उँगलियों की स्थिति से थकान कम होती है।',
      languageCode: 'hi', type: PracticeType.paragraph, difficulty: PracticeDifficulty.medium,
    ),
  ],
  hard: [
    PracticeItem(
      text: 'प्रौद्योगिकी विकास महत्वपूर्ण है। इससे रोजगार मिलता है और देश की अर्थव्यवस्था मजबूत होती है। कंप्यूटर और इंटरनेट ने शिक्षा को सबके लिए सुलभ बनाया है। डिजिटल साक्षरता आज की सबसे बड़ी जरूरत है।',
      languageCode: 'hi', type: PracticeType.paragraph, difficulty: PracticeDifficulty.hard,
    ),
    PracticeItem(
      text: 'भारतीय संविधान विश्व का सबसे बड़ा लिखित संविधान है। इसमें नागरिकों के मूल अधिकार और कर्तव्य स्पष्ट रूप से परिभाषित हैं। लोकतंत्र, समाजवाद और धर्मनिरपेक्षता इसके मूल सिद्धांत हैं।',
      languageCode: 'hi', type: PracticeType.paragraph, difficulty: PracticeDifficulty.hard,
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// GUJARATI CONTENT
// ─────────────────────────────────────────────────────────────────────────────

const _guWords = _Bucket(
  easy: [
    PracticeItem(text: 'કર',   languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'પર',   languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'તર',   languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'રકત',  languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'કરત',  languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'પકડ',  languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.easy),
  ],
  medium: [
    PracticeItem(text: 'ઘર',       languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'જળ',       languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'બાગ',      languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'પુસ્તક',   languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'કમ્પ્યુટર', languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'નમસ્તે',   languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.medium),
  ],
  hard: [
    PracticeItem(text: 'ઉપયોગ',         languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'વિશ્વવિદ્યાલય', languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'ઉદ્યોગ',         languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'મહત્વપૂર્ણ',     languageCode: 'gu', type: PracticeType.word, difficulty: PracticeDifficulty.hard),
  ],
);

const _guSentences = _Bucket(
  easy: [
    PracticeItem(text: 'મારું નામ રામ છે।',     languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'આજે હવામાન સારું છે।',  languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'આ એક ઝાડ છે।',          languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'નળમાંથી પાણી આવે છે।',  languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
    PracticeItem(text: 'બાળકો રમે છે।',          languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.easy),
  ],
  medium: [
    PracticeItem(text: 'ગુજરાત એક સુંદર રાજ્ય છે।',       languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'સાબરમતી નદી ગુજરાતમાં વહે છે।',    languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'દરરોજ કસરત કરવી જોઈએ।',            languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'ભણવાથી જ્ઞાન મળે છે।',              languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
    PracticeItem(text: 'સત્ય બોલવું સૌથી મોટી શક્તિ છે।',  languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.medium),
  ],
  hard: [
    PracticeItem(text: 'ગુજરાતી અમારી માતૃભાષા છે।',       languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'ઉદ્યોગ વિકાસ મહત્વપૂર્ણ છે।',       languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'નમસ્તે ધન્યવાદ કૃપા કરો।',           languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
    PracticeItem(text: 'વિજ્ઞાન અને ટેકનોલોજીએ જીવન બદલ્યું છે।', languageCode: 'gu', type: PracticeType.sentence, difficulty: PracticeDifficulty.hard),
  ],
);

const _guParagraphs = _Bucket(
  easy: [
    PracticeItem(
      text: 'ગુજરાત એક સુંદર રાજ્ય છે। અહીં ઘણા લોકો ગુજરાતી બોલે છે। ગુજરાતી એક પ્રાચીન ભાષા છે।',
      languageCode: 'gu', type: PracticeType.paragraph, difficulty: PracticeDifficulty.easy,
    ),
    PracticeItem(
      text: 'સૂરજ પૂર્વ દિશામાં ઉગે છે। પક્ષીઓ ગીત ગાય છે। બાળકો ખુશીથી રમે છે। દિવસ સુંદર અને ઉજળો હોય છે।',
      languageCode: 'gu', type: PracticeType.paragraph, difficulty: PracticeDifficulty.easy,
    ),
  ],
  medium: [
    PracticeItem(
      text: 'તંદુરસ્ત શરીરમાં તંદુરસ્ત મન વસે છે। નિયમિત કસરત અને સંતુલિત આહાર તંદુરસ્ત જીવનની ચાવી છે। દરરોજ ઓછામાં ઓછી અડધો કલાક ચાલવું જોઈએ।',
      languageCode: 'gu', type: PracticeType.paragraph, difficulty: PracticeDifficulty.medium,
    ),
    PracticeItem(
      text: 'ટાઇપિંગ એ એક મહત્વનું કૌશલ છે। નિયમિત અભ્યાસથી ઝડપ અને ચોકસાઈ બંને વધે છે। સાચી આંગળીઓની સ્થિતિ થાક ઘટાડે છે।',
      languageCode: 'gu', type: PracticeType.paragraph, difficulty: PracticeDifficulty.medium,
    ),
  ],
  hard: [
    PracticeItem(
      text: 'ઉદ્યોગ વિકાસ મહત્વપૂર્ણ છે। તેનાથી રોજગારી મળે છે અને દેશની અર્થવ્યવસ્થા મજબૂત થાય છે। કમ્પ્યુટર અને ઈન્ટરનેટે શિક્ષણને સૌ માટે સુલભ બનાવ્યું છે। ડિજિટલ સાક્ષરતા આજની સૌથી મોટી જરૂરિયાત છે।',
      languageCode: 'gu', type: PracticeType.paragraph, difficulty: PracticeDifficulty.hard,
    ),
    PracticeItem(
      text: 'ભારતીય બંધારણ વિશ્વનું સૌથી મોટું લેખિત બંધારણ છે। તેમાં નાગરિકોના મૂળ અધિકારો અને ફરજો સ્પષ્ટ રીતે વ્યાખ્યાયિત છે। લોકશાહી, સમાજવાદ અને બિનસાંપ્રદાયિકતા તેના મૂળ સિદ્ધાંતો છે।',
      languageCode: 'gu', type: PracticeType.paragraph, difficulty: PracticeDifficulty.hard,
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC API
// ─────────────────────────────────────────────────────────────────────────────

/// Central access point for all practice content.
///
/// Usage:
///   PracticeContent.english.get(type: PracticeType.word, difficulty: PracticeDifficulty.easy)
///   PracticeContent.forLanguage('hi').get(type: PracticeType.sentence, difficulty: PracticeDifficulty.medium)
///   PracticeContent.all(languageCode: 'en', type: PracticeType.paragraph)
class PracticeContent {
  PracticeContent._();

  static const LanguageContent english = LanguageContent(
    languageCode: 'en',
    words:      _enWords,
    sentences:  _enSentences,
    paragraphs: _enParagraphs,
  );

  static const LanguageContent hindi = LanguageContent(
    languageCode: 'hi',
    words:      _hiWords,
    sentences:  _hiSentences,
    paragraphs: _hiParagraphs,
  );

  static const LanguageContent gujarati = LanguageContent(
    languageCode: 'gu',
    words:      _guWords,
    sentences:  _guSentences,
    paragraphs: _guParagraphs,
  );

  /// Get content by language code.
  static LanguageContent forLanguage(String code) {
    switch (code) {
      case 'hi': return hindi;
      case 'gu': return gujarati;
      default:   return english;
    }
  }

  /// Convenience: get a flat list by language + type (all difficulties).
  static List<PracticeItem> all({
    required String languageCode,
    required PracticeType type,
  }) {
    final lang = forLanguage(languageCode);
    return [
      ...lang.get(type: type, difficulty: PracticeDifficulty.easy),
      ...lang.get(type: type, difficulty: PracticeDifficulty.medium),
      ...lang.get(type: type, difficulty: PracticeDifficulty.hard),
    ];
  }

  /// Get the first item for a given language/type/difficulty (for quick access).
  static PracticeItem? first({
    required String languageCode,
    required PracticeType type,
    required PracticeDifficulty difficulty,
  }) {
    final items = forLanguage(languageCode).get(type: type, difficulty: difficulty);
    return items.isNotEmpty ? items.first : null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API INTEGRATION LAYER (wire up when backend is ready)
// ─────────────────────────────────────────────────────────────────────────────

/// Contract that any data source must fulfil.
/// Swap implementations without touching the rest of the app.
abstract class PracticeContentRepository {
  /// Fetch items — may return cached data, local data, or network data.
  Future<List<PracticeItem>> fetch({
    required String languageCode,
    required PracticeType type,
    required PracticeDifficulty difficulty,
  });
}

/// Local-only implementation (default, no network needed).
class LocalPracticeContentRepository implements PracticeContentRepository {
  const LocalPracticeContentRepository();

  @override
  Future<List<PracticeItem>> fetch({
    required String languageCode,
    required PracticeType type,
    required PracticeDifficulty difficulty,
  }) async {
    return PracticeContent.forLanguage(languageCode)
        .get(type: type, difficulty: difficulty);
  }
}

/// API-backed implementation — fill in the URL and model when ready.
///
/// Steps to activate:
/// 1. Implement the `fetch` method below using `http` or `dio`.
/// 2. In your DI setup, replace `LocalPracticeContentRepository` with this.
/// 3. The practice screen uses `PracticeContentRepository` — it will
///    automatically use network data with zero other changes.
///
class ApiPracticeContentRepository implements PracticeContentRepository {
  final String baseUrl;

  const ApiPracticeContentRepository({required this.baseUrl});

  @override
  Future<List<PracticeItem>> fetch({
    required String languageCode,
    required PracticeType type,
    required PracticeDifficulty difficulty,
  }) async {
    // TODO: Implement when API is ready.
    //
    // Example (using http package):
    //   final uri = Uri.parse(
    //     '$baseUrl/practice'
    //     '?lang=$languageCode'
    //     '&type=${type.name}'
    //     '&difficulty=${difficulty.name}',
    //   );
    //   final response = await http.get(uri);
    //   if (response.statusCode == 200) {
    //     final List<dynamic> json = jsonDecode(response.body);
    //     return json.map((e) => PracticeItem(
    //       id:           e['id'],
    //       text:         e['text'],
    //       languageCode: e['languageCode'],
    //       type:         PracticeType.values.byName(e['type']),
    //       difficulty:   PracticeDifficulty.values.byName(e['difficulty']),
    //     )).toList();
    //   }
    //   throw Exception('Failed to fetch practice content: ${response.statusCode}');

    // Fallback to local data until API is ready:
    return const LocalPracticeContentRepository().fetch(
      languageCode: languageCode,
      type: type,
      difficulty: difficulty,
    );
  }
}
