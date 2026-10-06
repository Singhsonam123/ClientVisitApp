import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 52)),
                  ),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.headlineLarge
                      .copyWith(color: AppColors.textOnPrimary),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text(
                  AppConstants.eventName,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.gold),
                  strokeWidth: 2.5,
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
