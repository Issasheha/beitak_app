import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

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

    final disabled = !hasPackages;

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: disabled ? AppColors.textSecondary : AppColors.textPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الباقة (اختياري)',
                    style: TextStyle(
                      color: disabled ? AppColors.textSecondary : AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: SizeConfig.ts(14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disabled ? 'لا توجد باقات لهذه الخدمة' : selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: SizeConfig.ts(13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (!disabled) ...[
              Text(
                'تغيير',
                style: TextStyle(
                  color: AppColors.lightGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: SizeConfig.ts(13),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            ] else
              const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
