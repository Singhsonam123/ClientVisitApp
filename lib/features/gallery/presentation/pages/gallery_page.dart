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
import '../bloc/gallery_bloc.dart';
import '../../domain/models/photo_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared image builder
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildPhotoImage(String path, {BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('http')) {
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
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.textHint, size: 40),
      ),
    );
  }
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, __, ___) => Container(
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.broken_image_outlined,
          color: AppColors.textHint, size: 40),
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
  @override
  void initState() {
    super.initState();
    context.read<GalleryBloc>().add(const GalleryLoadRequested());
  }

  /// Returns sorted unique album names from the current BLoC state.
  List<String> _existingAlbums() {
    final state = context.read<GalleryBloc>().state;
    final photos = state is GalleryLoaded
        ? state.photos
        : state is GalleryUploading
            ? state.photos
            : <PhotoModel>[];
    final names = photos
        .map((p) => p.dayLabel.isNotEmpty ? p.dayLabel : 'General')
        .toSet()
        .toList()
      ..sort();
    return names;
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

    final existingAlbums = _existingAlbums();
    // Sentinel value used in dropdown to represent "create new album"
    const kNewAlbum = '__new__';

    String caption           = '';
    // Default: first existing album or sentinel if none exist
    String dropdownValue     = existingAlbums.isNotEmpty ? existingAlbums.first : kNewAlbum;
    String newAlbumName      = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final isNewAlbum = dropdownValue == kNewAlbum;

          // Dropdown items: existing albums + divider + "Create new album"
          final dropdownItems = <DropdownMenuItem<String>>[
            ...existingAlbums.map((name) => DropdownMenuItem(
                  value: name,
                  child: Text(name, overflow: TextOverflow.ellipsis),
                )),
            if (existingAlbums.isNotEmpty)
              const DropdownMenuItem<String>(
                enabled: false,
                value: '__divider__',
                child: Divider(height: 1),
              ),
            const DropdownMenuItem<String>(
              value: kNewAlbum,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Create new album',
                      style: TextStyle(color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ];

          return AlertDialog(
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
                      hintText: 'Add a caption…',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                    maxLines: 2,
                    onChanged: (v) => caption = v,
                  ),
                  const SizedBox(height: 20),

                  // ── Album dropdown ────────────────────────────────────────
                  const Text(
                    'Album',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: dropdownValue,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.photo_album_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                    ),
                    items: dropdownItems,
                    onChanged: (v) {
                      if (v == null || v == '__divider__') return;
                      setDlgState(() => dropdownValue = v);
                    },
                  ),

                  // ── Reset selection (shown when an existing album is chosen) ──
                  if (!isNewAlbum)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.restart_alt_rounded, size: 16),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () =>
                            setDlgState(() => dropdownValue = kNewAlbum),
                      ),
                    ),

                  // ── New-album text field (shown when "Create new album" selected) ──
                  if (isNewAlbum) ...[
                    const SizedBox(height: 16),
                    TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (v) => setDlgState(() => newAlbumName = v),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'New Album Name *',
                        labelStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        hintText: 'e.g. Day 1, Team Outing…',
                        prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded,
                            color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.primaryLight.withOpacity(0.15),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),
                    if (newAlbumName.trim().isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 6, left: 4),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 13, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Album name is required to continue.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
                label: Text(source == ImageSource.camera
                    ? 'Open Camera'
                    : 'Choose Photo'),
                onPressed: (isNewAlbum && newAlbumName.trim().isEmpty)
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        final resolvedAlbum = isNewAlbum
                            ? newAlbumName.trim()
                            : dropdownValue;
                        context.read<GalleryBloc>().add(
                              GalleryPhotoUploadRequested(
                                employeeId:   authState.employee.id,
                                employeeName: authState.employee.name,
                                albumName:    resolvedAlbum,
                                caption:      caption.trim(),
                                source: source,
                              ),
                            );
                      },
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSourcePicker,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Upload'),
      ),
      body: BlocConsumer<GalleryBloc, GalleryState>(
        listener: (context, state) {
          if (state is GalleryUploadError) {
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
              subtitle: 'Be the first to upload a memory from the event!',
            );
          }

          return _buildAlbumSections(photos);
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

  Widget _buildAlbumSections(List<PhotoModel> photos) {
    final albums = _groupByAlbum(photos);

    // ── Find the single most-liked photo across ALL albums ────────────────
    PhotoModel? topPhoto;
    for (final p in photos) {
      if (topPhoto == null || p.likeCount > topPhoto.likeCount) {
        topPhoto = p;
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (topPhoto != null && topPhoto.likeCount > 0)
          _MostLikedBanner(photo: topPhoto),
        ...albums.entries
            .map((e) => _AlbumSection(albumName: e.key, photos: e.value))
            .toList(),
      ],
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
                  child: _buildPhotoImage(photo.imagePath, fit: BoxFit.cover),
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
                Text(
                  '${photo.employeeName} · $albumLabel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
            childAspectRatio: 0.85,
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
              _buildPhotoImage(photo.imagePath, fit: BoxFit.cover),

              // Bottom gradient overlay: caption + like button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 6, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Caption — only shown when non-empty
                            if (photo.caption.isNotEmpty)
                              Text(
                                photo.caption,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              photo.employeeName,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _LikeButton(photo: photo, mini: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Full-screen dialog ───────────────────────────────────────────────────

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
                child: _buildPhotoImage(photo.imagePath, fit: BoxFit.contain),
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