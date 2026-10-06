# Progress

## What Works ✅

### Flutter App
- [x] Splash screen with animated logo
- [x] Login page (mock credentials, SharedPreferences session)
- [x] Auth BLoC (login, logout, session restore on app start)
- [x] Home page with BottomNavigationBar (Dashboard, Agenda, Gallery, Potluck, Voting tabs)
- [x] Dashboard page with event highlights and feature cards
- [x] Agenda page — 3-day timeline with session cards
- [x] Potluck page — static menu list by category
- [x] Sweets page — QR scanner reveals sweet details
- [x] Gallery page — grid view with day-filter chips, upload FAB
- [x] Gallery BLoC — `GalleryLoadRequested`, `GalleryPhotoUploadRequested` events; Loading / Uploading / Loaded / Error states
- [x] Voting page — candidate cards with vote counts, cast vote button
- [x] Voting BLoC — `VotingLoadRequested` (with employeeId), `VotingCastRequested` (employeeId + candidateId); handles 409 duplicate vote
- [x] `image_picker` integration in GalleryBloc for photo selection
- [x] Network image rendering in gallery (`_buildPhotoImage` handles http vs file path)

### Backend
- [x] Node.js + Express server (`backend/server.js`)
- [x] MongoDB connection via Mongoose
- [x] `Photo` model with Mongoose schema
- [x] `Vote` model with unique index on `employeeId`
- [x] Gallery routes: GET all, POST upload (multer), DELETE by ID
- [x] Votes routes: GET aggregated counts, GET check by employeeId, POST cast
- [x] Static file serving for `/uploads`
- [x] CORS enabled for all origins
- [x] `backend/.gitignore` (excludes node_modules, uploads, .env)
- [x] `backend/uploads/` directory created

### Integration
- [x] `ApiClient` (Dio singleton) configured with `baseUrl = http://10.0.2.2:3000`
- [x] `GalleryRepository` — fetches photos, uploads multipart, deletes
- [x] `VotingRepository` — fetches counts, checks vote, casts vote
- [x] `main.dart` — repositories injected into BLoCs via `MultiBlocProvider`
- [x] `flutter pub get` — dio resolved successfully
- [x] `npm install` — backend packages installed
- [x] `flutter analyze` — **zero errors** (65 info warnings, all pre-existing)

## What's Left / Optional 🔲

### Must Do Before Demo
- [ ] **Start MongoDB** and run `cd backend && npm start` before testing
- [ ] **End-to-end test** on Android emulator (gallery upload + vote persistence)
- [ ] **Real device**: change `ApiClient.baseUrl` in `lib/core/network/api_client.dart` to LAN IP

### Nice to Have
- [ ] Delete photo button in Gallery UI (backend DELETE route exists, no UI)
- [ ] Pull-to-refresh on Gallery and Voting pages
- [ ] Fix remaining `info` warnings (`withOpacity` → `withValues`, `prefer_const_constructors`)
- [ ] Fix deprecated `DropdownButtonFormField value:` → `initialValue:` (needs StatefulBuilder dialog)
- [ ] Pagination for gallery if photos grow large
- [ ] Error retry button on GalleryError / VotingError states

## Known Issues
- `withOpacity` deprecation warnings across multiple pages (cosmetic, no runtime impact)
- `DropdownButtonFormField value:` deprecation in gallery upload dialog (cosmetic)
- `avoid_print` warning in `api_client.dart` (LogInterceptor uses print — acceptable for dev)
- Backend has 1 moderate npm audit vulnerability (non-critical for internal event use)