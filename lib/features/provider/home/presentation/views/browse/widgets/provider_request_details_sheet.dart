import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/views/browse/viewmodels/provider_browse_viewmodel.dart';
import 'package:flutter/material.dart';

class ProviderRequestDetailsSheet extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onClose;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  const ProviderRequestDetailsSheet({
    super.key,
    required this.request,
    required this.onClose,
    this.onAccept,
    this.onCancel,
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: SizeConfig.padding(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SizeConfig.radius(24)),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: TextStyle(
                        fontSize: SizeConfig.ts(18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'تفاصيل الطلب ومعلومات العميل',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(12.5),
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizeConfig.v(16),

              // محتوى قابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildClientInfoCard(),
                      SizeConfig.v(16),
                      _buildScheduleAndLocation(),
                      SizeConfig.v(16),
                      _buildCategoryAndNotes(),
                    ],
                  ),
                ),
              ),

              SizeConfig.v(16),
              _buildActions(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClientInfoCard() {
    return Container(
      padding: SizeConfig.padding(all: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات العميل',
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(10),
          _infoRow(Icons.person_outline, request.clientName),
          SizeConfig.v(6),
          _infoRow(Icons.phone, request.phone),
          SizeConfig.v(6),
          _infoRow(Icons.email_outlined, request.email),
        ],
      ),
    );
  }

  Widget _buildScheduleAndLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSmallCard(
            title: 'التاريخ المحدد',
            rows: [
              _infoRow(Icons.calendar_today_outlined,
                  '${request.scheduledDate.year}/${request.scheduledDate.month}/${request.scheduledDate.day}'),
              _infoRow(Icons.access_time, request.timeLabel),
            ],
          ),
        ),
        SizeConfig.hSpace(12),
        Expanded(
          child: _buildSmallCard(
            title: 'الموقع والميزانية',
            rows: [
              _infoRow(Icons.location_on_outlined, request.fullLocation),
              _infoRow(Icons.attach_money, request.budgetLabel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallCard(
          title: 'الفئة',
          rows: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                request.category,
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizeConfig.v(12),
        _buildSmallCard(
          title: 'ملاحظات العميل',
          rows: [
            Text(
              request.notes,
              style: TextStyle(
                fontSize: SizeConfig.ts(13),
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String title,
    required List<Widget> rows,
  }) {
    return Container(
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizeConfig.v(8),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: SizeConfig.ts(16),
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: SizeConfig.ts(13),
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    // حسب حالة الطلب نغيّر الأزرار
    if (onAccept != null && request.status == 'قيد الانتظار') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
                padding: SizeConfig.padding(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'قبول الطلب',
                style: TextStyle(
                  fontSize: SizeConfig.ts(15),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizeConfig.hSpace(12),
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: SizeConfig.padding(vertical: 14),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'إلغاء الطلب',
                style: TextStyle(
                  fontSize: SizeConfig.ts(15),
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizeConfig.hSpace(12),
          TextButton(
            onPressed: onClose,
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    if (request.status == 'مقبولة' && onCancel != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: SizeConfig.padding(vertical: 14),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'إلغاء الطلب',
                style: TextStyle(
                  fontSize: SizeConfig.ts(15),
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizeConfig.hSpace(12),
          TextButton(
            onPressed: onClose,
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    // مكتملة أو أي حالة أخرى → زر إغلاق فقط
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onClose,
        style: OutlinedButton.styleFrom(
          padding: SizeConfig.padding(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'إغلاق',
          style: TextStyle(
            fontSize: SizeConfig.ts(15),
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
