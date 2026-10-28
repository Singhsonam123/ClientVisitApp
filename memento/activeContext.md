# Active Context

## Current Status
**Gallery Upload Button - EMPLOYEE Role Only.** Upload button now visible exclusively to EMPLOYEE role users, hidden from ADMIN and SUPER_ADMIN roles.

## What Was Just Completed (This Session)

### Gallery Upload Button - EMPLOYEE Role Visibility
- Updated [`lib/features/gallery/presentation/pages/gallery_page.dart`](lib/features/gallery/presentation/pages/gallery_page.dart:341-370):
  - Added import: `import '../../../auth/domain/models/employee_model.dart'` for `UserRole` enum
  - Changed role check from `!isAdmin` to `isEmployee` (lines 344-345)
  - Now checks: `authState.employee.role == UserRole.employee`
  - Upload FAB now visible **only to EMPLOYEE role**, hidden from ADMIN and SUPER_ADMIN
  - Flutter analyze: **zero errors** (16 pre-existing info warnings only)

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
