import 'package:equatable/equatable.dart';

/// User entity from login response
class UserEntity extends Equatable {
  final String userId;
  final String email;
  final String fullName;
  final String role;

  const UserEntity({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, email, fullName, role];
}

/// Login response entity containing tokens and user info
class LoginResponseEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  const LoginResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
