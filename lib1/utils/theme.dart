import 'package:flutter/material.dart';
import 'package:typingtutor/import_export.dart';

class AppTheme {
  // Use AppColors for consistency across the app
  static Color get primaryColor => AppColors.primaryBlue;
  static Color get primaryLightColor => AppColors.primaryBlueLight;
  static Color get primaryDarkColor => AppColors.primaryBlueDark;

  static Color get accentColor => AppColors.accentCoral;
  static Color get accentLightColor => AppColors.accentCoralLight;
  static Color get accentDarkColor => AppColors.accentCoralDark;

  static Color get scaffoldBackgroundColor => AppColors.scaffoldBackground;
  static Color get cardColor => AppColors.cardBackground;

  static Color get textPrimaryColor => AppColors.textPrimary;
  static Color get textSecondaryColor => AppColors.textSecondary;
  static Color get textLightColor => AppColors.textLight;

  static Color get keyboardBackgroundColor => AppColors.keyboardBackground;
  static Color get keyHighlightColor => AppColors.keyHighlight;
  static Color get keyErrorColor => AppColors.errorRed;

  // Get the theme data
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: keyErrorColor,
        onPrimary: textLightColor,
        onSecondary: textLightColor,
        onSurface: textPrimaryColor,
        onError: textLightColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: accentColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLightColor,
        ),
        iconTheme: IconThemeData(color: textLightColor),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textPrimaryColor),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: textSecondaryColor,
        ),
        bodySmall: GoogleFonts.poppins(fontSize: 12, color: textSecondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textLightColor,
          elevation: 2,
          shadowColor: accentColor.withOpacity(0.3),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(10),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hoverColor: primaryLightColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: keyErrorColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        floatingLabelStyle: GoogleFonts.poppins(
          color: accentColor,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: textSecondaryColor,
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: keyErrorColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
