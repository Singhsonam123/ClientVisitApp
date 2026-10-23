import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/login_response.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';
import '../models/login_response_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';

/// Implementation of [LoginRepository]
/// Handles login API calls and local storage persistence
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  LoginRepositoryImpl({
    required this.remoteDataSource,
    required this.prefs,
  });

  @override
  Future<LoginResponseEntity> login({
    required String email,
    required String password,
  }) async {
    // Call remote API
    final loginResponseModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save to local storage
    await _saveLoginResponse(loginResponseModel);

    // Set token in API client for subsequent requests
    ApiClient.setToken(loginResponseModel.accessToken);

    // Return domain entity
    return loginResponseModel.toEntity();
  }

  /// Save login response to local storage
  Future<void> _saveLoginResponse(LoginResponseModel response) async {
    // Save tokens
    await prefs.setString(
      AppConstants.prefKeyAuthToken,
      response.accessToken,
    );
    await prefs.setString(
      'refresh_token',
      response.refreshToken,
    );

    // Save user information
    await prefs.setString(
      AppConstants.prefKeyEmployeeId,
      response.user.userId,
    );
    await prefs.setString(
      AppConstants.prefKeyEmployeeEmail,
      response.user.email,
    );
    await prefs.setString(
      AppConstants.prefKeyEmployeeName,
      response.user.fullName,
    );
    await prefs.setString(
      'user_role',
      response.user.role,
    );

    // Mark as logged in
    await prefs.setBool(
      AppConstants.prefKeyIsLoggedIn,
      true,
    );

    // Save full response as JSON for reference
    await prefs.setString(
      'login_response',
      _loginResponseToJson(response),
    );
  }

  /// Convert LoginResponseModel to JSON string
  String _loginResponseToJson(LoginResponseModel response) {
    return '''
{
  "access": "${response.accessToken}",
  "refresh": "${response.refreshToken}",
  "user": {
    "user_id": "${response.user.userId}",
    "email": "${response.user.email}",
    "full_name": "${response.user.fullName}",
    "role": "${response.user.role}"
  }
}
''';
  }
}
