// lib/features/home/presentation/views/request_widgets/request_text_field.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class RequestTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool required;

  const RequestTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            if (!required)
              Text(' (اختياري)', style: TextStyle(fontSize: SizeConfig.ts(12), color: AppColors.textSecondary)),
          ],
        ),
        SizeConfig.v(8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            contentPadding: SizeConfig.padding(horizontal: 16, vertical: 14),
          ),
          validator: required ? (v) => v!.trim().isEmpty ? 'هذا الحقل مطلوب' : null : null,
        ),
      ],
    );
  }
}