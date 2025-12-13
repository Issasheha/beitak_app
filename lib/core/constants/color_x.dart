import 'package:flutter/material.dart';

extension ColorOpacityX on Color {
  /// بديل آمن لـ withOpacity (بدون تحذير) وبنفس النتيجة.
  Color o(double opacity) => withAlpha((opacity * 255).round());
}

extension ColorX on Color {
  /// opacity: 0..1 (بديل clean لـ withOpacity)
  Color alpha(double opacity) {
    final o = opacity.clamp(0.0, 1.0);
    return withAlpha((o * 255).round());
  }
}