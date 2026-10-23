import 'package:flutter/material.dart';

/// Utility class for showing toast messages
class ToastUtils {
  ToastUtils._();

  /// Show a toast message with the given text and duration
  static void showToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = const Color(0xFF323232),
    Color textColor = Colors.white,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show an error toast
  static void showErrorToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Show a success toast
  static void showSuccessToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showToast(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Show a warning toast
  static void showWarningToast(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }
}
