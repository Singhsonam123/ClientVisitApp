import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/photo_model.dart';
import '../../data/gallery_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class GalleryEvent extends Equatable {
  const GalleryEvent();
  @override
  List<Object?> get props => [];
}

class GalleryLoadRequested extends GalleryEvent {
  const GalleryLoadRequested();
}

class GalleryPhotoUploadRequested extends GalleryEvent {
  final String employeeId;
  final String employeeName;
  final String albumName;
  final String caption;
  final ImageSource source;
  const GalleryPhotoUploadRequested({
    required this.employeeId,
    required this.employeeName,
    required this.albumName,
    required this.caption,
    this.source = ImageSource.gallery,
  });
  @override
  List<Object?> get props =>
      [employeeId, employeeName, albumName, caption, source];
}

/// Toggles the like state of [photoId].
/// [albumName] is required so the bloc can enforce the "one like per album" rule.
class GalleryPhotoLikeToggleRequested extends GalleryEvent {
  final String photoId;
  final bool isCurrentlyLiked;
  final String albumName;
  const GalleryPhotoLikeToggleRequested({
    required this.photoId,
    required this.isCurrentlyLiked,
    required this.albumName,
  });
  @override
  List<Object?> get props => [photoId, isCurrentlyLiked, albumName];
}

/// Deletes [photoId] from the server. Should only be dispatched by the uploader.
class GalleryPhotoDeleteRequested extends GalleryEvent {
  final String photoId;
  const GalleryPhotoDeleteRequested({required this.photoId});
  @override
  List<Object?> get props => [photoId];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class GalleryState extends Equatable {
  const GalleryState();
  @override
  List<Object?> get props => [];
}

class GalleryInitial extends GalleryState {
  const GalleryInitial();
}

class GalleryLoading extends GalleryState {
  const GalleryLoading();
}

class GalleryLoaded extends GalleryState {
  final List<PhotoModel> photos;
  const GalleryLoaded(this.photos);
  @override
  List<Object?> get props => [photos];
}

class GalleryError extends GalleryState {
  final String message;
  const GalleryError(this.message);
  @override
  List<Object?> get props => [message];
}

class GalleryUploading extends GalleryState {
  final List<PhotoModel> photos;
  const GalleryUploading(this.photos);
  @override
  List<Object?> get props => [photos];
}

/// Emitted transiently when an upload fails so the UI can show a snackbar
/// without losing the existing photo list.
class GalleryUploadError extends GalleryState {
  final String message;
  final List<PhotoModel> photos;
  const GalleryUploadError({required this.message, required this.photos});
  @override
  List<Object?> get props => [message, photos];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepository _repository;
  final ImagePicker _picker = ImagePicker();

  GalleryBloc(this._repository) : super(const GalleryInitial()) {
    on<GalleryLoadRequested>(_onLoad);
    on<GalleryPhotoUploadRequested>(_onUpload);
    on<GalleryPhotoLikeToggleRequested>(_onLikeToggle);
    on<GalleryPhotoDeleteRequested>(_onDelete);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    GalleryLoadRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(const GalleryLoading());
    try {
      final photos = await _repository.fetchPhotos();
      emit(GalleryLoaded(photos));
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        emit(const GalleryError(
            'Session expired. Please log out and log in again.'));
      } else {
        final msg = _extractErrorMessage(
          e,
          fallback: 'Failed to load gallery. Please try again.',
        );
        emit(GalleryError(msg));
      }
    }
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  Future<void> _onUpload(
    GalleryPhotoUploadRequested event,
    Emitter<GalleryState> emit,
  ) async {
    final current = state is GalleryLoaded
        ? (state as GalleryLoaded).photos
        : <PhotoModel>[];
    emit(GalleryUploading(current));

    try {
      final picked = await _picker.pickImage(
        source: event.source,
        imageQuality: 80,
      );
      if (picked == null) {
        emit(GalleryLoaded(current));
        return;
      }

      await _repository.uploadPhoto(
        filePath:     picked.path,
        employeeId:   event.employeeId,
        employeeName: event.employeeName,
        caption:      event.caption,
        albumName:    event.albumName,
      );

      // Re-fetch so all albums are reflected.
      final photos = await _repository.fetchPhotos();
      emit(GalleryLoaded(photos));
    } catch (e) {
      final msg = _extractErrorMessage(e, fallback: 'Upload failed. Please try again.');
      emit(GalleryUploadError(message: msg, photos: current));
      await Future.delayed(const Duration(milliseconds: 100));
      emit(GalleryLoaded(current));
    }
  }

