import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/pages/provider_edit_package_view.dart';
import 'package:flutter/material.dart';

class ProviderPackageDetailsSheet extends StatelessWidget {
  final ProviderServiceModel service;
  final int packageIndex;

  const ProviderPackageDetailsSheet({
    super.key,
    required this.service,
    required this.packageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = service.packages[packageIndex];
    final height = MediaQuery.of(context).size.height * 0.62;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: SizeConfig.h(16),
            left: SizeConfig.w(16),
            right: SizeConfig.w(16),
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizeConfig.v(14),

              Text(
                pkg.name,
                style: AppTextStyles.title18.copyWith(
                  fontSize: SizeConfig.ts(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizeConfig.v(8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'السعر: ${pkg.price.toStringAsFixed(0)} د.أ',
                  style: AppTextStyles.label12.copyWith(
                    fontSize: SizeConfig.ts(12.5),
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightGreen,
                  ),
                ),
              ),

              SizeConfig.v(14),
              Text(
                'الوصف',
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(6),
              Text(
                (pkg.description ?? '').trim().isEmpty ? '—' : pkg.description!.trim(),
                style: AppTextStyles.body14.copyWith(color: AppColors.textSecondary),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
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
                                'تم حفظ التعديل بنجاح',
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: SizeConfig.padding(vertical: 12),
                      ),
                      child: Text(
                        'تعديل الباقة',
                        style: AppTextStyles.body14.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lightGreen,
                        side: const BorderSide(color: AppColors.lightGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: SizeConfig.padding(vertical: 12),
                      ),
                      child: Text(
                        'إغلاق',
                        style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
