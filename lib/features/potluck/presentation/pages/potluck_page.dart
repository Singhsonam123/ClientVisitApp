import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/potluck_item_model.dart';

class PotluckPage extends StatefulWidget {
  const PotluckPage({super.key});

  @override
  State<PotluckPage> createState() => _PotluckPageState();
}

class _PotluckPageState extends State<PotluckPage> {
  FoodCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final items = PotluckData.itemsByCategory(_selectedCategory);
    final categories = PotluckData.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Potluck Menu \u{1F37D}\uFE0F'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // ── Category filter chips ─────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = null),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: _selectedCategory == null
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    checkmarkColor: AppColors.textOnPrimary,
                  );
                }
                final cat = categories[index - 1];
                final isSelected = _selectedCategory == cat;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon,
                          size: 14,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              : cat.color),
                      const SizedBox(width: 4),
                      Text(cat.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(
                      () => _selectedCategory = isSelected ? null : cat),
                  selectedColor: cat.color,
                  backgroundColor: cat.bgColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : cat.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  checkmarkColor: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // ── Item list ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _PotluckCard(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _PotluckCard extends StatelessWidget {
  final PotluckItem item;
  const _PotluckCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _showDetail(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail — image if available, icon fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: Container(
              width: 72,
              height: 72,
              color: item.category.bgColor,
              child: item.imagePath != null
                  ? Image.asset(
                      item.imagePath!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          _CategoryIconBox(item: item, size: 72),
                    )
                  : _CategoryIconBox(item: item, size: 72),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish name
                Text(item.dishName, style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                // Category label
                Text(
                  item.category.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: item.category.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                // Flavour profile
                if (item.flavourProfile.isNotEmpty) ...[
                  Text(
                    item.flavourProfile,
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: item.category.color,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                // Description
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: AppTextStyles.cardSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
            children: [
              // ── Hero image ────────────────────────────────────────────
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: item.category.bgColor,
                  child: item.imagePath != null
                      ? Image.asset(
                          item.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(item.category.icon,
                                color: item.category.color, size: 72),
                          ),
                        )
                      : Center(
                          child: Icon(item.category.icon,
                              color: item.category.color, size: 72),
                        ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dish name
                    Text(item.dishName, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 4),

                    // Category label
                    Text(
                      item.category.label,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: item.category.color,
                          fontWeight: FontWeight.w600),
                    ),

                    // Description
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(item.description,
                          style: AppTextStyles.bodyMedium),
                    ],

                    const Divider(height: 28),

                    // Origin
                    if (item.origin.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: 'Origin',
                        value: item.origin,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Flavour profile
                    if (item.flavourProfile.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.local_dining_rounded,
                        label: 'Flavour',
                        value: item.flavourProfile,
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _CategoryIconBox extends StatelessWidget {
  final PotluckItem item;
  final double size;
  const _CategoryIconBox({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: item.category.bgColor,
      child: Icon(item.category.icon,
          color: item.category.color, size: size * 0.5),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondary)),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}