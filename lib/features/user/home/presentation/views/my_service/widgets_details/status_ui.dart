import 'package:flutter/material.dart';

class StatusUi {
  final String label;
  final Color color;
  final Color bg;
  final Color border;
  final String footerText;

  const StatusUi({
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
    required this.footerText,
  });
}
