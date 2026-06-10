// =========================================================================
// 🏆 LEVEL COMPLETION SCREEN - ANIMATED STAR RATING
// =========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:typingtutor/import_export.dart';
import 'package:typingtutor/models/practice_level.dart';

class LevelCompletionScreen extends StatefulWidget {
  final LevelCompletionResult result;
  final PracticeLevel level;
  final VoidCallback? onContinue;
  final VoidCallback? onRetry;

  const LevelCompletionScreen({
    Key? key,
    required this.result,
    required this.level,
    this.onContinue,
    this.onRetry,
  }) : super(key: key);

  @override
  State<LevelCompletionScreen> createState() => _LevelCompletionScreenState();
}

class _LevelCompletionScreenState extends State<LevelCompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _contentController;
  late AnimationController _confettiController;
  late Animation<double> _starScaleAnimation;
  late Animation<double> _contentFadeAnimation;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playCompletionSound();
    HapticFeedback.mediumImpact();
  }

  void _setupAnimations() {
    // Star animation controller (for individual stars)
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Content fade animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Star scale animation
    _starScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.elasticOut),
    );

    // Content fade animation
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeInOut),
    );

    // Individual star animations with stagger
    _starAnimations = List.generate(3, (index) {
      final startDelay = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _starController,
          curve: Interval(
            startDelay,
            startDelay + 0.4,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    // Start animations
    _starController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _contentController.forward();
    });
    if (widget.result.starsEarned == 3) {
      _confettiController.repeat();
    }
  }

  void _playCompletionSound() {
    // Play sound based on performance
    // This is a placeholder - implement with audioplayers if needed
  }

  @override
  void dispose() {
    _starController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            _buildBackground(),

            // Confetti for perfect score
            if (widget.result.starsEarned == 3) _buildConfetti(),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildStarsSection(),
                    const SizedBox(height: 32),
                    _buildStatsSection(),
                    const SizedBox(height: 32),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getPrimaryColor().withOpacity(0.1),
            Colors.white,
            _getPrimaryColor().withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            progress: _confettiController.value,
            color: _getPrimaryColor(),
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _contentFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _contentFadeAnimation.value)),
            child: Column(
              children: [
                // Trophy/Badge icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _getPrimaryColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getHeaderIcon(),
                    size: 64,
                    color: _getPrimaryColor(),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  _getHeaderTitle(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _getPrimaryColor(),
                  ),
                ),
                const SizedBox(height: 8),

                // Level info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getPrimaryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.level.type.displayName} - Level ${widget.level.id}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getPrimaryColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarsSection() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final earned = index < widget.result.starsEarned;
            final animation = _starAnimations[index];

            return Transform.scale(
              scale: animation.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect for earned stars
                    if (earned)
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),

                    // Star icon
                    Icon(
                      earned ? Icons.star : Icons.star_border,
                      size: 64,
                      color: earned ? Colors.amber : Colors.grey.shade400,
                    ),

                    // Sparkle effect for earned stars
                    if (earned && animation.value == 1.0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Colors.amber.shade200,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _contentFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Your Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.speed,
                      label: 'WPM',
                      value: '${widget.result.wpm}',
                      color: Colors.blue,
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      icon: Icons.gps_fixed,
                      label: 'Accuracy',
                      value: '${widget.result.accuracy.toStringAsFixed(1)}%',
                      color: Colors.green,
                    ),
                    _buildStatDivider(),
                    _buildStatItem(
                      icon: Icons.timer,
                      label: 'Time',
                      value: _formatDuration(widget.result.timeTaken),
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // New best indicator
                if (widget.result.isNewBest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 20,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'New Personal Best!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Character breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCharCount(
                      'Correct',
                      widget.result.correctChars,
                      Colors.green,
                    ),
                    const SizedBox(width: 32),
                    _buildCharCount(
                      'Errors',
                      widget.result.incorrectChars,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 50, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildCharCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return AnimatedBuilder(
      animation: _contentFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentFadeAnimation.value,
          child: Column(
            children: [
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.onContinue != null) {
                      widget.onContinue!();
                    } else {
                      Get.back();
                      Get.back(); // Go back to levels screen
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPrimaryColor(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.onRetry != null) {
                      widget.onRetry!();
                    } else {
                      Get.back(); // Return to practice
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: _getPrimaryColor(), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: _getPrimaryColor()),
                      const SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getPrimaryColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getBackgroundColor() {
    if (widget.result.starsEarned == 3) {
      return Colors.amber.shade50;
    } else if (widget.result.starsEarned == 2) {
      return Colors.green.shade50;
    } else if (widget.result.starsEarned == 1) {
      return Colors.blue.shade50;
    }
    return Colors.grey.shade100;
  }

  Color _getPrimaryColor() {
    if (widget.result.starsEarned == 3) {
      return Colors.amber.shade700;
    } else if (widget.result.starsEarned == 2) {
      return Colors.green;
    } else if (widget.result.starsEarned == 1) {
      return Colors.blue;
    }
    return Colors.grey.shade600;
  }

  IconData _getHeaderIcon() {
    if (widget.result.starsEarned == 3) {
      return Icons.emoji_events;
    } else if (widget.result.starsEarned >= 1) {
      return Icons.celebration;
    }
    return Icons.sentiment_satisfied;
  }

  String _getHeaderTitle() {
    return widget.result.starRatingText;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// =========================================================================
// 🎊 CONFETTI PAINTER
// =========================================================================

class ConfettiPainter extends CustomPainter {
  final double progress;
  final Color color;

  ConfettiPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = DateTime.now().millisecondsSinceEpoch;

    final colors = [
      Colors.amber,
      Colors.pink,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    for (int i = 0; i < 50; i++) {
      final x = (random * (i + 1) * 0.1) % size.width;
      final baseY = -50 + (size.height + 100) * ((progress + i * 0.02) % 1.0);
      final y = baseY;

      paint.color = colors[i % colors.length].withOpacity(0.8);

      // Draw different shapes
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x, y), 5, paint);
      } else if (i % 3 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 8),
          paint,
        );
      } else {
        final path =
            Path()
              ..moveTo(x, y - 6)
              ..lineTo(x + 5, y + 4)
              ..lineTo(x - 5, y + 4)
              ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
