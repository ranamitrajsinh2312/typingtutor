import 'package:flutter/material.dart';
import 'package:typingtutor/import_export.dart';

// =========================================================================
// 🎨 APP THEME — Modern, Attractive, Device-Adaptive Design System
// =========================================================================

class AppTheme {
  // ── Primary palette: Deep Navy + Electric Cyan ────────────────────────
  static const Color _primary      = Color(0xFF1A237E);
  static const Color _primaryLight = Color(0xFF534BAE);
  static const Color _primaryDark  = Color(0xFF000051);
  static const Color _accent       = Color(0xFF00BCD4);
  static const Color _accentLight  = Color(0xFF62EFFF);
  static const Color _accentDark   = Color(0xFF008BA3);
  static const Color _scaffold     = Color(0xFFF0F4FF);
  static const Color _card         = Color(0xFFFFFFFF);
  static const Color _textPrimary  = Color(0xFF1A237E);
  static const Color _textSecondary= Color(0xFF5C6BC0);
  static const Color _textLight    = Color(0xFFFFFFFF);

  static Color get primaryColor          => _primary;
  static Color get primaryLightColor     => _primaryLight;
  static Color get primaryDarkColor      => _primaryDark;
  static Color get accentColor           => _accent;
  static Color get accentLightColor      => _accentLight;
  static Color get accentDarkColor       => _accentDark;
  static Color get scaffoldBackgroundColor => _scaffold;
  static Color get cardColor             => _card;
  static Color get textPrimaryColor      => _textPrimary;
  static Color get textSecondaryColor    => _textSecondary;
  static Color get textLightColor        => _textLight;
  static Color get keyboardBackgroundColor => const Color(0xFF1C2333);
  static Color get keyHighlightColor     => const Color(0xFF00E5FF);
  static Color get keyErrorColor         => const Color(0xFFFF1744);

  static LinearGradient get appBarGradient => const LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
  );

  static LinearGradient get heroGradient => const LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF1A237E), Color(0xFF311B92)],
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: const Color(0xFF1A237E).withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1)),
  ];

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: _primary,
      colorScheme: ColorScheme.light(
        primary: _primary, secondary: _accent,
        surface: _card, background: _scaffold,
        error: const Color(0xFFFF1744),
        onPrimary: _textLight, onSecondary: _textLight,
        onSurface: _textPrimary, onBackground: _textPrimary,
        onError: _textLight, brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _scaffold,
      cardColor: _card,
      appBarTheme: AppBarTheme(
        backgroundColor: _primary, elevation: 0, scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: _textLight),
        iconTheme: const IconThemeData(color: _textLight),
      ),
      textTheme: TextTheme(
        displayLarge:  GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: _textPrimary),
        displayMedium: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary),
        displaySmall:  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: _textPrimary),
        headlineLarge:  GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary),
        headlineMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
        bodyLarge:  GoogleFonts.poppins(fontSize: 16, color: _textPrimary),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
        bodySmall:  GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
        labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary, foregroundColor: _textLight, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: _card, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
