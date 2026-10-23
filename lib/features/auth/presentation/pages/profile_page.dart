import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shutterfly_agenda/features/auth/presentation/pages/login_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/employee_model.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  final EmployeeModel employee;
  final VoidCallback? onLogout;

  const ProfilePage({
    super.key,
    required this.employee,
    this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userDataFuture;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  /// Fetch user data from /api/auth/me endpoint
  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final dio = ApiClient.instance;
      final response = await dio.get(ApiEndpoints.meEndpoint);
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch user data');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 
                      e.response?.data['error'] ?? 
                      'Failed to fetch user data';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  /// Refresh token using /api/auth/token/refresh/ endpoint
  Future<void> _refreshToken() async {
    try {
      final dio = ApiClient.instance;
      final response = await dio.post(ApiEndpoints.tokenRefreshEndpoint);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['token'] ?? data['access_token'] ?? '';
        
        if (newToken.isNotEmpty) {
          ApiClient.setToken(newToken);
          AppToast.showSuccess(context, 'Token refreshed successfully');
        }
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 
                      e.response?.data['error'] ?? 
                      'Failed to refresh token';
      AppToast.showError(context, message);
    } catch (e) {
      AppToast.showError(context, 'Error: ${e.toString()}');
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (!confirmed) return;

    setState(() => _isLoggingOut = true);

    try {
      // If onLogout callback is provided, use it
      if (widget.onLogout != null) {
        widget.onLogout!();
      } else {
        // Fallback: Clear tokens manually if no callback provided
        await _clearAllTokens();
      }
      
      // Pop back to previous screen after logout
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Even if error occurs, ensure user is logged out
      print('Logout error: $e');
      if (mounted) {
        // Clear tokens manually as fallback
        await _clearAllTokens();
        // Pop back
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  /// Clear all saved tokens from SharedPreferences
  Future<void> _clearAllTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      await prefs.remove('token');
      print('All tokens cleared successfully');
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  /// Show logout confirmation dialog
  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
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
                    onPressed: () => setState(() {
                      _userDataFuture = _fetchUserData();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userData = snapshot.data ?? {};
          final userName = userData['name'] ?? userData['displayName'] ?? widget.employee.name;
          final userEmail = userData['email'] ?? widget.employee.email;
          final userRole = userData['role'] ?? userData['user_role'] ?? widget.employee.role.displayName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userEmail,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Profile details
                _buildDetailCard('User Role', userRole),
                const SizedBox(height: 16),
                _buildDetailCard('Email', userEmail),
                const SizedBox(height: 16),
                const SizedBox(height: 32),

                // Action buttons
                // ElevatedButton.icon(
                //   onPressed: _refreshToken,
                //   icon: const Icon(Icons.refresh_rounded),
                //   label: const Text('Refresh Token'),
                //   style: ElevatedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 12),
                //     backgroundColor: AppColors.primary,
                //   ),
                // ),
                ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textOnPrimary,
                            ),
                          ),
                        )
                      : const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
