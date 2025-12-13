import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';

import 'package:beitak_app/features/user/home/presentation/views/my_service/models/booking_list_item.dart';

class ServiceCard extends StatelessWidget {
  final BookingListItem item;
  final VoidCallback? onChanged;

  const ServiceCard({
    super.key,
    required this.item,
    this.onChanged,
  });

  Color _statusColor() {
    if (item.isCancelled) return Colors.red.shade600;
    if (item.isCompleted) return Colors.blue.shade700;
    if (item.isPending) return Colors.orange.shade700;
    return AppColors.lightGreen;
  }

  IconData _statusIcon() {
    if (item.isCancelled) return Icons.cancel_rounded;
    if (item.isCompleted) return Icons.verified_rounded;
    if (item.isPending) return Icons.hourglass_top_rounded;
    return Icons.schedule_rounded;
  }

  String _moneyText() {
    if (item.price == null) return 'غير محدد';
    final v = item.price!.toStringAsFixed(
      item.price == item.price!.roundToDouble() ? 0 : 2,
    );
    return '${item.currency ?? ''} $v'.trim();
  }

  void _openDetails(BuildContext context) {
    context.push(AppRoutes.serviceDetail, extra: item).then((value) {
      // ✅ لو التفاصيل رجّعت true معناها صار إلغاء → نحدث التاب عبر onChanged
      if (value == true) {
        onChanged?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor();

    return Padding(
      padding: SizeConfig.padding(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openDetails(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // شريط ملون على يمين الكرت حسب الحالة
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    color: sColor.withValues(alpha: 0.85),
                  ),
                ),
                Padding(
                  padding: SizeConfig.padding(all: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شارة الحالة + رقم الطلب
                      Row(
                        children: [
                          Container(
                            padding: SizeConfig.padding(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: sColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: sColor.withValues(alpha: 0.55),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _statusIcon(),
                                  size: 16,
                                  color: sColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.typeLabel,
                                  style: TextStyle(
                                    fontSize: SizeConfig.ts(12),
                                    fontWeight: FontWeight.w700,
                                    color: sColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '#${item.bookingNumber}',
                            style: TextStyle(
                              fontSize: SizeConfig.ts(12),
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizeConfig.v(12),

                      // اسم الخدمة
                      Text(
                        item.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SizeConfig.ts(18),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizeConfig.v(10),

                      // سطر التاريخ + الوقت
                      Row(
                        children: [
                          Expanded(
                            child: _miniInfo(
                              Icons.calendar_today_rounded,
                              item.date.isEmpty ? '—' : item.date,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _miniInfo(
                              Icons.access_time_rounded,
                              item.time.isEmpty ? '—' : item.time,
                            ),
                          ),
                        ],
                      ),
                      SizeConfig.v(10),

                      // سطر الموقع
                      _miniInfo(
                        Icons.location_on_rounded,
                        item.location.isEmpty ? '—' : item.location,
                        maxLines: 2,
                      ),
                      SizeConfig.v(14),

                      Row(
                        children: [
                          // السعر
                          Container(
                            padding: SizeConfig.padding(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _moneyText(),
                                  style: TextStyle(
                                    fontSize: SizeConfig.ts(13),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // زر "عرض التفاصيل"
                          ElevatedButton.icon(
                            onPressed: () => _openDetails(context),
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            label: Text(
                              'عرض التفاصيل',
                              style: TextStyle(
                                fontSize: SizeConfig.ts(13),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBackground,
                              foregroundColor: AppColors.textPrimary,
                              padding: SizeConfig.padding(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: SizeConfig.ts(12),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
