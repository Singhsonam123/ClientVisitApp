/// Abstract repository for logout operations
abstract class LogoutRepository {
  /// Logs out user by calling logout API and clearing local session
  /// Throws exception on failure
  Future<void> logout();
}
