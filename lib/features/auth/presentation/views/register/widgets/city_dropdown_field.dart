import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/auth/presentation/providers/locations_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityDropdownField extends ConsumerWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const CityDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(citiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المدينة *',
          style: AppTextStyles.body14.copyWith(
            color: AppColors.textPrimary,
            fontSize: SizeConfig.ts(14.5),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),

        Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
          child: citiesAsync.when(
            loading: () => _buildDropdown(
              context,
              items: const [],
              enabled: false,
              hint: 'جاري تحميل المدن...',
            ),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  context,
                  items: const [],
                  enabled: false,
                  hint: 'تعذر تحميل المدن',
                ),
                SizedBox(height: SizeConfig.h(6)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'حدث خطأ أثناء تحميل المدن. حاول مرة أخرى.',
                        style: AppTextStyles.body14.copyWith(
                          color: Colors.red,
                          fontSize: SizeConfig.ts(12),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(citiesProvider),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ],
            ),
            data: (cities) => _buildDropdown(
              context,
              items: cities
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(
                        c.displayName,
                        style: AppTextStyles.body14.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: SizeConfig.ts(14.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              enabled: true,
              hint: 'اختر المدينة',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required List<DropdownMenuItem<int>> items,
    required bool enabled,
    required String hint,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      validator: (v) {
        if (!enabled) return 'يرجى المحاولة لاحقاً.';
        if (v == null) return 'يرجى اختيار المدينة.';
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body14.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.5),
          fontSize: SizeConfig.ts(14),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          Icons.location_city,
          color: AppColors.darkGreen,
          size: SizeConfig.w(24),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(20),
          vertical: SizeConfig.h(19),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.darkGreen,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
