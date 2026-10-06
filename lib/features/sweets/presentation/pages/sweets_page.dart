import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/sweet_model.dart';
import 'sweet_detail_page.dart';

class SweetsPage extends StatelessWidget {
  const SweetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sweets Showcase 🍬'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: SweetsData.sweets.length,
              itemBuilder: (context, index) {
                return _SweetGridCard(sweet: SweetsData.sweets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SweetGridCard extends StatelessWidget {
  final SweetModel sweet;
  const _SweetGridCard({required this.sweet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SweetDetailPage(sweet: sweet))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.sweetsCard,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppConstants.radiusL)),
                ),
                child: Center(
                  child: Text(sweet.emoji,
                      style: const TextStyle(fontSize: 52)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sweet.name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(sweet.origin,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}