// =========================================================================
// 🌍 KEYBOARD LAYOUTS DATA - MULTILINGUAL KEYBOARD MAPPINGS
// =========================================================================

import 'package:typingtutor/models/keyboard_layout.dart';

/// Repository of all supported keyboard layouts
class KeyboardLayouts {
  // =========================================================================
  // 🇺🇸 ENGLISH (QWERTY) LAYOUT
  // =========================================================================

  /// English QWERTY keyboard layout
  static const KeyboardLayout english = KeyboardLayout(
    languageCode: 'en',
    languageName: 'English',
    hasShiftVariant: true,
    isRightToLeft: false,
    rows: [
      // Row 1 (Top row - Number row with special chars)
      ['TAB', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\\'],
      // Row 2 (Home row)
      ['CAPS', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\'', 'ENTER'],
      // Row 3 (Bottom row)
      ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'SHIFT'],
      // Row 4 (Space row)
      ['SPACE'],
    ],
    shiftRows: [
      // Shift Row 1
      ['TAB', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '|'],
      // Shift Row 2
      ['CAPS', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', 'ENTER'],
      // Shift Row 3
      ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 'SHIFT'],
    ],
  );

  /// Simplified English layout for typing practice
  static const KeyboardLayout englishSimple = KeyboardLayout(
    languageCode: 'en',
    languageName: 'English',
    hasShiftVariant: true,
    isRightToLeft: false,
    rows: [
      // Row 1 (Top row)
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      // Row 2 (Home row)
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      // Row 3 (Bottom row)
      ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
      // Row 4 (Space row)
      ['SPACE'],
    ],
    shiftRows: [
      // Uppercase Row 1
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      // Uppercase Row 2
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      // Uppercase Row 3
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ],
  );

  // =========================================================================
  // 🇮🇳 HINDI (DEVANAGARI INSCRIPT) LAYOUT - COMPLETE
  // =========================================================================

