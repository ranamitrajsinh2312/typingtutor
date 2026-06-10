// =========================================================================
// 🌐 LANGUAGE CONFIG — Centralized multi-language configuration
// =========================================================================

class LanguageMeta {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;
  final bool isIndic;
  final String fontFamily;

  const LanguageMeta({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
    required this.isIndic,
    required this.fontFamily,
  });
}

class LanguageConfig {
  LanguageConfig._();

  static const LanguageMeta english = LanguageMeta(
    code: 'en', name: 'English', nativeName: 'English',
    flagEmoji: '🇺🇸', isIndic: false, fontFamily: '',
  );
  static const LanguageMeta hindi = LanguageMeta(
    code: 'hi', name: 'Hindi', nativeName: 'हिन्दी',
    flagEmoji: '🇮🇳', isIndic: true, fontFamily: 'Noto Sans Devanagari',
  );
  static const LanguageMeta gujarati = LanguageMeta(
    code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી',
    flagEmoji: '🇮🇳', isIndic: true, fontFamily: 'Noto Sans Gujarati',
  );

  static const List<LanguageMeta> all = [english, hindi, gujarati];
  static const List<String> codes = ['en', 'hi', 'gu'];

  static LanguageMeta of(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => english);

  static bool isSupported(String code) => codes.contains(code);
  static bool isIndic(String code) => of(code).isIndic;
  static bool requiresAtomicSplit(String code) => isIndic(code);
  static String nativeName(String code) => of(code).nativeName;
  static String displayName(String code) => of(code).name;
  static String flag(String code) => of(code).flagEmoji;
  static String? fontFamily(String code) {
    final f = of(code).fontFamily;
    return f.isEmpty ? null : f;
  }
  static String normalise(String? code) =>
      (code != null && isSupported(code)) ? code : 'en';
}
