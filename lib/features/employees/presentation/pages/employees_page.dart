import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/models/employee_model.dart' as auth_models;
import '../../../projects/data/models/project_model.dart';
import '../../data/models/employee_model.dart';
import '../../../home/presentation/widgets/dashboard_top_bar.dart';

// Job title enum
enum JobTitle {
  seniorSoftwareEngineer('Senior Software Engineer'),
  softwareEngineer('Software Engineer'),
  seniorAnalyst('Senior Analyst'),
  analyst('Analyst'),
  teamLead('Team Lead'),
  manager('Manager'),
  srManager('Sr. Manager'),
  qa('QA'),
  hr('HR'),
  director('Director'),
  consultant('Consultant'),
  srConsultant('Sr. Consultant'),
  developer('Developer');

  final String displayName;
  const JobTitle(this.displayName);
}

class EmployeesPage extends StatefulWidget {
  final List<ProjectModel>? projects;
  final ProjectModel? selectedProject;
  final Function(ProjectModel?)? onProjectChanged;
  final VoidCallback? onProfileTap;
  final bool isSuperAdmin;
  final VoidCallback? onAddProject;
  final String subtitle;

  const EmployeesPage({
    super.key,
    this.projects,
    this.selectedProject,
    this.onProjectChanged,
    this.onProfileTap,
    this.isSuperAdmin = false,
    this.onAddProject,
    this.subtitle = 'Employee Management',
  });

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late Future<List<EmployeeModel>> _employeesFuture;
  bool _isAdminRole = false;
  bool _isSuperAdminRole = false;
  bool _isAddingEmployee = false;
  late TextEditingController _searchController;
  List<EmployeeModel> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _checkUserRole();
    _employeesFuture = _loadProjectEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EmployeesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedProject?.id != widget.selectedProject?.id) {
      print('Project changed from ${oldWidget.selectedProject?.id} to ${widget.selectedProject?.id}');
      setState(() {
        _employeesFuture = _loadProjectEmployees();
      });
    }
  }

  void _checkUserRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _isAdminRole = authState.employee.role == auth_models.UserRole.admin;
      _isSuperAdminRole = authState.employee.role == auth_models.UserRole.superAdmin;
    }
  }

  Future<List<EmployeeModel>> _loadProjectEmployees() async {
    try {
      if (widget.selectedProject == null || widget.selectedProject!.id.isEmpty) {
        print('No project selected');
        return [];
      }

      final projectId = widget.selectedProject!.id;
      final endpoint = ApiEndpoints.projectMembersEndpoint.replaceFirst('{id}', projectId);
      print('Loading employees from endpoint: $endpoint');
      final response = await ApiClient.instance.get(endpoint);

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          print('Data is a list with ${data.length} items');
          return data
              .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic>) {
          print('Data is a map with keys: ${data.keys}');
          if (data.containsKey('members')) {
            final members = data['members'] as List;
            print('Found members key with ${members.length} items');
            return members
                .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data.containsKey('employees')) {
            final employees = data['employees'] as List;
            print('Found employees key with ${employees.length} items');
            return employees
                .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data.containsKey('results')) {
            final employees = data['results'] as List;
            print('Found results key with ${employees.length} items');
            return employees
                .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }

        throw Exception('Unexpected response format');
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading employees: $e');
      throw Exception('Error loading employees: $e');
    }
  }

  void _refreshEmployees() {
    setState(() {
      _employeesFuture = _loadProjectEmployees();
      _searchController.clear();
      _filteredEmployees = [];
    });
  }

  void _filterEmployees(String query, List<EmployeeModel> employees) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = employees;
      } else {
        _filteredEmployees = employees
            .where((employee) =>
                employee.fullName.toLowerCase().contains(query.toLowerCase()) ||
                employee.email.toLowerCase().contains(query.toLowerCase()) ||
                (employee.jobTitle?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  Future<void> _addEmployee(String email, String fullName, String phone, String jobTitle) async {
    try {
      if (widget.selectedProject == null || widget.selectedProject!.id.isEmpty) {
        AppToast.showError(context, 'Please select a project first');
        return;
      }

      setState(() => _isAddingEmployee = true);
      
      final projectId = widget.selectedProject!.id;
      final endpoint = '/projects/$projectId/add-employee/';
      
      final requestData = {
        'email': email,
        'full_name': fullName,
      };
      
      if (phone.isNotEmpty) {
        requestData['phone'] = phone;
      }
      if (jobTitle.isNotEmpty) {
        requestData['job_title'] = jobTitle;
      }
      
      print('[EMPLOYEES] Adding employee to project $projectId');
      print('[EMPLOYEES] Endpoint: $endpoint');
      print('[EMPLOYEES] Request data: $requestData');
      
      final response = await ApiClient.instance.post(
        endpoint,
        data: requestData,
      );

      print('[EMPLOYEES] Add employee response status: ${response.statusCode}');
      print('[EMPLOYEES] Add employee response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          AppToast.showSuccess(context, 'Employee added successfully');
          Navigator.pop(context);
          _refreshEmployees();
        }
      } else {
        if (mounted) {
          final errorMessage = response.data is Map
              ? response.data['message'] ?? response.data['error'] ?? 'Failed to add employee'
              : 'Failed to add employee';
          AppToast.showError(context, errorMessage);
        }
      }
    } catch (e) {
      print('[EMPLOYEES] Error adding employee: $e');
      if (mounted) {
        AppToast.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingEmployee = false);
      }
    }
  }

  Future<void> _addAdmin(String email, String fullName, String phone, String jobTitle) async {
    try {
      if (widget.selectedProject == null || widget.selectedProject!.id.isEmpty) {
        AppToast.showError(context, 'Please select a project first');
        return;
      }

      setState(() => _isAddingEmployee = true);
      
      final projectId = widget.selectedProject!.id;
      final endpoint = '/projects/$projectId/create-admin/';
      
      final requestData = {
        'email': email,
        'full_name': fullName,
      };
      
      if (phone.isNotEmpty) {
        requestData['phone'] = phone;
      }
      if (jobTitle.isNotEmpty) {
        requestData['job_title'] = jobTitle;
      }
      
      print('[EMPLOYEES] Adding admin to project $projectId');
      print('[EMPLOYEES] Endpoint: $endpoint');
      print('[EMPLOYEES] Request data: $requestData');
      
      final response = await ApiClient.instance.post(
        endpoint,
        data: requestData,
      );

      print('[EMPLOYEES] Add admin response status: ${response.statusCode}');
      print('[EMPLOYEES] Add admin response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          AppToast.showSuccess(context, 'Admin added successfully');
          Navigator.pop(context);
          _refreshEmployees();
        }
      } else {
        if (mounted) {
          final errorMessage = response.data is Map
              ? response.data['message'] ?? response.data['error'] ?? 'Failed to add admin'
              : 'Failed to add admin';
          AppToast.showError(context, errorMessage);
        }
      }
    } catch (e) {
      print('[EMPLOYEES] Error adding admin: $e');
      if (mounted) {
        AppToast.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingEmployee = false);
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showAddEmployeeSheet() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    JobTitle? selectedJobTitle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _isSuperAdminRole ? 'Add Admin' : 'Add Employee',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'employee@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: emailController.text.isNotEmpty && !_isValidEmail(emailController.text)
                        ? 'Please enter a valid email'
                        : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    counterText: '${nameController.text.length}/30',
                  ),
                  onChanged: (value) {
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+1 (555) 123-4567',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JobTitle>(
                  value: selectedJobTitle,
                  decoration: InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: JobTitle.values.map((JobTitle title) {
                    return DropdownMenuItem<JobTitle>(
                      value: title,
                      child: Text(title.displayName),
                    );
                  }).toList(),
                  onChanged: (JobTitle? newValue) {
                    setModalState(() {
                      selectedJobTitle = newValue;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAddingEmployee
                        ? null
                        : () {
                            final email = emailController.text.trim();
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            final jobTitle = selectedJobTitle?.displayName ?? '';

                            if (email.isEmpty || name.isEmpty || selectedJobTitle == null) {
                              AppToast.showError(
                                context,
                                'Please fill in all required fields',
                              );
                              return;
                            }

                            if (!_isValidEmail(email)) {
                              AppToast.showError(
                                context,
                                'Please enter a valid email address',
                              );
                              return;
                            }

                            if (name.length > 30) {
                              AppToast.showError(
                                context,
                                'Full name must be 30 characters or less',
                              );
                              return;
                            }

                            if (_isSuperAdminRole) {
                              _addAdmin(email, name, phone, jobTitle);
                            } else {
                              _addEmployee(email, name, phone, jobTitle);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    child: _isAddingEmployee
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _isSuperAdminRole ? 'Add Admin' : 'Add Employee',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning! 👋'
        : now.hour < 17
            ? 'Good Afternoon! 👋'
            : 'Good Evening! 👋';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: DashboardTopBar(
                    greeting: greeting,
                    subtitle: widget.subtitle,
                    projects: widget.projects,
                    selectedProject: widget.selectedProject,
                    onProjectChanged: widget.onProjectChanged,
                    onProfileTap: widget.onProfileTap,
                    isSuperAdmin: widget.isSuperAdmin,
                    onAddProject: widget.onAddProject,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<EmployeeModel>>(
                  future: _employeesFuture,
                  builder: (context, snapshot) {
                    // Show loading spinner while waiting for response
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    // Show error only if there's an error
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading employees',
                                style: AppTextStyles.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: AppTextStyles.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _refreshEmployees,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final employees = snapshot.data ?? [];
                    
                    // Initialize filtered employees on first load
                    if (_filteredEmployees.isEmpty && employees.isNotEmpty) {
                      _filteredEmployees = employees;
                    }

                    // Only show "No employees found" if API returned successfully with empty list
                    if (employees.isEmpty && snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No employees found',
                                style: AppTextStyles.headlineSmall,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _refreshEmployees,
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Search field
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name, email, or job title...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _filterEmployees('', employees);
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (query) {
                              _filterEmployees(query, employees);
                            },
                          ),
                        ),
                        // Employee list
                        if (_filteredEmployees.isEmpty && _searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No employees found',
                                    style: AppTextStyles.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try searching with different keywords',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          RefreshIndicator(
                            onRefresh: () async {
                              _refreshEmployees();
                              await _employeesFuture;
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredEmployees.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final employee = _filteredEmployees[index];
                                return _buildEmployeeCard(employee);
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          // Loading overlay when project is changed
          if (_employeesFuture != null)
            FutureBuilder<List<EmployeeModel>>(
              future: _employeesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
               onPressed: _showAddEmployeeSheet,
               backgroundColor: AppColors.primary,
               tooltip: _isSuperAdminRole ? 'Add Admin' : 'Add Employee',
               child: const Icon(Icons.add),
             )
           
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    final firstInitial = employee.firstName.isNotEmpty
        ? employee.firstName[0].toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Text(
                      firstInitial,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (employee.jobTitle != null && employee.jobTitle!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.work,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      employee.jobTitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            if (employee.phone != null && employee.phone!.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    employee.phone!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
