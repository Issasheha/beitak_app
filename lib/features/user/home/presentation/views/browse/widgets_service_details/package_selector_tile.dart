import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class PackageSelectorTile extends StatelessWidget {
  const PackageSelectorTile({
    super.key,
    required this.hasPackages,
    required this.selectedLabel,
    required this.onTap,
  });

  final bool hasPackages;
  final String selectedLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final disabled = !hasPackages || onTap == null;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7EF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7EAD7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined,
                color: AppColors.lightGreen, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الباقة (اختياري)',
                    style: AppTextStyles.semiBold.copyWith(
                      color: AppColors.lightGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: SizeConfig.ts(13),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disabled ? 'لا توجد باقات' : selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: SizeConfig.ts(13),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
