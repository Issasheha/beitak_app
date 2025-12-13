import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/pages/provider_edit_package_view.dart';
import 'package:flutter/material.dart';

class ProviderPackageTile extends StatelessWidget {
  final ProviderServiceModel service;
  final int packageIndex;

  const ProviderPackageTile({
    super.key,
    required this.service,
    required this.packageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = service.packages[packageIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: SizeConfig.padding(all: 12),
          childrenPadding: SizeConfig.padding(horizontal: 12, vertical: 10),
          collapsedIconColor: AppColors.textSecondary,
          iconColor: AppColors.textSecondary,
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.view_module_rounded,
                  color: AppColors.lightGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pkg.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(14),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${pkg.price.toStringAsFixed(0)} د.أ',
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (pkg.description ?? '').trim().isEmpty ? '—' : pkg.description!.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الوصف',
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(13.5),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizeConfig.v(6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                (pkg.description ?? '').trim().isEmpty ? '—' : pkg.description!.trim(),
                style: AppTextStyles.body14.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            SizeConfig.v(12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ProviderEditPackageView(
                        service: service,
                        packageIndex: packageIndex,
                      ),
                    ),
                  );

                  if (res == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم حفظ تعديل الباقة (إن نجح الطلب على السيرفر)',
                          style: AppTextStyles.body14.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: AppColors.lightGreen,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: SizeConfig.padding(vertical: 12),
                ),
                child: Text(
                  'تعديل الباقة',
                  style: AppTextStyles.body14.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
