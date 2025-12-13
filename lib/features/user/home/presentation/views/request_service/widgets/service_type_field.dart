import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

import '../models/service_type_option.dart';

class ServiceTypeField extends StatelessWidget {
  final ServiceTypeOption? selected;
  final ValueChanged<ServiceTypeOption> onSelected;

  const ServiceTypeField({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الخدمة *',
          style: TextStyle(
            fontSize: SizeConfig.ts(13),
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final picked = await showModalBottomSheet<ServiceTypeOption>(
              context: context,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              builder: (ctx) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: SizeConfig.h(10)),
                        Text(
                          'اختر نوع الخدمة',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: SizeConfig.ts(15),
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(10)),
                        ...ServiceTypeOptions.all.map((e) {
                          final isSel = selected?.categorySlug == e.categorySlug;
                          return ListTile(
                            leading: Icon(e.icon, color: isSel ? AppColors.lightGreen : AppColors.textSecondary),
                            title: Text(
                              e.labelAr,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: isSel ? AppColors.lightGreen : AppColors.textPrimary,
                              ),
                            ),
                            trailing: isSel ? const Icon(Icons.check_circle, color: AppColors.lightGreen) : null,
                            onTap: () => Navigator.of(ctx).pop(e),
                          );
                        }),
                        SizedBox(height: SizeConfig.h(10)),
                      ],
                    ),
                  ),
                );
              },
            );

            if (picked != null) onSelected(picked);
          },
          child: Container(
            width: double.infinity,
            padding: SizeConfig.padding(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.miscellaneous_services, color: AppColors.textSecondary),
                SizedBox(width: SizeConfig.w(10)),
                Expanded(
                  child: Text(
                    selected?.labelAr ?? 'اختر نوع الخدمة',
                    style: TextStyle(
                      fontSize: SizeConfig.ts(13),
                      fontWeight: FontWeight.w800,
                      color: selected == null ? AppColors.textSecondary.withValues(alpha: 0.7): AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
