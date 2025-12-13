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
        Container(
          padding: SizeConfig.padding(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_city, color: AppColors.textSecondary),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: loading
                    ? Padding(
                        padding: SizeConfig.padding(vertical: 14),
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
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<CityModel>(
                          isExpanded: true,
                          value: selected,
                          hint: Text(
                            'اختر المحافظة',
                            style: TextStyle(
                              fontSize: SizeConfig.ts(13),
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: onChanged,
                        ),
                      ),
              ),
              if (!loading && error != null)
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: AppColors.lightGreen),
                  tooltip: 'إعادة المحاولة',
                ),
            ],
          ),
        ),
        if (!loading && error != null) ...[
          SizedBox(height: SizeConfig.h(8)),
          Text(
            error!,
            style: TextStyle(
              fontSize: SizeConfig.ts(12),
              color: Colors.red.shade700,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}
