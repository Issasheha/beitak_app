import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

class ProviderEmptyServicesState extends StatelessWidget {
  final String message;

  const ProviderEmptyServicesState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Center(
      child: Padding(
        padding: SizeConfig.padding(horizontal: 18, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 78,
              color: AppColors.textSecondary.withValues(alpha: 0.35),
            ),
            SizeConfig.v(16),

            Text(
              message,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(16),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizeConfig.v(14),

            // ✅ Small + nice button
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => context.push(AppRoutes.providerAddService),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.lightGreen.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.lightGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'إضافة خدمة',
                      style: AppTextStyles.body14.copyWith(
                        fontSize: SizeConfig.ts(12.8),
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
