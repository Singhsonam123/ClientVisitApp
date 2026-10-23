import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/employee_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

const String _prefKeySelectedRole = 'selected_role';
const String _prefKeyUserRole = 'user_role';

/// Handles authentication against the configurable API (POST /auth/signup,
/// POST /auth/signin) plus SharedPreferences session persistence.
///
/// ## API contract
/// | Method | Path            | Body                            | Response           |
/// |--------|-----------------|---------------------------------|--------------------|
/// | POST   | /auth/signup    | {email,password,displayName}    | {id}               |
/// | POST   | /auth/signin    | {email,password}                | {token, ...}       |
class AuthRepository {
  final SharedPreferences _prefs;
  final Dio _dio = ApiClient.instance;

  AuthRepository(this._prefs);

  // ── Session ───────────────────────────────────────────────────────────────

  EmployeeModel? get currentEmployee {
    final isLoggedIn = _prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;
    print('[AUTH] currentEmployee getter called - isLoggedIn: $isLoggedIn');
    if (!isLoggedIn) {
      print('[AUTH] User not logged in');
      return null;
    }
    final id    = _prefs.getString(AppConstants.prefKeyEmployeeId);
    final name  = _prefs.getString(AppConstants.prefKeyEmployeeName);
    final email = _prefs.getString(AppConstants.prefKeyEmployeeEmail);
    final dept  = _prefs.getString(AppConstants.prefKeyEmployeeDept);
    final roleStr = _prefs.getString(_prefKeyUserRole);
    if (id == null || name == null || email == null || dept == null) {
      print('[AUTH] Missing employee data - id: $id, name: $name, email: $email, dept: $dept');
      return null;
    }

    // Restore token into ApiClient so subsequent requests are authenticated.
    final token = _prefs.getString(AppConstants.prefKeyAuthToken);
    print('[AUTH] Retrieved token from SharedPreferences: ${token?.substring(0, 20)}...');
    if (token != null && token.isNotEmpty) {
      ApiClient.setToken(token);
      print('[AUTH] Token restored to ApiClient');
    } else {
      print('[AUTH] WARNING: No token found in SharedPreferences');
    }

    // Restore refresh token into ApiClient
    final refreshToken = _prefs.getString(AppConstants.prefKeyRefreshToken);
    print('[AUTH] Retrieved refresh token from SharedPreferences: ${refreshToken?.substring(0, 20)}...');
    if (refreshToken != null && refreshToken.isNotEmpty) {
      ApiClient.setRefreshToken(refreshToken);
      print('[AUTH] Refresh token restored to ApiClient');
    } else {
      print('[AUTH] WARNING: No refresh token found in SharedPreferences');
    }

    final role = roleStr != null ? UserRoleExtension.fromString(roleStr) : UserRole.employee;
    return EmployeeModel(id: id, name: name, email: email, department: dept, role: role);
  }

  bool get isLoggedIn => _prefs.getBool(AppConstants.prefKeyIsLoggedIn) ?? false;

  UserRole? get selectedRole {
    final roleStr = _prefs.getString(_prefKeySelectedRole);
    if (roleStr == null) return null;
    return UserRoleExtension.fromString(roleStr);
  }

  Future<void> saveSelectedRole(UserRole role) async {
    await _prefs.setString(_prefKeySelectedRole, role.value);
  }

  Future<void> _saveSession(EmployeeModel employee, String token, {String? refreshToken}) async {
    print('[AUTH] Saving session with token: ${token.substring(0, 20)}...');
    await _prefs.setBool(AppConstants.prefKeyIsLoggedIn, true);
    await _prefs.setString(AppConstants.prefKeyEmployeeId,    employee.id);
    await _prefs.setString(AppConstants.prefKeyEmployeeName,  employee.name);
    await _prefs.setString(AppConstants.prefKeyEmployeeEmail, employee.email);
    await _prefs.setString(AppConstants.prefKeyEmployeeDept,  employee.department);
    await _prefs.setString(AppConstants.prefKeyAuthToken,     token);
    await _prefs.setString(_prefKeyUserRole, employee.role.value);
    
    // Save refresh token if provided
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _prefs.setString(AppConstants.prefKeyRefreshToken, refreshToken);
      ApiClient.setRefreshToken(refreshToken);
      print('[AUTH] Refresh token saved to SharedPreferences and ApiClient');
    }
    
