import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/utils/number_format.dart';

import 'details_line.dart';

class ServiceDetailsInfoSection extends StatelessWidget {
  final String date;
  final String time;
  final String location;
  final String priceText;

  final String? providerName;
  final String? providerPhone;

  final bool isCancelled;
  final String cancelReason; // ✅ حالياً "غير محدد" حسب طلبك

  const ServiceDetailsInfoSection({
    super.key,
    required this.date,
    required this.time,
    required this.location,
    required this.priceText,
    required this.providerName,
    required this.providerPhone,
    required this.isCancelled,
    required this.cancelReason,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailsLine(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.textSecondary,
          label: 'التاريخ:',
          value: date.isEmpty ? '—' : date,
        ),
        DetailsLine(
          icon: Icons.access_time_rounded,
          iconColor: AppColors.textSecondary,
          label: 'الوقت:',
          value: time.isEmpty ? '—' : time,
        ),
        if (location.isNotEmpty)
          DetailsLine(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red.shade600,
            label: 'الموقع:',
            value: location,
          ),
        DetailsLine(
          icon: Icons.payments_rounded,
          iconColor: AppColors.textSecondary,
          label: 'السعر:',
          value: priceText,
        ),
        DetailsLine(
          icon: Icons.person_rounded,
          iconColor: AppColors.textSecondary,
          label: 'المزود:',
          value: providerName ?? 'غير متاح حالياً',
        ),
        if (providerPhone != null && providerPhone!.trim().isNotEmpty)
          DetailsLine(
            icon: Icons.phone_rounded,
            iconColor: AppColors.textSecondary,
            label: 'الهاتف:',
            value: NumberFormat.smart(providerPhone!.trim()),
          ),
        if (isCancelled)
          DetailsLine(
            icon: Icons.info_outline_rounded,
            iconColor: Colors.red.shade700,
            label: 'سبب الإلغاء:',
            value: cancelReason,
          ),
      ],
    );
  }
}
