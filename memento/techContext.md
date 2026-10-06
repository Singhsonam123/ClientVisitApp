# Tech Context

## Flutter App

### Flutter Version
- Requires Flutter SDK ≥ 3.x (uses Material 3, `withValues()` API)
- `minSdk = 21` (required by `mobile_scanner`)

### Key Dependencies (`pubspec.yaml`)
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `equatable` | ^2.0.5 | Value equality for BLoC states/events |
| `dio` | ^5.7.0 | HTTP client + multipart upload |
| `image_picker` | ^1.1.2 | Camera / gallery photo selection |
| `mobile_scanner` | ^5.2.3 | QR code scanning |
| `shared_preferences` | ^2.3.5 | Session persistence (auth) |
| `go_router` | ^14.8.1 | (Available, not actively used — navigation is manual) |
| `uuid` | (via backend) | Unique filenames for uploads |

### Project Structure
```
lib/
  core/
    constants/    app_constants.dart
    network/      api_client.dart       ← Dio singleton
    theme/        app_colors.dart, app_theme.dart, app_text_styles.dart
    widgets/      app_card.dart (EmptyState, AppCard)
  features/
    auth/         AuthBloc, AuthRepository, LoginPage, SplashPage
    home/         HomePage (BottomNav), DashboardPage
    agenda/       AgendaPage (3-day timeline)
    gallery/      GalleryBloc, GalleryRepository, GalleryPage
    voting/       VotingBloc, VotingRepository, VotingPage
    potluck/      PotluckPage (static)
    sweets/       SweetsPage, SweetDetailPage (QR scanner)
  main.dart       MultiBlocProvider root, _AppRouter
```

## Backend

### Stack
- **Runtime**: Node.js (LTS)
- **Framework**: Express 4.x
- **ODM**: Mongoose 8.x
- **File upload**: multer 1.x
- **Other**: cors, dotenv, uuid, nodemon (dev)

### Configuration (`backend/.env`)
```
PORT=3000
MONGO_URI=mongodb://localhost:27017/shutterfly_agenda
```

### Directory Layout
```
backend/
  models/
    Photo.js      ← Mongoose schema
    Vote.js       ← Mongoose schema (unique index on employeeId)
  routes/
    gallery.js    ← GET /api/gallery, POST /api/gallery/upload, DELETE /api/gallery/:id
    votes.js      ← GET /api/votes, GET /api/votes/check/:id, POST /api/votes/cast
  uploads/        ← Stored image files (gitignored)
  server.js       ← Express app entry point
  package.json
  .env            ← gitignored
  .gitignore
```

### Running the Backend
```bash
# Requires MongoDB running locally on port 27017
cd backend
npm start          # uses nodemon via "start" script
```

### API Base URL
- **Android emulator**: `http://10.0.2.2:3000`
- **Real device**: `http://<your-LAN-IP>:3000`
- Change in `lib/core/network/api_client.dart` → `static const String baseUrl`

## Development Setup
1. Start MongoDB: `mongod --dbpath /data/db` (or via Homebrew service)
2. Start backend: `cd backend && npm start`
3. Run Flutter: `flutter run` (Android emulator or device)
4. For real device: update `ApiClient.baseUrl` to LAN IP before running

## Known Constraints
- No HTTPS — plain HTTP; acceptable for internal demo/event use
- Images stored on local disk — no CDN; server restart does NOT lose DB refs but files must remain on disk
- `mobile_scanner` requires `minSdk = 21` (set in `android/app/build.gradle.kts`)