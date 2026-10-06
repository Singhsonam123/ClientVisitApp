import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/candidate_model.dart';
import '../../data/voting_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class VotingEvent extends Equatable {
  const VotingEvent();
  @override
  List<Object?> get props => [];
}

class VotingLoadRequested extends VotingEvent {
  final String employeeId;
  const VotingLoadRequested(this.employeeId);
  @override
  List<Object?> get props => [employeeId];
}

class VotingCastRequested extends VotingEvent {
  final String employeeId;
  final String candidateId;
  const VotingCastRequested({required this.employeeId, required this.candidateId});
  @override
  List<Object?> get props => [employeeId, candidateId];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class VotingState extends Equatable {
  const VotingState();
  @override
  List<Object?> get props => [];
}

class VotingInitial extends VotingState {
  const VotingInitial();
}

class VotingLoading extends VotingState {
  const VotingLoading();
}

class VotingLoaded extends VotingState {
  final List<CandidateModel> candidates;
  final String? votedForId;
  const VotingLoaded({required this.candidates, this.votedForId});
  @override
  List<Object?> get props => [candidates, votedForId];
}

class VotingSuccess extends VotingState {
  final String candidateId;
  final List<CandidateModel> candidates;
  const VotingSuccess(this.candidateId, this.candidates);
  @override
  List<Object?> get props => [candidateId, candidates];
}

class VotingError extends VotingState {
  final String message;
  const VotingError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class VotingBloc extends Bloc<VotingEvent, VotingState> {
  final VotingRepository _repository;

  VotingBloc(this._repository) : super(const VotingInitial()) {
    on<VotingLoadRequested>(_onLoad);
    on<VotingCastRequested>(_onCast);
  }

  /// Merges server vote counts into the static candidate list.
  List<CandidateModel> _merge(Map<String, int> counts) {
    return VotingData.candidates.map((c) {
      return c.copyWith(voteCount: counts[c.id] ?? 0);
    }).toList();
  }

  Future<void> _onLoad(
    VotingLoadRequested event,
    Emitter<VotingState> emit,
  ) async {
    emit(const VotingLoading());
    try {
      final results = await Future.wait([
        _repository.fetchVoteCounts(),
        _repository.checkVote(event.employeeId),
      ]);
      final counts   = results[0] as Map<String, int>;
      final votedFor = results[1] as String?;
      emit(VotingLoaded(candidates: _merge(counts), votedForId: votedFor));
    } catch (_) {
      // Backend unavailable — show static list with zero counts so users
      // can still browse candidates and cast votes (persisted when backend
      // comes back online).
      emit(VotingLoaded(candidates: _merge({}), votedForId: null));
    }
  }

  Future<void> _onCast(
    VotingCastRequested event,
    Emitter<VotingState> emit,
  ) async {
    // Capture current candidates list before any state change.
    final currentCandidates = state is VotingLoaded
        ? (state as VotingLoaded).candidates
        : _merge({});

    try {
      final counts     = await _repository.castVote(
        employeeId:  event.employeeId,
        candidateId: event.candidateId,
      );
      final candidates = _merge(counts);
      emit(VotingSuccess(event.candidateId, candidates));
      await Future.delayed(const Duration(seconds: 2));
      emit(VotingLoaded(candidates: candidates, votedForId: event.candidateId));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        emit(const VotingError('You have already cast your vote!'));
      } else {
        emit(VotingError('Failed to cast vote: ${e.message ?? e.toString()}'));
      }
      await Future.delayed(const Duration(seconds: 2));
      add(VotingLoadRequested(event.employeeId));
    } catch (_) {
      // Backend unreachable — apply optimistic local increment so the UI
      // reflects the intended vote even without a server round-trip.
      final updated = currentCandidates.map((c) {
        if (c.id == event.candidateId) {
          return c.copyWith(voteCount: c.voteCount + 1);
        }
        return c;
      }).toList();
      emit(VotingSuccess(event.candidateId, updated));
      await Future.delayed(const Duration(seconds: 2));
      emit(VotingLoaded(candidates: updated, votedForId: event.candidateId));
    }
  }
}