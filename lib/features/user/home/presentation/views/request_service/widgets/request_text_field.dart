import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RequestTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final Widget? suffix;

  // ✅ NEW
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const RequestTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.suffix,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.semiBold.copyWith(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(13),
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '', // ✅ نخفي العداد حتى ما يخرب الشكل
            hintText: hint,
            hintStyle: AppTextStyles.body14.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: SizeConfig.ts(13),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: SizeConfig.padding(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
