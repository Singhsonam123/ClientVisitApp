import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/job_titles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/models/employee_model.dart' as auth_models;
import '../../../auth/presentation/pages/profile_page.dart';
import '../../data/models/employee_model.dart';
import 'dart:convert';

class ConfigurePage extends StatefulWidget {
  final String? projectId;
  final List<dynamic>? projects;
  final dynamic selectedProject;
  final Function(dynamic)? onProjectChanged;

  const ConfigurePage({
    super.key,
    this.projectId,
    this.projects,
    this.selectedProject,
    this.onProjectChanged,
  });

  @override
  State<ConfigurePage> createState() => _ConfigurePageState();
}

class _ConfigurePageState extends State<ConfigurePage> {
  late Future<List<EmployeeModel>> _membersFuture;
  bool _isAdminRole = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    if (widget.projectId != null && widget.projectId!.isNotEmpty) {
      _membersFuture = _loadProjectMembers();
    } else {
      _membersFuture = Future.value([]);
    }
  }

  void _checkUserRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _isAdminRole = authState.employee.role == auth_models.UserRole.admin;
    }
  }

  @override
  void didUpdateWidget(ConfigurePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      print('Project ID changed from ${oldWidget.projectId} to ${widget.projectId}');
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        setState(() {
          _membersFuture = _loadProjectMembers();
        });
      } else {
        setState(() {
          _membersFuture = Future.value([]);
        });
      }
    }
  }

