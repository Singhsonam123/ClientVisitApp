import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/agenda_item_model.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = AgendaData.days;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 58),
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.gold, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_month_rounded, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text('Event Agenda', style: AppTextStyles.appBarTitle),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.gold,
                  indicatorWeight: 3,
                  labelColor: AppColors.gold,
                  unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tabs: _days.map((d) => Tab(text: d)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) => _DayAgendaList(day: day)).toList(),
      ),
    );
  }
}

class _DayAgendaList extends StatelessWidget {
  final String day;
  const _DayAgendaList({required this.day});

  bool get _isWeekend => day.startsWith('Weekend');

  @override
  Widget build(BuildContext context) {
    if (_isWeekend) {
      return const _WeekendExploreView();
    }
    final items = AgendaData.itemsForDay(day);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) => _AgendaCard(item: items[index]),
    );
  }
}

// ── Weekend Explore View ───────────────────────────────────────────────────────

class _WeekendExploreView extends StatelessWidget {
  const _WeekendExploreView();

  @override
  Widget build(BuildContext context) {
    final satVenues = AgendaData.weekendVenues
        .where((v) => v.dayLabel.startsWith('Saturday'))
        .toList();
    final sunVenues = AgendaData.weekendVenues
        .where((v) => v.dayLabel.startsWith('Sunday'))
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Header banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          child: Row(
            children: [
              const Text('🏖️', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekend City Explore',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '8–9 Aug  •  Hyderabad Sightseeing',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Saturday section
        _DaySection(
          dayTitle: '🗓️  Saturday, 8 Aug',
          subtitle: 'Old City heritage & shopping',
          venues: satVenues,
        ),

        // Sunday section
        _DaySection(
          dayTitle: '🗓️  Sunday, 9 Aug',
          subtitle: 'Temples, lake & nightlife',
          venues: sunVenues,
        ),
      ],
    );
  }
}

class _DaySection extends StatefulWidget {
  final String dayTitle;
  final String subtitle;
  final List<WeekendVenue> venues;

  const _DaySection({
    required this.dayTitle,
    required this.subtitle,
    required this.venues,
  });

  @override
  State<_DaySection> createState() => _DaySectionState();
}

class _DaySectionState extends State<_DaySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Expandable header ────────────────────────────────────────
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dayTitle,
                        style: AppTextStyles.headlineSmall
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Chevron indicator
                AnimatedRotation(
                  turns: _expanded ? 0.0 : -0.25,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Animated venue list ──────────────────────────────────────
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              ...widget.venues.map((v) => _VenueCard(venue: v)),
              const SizedBox(height: 8),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),

        const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}

class _VenueCard extends StatelessWidget {
  final WeekendVenue venue;
  const _VenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: venue.accentColor.withOpacity(0.25),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusL),
            ),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                venue.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: venue.accentColor.withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                        color: venue.accentColor,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: venue.accentColor.withOpacity(0.12),
                  child: Center(
                    child: Text(
                      venue.emoji,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: venue.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        venue.emoji,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        venue.name,
                        style: AppTextStyles.cardTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  venue.description,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Regular Agenda Card ────────────────────────────────────────────────────────

class _AgendaCard extends StatelessWidget {
  final AgendaItem item;
  const _AgendaCard({required this.item});

  void _showDetail(BuildContext context) {
    final cat = item.category;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cat.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.headlineSmall),
                      Text(
                        item.startTime == item.endTime
                            ? item.startTime
                            : '${item.startTime} – ${item.endTime}',
                        style: AppTextStyles.timeLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.description, style: AppTextStyles.bodyMedium),
            if (item.speaker != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Speaker',
                value: item.speaker!,
              ),
            ],
            if (item.venue != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Venue',
                value: item.venue!,
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = item.category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.startTime,
                      style: AppTextStyles.timeLabel.copyWith(fontSize: 11)),
                  if (item.endTime != item.startTime)
                    Text(item.endTime,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.isHighlight ? cat.color : AppColors.border,
                    shape: BoxShape.circle,
                    border: Border.all(color: cat.color, width: 1.5),
                  ),
                ),
                Expanded(
                  child: Container(width: 2, color: AppColors.divider),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: item.isHighlight ? cat.bgColor : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(
                    color: item.isHighlight
                        ? cat.color.withOpacity(0.4)
                        : AppColors.divider,
                    width: item.isHighlight ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.isHighlight
                          ? cat.color.withOpacity(0.1)
                          : AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    onTap: () => _showDetail(context),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cat.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(cat.icon, size: 11, color: cat.color),
                                    const SizedBox(width: 4),
                                    Text(cat.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: cat.color,
                                        )),
                                  ],
                                ),
                              ),
                              if (item.isHighlight) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.star_rounded,
                                    size: 14, color: AppColors.gold),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.title, style: AppTextStyles.cardTitle),
                          if (item.venue != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(item.venue!,
                                      style: AppTextStyles.cardSubtitle),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}