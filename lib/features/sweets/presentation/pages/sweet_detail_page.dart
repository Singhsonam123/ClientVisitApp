import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/sweet_model.dart';

class SweetDetailPage extends StatelessWidget {
  final SweetModel sweet;
  const SweetDetailPage({super.key, required this.sweet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(sweet.name),
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroCard(sweet: sweet),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'The Specialty',
              icon: Icons.info_outline_rounded,
              content: sweet.description,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Ingredients',
              icon: Icons.restaurant_menu_rounded,
              content: sweet.ingredients,
            ),
            const SizedBox(height: 12),
            _FunFactCard(funFact: sweet.funFact),
            if (sweet.allergens.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Allergens',
                icon: Icons.warning_amber_rounded,
                content: sweet.allergens.join(' • '),
                contentColor: AppColors.warning,
                iconColor: AppColors.warning,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final SweetModel sweet;
  const _HeroCard({required this.sweet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sweetsCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(sweet.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 12),
          Text(sweet.name,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          FestiveTag(
            label: sweet.origin,
            color: AppColors.primary,
            textColor: Colors.white,
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FestiveTag(
                label: sweet.isVegetarian ? '🥬 Vegetarian' : '🍖 Non-Veg',
                color: sweet.isVegetarian
                    ? AppColors.successLight
                    : AppColors.errorLight,
                textColor:
                    sweet.isVegetarian ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 8),
              FestiveTag(
                label: sweet.calories,
                color: AppColors.surfaceVariant,
                textColor: AppColors.textSecondary,
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FunFactCard extends StatelessWidget {
  final String funFact;
  const _FunFactCard({required this.funFact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Interesting Fact',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(funFact,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final Color? contentColor;
  final Color? iconColor;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.content,
    this.contentColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionHeader),
            ],
          ),
          const SizedBox(height: 8),
          Text(content,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: contentColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}