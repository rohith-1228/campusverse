import 'package:flutter/material.dart';

/// App color palette supporting premium glassmorphism dark & clean light themes
class AppColors {
  // Dark Theme Backgrounds
  static const Color darkBg = Color(0xFF090D1A);
  static const Color darkBgSecondary = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkGlass = Color(0x1AFFFFFF);
  static const Color darkGlassCard = Color(0x221E293B);
  static const Color darkGlassBorder = Color(0x2BFFFFFF);

  // Light Theme Backgrounds
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightBgSecondary = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0x80FFFFFF);
  static const Color lightGlassCard = Color(0xB3FFFFFF);
  static const Color lightGlassBorder = Color(0x336366F1);

  // Primary & Gradient Accents
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondary = Color(0xFF8B5CF6); // Violet / Purple
  static const Color secondaryLight = Color(0xFFA78BFA);

  static const Color electricBlue = Color(0xFF38BDF8); // Electric Sky
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonPink = Color(0xFFEC4899);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF6366F1), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassOverlayGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHighlightGradient = LinearGradient(
    colors: [Color(0x408B5CF6), Color(0x106366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
