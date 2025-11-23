import 'package:beitak_app/features/provider/home/presentation/views/my_service/widgets/provider_job_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'provider_service_info_row.dart';

class ProviderServiceCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const ProviderServiceCard({super.key, required this.job});

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job['service'],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(job['status']).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    color: _statusColor(job['status']),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizeConfig.v(6),
          Text('العميل: ${job['client']}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),

          SizeConfig.v(12),
          ProviderServiceInfoRow(
              icon: Icons.calendar_today_outlined, label: job['date']),
          ProviderServiceInfoRow(icon: Icons.access_time, label: job['time']),
          ProviderServiceInfoRow(
              icon: Icons.location_on_outlined, label: job['location']),
          SizeConfig.v(6),
          Text('${job['price']}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizeConfig.v(12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.8,
                    minChildSize: 0.5,
                    builder: (_, controller) => SingleChildScrollView(
                      controller: controller,
                      child: ProviderJobDetailsSheet(job: job),
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.lightGreen,
                side: const BorderSide(color: AppColors.lightGreen),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('عرض التفاصيل'),
            ),
          ),
        ],
      ),
    );
  }
}