  /// Hindi Devanagari Inscript keyboard layout - Complete with all characters
  static const KeyboardLayout hindi = KeyboardLayout(
    languageCode: 'hi',
    languageName: 'हिंदी',
    hasShiftVariant: true,
    isRightToLeft: false,
    rows: [
      // Row 1 (Number row with Devanagari digits + ृ matra)
      ['१', '२', '३', '४', '५', '६', '७', '८', '९', '०', '-', 'ृ', 'ॅ', 'ॉ'],
      // Row 2 (Top row - Vowel marks/matras + consonants)
      ['ौ', 'ै', 'ा', 'ी', 'ू', 'ब', 'ह', 'ग', 'द', 'ज', 'ड', '़', '\\'],
      // Row 3 (Home row - Main consonants + halant)
      ['ो', 'े', '्', 'ि', 'ु', 'प', 'र', 'क', 'त', 'च', 'ट', 'ं'],
      // Row 4 (Bottom row - More consonants + punctuation)
      ['ः', 'ँ', 'म', 'न', 'व', 'ल', 'स', ',', '.', 'य', '?'],
      // Row 5 (Space row)
      ['SPACE'],
    ],
    shiftRows: [
      // Shift Row 1 (Punctuation + ॄ matra + symbols)
      ['!', '@', '॒', '॑', '₹', '^', '&', '*', '(', ')', '_', 'ॄ', 'ऍ', 'ऑ'],
      // Shift Row 2 (Full/Independent vowels + aspirated consonants)
      ['औ', 'ऐ', 'आ', 'ई', 'ऊ', 'भ', 'ङ', 'घ', 'ध', 'झ', 'ढ', 'ञ', '|'],
      // Shift Row 3 (Independent vowels + more aspirated consonants)
      ['ओ', 'ए', 'अ', 'इ', 'उ', 'फ', 'ऱ', 'ख', 'थ', 'छ', 'ठ', '॰'],
      // Shift Row 4 (Additional characters + conjuncts + danda)
      ['ऋ', 'ॠ', 'ष', 'श', 'ण', 'ळ', 'ऽ', 'श्र', '।', '॥', '/'],
    ],
    // Additional characters accessible via special keys
    nuktaVariants: [
      'क़', // qa
      'ख़', // kha
      'ग़', // gha
      'ज़', // za
      'ड़', // dda
      'ढ़', // ddha
      'फ़', // fa
      'य़', // yya
      'ऱ', // rra
      'ऴ', // llla
    ],
    matras: [
      'ा', // aa matra
      'ि', // i matra
      'ी', // ii matra
      'ु', // u matra
      'ू', // uu matra
      'ृ', // ri matra
      'ॄ', // rii matra
      'े', // e matra
      'ै', // ai matra
      'ो', // o matra
      'ौ', // au matra
      'ं', // anusvara
      'ः', // visarga
      '्', // halant/virama
      'ँ', // chandrabindu
      'ॅ', // candra e
      'ॉ', // candra o
      '़', // nukta
    ],
    vowels: [
      'अ', // a
      'आ', // aa
      'इ', // i
      'ई', // ii
      'उ', // u
      'ऊ', // uu
      'ऋ', // ri
      'ॠ', // rii
      'ऌ', // li
      'ॡ', // lii
      'ए', // e
      'ऐ', // ai
      'ओ', // o
      'औ', // au
      'ऍ', // candra e
      'ऑ', // candra o
    ],
    consonants: [
      // Velar (कवर्ग)
      'क', 'ख', 'ग', 'घ', 'ङ',
      // Palatal (चवर्ग)
      'च', 'छ', 'ज', 'झ', 'ञ',
      // Retroflex (टवर्ग)
      'ट', 'ठ', 'ड', 'ढ', 'ण',
      // Dental (तवर्ग)
      'त', 'थ', 'द', 'ध', 'न',
      // Labial (पवर्ग)
      'प', 'फ', 'ब', 'भ', 'म',
      // Semivowels (अन्तस्थ)
      'य', 'र', 'ल', 'व',
      // Sibilants (ऊष्म)
      'श', 'ष', 'स', 'ह',
      // Additional
      'ळ', 'क्ष', 'ज्ञ',
    ],
    conjuncts: [
      'क्ष', // ksha
      'त्र', // tra
      'ज्ञ', // gya/dnya
      'श्र', // shra
      'द्य', // dya
      'द्ध', // ddha
      'द्व', // dva
      'क्र', // kra
      'प्र', // pra
      'भ्र', // bhra
      'श्च', // shcha
      'ष्ट', // shta
      'ष्ठ', // shtha
      'ड्ड', // dda
      'ट्ट', // tta
      'ण्ड', // nda
      'ण्ढ', // ndha
      'न्न', // nna
      'ल्ल', // lla
      'त्त', // tta
      'क्क', // kka
      'च्च', // ccha
      'ज्ज', // jja
      'ट्ठ', // ttha
      'द्द', // dda
      'प्प', // ppa
      'म्म', // mma
      'य्य', // yya
      'र्र', // rra
      'ल्ल', // lla
      'व्व', // vva
      'स्स', // ssa
      'ह्न', // hna
      'ह्म', // hma
      'ह्य', // hya
      'ह्र', // hra
      'ह्ल', // hla
      'ह्व', // hva
    ],
    numbers: ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'],
    punctuation: [',', '.', '?', '!', '।', '॥', '-', '॰', '₹', '/', '\\', '|'],
  );

