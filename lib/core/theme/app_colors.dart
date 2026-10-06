import 'package:flutter/material.dart';

/// Centralized color palette for the Shutterfly Agenda app.
/// Uses a warm, festive Indian celebration theme.
class AppColors {
  AppColors._();

  // ── Brand / Primary ──────────────────────────────────────────────────
  static const Color primary = Color(0xFFE85D04);
  static const Color primaryLight = Color(0xFFFF8C42);
  static const Color primaryDark = Color(0xFFB54200);

  // ── Secondary ────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF7B2D8B);
  static const Color secondaryLight = Color(0xFFAB5EC3);
  static const Color secondaryDark = Color(0xFF4E1A5A);

  // ── Accent / Gold ────────────────────────────────────────────────────
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFC9A800);
  static const Color amber = Color(0xFFFFB300);

  // ── Backgrounds ──────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFF0E0);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5C5C5C);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Status ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDECEA);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF9E7);
  static const Color info = Color(0xFF2980B9);
  static const Color infoLight = Color(0xFFD6EAF8);

  // ── Divider / Border ─────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0D6CC);
  static const Color border = Color(0xFFD4C4B0);

  // ── Shadows ──────────────────────────────────────────────────────────
  static const Color shadow = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // ── Feature-specific ─────────────────────────────────────────────────
  static const Color agendaTag = Color(0xFF0077B6);
  static const Color agendaTagLight = Color(0xFFCAF0F8);
  static const Color votingActive = Color(0xFF27AE60);
  static const Color votingInactive = Color(0xFFBDC3C7);
  static const Color sweetsCard = Color(0xFFFDE2E4);
  static const Color potluckCard = Color(0xFFE8F5E9);
  static const Color galleryOverlay = Color(0x88000000);

  // ── Gradient helpers ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryDark, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient festiveGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [amber, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}