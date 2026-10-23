import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/logout_repository.dart';
import '../datasources/logout_remote_datasource.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';

/// Implementation of [LogoutRepository]
/// Handles logout API calls and local session cleanup
class LogoutRepositoryImpl implements LogoutRepository {
  final LogoutRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  LogoutRepositoryImpl({
    required this.remoteDataSource,
    required this.prefs,
  });

  @override
  Future<void> logout() async {
    try {
      // Call remote API to logout
      await remoteDataSource.logout();
    } catch (e) {
      // Continue with local cleanup even if API call fails
      // This ensures user can logout even if server is unreachable
    }

    // Clear local session data
    await _clearLocalSession();
  }

  /// Clear all local session data
  Future<void> _clearLocalSession() async {
    // Clear tokens
    await prefs.remove(AppConstants.prefKeyAuthToken);
    await prefs.remove('refresh_token');

    // Clear user information
    await prefs.remove(AppConstants.prefKeyEmployeeId);
    await prefs.remove(AppConstants.prefKeyEmployeeEmail);
    await prefs.remove(AppConstants.prefKeyEmployeeName);
    await prefs.remove('user_role');

    // Clear login status
    await prefs.setBool(AppConstants.prefKeyIsLoggedIn, false);

    // Clear full response
    await prefs.remove('login_response');

    // Clear selected role
    await prefs.remove('selected_role');

    // Clear token from API client
    ApiClient.setToken(null);
  }
}
