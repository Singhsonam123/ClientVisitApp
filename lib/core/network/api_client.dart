import 'package:dio/dio.dart';

/// Central Dio HTTP client with configurable base URL and bearer-token support.
///
/// ## Base URL (priority order)
/// 1. `--dart-define=API_URL=https://custom-host.com/api`  ← override at build/run time
/// 2. Falls back to `https://api-photoshare.valuelabs.com/api` ← production default
///
/// ## Override at run time
/// ```
/// flutter run --dart-define=API_URL=https://other-host.com/api
/// ```
///
/// ## Set token after sign-in
/// ```dart
/// ApiClient.setToken(token);
/// ```
/// Every subsequent Dio request will carry `Authorization: Bearer <token>`.
class ApiClient {
  ApiClient._();

  // ── Configurable base URL ─────────────────────────────────────────────────
  /// Injected at build/run time via `--dart-define=API_URL=...`
  /// Defaults to the production server when no override is provided.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api-photoshare.valuelabs.com/api',
  );

  // ── Bearer token ──────────────────────────────────────────────────────────
  static String? _token;

  /// Store the bearer token after successful sign-in.
  static void setToken(String? token) => _token = token;

  /// The currently active bearer token (null if not signed in).
  static String? get token => _token;

  // ── Dio singleton ─────────────────────────────────────────────────────────
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.addAll([
      // Inject Authorization header on every request when a token is present.
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => print('[API] $o'), // ignore: avoid_print
      ),
    ]);

  static Dio get instance => _dio;
}