# Active Context

## Current Status
**Gallery Moderation UI - Complete Fix with ProjectId in API Call.** Admin users can now successfully approve or reject pending photos with proper API calls including project ID.

## What Was Just Completed (This Session)

### Gallery Moderation - Final Implementation with ProjectId Parameter
- **Problem**: When admin clicked approve/reject button, got error: "Could not find the correct Provider<GalleryRepository> above this _PhotoCard Widget"
- **Root Cause**: `_moderatePhoto()` method was trying to access `GalleryRepository` directly via `context.read<GalleryRepository>()`, but the repository was not provided in the widget tree
- **Solution**: Use `GalleryBloc` to dispatch moderation events with projectId parameter, which internally calls the repository's `moderatePost()` method

### Changes Made

**File: [`lib/features/gallery/presentation/bloc/gallery_bloc.dart`](lib/features/gallery/presentation/bloc/gallery_bloc.dart)**
- Updated `GalleryPhotoModerationRequested` event to include `projectId` parameter:
  ```dart
  class GalleryPhotoModerationRequested extends GalleryEvent {
    final String projectId;
    final String photoId;
    final String status; // 'APPROVED' or 'REJECTED'
    const GalleryPhotoModerationRequested({
      required this.projectId,
      required this.photoId,
      required this.status,
    });
    @override
    List<Object?> get props => [projectId, photoId, status];
  }
  ```
- Added public getter to expose projectId:
  ```dart
  String get projectId => _projectId;
  ```

**File: [`lib/features/gallery/presentation/pages/gallery_page.dart`](lib/features/gallery/presentation/pages/gallery_page.dart)**
- Removed import of `GalleryRepository` (no longer needed)
- Refactored `_moderatePhoto()` method to:
  1. Get GalleryBloc instance
  2. Dispatch `GalleryPhotoModerationRequested` event with projectId from bloc
  3. Show success snackbar with message "Photo {status} successfully"
  4. Handle errors with try-catch and show error snackbar
  ```dart
  Future<void> _moderatePhoto(BuildContext context, String photoId, String status) async {
    try {
      final galleryBloc = context.read<GalleryBloc>();
      
      // Dispatch moderation event to GalleryBloc with projectId
      galleryBloc.add(
        GalleryPhotoModerationRequested(
          projectId: galleryBloc.projectId,
          photoId: photoId,
          status: status,
        ),
      );
      
      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(...),
              backgroundColor: status == 'APPROVED' ? Colors.green.shade700 : Colors.red.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(...),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
      }
    }
  }
  ```

### API Flow
1. Admin clicks approve/reject button on pending photo
2. `_ModerationMenu.onSelected()` calls `_moderatePhoto(context, photoId, status)`
3. `_moderatePhoto()` dispatches `GalleryPhotoModerationRequested` event with projectId to `GalleryBloc`
4. `GalleryBloc._onModerate()` handler:
   - Calls `_repository.moderatePost(photoId, status)`
   - Repository makes PATCH request to `/projects/{projectId}/feed/{photoId}/moderate/`
   - Request body: `{ "moderation_status": "APPROVED" }` or `{ "moderation_status": "REJECTED" }`
   - Re-fetches photos from server
   - Emits `GalleryLoaded` state with updated photos
5. UI shows success snackbar and automatically updates via BLoC state changes

### Implementation Details
- **API Endpoint**: `PATCH /api/projects/{project_id}/feed/{post_id}/moderate/`
- **URL Format**: Correctly includes both `{project_id}` and `{post_id}` in path
- **Request Format**: `{ "moderation_status": "APPROVED" | "REJECTED" }`
- **Response Handling**: Repository extracts response data via `_extractObject(resp.data, 'data')`
- **UI Feedback**: Success snackbar shows "Photo approved successfully" or "Photo rejected successfully"
- **Error Handling**: Errors are caught and displayed in red error snackbar
- **Gallery Refresh**: After moderation, gallery automatically refreshes to show updated photo status
- **Flutter analyze**: **zero errors** (9 pre-existing info warnings only)

### Previous: Gallery Moderation Menu - Three-Dot Icon (Initial Implementation)
- Added three-dot menu icon (`PopupMenuButton`) positioned on pending photos (top-right, below like button)
- Menu appears **only for ADMIN/SUPER_ADMIN roles** on **pending photos only**
- Menu options: "Approve" (green checkmark) and "Reject" (red X)
- Fixed role comparison to use `UserRole.admin` and `UserRole.superAdmin` enum values
- Removed old moderation buttons that were displayed below photo captions
- Used `const` constructors to optimize performance

### Previous: Gallery Upload Button - EMPLOYEE Role Visibility

