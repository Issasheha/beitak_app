import 'package:flutter/material.dart';

class AppColors {
  // الأساسية
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0x0ff3f3f5);
  static const Color lightGreen = Color(0xFF64AB68);
  static const Color goldAccent = Color(0xFFFFC107);
  static const Color white = Color(0xFFFFFFFF);
  static const Color buttonBackground = Color(0xFF12332C);

  // إضافية للـ UI الفاتح
  static const Color background = Color(0xFFDFE3E6);      // خلفية عامة
  static const Color cardBackground = Color(0xFFFFFFFF);  // الكروت
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFE53935);
  static const Color loginBackground = Color(0xFFE0E0E0);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [buttonBackground, lightGreen],
  );

  static final BoxShadow primaryShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}