    ApiClient.setToken(token);
    print('[AUTH] Token saved to SharedPreferences and ApiClient');
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  /// Creates a new user via POST /auth/signup (returns {id}), then
  /// automatically signs in via POST /auth/signin to obtain a bearer token.
  ///
  /// This "auto-approve" step means the caller never has to handle a
  /// partial (id-only) state — they receive a fully authenticated session.
  Future<EmployeeModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final displayName = '$firstName $lastName'.trim();

    // Step 1 — create account
    final signupResp = await _dio.post(
      '/auth/signup',
      data: {
        'email':       email.trim().toLowerCase(),
        'password':    password,
        'displayName': displayName,
      },
    );

    final signupData = signupResp.data as Map<String, dynamic>;
    // Signup returns { id } (not a token).
    final userId = signupData['id'] as String?
        ?? signupData['_id'] as String?
        ?? '';

    // Step 2 — auto sign in to receive bearer token
    final signinResp = await _dio.post(
      '/auth/signin',
      data: {
        'email':    email.trim().toLowerCase(),
        'password': password,
      },
    );

    final token = _extractToken(signinResp.data);
    final refreshToken = _extractRefreshToken(signinResp.data);
    final employee = _buildEmployee(
      id:    userId,
      name:  displayName,
      email: email.trim().toLowerCase(),
      data:  signinResp.data as Map<String, dynamic>,
    );