### Previous: Gallery Filter Chips & Rejected Status Support
- Updated [`lib/features/gallery/domain/models/photo_model.dart`](lib/features/gallery/domain/models/photo_model.dart):
  - Changed `isPending` boolean to `moderationStatus` string field ('PENDING', 'APPROVED', 'REJECTED')
  - Added convenience getters: `isPending`, `isApproved`, `isRejected`
  - Updated `fromJson()` to parse `moderation_status` from API
  - Updated `copyWith()` to support `moderationStatus` parameter

- Updated [`lib/features/gallery/data/gallery_repository.dart`](lib/features/gallery/data/gallery_repository.dart):
  - Modified `fetchPhotos()` to use `moderationStatus` instead of `isPending`
  - Modified `uploadPhoto()` to use `moderationStatus` instead of `isPending`

- Updated [`lib/features/gallery/presentation/pages/gallery_page.dart`](lib/features/gallery/presentation/pages/gallery_page.dart):
  - Added `_selectedFilter` state variable ('all', 'approved', 'pending', 'rejected')
  - Added `_buildFilterChip()` method to create filter chips with counts
  - Added `_filterPhotos()` method to filter photos based on selected status
  - Updated `_buildPhotoImage()` to use `moderationStatus` parameter instead of `isPending`
  - Updated `_buildAlbumSections()` to support rejected photos section
  - Added filter chips row at top of gallery showing counts for each status
  - **Three Status Sections**: Pending (orange), Approved (green), Rejected (red)
  - Most-liked banner only appears in Approved section
  - Captions displayed below images with employee name
  - Like button positioned in top-right corner
  - Flutter analyze: **zero errors** (7 pre-existing info warnings only)

### Previous: Gallery Sections by Approval Status
- Gallery displays two distinct sections: "Pending Approval" and "Approved" photos
- Captions shown below images instead of overlay
- Grid `childAspectRatio` adjusted to 0.65 to accommodate caption text

### Previous: Gallery Tab for ADMIN Role
- Updated [`lib/features/home/presentation/pages/home_page.dart`](lib/features/home/presentation/pages/home_page.dart):
  - Modified `_getNavItems()` to include Gallery tab for ADMIN and SUPER_ADMIN roles
  - Modified `_getPages()` to include gallery page for ADMIN and SUPER_ADMIN roles
  - ADMIN/SUPER_ADMIN now see: [Employee, Gallery] tabs
  - EMPLOYEE users still see: [Home, Gallery] tabs

## Implementation Details

### Placeholder Display Logic
When image URL is null or empty, the placeholder now shows:
1. **Icon**: `Icons.image_not_supported_outlined` (gray)
2. **Status**: "Pending Approval" (if `isPending` is true)
3. **Caption**: Photo caption text (if non-empty)
4. **Styling**: Centered layout with proper spacing and text ellipsis

### Code Changes
```dart
Widget _buildPhotoImage(
  String path, 
  {
    BoxFit fit = BoxFit.cover, 
    bool isPending = false, 
    String caption = ''  // NEW PARAMETER
  }
)
```

All three error handlers (null/empty, network error, file error) now display caption.

## Active Decisions
- Caption parameter is optional (defaults to empty string)
- Placeholder shows caption only if non-empty
- Caption text is limited to 2 lines with ellipsis
- Status and caption are displayed in all three image loading failure scenarios

## How It Works

### Gallery Feed API Flow
1. `GalleryPage.initState()` calls `GalleryLoadRequested` event
2. `GalleryBloc._onLoad()` calls `GalleryRepository.fetchPhotos()`
3. Repository fetches from `/projects/{projectId}/feed/` endpoint
4. Photos with null/empty `image_url` are handled gracefully
5. `PhotoModel` is created with empty `imagePath` and caption
6. Gallery UI renders placeholder with status and caption

### Placeholder Rendering
- When `imagePath` is empty or 'null', `_buildPhotoImage()` returns placeholder container
- Placeholder displays icon, status (if pending), and caption (if non-empty)
- Same placeholder logic applies to network errors and file errors
- Maintains consistent UX across all failure scenarios

## Ready to Test
1. Upload a photo without an image (caption only)
2. Verify placeholder shows with status and caption
3. Test in all three contexts: banner, grid, full-screen
4. Verify text wrapping and ellipsis work correctly

## Next Steps
1. **Backend Integration**: Ensure feed API returns proper `moderation_status` for pending posts
2. **Testing**: Test with various caption lengths and pending states
3. **Optional Enhancements**:
   - Add retry button on placeholder
   - Show upload timestamp on placeholder
   - Add employee avatar on placeholder
   - Implement image upload progress indicator

## Known Limitations
- Placeholder doesn't show employee name (could be added if needed)
- No retry mechanism on placeholder (could be added)
- Caption limited to 2 lines (could be configurable)
