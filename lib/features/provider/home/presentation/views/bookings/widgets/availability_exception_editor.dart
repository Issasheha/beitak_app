import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'package:beitak_app/features/provider/home/presentation/views/bookings/viewmodels/provider_availability_viewmodel.dart';

class AvailabilityExceptionEditor extends StatelessWidget {
  const AvailabilityExceptionEditor({
    super.key,
    required this.selectedDate,
    required this.weeklyDefault,
    required this.currentException,
    required this.onCloseDay,
    required this.onModifyHours,
    required this.onClearException,
  });

  final DateTime selectedDate;
  final WeeklyDayAvailability weeklyDefault;
  final AvailabilityException? currentException;

  final VoidCallback onCloseDay;
  final VoidCallback onModifyHours;
  final VoidCallback onClearException;

  String _dateLabel(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final defaultText = (weeklyDefault.available && weeklyDefault.range != null)
        ? 'افتراضيًا (من القالب): متاح ${weeklyDefault.range!.format(context)}'
        : 'افتراضيًا (من القالب): غير متاح';

    String currentText;
    Color badgeColor;
    String badgeLabel;

    if (currentException == null) {
      currentText = 'لا يوجد استثناء لهذا التاريخ';
      badgeColor = AppColors.textSecondary.withValues(alpha: 0.16);
      badgeLabel = 'بدون';
    } else if (currentException!.type == AvailabilityExceptionType.closedDay) {
      currentText = 'استثناء: مغلق لليوم كامل';
      badgeColor = Colors.red.withValues(alpha: 0.12);
      badgeLabel = 'مغلق';
    } else {
      currentText =
          'استثناء: ساعات خاصة ${currentException!.range!.format(context)}';
      badgeColor = Colors.orange.withValues(alpha: 0.14);
      badgeLabel = 'ساعات خاصة';
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: SizeConfig.padding(all: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'استثناء لتاريخ: ${_dateLabel(selectedDate)}',
                    style: AppTextStyles.body14.copyWith(
                      fontSize: SizeConfig.ts(13.8),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.borderLight.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppTextStyles.label12.copyWith(
                      fontSize: SizeConfig.ts(11.5),
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(10)),
            _InfoLine(icon: Icons.schedule, text: defaultText),
            SizedBox(height: SizeConfig.h(8)),
            _InfoLine(icon: Icons.info_outline, text: currentText),
            if (currentException != null) ...[
              SizedBox(height: SizeConfig.h(10)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onClearException,
                  child: Text(
                    'حذف الاستثناء',
                    style: AppTextStyles.body14.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: SizeConfig.ts(12.2),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: SizeConfig.h(6)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCloseDay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0,
                      padding: SizeConfig.padding(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radius(14)),
                      ),
                    ),
                    child: Text(
                      'إغلاق اليوم',
                      style: AppTextStyles.body14.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: SizeConfig.ts(12.8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.w(10)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onModifyHours,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 0,
                      padding: SizeConfig.padding(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radius(14)),
                      ),
                    ),
                    child: Text(
                      'تعديل الساعات',
                      style: AppTextStyles.body14.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: SizeConfig.ts(12.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(10)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.85),
                ),
              ),
              child: Text(
                'ملاحظة: الاستثناءات تطغى على القالب الأسبوعي لهذا التاريخ فقط.',
                style: AppTextStyles.body14.copyWith(
                  fontSize: SizeConfig.ts(12.1),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: SizeConfig.ts(16), color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
