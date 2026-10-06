# Product Context

## Why This Project Exists
Shutterfly hosts an annual employee celebration spanning 3 days. This app centralises all event information and social features so employees don't need to check emails/PDFs for the schedule, and can share memories in real-time.

## Problems It Solves
- Fragmented communication (agenda on email, photos on WhatsApp, voting on paper)
- No shared persistent gallery — photos lost when app closes
- No tamper-proof voting — employees could vote multiple times

## How It Works
1. Employee opens app → sees splash screen → taps to continue
2. Login with employee ID + password (mock credentials, session persisted via SharedPreferences)
3. Home dashboard shows 4 feature tiles: Agenda, Gallery, Potluck, Voting
4. **Agenda**: 3-day timeline with session cards (speaker, time, location)
5. **Gallery**: Grid of photos fetched from MongoDB; FAB opens upload dialog → picks image → uploads via multipart to Node.js → stored on disk + URL in MongoDB
6. **Potluck**: Static menu list of employee contributions by category
7. **Voting**: Shows candidates with current vote counts from MongoDB aggregation; employee casts one vote (enforced server-side + unique index); 409 response if already voted
8. **Sweets**: QR-code scanner reveals sweet details

## User Experience Goals
- Festive, warm colour palette (gradient purples/pinks)
- Fast load — BLoC handles loading states with progress indicators
- Offline-graceful — errors shown with empty-state widgets, not crashes
- Single-screen-at-a-time navigation via BottomNavigationBar on HomePage