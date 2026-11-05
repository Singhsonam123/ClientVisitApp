import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/models/employee_model.dart';
import '../bloc/gallery_bloc.dart';
import '../../domain/models/photo_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared image builder
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildPhotoImage(String path, {BoxFit fit = BoxFit.cover, String moderationStatus = 'APPROVED', String caption = ''}) {
  // Handle null or empty image URL - show placeholder with status and caption
  if (path.isEmpty || path == 'null') {
    final isPending = moderationStatus.toUpperCase() == 'PENDING';
    final isRejected = moderationStatus.toUpperCase() == 'REJECTED';
    
    return Container(
      color: AppColors.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined,
              color: AppColors.textHint, size: 40),
          const SizedBox(height: 8),
          if (isPending)
            const Text(
              'Pending Approval',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (isRejected)
            const Text(
              'Rejected',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                caption,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  if (path.startsWith('http')) {
    final isPending = moderationStatus.toUpperCase() == 'PENDING';
    final isRejected = moderationStatus.toUpperCase() == 'REJECTED';
    final headers = ApiClient.token != null
        ? {'Authorization': 'Bearer ${ApiClient.token}'}
        : <String, String>{};
    return CachedNetworkImage(
      imageUrl: path,
      httpHeaders: headers,
      fit: fit,
      placeholder: (_, __) => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surfaceVariant,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined,
                color: AppColors.textHint, size: 40),
            const SizedBox(height: 8),
            if (isPending)
              const Text(
                'Pending Approval',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (isRejected)
              const Text(
                'Rejected',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (caption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  caption,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  final isPending = moderationStatus.toUpperCase() == 'PENDING';
  final isRejected = moderationStatus.toUpperCase() == 'REJECTED';
  
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      color: AppColors.surfaceVariant,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined,
              color: AppColors.textHint, size: 40),
          const SizedBox(height: 8),
          if (isPending)
            const Text(
              'Pending Approval',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (isRejected)
            const Text(
              'Rejected',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                caption,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// GalleryPage
// ─────────────────────────────────────────────────────────────────────────────

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _selectedFilter = 'all'; // 'all', 'approved', 'pending', 'rejected'

  @override
  void initState() {
    super.initState();
    context.read<GalleryBloc>().add(const GalleryLoadRequested());
  }

  // ── Upload flow ─────────────────────────────────────────────────────────

  void _showSourcePicker() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.camera_alt_rounded,
                      color: AppColors.textOnPrimary),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUploadDialog(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.photo_library_rounded,
                      color: AppColors.textOnPrimary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick an existing photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showUploadDialog(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(ImageSource source) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    String caption = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(source == ImageSource.camera ? 'Take a Photo' : 'Upload Photo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Caption ───────────────────────────────────────────────
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Caption (optional)',
                  hintText: 'Add a caption to your photo…',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                maxLines: 2,
                onChanged: (v) => caption = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: Icon(source == ImageSource.camera
                ? Icons.camera_alt_rounded
                : Icons.photo_library_rounded),
            label: const Text('Upload'),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GalleryBloc>().add(
                    GalleryPhotoUploadRequested(
                      employeeId:   authState.employee.id,
                      employeeName: authState.employee.name,
                      caption:      caption.trim(),
                      source: source,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Fetch role from AuthBloc state
    final authState = context.read<AuthBloc>().state;
    final isEmployee = authState is AuthAuthenticated &&
        authState.employee.role == UserRole.employee;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<GalleryBloc>().add(const GalleryLoadRequested()),
          ),
        ],
      ),
      floatingActionButton: isEmployee
          ? FloatingActionButton.extended(
              onPressed: _showSourcePicker,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Upload'),
            )
          : null,
      body: BlocConsumer<GalleryBloc, GalleryState>(
        listener: (context, state) {
          if (state is GalleryUploadSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green.shade700,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
          } else if (state is GalleryUploadError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is GalleryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is GalleryError) {
            final isSessionExpired =
                state.message.toLowerCase().contains('session expired');
            return EmptyState(
              icon: isSessionExpired
                  ? Icons.lock_outline_rounded
                  : Icons.error_outline_rounded,
              title: state.message,
              subtitle: isSessionExpired
                  ? 'Your login session has ended.'
                  : null,
              action: isSessionExpired
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log Out & Sign In Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested()),
                    )
                  : null,
            );
          }

          final photos = state is GalleryLoaded
              ? state.photos
              : state is GalleryUploading
                  ? state.photos
                  : state is GalleryUploadError
                      ? state.photos
                      : <PhotoModel>[];

          if (state is GalleryUploading) {
            return Column(
              children: [
                const LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                ),
                Expanded(child: _buildAlbumSections(photos)),
              ],
            );
          }

          if (photos.isEmpty) {
            return const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No photos yet',
              subtitle: 'Be the first to share a photo to the project feed!',
            );
          }

          return Column(
            children: [
              // ── Filter chips ────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all', photos.length),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Approved',
                      'approved',
                      photos.where((p) => p.isApproved).length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Pending',
                      'pending',
                      photos.where((p) => p.isPending).length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Rejected',
                      'rejected',
                      photos.where((p) => p.isRejected).length,
                    ),
                  ],
                ),
              ),
              // ── Album sections ──────────────────────────────────────────
              Expanded(child: _buildAlbumSections(photos)),
            ],
          );
       },
     ),
   );
 }

  // ── Album-grouped layout ─────────────────────────────────────────────────

  Map<String, List<PhotoModel>> _groupByAlbum(List<PhotoModel> photos) {
    final map = <String, List<PhotoModel>>{};
    for (final p in photos) {
      final key = p.dayLabel.isNotEmpty ? p.dayLabel : 'General';
      (map[key] ??= []).add(p);
    }
    return map;
  }

  Future<void> _moderatePhoto(BuildContext context, PhotoModel photo, String status) async {
    if (!mounted) return;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              Text(
                'Processing...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final galleryBloc = context.read<GalleryBloc>();
      
      // Listen to bloc state changes to know when gallery is reloaded
      bool galleryReloaded = false;
      late StreamSubscription<GalleryState> subscription;
      
      subscription = galleryBloc.stream.listen((state) {
        if (state is GalleryLoaded && !galleryReloaded) {
          galleryReloaded = true;
          subscription.cancel();
          
          // Close the loading dialog after gallery is reloaded
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Show success snackbar
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Photo ${status.toLowerCase()} successfully',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: status == 'APPROVED' ? Colors.green.shade700 : Colors.red.shade700,
                  duration: const Duration(seconds: 3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
          }
        } else if (state is GalleryError && !galleryReloaded) {
          galleryReloaded = true;
          subscription.cancel();
          
          // Close the loading dialog on error
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  duration: const Duration(seconds: 4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
          }
        }
      });
      
      // Dispatch moderation event to GalleryBloc with projectId from photo
      galleryBloc.add(
        GalleryPhotoModerationRequested(
          projectId: photo.projectId,
          photoId: photo.id,
          status: status,
        ),
      );
    } catch (e) {
      // Close the loading dialog
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
      }
    }
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceVariant,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.textHint,
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  List<PhotoModel> _filterPhotos(List<PhotoModel> photos) {
    switch (_selectedFilter) {
      case 'approved':
        return photos.where((p) => p.isApproved).toList();
      case 'pending':
        return photos.where((p) => p.isPending).toList();
      case 'rejected':
        return photos.where((p) => p.isRejected).toList();
      default:
        return photos;
    }
  }

  Widget _buildAlbumSections(List<PhotoModel> photos) {
    // ── Filter photos based on selected filter ───────────────────────────
    final filteredPhotos = _filterPhotos(photos);
    
    // ── Separate photos by approval status ────────────────────────────────
    final pendingPhotos = filteredPhotos.where((p) => p.isPending).toList();
    final approvedPhotos = filteredPhotos.where((p) => p.isApproved).toList();
    final rejectedPhotos = filteredPhotos.where((p) => p.isRejected).toList();

    // ── Find the single most-liked photo across ALL APPROVED albums ───────
    PhotoModel? topPhoto;
    for (final p in approvedPhotos) {
      if (topPhoto == null || p.likeCount > topPhoto.likeCount) {
        topPhoto = p;
      }
    }

    final pendingAlbums = _groupByAlbum(pendingPhotos);
    final approvedAlbums = _groupByAlbum(approvedPhotos);
    final rejectedAlbums = _groupByAlbum(rejectedPhotos);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        // ── PENDING SECTION ──────────────────────────────────────────────
        if (pendingPhotos.isNotEmpty) ...[
          _StatusSectionHeader(
            title: 'Pending Approval',
            count: pendingPhotos.length,
            statusColor: Colors.orange,
            icon: Icons.hourglass_top_rounded,
          ),
          ...pendingAlbums.entries
              .map((e) => _AlbumSection(albumName: e.key, photos: e.value))
              .toList(),
        ],

        // ── APPROVED SECTION ─────────────────────────────────────────────
        if (approvedPhotos.isNotEmpty) ...[
          _StatusSectionHeader(
            title: 'Approved',
            count: approvedPhotos.length,
            statusColor: Colors.green,
            icon: Icons.check_circle_rounded,
          ),
          if (topPhoto != null && topPhoto.likeCount > 0)
            _MostLikedBanner(photo: topPhoto),
          ...approvedAlbums.entries
              .map((e) => _AlbumSection(albumName: e.key, photos: e.value))
              .toList(),
        ],

        // ── REJECTED SECTION ─────────────────────────────────────────────
        if (rejectedPhotos.isNotEmpty) ...[
          _StatusSectionHeader(
            title: 'Rejected',
            count: rejectedPhotos.length,
            statusColor: Colors.red,
            icon: Icons.cancel_rounded,
          ),
          ...rejectedAlbums.entries
              .map((e) => _AlbumSection(albumName: e.key, photos: e.value))
              .toList(),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatusSectionHeader — header for Pending/Approved sections
// ─────────────────────────────────────────────────────────────────────────────

class _StatusSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color statusColor;
  final IconData icon;

  const _StatusSectionHeader({
    required this.title,
    required this.count,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  // Text(
                  //   '$count photo${count == 1 ? '' : 's'} awaiting review',
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w500,
                  //     color: statusColor.withOpacity(0.7),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MostLikedBanner  — trophy card showing the album with most total likes
// ─────────────────────────────────────────────────────────────────────────────

class _MostLikedBanner extends StatelessWidget {
  final PhotoModel photo;

  const _MostLikedBanner({required this.photo});

  @override
  Widget build(BuildContext context) {
    final albumLabel =
        photo.dayLabel.isNotEmpty ? photo.dayLabel : 'General';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40FFA500),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Photo thumbnail ──────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: _buildPhotoImage(photo.imagePath, fit: BoxFit.cover, moderationStatus: photo.moderationStatus, caption: photo.caption),
                ),
              ),
              // Trophy badge overlay
              const Positioned(
                top: 0,
                left: 0,
                child: Text('🏆', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // ── Text info ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MOST LIKED PHOTO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                // Caption / title
                Text(
                  photo.caption.isNotEmpty ? photo.caption : 'No caption',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Uploader · Album
                // Text(
                //   '${photo.employeeName} · $albumLabel',
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.85),
                //     fontSize: 11,
                //     fontWeight: FontWeight.w500,
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Like count badge ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(height: 2),
                Text(
                  '${photo.likeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// _AlbumSection  — header + 2-column grid for one album
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumSection extends StatelessWidget {
  final String albumName;
  final List<PhotoModel> photos;

  const _AlbumSection({required this.albumName, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Album header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: AppColors.festiveGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  albumName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${photos.length} photo${photos.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── 2-column grid ────────────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.65,
          ),
          itemCount: photos.length,
          itemBuilder: (_, index) => _PhotoCard(photo: photos[index]),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PhotoCard
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  final PhotoModel photo;

  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreen(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image container ─────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo
                    _buildPhotoImage(photo.imagePath, fit: BoxFit.cover, moderationStatus: photo.moderationStatus, caption: photo.caption),

                    // Like button in top-right corner
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _LikeButton(photo: photo, mini: true),
                    ),

                    // Three-dot menu for ADMIN moderation (top-right, below like button)
                    if (_isAdminAndPending(context))
                      Positioned(
                        top: 50,
                        right: 8,
                        child: _ModerationMenu(
                          photo: photo,
                          onModerate: (status) {
                            final pageState = context.findAncestorStateOfType<_GalleryPageState>();
                            pageState?._moderatePhoto(context, photo, status);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Caption and employee name below image ────────────────────────
          const SizedBox(height: 8),
          if (photo.caption.isNotEmpty)
            Text(
              photo.caption,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            photo.employeeName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Full-screen dialog ───────────────────────────────────────────────────

  bool _isAdminAndPending(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated &&
        (authState.employee.role == UserRole.admin ||
            authState.employee.role == UserRole.superAdmin) &&
        photo.isPending;
  }

  void _showFullScreen(BuildContext context) {
    final galleryBloc = context.read<GalleryBloc>();

    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: galleryBloc,
        child: Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Full-screen image
              Center(
                child: _buildPhotoImage(photo.imagePath, fit: BoxFit.contain, moderationStatus: photo.moderationStatus, caption: photo.caption),
              ),

              // Close button (top-right)
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 30),
                ),
              ),

              // Bottom bar: caption + like
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Caption — only shown when non-empty
                          if (photo.caption.isNotEmpty) ...[
                            Text(
                              photo.caption,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'by ${photo.employeeName}'
                            '${photo.dayLabel.isNotEmpty ? " · ${photo.dayLabel}" : ""}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<GalleryBloc, GalleryState>(
                      builder: (ctx, state) {
                        final photos = state is GalleryLoaded
                            ? state.photos
                            : state is GalleryUploading
                                ? state.photos
                                : <PhotoModel>[];
                        final current = photos.firstWhere(
                          (p) => p.id == photo.id,
                          orElse: () => photo,
                        );
                        return _LikeButton(photo: current, mini: false);
                      },
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// _ModerationMenu — Three-dot menu for ADMIN to approve/reject pending photos
// ─────────────────────────────────────────────────────────────────────────────

class _ModerationMenu extends StatelessWidget {
  final PhotoModel photo;
  final Function(String) onModerate;

  const _ModerationMenu({
    required this.photo,
    required this.onModerate,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color.fromARGB(153, 0, 0, 0),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          color: Colors.white,
          size: 10,
        ),
      ),
      onSelected: (value) {
        onModerate(value);
      },
      itemBuilder: (BuildContext context) => const [
        PopupMenuItem<String>(
          value: 'APPROVED',
          child: Row(
            children: [
              Icon(Icons.check_rounded, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Approve'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'REJECTED',
          child: Row(
            children: [
              Icon(Icons.close_rounded, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Reject'),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LikeButton
// ─────────────────────────────────────────────────────────────────────────────

class _LikeButton extends StatelessWidget {
  final PhotoModel photo;
  final bool mini;

  const _LikeButton({required this.photo, required this.mini});

  @override
  Widget build(BuildContext context) {
    final liked    = photo.likedByCurrentUser;
    final count    = photo.likeCount;
    final iconSize = mini ? 18.0 : 26.0;
    final textSize = mini ? 10.0 : 14.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<GalleryBloc>().add(
              GalleryPhotoLikeToggleRequested(
                photoId:          photo.id,
                isCurrentlyLiked: liked,
                albumName:        photo.dayLabel,
              ),
            );
      },
      child: Padding(
        padding: EdgeInsets.all(mini ? 4 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(liked),
                color: liked ? Colors.redAccent : Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: textSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}