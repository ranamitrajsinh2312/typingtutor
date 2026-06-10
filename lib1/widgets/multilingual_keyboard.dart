// =========================================================================
// 🎹 MULTILINGUAL KEYBOARD WIDGET - DYNAMIC LANGUAGE SWITCHING
// =========================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:typingtutor/controllers/keyboard_controller.dart';
import 'dart:math';

/// A keyboard widget that dynamically changes letters based on selected language
/// Uses GetX for reactive updates
class MultilingualKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final String currentChar;
  final List<int>? highlightedKeyPosition;
  final List<int>? errorKeyPosition;
  final bool isShiftActive;

  const MultilingualKeyboard({
    Key? key,
    required this.onKeyPressed,
    this.currentChar = '',
    this.highlightedKeyPosition,
    this.errorKeyPosition,
    this.isShiftActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KeyboardController>(
      init:
          Get.isRegistered<KeyboardController>()
              ? Get.find<KeyboardController>()
              : Get.put(KeyboardController()),
      builder: (controller) {
        return _KeyboardContent(
          controller: controller,
          onKeyPressed: onKeyPressed,
          currentChar: currentChar,
          highlightedKeyPosition: highlightedKeyPosition,
          errorKeyPosition: errorKeyPosition,
          isShiftActive: isShiftActive || controller.isShiftActive,
        );
      },
    );
  }
}

class _KeyboardContent extends StatelessWidget {
  final KeyboardController controller;
  final Function(String) onKeyPressed;
  final String currentChar;
  final List<int>? highlightedKeyPosition;
  final List<int>? errorKeyPosition;
  final bool isShiftActive;