  // ── Like toggle ───────────────────────────────────────────────────────────

  Future<void> _onLikeToggle(
    GalleryPhotoLikeToggleRequested event,
    Emitter<GalleryState> emit,
  ) async {
    final current = _currentPhotos;
    if (current.isEmpty) return;

    if (!event.isCurrentlyLiked) {
      // ── Liking ────────────────────────────────────────────────────────────
      // Enforce "one like per album": find any other photo in the same album
      // that the user has already liked and unlike it first.
      final prevLiked = current
          .where((p) =>
              p.id != event.photoId &&
              p.dayLabel == event.albumName &&
              p.likedByCurrentUser)
          .toList();

      // Optimistic: unlike all prev + like target
      var optimistic = current;
      for (final p in prevLiked) {
        optimistic = _applyLikeOptimistic(
            photos: optimistic, photoId: p.id, liked: false);
      }
      optimistic = _applyLikeOptimistic(
          photos: optimistic, photoId: event.photoId, liked: true);
      emit(GalleryLoaded(optimistic));

      try {
        for (final p in prevLiked) {
          await _repository.unlikePhoto(p.id);
        }
        await _repository.likePhoto(event.photoId);
        final refreshed = await _repository.fetchPhotos();
        emit(GalleryLoaded(refreshed));
      } catch (_) {
        emit(GalleryLoaded(current));
      }
    } else {
      // ── Unliking ──────────────────────────────────────────────────────────
      final optimistic = _applyLikeOptimistic(
        photos:  current,
        photoId: event.photoId,
        liked:   false,
      );
      emit(GalleryLoaded(optimistic));

      try {
        await _repository.unlikePhoto(event.photoId);
        final refreshed = await _repository.fetchPhotos();
        emit(GalleryLoaded(refreshed));
      } catch (_) {
        emit(GalleryLoaded(current));
      }
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _onDelete(
    GalleryPhotoDeleteRequested event,
    Emitter<GalleryState> emit,
  ) async {
    final current = _currentPhotos;
    // Optimistically remove from list immediately.
    final optimistic =
        current.where((p) => p.id != event.photoId).toList();
    emit(GalleryLoaded(optimistic));

    try {
      await _repository.deletePhoto(event.photoId);
      // Re-fetch to get the authoritative server state.
      final refreshed = await _repository.fetchPhotos();
      emit(GalleryLoaded(refreshed));
    } catch (_) {
      // Revert on error.
      emit(GalleryLoaded(current));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extracts a human-readable message from a [DioException] by reading
  /// `detail` > `message` > `error` from the response body, or falls back to
  /// [fallback] for network/unknown errors.
  String _extractErrorMessage(Object e, {required String fallback}) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final detail  = data['detail']  as String?;
        final message = data['message'] as String?;
        final error   = data['error']   as String?;
        if (detail?.isNotEmpty == true)  return detail!;
        if (message?.isNotEmpty == true) return message!;
        if (error?.isNotEmpty == true)   return error!;
      }
      // Network-level error (no response)
      if (e.response == null) return 'Network error. Please check your connection.';
      return fallback;
    }
    return fallback;
  }

  List<PhotoModel> get _currentPhotos {
    if (state is GalleryLoaded) return (state as GalleryLoaded).photos;
    if (state is GalleryUploading) return (state as GalleryUploading).photos;
    return [];
  }

  List<PhotoModel> _applyLikeOptimistic({
    required List<PhotoModel> photos,
    required String photoId,
    required bool liked,
  }) {
    return photos.map((p) {
      if (p.id != photoId) return p;
      return p.copyWith(
        likedByCurrentUser: liked,
        likeCount: liked ? p.likeCount + 1 : (p.likeCount - 1).clamp(0, 9999),
      );
    }).toList();
  }
}