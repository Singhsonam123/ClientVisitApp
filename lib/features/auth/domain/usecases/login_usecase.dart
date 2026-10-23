import '../entities/login_response.dart';
import '../repositories/login_repository.dart';

/// Use case for user login
/// Implements clean architecture pattern
class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  /// Execute login with email and password
  /// Returns [LoginResponseEntity] containing tokens and user info
  Future<LoginResponseEntity> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}
