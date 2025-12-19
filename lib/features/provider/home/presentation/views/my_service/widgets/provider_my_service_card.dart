import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/models/provider_service_model.dart';
import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_service_details_sheet.dart';
import 'package:flutter/material.dart';

class ProviderServiceCard extends StatelessWidget {
  final ProviderServiceModel service;
  const ProviderServiceCard({super.key, required this.service});

  String _arabicCategory() {
    final cat = (service.categoryOther ?? '').trim();
    if (cat.isNotEmpty) return cat;

    switch (service.name.toLowerCase()) {
      case 'plumbing':
        return 'السباكة';
      case 'cleaning':
        return 'التنظيف';
      case 'home_maintenance':
        return 'صيانة للمنزل';
      case 'appliance_maintenance':
        return 'صيانة للأجهزة';
      case 'electricity':
        return 'كهرباء';
      default:
        return service.name;
    }
  }

  String _priceText() {
    final p = service.basePrice.toStringAsFixed(0);
    if (service.priceType == 'hourly') return 'يبدأ من: $p د.أ / ساعة';
    return 'يبدأ من: $p د.أ';
  }

  void _openSheet(BuildContext context, {required int initialTab}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderServiceDetailsSheet(
        service: service,
        initialTab: initialTab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packagesCount = service.packages.length;

    return Container(
      padding: SizeConfig.padding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + badges
          Row(
            children: [
              Expanded(
                child: Text(
                  _arabicCategory(),
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),

              // ✅ Badge جديد
              if (service.isNew) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'جديد',
                    style: AppTextStyles.label12.copyWith(
                      fontSize: SizeConfig.ts(12),
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (service.isActive ? AppColors.lightGreen : Colors.grey).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service.isActive ? 'نشطة' : 'غير نشطة',
                  style: AppTextStyles.label12.copyWith(
                    fontSize: SizeConfig.ts(12),
                    fontWeight: FontWeight.w600,
                    color: service.isActive ? AppColors.lightGreen : Colors.grey,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          SizeConfig.v(8),

          Text(
            (service.description ?? '').trim().isEmpty ? '—' : service.description!.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),

          SizeConfig.v(10),

          Row(
            children: [
              const Icon(Icons.attach_money_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _priceText(),
                  style: AppTextStyles.label12.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          SizeConfig.v(6),

          Row(
            children: [
              const Icon(Icons.view_module_rounded, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'عدد الباقات: $packagesCount',
                style: AppTextStyles.label12.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizeConfig.v(14),

          if (packagesCount == 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openSheet(context, initialTab: 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: SizeConfig.padding(vertical: 12),
                ),
                child: Text(
                  'تفاصيل الخدمة',
                  style: AppTextStyles.body14.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openSheet(context, initialTab: 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: SizeConfig.padding(vertical: 12),
                    ),
                    child: Text(
                      'عرض الباقات',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openSheet(context, initialTab: 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.lightGreen,
                      side: const BorderSide(color: AppColors.lightGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: SizeConfig.padding(vertical: 12),
                    ),
                    child: Text(
                      'تفاصيل الخدمة',
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
