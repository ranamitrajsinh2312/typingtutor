import 'package:flutter/material.dart';
import 'package:typingtutor/constants/app_constants.dart';

/// Responsive helper class for handling different screen sizes and orientations
class ResponsiveHelper {
  // Breakpoints
  static const double mobileMaxWidth = AppConstants.mobileBreakpoint;
  static const double tabletMaxWidth = AppConstants.tabletBreakpoint;
  static const double desktopMaxWidth = AppConstants.desktopBreakpoint;

  /// Check if current device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// Check if current device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  /// Check if current device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get device type as string
  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) return 'mobile';
    if (isTablet(context)) return 'tablet';
    return 'desktop';
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
          : const EdgeInsets.all(20);
    } else {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
          : const EdgeInsets.all(24);
    }
  }

  /// Get responsive margin based on device type
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          : const EdgeInsets.all(16);
    } else {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
          : const EdgeInsets.all(20);
    }
  }

  /// Get responsive font size based on device type and context
  static double getResponsiveFontSize(BuildContext context, FontSizeType type) {
    final isMobileDevice = isMobile(context);
    final isTabletDevice = isTablet(context);
    final landscapeMode = isLandscape(context);

    switch (type) {
      case FontSizeType.small:
        if (isMobileDevice) return landscapeMode ? 10 : 12;
        if (isTabletDevice) return landscapeMode ? 12 : 14;
        return landscapeMode ? 14 : 16;

      case FontSizeType.medium:
        if (isMobileDevice) return landscapeMode ? 14 : 16;
        if (isTabletDevice) return landscapeMode ? 16 : 18;
        return landscapeMode ? 18 : 20;

      case FontSizeType.large:
        if (isMobileDevice) return landscapeMode ? 18 : 20;
        if (isTabletDevice) return landscapeMode ? 20 : 22;
        return landscapeMode ? 22 : 24;

      case FontSizeType.extraLarge:
        if (isMobileDevice) return landscapeMode ? 22 : 24;
        if (isTabletDevice) return landscapeMode ? 24 : 26;
        return landscapeMode ? 26 : 28;
    }
  }

  /// Get responsive container max width
  static double getMaxContainerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth * 0.95;
    } else if (isTablet(context)) {
      return isLandscape(context) ? screenWidth * 0.9 : screenWidth * 0.85;
    } else {
      return isLandscape(context) ? screenWidth * 0.8 : screenWidth * 0.75;
    }
  }

  /// Get responsive keyboard height
  static double getKeyboardHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    // Define minimum keyboard height to ensure usability
    const double minKeyboardHeight = 200.0; // Increased from 150.0

    double keyboardHeight;
    if (isMobileDevice) {
      keyboardHeight = landscapeMode ? screenHeight * 0.45 : screenHeight * 0.35;
    } else if (isTablet(context)) {
      keyboardHeight = landscapeMode ? screenHeight * 0.55 : screenHeight * 0.4;
    } else {
      keyboardHeight = landscapeMode ? screenHeight * 0.6 : screenHeight * 0.45;
    }

    // Ensure keyboard height doesn't fall below the minimum
    return keyboardHeight < minKeyboardHeight ? minKeyboardHeight : keyboardHeight;
  }

  /// Get ultra compact keyboard height for landscape mode
  static double getUltraCompactKeyboardHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    // Define minimum keyboard height for ultra compact mode
    const double minKeyboardHeight = 400.0; // Increased from 150.0

    double keyboardHeight;
    if (isMobileDevice) {
      keyboardHeight = landscapeMode ? screenHeight * 0.5 : screenHeight * 0.25;
    } else if (isTablet(context)) {
      keyboardHeight = landscapeMode ? screenHeight * 0.58 : screenHeight * 0.3;
    } else {
      keyboardHeight = landscapeMode ? screenHeight * 0.62 : screenHeight * 0.35;
    }

    // Ensure keyboard height doesn't fall below the minimum
    return keyboardHeight < minKeyboardHeight ? minKeyboardHeight : keyboardHeight;
  }

  /// Get responsive key height for keyboard
  static double getKeyHeight(BuildContext context) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice) {
      return landscapeMode ? 58 : 58; // Increased from 40 for landscape
    } else if (isTablet(context)) {
      return landscapeMode ? 66 : 66; // Increased from 48 for landscape
    } else {
      return landscapeMode ? 74 : 74; // Increased from 56 for landscape
    }
  }

  /// Get ultra compact key height for keyboard in landscape mode
  static double getUltraCompactKeyHeight(BuildContext context) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice) {
      return landscapeMode ? 50 : 50; // Increased from 32 for landscape
    } else if (isTablet(context)) {
      return landscapeMode ? 58 : 58; // Increased from 40 for landscape
    } else {
      return landscapeMode ? 66 : 66; // Increased from 48 for landscape
    }
  }

  /// Get responsive keyboard font size
  static double getKeyboardFontSize(BuildContext context, bool isSpecialKey) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    double baseFontSize;
    if (isMobileDevice) {
      baseFontSize = landscapeMode ? 18 : 16; // Increased for readability
    } else if (isTablet(context)) {
      baseFontSize = landscapeMode ? 14 : 16;
    } else {
      baseFontSize = landscapeMode ? 16 : 18;
    }

    return isSpecialKey ? baseFontSize - 2 : baseFontSize;
  }

  /// Get ultra compact keyboard font size for landscape mode
  static double getUltraCompactKeyboardFontSize(BuildContext context, bool isSpecialKey) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    double baseFontSize;
    if (isMobileDevice) {
      baseFontSize = landscapeMode ? 10 : 12; // Increased for readability
    } else if (isTablet(context)) {
      baseFontSize = landscapeMode ? 12 : 14;
    } else {
      baseFontSize = landscapeMode ? 14 : 16;
    }

    return isSpecialKey ? baseFontSize - 1 : baseFontSize;
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, IconSizeType type) {
    final isMobileDevice = isMobile(context);
    final isTabletDevice = isTablet(context);
    final landscapeMode = isLandscape(context);

    switch (type) {
      case IconSizeType.small:
        if (isMobileDevice) return landscapeMode ? 16 : 18;
        if (isTabletDevice) return landscapeMode ? 18 : 20;
        return landscapeMode ? 20 : 22;

      case IconSizeType.medium:
        if (isMobileDevice) return landscapeMode ? 20 : 24;
        if (isTabletDevice) return landscapeMode ? 24 : 28;
        return landscapeMode ? 28 : 32;

      case IconSizeType.large:
        if (isMobileDevice) return landscapeMode ? 32 : 40;
        if (isTabletDevice) return landscapeMode ? 40 : 48;
        return landscapeMode ? 48 : 56;

      case IconSizeType.extraLarge:
        if (isMobileDevice) return landscapeMode ? 48 : 60;
        if (isTabletDevice) return landscapeMode ? 60 : 72;
        return landscapeMode ? 72 : 80;
    }
  }

  /// Get responsive grid columns count
  static int getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final landscapeMode = isLandscape(context);

    if (isMobile(context)) {
      return landscapeMode ? 3 : 2;
    } else if (isTablet(context)) {
      return landscapeMode ? 4 : 3;
    } else {
      return landscapeMode ? 5 : 4;
    }
  }

  /// Get responsive stats card layout
  static bool shouldUseColumnLayout(BuildContext context) {
    return isMobile(context) && isPortrait(context);
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, SpacingType type) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    double multiplier = 1.0;
    if (isMobileDevice) {
      multiplier = landscapeMode ? 0.8 : 1.0;
    } else if (isTablet(context)) {
      multiplier = landscapeMode ? 1.2 : 1.4;
    } else {
      multiplier = landscapeMode ? 1.4 : 1.6;
    }

    switch (type) {
      case SpacingType.small:
        return 8 * multiplier;
      case SpacingType.medium:
        return 16 * multiplier;
      case SpacingType.large:
        return 24 * multiplier;
      case SpacingType.extraLarge:
        return 32 * multiplier;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, BorderRadiusType type) {
    final isMobileDevice = isMobile(context);

    double baseRadius;
    switch (type) {
      case BorderRadiusType.small:
        baseRadius = 6;
        break;
      case BorderRadiusType.medium:
        baseRadius = 12;
        break;
      case BorderRadiusType.large:
        baseRadius = 16;
        break;
      case BorderRadiusType.extraLarge:
        baseRadius = 20;
        break;
    }

    return isMobileDevice ? baseRadius * 0.8 : baseRadius;
  }

  /// Check if should show hand images based on available space
  static bool shouldShowHandImages(BuildContext context, double availableHeight) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice && landscapeMode) {
      return availableHeight > 120; // Reduced requirement for mobile landscape
    } else if (isMobileDevice) {
      return availableHeight > 250; // Slightly reduced for mobile portrait
    } else {
      return availableHeight > 200; // Reduced for tablets/desktop
    }
  }

  /// Get hand image size
  static double getHandImageSize(BuildContext context) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice) {
      return landscapeMode ? 80 : 100;
    } else if (isTablet(context)) {
      return landscapeMode ? 120 : 140;
    } else {
      return landscapeMode ? 140 : 160;
    }
  }

  /// Get text display height
  static double getTextDisplayHeight(BuildContext context) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice) {
      return landscapeMode ? 44 : 70;
    } else if (isTablet(context)) {
      return landscapeMode ? 54 : 80;
    } else {
      return landscapeMode ? 64 : 90;
    }
  }

  /// Get ultra compact text display height for landscape mode
  static double getUltraCompactTextDisplayHeight(BuildContext context) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice) {
      return landscapeMode ? 40 : 60; // Ultra compact heights for landscape
    } else if (isTablet(context)) {
      return landscapeMode ? 50 : 70; // Ultra compact heights for landscape
    } else {
      return landscapeMode ? 60 : 80; // Ultra compact heights for landscape
    }
  }

  /// Get ultra compact stats height for landscape mode
  static double getUltraCompactStatsHeight(BuildContext context) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    if (isMobileDevice) {
      return landscapeMode ? 26 : 50;
    } else if (isTablet(context)) {
      return landscapeMode ? 32 : 55;
    } else {
      return landscapeMode ? 36 : 60;
    }
  }

  /// Get ultra compact spacing for landscape mode
  static double getUltraCompactSpacing(BuildContext context, SpacingType type) {
    final isMobileDevice = isMobile(context);
    final landscapeMode = isLandscape(context);

    double multiplier = 1.0;
    if (isMobileDevice) {
      multiplier = landscapeMode ? 0.4 : 0.8; // Ultra compact in landscape
    } else if (isTablet(context)) {
      multiplier = landscapeMode ? 0.6 : 1.2; // Ultra compact in landscape
    } else {
      multiplier = landscapeMode ? 0.8 : 1.4; // Ultra compact in landscape
    }

    switch (type) {
      case SpacingType.small:
        return 8 * multiplier;
      case SpacingType.medium:
        return 16 * multiplier;
      case SpacingType.large:
        return 24 * multiplier;
      case SpacingType.extraLarge:
        return 32 * multiplier;
    }
  }

  /// Get ultra compact padding for landscape mode
  static EdgeInsets getUltraCompactPadding(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) // Ultra compact in landscape
          : const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) // Ultra compact in landscape
          : const EdgeInsets.all(20);
    } else {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) // Ultra compact in landscape
          : const EdgeInsets.all(24);
    }
  }

  /// Get ultra compact margin for landscape mode
  static EdgeInsets getUltraCompactMargin(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3) // Ultra compact in landscape
          : const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) // Ultra compact in landscape
          : const EdgeInsets.all(16);
    } else {
      return isLandscape(context)
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5) // Ultra compact in landscape
          : const EdgeInsets.all(20);
    }
  }

  /// Get adaptive layout type
  static LayoutType getLayoutType(BuildContext context) {
    if (isMobile(context) && isPortrait(context)) {
      return LayoutType.mobilePortrait;
    } else if (isMobile(context) && isLandscape(context)) {
      return LayoutType.mobileLandscape;
    } else if (isTablet(context) && isPortrait(context)) {
      return LayoutType.tabletPortrait;
    } else if (isTablet(context) && isLandscape(context)) {
      return LayoutType.tabletLandscape;
    } else if (isDesktop(context) && isPortrait(context)) {
      return LayoutType.desktopPortrait;
    } else {
      return LayoutType.desktopLandscape;
    }
  }
}

/// Font size types for responsive design
enum FontSizeType {
  small,
  medium,
  large,
  extraLarge,
}

/// Icon size types for responsive design
enum IconSizeType {
  small,
  medium,
  large,
  extraLarge,
}

/// Spacing types for responsive design
enum SpacingType {
  small,
  medium,
  large,
  extraLarge,
}

/// Border radius types for responsive design
enum BorderRadiusType {
  small,
  medium,
  large,
  extraLarge,
}

/// Layout types based on device and orientation
enum LayoutType {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
  desktopPortrait,
  desktopLandscape,
}

/// Screen breakpoints helper class
class ScreenBreakpoints {
  static const double mobile = AppConstants.mobileBreakpoint;
  static const double tablet = AppConstants.tabletBreakpoint;
  static const double desktop = AppConstants.desktopBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}