  /// Hindi typing practice layout (comprehensive for lessons)
  static const KeyboardLayout hindiPractice = KeyboardLayout(
    languageCode: 'hi',
    languageName: 'हिंदी',
    hasShiftVariant: true,
    isRightToLeft: false,
    rows: [
      // Row 1: Vowels (स्वर) - All independent vowels
      ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ऋ', 'ए', 'ऐ', 'ओ', 'औ', 'ऑ'],
      // Row 2: Consonants Row 1 (क-वर्ग to च-वर्ग)
      ['क', 'ख', 'ग', 'घ', 'ङ', 'च', 'छ', 'ज', 'झ', 'ञ'],
      // Row 3: Consonants Row 2 (ट-वर्ग to त-वर्ग)
      ['ट', 'ठ', 'ड', 'ढ', 'ण', 'त', 'थ', 'द', 'ध', 'न'],
      // Row 4: Consonants Row 3 (प-वर्ग + अन्तस्थ + ऊष्म)
      ['प', 'फ', 'ब', 'भ', 'म', 'य', 'र', 'ल', 'व', 'श', 'ष', 'स', 'ह'],
      // Row 5: Matras and signs
      ['ा', 'ि', 'ी', 'ु', 'ू', 'ृ', 'े', 'ै', 'ो', 'ौ', '्', 'ं', 'ः'],
      // Row 6: Numbers and Space
      ['१', '२', '३', '४', '५', '६', '७', '८', '९', '०', 'SPACE'],
    ],
    shiftRows: [
      // Shift Row 1: Extended vowels
      ['ॠ', 'ऌ', 'ॡ', 'ऍ', 'ॅ', 'ॉ', 'ँ', '॰', '।', '॥', '₹', 'ऽ'],
      // Shift Row 2: Nukta variants
      ['क़', 'ख़', 'ग़', 'ज़', 'ड़', 'ढ़', 'फ़', 'य़', 'ऱ', 'ऴ'],
      // Shift Row 3: Common conjuncts (Row 1)
      ['क्ष', 'त्र', 'ज्ञ', 'श्र', 'क्र', 'प्र', 'भ्र', 'द्व', 'द्य', 'द्ध'],
      // Shift Row 4: More conjuncts
      [
        'ष्ट',
        'ष्ठ',
        'न्न',
        'ल्ल',
        'त्त',
        'क्क',
        'च्च',
        'ज्ज',
        'द्द',
        'म्म',
        'स्स',
        'ह्म',
        'ह्न',
      ],
      // Shift Row 5: Rare matras and vedic
      ['ॄ', '॒', '॑', 'ॢ', 'ॣ', '॔', '॓', 'ॱ', '।', '॥', ':', ';', '?'],
      // Shift Row 6: Symbols
      ['!', '@', '#', r'$', '%', '^', '&', '*', '(', ')', '-'],
    ],
    matras: [
      'ा',
      'ि',
      'ी',
      'ु',
      'ू',
      'ृ',
      'ॄ',
      'े',
      'ै',
      'ो',
      'ौ',
      'ं',
      'ः',
      '्',
      'ँ',
      'ॅ',
      'ॉ',
      '़',
    ],
    vowels: [
      'अ',
      'आ',
      'इ',
      'ई',
      'उ',
      'ऊ',
      'ऋ',
      'ॠ',
      'ऌ',
      'ॡ',
      'ए',
      'ऐ',
      'ओ',
      'औ',
      'ऍ',
      'ऑ',
    ],
    consonants: [
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
      'ळ',
    ],
    nuktaVariants: ['क़', 'ख़', 'ग़', 'ज़', 'ड़', 'ढ़', 'फ़', 'य़', 'ऱ', 'ऴ'],
    conjuncts: [
      'क्ष',
      'त्र',
      'ज्ञ',
      'श्र',
      'क्र',
      'प्र',
      'भ्र',
      'द्व',
      'द्य',
      'द्ध',
    ],
    numbers: ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'],
    punctuation: [',', '.', '?', '!', '।', '॥', '-', '॰', '₹'],
  );

  // =========================================================================
  // 🇮🇳 GUJARATI (INSCRIPT) LAYOUT - COMPLETE
  // =========================================================================

