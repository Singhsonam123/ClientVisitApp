import '../entities/login_response.dart';

/// Abstract repository for authentication operations
abstract class LoginRepository {
  /// Authenticates user with email and password
  /// Returns [LoginResponseEntity] on success
  /// Throws exception on failure
  Future<LoginResponseEntity> login({
    required String email,
    required String password,
  });
}
