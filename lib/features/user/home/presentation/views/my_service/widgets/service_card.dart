// lib/features/home/presentation/views/my_service_widgets/service_card.dart
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/widgets/service_info_row.dart';
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ServiceCard({super.key, required this.item});

  Color _getStatusColor(String type) {
    if (type == 'قادمة' || type == 'قيد الانتظار') return AppColors.lightGreen;
    if (type == 'ملغاة') return Colors.red.shade500;
    if (type == 'مكتملة') return Colors.blue.shade600;
    return AppColors.lightGreen;
  }

  String _getStatusText(String type) {
    if (type == 'قادمة') return 'قادمة';
    if (type == 'ملغاة') return 'ملغاة';
    if (type == 'مكتملة') return 'مكتملة';
    return 'قيد الانتظار';
  }

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;

    return Container(
      margin: SizeConfig.padding(bottom: 16),
      padding: SizeConfig.padding(all: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item['id'], style: TextStyle(fontSize: SizeConfig.ts(13), color: AppColors.textSecondary)),
              const Spacer(),
              Container(
                padding: SizeConfig.padding(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _getStatusColor(type), width: 1.4),
                ),
                child: Text(
                  _getStatusText(type),
                  style: TextStyle(
                    fontSize: SizeConfig.ts(12),
                    color: _getStatusColor(type),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizeConfig.v(14),

          Text(
            item['service'],
            style: TextStyle(fontSize: SizeConfig.ts(18), fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),

          SizeConfig.v(18),

          Row(
            children: [
              ServiceInfoRow(label: 'التاريخ', value: item['date'], icon: Icons.calendar_today_outlined),
              ServiceInfoRow(label: 'الوقت', value: item['time'], icon: Icons.access_time_outlined),
              ServiceInfoRow(label: 'الموقع', value: item['location'], icon: Icons.location_on_outlined, isLong: true),
            ],
          ),

          SizeConfig.v(20),

          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              label: Text('عرض التفاصيل', style: TextStyle(fontSize: SizeConfig.ts(14))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                foregroundColor: Colors.white,
                padding: SizeConfig.padding(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}