  /// Gujarati Inscript keyboard layout - Complete with all characters
  static const KeyboardLayout gujarati = KeyboardLayout(
    languageCode: 'gu',
    languageName: 'ગુજરાતી',
    hasShiftVariant: true,
    isRightToLeft: false,
    rows: [
      // Row 1 (Number row with Gujarati digits + ૃ matra)
      ['૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯', '૦', '-', 'ૃ', 'ૅ', 'ૉ'],
      // Row 2 (Top row - Vowel marks/matras + consonants)
      ['ૌ', 'ૈ', 'ા', 'ી', 'ૂ', 'બ', 'હ', 'ગ', 'દ', 'જ', 'ડ', '઼', '\\'],
      // Row 3 (Home row - Main consonants + halant)
      ['ો', 'ે', '્', 'િ', 'ુ', 'પ', 'ર', 'ક', 'ત', 'ચ', 'ટ'],
      // Row 4 (Bottom row - z=ૅ, x=ં, then consonants + punctuation)
      ['ૅ', 'ં', 'મ', 'ન', 'વ', 'લ', 'સ', ',', '.', 'ય'],
      // Row 5 (Space row)
      ['SPACE'],
    ],
    shiftRows: [
      // Shift Row 1 (Punctuation + ૄ matra + symbols)
      ['!', '@', '#', r'$', '₹', '^', '&', '*', '(', ')', '_', 'ૄ', 'ઍ', 'ઑ'],
      // Shift Row 2 (Full/Independent vowels + aspirated consonants)
      ['ઔ', 'ઐ', 'આ', 'ઈ', 'ઊ', 'ભ', 'ઙ', 'ઘ', 'ધ', 'ઝ', 'ઢ', 'ઞ', '|'],
      // Shift Row 3 (Independent vowels + more aspirated consonants)
      ['ઓ', 'એ', 'અ', 'ઇ', 'ઉ', 'ફ', 'ર', 'ખ', 'થ', 'છ', 'ઠ', '૰'],
      // Shift Row 4 (Additional characters + conjuncts + danda)
      ['ઋ', 'ૠ', 'ષ', 'શ', 'ણ', 'ળ', 'ઽ', 'શ્ર', '।', '॥', '/'],
    ],
    // Additional characters
    nuktaVariants: [
      'ક઼', // qa
      'ખ઼', // kha
      'ગ઼', // gha
      'જ઼', // za
      'ફ઼', // fa
      'ર઼', // rra (with nukta)
    ],
    matras: [
      'ા', // aa matra
      'િ', // i matra
      'ી', // ii matra
      'ુ', // u matra
      'ૂ', // uu matra
      'ૃ', // ri matra
      'ૄ', // rii matra
      'ે', // e matra
      'ૈ', // ai matra
      'ો', // o matra
      'ૌ', // au matra
      'ં', // anusvara
      'ઃ', // visarga
      '્', // halant/virama
      'ઁ', // chandrabindu
      'ૅ', // candra e
      'ૉ', // candra o
      '઼', // nukta
    ],
    vowels: [
      'અ', // a
      'આ', // aa
      'ઇ', // i
      'ઈ', // ii
      'ઉ', // u
      'ઊ', // uu
      'ઋ', // ri
      'ૠ', // rii
      'ઌ', // li
      'ૡ', // lii
      'એ', // e
      'ઐ', // ai
      'ઓ', // o
      'ઔ', // au
      'ઍ', // candra e
      'ઑ', // candra o
    ],
    consonants: [
      // Velar (કવર્ગ)
      'ક', 'ખ', 'ગ', 'ઘ', 'ઙ',
      // Palatal (ચવર્ગ)
      'ચ', 'છ', 'જ', 'ઝ', 'ઞ',
      // Retroflex (ટવર્ગ)
      'ટ', 'ઠ', 'ડ', 'ઢ', 'ણ',
      // Dental (તવર્ગ)
      'ત', 'થ', 'દ', 'ધ', 'ન',
      // Labial (પવર્ગ)
      'પ', 'ફ', 'બ', 'ભ', 'મ',
      // Semivowels
      'ય', 'ર', 'લ', 'વ',
      // Sibilants
      'શ', 'ષ', 'સ', 'હ',
      // Additional
      'ળ', 'ક્ષ', 'જ્ઞ',
    ],
    conjuncts: [
      'ક્ષ', // ksha
      'ત્ર', // tra
      'જ્ઞ', // gya/dnya
      'શ્ર', // shra
      'દ્ય', // dya
      'દ્ધ', // ddha
      'દ્વ', // dva
      'ક્ર', // kra
      'પ્ર', // pra
      'ભ્ર', // bhra
      'શ્ચ', // shcha
      'ષ્ટ', // shta
      'ષ્ઠ', // shtha
      'ડ્ડ', // dda
      'ટ્ટ', // tta
      'ણ્ડ', // nda
      'ણ્ઢ', // ndha
      'ન્ન', // nna
      'લ્લ', // lla
      'ત્ત', // tta
      'ક્ક', // kka
      'ચ્ચ', // ccha
      'જ્જ', // jja
      'ટ્ઠ', // ttha
      'દ્દ', // dda
      'પ્પ', // ppa
      'મ્મ', // mma
      'ય્ય', // yya
      'ર્ર', // rra
      'લ્લ', // lla
      'વ્વ', // vva
      'સ્સ', // ssa
      'હ્ન', // hna
      'હ્મ', // hma
      'હ્ય', // hya
      'હ્ર', // hra
      'હ્લ', // hla
      'હ્વ', // hva
    ],
    numbers: ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'],
    punctuation: [',', '.', '?', '!', '।', '॥', '-', '૰', '₹', '/', '\\', '|'],
  );

