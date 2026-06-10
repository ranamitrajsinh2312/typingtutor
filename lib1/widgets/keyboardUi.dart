import 'package:flutter/material.dart';
import 'package:typingtutor/utils/responsive_helper.dart';
import 'dart:math';

class ModernKeyboardWidget extends StatelessWidget {
  final List<List<String>> keys;
  final List<List<Color>> keyColors;
  final String currentChar;
  final List<String> requiredKeys;
  final String? wrongKey;
  final String testString;
  final int currentIndex;
  final Function(String) onKeyPressed;
  final bool isLandscape;

  const ModernKeyboardWidget({
    Key? key,
    required this.keys,
    required this.keyColors,
    required this.currentChar,
    required this.requiredKeys,
    this.wrongKey,
    required this.testString,
    required this.currentIndex,
    required this.onKeyPressed,
    required this.isLandscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final layoutType = ResponsiveHelper.getLayoutType(context);
    final responsivePadding = ResponsiveHelper.getUltraCompactPadding(context);
    final responsiveMargin = ResponsiveHelper.getUltraCompactMargin(context);
    final keyboardHeight = ResponsiveHelper.isLandscape(context)
        ? ResponsiveHelper.getUltraCompactKeyboardHeight(context)
        : ResponsiveHelper.getKeyboardHeight(context);
    final maxContainerWidth = ResponsiveHelper.getMaxContainerWidth(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.medium);
    final spacing = ResponsiveHelper.getUltraCompactSpacing(context, SpacingType.small);

    // Improved keyboard sizing with better overflow prevention
    double keyboardMaxWidth;
    double keyboardMaxHeight;

    switch (layoutType) {
      case LayoutType.mobilePortrait:
        keyboardMaxWidth = min(screenWidth * 0.96, maxContainerWidth * 0.98);
        keyboardMaxHeight = min(screenHeight * 0.35, keyboardHeight * 0.70);
        break;
      case LayoutType.mobileLandscape:
        keyboardMaxWidth = min(screenWidth * 0.72, maxContainerWidth * 0.75);
        keyboardMaxHeight = min(screenHeight * 0.50, keyboardHeight * 0.40);
        break;
      case LayoutType.tabletPortrait:
        keyboardMaxWidth = min(screenWidth * 0.88, min(maxContainerWidth * 0.88, 650));
        keyboardMaxHeight = min(screenHeight * 0.40, keyboardHeight * 0.65);
        break;
      case LayoutType.tabletLandscape:
        keyboardMaxWidth = min(screenWidth * 0.70, min(maxContainerWidth * 0.70, 720));
        keyboardMaxHeight = min(screenHeight * 0.65, keyboardHeight * 0.40);
        break;
      default:
        keyboardMaxWidth = min(screenWidth * 0.45, min(maxContainerWidth * 0.45, 750));
        keyboardMaxHeight = min(screenHeight * 0.45, keyboardHeight * 0.50);
    }

    return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;
          final adjustedMaxWidth = min(keyboardMaxWidth, availableWidth * 0.98);
          final adjustedMaxHeight = min(keyboardMaxHeight, availableHeight * 0.85);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: adjustedMaxWidth,
                maxHeight: adjustedMaxHeight,
              ),
              child: Container(
                width: adjustedMaxWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: _getHorizontalPadding(context, adjustedMaxWidth),
                  vertical: _getVerticalPadding(context, adjustedMaxHeight),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: _getTopPadding(context, spacing),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(keys.length, (rowIndex) {
                        return Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: _getRowVerticalPadding(context, spacing),
                            ),
                            child: _buildKeyboardRow(
                              context,
                              keys[rowIndex],
                              keyColors[rowIndex],
                              rowIndex,
                              adjustedMaxWidth,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          );
        },

    );
  }

  double _getHorizontalPadding(BuildContext context, double containerWidth) {
    if (ResponsiveHelper.isTablet(context)) {
      return containerWidth * 0.02;
    } else if (ResponsiveHelper.isLandscape(context)) {
      return containerWidth * 0.015;
    } else {
      return containerWidth * 0.025;
    }
  }

