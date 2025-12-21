import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // ✅ NEW
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

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

    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final hintColor =
        customHintColor ?? (onDarkBackground ? Colors.black87 : AppColors.textSecondary);
    final textColor =
        customTextColor ?? (onDarkBackground ? AppColors.white : AppColors.textPrimary);
    final iconColor =
        customIconColor ?? (onDarkBackground ? Colors.black87 : AppColors.primaryGreen);
    final fillColor =
        customFillColor ?? (onDarkBackground ? Colors.white.withValues(alpha: 0.18) : AppColors.background);

    final labelColor = customLabelColor ?? AppColors.textPrimary;

    final disabledFill = AppColors.background.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body14.copyWith(
            color: labelColor,
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
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body14.copyWith(
            color: enabled ? textColor : AppColors.textSecondary,
            fontSize: SizeConfig.ts(14),
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body14.copyWith(
              color: hintColor,
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: enabled ? fillColor : disabledFill,
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
