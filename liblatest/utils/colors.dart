// =========================================================================
// 🎨 APP COLORS - CENTRALIZED COLOR PALETTE
// =========================================================================

import 'package:flutter/material.dart';

/// Central repository for all app colors and color schemes
class AppColors {
  // =========================================================================
  // 🎯 PRIMARY BRAND COLORS
  // =========================================================================
  
  // Primary blue palette
  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color primaryBlueLight = Color(0xFF768FFF);
  static const Color primaryBlueDark = Color(0xFF0039CB);
  
  // Accent coral palette  
  static const Color accentCoral = Color(0xFFFF6E40);
  static const Color accentCoralLight = Color(0xFFFFCCBC);
  static const Color accentCoralDark = Color(0xFFDD2C00);
  
  // Legacy colors (maintained for compatibility)
  static const Color buttonColor = Color.fromRGBO(240, 51, 74, 1);
  static const Color kSecondaryBackgroundColor = Color.fromRGBO(107, 82, 200, 0.1);
  static const Color kPrimaryBackgroundColor = Colors.deepOrange;
  
  // =========================================================================
  // 🌈 SEMANTIC COLORS
  // =========================================================================
  
  // Status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successGreenLight = Color(0xFFC8E6C9);
  static const Color successGreenDark = Color(0xFF2E7D32);
  
  static const Color errorRed = Color(0xFFF44336);
  static const Color errorRedLight = Color(0xFFFFCDD2);
  static const Color errorRedDark = Color(0xFFD32F2F);
  
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color warningOrangeLight = Color(0xFFFFE0B2);
  static const Color warningOrangeDark = Color(0xFFF57C00);
  
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color infoBlueLight = Color(0xFFBBDEFB);
  static const Color infoBlueDark = Color(0xFF1976D2);
  
  // =========================================================================
  // 📝 TYPING INTERFACE COLORS
  // =========================================================================
  
  // Character state colors
  static const Color correctChar = successGreen;
  static const Color incorrectChar = errorRed;
  static const Color currentChar = primaryBlue;
  static const Color pendingChar = Color(0xFF9E9E9E);
  
  // Character background colors
  static const Color correctCharBg = Color(0xFFE8F5E8);
  static const Color incorrectCharBg = Color(0xFFFFEBEE);
  static const Color currentCharBg = Color(0xFFE3F2FD);
  static const Color pendingCharBg = Color(0xFFF5F5F5);
  
  // =========================================================================
  // 🎹 KEYBOARD COLORS
  // =========================================================================
  
  // Keyboard base colors
  static const Color keyboardBackground = Color(0xFF37474F);
  static const Color keyboardBackgroundLight = Color(0xFF62727B);
  static const Color keyboardBackgroundDark = Color(0xFF102027);
  
  // Key colors
  static const Color keyDefault = Color(0xFFFFFFFF);
  static const Color keyPressed = Color(0xFFE0E0E0);
  static const Color keyHighlight = Color(0xFF00C853);
  static const Color keyError = Color(0xFFFF5252);
  static const Color keyDisabled = Color(0xFFBDBDBD);
  
  // Key text colors
  static const Color keyTextDefault = Color(0xFF212121);
  static const Color keyTextPressed = Color(0xFF424242);
  static const Color keyTextHighlight = Color(0xFFFFFFFF);
  static const Color keyTextError = Color(0xFFFFFFFF);
  static const Color keyTextDisabled = Color(0xFF9E9E9E);
  
  // =========================================================================
  // 🖼️ BACKGROUND & SURFACE COLORS
  // =========================================================================
  
  // Main backgrounds
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dialogBackground = Color(0xFFFFFFFF);
  
  // Surface variations
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF5F5F5);
  
  // Overlay colors
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlay = Color(0x52000000);
  static const Color overlayDark = Color(0x99000000);
  
  // =========================================================================
  // 📚 TEXT COLORS
  // =========================================================================
  
  // Primary text colors
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  
  // Light text colors (for dark backgrounds)
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textLightSecondary = Color(0xFFEEEEEE);
  static const Color textLightTertiary = Color(0xFFBDBDBD);
  
  // Disabled text
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // =========================================================================
  // 📊 PERFORMANCE COLORS
  // =========================================================================
  
  // WPM performance colors
  static const Color expertPerformance = Color(0xFF6A1B9A);
  static const Color excellentPerformance = Color(0xFF2E7D32);
  static const Color goodPerformance = Color(0xFF1976D2);
  static const Color averagePerformance = Color(0xFFF57C00);
  static const Color beginnerPerformance = Color(0xFFD32F2F);
  
  // Accuracy colors
  static const Color highAccuracy = Color(0xFF4CAF50);
  static const Color mediumAccuracy = Color(0xFFFF9800);
  static const Color lowAccuracy = Color(0xFFF44336);
  
  // =========================================================================
  // 🔲 BORDER & DIVIDER COLORS
  // =========================================================================
  
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF757575);
  
  static const Color dividerLight = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFFE0E0E0);
  
  // =========================================================================
  // 🔧 UTILITY METHODS
  // =========================================================================
  
  /// Get performance color based on WPM
  static Color getWpmColor(int wpm) {
    if (wpm >= 80) return expertPerformance;
    if (wpm >= 60) return excellentPerformance;
    if (wpm >= 40) return goodPerformance;
    if (wpm >= 20) return averagePerformance;
    return beginnerPerformance;
  }
  
  /// Get accuracy color based on percentage
  static Color getAccuracyColor(double accuracy) {
    if (accuracy >= 90.0) return highAccuracy;
    if (accuracy >= 75.0) return mediumAccuracy;
    return lowAccuracy;
  }
  
  /// Get character state color
  static Color getCharacterStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'correct': return correctChar;
      case 'incorrect': return incorrectChar;
      case 'current': return currentChar;
      default: return pendingChar;
    }
  }
  
  /// Get character background color
  static Color getCharacterBackgroundColor(String state) {
    switch (state.toLowerCase()) {
      case 'correct': return correctCharBg;
      case 'incorrect': return incorrectCharBg;
      case 'current': return currentCharBg;
      default: return pendingCharBg;
    }
  }
  
  /// Create a material color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;
    
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
  
  /// Get a color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }
  
  /// Lighten a color by a percentage
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
  
  /// Darken a color by a percentage
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}
