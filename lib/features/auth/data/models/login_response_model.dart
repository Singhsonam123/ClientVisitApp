import '../../domain/entities/login_response.dart';

/// User model for JSON serialization/deserialization
class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String role;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  /// Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'role': role,
    };
  }

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      fullName: fullName,
      role: role,
    );
  }
}

/// Login response model for JSON serialization/deserialization
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  /// Convert JSON to LoginResponseModel
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access'] as String? ?? json['access_token'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? json['refresh_token'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert LoginResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
      'user': user.toJson(),
    };
  }

  /// Convert to domain entity
  LoginResponseEntity toEntity() {
    return LoginResponseEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }
}
