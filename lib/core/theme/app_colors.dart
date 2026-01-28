import 'package:flutter/material.dart';

class AppColors {
  // Premium Emerald & Gold Palette
  static const Color primary = Color(0xFF0056D2); // Deep Premium Emerald
  static const Color primaryLight = Color(0xFF00A86B); // Vibrant Emerald
  static const Color primaryDark = Color(0xFF004D36); // Night Emerald
  static const Color accent = Color(0xFFD4AF37); // Metallic Gold
  static const Color accentLight = Color(0xFFFFD700); // Pure Gold

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0A0F0C); // Deep Charcoal Night (Dark Mode by default for premium feel)
  static const Color surface = Color(0xFF161B18); // Slightly lighter charcoal
  static const Color surfaceGreen = Color(0xFF0E241B); // Mossy surface

  // Glassmorphism Tokens
  static const Color glassBase = Color(0x33FFFFFF); // 20% White
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% White border
  static const Color glassHighlight = Color(0x1AFFFFFF); // 10% White shine

  // Text Hierarchy
  static const Color textPremium = Color(0xFFF5F5F5); // Off-white
  static const Color textMuted = Color(0xFFA0A0A0); // Greyed out text
  static const Color textGold = Color(0xFFD4AF37); // Gold for emphasis

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE53935);
  
  // Compatibility
  static const Color textPrimary = textPremium;
  static const Color textSecondary = textMuted;
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textGrey = textMuted;
  static const Color divider = Color(0x1AFFFFFF); // Thin transparent divider
}
