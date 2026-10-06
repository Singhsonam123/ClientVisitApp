# System Patterns

## Architecture Overview
```
Flutter App (BLoC + Repository)
        │
        │  HTTP (Dio)
        ▼
Node.js / Express API  (port 3000)
        │
        │  Mongoose
        ▼
MongoDB  (shutterfly_agenda database)
        +  /uploads  (static files on disk)
```

## Flutter Architecture

### Layer Structure (per feature)
```
features/<name>/
  data/           ← Repository (calls API via Dio)
  domain/
    models/       ← Pure Dart data models (Equatable)
  presentation/
    bloc/         ← BLoC (events, states, logic)
    pages/        ← UI widgets
```

### BLoC Pattern
- Every feature has its own BLoC, provided globally in `main.dart` via `MultiBlocProvider`
- BLoCs receive Repository instances via constructor injection
- States: Loading → Loaded / Error (+ feature-specific states like GalleryUploading, VotingSubmitting)

### Repository Pattern
- `GalleryRepository` — wraps Dio calls for photo CRUD
- `VotingRepository` — wraps Dio calls for votes
- `AuthRepository` — wraps SharedPreferences for session management (no API calls)

### Singleton API Client
- `lib/core/network/api_client.dart` — Dio singleton
- `baseUrl = 'http://10.0.2.2:3000'` for Android emulator
- **Change to LAN IP** (e.g. `192.168.x.x`) for real device testing
- Has `LogInterceptor` for debug logging

## Backend Architecture

### Express Routes
| Route | Method | Description |
|-------|--------|-------------|
| `/api/gallery` | GET | Fetch all photos (sorted by newest) |
| `/api/gallery/upload` | POST | Multipart upload; saves file + MongoDB doc |
| `/api/gallery/:id` | DELETE | Remove photo doc + file from disk |
| `/api/votes` | GET | Aggregated vote counts per candidate |
| `/api/votes/check/:employeeId` | GET | Check if employee has already voted |
| `/api/votes/cast` | POST | Cast vote; 409 if already voted |

### MongoDB Models
- **Photo**: `employeeId`, `employeeName`, `imagePath` (disk), `imageUrl` (public URL), `caption`, `dayLabel`, timestamps
- **Vote**: `employeeId` (unique index), `candidateId`, timestamps

### File Upload Flow
1. Flutter picks image → `image_picker`
2. Dio `FormData` multipart POST to `/api/gallery/upload`
3. `multer` saves file to `backend/uploads/<uuid>.jpg`
4. MongoDB doc saved with `imageUrl = http://<host>:3000/uploads/<filename>`
5. Flutter receives full photo JSON, adds to BLoC state

## Key Design Decisions
- **One vote per employee**: Enforced via MongoDB unique index on `employeeId` field in Vote collection. Returns HTTP 409 on duplicate.
- **imagePath dual-use**: `PhotoModel.imagePath` holds either a local file path (during upload preview) or a server URL (for persisted photos). `_buildPhotoImage()` in gallery_page detects `http` prefix to pick `Image.network` vs `Image.file`.
- **AuthBloc provides employeeId**: Both `VotingPage` and `GalleryPage` read `AuthBloc.state` to get the current employee's ID before dispatching events.
- **Candidates are hardcoded**: `CandidateModel` list is defined in `voting_page.dart`; vote counts are fetched from API and merged via `copyWith`.