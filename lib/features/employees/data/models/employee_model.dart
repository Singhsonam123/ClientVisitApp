class EmployeeModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? role;
  final String? status;
  final String? createdAt;
  final String? jobTitle;

  EmployeeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.role,
    this.status,
    this.createdAt,
    this.jobTitle,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user_detail structure from project members endpoint
    final userDetail = json['user_detail'] as Map<String, dynamic>?;
    
    if (userDetail != null) {
      return EmployeeModel(
        id: json['id'] as String? ?? '',
        firstName: (userDetail['full_name'] as String? ?? '').split(' ').first,
        lastName: (userDetail['full_name'] as String? ?? '').split(' ').skip(1).join(' '),
        email: userDetail['email'] as String? ?? '',
        phone: userDetail['phone'] as String?,
        role: userDetail['role'] as String?,
        status: userDetail['is_active'] == true ? 'active' : 'inactive',
        createdAt: userDetail['created_at'] as String?,
        jobTitle: userDetail['job_title'] as String?,
      );
    }
    
    // Handle flat structure (legacy format)
    return EmployeeModel(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName: json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      jobTitle: json['job_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'created_at': createdAt,
      'job_title': jobTitle,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}