    await _saveSession(employee, token, refreshToken: refreshToken);
    return employee;
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  /// Authenticates via POST /auth/login/ and returns the bearer token
  /// alongside a populated [EmployeeModel].
  Future<EmployeeModel> login({
    required String email,
    required String password,
  }) async {
    print('[AUTH] Login attempt for email: $email');
    final response = await _dio.post(
      '/auth/login/',
      data: {
        'email':    email.trim().toLowerCase(),
        //'password': password,
      },
    );

    print('[AUTH] Login response status: ${response.statusCode}');
    print('[AUTH] Login response data: ${response.data}');
    final data  = response.data as Map<String, dynamic>;
    final token = _extractToken(data);
    final refreshToken = _extractRefreshToken(data);
    print('[AUTH] Extracted token length: ${token.length}');
    if (token.isEmpty) {
      print('[AUTH] ERROR: Token extraction failed! Response keys: ${data.keys.toList()}');
      throw Exception('Failed to extract token from login response');
    }

    // Try to get id from response body or by decoding the JWT payload.
    String userId = data['id'] as String?
        ?? data['_id'] as String?
        ?? data['userId'] as String?
        ?? '';
    String displayName = data['displayName'] as String?
        ?? data['name'] as String?
        ?? '';
    if (userId.isEmpty) {
      // Decode JWT payload (base64url, no verification needed).
      final claims = _decodeJwtPayload(token);
      userId      = claims['id'] as String?
          ?? claims['sub'] as String?
          ?? claims['userId'] as String?
          ?? '';
      displayName = displayName.isNotEmpty
          ? displayName
          : claims['displayName'] as String?
              ?? claims['name'] as String?
              ?? email.split('@').first;
    }

    final employee = _buildEmployee(
      id:    userId,
      name:  displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email.trim().toLowerCase(),
      data:  data,
    );

    await _saveSession(employee, token, refreshToken: refreshToken);
    return employee;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  /// Signs out server-side (POST /auth/signout) then clears the local session.
  /// The server call is best-effort — local state is always cleared even if
  /// the network request fails (e.g. the token is already expired).
  Future<void> logout() async {
    // Revoke the token server-side so it can no longer be reused.
    try {
      await _dio.post('/auth/signout/');
    } catch (_) {
      // Ignore — proceed with local cleanup regardless.
    }
    ApiClient.setToken(null);
    ApiClient.setRefreshToken(null);
    await _prefs.setBool(AppConstants.prefKeyIsLoggedIn, false);
    await _prefs.remove(AppConstants.prefKeyEmployeeId);
    await _prefs.remove(AppConstants.prefKeyEmployeeName);
    await _prefs.remove(AppConstants.prefKeyEmployeeEmail);
    await _prefs.remove(AppConstants.prefKeyEmployeeDept);
    await _prefs.remove(AppConstants.prefKeyAuthToken);
    await _prefs.remove(AppConstants.prefKeyRefreshToken);
    await _prefs.remove(_prefKeyUserRole);
    // Clear cached album so the next session fetches/creates a fresh one.
    await _prefs.remove(AppConstants.prefKeyAlbumId);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Extracts the bearer token from multiple common response shapes:
  /// `{ "token": "..." }`, `{ "access_token": "..." }`,
  /// or a plain string body.
  String _extractToken(dynamic responseData) {
    print('[AUTH] _extractToken called');
    
    if (responseData is String) {
      print('[AUTH] Token is String type');
      return responseData;
    }
    
    if (responseData is Map) {
      print('[AUTH] Response keys: ${responseData.keys.toList()}');
      
      // Try all common token key names
      final token = responseData['token'] as String?
          ?? responseData['access_token'] as String?
          ?? responseData['accessToken'] as String?
          ?? responseData['access'] as String?
          ?? responseData['jwt'] as String?
          ?? responseData['auth_token'] as String?
          ?? '';
      
      if (token.isNotEmpty) {
        print('[AUTH] ✓ Token extracted successfully (${token.length} chars)');
        print('[AUTH] Token preview: ${token.substring(0, 20)}...');
      } else {
        print('[AUTH] ✗ ERROR: Token not found in response!');
        print('[AUTH] Response data: $responseData');
      }
      
      return token;
    }
    
    print('[AUTH] ✗ ERROR: Response is neither String nor Map');
    return '';
  }

  /// Extracts the refresh token from the response data.
  /// Tries multiple common refresh token key names.
  String _extractRefreshToken(dynamic responseData) {
    print('[AUTH] _extractRefreshToken called');
    
    if (responseData is Map) {
      print('[AUTH] Response keys: ${responseData.keys.toList()}');
      
      // Try all common refresh token key names
      final refreshToken = responseData['refresh_token'] as String?
          ?? responseData['refreshToken'] as String?
          ?? responseData['refresh'] as String?
          ?? '';
      
      if (refreshToken.isNotEmpty) {
        print('[AUTH] ✓ Refresh token extracted successfully (${refreshToken.length} chars)');
        print('[AUTH] Refresh token preview: ${refreshToken.substring(0, 20)}...');
      } else {
        print('[AUTH] ℹ No refresh token in response (optional)');
      }
      
      return refreshToken;
    }
    
    print('[AUTH] ℹ Response is not a Map, no refresh token available');
    return '';
  }

  /// Builds an [EmployeeModel] from the known fields or the response body.
  EmployeeModel _buildEmployee({
    required String id,
    required String name,
    required String email,
    required Map<String, dynamic> data,
  }) {
    final firstName = data['firstName'] as String? ?? '';
    final lastName  = data['lastName']  as String? ?? '';
    final fullName  = firstName.isNotEmpty && lastName.isNotEmpty
        ? '$firstName $lastName'.trim()
        : name.isNotEmpty
            ? name
            : email.split('@').first;

    // Extract role from response - try multiple common field names
    final roleStr = data['role'] as String?
        ?? data['user_role'] as String?
        ?? data['userRole'] as String?
        ?? 'employee';
    final role = UserRoleExtension.fromString(roleStr);

    return EmployeeModel(
      id:         id,
      name:       fullName,
      email:      email,
      department: data['department'] as String? ?? 'General',
      role:       role,
    );
  }

  /// Decodes the payload section of a JWT without verifying the signature.
  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      // Base64url → base64 padding fix
      String payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}