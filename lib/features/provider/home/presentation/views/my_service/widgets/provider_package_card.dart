import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import '../models/provider_service_model.dart';
import 'provider_service_info_row.dart';

class ProviderMyServiceCard extends StatelessWidget {
  final ProviderServiceModel service;
  final VoidCallback onOpenDetails;
  final VoidCallback? onOpenPackages;

  const ProviderMyServiceCard({
    super.key,
    required this.service,
    required this.onOpenDetails,
    required this.onOpenPackages,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = service.isActive ? 'نشطة' : 'غير مفعّلة';
    final statusColor = service.isActive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: SizeConfig.padding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Status
          Row(
            children: [
              Expanded(
                child: Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title18.copyWith(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.label12.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: SizeConfig.ts(12),
                  ),
                ),
              ),
            ],
          ),

          SizeConfig.v(6),

          if ((service.description ?? '').trim().isNotEmpty)
            Text(
              service.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),

          SizeConfig.v(12),

          ProviderServiceInfoRow(
            icon: Icons.price_check_rounded,
            label: 'يبدأ من ${_priceText(service)}',
          ),
          SizeConfig.v(6),
          ProviderServiceInfoRow(
            icon: Icons.layers_outlined,
            label: 'عدد الباقات: ${service.packages.length}',
          ),

          SizeConfig.v(12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.lightGreen,
                    side: const BorderSide(color: AppColors.lightGreen),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'تفاصيل الخدمة',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpenPackages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    disabledBackgroundColor:
                        AppColors.lightGreen.withValues(alpha: 0.25),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'عرض الباقات',
                    style: AppTextStyles.body14.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  String _priceText(ProviderServiceModel s) {
    final p = s.basePrice;
    final suffix = _priceTypeSuffix(s.priceType);
    final price =
        (p == p.roundToDouble()) ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
    return '$price د.أ$suffix';
  }

  String _priceTypeSuffix(String type) {
    switch (type) {
      case 'hourly':
        return ' / ساعة';
      case 'fixed':
        return '';
      case 'custom':
        return ' (حسب الطلب)';
      default:
        return '';
    }
  }
}
