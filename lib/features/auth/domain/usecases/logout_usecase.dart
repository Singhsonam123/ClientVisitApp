import '../repositories/logout_repository.dart';

/// Use case for user logout
/// Implements clean architecture pattern
class LogoutUseCase {
  final LogoutRepository repository;

  LogoutUseCase(this.repository);

  /// Execute logout
  /// Calls the logout API endpoint and clears local session
  Future<void> call() async {
    return await repository.logout();
  }
}
