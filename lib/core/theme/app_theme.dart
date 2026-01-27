import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: isDark ? AppColors.background : Colors.white,
      colorScheme: isDark 
        ? const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: Colors.white,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
          ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: TextStyle(
          color: isDark ? AppColors.textPremium : AppColors.textDark,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: isDark ? AppColors.textPremium : AppColors.textDark,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: isDark ? AppColors.textPremium : AppColors.textDark, 
          letterSpacing: 0.1
        ),
        bodyMedium: TextStyle(
          color: isDark ? AppColors.textMuted : Colors.black54, 
          height: 1.5
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.textPremium : AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.surface : Colors.white,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: isDark 
              ? const BorderSide(color: AppColors.glassBorder, width: 0.5)
              : BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
        margin: const EdgeInsets.all(8),
      ),
      useMaterial3: true,
    );
  }
}
