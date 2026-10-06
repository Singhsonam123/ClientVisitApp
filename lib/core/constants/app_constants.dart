/// Global constants for the Shutterfly Agenda app.
class AppConstants {
  AppConstants._();

  // ── App Info ─────────────────────────────────────────────────────────
  static const String appName = 'Shutterfly Connect';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Shutterfly';

  // ── Event Info ────────────────────────────────────────────────────────
  static const String eventName = 'Shutterfly Team Connect';
  static const String eventDate = 'August 2026';
  static const String eventLocation = 'Shutterfly Office';

  // ── SharedPreferences Keys ────────────────────────────────────────────
  static const String prefKeyIsLoggedIn    = 'is_logged_in';
  static const String prefKeyEmployeeId    = 'employee_id';
  static const String prefKeyEmployeeName  = 'employee_name';
  static const String prefKeyEmployeeEmail = 'employee_email';
  static const String prefKeyEmployeeDept  = 'employee_dept';
  /// Bearer token returned by POST /auth/signin
  static const String prefKeyAuthToken     = 'auth_token';
  /// Album ID of the shared event album (auto-created on first upload)
  static const String prefKeyAlbumId       = 'event_album_id';
  static const String prefKeyVotedFor      = 'voted_for';
  static const String prefKeyUploadedPhotos = 'uploaded_photos';

  // ── Event Album ───────────────────────────────────────────────────────
  static const String eventAlbumName =
      'Shutterfly Annual Celebration 2026';
  static const String eventAlbumDescription =
      'Memories from the 3-day celebration';

  // ── Navigation Routes ─────────────────────────────────────────────────
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeAgenda = '/agenda';
  static const String routeGallery = '/gallery';
  static const String routePotluck = '/potluck';
  static const String routeVoting = '/voting';
  static const String routeSweets = '/sweets';
  static const String routeSweetDetail = '/sweets/detail';
  static const String routeQrScanner = '/qr-scanner';
  static const String routeProfile = '/profile';

  // ── Padding / Spacing ──────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // ── Border Radius ─────────────────────────────────────────────────
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 100.0;

  // ── Icon Sizes ────────────────────────────────────────────────────
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // ── Animation Durations ───────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ── Mock Credentials ──────────────────────────────────────────────
  static const String demoEmployeeId = 'EMP001';
  static const String demoPassword = 'shutterfly@2026';
}

/// Day labels for the multi-day event.
class EventDays {
  EventDays._();
  static const String day1 = 'Day 1 – Sweets & Welcome';
  static const String day2 = 'Day 2 – Traditional Day';
  static const String day3 = 'Day 3 – Potluck & Celebration';
}