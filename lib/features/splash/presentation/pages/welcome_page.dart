import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Welcome screen shown for [_displaySeconds] seconds after the splash.
/// Calls [onComplete] when the timer expires.
class WelcomePage extends StatefulWidget {
  final VoidCallback onComplete;
  const WelcomePage({super.key, required this.onComplete});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  static const int _displaySeconds = 10;

  late final AnimationController _progressCtrl;
  late final AnimationController _bouquetCtrl;
  late final AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();

    // Progress bar runs for exactly _displaySeconds then fires onComplete
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _displaySeconds),
    )..forward().whenComplete(widget.onComplete);

    // Bouquet floats up-and-down in a loop
    _bouquetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Confetti rotates continuously
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _bouquetCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Decorative circles ───────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.10),
              ),
            ),
          ),

          // ── Floating confetti emojis ─────────────────────────────────
          ..._FloatingEmoji.positions(size).map(
            (fp) => _FloatingEmoji(
              config: fp,
              controller: _confettiCtrl,
            ),
          ),

          // ── Skip button (top-right) ──────────────────────────────────
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Adds padding from screen edge
                child: GestureDetector(
                  onTap: widget.onComplete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.85),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // App name chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.gold.withOpacity(0.5)),
                    ),
                    child: Text(
                      AppConstants.appName,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.gold),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.5),

                  const SizedBox(height: 20),

                  // ── Bouquet presentation animation ───────────────────
                  AnimatedBuilder(
                    animation: _bouquetCtrl,
                    builder: (_, __) {
                      final bounce = Curves.easeInOut
                          .transform(_bouquetCtrl.value);
                      return Transform.translate(
                        offset: Offset(0, -12 * bounce + 6),
                        child: const Text(
                          '💐',
                          style: TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                        delay: 200.ms,
                      )
                      .fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 8),

                  // Presenting / receiving emoji row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🙏', style: TextStyle(fontSize: 28))
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -1),
                      const SizedBox(width: 16),
                      const Text('🎊', style: TextStyle(fontSize: 28))
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 400.ms)
                          .scale(curve: Curves.elasticOut),
                      const SizedBox(width: 16),
                      const Text('🙏', style: TextStyle(fontSize: 28))
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 1),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.white.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('✦',
                            style: TextStyle(
                                color: AppColors.gold.withOpacity(0.7),
                                fontSize: 14)),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.white.withOpacity(0.2))),
                    ],
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 24),

                  // "A warm welcome to"
                  Text(
                    'A Warm Welcome to',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.75),
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.4),

                  const SizedBox(height: 10),

                  // Client name
                  Text(
                    'Parveen Yadav',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 750.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3)
                      .shimmer(
                        delay: 1200.ms,
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.6),
                      ),

                  const SizedBox(height: 8),

                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.secondary.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Text(
                      'Head of Mobile Engineering',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      .animate(delay: 900.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3),

                  const SizedBox(height: 6),

                  // Company tag
                  Text(
                    'Shutterfly',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.55),
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 1100.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // Message
                  Text(
                    'Wishing you an amazing time at\n${AppConstants.eventName}! 🎉',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 1300.ms)
                      .fadeIn(duration: 500.ms),

                  const Spacer(flex: 3),

                  // ── Progress bar ─────────────────────────────────────
                  Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (_, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressCtrl.value,
                            minHeight: 3,
                            backgroundColor:
                                Colors.white.withOpacity(0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.gold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (_, __) {
                          final remaining = (_displaySeconds *
                                  (1 - _progressCtrl.value))
                              .ceil();
                          return Text(
                            'Entering in $remaining…',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating confetti emoji helper ─────────────────────────────────────────────

class _EmojiPosition {
  final String emoji;
  final double left;
  final double top;
  final double size;
  final double phaseOffset; // 0..1 to stagger animations
  const _EmojiPosition({
    required this.emoji,
    required this.left,
    required this.top,
    required this.size,
    required this.phaseOffset,
  });
}

class _FloatingEmoji extends StatelessWidget {
  final _EmojiPosition config;
  final AnimationController controller;
  const _FloatingEmoji(
      {required this.config, required this.controller});

  static List<_EmojiPosition> positions(Size size) => [
        _EmojiPosition(
            emoji: '🎉',
            left: size.width * 0.08,
            top: size.height * 0.10,
            size: 24,
            phaseOffset: 0.0),
        _EmojiPosition(
            emoji: '✨',
            left: size.width * 0.82,
            top: size.height * 0.08,
            size: 20,
            phaseOffset: 0.25),
        _EmojiPosition(
            emoji: '🎊',
            left: size.width * 0.70,
            top: size.height * 0.22,
            size: 22,
            phaseOffset: 0.5),
        _EmojiPosition(
            emoji: '⭐',
            left: size.width * 0.12,
            top: size.height * 0.28,
            size: 18,
            phaseOffset: 0.75),
        _EmojiPosition(
            emoji: '🌟',
            left: size.width * 0.88,
            top: size.height * 0.42,
            size: 20,
            phaseOffset: 0.3),
        _EmojiPosition(
            emoji: '🎈',
            left: size.width * 0.05,
            top: size.height * 0.55,
            size: 22,
            phaseOffset: 0.6),
        _EmojiPosition(
            emoji: '💫',
            left: size.width * 0.78,
            top: size.height * 0.65,
            size: 20,
            phaseOffset: 0.15),
        _EmojiPosition(
            emoji: '🎀',
            left: size.width * 0.20,
            top: size.height * 0.78,
            size: 18,
            phaseOffset: 0.85),
      ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: config.left,
      top: config.top,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final phase = (controller.value + config.phaseOffset) % 1.0;
          final float = math.sin(phase * 2 * math.pi) * 8;
          final opacity = 0.3 + 0.4 * math.sin(phase * math.pi).abs();
          return Transform.translate(
            offset: Offset(0, float),
            child: Opacity(
              opacity: opacity,
              child: Text(
                config.emoji,
                style: TextStyle(fontSize: config.size),
              ),
            ),
          );
        },
      ),
    );
  }
}