import 'package:equatable/equatable.dart';

/// Enum for user roles
enum UserRole {
  admin,
  superAdmin,
  employee,
  guest,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.employee:
        return 'Employee';
      case UserRole.guest:
        return 'Guest';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.employee:
        return 'employee';
      case UserRole.guest:
        return 'guest';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
        return UserRole.superAdmin;
      case 'employee':
        return UserRole.employee;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.employee;
    }
  }
}

/// Represents a logged-in employee.
class EmployeeModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String? avatarUrl;
  final bool isAdmin;
  final UserRole role;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.avatarUrl,
    this.isAdmin = false,
    this.role = UserRole.employee,
  });

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? avatarUrl,
    bool? isAdmin,
    UserRole? role,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'department': department,
        'avatarUrl': avatarUrl,
        'isAdmin': isAdmin,
        'role': role.value,
      };

  factory EmployeeModel.fromMap(Map<String, dynamic> map) => EmployeeModel(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        department: map['department'] as String,
        avatarUrl: map['avatarUrl'] as String?,
        isAdmin: map['isAdmin'] as bool? ?? false,
        role: UserRoleExtension.fromString(map['role'] as String? ?? 'employee'),
      );

  @override
  List<Object?> get props => [id, name, email, department, avatarUrl, isAdmin, role];
}

/// Static list of mock employees for demo purposes.
class MockEmployees {
  static const List<Map<String, dynamic>> employees = [
    {
      'id': 'EMP001',
      'password': 'shutterfly@2026',
      'name': 'Arjun Sharma',
      'email': 'arjun.sharma@shutterfly.com',
      'department': 'Engineering',
      'isAdmin': true,
    },
    {
      'id': 'EMP002',
      'password': 'shutterfly@2026',
      'name': 'Priya Nair',
      'email': 'priya.nair@shutterfly.com',
      'department': 'Design',
      'isAdmin': false,
    },
    {
      'id': 'EMP003',
      'password': 'shutterfly@2026',
      'name': 'Rahul Mehta',
      'email': 'rahul.mehta@shutterfly.com',
      'department': 'Product',
      'isAdmin': false,
    },
    {
      'id': 'EMP004',
      'password': 'shutterfly@2026',
      'name': 'Sneha Patel',
      'email': 'sneha.patel@shutterfly.com',
      'department': 'Marketing',
      'isAdmin': false,
    },
    {
      'id': 'EMP005',
      'password': 'shutterfly@2026',
      'name': 'Vikram Joshi',
      'email': 'vikram.joshi@shutterfly.com',
      'department': 'HR',
      'isAdmin': false,
    },
  ];
}