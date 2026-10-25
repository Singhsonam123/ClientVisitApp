import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../agenda/domain/models/agenda_item_model.dart';
import '../../../agenda/presentation/pages/agenda_page.dart';
import '../../../potluck/presentation/pages/potluck_page.dart';
import '../../../sweets/presentation/pages/sweets_page.dart';
import '../../../projects/data/models/project_model.dart';
// Dynamic imports — gallery commented out until backend is connected:
// import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../voting/presentation/pages/voting_page.dart';
import '../widgets/dashboard_top_bar.dart';

class DashboardPage extends StatelessWidget {
  final ProjectModel? selectedProject;
  final VoidCallback onProjectTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;
  final bool isSuperAdmin;
  final List<ProjectModel> projects;
  final Function(ProjectModel?) onProjectChanged;
  final VoidCallback onAddProject;
  final String subtitle;

  const DashboardPage({
    super.key,
    this.selectedProject,
    required this.onProjectTap,
    required this.onProfileTap,
    required this.onLogoutTap,
    this.isSuperAdmin = false,
    this.projects = const [],
    required this.onProjectChanged,
    required this.onAddProject,
    this.subtitle = 'Team Connect',
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final todayDayLabel = _eventDayLabel(DateTime.now());
    final highlights = AgendaData.items
        .where((i) => i.isHighlight && i.dayLabel == todayDayLabel)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: DashboardTopBar(
                greeting: '$greeting! 👋',
                subtitle: subtitle,
                projects: projects,
                selectedProject: selectedProject,
                onProjectChanged: onProjectChanged,
                onProfileTap: onProfileTap,
                onAddProject: onAddProject,
                isSuperAdmin: isSuperAdmin,
              ),
            ),
          ),

          // Quick access grid
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Quick Access'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      // Static screens — navigation enabled:
                      _QuickCard(
                        emoji: '📅',
                        label: 'Agenda',
                        color: AppColors.agendaTag,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AgendaPage()),
                        ),
                      ),
                      _QuickCard(
                        emoji: '🍽️',
                        label: 'Potluck',
                        color: AppColors.success,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PotluckPage()),
                        ),
                      ),
                      _QuickCard(
                        emoji: '🍬',
                        label: 'Sweets',
                        color: AppColors.primaryDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SweetsPage()),
                        ),
                      ),
                      // Dynamic screens — gallery commented out until backend is connected:
                      // _QuickCard(
                      //   emoji: '📸',
                      //   label: 'Gallery',
                      //   color: AppColors.primary,
                      //   onTap: () => Navigator.push(context,
                      //     MaterialPageRoute(builder: (_) => const GalleryPage())),
                      // ),
                      _QuickCard(
                        emoji: '🗳️',
                        label: 'Vote',
                        color: AppColors.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VotingPage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ),

          // Highlights — filtered to today's event day
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: '$todayDayLabel Highlights ⭐'),
                if (highlights.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Text(
                      'No highlights scheduled for today.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textHint),
                    ),
                  )
                else
                  ...highlights.map((item) => _HighlightCard(item: item)),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ),

          // Event Days section hidden — kept for future reference
          // SliverToBoxAdapter(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const SectionHeader(title: 'Event Days'),
          //       Padding(
          //         padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          //         child: Column(
          //           children: const [
          //             _DayCard(day: 'Day 1', title: EventDays.day1, emoji: '🍬', color: AppColors.primary),
          //             SizedBox(height: 10),
          //             _DayCard(day: 'Day 2', title: EventDays.day2, emoji: '👘', color: AppColors.secondary),
          //             SizedBox(height: 10),
          //             _DayCard(day: 'Day 3', title: EventDays.day3, emoji: '🍽️', color: AppColors.success),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          // ),
        ],
      ),
    );
  }

  void _showProfile(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final emp = authState.employee;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
                  style: AppTextStyles.headlineLarge
                      .copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(emp.name, style: AppTextStyles.headlineSmall),
              Text(emp.department,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.secondary)),
              const SizedBox(height: 4),
              Text(emp.email, style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              FestiveTag(
                label: emp.id,
                color: AppColors.primaryLight,
                textColor: AppColors.textOnPrimary,
                icon: Icons.badge_outlined,
              ),
              const Divider(height: 32),
              SizedBox(
                width: double.infinity,
                child: Builder(
                  builder: (ctx) => OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ctx.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    label: const Text('Sign Out',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  /// Optional tap handler — null means the card is not interactive.
  final VoidCallback? onTap;

  const _QuickCard({
    required this.emoji,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: onTap != null ? color.withOpacity(0.35) : AppColors.divider,
            ),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(onTap != null ? 0.15 : 0.07),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 22,
                      color: onTap != null ? null : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: onTap != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final AgendaItem item;
  const _HighlightCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cat = item.category;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cat.bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: cat.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(cat.icon, color: cat.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.cardTitle),
                Text(
                  '${item.dayLabel}  •  ${item.startTime}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: cat.color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Right-arrow removed — highlight cards are display-only on home screen
        ],
      ),
    );
  }
}

// _DayCard removed — Event Days section is hidden on dashboard.
// Preserved below for future reference if the section is re-enabled.
//
// class _DayCard extends StatelessWidget {
//   final String day;
//   final String title;
//   final String emoji;
//   final Color color;
//   const _DayCard({required this.day, required this.title, required this.emoji, required this.color});
//   @override
//   Widget build(BuildContext context) {
//     return Container( /* ... */ );
//   }
// }

/// Maps the current [date] to the event day label used in [AgendaItem.dayLabel].
///
/// Date → Day mapping:
///   5 Aug 2026           → Day 1
///   6 Aug 2026           → Day 2
///   7 Aug 2026           → Day 3
///   8–9 Aug 2026 (Wknd)  → Day 3  (last work day before weekend)
///   10 Aug 2026          → Day 5
///   11 Aug 2026          → Day 6
///   12 Aug 2026          → Day 7
///   13 Aug 2026+         → Day 8
String _eventDayLabel(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  if (d.compareTo(DateTime(2026, 8, 6)) < 0) return 'Day 1'; // ≤ 5 Aug
  if (d.compareTo(DateTime(2026, 8, 7)) < 0) return 'Day 2'; // 6 Aug
  if (d.compareTo(DateTime(2026, 8, 10)) < 0) return 'Day 3'; // 7–9 Aug
  if (d.compareTo(DateTime(2026, 8, 11)) < 0) return 'Day 5'; // 10 Aug
  if (d.compareTo(DateTime(2026, 8, 12)) < 0) return 'Day 6'; // 11 Aug
  if (d.compareTo(DateTime(2026, 8, 13)) < 0) return 'Day 7'; // 12 Aug
  return 'Day 8'; // 13 Aug+
}