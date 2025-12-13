// lib/core/utils/app_text_styles.dart
import 'package:flutter/material.dart';

/// Centralized typography for Beitak.
/// Default font family: Poppins
///
/// Designer preference: Regular (w400) is the default across most UI.
abstract class AppTextStyles {
  static const String fontFamily = 'Poppins';

  // -----------------------------
  // Base (Designer default)
  // -----------------------------
  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle medium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle semiBold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
  );

  // -----------------------------
  // Display / Large Headings
  // (ممكن تكون أثقل شوي لتمييز العناوين)
  // -----------------------------
  static const TextStyle display32 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );

  static const TextStyle display28 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // -----------------------------
  // Headlines
  // -----------------------------
  static const TextStyle headline24 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle headline22 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  // -----------------------------
  // Titles (خليتها Medium بدل SemiBold عشان تظل أقرب للـ Regular)
  // -----------------------------
  static const TextStyle title20 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle title18 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // -----------------------------
  // Body (Regular - default UI)
  // -----------------------------
  static const TextStyle body16 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle body14 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  // -----------------------------
  // Labels / Small text
  // (Regular غالبًا، إلا إذا بدك أزرار/Chips تكون أوضح)
  // -----------------------------
  static const TextStyle label12 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle caption11 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const TextStyle overline10 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
  );
  // -----------------------------
  // Aliases (لتفادي أخطاء مثل h2)
  // -----------------------------
  static const TextStyle h1 = headline24;
  static const TextStyle h2 = headline22;

  // -----------------------------
  // Semantic styles (موحّدين لكل المشروع)
  // -----------------------------
  /// عنوان شاشة / AppBar / Headline عام
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// عنوان BottomSheet / Dialog
  static const TextStyle sheetTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// عنوان Card داخل الشاشة
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// عنوان Section داخل الكارد/الشيت
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.55,
  );

  /// Label صغير (مثل “العميل:”)
  static const TextStyle lineLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Value صغير (قيمة الليبل)
  static const TextStyle lineValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  /// نص عادي
  static const TextStyle body = body14;

  /// نص مساعد صغير
  static const TextStyle helper = label12;

  // -----------------------------
  // Theme helpers
  // -----------------------------
  /// Plug this into ThemeData(textTheme: AppTextStyles.textTheme(...))
  static TextTheme textTheme({Color? color}) {
    TextStyle c(TextStyle s) => (color == null) ? s : s.copyWith(color: color);

    return TextTheme(
      displayLarge: c(display32),
      displayMedium: c(display28),
      headlineLarge: c(headline24),
      headlineMedium: c(headline22),
      titleLarge: c(title20),
      titleMedium: c(title18),
      bodyLarge: c(body16),
      bodyMedium: c(body14),
      labelLarge: c(label12),
      labelMedium: c(caption11),
      labelSmall: c(overline10),
    );
  }
}