Future<List<EmployeeModel>> _loadProjectMembers() async {
    try {
      if (widget.projectId == null || widget.projectId!.isEmpty) {
        throw Exception('No project selected');
      }

      final endpoint = ApiEndpoints.projectMembersEndpoint.replaceFirst('{id}', widget.projectId!);
      print('Loading members from endpoint: $endpoint');
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
          } else if (data.containsKey('data')) {
            final dataList = data['data'] as List;
            print('Found data key with ${dataList.length} items');
            return dataList
                .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
        
        print('No members found in response');
        return [];
      }
      
      throw Exception('Failed to load project members: ${response.statusCode}');
    } catch (e) {
      print('Error loading members: $e');
      rethrow;
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showCreateAdminSheet() {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    
    final emailFocus = FocusNode();
    final fullNameFocus = FocusNode();
    final phoneFocus = FocusNode();
    
    JobTitle? selectedJobTitle;
    bool isLoading = false;
    String? emailError;
    bool emailFocused = false;
    bool fullNameFocused = false;
    bool phoneFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Admin',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => emailFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: emailFocus,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'admin@valuelabs.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: emailError != null ? Colors.red : (emailFocused ? AppColors.primary : Colors.grey),
                          width: emailFocused ? 2 : 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorText: emailError,
                      suffixIcon: emailController.text.isNotEmpty
                          ? (emailError == null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red))
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setModalState(() {
                        if (value.isEmpty) {
                          emailError = null;
                        } else if (!_isValidEmail(value.trim())) {
                          emailError = 'Invalid email format';
                        } else {
                          emailError = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => fullNameFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: fullNameFocus,
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: fullNameController.text.isNotEmpty
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => phoneFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: phoneFocus,
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: '+91-9876543210',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: phoneController.text.isNotEmpty
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JobTitle>(
                  value: selectedJobTitle,
                  decoration: InputDecoration(
                    labelText: 'Job Title',
                    hintText: 'Select a job title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    suffixIcon: selectedJobTitle != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  items: JobTitle.values.map((JobTitle jobTitle) {
                    return DropdownMenuItem<JobTitle>(
                      value: jobTitle,
                      child: Text(jobTitle.displayName),
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (emailController.text.isEmpty ||
                                fullNameController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                selectedJobTitle == null) {
                              AppToast.showError(
                                context,
                                'Please fill all fields',
                              );
                              return;
                            }

                            if (!_isValidEmail(emailController.text.trim())) {
                              AppToast.showError(
                                context,
                                'Please enter a valid email address',
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            try {
                              final endpoint =
                                  '/projects/${widget.projectId}/create-admin/';
                              final payload = {
                                'email': emailController.text.trim(),
                                'full_name': fullNameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'job_title': selectedJobTitle!.displayName,
                              };

                              final response = await ApiClient.instance.post(
                                endpoint,
                                data: payload,
                              );

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  AppToast.showSuccess(
                                    context,
                                    'Admin created successfully',
                                  );
                                  // Reload members list
                                  setState(() {
                                    _membersFuture = _loadProjectMembers();
                                  });
                                }
                              } else {
                                if (mounted) {
                                  AppToast.showError(
                                    context,
                                    'Failed to create admin',
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                AppToast.showError(
                                  context,
                                  'Error: ${e.toString()}',
                                );
                              }
                            } finally {
                              setModalState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEmployeeSheet() {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    
    final emailFocus = FocusNode();
    final fullNameFocus = FocusNode();
    final phoneFocus = FocusNode();
    
    JobTitle? selectedJobTitle;
    bool isLoading = false;
    String? emailError;
    bool emailFocused = false;
    bool fullNameFocused = false;
    bool phoneFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Employee',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => emailFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: emailFocus,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'employee@valuelabs.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: emailError != null ? Colors.red : (emailFocused ? AppColors.primary : Colors.grey),
                          width: emailFocused ? 2 : 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorText: emailError,
                      suffixIcon: emailController.text.isNotEmpty
                          ? (emailError == null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red))
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setModalState(() {
                        if (value.isEmpty) {
                          emailError = null;
                        } else if (!_isValidEmail(value.trim())) {
                          emailError = 'Invalid email format';
                        } else {
                          emailError = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => fullNameFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: fullNameFocus,
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: fullNameController.text.isNotEmpty
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => phoneFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: phoneFocus,
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: '+91-9876543210',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: phoneController.text.isNotEmpty
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<JobTitle>(
                  value: selectedJobTitle,
                  decoration: InputDecoration(
                    labelText: 'Job Title',
                    hintText: 'Select a job title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    suffixIcon: selectedJobTitle != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  items: JobTitle.values.map((JobTitle jobTitle) {
                    return DropdownMenuItem<JobTitle>(
                      value: jobTitle,
                      child: Text(jobTitle.displayName),
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
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (emailController.text.isEmpty ||
                                fullNameController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                selectedJobTitle == null) {
                              AppToast.showError(
                                context,
                                'Please fill all fields',
                              );
                              return;
                            }

                            if (!_isValidEmail(emailController.text.trim())) {
                              AppToast.showError(
                                context,
                                'Please enter a valid email address',
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            try {
                              final endpoint =
                                  '/api/projects/${widget.projectId}/add-employee/';
                              final payload = {
                                'email': emailController.text.trim(),
                                'full_name': fullNameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'job_title': selectedJobTitle!.displayName,
                              };

                              final response = await ApiClient.instance.post(
                                endpoint,
                                data: payload,
                              );

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  AppToast.showSuccess(
                                    context,
                                    'Employee added successfully',
                                  );
                                  // Reload members list
                                  setState(() {
                                    _membersFuture = _loadProjectMembers();
                                  });
                                }
                              } else {
                                if (mounted) {
                                  AppToast.showError(
                                    context,
                                    'Failed to add employee',
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                AppToast.showError(
                                  context,
                                  'Error: ${e.toString()}',
                                );
                              }
                            } finally {
                              setModalState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Employee'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddGuestSheet() {
    final emailController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    
    final emailFocus = FocusNode();
    final fullNameFocus = FocusNode();
    final phoneFocus = FocusNode();
    
    bool isLoading = false;
    String? emailError;
    bool emailFocused = false;
    bool fullNameFocused = false;
    bool phoneFocused = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Guest/Client',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => emailFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: emailFocus,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'guest@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: emailError != null ? Colors.red : (emailFocused ? AppColors.primary : Colors.grey),
                          width: emailFocused ? 2 : 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorText: emailError,
                      suffixIcon: emailController.text.isNotEmpty
                          ? (emailError == null
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red))
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setModalState(() {
                        if (value.isEmpty) {
                          emailError = null;
                        } else if (!_isValidEmail(value.trim())) {
                          emailError = 'Invalid email format';
                        } else {
                          emailError = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => fullNameFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: fullNameFocus,
                    controller: fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: fullNameController.text.isNotEmpty
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) {
                    setModalState(() => phoneFocused = hasFocus);
                  },
                  child: TextField(
                    focusNode: phoneFocus,
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      hintText: '+91-9876543210',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: phoneController.text.isNotEmpty
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (emailController.text.isEmpty ||
                                fullNameController.text.isEmpty ||
                                phoneController.text.isEmpty) {
                              AppToast.showError(
                                context,
                                'Please fill all fields',
                              );
                              return;
                            }

                            if (!_isValidEmail(emailController.text.trim())) {
                              AppToast.showError(
                                context,
                                'Please enter a valid email address',
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            try {
                              final endpoint =
                                  '/api/projects/${widget.projectId}/add-guest/';
                              final payload = {
                                'email': emailController.text.trim(),
                                'full_name': fullNameController.text.trim(),
                                'phone': phoneController.text.trim(),
                              };

                              final response = await ApiClient.instance.post(
                                endpoint,
                                data: payload,
                              );

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                if (mounted) {
                                  Navigator.pop(context);
                                  AppToast.showSuccess(
                                    context,
                                    'Guest added successfully',
                                  );
                                  // Reload members list
                                  setState(() {
                                    _membersFuture = _loadProjectMembers();
                                  });
                                }
                              } else {
                                if (mounted) {
                                  AppToast.showError(
                                    context,
                                    'Failed to add guest',
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                AppToast.showError(
                                  context,
                                  'Error: ${e.toString()}',
                                );
                              }
                            } finally {
                              setModalState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Guest'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, AuthState authState, bool isAdminRole) {
    return widget.projectId == null || widget.projectId!.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please select a project first',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          )
        : FutureBuilder<List<EmployeeModel>>(
            future: _membersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load project members',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _membersFuture = _loadProjectMembers();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No members found in this project',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              final members = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _membersFuture = _loadProjectMembers();
                  });
                  await _membersFuture;
                },
                color: AppColors.primary,
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            member.firstName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(member.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              member.email,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (member.jobTitle != null && member.jobTitle!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Job Title: ${member.jobTitle}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            if (member.phone != null && member.phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Phone: ${member.phone}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              );
            },
          );
  }

  void _showProjectSelector(BuildContext context) {
    if (widget.projects == null || widget.projects!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Project',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.projects!.length,
                itemBuilder: (context, index) {
                  final project = widget.projects![index];
                  final isSelected = widget.selectedProject?.id == project.id;
                  return ListTile(
                    title: Text(project.name),
                    subtitle: Text(project.description ?? ''),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () {
                      widget.onProjectChanged?.call(project);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

 void _openProfile(BuildContext context, AuthState authState) {
   if (authState is! AuthAuthenticated) {
     return;
   }

   if (!context.mounted) return;

   Navigator.of(context).push(
     MaterialPageRoute(
       builder: (context) => ProfilePage(
         employee: authState.employee,
         onLogout: () {
           // Dispatch logout event from the current context
           context.read<AuthBloc>().add(const AuthCleanLogoutRequested());
         },
       ),
     ),
   );
 }

 @override
 Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdminRole = authState is AuthAuthenticated &&
            authState.employee.role == auth_models.UserRole.admin;

        final now = DateTime.now();
        final greeting = now.hour < 12
            ? 'Good Morning'
            : now.hour < 17
                ? 'Good Afternoon'
                : 'Good Evening';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.festiveGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$greeting! 👋',
                              style: AppTextStyles.headlineMedium
                                  .copyWith(color: AppColors.textOnPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAdminRole ? 'Employee Management' : 'Admin Management',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnPrimary.withOpacity(0.85)),
                            ),
                            const SizedBox(height: 15),
                            // Project selector
                            if (widget.projects != null && widget.projects!.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _showProjectSelector(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white30),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.selectedProject?.name ?? 'Select Project',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white70),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                   if (authState is AuthAuthenticated)
                     IconButton(
                       icon: const CircleAvatar(
                         backgroundColor: Colors.white24,
                         child: Icon(Icons.person_rounded, color: Colors.white),
                       ),
                       onPressed: () {
                         _openProfile(context, authState);
                       },
                       tooltip: 'My Account',
                     ),
                 ],
              ),
              SliverFillRemaining(
                child: _buildPageContent(context, authState, isAdminRole),
              ),
            ],
          ),
          floatingActionButton: widget.projectId != null &&
                  widget.projectId!.isNotEmpty
              ? isAdminRole
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'employee') {
                          _showAddEmployeeSheet();
                        } else if (value == 'guest') {
                          _showAddGuestSheet();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'employee',
                          child: Row(
                            children: [
                              Icon(Icons.person_add, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Add Employee'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'guest',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Add Guest'),
                            ],
                          ),
                        ),
                      ],
                      child: FloatingActionButton(
                        onPressed: () {},
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.add),
                      ),
                    )
                  : FloatingActionButton(
                      onPressed: _showCreateAdminSheet,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.add),
                    )
              : null,
       );
     },
   );
 }
}
