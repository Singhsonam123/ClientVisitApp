import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Common toast/snackbar utility for displaying messages
class AppToast {
  AppToast._();

  /// Show error message
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.error,
      Icons.error_outline_rounded,
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.success,
      Icons.check_circle_outline_rounded,
    );
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.warning,
      Icons.warning_amber_rounded,
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      AppColors.primary,
      Icons.info_outline_rounded,
    );
  }

  /// Internal method to show snackbar
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
