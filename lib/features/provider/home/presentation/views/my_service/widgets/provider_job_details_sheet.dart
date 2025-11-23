import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class ProviderJobDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> job;

  const ProviderJobDetailsSheet({super.key, required this.job});

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
    final height = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: SizeConfig.h(18),
          left: SizeConfig.w(18),
          right: SizeConfig.w(18),
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== العنوان ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job['service'],
                      style: TextStyle(
                        fontSize: SizeConfig.ts(20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(job['status']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _translateStatus(job['status']),
                      style: TextStyle(
                        color: _statusColor(job['status']),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              SizeConfig.v(10),

              // ========== بيانات العميل ==========
              Text(
                'معلومات العميل',
                style: TextStyle(
                  fontSize: SizeConfig.ts(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(8),
              _clientInfoBox(context),

              SizeConfig.v(18),
              _infoItem(Icons.calendar_today, 'التاريخ', job['date']),
              _infoItem(Icons.access_time, 'الوقت', job['time']),
              _infoItem(Icons.location_on_outlined, 'الموقع', job['location']),
              _infoItem(Icons.monetization_on_outlined, 'السعر', job['price']),
              SizeConfig.v(18),

              Text(
                'ملاحظات إضافية:',
                style: TextStyle(
                  fontSize: SizeConfig.ts(15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizeConfig.v(6),
              Text(
                job['notes'] ?? 'لا توجد ملاحظات من العميل.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: SizeConfig.ts(14),
                ),
              ),
              SizeConfig.v(30),

              // ========== الأزرار حسب الحالة ==========
              _buildActionButtons(context, job['status']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clientInfoBox(BuildContext context) {
    final bool showPhone = job['showPhone'] ?? false;

    return Container(
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _clientRow(Icons.person_outline, job['client']),
          _clientRow(Icons.email_outlined, 'client@example.com'),
          if (showPhone)
            _clientRow(Icons.phone_outlined, '+962 79 XXX XXXX')
          else
            _clientRow(Icons.phone_outlined, 'العميل لم يسمح بعرض الرقم'),
        ],
      ),
    );
  }

  Widget _clientRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    if (status == 'Approved') {
      // ======== حالة الموافقة ========
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.done, size: 18),
              label: const Text('تم الإنجاز'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.w(12)),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, color: Colors.green, size: 18),
              label: const Text('اتصال بالعميل'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'Pending') {
      // ======== حالة قيد الانتظار ========
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: اكتب منطق الموافقة هنا
                // مثال: setState(() => job['status'] = 'Approved');
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('موافقة على الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.w(12)),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: اكتب منطق الإلغاء هنا
                // مثال: setState(() => job['status'] = 'Cancelled');
              },
              icon: const Icon(Icons.cancel_outlined,
                  color: Colors.red, size: 18),
              label: const Text('إلغاء الطلب'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Pending':
        return 'قيد الانتظار';
      case 'Approved':
        return 'موافقة';
      case 'Completed':
        return 'مكتمل';
      case 'Cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
