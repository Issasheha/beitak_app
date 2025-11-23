import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/viewmodels/provider_browse_viewmodel.dart';
import 'package:flutter/material.dart';

class ProviderRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onViewDetails;

  const ProviderRequestCard({
    super.key,
    required this.request,
    required this.onViewDetails,
  });

  Color get _statusColor {
    switch (request.status) {
      case 'قيد الانتظار':
        return Colors.orange;
      case 'مقبولة':
        return Colors.green;
      case 'مكتملة':
        return AppColors.lightGreen;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: SizeConfig.padding(vertical: 8),
      padding: SizeConfig.padding(all: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + الحالة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(11),
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizeConfig.v(4),
          Text(
            'بواسطة ${request.clientName}',
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textSecondary,
            ),
          ),
          SizeConfig.v(12),

          // سطر المسافة + التاريخ + الميزانية
          Row(
            children: [
              Icon(Icons.place_outlined,
                  size: SizeConfig.ts(16),
                  color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${request.distanceKm.toStringAsFixed(1)} كم',
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today_outlined,
                  size: SizeConfig.ts(16),
                  color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${request.scheduledDate.month}/${request.scheduledDate.day}/${request.scheduledDate.year}',
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizeConfig.v(6),

          Row(
            children: [
              Icon(Icons.access_time,
                  size: SizeConfig.ts(16),
                  color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                request.timeLabel,
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.attach_money,
                  size: SizeConfig.ts(16),
                  color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                request.budgetLabel,
                style: TextStyle(
                  fontSize: SizeConfig.ts(12.5),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizeConfig.v(16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                padding: SizeConfig.padding(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: AppColors.borderLight.withValues(alpha: 0.9),
                ),
              ),
              child: Text(
                'عرض التفاصيل',
                style: TextStyle(
                  fontSize: SizeConfig.ts(13.5),
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