  /// Gujarati typing practice layout (comprehensive for lessons)
  static const KeyboardLayout gujaratiPractice = KeyboardLayout(
    languageCode: 'gu',
    languageName: 'ગુજરાતી',
    hasShiftVariant: true,
    isRightToLeft: false,
    rows: [
      // Row 1: Vowels (સ્વર) - All independent vowels
      ['અ', 'આ', 'ઇ', 'ઈ', 'ઉ', 'ઊ', 'ઋ', 'એ', 'ઐ', 'ઓ', 'ઔ', 'ઑ'],
      // Row 2: Consonants Row 1 (ક-વર્ગ to ચ-વર્ગ)
      ['ક', 'ખ', 'ગ', 'ઘ', 'ઙ', 'ચ', 'છ', 'જ', 'ઝ', 'ઞ'],
      // Row 3: Consonants Row 2 (ટ-વર્ગ to ત-વર્ગ)
      ['ટ', 'ઠ', 'ડ', 'ઢ', 'ણ', 'ત', 'થ', 'દ', 'ધ', 'ન'],
      // Row 4: Consonants Row 3 (પ-વર્ગ + અન્તસ્થ + ઊષ્મ)
      ['પ', 'ફ', 'બ', 'ભ', 'મ', 'ય', 'ર', 'લ', 'વ', 'શ', 'ષ', 'સ', 'હ'],
      // Row 5: Matras and signs
      ['ા', 'િ', 'ી', 'ુ', 'ૂ', 'ૃ', 'ે', 'ૈ', 'ો', 'ૌ', '્', 'ં', 'ઃ'],
      // Row 6: Numbers and Space
      ['૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯', '૦', 'SPACE'],
    ],
    shiftRows: [
      // Shift Row 1: Extended vowels
      ['ૠ', 'ઌ', 'ૡ', 'ઍ', 'ૅ', 'ૉ', 'ઁ', '૰', '।', '॥', '₹', 'ઽ'],
      // Shift Row 2: Nukta variants
      ['ક઼', 'ખ઼', 'ગ઼', 'જ઼', 'ફ઼', 'ર઼', '૱', '૱', '૱', '૱'],
      // Shift Row 3: Common conjuncts (Row 1)
      ['ક્ષ', 'ત્ર', 'જ્ઞ', 'શ્ર', 'ક્ર', 'પ્ર', 'ભ્ર', 'દ્વ', 'દ્ય', 'દ્ધ'],
      // Shift Row 4: More conjuncts
      [
        'ષ્ટ',
        'ષ્ઠ',
        'ન્ન',
        'લ્લ',
        'ત્ત',
        'ક્ક',
        'ચ્ચ',
        'જ્જ',
        'દ્દ',
        'મ્મ',
        'સ્સ',
        'હ્મ',
        'હ્ન',
      ],
      // Shift Row 5: Additional matras and symbols
      ['ૄ', 'ૢ', 'ૣ', '।', '॥', ':', ';', '?', '!', '@', '#', '%'],
    ],
    matras: [
      'ા',
      'િ',
      'ી',
      'ુ',
      'ૂ',
      'ૃ',
      'ૄ',
      'ે',
      'ૈ',
      'ો',
      'ૌ',
      'ં',
      'ઃ',
      '્',
      'ઁ',
      'ૅ',
      'ૉ',
      '઼',
    ],
    vowels: [
      'અ',
      'આ',
      'ઇ',
      'ઈ',
      'ઉ',
      'ઊ',
      'ઋ',
      'ૠ',
      'ઌ',
      'ૡ',
      'એ',
      'ઐ',
      'ઓ',
      'ઔ',
      'ઍ',
      'ઑ',
    ],
    consonants: [
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
    ],
    nuktaVariants: ['ક઼', 'ખ઼', 'ગ઼', 'જ઼', 'ફ઼', 'ર઼'],
    conjuncts: [
      'ક્ષ',
      'ત્ર',
      'જ્ઞ',
      'શ્ર',
      'ક્ર',
      'પ્ર',
      'ભ્ર',
      'દ્વ',
      'દ્ય',
      'દ્ધ',
    ],
    numbers: ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'],
    punctuation: [',', '.', '?', '!', '।', '॥', '-', '૰', '₹'],
  );

