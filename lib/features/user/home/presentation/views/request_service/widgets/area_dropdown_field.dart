import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

import '../models/location_models.dart' show AreaModel;

class AreaDropdownField extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final String? error;
  final List<AreaModel> areas;
  final AreaModel? selected;
  final ValueChanged<AreaModel?> onChanged;
  final VoidCallback onRetry;

  const AreaDropdownField({
    super.key,
    required this.enabled,
    required this.loading,
    required this.error,
    required this.areas,
    required this.selected,
    required this.onChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return _disabledHint('اختر المحافظة أولاً');
    }

    if (loading) {
      return _disabledHint('جارٍ تحميل المناطق...');
    }

    if (error != null) {
      return Container(
        padding: SizeConfig.padding(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'تعذر تحميل المناطق: $error',
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          ],
        ),
      );
    }

    return DropdownButtonFormField<AreaModel>(
      value: selected,
      isExpanded: true,
      items: areas
          .map(
            (a) => DropdownMenuItem(
              value: a,
              child: Text(
                // افترض إن عندك name_ar أو name في الـ model
                (a.nameAr?.trim().isNotEmpty == true)
                    ? a.nameAr!.trim()
                    : (a.nameAr?.toString() ?? ''),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => (v == null) ? 'المنطقة مطلوبة' : null,
      decoration: InputDecoration(
        labelText: 'المنطقة *',
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
      ),
    );
  }

  Widget _disabledHint(String text) {
    return Container(
      width: double.infinity,
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: SizeConfig.ts(12),
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
