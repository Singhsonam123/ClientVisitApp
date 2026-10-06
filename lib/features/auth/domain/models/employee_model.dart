import 'package:equatable/equatable.dart';

/// Represents a logged-in employee.
class EmployeeModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String department;
  final String? avatarUrl;
  final bool isAdmin;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    this.avatarUrl,
    this.isAdmin = false,
  });

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? avatarUrl,
    bool? isAdmin,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'department': department,
        'avatarUrl': avatarUrl,
        'isAdmin': isAdmin,
      };

  factory EmployeeModel.fromMap(Map<String, dynamic> map) => EmployeeModel(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        department: map['department'] as String,
        avatarUrl: map['avatarUrl'] as String?,
        isAdmin: map['isAdmin'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, name, email, department, avatarUrl, isAdmin];
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