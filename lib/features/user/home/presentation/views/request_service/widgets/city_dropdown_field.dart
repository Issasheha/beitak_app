import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

import '../models/city_model.dart';

class CityDropdownField extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<CityModel> cities;
  final CityModel? selected;
  final ValueChanged<CityModel?> onChanged;
  final VoidCallback onRetry;

  const CityDropdownField({
    super.key,
    required this.loading,
    required this.error,
    required this.cities,
    required this.selected,
    required this.onChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const preferArabic = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المحافظة *',
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),

        if (loading)
          Container(
            padding: SizeConfig.padding(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: SizeConfig.w(10)),
                Text(
                  'جارٍ تحميل المحافظات...',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<CityModel>(
            initialValue: selected,
            isExpanded: true,
            items: cities
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c.localizedName(preferArabic: preferArabic),
                      style: TextStyle(
                        fontSize: SizeConfig.ts(13),
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: (v) => (v == null) ? 'المحافظة مطلوبة' : null,
            decoration: InputDecoration(
              hintText: 'اختر المحافظة',
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
              suffixIcon: const Icon(Icons.location_city, color: AppColors.textSecondary),
            ),
          ),

        if (!loading && error != null) ...[
          SizedBox(height: SizeConfig.h(8)),
          Row(
            children: [
              Expanded(
                child: Text(
                  error!,
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
              ),
            ],
          ),
        ],
      ],
    );
  }
}