  double _getVerticalPadding(BuildContext context, double containerHeight) {
    if (ResponsiveHelper.isTablet(context)) {
      return containerHeight * 0.02;
    } else if (ResponsiveHelper.isLandscape(context)) {
      return containerHeight * 0.015;
    } else {
      return containerHeight * 0.03;
    }
  }

  double _getTopPadding(BuildContext context, double spacing) {
    if (ResponsiveHelper.isTablet(context)) {
      return spacing * 0.04;
    } else if (ResponsiveHelper.isLandscape(context)) {
      return spacing * 0.03;
    } else {
      return spacing * 0.15;
    }
  }

  double _getRowVerticalPadding(BuildContext context, double spacing) {
    if (ResponsiveHelper.isTablet(context)) {
      return spacing * 0.025;
    } else if (ResponsiveHelper.isLandscape(context)) {
      return spacing * 0.02;
    } else {
      return spacing * 0.12;
    }
  }

  Widget _buildKeyboardRow(BuildContext context, List<String> rowKeys, List<Color> rowColors, int rowIndex, double containerWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = ResponsiveHelper.getUltraCompactSpacing(context, SpacingType.small);
        final isLandscape = ResponsiveHelper.isLandscape(context);
        final isTablet = ResponsiveHelper.isTablet(context);

        // Improved spacing calculations
        final rowSpacing = _getKeySpacing(context, spacing);
        final keyMargin = rowSpacing * 0.8;
        final minKeyWidth = _getMinKeyWidth(context);

        // More precise available width calculation
        final totalMargins = (rowKeys.length - 1) * rowSpacing;
        final sideMargins = keyMargin * 2;
        double availableWidth = constraints.maxWidth - totalMargins - sideMargins;
        if (availableWidth < 0) availableWidth = constraints.maxWidth * 0.9;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rowKeys.length, (keyIndex) {
            final keyFlex = _getKeyFlex(context, rowKeys[keyIndex], rowIndex);
            final keyWidth = _calculateOptimalKeyWidth(context, rowKeys[keyIndex], availableWidth, rowKeys, rowIndex);
            final finalKeyWidth = max(minKeyWidth, keyWidth);

            return Flexible(
              flex: keyFlex,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: finalKeyWidth,
                  minWidth: minKeyWidth,
                ),
                margin: EdgeInsets.symmetric(horizontal: keyMargin),
                child: _buildKey(
                  context,
                  rowKeys[keyIndex],
                  rowColors[keyIndex],
                  rowIndex == 1,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  double _getKeySpacing(BuildContext context, double spacing) {
    if (ResponsiveHelper.isTablet(context)) {
      return ResponsiveHelper.isLandscape(context) ? spacing * 0.03 : spacing * 0.035;
    } else {
      return ResponsiveHelper.isLandscape(context) ? spacing * 0.025 : spacing * 0.12;
    }
  }

  double _getMinKeyWidth(BuildContext context) {
    if (ResponsiveHelper.isTablet(context)) {
      return ResponsiveHelper.isLandscape(context) ? 22.0 : 26.0;
    } else {
      return ResponsiveHelper.isLandscape(context) ? 18.0 : 22.0;
    }
  }

  double _calculateOptimalKeyWidth(BuildContext context, String key, double availableWidth, List<String> rowKeys, int rowIndex) {
    double totalFlex = 0;
    for (String k in rowKeys) {
      totalFlex += _getKeyFlex(context, k, rowIndex);
    }
    if (totalFlex <= 0) totalFlex = rowKeys.length.toDouble();

    double unitWidth = availableWidth / totalFlex;
    double calculatedWidth = unitWidth * _getKeyFlex(context, key, rowIndex);

    return max(calculatedWidth, _getMinKeyWidth(context));
  }

  Widget _buildKey(BuildContext context, String keyText, Color keyColor, bool isHomeRow) {
    final bool isRequired = requiredKeys.contains(keyText) ||
        (keyText == 'SPACE' && requiredKeys.contains('SPACE'));
    final bool isCurrentKey = _isCurrentTargetKey(keyText);
    final bool isWrong = wrongKey != null &&
        (keyText == wrongKey ||
            (keyText == 'SPACE' && wrongKey?.toLowerCase() == 'space'));
    final bool isPressed = keyColor == Colors.green || keyColor == Colors.red;
    final bool isSpecialKey = _isSpecialKey(keyText);
    final bool isHighlighted = keyColor == Colors.blue.shade200;

    final keyHeight = _getOptimalKeyHeight(context);
    final fontSize = _getOptimalFontSize(context, isSpecialKey);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context, BorderRadiusType.small);
    final spacing = ResponsiveHelper.getUltraCompactSpacing(context, SpacingType.small);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: keyHeight,
      decoration: BoxDecoration(
        gradient: _getKeyGradient(keyColor, isRequired, isCurrentKey, isWrong, isSpecialKey, isHighlighted),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isCurrentKey
              ? Colors.blue.shade300
              : isWrong
              ? Colors.red.shade300
              : isRequired
              ? Colors.orange.shade300
              : isHomeRow && !isSpecialKey
              ? Colors.orange.shade300.withOpacity(0.3)
              : Colors.grey.shade600,
          width: isCurrentKey || isWrong ? 2 : isRequired ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentKey
                ? Colors.blue.withOpacity(0.4)
                : isWrong
                ? Colors.red.withOpacity(0.4)
                : isRequired
                ? Colors.orange.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: isCurrentKey || isWrong ? 6 : isRequired ? 4 : 2,
            offset: Offset(0, isPressed ? 1 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () => onKeyPressed(keyText),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(_getKeyPadding(context, spacing)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _getDisplayText(context, keyText),
                      style: TextStyle(
                        color: _getTextColor(keyColor, isRequired, isCurrentKey, isWrong, isSpecialKey, isHighlighted),
                        fontSize: fontSize,
                        fontWeight: isCurrentKey || isWrong ? FontWeight.bold : isRequired ? FontWeight.w700 : FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                if (isHomeRow && !isSpecialKey && keyText != 'SPACE')
                  Container(
                    margin: EdgeInsets.only(top: spacing * 0.1),
                    width: _getHomeRowIndicatorWidth(context),
                    height: _getHomeRowIndicatorHeight(context),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getOptimalKeyHeight(BuildContext context) {
    if (ResponsiveHelper.isTablet(context)) {
      return ResponsiveHelper.isLandscape(context)
          ? ResponsiveHelper.getUltraCompactKeyHeight(context) * 0.85
          : ResponsiveHelper.getKeyHeight(context) * 0.88;
    } else {
      return ResponsiveHelper.isLandscape(context)
          ? ResponsiveHelper.getUltraCompactKeyHeight(context) * 0.80
          : ResponsiveHelper.getKeyHeight(context) * 0.85;
    }
  }

  double _getOptimalFontSize(BuildContext context, bool isSpecialKey) {
    double baseFontSize;
    if (ResponsiveHelper.isTablet(context)) {
      baseFontSize = ResponsiveHelper.isLandscape(context)
          ? ResponsiveHelper.getUltraCompactKeyboardFontSize(context, isSpecialKey)
          : ResponsiveHelper.getKeyboardFontSize(context, isSpecialKey);
    } else {
      baseFontSize = ResponsiveHelper.isLandscape(context)
          ? ResponsiveHelper.getUltraCompactKeyboardFontSize(context, isSpecialKey)
          : ResponsiveHelper.getKeyboardFontSize(context, isSpecialKey);
    }

    return baseFontSize * (isSpecialKey ? 1.3 : 1.1);
  }

  double _getKeyPadding(BuildContext context, double spacing) {
    if (ResponsiveHelper.isTablet(context)) {
      return spacing * 0.25;
    } else {
      return spacing * 0.2;
    }
  }

  double _getHomeRowIndicatorWidth(BuildContext context) {
    if (ResponsiveHelper.isTablet(context)) {
      return 3.2;
    } else if (ResponsiveHelper.isMobile(context)) {
      return 2.8;
    } else {
      return 3.8;
    }
  }

  double _getHomeRowIndicatorHeight(BuildContext context) {
    if (ResponsiveHelper.isTablet(context)) {
      return 1.6;
    } else if (ResponsiveHelper.isMobile(context)) {
      return 1.4;
    } else {
      return 1.8;
    }
  }

  bool _isCurrentTargetKey(String keyText) {
    if (currentIndex >= testString.length) return false;
    String currentChar = testString[currentIndex];
    if (currentChar == ' ') {
      return keyText == 'SPACE';
    } else {
      return keyText == currentChar.toUpperCase();
    }
  }

  LinearGradient _getKeyGradient(Color keyColor, bool isRequired, bool isCurrentKey, bool isWrong,
      bool isSpecialKey, bool isHighlighted) {
    if (isWrong) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.red.shade400, Colors.red.shade600],
      );
    }
    if (isCurrentKey || isHighlighted) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.shade400, Colors.blue.shade600],
      );
    }
    if (isRequired) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.orange.shade200, Colors.orange.shade300],
      );
    }
    if (keyColor == Colors.green) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.green.shade400, Colors.green.shade600],
      );
    }
    if (keyColor == Colors.red) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.red.shade400, Colors.red.shade600],
      );
    }
    if (isSpecialKey) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.grey.shade300, Colors.grey.shade400],
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.grey.shade100, Colors.grey.shade200],
    );
  }

  Color _getTextColor(Color keyColor, bool isRequired, bool isCurrentKey, bool isWrong,
      bool isSpecialKey, bool isHighlighted) {
    if (isCurrentKey || isWrong || isHighlighted ||
        keyColor == Colors.green || keyColor == Colors.red) {
      return Colors.white;
    }
    if (isRequired) {
      return Colors.orange.shade800;
    }
    if (isSpecialKey) {
      return Colors.grey.shade700;
    }
    return Colors.grey.shade800;
  }

  String _getDisplayText(BuildContext context, String keyText) {
    switch (keyText) {
      case 'TAB':
        return 'Tab';
      case 'CAPS':
        return ResponsiveHelper.isMobile(context) ? 'Caps' : 'Caps Lock';
      case 'ENTER':
        return '⏎';
      case 'SHIFT':
        return '⇧';
      case 'SPACE':
        return ResponsiveHelper.isMobile(context) ? '' : 'Space';
      case '|':
        return '\\';
      case '/':
        return '/';
      default:
        return keyText;
    }
  }

  bool _isSpecialKey(String key) {
    return ['TAB', 'CAPS', 'ENTER', 'SHIFT', 'SPACE'].contains(key);
  }

  int _getKeyFlex(BuildContext context, String key, int rowIndex) {
    final isLandscapeMode = ResponsiveHelper.isLandscape(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Optimized flex values for better key distribution and size
    int baseFlex;
    int specialKeyMultiplier;
    int spaceKeyMultiplier;

    if (isMobile) {
      baseFlex = isLandscapeMode ? 5 : 7;
      specialKeyMultiplier = isLandscapeMode ? 8 : 12;
      spaceKeyMultiplier = isLandscapeMode ? 16 : 25;
    } else if (isTablet) {
      baseFlex = isLandscapeMode ? 5 : 7;
      specialKeyMultiplier = isLandscapeMode ? 7 : 12;
      spaceKeyMultiplier = isLandscapeMode ? 16 : 25;
    } else {
      baseFlex = isLandscapeMode ? 5 : 7;
      specialKeyMultiplier = isLandscapeMode ? 7 : 12;
      spaceKeyMultiplier = isLandscapeMode ? 16 : 25;
    }

    switch (key) {
      case 'TAB':
        return (specialKeyMultiplier * 0.6).round();
      case 'CAPS':
        return (specialKeyMultiplier * 0.65).round();
      case 'ENTER':
        return (specialKeyMultiplier * 0.75).round();
      case 'SHIFT':
        return (specialKeyMultiplier * 0.6).round();
      case 'SPACE':
        return spaceKeyMultiplier;
      default:
        return baseFlex;
    }
  }
}