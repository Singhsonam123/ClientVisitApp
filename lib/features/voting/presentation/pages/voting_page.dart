import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/models/candidate_model.dart';
import '../bloc/voting_bloc.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  bool _showResults = false;
  final TextEditingController _searchController = TextEditingController();

  String _employeeId(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.employee.id : '';
  }

  @override
  void initState() {
    super.initState();
    context
        .read<VotingBloc>()
        .add(VotingLoadRequested(_employeeId(context)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CandidateModel> _filter(List<CandidateModel> all, String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.designation.toLowerCase().contains(q) ||
          c.team.toLowerCase().contains(q) ||
          c.projectName.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.empId.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Best Attire Vote 🗳️'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.secondaryGradient),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => setState(() => _showResults = !_showResults),
            child: Text(
              _showResults ? 'Vote' : 'Results',
              style: const TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
      body: BlocConsumer<VotingBloc, VotingState>(
        listener: (context, state) {
          if (state is VotingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Vote cast successfully! 🎉'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
          }
          if (state is VotingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
          }
        },
        builder: (context, state) {
          if (state is VotingInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.secondary));
          }

          List<CandidateModel> candidates = [];
          String? votedForId;

          if (state is VotingLoaded) {
            candidates = state.candidates;
            votedForId = state.votedForId;
          } else if (state is VotingSuccess) {
            candidates = state.candidates;
            votedForId = state.candidateId;
          } else if (state is VotingError) {
            final prevState = context.read<VotingBloc>().state;
            if (prevState is VotingLoaded) {
              candidates = prevState.candidates;
              votedForId = prevState.votedForId;
            }
          }

          if (candidates.isEmpty) {
            return const EmptyState(
              icon: Icons.how_to_vote_outlined,
              title: 'Voting not available',
            );
          }

          final hasVoted = votedForId != null;
          final totalVotes =
              candidates.fold<int>(0, (sum, c) => sum + c.voteCount);

          return Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondaryDark, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Row(
                  children: [
                    const Text('👘', style: TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasVoted
                                ? 'Thanks for voting! 🎉'
                                : 'Vote for Best Attire',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: Colors.white),
                          ),
                          Text(
                            hasVoted
                                ? 'Total votes: $totalVotes'
                                : 'One vote per employee  ',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search bar ──────────────────────────────────────────────
              // ValueListenableBuilder drives the suffix-icon and the list
              // directly from the controller — no setState needed.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, __) {
                    return TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, team, designation…',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textHint),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary, size: 20),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    size: 18, color: AppColors.textSecondary),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.secondary, width: 1.5),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Count + list (react to search changes via ValueListenable) ──
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, __) {
                    final query = value.text.trim();
                    final filtered = _filter(candidates, query);

                    return Column(
                      children: [
                        // Count / hint row
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                '${filtered.length} member${filtered.length == 1 ? '' : 's'}',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              if (!hasVoted && !_showResults)
                                const Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                    SizedBox(width: 4),
                                    Text('Tap a card to vote'),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // List
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 48,
                                          color: AppColors.textHint),
                                      SizedBox(height: 8),
                                      Text(
                                        'No members found',
                                        style: TextStyle(
                                            color: AppColors.textHint),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding:
                                      const EdgeInsets.only(bottom: 24),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final candidate = filtered[index];
                                    final isVoted =
                                        votedForId == candidate.id;
                                    final pct = totalVotes == 0
                                        ? 0.0
                                        : candidate.voteCount / totalVotes;
                                    final rank =
                                        candidates.indexOf(candidate) + 1;

                                    return _showResults || hasVoted
                                        ? _ResultCard(
                                            candidate: candidate,
                                            percent: pct,
                                            isVoted: isVoted,
                                            totalVotes: totalVotes,
                                            rank: rank,
                                          )
                                        : _VoteCard(
                                            candidate: candidate,
                                            onVote: () => _confirmVote(
                                                context, candidate),
                                          );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmVote(BuildContext context, CandidateModel candidate) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Vote'),
        content: Text(
          'Cast your vote for ${candidate.name}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VotingBloc>().add(
                    VotingCastRequested(
                      employeeId: _employeeId(context),
                      candidateId: candidate.id,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary),
            child: const Text('Vote!'),
          ),
        ],
      ),
    );
  }
}

class _VoteCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback onVote;
  const _VoteCard({required this.candidate, required this.onVote});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onVote,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            child: Text(candidate.emoji,
                style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(candidate.name, style: AppTextStyles.cardTitle),
                if (candidate.designation.isNotEmpty)
                  Text(candidate.designation,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.secondary)),
                const SizedBox(height: 2),
                if (candidate.team.isNotEmpty || candidate.projectName.isNotEmpty)
                  Text(
                    [
                      if (candidate.team.isNotEmpty) candidate.team,
                      if (candidate.projectName.isNotEmpty) candidate.projectName,
                    ].join(' • '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                if (candidate.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    candidate.email.toLowerCase(),
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('VOTE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final CandidateModel candidate;
  final double percent;
  final bool isVoted;
  final int totalVotes;
  final int rank;

  const _ResultCard({
    required this.candidate,
    required this.percent,
    required this.isVoted,
    required this.totalVotes,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final pctInt = (percent * 100).toInt();
    return AppCard(
      border: isVoted
          ? Border.all(color: AppColors.secondary, width: 2)
          : null,
      color: isVoted
          ? AppColors.secondary.withValues(alpha: 0.05)
          : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? AppColors.gold
                      : rank == 2
                              ? AppColors.secondary.withValues(alpha: 0.4)
                          : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank == 1 ? '🥇' : rank == 2 ? '🥈' : '#$rank',
                    style: TextStyle(
                      fontSize: rank <= 2 ? 16 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(candidate.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate.name, style: AppTextStyles.cardTitle),
                    if (candidate.designation.isNotEmpty)
                      Text(candidate.designation,
                          style: AppTextStyles.bodySmall
                              .copyWith(fontSize: 11)),
                    if (candidate.team.isNotEmpty || candidate.projectName.isNotEmpty)
                      Text(
                        [
                          if (candidate.team.isNotEmpty) candidate.team,
                          if (candidate.projectName.isNotEmpty) candidate.projectName,
                        ].join(' • '),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$pctInt%',
                      style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700)),
                  Text('${candidate.voteCount} votes',
                      style: AppTextStyles.bodySmall),
                ],
              ),
              if (isVoted) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.secondary, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: percent.clamp(0.0, 1.0),
            backgroundColor: AppColors.divider,
            progressColor:
                isVoted ? AppColors.secondary : AppColors.primary,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}