  const _KeyboardContent({
    required this.controller,
    required this.onKeyPressed,
    required this.currentChar,
    this.highlightedKeyPosition,
    this.errorKeyPosition,
    required this.isShiftActive,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Get current keyboard rows
    final rows = controller.currentRows;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = min(constraints.maxWidth * 0.95, 800.0);
        final maxHeight = min(constraints.maxHeight * 0.95, 300.0);

        return Center(
          child: Container(
            width: maxWidth,
            height: maxHeight,
            padding: EdgeInsets.symmetric(
              horizontal: maxWidth * 0.02,
              vertical: maxHeight * 0.03,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade800, Colors.grey.shade900],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language indicator
                _buildLanguageIndicator(),
                const SizedBox(height: 8),

                // Keyboard rows
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(rows.length, (rowIndex) {
                      return _buildKeyboardRow(
                        context,
                        rows[rowIndex],
                        rowIndex,
                        maxWidth,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageIndicator() {
    final langInfo = controller.currentLanguageInfo;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                langInfo?.flagEmoji ?? '🌐',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                langInfo?.nativeName ?? 'English',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Shift indicator
        if (isShiftActive)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_upward, color: Colors.blue, size: 14),
                SizedBox(width: 4),
                Text(
                  'SHIFT',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKeyboardRow(
    BuildContext context,
    List<String> rowKeys,
    int rowIndex,
    double containerWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          rowKeys.asMap().entries.map((entry) {
            final colIndex = entry.key;
            final key = entry.value;

            return _buildKey(
              context,
              key,
              rowIndex,
              colIndex,
              containerWidth,
              rowKeys.length,
            );
          }).toList(),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String key,
    int rowIndex,
    int colIndex,
    double containerWidth,
    int keysInRow,
  ) {
    // Determine key properties
    final isSpecialKey = _isSpecialKey(key);
    final isHighlighted = _isKeyHighlighted(rowIndex, colIndex);
    final isError = _isKeyError(rowIndex, colIndex);

    // Unicode-safe character comparison
    bool isCurrentChar = false;
    if (currentChar.isNotEmpty) {
      if (controller.currentLanguage == 'en') {
        // English: case-insensitive
        isCurrentChar = key.toLowerCase() == currentChar.toLowerCase();
      } else {
        // Indic scripts: exact match or rune match
        isCurrentChar =
            key == currentChar ||
            (key.runes.isNotEmpty &&
                currentChar.runes.isNotEmpty &&
                key.runes.first == currentChar.runes.first);
      }
    }

    // Calculate key width
    double keyWidth = _calculateKeyWidth(key, containerWidth, keysInRow);
    double keyHeight = 40.0;

    // Key colors
    Color backgroundColor;
    Color textColor;

    if (isError) {
      backgroundColor = Colors.red.shade400;
      textColor = Colors.white;
    } else if (isHighlighted || isCurrentChar) {
      backgroundColor = Colors.blue.shade400;
      textColor = Colors.white;
    } else if (isSpecialKey) {
      backgroundColor = Colors.grey.shade600;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }

    // Display text
    String displayText = _getDisplayText(key);

    return GestureDetector(
      onTap: () => onKeyPressed(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(2),
        width: keyWidth,
        height: keyHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isHighlighted || isCurrentChar
                    ? Colors.blue.shade600
                    : Colors.grey.shade700,
            width: isHighlighted || isCurrentChar ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                displayText,
                style: TextStyle(
                  color: textColor,
                  fontSize: _getFontSize(key),
                  fontWeight:
                      isHighlighted || isCurrentChar
                          ? FontWeight.bold
                          : FontWeight.normal,
                  fontFamily:
                      controller.currentLanguage != 'en' && !isSpecialKey
                          ? 'Noto Sans Devanagari'
                          : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isSpecialKey(String key) {
    return [
      'TAB',
      'CAPS',
      'SHIFT',
      'ENTER',
      'SPACE',
      'BACKSPACE',
    ].contains(key);
  }

  bool _isKeyHighlighted(int row, int col) {
    if (highlightedKeyPosition == null) return false;
    return highlightedKeyPosition![0] == row &&
        highlightedKeyPosition![1] == col;
  }

  bool _isKeyError(int row, int col) {
    if (errorKeyPosition == null) return false;
    return errorKeyPosition![0] == row && errorKeyPosition![1] == col;
  }

  double _calculateKeyWidth(String key, double containerWidth, int keysInRow) {
    final baseWidth = (containerWidth - 20) / 14; // Max 14 keys per row

    switch (key) {
      case 'TAB':
      case 'CAPS':
      case 'ENTER':
        return baseWidth * 1.5;
      case 'SHIFT':
        return baseWidth * 1.8;
      case 'SPACE':
        return baseWidth * 6;
      case 'BACKSPACE':
        return baseWidth * 1.5;
      default:
        return baseWidth;
    }
  }

  String _getDisplayText(String key) {
    switch (key) {
      case 'TAB':
        return '⇥';
      case 'CAPS':
        return '⇪';
      case 'SHIFT':
        return '⇧';
      case 'ENTER':
        return '↵';
      case 'SPACE':
        return '';
      case 'BACKSPACE':
        return '⌫';
      default:
        return key;
    }
  }

  double _getFontSize(String key) {
    if (_isSpecialKey(key)) {
      return 14;
    }
    // Larger font for Devanagari/Gujarati scripts
    if (controller.currentLanguage != 'en') {
      return 16;
    }
    return 14;
  }
}

// =========================================================================
// 🎛️ LANGUAGE SELECTOR WIDGET
// =========================================================================

/// A widget for selecting keyboard language
class LanguageSelector extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageSelector({Key? key, this.onLanguageChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KeyboardController>(
      builder: (controller) {
        return PopupMenuButton<String>(
          onSelected: (code) {
            controller.changeLanguage(code);
            onLanguageChanged?.call();
          },
          itemBuilder: (context) {
            return controller.availableLanguages.map((lang) {
              final isSelected = lang.code == controller.currentLanguage;

              return PopupMenuItem<String>(
                value: lang.code,
                child: Row(
                  children: [
                    Text(lang.flagEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.name,
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          Text(
                            lang.nativeName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.green, size: 20),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.currentLanguageInfo?.flagEmoji ?? '🌐',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.currentLanguageInfo?.name ?? 'English',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// 📋 KEYBOARD LAYOUT EXAMPLE USAGE WIDGET
// =========================================================================

/// Example widget showing how to use the keyboard with language switching
class KeyboardExampleUsage extends StatelessWidget {
  const KeyboardExampleUsage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controllers if not already done
    if (!Get.isRegistered<KeyboardController>()) {
      Get.put(KeyboardController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Multilingual Keyboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: GetBuilder<KeyboardController>(
              builder: (controller) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      controller.availableLanguages.map((lang) {
                        final isSelected =
                            lang.code == controller.currentLanguage;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(lang.flagEmoji),
                                const SizedBox(width: 6),
                                Text(lang.name),
                              ],
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                controller.changeLanguage(lang.code);
                              }
                            },
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),

          // Keyboard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MultilingualKeyboard(
                onKeyPressed: (key) {
                  // Handle key press
                  debugPrint('Key pressed: $key');
                },
                currentChar: 'a',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
