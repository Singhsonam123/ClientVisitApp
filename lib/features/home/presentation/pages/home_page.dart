import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/logout_dialog.dart';
import '../../../employees/presentation/pages/configure_page.dart';
import '../../../employees/presentation/pages/employees_page.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/models/employee_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../settings/data/settings_repository.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../projects/data/datasources/projects_remote_datasource.dart';
import '../../../projects/data/models/project_model.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  bool _isLoadingProjects = false;
  bool _isSuperAdmin = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _loadUserRole();
  }

  /// Load user role from SharedPreferences
  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roleStr = prefs.getString('user_role') ?? 'admin';
      final role = UserRoleExtension.fromString(roleStr);
      setState(() {
        _isSuperAdmin = role == UserRole.superAdmin;
        _isAdmin = role == UserRole.admin;
      });
      print('[HOME] User role loaded from prefs: $roleStr');
      print('[HOME] Is Super Admin: $_isSuperAdmin');
      print('[HOME] Is Admin: $_isAdmin');
    } catch (e) {
      print('[HOME] Error loading user role: $e');
    }
  }

  List<_NavItem> _getNavItems(bool isSuperAdmin, bool isAdmin) {
    // For ADMIN and SUPER_ADMIN roles, show only Employee screen
    if (isAdmin || isSuperAdmin) {
      return const [
        _NavItem(icon: Icons.people_rounded, label: 'Employee'),
      ];
    } else {
      return const [
        _NavItem(icon: Icons.home_rounded, label: 'Home'),
        _NavItem(icon: Icons.calendar_month_rounded, label: 'Agenda'),
        _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Potluck'),
        _NavItem(icon: Icons.cake_rounded, label: 'Sweets'),
      ];
    }
  }

  List<Widget> _getPages(bool isSuperAdmin, bool isAdmin) {
    // Determine subtitle based on role
    final subtitle = isSuperAdmin
        ? 'Admin Management'
        : isAdmin
            ? 'Employee Management'
            : 'Team Connect';

    final dashboardPage = DashboardPage(
      selectedProject: _selectedProject,
      onLogoutTap: () => _handleLogout(context),
      onProfileTap: () => _openProfile(context),
      onProjectTap: () => _loadProjects(),
      isSuperAdmin: isSuperAdmin,
      projects: _projects,
      onProjectChanged: (project) {
        setState(() => _selectedProject = project);
      },
      onAddProject: _createNewProject,
      subtitle: subtitle,
    );

    final employeesPage = EmployeesPage(
      projects: _projects,
      selectedProject: _selectedProject,
      onProjectChanged: (project) {
        setState(() => _selectedProject = project);
      },
      onProfileTap: () => _openProfile(context),
      isSuperAdmin: isSuperAdmin,
      onAddProject: _createNewProject,
      subtitle: subtitle,
    );

    final configurePage = ConfigurePage(
      key: ValueKey(_selectedProject?.id ?? 'no-project'),
      projectId: _selectedProject?.id,
      projects: _projects,
      selectedProject: _selectedProject,
      onProjectChanged: (project) {
        setState(() => _selectedProject = project);
      },
    );

    // For ADMIN and SUPER_ADMIN roles, show only Employee screen
    if (isAdmin || isSuperAdmin) {
      return [employeesPage];
    } else {
      return [
        dashboardPage,
        const SizedBox.shrink(), // Agenda placeholder
        const SizedBox.shrink(), // Potluck placeholder
        const SizedBox.shrink(), // Sweets placeholder
        configurePage,
      ];
    }
  }

  Future<void> _loadProjects() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoadingProjects = true);
    try {
      final dataSource = ProjectsRemoteDataSourceImpl();
      final projects = await dataSource.listProjects();
      setState(() {
        _projects = projects;
        if (projects.isNotEmpty) {
          _selectedProject = projects.first;
        }
      });
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Failed to load projects');
      }
    } finally {
      setState(() => _isLoadingProjects = false);
    }
  }

  Future<void> _createNewProject() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Check if user is super admin
    if (authState.employee.role.displayName != 'super_admin') {
      AppToast.showError(context, 'Only Super Admin can create projects');
      return;
    }

    // Show create project dialog
    if (!mounted) return;
    _showCreateProjectDialog();
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter project description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();

              if (name.isEmpty || description.isEmpty) {
                AppToast.showError(context, 'Please fill all fields');
                return;
              }

              try {
                final dataSource = ProjectsRemoteDataSourceImpl();
                final newProject = await dataSource.createProject(
                  name: name,
                  description: description,
                );

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _projects.add(newProject);
                    _selectedProject = newProject;
                  });
                  AppToast.showSuccess(context, 'Project created successfully');
                }
              } catch (e) {
                if (mounted) {
                  AppToast.showError(context, 'Failed to create project');
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final navItems = _getNavItems(_isSuperAdmin, _isAdmin);
        final pages = _getPages(_isSuperAdmin, _isAdmin);
        
        // Reset current index if it exceeds the available pages
        if (_currentIndex >= pages.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _currentIndex = 0);
          });
        }

        return Stack(
          children: [
            Scaffold(
              body: IndexedStack(
                index: _currentIndex.clamp(0, pages.length - 1),
                children: pages,
              ),
              bottomNavigationBar: navItems.length > 1
                  ? Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: BottomNavigationBar(
                        currentIndex: _currentIndex.clamp(0, navItems.length - 1),
                        onTap: (index) => setState(() => _currentIndex = index),
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: AppColors.primary,
                        unselectedItemColor: AppColors.textHint,
                        selectedLabelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: const TextStyle(fontSize: 11),
                        items: navItems
                            .map((item) => BottomNavigationBarItem(
                                  icon: Icon(item.icon),
                                  label: item.label,
                                ))
                            .toList(),
                      ),
                    )
                  : null,
            ),
            // Loading overlay
            if (_isLoadingProjects)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openProfile(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return;
    }

    if (!context.mounted) return;

    final authBloc = context.read<AuthBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          employee: authState.employee,
          onLogout: () {
            // Dispatch logout event to AuthBloc
            authBloc.add(const AuthCleanLogoutRequested());
          },
        ),
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    final authRepository = context.read<AuthRepository>();
    final selectedRole = authRepository.selectedRole?.displayName ?? 'Guest';

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => SettingsBloc(
            context.read<SettingsRepository>(),
          ),
          child: SettingsPage(
            userRole: selectedRole,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await LogoutDialog.show(context);
    if (confirmed && mounted) {
      context.read<AuthBloc>().add(const AuthCleanLogoutRequested());
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