  // =========================================================================
  // 📦 LAYOUT REGISTRY
  // =========================================================================

  /// Map of all available layouts by language code
  static const Map<String, KeyboardLayout> layouts = {
    'en': english,
    'en_simple': englishSimple,
    'hi': hindi,
    'hi_practice': hindiPractice,
    'gu': gujarati,
    'gu_practice': gujaratiPractice,
  };

  /// List of supported language codes
  static List<String> get supportedLanguages => layouts.keys.toList();

  /// Get layout by language code
  static KeyboardLayout? getLayout(String languageCode) {
    return layouts[languageCode];
  }

  /// Get default layout (English)
  static KeyboardLayout get defaultLayout => english;

  /// Check if language is supported
  static bool isSupported(String languageCode) {
    return layouts.containsKey(languageCode);
  }

  // =========================================================================
  // 📊 JSON EXPORTS
  // =========================================================================

  /// Get all layouts as JSON (for debugging/export)
  static Map<String, Map<String, dynamic>> toJson() {
    return layouts.map((key, layout) => MapEntry(key, layout.toJson()));
  }

  /// Get single layout as JSON
  static Map<String, dynamic>? getLayoutJson(String languageCode) {
    return layouts[languageCode]?.toJson();
  }
}

// =========================================================================
// 🔤 LANGUAGE INFO
// =========================================================================

/// Information about supported languages
class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;
  final bool isRTL;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
    this.isRTL = false,
  });

  static const List<LanguageInfo> supportedLanguages = [
    LanguageInfo(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇺🇸',
    ),
    LanguageInfo(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिंदी',
      flagEmoji: '🇮🇳',
    ),
    LanguageInfo(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      flagEmoji: '🇮🇳',
    ),
  ];

  static LanguageInfo? getByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }
}
