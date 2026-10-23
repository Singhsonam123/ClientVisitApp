import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Central Dio HTTP client with configurable base URL and bearer-token support.
///
/// ## Base URL (priority order)
/// 1. `--dart-define=API_URL=http://localhost:3000/api`  ← override at build/run time
/// 2. Falls back to `http://localhost:3000/api` ← localhost default for development
///
/// ## Override at run time
/// ```
/// # For localhost
/// flutter run --dart-define=API_URL=http://localhost:3000/api
///
/// # For Android emulator
/// flutter run --dart-define=API_URL=http://10.0.2.2:3000/api
///
/// # For production
/// flutter run --dart-define=API_URL=https://api-photoshare.valuelabs.com/api
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
  /// Defaults to 10.0.2.2 for Android emulator (special alias for host machine).
  /// For iOS simulator, use: flutter run --dart-define=API_URL=http://127.0.0.1:3000/api
  /// For physical device, use your Mac's LAN IP: flutter run --dart-define=API_URL=http://192.168.x.x:3000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  // ── Bearer token ──────────────────────────────────────────────────────────
  static String? _token;
  static String? _refreshToken;
  static bool _isRefreshing = false;
  static Function? _onSessionExpired;

  /// Store the bearer token after successful sign-in.
  static void setToken(String? token) => _token = token;

  /// Store the refresh token after successful sign-in.
  static void setRefreshToken(String? token) => _refreshToken = token;

  /// Set a callback to be invoked when session expires (401 after failed refresh)
  static void setOnSessionExpired(Function callback) => _onSessionExpired = callback;

  /// The currently active bearer token (null if not signed in).
  static String? get token => _token;

  /// The currently active refresh token (null if not signed in).
  static String? get refreshToken => _refreshToken;

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
          print('[API] Current token: $_token');
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
            print('[API] Authorization header set: Bearer ${_token!.substring(0, 20)}...');
          } else {
            print('[API] WARNING: No token available for request');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized responses
          if (error.response?.statusCode == 401) {
            print('[API] 401 Unauthorized received');
            
            // Avoid multiple simultaneous refresh attempts
            if (!_isRefreshing) {
              _isRefreshing = true;
              try {
                print('[API] Attempting to refresh token using refresh token: ${_refreshToken?.substring(0, 20)}...');
                
                // Try to refresh the token
                final refreshed = await _refreshAccessToken();
                
                if (refreshed) {
                  print('[API] Token refreshed successfully');
                  _isRefreshing = false;
                  
                  // Retry the original request with new token
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $_token';
                  return handler.resolve(await _dio.request(
                    options.path,
                    options: Options(
                      method: options.method,
                      headers: options.headers,
                      contentType: options.contentType,
                    ),
                    data: options.data,
                    queryParameters: options.queryParameters,
                  ));
                } else {
                  print('[API] Token refresh failed - session expired');
                  _isRefreshing = false;
                  
                  // Invoke session expired callback if set
                  if (_onSessionExpired != null) {
                    print('[API] Invoking session expired callback');
                    _onSessionExpired!();
                  }
                  
                  // Token refresh failed, proceed with error
                  return handler.next(error);
                }
              } catch (e) {
                print('[API] Exception during token refresh: $e');
                _isRefreshing = false;
                
                // Invoke session expired callback if set
                if (_onSessionExpired != null) {
                  print('[API] Invoking session expired callback due to exception');
                  _onSessionExpired!();
                }
                
                return handler.next(error);
              }
            } else {
              // Wait for the refresh to complete
              print('[API] Token refresh already in progress, waiting...');
              await Future.delayed(const Duration(milliseconds: 500));
              
              // Retry with the new token
              final options = error.requestOptions;
              if (_token != null) {
                options.headers['Authorization'] = 'Bearer $_token';
                return handler.resolve(await _dio.request(
                  options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                    contentType: options.contentType,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters,
                ));
              }
              return handler.next(error);
            }
          }
          
          return handler.next(error);
        },
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => print('[API] $o'), // ignore: avoid_print
      ),
    ]);

  static Dio get instance => _dio;

  // ── Token Refresh ─────────────────────────────────────────────────────────
  /// Attempts to refresh the access token using the refresh token.
  /// Returns true if successful, false otherwise.
  static Future<bool> _refreshAccessToken() async {
    try {
      if (_refreshToken == null || _refreshToken!.isEmpty) {
        print('[API] No refresh token available');
        return false;
      }

      print('[API] Sending refresh token request');
      final response = await _dio.post(
        '/auth/refresh/',
        data: {'refresh_token': _refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['access_token'] as String?
            ?? data['token'] as String?
            ?? '';

        if (newToken.isNotEmpty) {
          _token = newToken;
          
          // Save new token to SharedPreferences
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(AppConstants.prefKeyAuthToken, newToken);
            print('[API] New token saved to SharedPreferences');
          } catch (e) {
            print('[API] Failed to save token to SharedPreferences: $e');
          }

          print('[API] Token refreshed successfully');
          return true;
        }
      }

      print('[API] Token refresh failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('[API] Token refresh exception: $e');
      return false;
    }
  }

  // ── HTTP Methods ──────────────────────────────────────────────────────────

  /// Perform a GET request
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform a POST request
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform a PATCH request
  static Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Perform a DELETE request
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Perform a PUT request
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
