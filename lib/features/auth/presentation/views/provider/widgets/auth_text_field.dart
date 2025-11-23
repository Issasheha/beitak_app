import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool onDarkBackground;
  final Color? customFillColor;
  final Color? customTextColor;
  final Color? customHintColor;
  final Color? customLabelColor;
  final Color? customIconColor;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.controller,
    this.onDarkBackground = true,
    this.customFillColor,
    this.customTextColor,
    this.customHintColor,
    this.customLabelColor,
    this.customIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final hintColor = customHintColor ?? (onDarkBackground ? Colors.black87 : AppColors.textSecondary);
    final textColor = customTextColor ?? (onDarkBackground ? AppColors.white : AppColors.textPrimary);
    final iconColor = customIconColor ?? (onDarkBackground ? Colors.black87 : AppColors.primaryGreen);
    final fillColor = customFillColor ?? (onDarkBackground ? Colors.white.withValues(alpha: 0.18): AppColors.background);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizeConfig.v(6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            color: textColor,
            fontSize: SizeConfig.ts(14),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: SizeConfig.ts(13),
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.h(10),
              horizontal: SizeConfig.w(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: iconColor, size: SizeConfig.w(20)),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}