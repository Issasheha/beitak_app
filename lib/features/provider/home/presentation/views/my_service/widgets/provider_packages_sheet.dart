import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_package_details_sheet.dart';
import 'package:flutter/material.dart';

class ProviderPackagesSheet extends StatelessWidget {
  final ProviderServiceModel service;
  const ProviderPackagesSheet({super.key, required this.service});

  String _arabicCategory() {
    final cat = (service.categoryOther ?? '').trim();
    if (cat.isNotEmpty) return cat;
    return service.name;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.70;

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
                'باقات خدمة: ${_arabicCategory()}',
                style: AppTextStyles.body16.copyWith(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(12),

              if (service.packages.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'لا توجد باقات لهذه الخدمة حالياً',
                      style: AppTextStyles.body14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: service.packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = service.packages[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ProviderPackageDetailsSheet(
                              service: service,
                              packageIndex: i,
                            ),
                          );
                        },
                        child: Container(
                          padding: SizeConfig.padding(all: 14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: AppTextStyles.body14.copyWith(
                                        fontSize: SizeConfig.ts(14),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (p.description ?? '').trim().isEmpty
                                          ? '—'
                                          : p.description!.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body14.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${p.price.toStringAsFixed(0)} د.أ',
                                style: AppTextStyles.body14.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_left_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizeConfig.v(12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.lightGreen,
                    side: const BorderSide(color: AppColors.lightGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: SizeConfig.padding(vertical: 12),
                  ),
                  child: Text(
                    'إغلاق',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
