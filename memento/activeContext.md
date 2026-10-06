# Active Context

## Current Status
**MongoDB full-stack integration is complete.** The Flutter app and Node.js backend are fully wired. All code changes have been applied and verified with `flutter analyze` (zero errors, 65 info-level warnings only).

## What Was Just Completed (This Session)
1. **`main.dart`** — Updated `MultiBlocProvider` to instantiate `GalleryRepository()` and `VotingRepository()` and inject into `GalleryBloc` and `VotingBloc`
2. **`gallery_page.dart`** — Fixed image rendering: replaced all `Image.file()` calls with `_buildPhotoImage()` helper that detects HTTP URLs vs local file paths and uses `Image.network` or `Image.file` accordingly
3. **`backend/.gitignore`** — Created to exclude `node_modules/`, `uploads/`, `.env`
4. **`backend/uploads/`** — Created directory for multer file storage
5. **`flutter pub get`** — Run successfully; `dio: ^5.7.0` resolved
6. **`cd backend && npm install`** — Run successfully; all Node packages installed
7. **Memento files** — Created all 6 core memento files from scratch

## Active Decisions
- `PhotoModel.imagePath` is reused for both local paths and server URLs (dual-use field)
- `_buildPhotoImage()` is a top-level function in `gallery_page.dart` (not a widget class) to keep it lean
- `DropdownButtonFormField` still uses deprecated `value:` parameter (minor warning; fixing requires `StatefulBuilder` dialog — deferred)

## Ready to Test
The system is ready for end-to-end testing. Prerequisites:
1. MongoDB running locally on port 27017
2. Backend running: `cd backend && npm start`
3. Flutter on Android emulator: `flutter run`

## Next Steps
1. **End-to-end test** — run backend + emulator, test gallery upload and voting persistence
2. **Real device test** — update `ApiClient.baseUrl` in [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart) to LAN IP
3. **Optional cleanup** — fix remaining `info` warnings (`withOpacity` → `withValues`, `prefer_const_constructors`) across other pages
4. **Optional: `DELETE` photo from gallery UI** — backend route exists (`DELETE /api/gallery/:id`) but no UI button yet
5. **Optional: Pull-to-refresh** on GalleryPage and VotingPage